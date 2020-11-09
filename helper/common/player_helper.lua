-- 玩家工具类
PlayerHelper = {
  PLAYERATTR = {
    MAX_HP = 1,
    CUR_HP = 2,
    MAX_HUNGER = 5,
    CUR_HUNGER = 6
  },
  players = {}, -- { objid -> MyPlayer }
  defeatActors = {}, -- 击败的生物
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
  local objid = PlayerHelper:getMainPlayerUin()
  if (objid) then
    return PlayerHelper:getPlayer(objid)
  else
    return nil
  end
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
    if (hp) then
      if (hp <= 0) then
        self:showToast(objid, StringHelper:concat(actorname, '已死亡'))
      else
        hp = math.ceil(hp)
        self:showToast(objid, StringHelper:concat(actorname, '剩余生命：', 
          StringHelper:number2String(hp)))
      end
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

function PlayerHelper:everyPlayerSpeakToSelf (second, ...)
  for i, v in ipairs(self:getAllPlayers()) do
    v.action:speakToAfterSeconds(v.objid, second, ...)
  end
end

function PlayerHelper:everyPlayerSpeak (second, ...)
  for i, v in ipairs(self:getAllPlayers()) do
    v.action:speakAfterSeconds(second, ...)
  end
end

function PlayerHelper:everyPlayerThinkToSelf (second, ...)
  for i, v in ipairs(self:getAllPlayers()) do
    v.action:thinkToAfterSeconds(v.objid, second, ...)
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

function PlayerHelper:everyPlayerRunTo (positions, callback, afterSeconds)
  self:everyPlayerDoSomeThing(function (player)
    player.action:runTo(positions, callback, player)
  end, afterSeconds)
end

function PlayerHelper:everyPlayerAddBuff (buffid, bufflv, customticks, afterSeconds)
  self:everyPlayerDoSomeThing(function (player)
    ActorHelper:addBuff(player.objid, buffid, bufflv, customticks)
  end, afterSeconds)
end

function PlayerHelper:everyPlayerLookAt (toobjid, afterSeconds)
  self:everyPlayerDoSomeThing(function (player)
    player:lookAt(toobjid)
  end, afterSeconds)
end

function PlayerHelper:everyPlayerPlayAct (act, afterSeconds)
  self:everyPlayerDoSomeThing(function (player)
    player.action:playAct(act)
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

-- 设置玩家是否可破坏方块
function PlayerHelper:setPlayerEnableDestroyBlock (objid, enable)
  return self:setActionAttrState(objid, PLAYERATTR.ENABLE_DESTROYBLOCK, enable)
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
  return self:getAttr(objid, PLAYERATTR.CUR_LEVELEXP)
end

function PlayerHelper:setExp (objid, exp)
  return self:setAttr(objid, PLAYERATTR.CUR_LEVELEXP, exp)
end

function PlayerHelper:getLevel (objid)
  return self:getAttr(objid, PLAYERATTR.CUR_LEVEL)
end

function PlayerHelper:setLevel (objid, level)
  return self:setAttr(objid, PLAYERATTR.CUR_LEVEL, level)
end

-- 氧气
function PlayerHelper:getOxygen (objid)
  return self:getAttr(objid, PLAYERATTR.CUR_OXYGEN)
end

-- 移动速度
function PlayerHelper:setWalkSpeed (objid, speed)
  return self:setAttr(objid, PLAYERATTR.WALK_SPEED, speed)
end

-- 游泳速度
function PlayerHelper:setSwimSpeed (objid, speed)
  return self:setAttr(objid, PLAYERATTR.SWIN_SPEED, speed)
end

-- 跳跃力
function PlayerHelper:setJumpPower (objid, jumpPower)
  return self:setAttr(objid, PLAYERATTR.JUMP_POWER, jumpPower)
end

-- 大小
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
  return PlayerHelper:addAttr(objid, PLAYERATTR.CUR_LEVELEXP, exp)
end

function PlayerHelper:recoverAttr (objid, attrtype)
  return self:setAttr(objid, attrtype + 1, self:getAttr(objid, attrtype))
end

-- 事件

-- 玩家进入游戏 是否之前已存在
function PlayerHelper:playerEnterGame (objid)
  local player = self:getPlayer(objid)
  if (not(player)) then
    player = PlayerHelper:addPlayer(objid)
    player:init()
    return false
  else
    player:init()
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
  ItemHelper:clickBlock(objid, blockid, x, y, z)
  local player = PlayerHelper:getPlayer(objid)
  player:breakTalk()
end

-- 玩家点击生物
function PlayerHelper:playerClickActor (objid, toobjid)
  local myActor = ActorHelper:getActor(toobjid)
  if (myActor) then
    ActorHelper:recordClickActor(objid, myActor)
    if (not(myActor:isWantsExist()) or myActor.wants[1].think ~= 'forceDoNothing') then
      myActor:defaultPlayerClickEvent(objid)
    end
  end
end

-- 玩家获得道具
function PlayerHelper:playerAddItem (objid, itemid, itemnum)
  -- body
end

-- 玩家使用道具
function PlayerHelper:playerUseItem (objid, toobjid, itemid, itemnum)
  ItemHelper:useItem(objid, itemid)
end

-- 玩家消耗道具
function PlayerHelper:playerConsumeItem (objid, toobjid, itemid, itemnum)
  -- body
end

-- 玩家攻击命中
function PlayerHelper:playerAttackHit (objid, toobjid)
  local itemid = PlayerHelper:getCurToolID(objid)
  local item = ItemHelper:getItem(itemid)
  if (item) then
    item:attackHit(objid, toobjid)
    if (objid ~= toobjid) then
      PlayerHelper:showActorHp(objid, toobjid)
    end
  end
end

-- 玩家造成伤害
function PlayerHelper:playerDamageActor (objid, toobjid, hurtlv)
  local key = PlayerHelper:generateDamageKey(objid, toobjid)
  TimeHelper:setFrameInfo(key, hurtlv)
  PlayerHelper:showActorHp(objid, toobjid)
end

-- 玩家击败目标
function PlayerHelper:playerDefeatActor (playerid, objid)
  if (PlayerHelper:getDefeatActor(objid)) then -- 该生物已死亡
    return false
  else
    PlayerHelper:recordDefeatActor(objid)
    local player = PlayerHelper:getPlayer(playerid)
    player:defeatActor(objid)
    return true
  end
end

-- 玩家受到伤害
function PlayerHelper:playerBeHurt (objid, toobjid, hurtlv)
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
function PlayerHelper:playerSelectShortcut (objid, toobjid, itemid, itemnum)
  local player = self:getPlayer(objid)
  player:holdItem()
  ItemHelper:selectItem(objid, itemid)
  player:choose()
end

-- 玩家快捷栏变化
function PlayerHelper:playerShortcutChange (objid, toobjid, itemid, itemnum)
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
  if (SkillHelper:isFlying(objid)) then
    local isStartFly = SkillHelper:isStartFly(objid)
    if (ActorHelper:isApproachBlock(objid, isStartFly)) then -- 靠近了方块
      SkillHelper:stopFly(objid)
    end
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
function PlayerHelper:playerInputContent (objid, content)
  -- body
end

-- 输入字符串
function PlayerHelper:playerNewInputContent (objid, content)
  -- body
end

-- 按键被按下
function PlayerHelper:playerInputKeyDown (objid, vkey)
  -- body
end

-- 按键处于按下状态
function PlayerHelper:playerInputKeyOnPress (objid, vkey)
  -- body
end

-- 按键松开
function PlayerHelper:playerInputKeyUp (objid, vkey)
  -- body
end

-- 等级发生变化
function PlayerHelper:playerLevelModelUpgrade (objid, toobjid)
  local player = PlayerHelper:getPlayer(objid)
  local prevLevel = player:getPrevLevel()
  local level = player:getLevel()
  if (level) then
    player:upgrade(level - prevLevel)
    local map = { level = level }
    local msg = StringHelper:getTemplateResult(MyTemplate.UPGRADE_MSG, map)
    ChatHelper:sendMsg(objid, msg)
  end
  -- body
end

-- 属性变化
function PlayerHelper:playerChangeAttr (objid, playerattr)
  -- body
end

-- 玩家获得状态效果
function PlayerHelper:playerAddBuff (objid, buffid, bufflvl)
  -- body
end

-- 玩家失去状态效果
function PlayerHelper:playerRemoveBuff (objid, buffid, bufflvl)
  -- body
end

-- 封装原始接口

-- 获取玩家昵称
function PlayerHelper:getNickname (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getNickname(objid)
  end, '获取玩家昵称', 'objid=', objid)
end

-- 对玩家显示飘窗文字
function PlayerHelper:notifyGameInfo2Self (objid, info)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:notifyGameInfo2Self(objid, info)
  end, '对玩家显示飘窗文字', 'objid=', objid, ',info=', info)
end

-- 设置玩家道具设置属性
function PlayerHelper:setItemAttAction (objid, itemid, attrtype, switch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setItemAttAction(objid, itemid, attrtype, switch)
  end, '设置玩家道具设置属性', 'objid=', objid, ',itemid=', itemid, ',attrtype=',
    attrtype, ',switch=', switch)
end

-- 设置玩家位置
function PlayerHelper:setPosition (objid, x, y, z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setPosition(objid, x, y, z)
  end, '设置玩家位置', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end

-- 获取玩家特殊属性的状态
function PlayerHelper:checkActionAttrState (objid, actionattr)
  return Player:checkActionAttrState(objid, actionattr) == ErrorCode.OK
end

-- 设置玩家行为属性状态
function PlayerHelper:setActionAttrState (objid, actionattr, switch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setActionAttrState(objid, actionattr, switch)
  end, '设置玩家行为属性状态', 'objid=', objid, ',actionattr=', actionattr,
    ',switch=', switch)
end

-- 旋转玩家镜头
function PlayerHelper:rotateCamera (objid, yaw, pitch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:rotateCamera(objid, yaw, pitch)
  end, '旋转玩家镜头', 'objid=', objid, ',yaw=', yaw, ',pitch=', pitch)
end

-- 玩家属性获取
function PlayerHelper:getAttr (objid, attrtype)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getAttr(objid, attrtype)
  end, '玩家属性获取', 'objid=', objid, ',attrtype=', attrtype)
end

-- 玩家属性设置
function PlayerHelper:setAttr (objid, attrtype, val)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setAttr(objid, attrtype, val)
  end, '玩家属性设置', 'objid=', objid, ',attrtype=', attrtype, ',val=', val)
