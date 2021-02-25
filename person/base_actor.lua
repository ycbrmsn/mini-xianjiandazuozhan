-- 角色基类
BaseActor = {
  objid = nil,
  actorid = nil,
  x = nil,
  y = nil,
  z = nil,
  defaultSpeed = 300, -- 默认移动速度
  cantMoveTime = 0, -- 无法移动的时间
  motion = 0, -- 静止
  freeInAreaId = nil, -- 自由活动区域id
  timername = 'myActorTimer',
  wants = nil,
  isAIOpened = true,
  isInit = false, -- 是否初始化完成
  sealTimes = 0, -- 封魔叠加次数
  talkIndex = {}, -- 对话进度 { playerid -> index }
  talkInfos = {}, -- 对话信息
  defaultTalkMsg = nil, -- 默认对话
  speakDim = { x = 30, y = 30, z = 30 }, -- 默认说话声音传播范围
}

function BaseActor:new (actorid, objid)
  if (not(actorid)) then
    LogHelper:error('初始化生物的actorid为：', actorid)
  end
  local o = {
    actorid = actorid
  }
  if (objid) then
    o.objid = objid
    ActorHelper:addActor(o) -- 生物加入集合中
  end
  setmetatable(o, self)
  self.__index = self
  return o
end

function BaseActor:newMonster (x, y, z, num, isSingleton)
  if (isSingleton) then
    MonsterHelper:delMonstersByActorid(self.actorid)
  end
  if (not(self.action)) then
    self.action = BaseActorAction:new(self)
    -- self.want = BaseActorWant:new(self)
  end
  local objids = WorldHelper:spawnCreature(x, y, z, self.actorid, num)
end

