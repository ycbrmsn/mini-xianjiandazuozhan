-- 我的玩家工具类
MyPlayerHelper = {
  initPosition = MyPosition:new(3, 10, 42),
  disableThrowItems = {
    MyMap.ITEM.ENERGY_FRAGMENT_ID, -- 能量碎片
    MyWeaponAttr.controlSword.levelIds[1], -- 御仙剑
    MyWeaponAttr.tenThousandsSword.levelIds[1], -- 万仙剑
    MyWeaponAttr.huixianSword.levelIds[1], -- 回仙剑
    MyWeaponAttr.vitalqiSword.levelIds[1], -- 气仙剑
    MyWeaponAttr.luanSword.levelIds[1], -- 乱仙剑
    MyWeaponAttr.shunSword.levelIds[1], -- 瞬仙剑
    MyWeaponAttr.qiuSword.levelIds[1], -- 囚仙剑
    MyWeaponAttr.fengSword.levelIds[1], -- 封仙剑
    MyMap.ITEM.TIME_TURNTABLE_ID, -- 时间轮盘
    MyMap.ITEM.HANDBOOK_ID, -- 冒险手册
  },
  warn = {}, -- { objid = {} } -- 碎片数量过多玩家信息
  findBookPlayer = {}, -- { objid = true, objid = true }
}

function MyPlayerHelper.sendTeamMsg (objid)
  local teams = { [0] = 0, [1] = 0, [2] = 0 } -- 队伍人数
  local players = PlayerHelper.getAllPlayers()
  for i, v in ipairs(players) do
    if (v:isActive() and v.objid ~= objid) then
      local team = PlayerHelper.getTeam(v.objid)
      if (teams[team]) then
        teams[team] = teams[team] + 1
      else
        teams[team] = 1
      end
    end
  end
  local teamMap = {}
  for k, v in pairs(teams) do
    teamMap[k] = StringHelper.int2Chinese(v)
  end
  ChatHelper.sendTemplateMsg(MyTemplate.TEAM_MSG, teamMap, objid)
end

-- 开启公告
function MyPlayerHelper.openAnnounce (content, delay)
  delay = delay or 120
  MyGameHelper.isAnnounceOpen = true
  TimeHelper.callFnFastRuns(function ()
    ChatHelper.sendMsg(nil, content)
    MyPlayerHelper.openAnnounce(content, delay)
  end, delay, MyGameHelper.announce)
end

-- 关闭公告
function MyPlayerHelper.closeAnnounce ()
  MyGameHelper.isAnnounceOpen = false
  TimeHelper.delFnFastRuns(MyGameHelper.announce)
end

-- 获得两方队伍颜色
function MyPlayerHelper.getTeamColor (objid, toobjid)
  local teamid1 = PlayerHelper.getTeam(objid)
  local teamid2 = PlayerHelper.getTeam(toobjid)
  if (teamid1 and teamid2) then
    if (teamid1 == 1) then
      return '#R', '#B'
    else
      return '#B', '#R'
    end
  else
    return nil
  end
end

-- 显示击败玩家信息
function MyPlayerHelper.showDefeatPlayerMsg (player, toPlayer, item)
  local color1, color2 = MyPlayerHelper.getTeamColor(player.objid, toPlayer.toobjid)
  local desc1, desc2, desc3 = MyItemHelper.getDefeatPlayerDesc(player.objid, item)
  if (color1 and desc1) then
    ChatHelper.sendMsg(nil, desc1, color1, player:getName(), desc2, color2, toPlayer:getName(), desc3)
  end
end

-- 事件