end

-- 获取玩家队伍
function PlayerHelper:getTeam (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getTeam(objid)
  end, '获取玩家队伍', 'objid=', objid)
end

-- 设置玩家队伍（数据变了，但是好像没起作用）
function PlayerHelper:setTeam (objid, teamid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setTeam(objid, teamid)
  end, '设置玩家队伍', 'objid=', objid, ',teamid=', teamid)
end

-- 玩家播放动画
function PlayerHelper:playAct (objid, actid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:playAct(objid, actid)
  end, '玩家播放动画', 'objid=', objid, ',actid=', actid)
end

-- 改变玩家视角模式
function PlayerHelper:changeViewMode (objid, viewmode, islock)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:changeViewMode(objid, viewmode, islock)
  end, '改变玩家视角模式', 'objid=', objid, ',viewmode=', viewmode, ',islock=', islock)
end

-- 获取当前所用快捷栏键 0~7
function PlayerHelper:getCurShotcut (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getCurShotcut(objid)
  end, '获取当前所用快捷栏键', 'objid=', objid)
end

-- 获取当前饱食度
function PlayerHelper:getFoodLevel (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getFoodLevel(objid)
  end, '获取当前饱食度', 'objid=', objid)
end

-- 设置玩家饱食度
function PlayerHelper:setFoodLevel (objid, foodLevel)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setFoodLevel(objid, foodLevel)
  end, '设置玩家饱食度', 'objid=', objid, ',foodLevel=', foodLevel)
