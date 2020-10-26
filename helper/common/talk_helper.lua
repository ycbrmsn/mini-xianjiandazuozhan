-- 对话工具类
TalkHelper = {
  prevTalkInfos = {}, -- { 玩家 -> 上次对话 } { playerid -> talkInfos }
  talkProgress = {}, -- { playerid -> { talkid -> talkProgress } }
  tasks = {}, -- { 玩家 -> 任务id数组 } { playerid -> { taskid } }
}

-- 玩家当前会话
function TalkHelper:getPrevTalkInfo (playerid)
  return self.prevTalkInfos[playerid]
end

-- 设置玩家当前会话
function TalkHelper:setPrevTalkInfo (playerid, talkInfo)
  self.prevTalkInfos[playerid] = talkInfo
end

-- 获取会话进度
function TalkHelper:getProgress (playerid, talkid)
  if (not(self.talkProgress[playerid])) then
    self.talkProgress[playerid] = {}
  end
  if (not(self.talkProgress[playerid][talkid])) then
    self.talkProgress[playerid][talkid] = 1
  end
  return self.talkProgress[playerid][talkid]
end

-- 设置会话进度
function TalkHelper:setProgress (playerid, talkid, talkProgress)
  local progress = TalkHelper:getProgress(playerid, talkid)
  if (progress ~= talkProgress) then
    self.talkProgress[playerid][talkid] = talkProgress
  end
end

-- 玩家是否有该任务
function TalkHelper:hasTask (playerid, taskid)
  local taskids = TalkHelper:getTaskids(playerid)
  for i, v in ipairs(taskids) do
    if (v == taskid) then
      -- LogHelper:debug('hasTask')
      return true
    end
  end
  -- LogHelper:debug('noTask', playerid)
  return false
end

-- 获取玩家已领取的所有任务id
function TalkHelper:getTaskids (playerid)
  if (not(self.tasks[playerid])) then
    self.tasks[playerid] = {}
  end
  return self.tasks[playerid]
end

-- 玩家新增任务
function TalkHelper:addTask (playerid, taskid)
  local taskids = TalkHelper:getTaskids(playerid)
  table.insert(taskids, taskid)
end

-- 是否满足条件
function TalkHelper:isMeet (playerid, talkInfo)
  local ants = talkInfo.ants
  if (not(ants)) then
    return true
  end
  for i, ant in ipairs(ants) do
    if (ant.t == 1) then -- 前置必需任务
      if (not(TalkHelper:hasTask(playerid, ant.taskid))) then
        return false
      end
    elseif (ant.t == 2) then -- 前置互斥任务
      if (TalkHelper:hasTask(playerid, ant.taskid)) then
        return false
      end
    elseif (ant.t == 3) then -- 世界时间
      local hour = TimeHelper:getHour()
      if (not(hour >= ant.beginHour and hour < ant.endHour)) then
        return false
      end
    elseif (ant.t == 4) then -- 拥有道具
      -- LogHelper:debug('道具')
      if (not(BackpackHelper:hasItem(playerid, ant.itemid, true))) then
        -- LogHelper:debug('没道具')
        return false
      end
    end
  end
  return true
end

