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

-- 结束任务
function TaskHelper:finishTask (playerid, taskid)
  local task = TaskHelper:getTask(playerid, taskid)
  if (type(task) == 'table') then
    task.finish = true
    return true
  else
    return false
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
    return true
  end
end

-- 击杀角色
function TaskHelper:killActor (playerid, actorid, isShow)
  local tasks = TaskHelper:getTasks(playerid)
  for taskid, task in pairs(tasks) do -- 所有任务
    if (type(task) == 'table' and task.category == 1) then -- 击败任务
      for i, beatInfo in ipairs(task.beatInfos) do
        if (beatInfo.actorid == actorid) then -- 击败该生物
          beatInfo.curnum = beatInfo.curnum + 1
          if (isShow and beatInfo.curnum <= beatInfo.num) then -- 未超过任务数量
            ChatHelper:sendMsg(playerid, '击败', beatInfo.actorname, '：', beatInfo.curnum,
              '', beatInfo.num)
          end
        end
      end
    end
  end
end