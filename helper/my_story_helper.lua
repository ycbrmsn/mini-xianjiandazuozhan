-- 我的剧情工具类
MyStoryHelper = {
  winPlayer = nil
}

function MyStoryHelper.init ()
  story1 = Story1:new()
  StoryHelper.setStorys({ story1 })
end

-- 玩家获得道具
EventHelper.addEvent('playerAddItem', function (objid, itemid, itemnum)
  if (itemid == MyMap.ITEM.GREEN_SOFT_STONE_ID) then -- 判断是否集齐碎片
    BackpackHelper.removeGridItemByItemID(objid, itemid, 1) -- 销毁绿色软石块
    local num = BackpackHelper.getItemNumAndGrid(objid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
    local player = PlayerHelper.getPlayer(objid)
    local actor = player:getClickActor()
    if (num < 100) then
      actor:speakTo(objid, 0, '年轻人勿打诳语啊……')
    else
      actor:speakTo(objid, 0, '好，我这就施展大挪移之术。')
      if (not(MyStoryHelper.winPlayer)) then
        MyStoryHelper.winPlayer = player
        TimeHelper.callFnFastRuns(function ()
          PlayerHelper.setGameWin(objid)
        end, 2)
      end
    end
  elseif (itemid == MyMap.ITEM.BLUE_SOFT_STONE_ID) then -- 维修仙剑
    BackpackHelper.removeGridItemByItemID(objid, itemid, 1) -- 销毁蓝色软石块
    for i, v in ipairs(MyItemHelper.swords) do
      local num, grids = BackpackHelper.getItemNumAndGrid2(objid, v)
      for j, gridid in ipairs(grids) do
        local durcur, durmax = BackpackHelper.getGridDurability(objid, gridid)
        BackpackHelper.setGridItem(objid, gridid, v, 1, durmax)
      end
    end
  elseif (itemid == MyMap.ITEM.PURPLE_SOFT_STONE_ID) then -- 查询碎片数量
    BackpackHelper.removeGridItemByItemID(objid, itemid, 1) -- 销毁紫色软石块
    local teamInfos = { [1] = { max = 0 }, [2] = { max = 0 } }
    for i, v in ipairs(PlayerHelper.getActivePlayers()) do
      local teamid = PlayerHelper.getTeam(v.objid)
      if (teamid) then
        local num = BackpackHelper.getItemNumAndGrid(v.objid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
        local info = teamInfos[teamid]
        if (info.max < num) then
          info.max = num
          info.maxPlayer = v:getName()
        end
      end
    end
    local player = PlayerHelper.getPlayer(objid)
    local actor = player:getClickActor()
    local second = 0
    local info = teamInfos[1]
    if (info.maxPlayer) then
      actor:speakTo(objid, second, '目前红队搜集碎片最多的玩家是#G', info.maxPlayer)
      second = second + 2
      actor:speakTo(objid, second, '嗯，已经搜集了#G', info.max, '#W枚碎片')
    else
      actor:speakTo(objid, second, '目前红队还没有人搜集到碎片')
    end
    second = second + 2
    info = teamInfos[2]
    if (info.maxPlayer) then
      actor:speakTo(objid, second, '目前蓝队搜集碎片最多的玩家是#G', info.maxPlayer)
      second = second + 2
      actor:speakTo(objid, second, '嗯，已经搜集了#G', info.max, '#W枚碎片')
    else
      actor:speakTo(objid, second, '目前蓝队还没有人搜集到碎片')
    end
  end
end)
