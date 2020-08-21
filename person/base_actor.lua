-- actor基类
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
  sealTimes = 0 -- 封魔叠加次数
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
    self.want = BaseActorWant:new(self)
  end
  local objids = WorldHelper:spawnCreature(x, y, z, self.actorid, num)
end

-- 生物是否有效
function BaseActor:isActive ()
  local x, y, z = ActorHelper:getPosition(self.objid)
  if (x) then
    self:updateCantMoveTime(x, y, z)
    self.x, self.y, self.z = x, y, z
    return true
  else
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
  CreatureHelper:openAI(self.objid)
  self.isAIOpened = true
end

function BaseActor:closeAI ()
  CreatureHelper:closeAI(self.objid)
  self.isAIOpened = false
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

-- 看向某人/某处
function BaseActor:lookAt (objid)
  self.action:lookAt(objid)
end

function BaseActor:speak (afterSeconds, ...)
  if (afterSeconds > 0) then
    self.action:speakToAllAfterSecond(afterSeconds, ...)
  else
    self.action:speakToAll(...)
  end
end

function BaseActor:speakTo (playerids, afterSeconds, ...)
  if (type(playerids) == 'number') then
    if (afterSeconds > 0) then
      self.action:speakAfterSecond(playerids, afterSeconds, ...)
    else
      self.action:speak(playerids, ...)
    end
  elseif (type(playerids) == 'table') then
    for i, v in ipairs(playerids) do
      self:speakTo(v)
    end
  end
end

function BaseActor:thinks (afterSeconds, ...)
  if (afterSeconds > 0) then
    self.action:speakInHeartToAllAfterSecond(afterSeconds, ...)
  else
    self.action:speakInHeartToAll(...)
  end
end

function BaseActor:thinkTo (playerids, afterSeconds, ...)
  if (type(playerids) == 'number') then
    if (afterSeconds > 0) then
      self.action:speakInHeartAfterSecond(playerids, afterSeconds, ...)
    else
      self.action:speakInHeart(playerids, ...)
    end
  elseif (type(playerids) == 'table') then
    for i, v in ipairs(playerids) do
      self:thinkTo(v)
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
  self.want:wantMove(think, positions, isNegDir, index, restTime, speed)
end

function BaseActor:wantApproach (think, positions, isNegDir, index, restTime)
  self.want:wantApproach(think, positions, isNegDir, index, restTime)
end

-- 生物想原地不动
function BaseActor:wantDontMove (think)
  self.want:wantDontMove(think)
end

-- 生物想停留一会儿
function BaseActor:wantStayForAWhile(second)
  self.want:wantStayForAWhile(second)
end

-- 生物想巡逻
function BaseActor:wantPatrol (think, positions, isNegDir, index, restTime)
  self.want:wantPatrol(think, positions, isNegDir, index, restTime)
end

-- 生物想自由活动
function BaseActor:wantFreeTime (think)
  self.want:wantFreeTime(think)
end

function BaseActor:wantFreeAndAlert (think, speed)
  self.want:wantFreeAndAlert(think, speed)
end

-- 生物想在区域内自由活动，think可选
function BaseActor:wantFreeInArea (think, posPairs)
  self.want:wantFreeInArea(think, posPairs)
end

-- 生物默认想法，可重写
function BaseActor:defaultWant ()
  self:wantFreeTime()
end

-- 生物想不做事
function BaseActor:wantDoNothing (think)
  self.want:wantDoNothing(think)
end

function BaseActor:wantLookAt (think, myPosition, restTime)
  self.want:wantLookAt(think, myPosition, restTime)
end

function BaseActor:wantGoToSleep (bedData)
  self.want:wantGoToSleep(bedData)
end

function BaseActor:wantBattle (think)
  self.want:wantBattle(think)
end

function BaseActor:isWantsExist ()
  return self.wants and #self.wants > 0
end

function BaseActor:nextWantMove (think, positions, isNegDir, index, restTime, speed)
  self.want:nextWantMove(think, positions, isNegDir, index, restTime, speed)
end

function BaseActor:nextWantApproach (think, positions, isNegDir, index, restTime)
  self.want:nextWantApproach(think, positions, isNegDir, index, restTime)
end

-- 生物接下来想巡逻
function BaseActor:nextWantPatrol (think, positions, isNegDir, index, restTime)
  self.want:nextWantPatrol(think, positions, isNegDir, index, restTime)
end

-- 生物接下来想在区域内自由活动
function BaseActor:nextWantFreeInArea (think, posPairs)
  self.want:nextWantFreeInArea(think, posPairs)
end

function BaseActor:nextWantDoNothing (think)
  self.want:nextWantDoNothing(think)
end

function BaseActor:nextWantLookAt (think, pos, restTime)
  self.want:nextWantLookAt(think, pos, restTime)
end

function BaseActor:nextWantSleep (think, faceYaw)
  self.want:nextWantSleep(think, faceYaw)
end

function BaseActor:nextWantWait (think, second)
  self.want:nextWantWait(think, second)
end

function BaseActor:nextWantGoToSleep (bedData)
  self.want:nextWantGoToSleep(bedData)
end

function BaseActor:nextWantToggleCandle (think, isLitCandle)
  self.want:nextWantToggleCandle(think, isLitCandle)
end

-- 强制不能做什么，用于受技能影响
function BaseActor:forceDoNothing (think)
  self.want:forceDoNothing(think)
end

-- 生物固定时间点想做什么
function BaseActor:wantAtHour (hour)
  -- 各个生物重写此方法内容
end

-- 一般重写此方法
function BaseActor:playerClickEvent (objid)
  self.action:playFree2(2)
end

function BaseActor:defaultPlayerClickEvent (playerid)
  local actorTeam = CreatureHelper:getTeam(self.objid)
  local playerTeam = PlayerHelper:getTeam(playerid)
  if (actorTeam ~= 0 and actorTeam == playerTeam) then -- 有队伍并且同队
    self.action:stopRun()
    self:wantLookAt(nil, playerid, 60)
    self:playerClickEvent(playerid)
  end
end

function BaseActor:candleEvent (myPlayer, candle)
  local nickname = myPlayer:getName()
  self.action:speak(myPlayer.objid, nickname, '，你搞啥呢')
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

function BaseActor:initActor (initPosition)
  local actorid = CreatureHelper:getActorID(self.objid)
  if (actorid and actorid == self.actorid) then
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
    -- 清除木围栏
    -- local areaid = AreaHelper:getAreaByPos(initPosition)
    -- if (areaid) then
    --   AreaHelper:clearAllWoodenFence(areaid)
    -- end
    self:wantAtHour()
    return true
  else
    return false
  end
end

function BaseActor:collidePlayer (playerid, isPlayerInFront)
  -- body
end

function BaseActor:defaultCollidePlayerEvent (playerid, isPlayerInFront)
  local actorTeam = CreatureHelper:getTeam(self.objid)
  local playerTeam = PlayerHelper:getTeam(playerid)
  if (actorTeam ~= 0 and actorTeam == playerTeam) then -- 有队伍并且同队
    self.action:stopRun()
    self:collidePlayer(playerid, isPlayerInFront)
    self:wantLookAt(nil, playerid)
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