-- 返回会话信息
function TalkHelper:getTalkInfo (playerid, actor)
  local talkInfos = actor.talkInfos
  if (talkInfos and #talkInfos > 0) then
    for i, talkInfo in ipairs(talkInfos) do
      if (TalkHelper:isMeet(playerid, talkInfo)) then -- 满足一项
        local prevTalkInfo = TalkHelper:getPrevTalkInfo(playerid)
        local talkIndex = TalkHelper:getTalkIndex(playerid, actor)
        if (prevTalkInfo and prevTalkInfo ~= talkInfo and talkIndex ~= 1) then -- 表示突然不满足条件了
          TalkHelper:resetTalkIndex(playerid, actor, index)
          ChatHelper:showBreakSeparate(playerid)
        end
        return talkInfo
      end
    end
  end
  return nil
end

-- NPC与玩家对话
function TalkHelper:talkWith (playerid, actor)
  local sessions = TalkHelper:getSessions(playerid, actor)
  if (sessions) then
    local index = TalkHelper:getTalkIndex(playerid, actor)
    local session = sessions[index]
    if (session) then
      TalkHelper:handleTalkSession(playerid, actor, session, #sessions)
    else
      if (actor.defaultTalkMsg) then
        actor:speakTo(playerid, 0, actor.defaultTalkMsg)
        ChatHelper:showEndSeparate(playerid)
      end
    end
  else
    if (actor.defaultTalkMsg) then
      actor:speakTo(playerid, 0, actor.defaultTalkMsg)
      ChatHelper:showEndSeparate(playerid)
    end
  end
end

function TalkHelper:getSessions (playerid, actor)
  local talkInfo = TalkHelper:getTalkInfo(playerid, actor)
  if (not(talkInfo)) then -- 没有会话
    return nil
  end
  local talkProgress = TalkHelper:getProgress(playerid, talkInfo.id)
  local sessions = talkInfo.progress[talkProgress]
  if (not(sessions)) then -- 没找到对应会话
    sessions = talkInfo.progress[0] -- 任意进度均此对话
    if (not(sessions)) then -- 任意进度对话也没有
      return nil
    end
  end
  return sessions
end

function TalkHelper:getTalkIndex (playerid, actor)
  local index = actor.talkIndex[playerid]
  if (not(index)) then
    index = 1
    actor.talkIndex[playerid] = index
  end
  return index
end

-- 对话序数跳转 默认跳一个
function TalkHelper:turnTalkIndex (playerid, actor, max, index)
  if (not(index)) then
    index = TalkHelper:getTalkIndex(playerid, actor) + 1
  end
  if (index > max or index == -1) then
    index = 1
    actor.talkIndex[playerid] = index
    ChatHelper:showEndSeparate(playerid)
    return false
  else
    actor.talkIndex[playerid] = index
    return true
  end
end

-- 重置序数
function TalkHelper:resetTalkIndex (playerid, actor, index)
  actor.talkIndex[playerid] = index or 1
end

function TalkHelper:handleTalkSession (playerid, actor, session, max)
  local player = PlayerHelper:getPlayer(playerid)
  if (session.t == 1) then
    actor:speakTo(playerid, 0, session.msg)
    if (session.f) then
      session.f(player)
    end
    TalkHelper:turnTalkIndex(playerid, actor, max, session.turnTo)
  elseif (session.t == 2) then
    actor:thinkTo(playerid, 0, session.msg)
    if (session.f) then
      session.f(player)
    end
    TalkHelper:turnTalkIndex(playerid, actor, max, session.turnTo)
  elseif (type(session.msg) == 'table') then -- 选项
    ChatHelper:showChooseItems(playerid, session.msg, 'msg')
    -- ChatHelper:sendMsg(playerid, '---------')
    -- for i, v in ipairs(session.msg) do
    --   ChatHelper:sendMsg(playerid, v.msg)
    -- end
    player.whichChoose = 'talk'
    if (session.f) then
      session.f(player)
    end
  else -- 对话
    if (session.t == 3) then
      player:speakSelf(0, session.msg)
    elseif (session.t == 4) then
      player:thinkSelf(0, session.msg)
    end
    if (session.f) then
      session.f(player)
    end
    TalkHelper:turnTalkIndex(playerid, actor, max, session.turnTo)
  end
end

-- 选择对话
function TalkHelper:chooseTalk (playerid)
  local player = PlayerHelper:getPlayer(playerid)
  local actor = player:getClickActor()
  if (not(actor)) then -- 没有选择过特定生物
    return
  end
  local sessions = TalkHelper:getSessions(playerid, actor)
  if (not(sessions)) then
    return
  end
  local index = TalkHelper:getTalkIndex(playerid, actor)
  local session = sessions[index]
  if (not(session) or type(session.msg) ~= 'table') then -- 当前不是选择项
    return
  end
  local index = PlayerHelper:getCurShotcut(playerid) + 1
  if (index > #session.msg) then -- 没有该选项
    return
  end
  -- 选择了
  local playerTalk = session.msg[index]
  local max = #sessions
  if (playerTalk.f) then
    playerTalk.f(player)
  end
  if (not(playerTalk.t) or playerTalk.t == 1) then -- 继续
    if (TalkHelper:turnTalkIndex(playerid, actor, max)) then
      TalkHelper:talkWith(playerid, actor)
    end
  elseif (playerTalk.t == 2) then -- 跳转
    if (TalkHelper:turnTalkIndex(playerid, actor, max, playerTalk.other)) then
      TalkHelper:talkWith(playerid, actor)
    end
  elseif (playerTalk.t == 3) then -- 终止
    TalkHelper:turnTalkIndex(playerid, actor, max, max + 1)
  elseif (playerTalk.t == 4) then -- 任务

  end
end

-- 重置进度对话
function TalkHelper:resetProgressContent (actor, talkid, progressid, sessions)
  local talkInfos = actor.talkInfos
  if (talkInfos and #talkInfos > 0) then
    for i, talkInfo in ipairs(talkInfos) do
      if (talkInfo.id == talkid) then
        talkInfo.progress[progressid] = sessions
        return true
      end
    end
  end
  return false
end