-- 玩家进入游戏
EventHelper.addEvent('playerEnterGame', function (objid)
  -- PlayerHelper.teleportHome(objid) 不再传送到出生点，会有问题
  local player = PlayerHelper.getPlayer(objid)
  -- player:setPosition(MyPlayerHelper.initPosition)
  player:updateMaxHp()
  -- 不可丢弃
  for i, v in ipairs(MyPlayerHelper.disableThrowItems) do
    PlayerHelper.setItemDisableThrow(objid, v)
  end
  BackpackHelper.gainItem(objid, MyMap.ITEM.HANDBOOK_ID, 1) -- 冒险手册
  -- 播放背景音乐
  MusicHelper.startBGM(objid, 1, true)
  -- 提示队伍人数
  -- if (player ~= PlayerHelper.getHostPlayer()) then
  --   MyPlayerHelper.sendTeamMsg(objid)
  -- end
  -- 更新报告显示
  -- MyGameHelper.showUpdateContent(objid)
  if (objid == 807364131) then -- 作者携带道具
    local items = {
      MyWeaponAttr.controlSword.levelIds[1],
      MyWeaponAttr.tenThousandsSword.levelIds[1],
      MyWeaponAttr.huixianSword.levelIds[1],
      MyWeaponAttr.vitalqiSword.levelIds[1],
      MyWeaponAttr.luanSword.levelIds[1],
      MyWeaponAttr.shunSword.levelIds[1],
      MyWeaponAttr.qiuSword.levelIds[1],
      MyWeaponAttr.fengSword.levelIds[1],
      MyMap.ITEM.MUSIC_PLAYER_ID,
      MyMap.ITEM.TIME_TURNTABLE_ID,
      MyMap.ITEM.CHEST_ID,
    }
    for i, v in ipairs(items) do
      BackpackHelper.setGridItem(objid, i - 1, v, 1)
    end
    TimeHelper.callFnFastRuns(function ()
      LogHelper.showErrorRecords(objid)
    end, 1)
  end
  -- 清空所有任务
  TaskHelper.clearTask(objid)
  -- ActorHelper.updateHp(objid, 130) -- 不再显示生命
end)

-- 玩家离开游戏
EventHelper.addEvent('playerLeaveGame', function (objid)
  if (SkillHelper.isFlying(objid)) then -- 如果玩家在飞行，则停止飞行
    SkillHelper.stopFly(objid)
  end
  MySkillHelper.clearHuitian(objid) -- 清除玩家的环绕回仙剑
  MySkillHelper.stopAirArmour(objid) -- 停止气甲术
  -- 停止背景音乐
  MusicHelper.stopBGM(objid)
  MyPlayerHelper.warn[objid] = nil
end)

-- 玩家获得道具
EventHelper.addEvent('playerAddItem', function (objid, itemid, itemnum)
  -- 能量碎片过多提示
  if (itemid == MyMap.ITEM.ENERGY_FRAGMENT_ID) then
    local num = BackpackHelper.getItemNumAndGrid(objid, itemid)
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
      local info = MyPlayerHelper.warn[objid]
      if (not(info)) then
        info = {}
        MyPlayerHelper.warn[objid] = info
      end
      if (not(info[warnNum])) then
        info[warnNum] = true
        ChatHelper.sendMsg(nil, '注意：有玩家碎片数已达到#G', warnNum)
      end
    end
  end
end)

-- 玩家使用道具
EventHelper.addEvent('playerUseItem', function (objid, toobjid, itemid, itemnum)
  if (itemid == MyMap.ITEM.MUSIC_PLAYER_ID) then -- 音乐播放器
    local index = PlayerHelper.getCurShotcut(objid)
    if (index == 3) then -- 加速
      MusicHelper.changeSpeed (objid, 1)
    elseif (index == 4) then -- 减速
      MusicHelper.changeSpeed (objid, -1)
    elseif (index == 5) then -- 调大声音
      MusicHelper.modulateVolume(objid, 1)
    elseif (index == 6) then -- 调小声音
      MusicHelper.modulateVolume(objid, -1)
    elseif (index == 7) then -- 重置音乐选项
      MusicHelper.changeBGM(objid, 1, true, true)
      ChatHelper.sendMsg(objid, '音乐、音量及播放速度重置完成')
    else
      ChatHelper.sendMsg(objid, '当前处于快捷栏第', index + 1, '格，暂无对应功能')
    end
  end
end)

