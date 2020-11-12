-- 我的对话工具类
MyTalkHelper = {
  needRemoveTasks = { 11, 12, 13, 14, 21, 2100, 2101, 22, 2200, 2201, 23, 2300, 2301,
    24, 2400, 2401, 25, 2500, 2501, 26, 2600, 2601, 27, 2700, 2701, 28, 2800, 2801,
    29, 2900, 2901, 30, 3000, 3001, 31, 3100, 3101, 32, 3200, 3201, 5100, 5101, 5200,
    5201 }
}

-- 显示对话结束分隔
function MyTalkHelper:showEndSeparate (objid)
  TaskHelper:removeTasks(objid, self.needRemoveTasks)
  ChatHelper:showEndSeparate(objid)
end

-- 显示对话中止分隔
function MyTalkHelper:showBreakSeparate (objid)
  TaskHelper:removeTasks(objid, self.needRemoveTasks)
  ChatHelper:showBreakSeparate(objid)
end

-- 查询碎片
function MyTalkHelper:queryFragment (actor)
  local teamInfos = { [1] = { max = 0 }, [2] = { max = 0 } }
  for i, v in ipairs(PlayerHelper:getActivePlayers()) do
    local teamid = PlayerHelper:getTeam(v.objid)
    if (teamid) then
      local num = BackpackHelper:getItemNumAndGrid(v.objid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
      local info = teamInfos[teamid]
      if (info.max < num) then
        info.max = num
        info.maxPlayer = v:getName()
      end
    end
  end
  TalkHelper:clearProgressContent(actor, 12, 0, 3)
  local sessions = {}
  local info = teamInfos[1]
  if (info.maxPlayer) then
    table.insert(sessions, TalkSession:new(1, '目前红队搜集碎片最多的玩家是#G' .. info.maxPlayer))
    table.insert(sessions, TalkSession:new(1, '嗯，已经搜集了#G' .. info.max .. '#W枚碎片'))
  else
    table.insert(sessions, TalkSession:new(1, '目前红队还没有人搜集到碎片'))
  end
  info = teamInfos[2]
  if (info.maxPlayer) then
    table.insert(sessions, TalkSession:new(1, '目前蓝队搜集碎片最多的玩家是#G' .. info.maxPlayer))
    table.insert(sessions, TalkSession:new(1, '嗯，已经搜集了#G' .. info.max .. '#W枚碎片'))
  else
    table.insert(sessions, TalkSession:new(1, '目前蓝队还没有人搜集到碎片'))
  end
  TalkHelper:addProgressContents(actor, 12, 0, sessions)
end

-- 设置玩家胜利
function MyTalkHelper:setWinPlayer (player, actor)
  if (not(MyStoryHelper.winPlayer)) then
    MyStoryHelper.winPlayer = player
    TimeHelper:callFnFastRuns(function ()
      PlayerHelper:setGameWin(player.objid)
    end, 2)
    BackpackHelper:removeGridItemByItemID(player.objid, MyMap.ITEM.ENERGY_FRAGMENT_ID, 100)
    actor.action:playFree2()
    ActorHelper:playAndStopBodyEffect(actor.objid, BaseConstant.BODY_EFFECT.LIGHT4)
  end
end