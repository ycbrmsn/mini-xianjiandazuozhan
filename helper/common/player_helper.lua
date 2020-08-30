-- 玩家工具类
PlayerHelper = {
  PLAYERATTR = {
    MAX_HP = 1,
    CUR_HP = 2,
    MAX_HUNGER = 5,
    CUR_HUNGER = 6
  },
  players = {}, -- { objid -> MyPlayer }
  defeatActors = {} -- 击败的生物
}

-- 如果玩家信息不存在则添加玩家信息
function PlayerHelper:addPlayer (objid)
  local player = MyPlayer:new(objid)
  table.insert(self:getAllPlayers(), player)
  return player
end

-- 移除玩家信息
function PlayerHelper:removePlayer (objid)
  for i, v in ipairs(self:getAllPlayers()) do
    if (v.objid == objid) then
      table.remove(self:getAllPlayers(), i)
      break
    end
  end
end

-- 获取玩家信息
function PlayerHelper:getPlayer (objid)
  for i, v in ipairs(self:getAllPlayers()) do
    if (v.objid == objid) then
      return v
    end
  end
  return nil
end

-- 获取房主信息
function PlayerHelper:getHostPlayer ()
  return self:getAllPlayers()[1]
end

-- 获取所有玩家信息
function PlayerHelper:getAllPlayers ()
  return self.players
end

-- 获取有效玩家
function PlayerHelper:getActivePlayers ()
  local players = {}
  for i, v in ipairs(self:getAllPlayers()) do
    if (v:isActive()) then
      table.insert(players, v)
    end
  end
  return players
end

-- 获取所有玩家名字
function PlayerHelper:getAllPlayerNames ()
  local names = {}
  for i, v in ipairs(self:getAllPlayers()) do
    table.insert(names, v:getName())
  end
  return names
end

-- 记录死亡生物，5秒后清除数据
function PlayerHelper:recordDefeatActor (objid)
  self.defeatActors[objid] = true
  TimeHelper:callFnAfterSecond(function ()
    self.defeatActors[objid] = nil
  end, 5)
end

-- 获取被击败的actor
function PlayerHelper:getDefeatActor (objid)
  return self.defeatActors[objid]
end

-- 显示飘窗信息
function PlayerHelper:showToast (objid, ...)
  local info = StringHelper:concat(...)
  TimeHelper:callFnInterval(objid, 'toast', function (p)
    PlayerHelper:notifyGameInfo2Self(objid, info)
  end, 2)
end

-- 显示actor当前生命值
function PlayerHelper:showActorHp (objid, toobjid)
  local actorname, hp
  if (ActorHelper:isPlayer(toobjid)) then -- 生物是玩家
    local player = PlayerHelper:getPlayer(toobjid)
    actorname = player:getName()
    hp = PlayerHelper:getHp(toobjid)
  else
    actorname = CreatureHelper:getActorName(toobjid)
    hp = CreatureHelper:getHp(toobjid)
  end
  local t = 'showActorHp' .. toobjid
  TimeHelper:delFnFastRuns(t)
  TimeHelper:callFnFastRuns(function ()
    if (hp and hp <= 0) then
      self:showToast(objid, StringHelper:concat(actorname, '已死亡'))
    else
      hp = math.ceil(hp)
      self:showToast(objid, StringHelper:concat(actorname, '剩余生命：', 
        StringHelper:number2String(hp)))
    end
  end, 0.1, t)
end

-- actor行动
function PlayerHelper:runPlayers ()
  for k, v in pairs(self.players) do
    LogHelper:call(function ()
      v.action:execute()
    end)
  end
end

function PlayerHelper:generateDamageKey (objid, toobjid)
  return objid .. 'damage' .. toobjid
end