-- 玩家击败目标
EventHelper.addEvent('playerDefeatActor', function (objid, toobjid, item)
  if (item) then -- 如果是道具技能击败，则提示
    -- 由于事件先后顺序问题，因而延迟执行
    TimeHelper.callFnAfterSecond(function ()
      PlayerHelper.showActorHp(objid, toobjid)
    end, 1)
  end

  local player = PlayerHelper.getPlayer(objid)
  if (ActorHelper.isPlayer(toobjid)) then
    local toPlayer = PlayerHelper.getPlayer(toobjid)
    -- 击败玩家描述
    MyPlayerHelper.showDefeatPlayerMsg(player, toPlayer, item)
    -- 击败玩家获得碎片
    local num = math.random(5, 9)
    if (BackpackHelper.addItem(objid, MyMap.ITEM.ENERGY_FRAGMENT_ID, num)) then
      ChatHelper.sendMsg(objid, '击败#G', toPlayer:getName(), '#n获得#G', num, '#n枚碎片')
    end

    -- 被玩家击败遗失碎片
    local totalNum = BackpackHelper.getItemNumAndGrid(toobjid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
    if (totalNum and totalNum > 0) then
      local maxLostNum = math.floor(totalNum / 5) -- 最多两层
      if (maxLostNum < 1) then
        maxLostNum = 1
      end
      local lostNum = math.random(1, maxLostNum)
      if (BackpackHelper.removeGridItemByItemID(toobjid, MyMap.ITEM.ENERGY_FRAGMENT_ID, lostNum)) then
        ChatHelper.sendMsg(toobjid, '你被#G', player:getName(), '#n击败，遗失了#G', lostNum, '#n枚碎片')
      end
    end
  end

  -- 记录击杀数
  if (ActorHelper.isPlayer(toobjid)) then
    player.killPlayerNum = player.killPlayerNum + 1
  else
    player.KillMonsterNum = player.KillMonsterNum + 1
  end
end)

-- 玩家受到伤害
EventHelper.addEvent('playerBeHurt', function (objid, toobjid, hurtlv)
  if (SkillHelper.isFlying(objid)) then -- 玩家在御剑飞行，则飞行失控
    local player = PlayerHelper.getPlayer(objid)
    SkillHelper.stopFly(objid, ItemHelper.getItem(player.hold))
  end
end)

-- 玩家死亡
EventHelper.addEvent('playerDie', function (objid, toobjid)
  local player = PlayerHelper.getPlayer(objid)
  player.isKilled = true
  if (SkillHelper.isFlying(objid)) then -- 玩家在御剑飞行，则取消飞行
    SkillHelper.stopFly(objid)
  end
  MySkillHelper.clearHuitian(objid) -- 清除玩家的环绕回仙剑
  MySkillHelper.stopAirArmour(objid) -- 停止气甲术
end)

-- 玩家复活
EventHelper.addEvent('playerRevive', function (objid, toobjid)
  local player = PlayerHelper.getPlayer(objid)
  player.isKilled = false
  -- 恢复最大生命值
  TimeHelper.callFnFastRuns(function ()
    player:updateMaxHp()
  end, 0.3)
end)

-- 玩家快捷栏变化
EventHelper.addEvent('playerShortcutChange', function (objid, toobjid, itemid, itemnum)
  local player = PlayerHelper.getPlayer(objid)
  if (itemid == 11803) then
    if (not(MyPlayerHelper.findBookPlayer[objid])) then
      MyPlayerHelper.findBookPlayer[objid] = true
      ChatHelper.sendMsg(nil, '#G', player:getName(), '#n似乎找到了什么')
    end
  end
end)

-- 玩家移动一格
EventHelper.addEvent('playerMoveOneBlockSize', function (objid, toobjid)
  if (SkillHelper.isFlying(objid)) then -- 飞行靠近方块检测
    local isStartFly = SkillHelper.isStartFly(objid)
    if (ActorHelper.isApproachBlock(objid, isStartFly)) then -- 靠近了方块
      SkillHelper.stopFly(objid)
    end
  end
  local player = PlayerHelper.getPlayer(objid)
  local pos = player:getMyPosition()
  -- 高度
  local t = objid .. 'flyTooHigh'
  if (pos.y < -50) then
    if (not(player.isKilled)) then
      ActorHelper.killSelf(objid)
      player:setPosition(pos.x, 0, pos.z)
    end
  elseif (pos.y >= 80 and not(player.isTooHigh)) then
    player.isTooHigh = true
    local idx = 0
    TimeHelper.callFnContinueRuns(function ()
      if (idx % 20 == 0) then
        player:recoverHp(-25)
      end
      idx = idx + 1
    end, -1, t)
    ChatHelper.sendSystemMsg('飞行过高，你觉得有些不适', objid)
  elseif (player.isTooHigh and pos.y < 80) then
    player.isTooHigh = false
    TimeHelper.delFnContinueRuns(t)
    ChatHelper.sendSystemMsg('你觉得好多了', objid)
  end
  -- 四周太远
  local t2 = objid .. 'flyTooFar'
  if ((pos.x >= 90 or pos.x <= -90 or pos.z >= 130 or pos.z <= -50) and not(player.isTooFar)) then
    player.isTooFar = true
    local idx2 = 0
    local timeGap = 200
    TimeHelper.callFnContinueRuns(function ()
      idx2 = idx2 + 1
      if (idx2 % timeGap == 0) then
        local p = player:getDistancePosition(10)
        local playerPos = player:getMyPosition()
        if (idx2 % 2 == 0) then
          playerPos.x = playerPos.x + math.random(-2, 2)
          playerPos.y = playerPos.y + math.random(-2, 3)
          playerPos.z = playerPos.z + math.random(-2, 2)
        end
        WorldHelper.spawnProjectileByPos(nil, 
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
    ChatHelper.sendSystemMsg('飞行过远，你仿佛觉得被什么东西盯住了', objid)
  elseif (player.isTooFar and (pos.x > -90 and pos.x < 90 and pos.z > -50 and pos.z < 130)) then
    player.isTooFar = false
    TimeHelper.delFnContinueRuns(t2)
    ChatHelper.sendSystemMsg('被盯住的感觉消失了，你觉得轻松多了', objid)
  end
end)

-- 输入字符串
EventHelper.addEvent('playerNewInputContent', function (objid, content)
  -- 开启/关闭系统公告
  if (objid == 807364131 and string.find(content, '关闭' .. MyGameHelper.announce)) then
    MyPlayerHelper.closeAnnounce()
  elseif (objid == 807364131 and string.find(content, MyGameHelper.announce)) then
    if (MyGameHelper.isAnnounceOpen) then
      ChatHelper.sendMsg(nil, '作者更新了系统公告')
    else
      ChatHelper.sendMsg(nil, '作者开启了系统公告')
    end
    local delay
    local arr = StringHelper.split(content, '-')
    if (#arr > 1) then
      delay = tonumber(arr[1])
      content = arr[2]
    end
    ChatHelper.sendMsg(nil, content)
    MyPlayerHelper.closeAnnounce()
    MyPlayerHelper.openAnnounce(content, delay)
  elseif (content == '关闭日志') then
    LogHelper.level = 'no'
    ChatHelper.sendMsg(nil, '关闭日志成功')
  elseif (content == '错误信息') then
    LogHelper.showErrorRecords(objid)
  elseif (content == '停止错误信息') then
    LogHelper.stopErrorRecords(objid)
  elseif (objid == 807364131 and string.find(content, '日志')) then
    local arr = StringHelper.split(content, '-')
    if (#arr > 1) then
      if (arr[2] == 'debug' or arr[2] == 'info' or arr[2] == 'error' or arr[2] == 'no') then
        LogHelper.level = arr[2]
        ChatHelper.sendMsg(objid, '修改日志等级成功')
      end
    end
  end
  -- 特殊道具效果
  local itemid = PlayerHelper.getCurToolID(objid)
  if (itemid == MyMap.ITEM.TIME_TURNTABLE_ID) then -- 时间轮盘
    TimeTurntable:useItem(objid, content)
  end
end)

-- 按键被按下
EventHelper.addEvent('playerInputKeyDown', function (objid, vkey)
  local player = PlayerHelper.getPlayer(objid)
  if (vkey == 'SPACE') then
    SkillHelper.flyUp(objid)
  end
end)

-- 按键松开
EventHelper.addEvent('playerInputKeyUp', function (objid, vkey)
  if (vkey == 'SPACE') then
    SkillHelper.stopFlyUp(objid)
  end
end)

-- 属性变化
EventHelper.addEvent('playerChangeAttr', function (objid, playerattr)
  if (playerattr == PLAYERATTR.CUR_HP) then
    -- ActorHelper.updateHp(objid, 130) -- 不再显示生命
  end
end)
