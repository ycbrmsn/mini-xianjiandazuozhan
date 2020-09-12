-- 我的玩家工具类
MyPlayerHelper = {
  initPosition = MyPosition:new(3, 10, 42),
  disableThrowItems = {
    MyMap.ITEM.ENERGY_FRAGMENT_ID, -- 能量碎片
    MyWeaponAttr.controlSword.levelIds[1], -- 御仙剑
    MyWeaponAttr.tenThousandsSword.levelIds[1], -- 万仙剑
    MyWeaponAttr.huixianSword.levelIds[1], -- 回仙剑
    MyWeaponAttr.vitalqiSword.levelIds[1] -- 气仙剑
  },
  warn = {} -- { objid = {} }
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

-- 开启公告
function MyPlayerHelper:openAnnounce (content, delay)
  delay = delay or 120
  MyGameHelper.isAnnounceOpen = true
  TimeHelper:callFnFastRuns(function ()
    ChatHelper:sendMsg(nil, content)
    MyPlayerHelper:openAnnounce(content, delay)
  end, delay, MyGameHelper.announce)
end

-- 关闭公告
function MyPlayerHelper:closeAnnounce ()
  MyGameHelper.isAnnounceOpen = false
  TimeHelper:delFnFastRuns(MyGameHelper.announce)
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
  self.warn[objid] = nil
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
  -- body
  -- 能量碎片过多提示
  if (itemid == MyMap.ITEM.ENERGY_FRAGMENT_ID) then
    local num = BackpackHelper:getItemNumAndGrid(objid, itemid)
    local warnNum = nil
    if (num >= 100 and num - itemnum < 100) then
      warnNum = 100
    elseif (num >= 90 and num - itemnum < 90) then
      warnNum = 90
    elseif (num >= 80 and num - itemnum < 80) then
      warnNum = 80
    elseif (num >= 70 and num - itemnum < 70) then
      warnNum = 70
    end
    if (warnNum) then
      local info = self.warn[objid]
      if (not(info)) then
        info = {}
        self.warn[objid] = info
      end
      if (not(info[warnNum])) then
        info[warnNum] = true
        ChatHelper:sendMsg(nil, '注意：有玩家碎片数已达到#G', warnNum)
      end
    end
  end
end

-- 玩家使用道具
function MyPlayerHelper:playerUseItem (objid, toobjid, itemid, itemnum)
  PlayerHelper:playerUseItem(objid, toobjid, itemid, itemnum)
  MyStoryHelper:playerUseItem(objid, toobjid, itemid, itemnum)
  -- body
  if (itemid == MyMap.ITEM.MUSIC_PLAYER_ID) then -- 音乐播放器
    local index = PlayerHelper:getCurShotcut(objid)
    if (index == 3) then -- 加速
      MusicHelper:changeSpeed (objid, 1)
    elseif (index == 4) then -- 减速
      MusicHelper:changeSpeed (objid, -1)
    elseif (index == 5) then -- 调大声音
      MusicHelper:modulateVolume(objid, 1)
    elseif (index == 6) then -- 调小声音
      MusicHelper:modulateVolume(objid, -1)
    elseif (index == 7) then -- 重置音乐选项
      MusicHelper:changeBGM(objid, 1, true, true)
      ChatHelper:sendMsg(objid, '音乐、音量及播放速度重置完成')
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
function MyPlayerHelper:playerDamageActor (objid, toobjid, hurtlv)
  PlayerHelper:playerDamageActor(objid, toobjid, hurtlv)
  MyStoryHelper:playerDamageActor(objid, toobjid, hurtlv)
end

-- 玩家击败目标
function MyPlayerHelper:playerDefeatActor (objid, toobjid)
  local realDefeat = PlayerHelper:playerDefeatActor(objid, toobjid)
  MyStoryHelper:playerDefeatActor(objid, toobjid)
  -- body
  if (realDefeat and ActorHelper:isPlayer(toobjid)) then -- 击败玩家获得碎片
    local toPlayer = PlayerHelper:getPlayer(toobjid)
    local num = math.random(5, 9)
    BackpackHelper:addItem(objid, MyMap.ITEM.ENERGY_FRAGMENT_ID, num)
    ChatHelper:sendMsg(objid, '击败#G', toPlayer:getName(), '#n获得', num, '枚碎片')
  end
  -- 记录击杀数
  local player = PlayerHelper:getPlayer(objid)
  if (realDefeat) then
    if (ActorHelper:isPlayer(toobjid)) then
      player.killPlayerNum = player.killPlayerNum + 1
    else
      player.KillMonsterNum = player.KillMonsterNum + 1
    end
  end
end

-- 玩家受到伤害
function MyPlayerHelper:playerBeHurt (objid, toobjid, hurtlv)
  PlayerHelper:playerBeHurt(objid, toobjid, hurtlv)
  MyStoryHelper:playerBeHurt(objid, toobjid, hurtlv)
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
function MyPlayerHelper:playerSelectShortcut (objid, toobjid, itemid, itemnum)
  PlayerHelper:playerSelectShortcut(objid, toobjid, itemid, itemnum)
  MyStoryHelper:playerSelectShortcut(objid, toobjid, itemid, itemnum)
end

-- 玩家快捷栏变化
function MyPlayerHelper:playerShortcutChange (objid, toobjid, itemid, itemnum)
  PlayerHelper:playerShortcutChange(objid, toobjid, itemid, itemnum)
  MyStoryHelper:playerShortcutChange(objid, toobjid, itemid, itemnum)
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
  -- body
  -- 开启/关闭系统公告
  if (objid == 807364131 and string.find(content, '关闭' .. MyGameHelper.announce)) then
    MyPlayerHelper:closeAnnounce()
  elseif (objid == 807364131 and string.find(content, MyGameHelper.announce)) then
    if (MyGameHelper.isAnnounceOpen) then
      ChatHelper:sendMsg(nil, '作者更新了系统公告')
    else
      ChatHelper:sendMsg(nil, '作者开启了系统公告')
    end
    local delay
    local arr = StringHelper:split(content, '-')
    if (#arr > 1) then
      delay = tonumber(arr[1])
      content = arr[2]
    end
    ChatHelper:sendMsg(nil, content)
    MyPlayerHelper:closeAnnounce()
    MyPlayerHelper:openAnnounce(content, delay)
  elseif (content == '关闭日志') then
    LogHelper.level = 'no'
    ChatHelper:sendMsg(nil, '关闭日志成功')
  elseif (content == '错误信息') then
    LogHelper:showErrorRecords(objid)
  elseif (content == '停止错误信息') then
    LogHelper:stopErrorRecords(objid)
  elseif (objid == 807364131 and string.find(content, '日志')) then
    local arr = StringHelper:split(content, '-')
    if (#arr > 1) then
      if (arr[2] == 'debug' or arr[2] == 'info' or arr[2] == 'error' or arr[2] == 'no') then
        LogHelper.level = arr[2]
        ChatHelper:sendMsg(objid, '修改日志等级成功')
      end
    end
  end
end