function PlayerHelper:everyPlayerDoSomeThing (f, afterSeconds)
  if (not(f)) then
    return
  end
  if (afterSeconds) then
    TimeHelper:callFnAfterSecond (function ()
      for i, v in ipairs(self:getAllPlayers()) do
        f(v)
      end
    end, afterSeconds)
  else
    for i, v in ipairs(self:getAllPlayers()) do
      f(v)
    end
  end
end

function PlayerHelper:updateEveryPlayerPositions ()
  self:everyPlayerDoSomeThing(function (player)
    player:updatePositions()
  end)
end

function PlayerHelper:setEveryPlayerPosition (x, y, z, afterSeconds)
  self:everyPlayerDoSomeThing(function (player)
    player:setPosition(x, y, z)
  end, afterSeconds)
end

function PlayerHelper:everyPlayerSpeakAfterSecond (second, ...)
  for i, v in ipairs(self:getAllPlayers()) do
    v.action:speakAfterSecond(v.objid, second, ...)
  end
end

function PlayerHelper:everyPlayerSpeakToAllAfterSecond (second, ...)
  for i, v in ipairs(self:getAllPlayers()) do
    v.action:speakToAllAfterSecond(second, ...)
  end
end

function PlayerHelper:everyPlayerSpeakInHeartAfterSecond (second, ...)
  for i, v in ipairs(self:getAllPlayers()) do
    v.action:speakInHeartAfterSecond(v.objid, second, ...)
  end
end

function PlayerHelper:everyPlayerNotify (info, afterSeconds)
  self:everyPlayerDoSomeThing(function (player)
    PlayerHelper:notifyGameInfo2Self(player.objid, info)
  end, afterSeconds)
end

function PlayerHelper:everyPlayerEnableMove (enable, afterSeconds)
  self:everyPlayerDoSomeThing(function (player)
    player:enableMove(enable, true)
  end, afterSeconds)
end

function PlayerHelper:everyPlayerRunTo (positions, callback, param, afterSeconds)
  self:everyPlayerDoSomeThing(function (player)
    player.action:runTo(positions, callback, param)
  end, afterSeconds)
end

function PlayerHelper:everyPlayerAddBuff (buffid, bufflv, customticks, afterSeconds)
  self:everyPlayerDoSomeThing(function (player)
    ActorHelper:addBuff(player.objid, buffid, bufflv, customticks)
  end, afterSeconds)
end

-- 改变玩家视角模式
function PlayerHelper:changeVMode (objid, viewmode, islock)
  viewmode = viewmode or VIEWPORTTYPE.BACKVIEW
  if (not(objid)) then
    self:everyPlayerDoSomeThing(function (p)
      PlayerHelper:changeViewMode(p.objid, viewmode, islock)
    end)
  elseif (type(objid) == 'number') then
    PlayerHelper:changeViewMode(objid, viewmode, islock)
  else
    for i, v in ipairs(objid) do
      PlayerHelper:changeViewMode(v, viewmode, islock)
    end
  end
end

-- 设置道具不可丢弃
function PlayerHelper:setItemDisableThrow (objid, itemid)
  return self:setItemAttAction(objid, itemid, PLAYERATTR.ITEM_DISABLE_THROW, true)
end

-- 设置玩家是否可以移动
function PlayerHelper:setPlayerEnableMove (objid, enable)
  return self:setActionAttrState(objid, PLAYERATTR.ENABLE_MOVE, enable)
end

-- 查询玩家是否可被杀死
function PlayerHelper:getPlayerEnableBeKilled (objid)
  return self:checkActionAttrState(objid, PLAYERATTR.ENABLE_BEKILLED)
end

-- 设置玩家是否可被杀死
function PlayerHelper:setPlayerEnableBeKilled (objid, enable)
  return self:setActionAttrState(objid, PLAYERATTR.ENABLE_BEKILLED, enable)
end

-- 设置玩家是否可被攻击
function PlayerHelper:setPlayerEnableBeAttacked (objid, enable)
  return self:setActionAttrState(objid, PLAYERATTR.ENABLE_BEATTACKED, enable)