-- 生物是否有效
function BaseActor:isActive ()
  local x, y, z = ActorHelper:getPosition(self.objid)
  if (x) then
    self:updateCantMoveTime(x, y, z)
    self.x, self.y, self.z = x, y, z
    -- 处理恢复加载时生物的一些属性会遗失的问题
    if (self.maxHp) then -- 最大生命值
      local maxHp = CreatureHelper:getMaxHp(self.objid)
      if (maxHp and maxHp ~= self.maxHp) then
        CreatureHelper:setMaxHp(self.objid, self.maxHp)
      end
    end
    if (self.unableBeKilled) then -- 不可被杀死
      if (ActorHelper:getEnableBeKilledState(self.objid)) then
        ActorHelper:setEnableBeKilledState(self.objid, false)
      end
    end
    if (self.immuneFall) then -- 不会摔伤
      ActorHelper:setImmuneFall(self.objid, true)
    end
    if (self.recoverNow) then -- 恢复生命
      if (CreatureHelper:resetHp(self.objid)) then
        self.recoverNow = false
      end
    end
    return true
  else
    -- 以下方法有误，容易同时出现两个NPC，因此不再使用
    -- local blockid = BlockHelper:getBlockID(self.x, self.y, self.z)
    -- if (blockid and blockid ~= BaseConstant.UNKNOWN_BLOCK) then -- 表示生物不见了（多半是因bug被销毁）
    --   local objids = WorldHelper:spawnCreature(self.x, self.y, self.z, self.actorid, 1)
    --   if (objids and #objids > 0) then -- 创建生物成功
    --     self.objid = objids[1]
    --     return true
    --   end
    -- end
    return false
  end
end

-- 更新不能移动时间
function BaseActor:updateCantMoveTime (x, y, z)
  if (self.x) then
    if (self.x == x and self.y == y and self.z == z) then
      if (self.action:isForceMove()) then
        self.cantMoveTime = self.cantMoveTime + 1
      end
      self.motion = 0 -- 静止
    else
      self.cantMoveTime = 0
      self.motion = 1 -- 运动
    end
  end
end

-- 设置生物是否可移动
function BaseActor:enableMove (switch)
  return ActorHelper:setEnableMoveState(self.objid, switch)
end

function BaseActor:openAI ()
  if (CreatureHelper:openAI(self.objid)) then
    self.isAIOpened = true
    return true
  else
    return false
  end
end

function BaseActor:closeAI ()
  if (CreatureHelper:closeAI(self.objid)) then
    self.isAIOpened = false
    return true
  else
    return false
  end
end

function BaseActor:runTo (pos, speed)
  self.action:runTo(pos, speed)
end

function BaseActor:stopRun ()
  self.action:stopRun()
end

-- 获取生物位置
function BaseActor:getPosition ()
  return ActorHelper:getPosition(self.objid)
end

function BaseActor:getMyPosition ()
  return MyPosition:new(self:getPosition())
end

-- 设置生物位置
function BaseActor:setPosition (x, y, z)
  return ActorHelper:setMyPosition(self.objid, x, y, z)
end

function BaseActor:getDistancePosition (distance, angle)
  return ActorHelper:getDistancePosition(self.objid, distance, angle)
end

function BaseActor:setDistancePosition (objid, distance, angle)
  self:setPosition(ActorHelper:getDistancePosition(objid, distance, angle))
end

function BaseActor:getFaceYaw ()
  return ActorHelper:getFaceYaw(self.objid)
end

function BaseActor:setFaceYaw (yaw)
  return ActorHelper:setFaceYaw(self.objid, yaw)
end

function BaseActor:setFacePitch (pitch)
  return ActorHelper:setFacePitch(self.objid, pitch)
end

-- 额外伤害（目前用于怪物）
function BaseActor:getCollateralDamage ()
  return 0
end

-- 看向某人/某处
function BaseActor:lookAt (objid, afterSeconds)
  if (afterSeconds and afterSeconds > 0) then
    TimeHelper:callFnAfterSecond(function ()
      self.action:lookAt(objid)
    end, afterSeconds)
  else
    self.action:lookAt(objid)
  end
end

function BaseActor:speak (afterSeconds, ...)
  if (afterSeconds > 0) then
    self.action:speakAfterSeconds(afterSeconds, ...)
  else
    self.action:speakToAll(...)
  end
end

function BaseActor:speakTo (playerids, afterSeconds, ...)
  if (type(playerids) == 'number') then
    if (afterSeconds > 0) then
      self.action:speakToAfterSeconds(playerids, afterSeconds, ...)
    else
      self.action:speak(playerids, ...)
    end
  elseif (type(playerids) == 'table') then
    for i, v in ipairs(playerids) do
      self:speakTo(v, afterSeconds, ...)
    end
  end
end

function BaseActor:speakAround (dim, afterSeconds, ...)
  dim = dim or self.speakDim
  local pos = self:getMyPosition()
  local objids = ActorHelper:getAllPlayersArroundPos(pos, dim)
  if (objids and #objids > 0) then
    self:speakTo(objids, afterSeconds, ...)
  end
end

function BaseActor:thinks (afterSeconds, ...)
  if (afterSeconds > 0) then
    self.action:thinkAfterSeconds(afterSeconds, ...)
  else
    self.action:think(...)
  end
end

function BaseActor:thinkTo (playerids, afterSeconds, ...)
  if (type(playerids) == 'number') then
    if (afterSeconds > 0) then
      self.action:thinkToAfterSeconds(playerids, afterSeconds, ...)
    else
      self.action:thinkTo(playerids, ...)
    end
  elseif (type(playerids) == 'table') then
    for i, v in ipairs(playerids) do
      self:thinkTo(v, afterSeconds, ...)
    end
  end
end

function BaseActor:goToBed (isNow)
  self.action:goToBed(isNow)
end

function BaseActor:lightCandle (think, isNow, candlePositions)
  return self.action:lightCandle(think, isNow, candlePositions)
end

function BaseActor:putOutCandle (think, isNow, candlePositions)
  return self.action:putOutCandle(think, isNow, candlePositions)
end

function BaseActor:putOutCandleAndGoToBed (candlePositions)
  self.action:putOutCandleAndGoToBed(candlePositions)
end

function BaseActor:toggleCandle (think, myPosition, isLitCandle, isNow)
  self.action:toggleCandle(think, myPosition, isLitCandle, isNow)
end

-- 生物想向指定位置移动
function BaseActor:wantMove (think, positions, isNegDir, index, restTime, speed)
  AreaHelper:removeToArea(self)
  self:closeAI()
  self.think = think
  local want = MoveAction:new(self, think, positions, isNegDir, index, restTime, speed)
  self.wants = { want }
  -- 创建当前前往区域
  ActorActionHelper:createMoveToPos(want)
  self.action:runTo(want.toPos)
  return want
end

function BaseActor:nextWantMove (think, positions, isNegDir, index, restTime, speed)
  local want
  if (self:isWantsExist()) then
    want = MoveAction:new(self, think, positions, isNegDir, index, restTime, speed)
    table.insert(self.wants, want)
  else
    want = self:wantMove(think, positions, isNegDir, index, restTime, speed)
  end
  return want
end

function BaseActor:wantApproach (think, positions, isNegDir, index, restTime, speed)
  AreaHelper:removeToArea(self)
  self:closeAI()
  self.think = think
  local want = ApproachAction:new(self, think, positions, isNegDir, index, restTime, speed)
  self.wants = { want }
  -- 创建当前前往区域
  ActorActionHelper:createApproachToPos(want)
  return want
end

function BaseActor:nextWantApproach (think, positions, isNegDir, index, restTime)
  local want
  if (self:isWantsExist()) then
    want = ApproachAction:new(self, think, positions, isNegDir, index, restTime)
    table.insert(self.wants, want)
  else
    want = self:wantApproach(think, positions, isNegDir, index, restTime)
  end
  return want
end

-- 生物想巡逻
function BaseActor:wantPatrol (think, positions, isNegDir, index, restTime)
  AreaHelper:removeToArea(self)
  -- LogHelper:debug(self:getName() .. '想巡逻')
  self:closeAI()
  self.think = think
  local want = PatrolAction:new(self, think, positions, isNegDir, index, restTime)
  self.wants = { want }
  -- 创建当前前往区域
  ActorActionHelper:createMoveToPos(want)
  return want
end

-- 生物接下来想巡逻
function BaseActor:nextWantPatrol (think, positions, isNegDir, index, restTime)
  local want
  if (self:isWantsExist()) then
    want = PatrolAction:new(self, think, positions, isNegDir, index, restTime)
    table.insert(self.wants, want)
  else
    want = self:wantPatrol(think, positions, isNegDir, index, restTime)
  end
  return want
end

-- 生物想自由活动
function BaseActor:wantFreeTime (think)
  AreaHelper:removeToArea(self)
  think = think or 'free'
  self:openAI()
  self.think = think
  local want = FreeTimeAction:new(self, think)
  self.wants = { want }
  ActorActionHelper:freeTime(want)
  return want
end

function BaseActor:wantFreeAndAlert (think, speed)
  AreaHelper:removeToArea(self)
  think = think or 'alert'
  self:closeAI()
  self.think = think
  local want = FreeAndAlertAction:new(self, think, speed)
  self.wants = { want }
  self.action:freeAndAlert(want)
  return want
end

-- 生物想在区域内自由活动，think可选
function BaseActor:wantFreeInArea (think, posPairs)
  AreaHelper:removeToArea(self)
  if (not(posPairs)) then
    posPairs = think
    think = 'free'
  end
  self:closeAI()
  self.think = think
  local want = ActorActionHelper:setFreeInArea(think, self, posPairs)
  want.toPos = ActorActionHelper:getFreeInAreaPos(self.freeInAreaIds)
  -- 创建当前前往区域
  ActorActionHelper:createMoveToPos(want)
  return want
end

-- 生物接下来想在区域内自由活动
function BaseActor:nextWantFreeInArea (think, posPairs)
  local want
  if (self:isWantsExist()) then
    if (not(posPairs)) then
      posPairs = think
      think = 'free'
    end
    want = ActorActionHelper:setFreeInArea(think, self, posPairs, true)
  else
    want = self:wantFreeInArea(think, posPairs)
  end
  return want
end

function BaseActor:wantFreeAttack (think, posPairs)
  AreaHelper:removeToArea(self)
  if (not(posPairs)) then
    posPairs = think
    think = 'freeAttack'
  end
  self:closeAI()
  self.think = think
  local want = ActorActionHelper:setFreeAttack(think, self, posPairs)
  want.toPos = ActorActionHelper:getFreeInAreaPos(self.freeInAreaIds)
  -- 创建当前前往区域
  ActorActionHelper:createMoveToPos(want)
  return want
end

function BaseActor:nextWantFreeAttack (think, posPairs)
  local want
  if (self:isWantsExist()) then
    if (not(posPairs)) then
      posPairs = think
      think = 'freeAttack'
    end
    want = ActorActionHelper:setFreeAttack(think, self, posPairs, true)
  else
    want = self:wantFreeAttack(think, posPairs)
  end
  return want
end

function BaseActor:wantFollow (think, toobjid, speed)
  AreaHelper:removeToArea(self)
  think = think or 'follow'
  self.think = think
  local want = FollowAction:new(self, think, toobjid, speed)
  self.wants = { want }
  return want
end

function BaseActor:nextWantFollow (think, toobjid, speed)
  local want = FollowAction:new(self, think, toobjid, speed)
  table.insert(self.wants, want)
  return want
end

-- 生物想原地不动
function BaseActor:wantDontMove (think)
  AreaHelper:removeToArea(self)
  think = think or 'dontMove'
  self.think = think
  local want = DontMoveAction:new(self, think)
  self.wants = { want }
  self:stopRun()
  return want
end

-- 生物想停留一会儿
function BaseActor:wantStayForAWhile(second)
  second = second or 5 -- 默认休息5秒
  if (not(self.wants)) then -- 如果生物没有想法，则给他一个原始的想法
    self:defaultWant()
  end
  self.wants[1].currentRestTime = second
  self.action:stopRun()
end

function BaseActor:nextWantWait (think, second)
  local want = WaitAction:new(self, think, second)
  table.insert(self.wants, want)
  return want
end

-- 生物想不做事
function BaseActor:wantDoNothing (think)
  AreaHelper:removeToArea(self)
  think = think or 'doNothing'
  self:closeAI()
  self.think = think
  local want = DoNothingAction:new(self, think)
  self.wants = { want }
  return want
end

function BaseActor:nextWantDoNothing (think)
  local want
  if (self:isWantsExist()) then
    think = think or 'doNothing'
    want = DoNothingAction:new(self, think)
    table.insert(self.wants, want)
  else
    want = self:wantDoNothing(think)
  end
  return want
end

function BaseActor:wantLookAt (think, myPosition, restTime)
  self:closeAI()
  local want
  if (self:isWantsExist()) then
    think = think or self.think
    want = LookAtAction:new(self, think, myPosition, restTime)
    if (self.wants[1].style == 'lookAt' or self.wants[1].style == 'lookingAt') then
      self.wants[1] = want
    else
      table.insert(self.wants, 1, want)
    end
  else
    think = think or 'lookAt'
    want = LookAtAction:new(self, think, myPosition, restTime)
    self.wants = { want }
  end
  self.think = think
  return want
end

function BaseActor:nextWantLookAt (think, pos, restTime)
  local want
  if (self:isWantsExist()) then
    think = think or self.wants[#self.wants].think or 'lookAt'
    want = LookAtAction:new(self, think, pos, restTime)
    table.insert(self.wants, want)
  else
    want = self:wantLookAt(think, pos, restTime)
  end
  return want
end

function BaseActor:wantGoToSleep (bedData)
  AreaHelper:removeToArea(self)
  self:wantMove('sleep', { bedData[1] })
  return self:nextWantSleep('sleep', bedData[2])
end

function BaseActor:nextWantGoToSleep (bedData)
  if (self:isWantsExist()) then
    self:nextWantMove('sleep', { bedData[1] })
    return self:nextWantSleep('sleep', bedData[2])
  else
    return self:wantGoToSleep(bedData)
  end
end

function BaseActor:nextWantSleep (think, faceYaw)
  local want = SleepAction:new(self, think, faceYaw)
  self:nextWantWait(think, 2)
  table.insert(self.wants, want)
  return want
end

-- 生物默认想法，可重写
function BaseActor:defaultWant ()
  return self:wantFreeTime()
end

function BaseActor:wantBattle (think)
  AreaHelper:removeToArea(self)
  think = think or 'battle'
  self.think = think
  local want = BattleAction:new(self, think)
  self.wants = { want }
  return want
end

-- 总是在approach之后，所以无需判断exists
function BaseActor:nextWantToggleCandle (think, isLitCandle)
  local want = ToggleCandleAction:new(self, think, isLitCandle)
  table.insert(self.wants, want)
  return want
end

-- 强制不能做什么，用于受技能影响
function BaseActor:forceDoNothing (think)
  self:closeAI()
  local want
  if (self:isWantsExist()) then
    want = self.wants[1]
    if (want.style == 'forceDoNothing') then -- 如果已经存在，则次数叠加
      want.times = want.times + 1
    else
      think = think or 'forceDoNothing'
      want = ForceDoNothingAction:new(self, think)
      table.insert(self.wants, 1, want)
    end
  else
    think = think or 'forceDoNothing'
    want = ForceDoNothingAction:new(self, think)
    self.wants = { want }
  end
  self.think = think
  return want
end

-- 生物固定时间点想做什么
function BaseActor:wantAtHour (hour)
  -- 各个生物重写此方法内容
end

function BaseActor:isWantsExist ()
  return self.wants and #self.wants > 0
end

function BaseActor:getName ()
  if (not(self.actorname)) then
    self.actorname = CreatureHelper:getActorName(self.objid)
  end
  return self.actorname
end

function BaseActor:getWalkSpeed ()
  if (not(self.walkSpeed)) then
    self.walkSpeed = CreatureHelper:getWalkSpeed(self.objid)
  end
  return self.walkSpeed
end

-- 速度与原速度不同就改变速度
function BaseActor:setWalkSpeed (speed)
  if (CreatureHelper:setWalkSpeed(self.objid, speed)) then
    self.walkSpeed = speed
    return true
  else
    return false
  end
end

-- 初始化人物行为
function BaseActor:init (hour)
  -- body
end

function BaseActor:initActor ()
  if (self:isFind()) then
    ActorHelper:addActor(self) -- 生物加入集合中
    -- 加入蜡烛台数据
    if (self.candlePositions and #self.candlePositions > 0) then
      for i, v in ipairs(self.candlePositions) do
        BlockHelper:addCandle(v)
      end
    end
    -- 如果有最大生命设置，则设置最大生命值
    if (self.maxHp) then
      CreatureHelper:setMaxHp(self.objid, self.maxHp)
      CreatureHelper:setHp(self.objid, self.maxHp)
    end
    -- 如果生物不可被杀死，则设置不可被杀死
    if (self.unableBeKilled) then
      ActorHelper:setEnableBeKilledState(self.objid, false)
    end
    -- 如果生物不会摔伤，则设置不会摔伤
    if (self.immuneFall) then
      ActorHelper:setImmuneFall(self.objid, true)
    end
    self:keepSingleIfNeed()
    self:wantAtHour()
    self.isInit = true
    LogHelper:debug('初始化', self:getName(), '完成')
    return true
  else
    -- LogHelper:debug('未找到', self.actorid)
    return false
  end
end

-- 是否找到该生物
function BaseActor:isFind ()
  -- local actorid = CreatureHelper:getActorID(self.objid)
  -- return actorid and actorid == self.actorid
  local objids = ActorHelper:getInitActorObjids()
  for i, objid in ipairs(objids) do
    local actorid = CreatureHelper:getActorID(objid)
    if (actorid and actorid == self.actorid) then
      self.objid = objid
      return true
    end
  end
  return false
end

-- 保持只有一个，移除其他
function BaseActor:keepSingleIfNeed ()
  if (self.isSingleton) then
    local objids = ActorHelper:getInitActorObjids()
    for i, objid in ipairs(objids) do
      local actorid = CreatureHelper:getActorID(objid)
      if (actorid and actorid == self.actorid and objid ~= self.objid) then
        WorldHelper:despawnActor(objid)
      end
    end
  end
end

-- 是否完成初始化
function BaseActor:isFinishInit ()
  return self.isInit
end

function BaseActor:candleEvent (myPlayer, candle)
  local nickname = myPlayer:getName()
  self:speakTo(myPlayer.objid, 0, nickname, '，你搞啥呢')
end

-- 一般重写此方法
function BaseActor:playerClickEvent (objid)
  self.action:playFree2(2)
end

function BaseActor:defaultPlayerClickEvent (playerid)
  local actorTeam = CreatureHelper:getTeam(self.objid)
  local playerTeam = PlayerHelper:getTeam(playerid)
  if (actorTeam ~= 0 and actorTeam == playerTeam) then -- 有队伍并且同队
    if (self.wants and self.wants[1].style == 'sleeping') then
      self.wants[1].style = 'wake'
    end
    local pos = self:getMyPosition()
    if (ActorHelper:isInWater(self.objid)) then -- 生物在水中，则移动到玩家位置
      local player = PlayerHelper:getPlayer(playerid)
      local newPos = player:getDistancePosition(1)
      self:setPosition(newPos)
      ChatHelper:sendMsg(playerid, '你把', self:getName(), '从水里捞了过来')
    else
      self.action:stopRun()
    end
    self:wantLookAt(nil, playerid, 60)
    self:playerClickEvent(playerid)
  end
end

function BaseActor:collidePlayer (playerid, isPlayerInFront)
  -- body
end

function BaseActor:defaultCollidePlayerEvent (playerid, isPlayerInFront)
  local actorTeam = CreatureHelper:getTeam(self.objid)
  local playerTeam = PlayerHelper:getTeam(playerid)
  if (actorTeam ~= 0 and actorTeam == playerTeam) then -- 有队伍并且同队
    if (self.wants and self.wants[1].style == 'sleeping') then
      self.wants[1].style = 'wake'
    end
    self.action:stopRun()
    self:wantLookAt(nil, playerid)
    self:collidePlayer(playerid, isPlayerInFront)
  end
end

-- 攻击命中
function BaseActor:attackHit (toobjid)
  -- body
end

-- 行为改变
function BaseActor:changeMotion (actormotion)
  -- body
end

-- 受到伤害
function BaseActor:beHurt (toobjid, hurtlv)
  -- body
end

-- 获得状态
function BaseActor:addBuff (buffid, bufflvl)
  -- body
end

-- 移除状态
function BaseActor:removeBuff (buffid, bufflvl)
  -- body
end

-- 设置囚禁状态
function BaseActor:setImprisoned (active)
  if (active) then
    self:forceDoNothing()
  else
    return self:freeForceDoNothing()
  end
end

-- 解除囚禁状态，返回true表示已不是囚禁状态
function BaseActor:freeForceDoNothing ()
  if (self:isWantsExist() and self.wants[1].style == 'forceDoNothing') then
    if (self.wants[1].times > 1) then
      self.wants[1].times = self.wants[1].times - 1
      return false
    else
      ActorHelper:handleNextWant(self)
    end
  end
  return true
end

-- 设置封魔状态
function BaseActor:setSealed (active)
  if (active) then
    self.sealTimes = self.sealTimes + 1
  else
    self.sealTimes = self.sealTimes - 1
    return self.sealTimes <= 0
  end
end

-- 立刻行动
function BaseActor:actionRightNow ()
  if (self.wants and #self.wants > 0) then
    self.wants[1].currentRestTime = 1
  end
  self.action:execute()
end