end

-- 获取玩家当前手持的物品id，空手是0
function PlayerHelper:getCurToolID (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getCurToolID(objid)
  end, '获取玩家当前手持的物品id', 'objid=', objid)
end

-- 设置技能CD，该技能CD为工具原生技能的CD，添加的技能CD与此无关，因此，此方法没什么用
function PlayerHelper:setSkillCD (objid, itemid, cd)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setSkillCD(objid, itemid, cd)
  end, '设置技能CD', 'objid=', objid, ',itemid=', itemid, ',cd=', cd)
end

-- 获取player准星位置
function PlayerHelper:getAimPos (objid)
  return CommonHelper:callThreeResultMethod(function (p)
    return Player:getAimPos(objid)
  end, '获取player准星位置', 'objid=', objid)
end

-- 传送玩家到出生点
function PlayerHelper:teleportHome (objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:teleportHome(objid)
  end, '传送玩家到出生点', 'objid=', objid)
end

-- 使玩家获得游戏胜利
function PlayerHelper:setGameWin (objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setGameWin(objid)
  end, '使玩家获得游戏胜利', 'objid=', objid)
end

-- 对玩家播放背景音乐
function PlayerHelper:playMusic (objid, musicid, volume, pitch, isLoop)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:playMusic(objid, musicid, volume, pitch, isLoop)
  end, '对玩家播放背景音乐', 'objid=', objid, ',musicid=', musicid, ',volume=',
    volume, ',pitch=', pitch, ',isLoop=', isLoop)
end

-- 停止播放玩家背景音乐
function PlayerHelper:stopMusic (objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:stopMusic(objid)
  end, '停止播放玩家背景音乐', 'objid=', objid)
end

-- 改变玩家复活点位置
function PlayerHelper:setRevivePoint (objid, x, y, z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setRevivePoint(objid, x, y, z)
  end, '改变玩家复活点位置', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end

-- 是否是本地玩家
function PlayerHelper:isMainPlayer (objid)
  return Player:isMainPlayer(objid) == ErrorCode.OK
end

-- 获取本地玩家的uin
function PlayerHelper:getMainPlayerUin ()
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getMainPlayerUin()
  end, '获取本地玩家的uin')
end

-- 获取玩家比赛结果 0游戏中 1游戏胜利 2游戏结束
function PlayerHelper:getGameResults (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Player:getGameResults(objid)
  end, '获取玩家比赛结果', 'objid=', objid)
end

-- 设置玩家比赛结果 0游戏中 1游戏胜利 2游戏结束
function PlayerHelper:setGameResults (objid, result)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:setGameResults(objid, result)
  end, '设置玩家比赛结果', 'objid=', objid, ',result=', result)
end

function PlayerHelper:openBoxByPos (objid, x, y, z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:openBoxByPos(objid, x, y, z)
  end, '打开可以操作的箱子', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end

function PlayerHelper:reviveToPos (objid, x, y, z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Player:reviveToPos(objid, x, y, z)
  end, '复活玩家到指定点', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end