end

function PlayerHelper:getHp (objid)
  return self:getAttr(objid, PLAYERATTR.CUR_HP)
end

function PlayerHelper:getMaxHp (objid)
  return self:getAttr(objid, PLAYERATTR.MAX_HP)
end

function PlayerHelper:getLevel (objid)
  return self:getAttr(objid, PLAYERATTR.LEVEL)
end

function PlayerHelper:setHp (objid, hp)
  return self:setAttr(objid, PLAYERATTR.CUR_HP, hp)
end

function PlayerHelper:setMaxHp (objid, hp)
  return self:setAttr(objid, PLAYERATTR.MAX_HP, hp)
end

function PlayerHelper:getExp (objid)
  return self:getAttr(objid, 26)
end

function PlayerHelper:setExp (objid, exp)
  return self:setAttr(objid, 26, exp)
end

function PlayerHelper:getTotalLevel (objid)
  return self:getAttr(objid, 27)
end

function PlayerHelper:setTotalLevel (objid, totalLevel)
  return self:setAttr(objid, 27, totalLevel)
end

function PlayerHelper:setWalkSpeed (objid, speed)
  return self:setAttr(objid, PLAYERATTR.WALK_SPEED, speed)
end

function PlayerHelper:getDimension (objid)
  return self:getAttr(objid, PLAYERATTR.DIMENSION)
end

function PlayerHelper:setDimension (objid, dimension)
  return self:setAttr(objid, PLAYERATTR.DIMENSION, dimension)
end

function PlayerHelper:addAttr (objid, attrtype, addVal)
  local curVal = self:getAttr(objid, attrtype)
  return self:setAttr(objid, attrtype, curVal + addVal)
end

function PlayerHelper:addExp (objid, exp)
  return PlayerHelper:addAttr(objid, 26, exp)
end

function PlayerHelper:recoverAttr (objid, attrtype)
  return self:setAttr(objid, attrtype + 1, self:getAttr(objid, attrtype))
end

-- 事件

-- 玩家进入游戏 是否之前已存在
function PlayerHelper:playerEnterGame (objid)
  local player = self:getPlayer(objid)
  if (not(player)) then
    PlayerHelper:addPlayer(objid)
    return false
  else
    player:setActive(true)
    return true
  end
end

-- 玩家离开游戏
function PlayerHelper:playerLeaveGame (objid)
  -- PlayerHelper:removePlayer(objid)
  if (SkillHelper:isFlying(objid)) then -- 如果玩家在飞行，则停止飞行
    SkillHelper:stopFly(objid)
  end
  SkillHelper:clearHuitian(objid) -- 清除玩家的环绕回仙剑
  SkillHelper:stopAirArmour(objid) -- 停止气甲术
  -- 设置玩家不活跃
  local player = PlayerHelper:getPlayer(objid)
  player:setActive(false)
end

-- 玩家进入区域
function PlayerHelper:playerEnterArea (objid, areaid)
  local player = PlayerHelper:getPlayer(objid)
  if (areaid == player.toAreaId) then -- 玩家自动前往地点
    AreaHelper:destroyArea(areaid)
    -- player.action:runAction()
    player.action:doNext()
  elseif (AreaHelper:showToastArea(objid, areaid)) then -- 显示提示区域检测
  end
end

-- 玩家离开区域
function PlayerHelper:playerLeaveArea (objid, areaid)
  -- body
end

-- 玩家点击方块
function PlayerHelper:playerClickBlock (objid, blockid, x, y, z)
  local pos = MyPosition:new(x, y, z)
  local blockid = BlockHelper:getBlockID(pos.x, pos.y, pos.z)
  if (BlockHelper:checkCandle(objid, blockid, pos)) then
  end
end

