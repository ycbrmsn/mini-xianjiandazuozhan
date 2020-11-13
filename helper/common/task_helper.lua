-- 任务工具类
TaskHelper = {
  tasks = {}, -- { 玩家 -> 任务id数组 } { playerid -> { taskid } }
}

-- 玩家是否有该任务
function TaskHelper:hasTask (playerid, taskid)
  local tasks = TaskHelper:getTasks(playerid)
  if (tasks[taskid]) then
    return true
  else
    return false
  end
end

-- 获取任务
function TaskHelper:getTask (playerid, taskid)
  local tasks = TaskHelper:getTasks(playerid)
  return tasks[taskid]
end

-- 获取玩家已领取的所有任务
function TaskHelper:getTasks (playerid)
  if (not(self.tasks[playerid])) then
    self.tasks[playerid] = {}
  end
  return self.tasks[playerid]
end

-- 获取未结束的有效任务 state(任务状态1未完成2已完成3已结束)
function TaskHelper:getActiveTasks (playerid, state)
  local tasks = {}
  for taskid, task in pairs(TaskHelper:getTasks(playerid)) do
    if (type(task) == 'table') then
      if (state) then
        local taskState = TaskHelper:getTaskState(playerid, taskid)
        if (state == taskState) then
          tasks[taskid] = task
        end
      elseif (not(task.finish)) then
        tasks[taskid] = task
      end
    end
  end
  return tasks
end

-- 新增玩家任务
function TaskHelper:addTask (playerid, taskid, task)
  local tasks = TaskHelper:getTasks(playerid)
  if (task) then -- 有具体任务
    tasks[taskid] = task
  else
    tasks[taskid] = true
  end
end

-- 删除玩家任务
function TaskHelper:removeTask (playerid, taskid)
  local tasks = TaskHelper:getTasks(playerid)
  if (tasks[taskid]) then
    tasks[taskid] = nil
    return true
  else
    return false
  end
end

-- 删除一些玩家任务
function TaskHelper:removeTasks (playerid, tids)
  local result = true
  for i, taskid in ipairs(tids) do
    if (not(TaskHelper:removeTask(playerid, taskid))) then
      result = false
    end
  end
  return result
end

-- 清空所有任务
function TaskHelper:clearTask (playerid)
  self.tasks[playerid] = {}
end

-- 结束任务
function TaskHelper:finishTask (playerid, taskid)
  local state = TaskHelper:getTaskState(playerid, taskid)
  if (state == 1) then
    return false
  elseif (state == 3) then
    return true
  else
    local task = TaskHelper:getTask(playerid, taskid)
    if (task.category == 2) then -- 交付道具
      for i, itemInfo in ipairs(task.itemInfos) do
        BackpackHelper:removeGridItemByItemID(playerid, itemInfo.itemid, itemInfo.num)
      end
    end
    for i, reward in ipairs(task.rewards) do
      if (reward.category == 1) then -- 道具
        BackpackHelper:gainItem(playerid, reward.itemid, reward.num)
      elseif (reward.category == 2) then -- 经验
        local player = PlayerHelper:getPlayer(playerid)
        player:gainExp(reward.num)
      end
    end
    task.finish = true
    return true
  end
end

-- 玩家任务状态(1未完成2已完成3已结束)
function TaskHelper:getTaskState (playerid, taskid)
  local task = TaskHelper:getTask(playerid, taskid)
  if (type(task) == 'table') then -- 具体任务
    if (task.finish) then
      return 3
    elseif (task:isComplete(playerid)) then
      return 2
    else
      return 1
    end
  else
    return 3
  end
end

-- 击杀角色
function TaskHelper:killActor (playerid, actorid, isShow)
  local tasks = TaskHelper:getActiveTasks(playerid)
  for taskid, task in pairs(tasks) do -- 所有任务
    if (type(task) == 'table' and task.category == 1) then -- 击败任务
      for i, beatInfo in ipairs(task.beatInfos) do
        if (actorid == beatInfo.actorid) then -- 击败该生物
          beatInfo.curnum = beatInfo.curnum + 1
          if (isShow and beatInfo.curnum <= beatInfo.num) then -- 未超过任务数量
            ChatHelper:sendMsg(playerid, '击败', beatInfo.actorname, '（', beatInfo.curnum,
              '/', beatInfo.num, '）')
            local state = TaskHelper:getTaskState(playerid, taskid)
            if (state == 2) then
              ChatHelper:sendMsg(playerid, '#G', task.name, '任务#n可交付')
            end
          end
        end
      end
    end
  end
