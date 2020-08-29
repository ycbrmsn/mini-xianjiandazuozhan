-- 我的玩家工具类
MyPlayerHelper = {
  initPosition = MyPosition:new(3, 10, 42),
  disableThrowItems = {
    MyMap.ITEM.ENERGY_FRAGMENT_ID, -- 能量碎片
    MyWeaponAttr.controlSword.levelIds[1], -- 御仙剑
    MyWeaponAttr.tenThousandsSword.levelIds[1], -- 万仙剑
    MyWeaponAttr.huixianSword.levelIds[1], -- 回仙剑
    MyWeaponAttr.vitalqiSword.levelIds[1] -- 气仙剑
  }
}

function MyPlayerHelper:sendTeamMsg (objid)
  local teams = { [0] = 0, [1] = 0, [2] = 0 } -- 队伍人数
  local players = PlayerHelper:getAllPlayers()
  for i, v in ipairs(players) do
    if (v:isActive() and v.objid ~= objid) then
      local team = PlayerHelper:getTeam(v.objid)
      if (teams[team]) then
        teams[team] = teams[team] + 1
      else
        teams[team] = 1
      end
    end
  end
  local teamMap = {}
  for k, v in pairs(teams) do
    teamMap[k] = StringHelper:int2Chinese(v)
  end
  ChatHelper:sendTemplateMsg(MyTemplate.TEAM_MSG, teamMap, objid)
end

-- 事件

-- 玩家进入游戏
function MyPlayerHelper:playerEnterGame (objid)
  local isEntered = PlayerHelper:playerEnterGame(objid)
  MyStoryHelper:playerEnterGame(objid)
  -- body
  PlayerHelper:teleportHome(objid)
  local player = PlayerHelper:getPlayer(objid)
  -- player:setPosition(self.initPosition)
  player:updateMaxHp()
  -- 不可丢弃
  for i, v in ipairs(self.disableThrowItems) do
    PlayerHelper:setItemDisableThrow(objid, v)
  end
  -- 播放背景音乐
  MusicHelper:startBGM(objid, 1, true)
  -- 提示队伍人数
  -- if (player ~= PlayerHelper:getHostPlayer()) then
  --   MyPlayerHelper:sendTeamMsg(objid)
  -- end
end

-- 玩家离开游戏
function MyPlayerHelper:playerLeaveGame (objid)
  PlayerHelper:playerLeaveGame(objid)
  MyStoryHelper:playerLeaveGame(objid)
  -- body
  -- 停止背景音乐
  MusicHelper:stopBGM(objid)
end

-- 玩家进入区域
function MyPlayerHelper:playerEnterArea (objid, areaid)
  PlayerHelper:playerEnterArea(objid, areaid)
  MyStoryHelper:playerEnterArea(objid, areaid)
  -- body
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
  -- body
  if (itemid == MyMap.ITEM.MUSIC_PLAYER_ID) then -- 音乐播放器
    local index = PlayerHelper:getCurShotcut(objid)
    if (index == 5) then -- 调大声音
      MusicHelper:modulateVolume(objid, 1)
    elseif (index == 6) then -- 调小声音
      MusicHelper:modulateVolume(objid, -1)
    elseif (index == 7) then -- 重置音乐选项
      MusicHelper:changeBGM(objid, 1, true, true)
      ChatHelper:sendMsg(objid, '音乐及音量重置完成')
    else
      ChatHelper:sendMsg(objid, '当前处于快捷栏第', index + 1, '格，暂无对应功能')
    end
  end
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

-- 玩家击败目标
function MyPlayerHelper:playerDefeatActor (objid, toobjid)
  PlayerHelper:playerDefeatActor(objid, toobjid)
  MyStoryHelper:playerDefeatActor(objid, toobjid)
  -- body
  if (ActorHelper:isPlayer(toobjid)) then -- 击败玩家获得碎片
    local toPlayer = PlayerHelper:getPlayer(toobjid)
    local num = math.random(5, 9)
    BackpackHelper:addItem(objid, MyMap.ITEM.ENERGY_FRAGMENT_ID, num)
    local msg = StringHelper:concat('击败#G', toPlayer:getName(), '#n获得', num, '枚碎片')
    ChatHelper:sendSystemMsg(msg, objid)
  end
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
  -- body
  -- 恢复最大生命值
  local player = PlayerHelper:getPlayer(objid)
  player:updateMaxHp()
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
  if (pos.y >= 80 and not(player.isTooHigh)) then
    player.isTooHigh = true
    local idx = 0
    TimeHelper:callFnContinueRuns(function ()
      if (idx % 20 == 0) then
        player:recoverHp(-25)
      end
      idx = idx + 1
    end, -1, t)
    ChatHelper:sendSystemMsg('飞行过高，你觉得有些不适', objid)
  elseif (player.isTooHigh and pos.y < 80) then
    player.isTooHigh = false
    TimeHelper:delFnContinueRuns(t)
    ChatHelper:sendSystemMsg('你觉得好多了', objid)
  end
  -- 四周太远
  local t2 = objid .. 'flyTooFar'
  if ((pos.x >= 90 or pos.x <= -90 or pos.z >= 130 or pos.z <= -50) and not(player.isTooFar)) then
    player.isTooFar = true
    local idx2 = 0
    local timeGap = 200
    TimeHelper:callFnContinueRuns(function ()
      idx2 = idx2 + 1
      if (idx2 % timeGap == 0) then
        local p = player:getDistancePosition(10)
        local playerPos = player:getMyPosition()
        if (idx2 % 2 == 0) then
          playerPos.x = playerPos.x + math.random(-2, 2)
          playerPos.y = playerPos.y + math.random(-2, 3)
          playerPos.z = playerPos.z + math.random(-2, 2)
        end
        WorldHelper:spawnProjectileByPos(nil, 
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
  elseif (player.isTooFar and (pos.x > -90 and pos.x < 90 and pos.z > -50 and pos.z < 130)) then
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

-- 聊天输出界面变化
function MyPlayerHelper:playerInputContent(objid, content)
  PlayerHelper:playerInputContent(objid, content)
  MyStoryHelper:playerInputContent(objid, content)
end

-- 输入字符串
function MyPlayerHelper:playerNewInputContent(objid, content)
  PlayerHelper:playerNewInputContent(objid, content)
  MyStoryHelper:playerNewInputContent(objid, content)
end