-- 玩家点击生物
function PlayerHelper:playerClickActor (objid, toobjid)
  local myActor = ActorHelper:getActor(toobjid)
  if (myActor) then
    ActorHelper:recordClickActor(objid, myActor)
    if (myActor.wants and myActor.wants[1].style == 'sleeping') then
      myActor.wants[1].style = 'wake'
    end
    myActor:defaultPlayerClickEvent(objid)
  end
end

-- 玩家获得道具
function PlayerHelper:playerAddItem (objid, itemid, itemnum)
  -- body
end

-- 玩家使用道具
function PlayerHelper:playerUseItem (objid, itemid)
  ItemHelper:useItem(objid, itemid)
end

-- 玩家攻击命中
function PlayerHelper:playerAttackHit (objid, toobjid)
  local itemid = PlayerHelper:getCurToolID(objid)
  local item = ItemHelper:getItem(itemid)
  if (item) then
    item:attackHit(objid, toobjid)
    PlayerHelper:showActorHp(objid, toobjid)
  end
end

-- 玩家造成伤害
function PlayerHelper:playerDamageActor (objid, toobjid)
  local key = PlayerHelper:generateDamageKey(objid, toobjid)
  TimeHelper:setFrameInfo(key, true)
  PlayerHelper:showActorHp(objid, toobjid)
end

-- 玩家击败生物
function PlayerHelper:playerDefeatActor (playerid, objid)
  if (PlayerHelper:getDefeatActor(objid)) then -- 该生物已死亡
    return
  else
    PlayerHelper:recordDefeatActor(objid)
  end
  local player = PlayerHelper:getPlayer(playerid)
  player:defeatActor(objid)
end

-- 玩家受到伤害
function PlayerHelper:playerBeHurt (objid, toobjid)
  if (SkillHelper:isFlying(objid)) then -- 玩家在御剑飞行，则飞行失控
    local player = PlayerHelper:getPlayer(objid)
    SkillHelper:stopFly(objid, ItemHelper:getItem(player.hold))
  end
end

-- 玩家死亡
function PlayerHelper:playerDie (objid, toobjid)
  -- 检测技能是否正在释放
  if (ItemHelper:isDelaySkillUsing(objid, '坠星')) then -- 技能释放中
    FallStarBow:cancelSkill(objid)
  end
  if (SkillHelper:isFlying(objid)) then -- 玩家在御剑飞行，则取消飞行
    SkillHelper:stopFly(objid)
  end
  SkillHelper:clearHuitian(objid) -- 清除玩家的环绕回仙剑
  SkillHelper:stopAirArmour(objid) -- 停止气甲术
end

-- 玩家复活
function PlayerHelper:playerRevive (objid, toobjid)
  local player = PlayerHelper:getPlayer(objid)
  player:gainDefeatedExp()
end

-- 玩家选择快捷栏
function PlayerHelper:playerSelectShortcut (objid)
  local player = self:getPlayer(objid)
  player:holdItem()
end

-- 玩家快捷栏变化
function PlayerHelper:playerShortcutChange (objid)
  local player = self:getPlayer(objid)
  player:holdItem()
end

-- 玩家运动状态改变
function PlayerHelper:playerMotionStateChange (objid, playermotion)
  if (playermotion == PLAYERMOTION.SNEAK) then -- 潜行
    ItemHelper:useItem2(objid)
  end
end

-- 玩家移动一格
function PlayerHelper:playerMoveOneBlockSize (objid)
  ActorHelper:resumeClickActor(objid)
  if (ActorHelper:isApproachBlock(objid)) then -- 靠近了方块
    SkillHelper:stopFly(objid)
  end
end

-- 骑乘
function PlayerHelper:playerMountActor (objid, toobjid)
  -- body
end

-- 取消骑乘
function PlayerHelper:playerDismountActor (objid, toobjid)
  -- body
end

-- 聊天输出界面变化
function PlayerHelper:playerInputContent(objid, content)
  -- body
end

-- 输入字符串
function PlayerHelper:playerNewInputContent(objid, content)
  -- body
end

-- 封装原始接口