end

-- 获得道具
function TaskHelper:addItem (playerid, itemid, isShow)
  local tasks = TaskHelper:getActiveTasks(playerid)
  for taskid, task in pairs(tasks) do -- 所有任务
    if (type(task) == 'table' and task.category == 2) then -- 交付任务
      for i, itemInfos in ipairs(task.itemInfos) do
        if (itemid == itemInfos.itemid) then -- 获得该道具
          local curnum = BackpackHelper:getItemNumAndGrid(playerid, itemid)
          if (isShow and curnum <= itemInfos.num) then -- 未超过任务数量
            ChatHelper:sendMsg(playerid, '获得', ItemHelper:getItemName(itemid),
              '（', curnum, '/', itemInfos.num, '）')
            local state = TaskHelper:getTaskState(playerid, taskid)
            if (state == 2) then
              ChatHelper:sendMsg(playerid, '#G', task.name, '任务#n可交付')
            end
          end
        end
      end
    end
  end
end

-- 插入选项
function TaskHelper:appendPlayerTalk (playerTalks, player, taskid, taskname)
  if (TaskHelper:hasTask(player.objid, taskid * 10)) then -- 已有任务
    local state = TaskHelper:getTaskState(player.objid, taskid * 10)
    if (state == 1) then -- 未完成
      table.insert(playerTalks, PlayerTalk:new('询问' .. taskname .. '任务', 1, nil, function (player)
        TaskHelper:addTask(player.objid, taskid * 100)
        player:resetTalkIndex(0)
      end))
    elseif (state == 2) then -- 已完成
      table.insert(playerTalks, PlayerTalk:new('交付' .. taskname .. '任务', 1, nil, function (player)
        TaskHelper:addTask(player.objid, taskid * 100 + 1)
        player:resetTalkIndex(0)
      end))
    else -- 已结束
    end
  else -- 未接任务
    table.insert(playerTalks, PlayerTalk:new(taskname .. '任务', 1, nil, function (player)
      TaskHelper:addTask(player.objid, taskid)
      player:resetTalkIndex(0)
    end))
  end
end

-- 生成接任务对话
function TaskHelper:generateAcceptTalk (taskid, talks, cTask)
  local sessions = {}
  for i, v in ipairs(talks) do
    if (i ~= #talks) then
      table.insert(sessions, TalkSession:new(v[1], v[2]))
    else
      table.insert(sessions, TalkSession:new(5, {
        PlayerTalk:new('接受', 3, nil, function (player, actor)
          local task = cTask:new(taskid * 10, actor.actorid, actor:getName())
          TaskHelper:addTask(player.objid, task.id, task)
          player:speakSelf(0, v[1])
        end),
        PlayerTalk:new('拒绝', 3, nil, function (player, actor)
          player:speakSelf(0, v[2])
        end),
      }))
    end
  end
  return TalkInfo:new({
    id = taskid,
    ants = {
      TalkAnt:new({ t = 1, taskid = taskid }),
      TalkAnt:new({ t = 2, taskid = taskid * 10 }),
    },
    progress = {
      [0] = sessions
    }
  })
end

-- 生成查询任务对话
function TaskHelper:generateQueryTalk (taskid, talks)
  local sessions = {}
  for i, v in ipairs(talks) do
    table.insert(sessions, TalkSession:new(v[1], v[2]))
  end
  return TalkInfo:new({
    id = taskid * 100,
    ants = {
      TalkAnt:new({ t = 1, taskid = taskid * 100 }),
    },
    progress = {
      [0] = sessions
    },
  })
end

-- 生成交付任务对话
function TaskHelper:generatePayTalk (taskid, talks)
  local sessions = {}
  for i, v in ipairs(talks) do
    if (i ~= #talks) then
      table.insert(sessions, TalkSession:new(v[1], v[2]))
    else
      table.insert(sessions, TalkSession:new(v[1], v[2], function (player)
        TaskHelper:finishTask(player.objid, taskid * 10)
      end))
    end
  end
  return TalkInfo:new({
    id = taskid * 100 + 1,
    ants = {
      TalkAnt:new({ t = 1, taskid = taskid * 100 + 1 }),
      TalkAnt:new({ t = 1, taskid = taskid * 10, state = 2 }),
    },
    progress = {
      [0] = sessions
    },
  })
end