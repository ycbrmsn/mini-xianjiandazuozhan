-- 我的玩家工具类
MyPlayerHelper = {
  hourseid = 4300173509
}

-- 事件

-- 玩家进入游戏
function MyPlayerHelper:playerEnterGame (objid)
  PlayerHelper:playerEnterGame(objid)
  MyStoryHelper:playerEnterGame(objid)
end

-- 玩家离开游戏
function MyPlayerHelper:playerLeaveGame (objid)
  PlayerHelper:playerLeaveGame(objid)
  MyStoryHelper:playerLeaveGame(objid)
end

-- 玩家进入区域
function MyPlayerHelper:playerEnterArea (objid, areaid)
  PlayerHelper:playerEnterArea(objid, areaid)
  MyStoryHelper:playerEnterArea(objid, areaid)
end

-- 玩家离开区域
function MyPlayerHelper:playerLeaveArea (objid, areaid)
  PlayerHelper:playerLeaveArea(objid, areaid)
  MyStoryHelper:playerLeaveArea(objid, areaid)
end

-- 玩家点击方块
function MyPlayerHelper:playerClickBlock (objid, blockid, x, y, z)
  PlayerHelper:playerClickBlock(objid, blockid, x, y, z)
  MyStoryHelper:playerClickBlock(objid, blockid, x, y, z)
  -- body
  local blockid = BlockHelper:getBlockID(x, y, z)
  if (MyBed:isBed(blockid)) then
    -- 处理床
    PlayerHelper:showToast(objid, '你无法在别人的床上睡觉')
  end
end

-- 玩家点击生物
function MyPlayerHelper:playerClickActor (objid, toobjid)
  PlayerHelper:playerClickActor(objid, toobjid)
  MyStoryHelper:playerClickActor(objid, toobjid)
end

-- 玩家获得道具
function MyPlayerHelper:playerAddItem (objid, itemid, itemnum)
  PlayerHelper:playerAddItem(objid, itemid, itemnum)
  MyStoryHelper:playerAddItem(objid, itemid, itemnum)
end

-- 玩家使用道具
function MyPlayerHelper:playerUseItem (objid, itemid)
  PlayerHelper:playerUseItem(objid, itemid)
  MyStoryHelper:playerUseItem(objid, itemid)
end

-- 玩家攻击命中
function MyPlayerHelper:playerAttackHit (objid, toobjid)
  PlayerHelper:playerAttackHit(objid, toobjid)
  MyStoryHelper:playerAttackHit(objid, toobjid)
end

-- 玩家造成伤害
function MyPlayerHelper:playerDamageActor (objid, toobjid)
  PlayerHelper:playerDamageActor(objid, toobjid)
  MyStoryHelper:playerDamageActor(objid, toobjid)
end

-- 玩家击败生物
function MyPlayerHelper:playerDefeatActor (playerid, objid)
  PlayerHelper:playerDefeatActor(playerid, objid)
  MyStoryHelper:playerDefeatActor(playerid, objid)
end

-- 玩家受到伤害
function MyPlayerHelper:playerBeHurt (objid, toobjid)
  PlayerHelper:playerBeHurt(objid, toobjid)
  MyStoryHelper:playerBeHurt(objid, toobjid)
end

-- 玩家死亡
function MyPlayerHelper:playerDie (objid, toobjid)
  PlayerHelper:playerDie(objid, toobjid)
  MyStoryHelper:playerDie(objid, toobjid)
end

-- 玩家复活
function MyPlayerHelper:playerRevive (objid, toobjid)
  PlayerHelper:playerRevive(objid, toobjid)
  MyStoryHelper:playerRevive(objid, toobjid)
end

-- 玩家选择快捷栏
function MyPlayerHelper:playerSelectShortcut (objid)
  PlayerHelper:playerSelectShortcut(objid)
  MyStoryHelper:playerSelectShortcut(objid)
end

-- 玩家快捷栏变化
function MyPlayerHelper:playerShortcutChange (objid)
  PlayerHelper:playerShortcutChange(objid)
  MyStoryHelper:playerShortcutChange(objid)
end

-- 玩家运动状态改变
function MyPlayerHelper:playerMotionStateChange (objid, playermotion)
  PlayerHelper:playerMotionStateChange(objid, playermotion)
  MyStoryHelper:playerMotionStateChange(objid, playermotion)
end

-- 玩家移动一格
function MyPlayerHelper:playerMoveOneBlockSize (objid)
  PlayerHelper:playerMoveOneBlockSize(objid)
  MyStoryHelper:playerMoveOneBlockSize(objid)
  -- body
  local player = PlayerHelper:getPlayer(objid)
  local pos = player:getMyPosition()
  -- 高度
  local t = objid .. 'flyTooHigh'
  if (pos.y >= 100 and not(player.isTooHigh)) then
    player.isTooHigh = true
    local idx = 0
    TimeHelper:callFnContinueRuns(function ()
      if (idx % 20 == 0) then
        player:recoverHp(-5)
      end
      idx = idx + 1
    end, -1, t)
    ChatHelper:sendSystemMsg('飞行过高，你觉得有些不适', objid)
  elseif (player.isTooHigh and pos.y < 100) then
    player.isTooHigh = false
    TimeHelper:delFnContinueRuns(t)
    ChatHelper:sendSystemMsg('你觉得好多了', objid)
  end
  -- 四周太远
  local t2 = objid .. 'flyTooFar'
  if ((pos.x >= 129 or pos.x <= -111 or pos.z >= 161 or pos.z <= -99) and not(player.isTooFar)) then
    player.isTooFar = true
    local idx2 = 0
    local timeGap = 200
    TimeHelper:callFnContinueRuns(function ()
      idx2 = idx2 + 1
      if (idx2 % timeGap == 0) then
        local p = player:getDistancePosition(10)
        local playerPos = player:getMyPosition()
        playerPos.x = playerPos.x + math.random(-2, 2)
        playerPos.y = playerPos.y + math.random(-2, 3)
        playerPos.z = playerPos.z + math.random(-2, 2)
        WorldHelper:spawnProjectileByPos(self.hourseid, 
          MyWeaponAttr.tenThousandsSword.projectileid, p, playerPos, 100)
        -- 重置计数
        idx2 = 0
        if (timeGap > 20) then
          timeGap = timeGap - 20
        elseif (timeGap > 5) then
          timeGap = timeGap - 5
        end
      end
    end, -1, t2)
    ChatHelper:sendSystemMsg('飞行过远，你仿佛觉得被什么东西盯住了', objid)
  elseif (player.isTooFar and (pos.x > -111 and pos.x < 129 and pos.z > -99 and pos.z < 161)) then
    player.isTooFar = false
    TimeHelper:delFnContinueRuns(t2)
    ChatHelper:sendSystemMsg('被盯住的感觉消失了，你觉得轻松多了', objid)
  end
end

-- 玩家骑乘
function MyPlayerHelper:playerMountActor (objid, toobjid)
  PlayerHelper:playerMountActor(objid, toobjid)
  MyStoryHelper:playerMountActor(objid, toobjid)
end

-- 玩家取消骑乘
function MyPlayerHelper:playerDismountActor (objid, toobjid)
  PlayerHelper:playerDismountActor(objid, toobjid)
  MyStoryHelper:playerDismountActor(objid, toobjid)
end