-- 获取玩家昵称
function PlayerHelper:getNickname (objid)
  local onceFailMessage = '获取玩家昵称失败一次'
  local finillyFailMessage = StringHelper:concat('获取玩家昵称失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getNickname(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 对玩家显示飘窗文字
function PlayerHelper:notifyGameInfo2Self (objid, info)
  local onceFailMessage = '对玩家显示飘窗文字失败一次'
  local finillyFailMessage = StringHelper:concat('对玩家显示飘窗文字失败，参数：objid=', objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:notifyGameInfo2Self(objid, info)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置玩家道具设置属性
function PlayerHelper:setItemAttAction (objid, itemid, attrtype, switch)
  local onceFailMessage = '设置玩家道具设置属性失败一次'
  local finillyFailMessage = StringHelper:concat('设置玩家道具设置属性失败，参数：objid=', objid, ', itemid=', itemid, ', attrtype=', attrtype, ', switch=', switch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setItemAttAction(objid, itemid, attrtype, switch)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置玩家位置
function PlayerHelper:setPosition (objid, x, y, z)
  local onceFailMessage = '设置玩家位置失败一次'
  local finillyFailMessage = StringHelper:concat('设置玩家位置失败，参数：objid=', objid, ', x=', x, ', y=', y, ', z=', z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setPosition(objid, x, y, z)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取玩家特殊属性的状态
function PlayerHelper:checkActionAttrState (objid, actionattr)
  return Player:checkActionAttrState(objid, actionattr) == ErrorCode.OK
end

-- 设置玩家行为属性状态
function PlayerHelper:setActionAttrState (objid, actionattr, switch)
  local onceFailMessage = '设置玩家行为属性状态失败一次'
  local finillyFailMessage = StringHelper:concat('设置玩家行为属性状态失败，参数：objid=', objid, ', actionattr=', actionattr, ', switch=', switch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setActionAttrState(objid, actionattr, switch)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 旋转玩家镜头
function PlayerHelper:rotateCamera (objid, yaw, pitch)
  local onceFailMessage = '旋转玩家镜头失败一次'
  local finillyFailMessage = StringHelper:concat('旋转玩家镜头失败，参数：objid=', objid, ', yaw=', yaw, ', pitch=', pitch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:rotateCamera(objid, yaw, pitch)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 玩家属性获取
function PlayerHelper:getAttr (objid, attrtype)
  local onceFailMessage = '玩家属性获取失败一次'
  local finillyFailMessage = StringHelper:concat('玩家属性获取失败，参数：objid=', objid, ', attrtype=', attrtype)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getAttr(objid, attrtype)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 玩家属性设置
function PlayerHelper:setAttr (objid, attrtype, val)
  local onceFailMessage = '玩家属性设置失败一次'
  local finillyFailMessage = StringHelper:concat('玩家属性设置失败，参数：objid=', objid, ', attrtype=', attrtype, ', val=', val)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setAttr(objid, attrtype, val)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取玩家队伍
function PlayerHelper:getTeam (objid)
  local onceFailMessage = '获取玩家队伍失败一次'
  local finillyFailMessage = StringHelper:concat('获取玩家队伍失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getTeam(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置玩家队伍（数据变了，但是好像没起作用）
function PlayerHelper:setTeam (objid, teamid)
  local onceFailMessage = '设置玩家队伍失败一次'
  local finillyFailMessage = StringHelper:concat('设置玩家队伍失败，参数：objid=', objid, ', teamid=', teamid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setTeam(objid, teamid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 玩家播放动画
function PlayerHelper:playAct (objid, actid)
  local onceFailMessage = '玩家播放动画失败一次'
  local finillyFailMessage = StringHelper:concat('玩家播放动画失败，参数：objid=', objid, ', actid=', actid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:playAct(objid, actid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 改变玩家视角模式
function PlayerHelper:changeViewMode (objid, viewmode, islock)
  local onceFailMessage = '改变玩家视角模式失败一次'
  local finillyFailMessage = StringHelper:concat('改变玩家视角模式失败，参数：objid=', objid, ',viewmode=', viewmode, ',islock=', islock)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:changeViewMode(objid, viewmode, islock)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取当前所用快捷栏键
function PlayerHelper:getCurShotcut (objid)
  local onceFailMessage = '获取当前所用快捷栏键失败一次'
  local finillyFailMessage = StringHelper:concat('获取当前所用快捷栏键失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getCurShotcut(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取当前饱食度
function PlayerHelper:getFoodLevel (objid)
  local onceFailMessage = '获取当前饱食度失败一次'
  local finillyFailMessage = StringHelper:concat('获取当前饱食度失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getFoodLevel(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置玩家饱食度
function PlayerHelper:setFoodLevel (objid, foodLevel)
  local onceFailMessage = '设置玩家饱食度失败一次'
  local finillyFailMessage = StringHelper:concat('设置玩家饱食度失败，参数：objid=', objid, ',foodLevel=', foodLevel)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setFoodLevel(objid, foodLevel)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取玩家当前手持的物品id
function PlayerHelper:getCurToolID (objid)
  local onceFailMessage = '获取玩家当前手持的物品id失败一次'
  local finillyFailMessage = StringHelper:concat('获取玩家当前手持的物品id失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getCurToolID(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置技能CD，该技能CD为工具原生技能的CD，添加的技能CD与此无关，因此，此方法没什么用
function PlayerHelper:setSkillCD (objid, itemid, cd)
  local onceFailMessage = '设置技能CD失败一次'
  local finillyFailMessage = StringHelper:concat('设置技能CD失败，参数：objid=', objid, ',itemid=', itemid, ',cd=', cd)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setSkillCD(objid, itemid, cd)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取player准星位置
function PlayerHelper:getAimPos (objid)
  local onceFailMessage = '获取player准星位置失败一次'
  local finillyFailMessage = StringHelper:concat('获取player准星位置失败，参数：objid=', objid)
  return CommonHelper:callThreeResultMethod(function (p)
    return Player:getAimPos(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 传送玩家到出生点
function PlayerHelper:teleportHome (objid)
  local onceFailMessage = '传送玩家到出生点失败一次'
  local finillyFailMessage = StringHelper:concat('传送玩家到出生点失败，参数：objid=', objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:teleportHome(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 使玩家获得游戏胜利
function PlayerHelper:setGameWin (objid)
  local onceFailMessage = '使玩家获得游戏胜利失败一次'
  local finillyFailMessage = StringHelper:concat('使玩家获得游戏胜利失败，参数：objid=', objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setGameWin(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 对玩家播放背景音乐
function PlayerHelper:playMusic (objid, musicid, volume, pitch, isLoop)
  local onceFailMessage = '对玩家播放背景音乐失败一次'
  local finillyFailMessage = StringHelper:concat('对玩家播放背景音乐失败，参数：objid=', objid, ',musicid=', 
    musicid, ',volume=', volume, ',pitch=', pitch, ',isLoop=', isLoop)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:playMusic(objid, musicid, volume, pitch, isLoop)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 停止播放玩家背景音乐
function PlayerHelper:stopMusic (objid)
  local onceFailMessage = '停止播放玩家背景音乐失败一次'
  local finillyFailMessage = StringHelper:concat('停止播放玩家背景音乐失败，参数：objid=', objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:stopMusic(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 改变玩家复活点位置
function PlayerHelper:setRevivePoint (objid, x, y, z)
  local onceFailMessage = '改变玩家复活点位置失败一次'
  local finillyFailMessage = StringHelper:concat('改变玩家复活点位置失败，参数：objid=', objid,
    ',x=', x, ',y=', y, ',z=', z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setRevivePoint(objid, x, y, z)
  end, nil, onceFailMessage, finillyFailMessage)
end