-- actor行为类
BaseActorAction = {
  myActor = nil,
  maxCantMoveTime = 5
}

function BaseActorAction:new (myActor)
  local o = {
    myActor = myActor
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 生物是否是强制移动，强制移动即用脚本让他移动
function BaseActorAction:isForceMove ()
  if (not(self.myActor.wants) or not(self.myActor.wants[1])) then -- 没有想法，则不是
    return false
  end
  local want = self.myActor.wants[1]
  if (want.currentRestTime > 0) then -- 如果在休息，也不是
    return false
  end
  return (want.style == 'move' or want.style == 'patrol' or want.style == 'freeInArea' or want.style == 'approach')
end

-- 跑到指定地点
function BaseActorAction:runTo (pos, speed)
  speed = speed or self.myActor.defaultSpeed
  local x, y, z = math.floor(pos.x) + 0.5, math.floor(pos.y) + 0.5, math.floor(pos.z) + 0.5
  return ActorHelper:tryMoveToPos(self.myActor.objid, x, y, z, speed)
end

-- 传送到指定地点
function BaseActorAction:transmitTo (pos)
  return self.myActor:setPosition(pos.x, pos.y, pos.z)
end

function BaseActorAction:stopRun ()
  self.myActor:closeAI()
  self:runTo(MyPosition:new(self.myActor:getPosition()))
end

function BaseActorAction:playHi (afterSeconds)
  self:playAct(ActorHelper.ACT.HI, afterSeconds)
end

function BaseActorAction:playDown (afterSeconds)
  self:playAct(ActorHelper.ACT.DOWN, afterSeconds)
end

function BaseActorAction:playSleep (afterSeconds)
  self:playAct(ActorHelper.ACT.SLEEP, afterSeconds)
end

function BaseActorAction:playSit (afterSeconds)
  self:playAct(ActorHelper.ACT.SIT, afterSeconds)
end

function BaseActorAction:playAttack (afterSeconds)
  self:playAct(ActorHelper.ACT.ATTACK, afterSeconds)
end

function BaseActorAction:playFree (afterSeconds)
  self:playAct(ActorHelper.ACT.FREE, afterSeconds)
end

function BaseActorAction:playFree2 (afterSeconds)
  self:playAct(ActorHelper.ACT.FREE2, afterSeconds)
end

function BaseActorAction:playPoss (afterSeconds)
  self:playAct(ActorHelper.ACT.POSE, afterSeconds)
end

function BaseActorAction:playAngry (afterSeconds)
  self:playAct(ActorHelper.ACT.ANGRY, afterSeconds)
end

function BaseActorAction:playThink (afterSeconds)
  self:playAct(ActorHelper.ACT.THINK, afterSeconds)
end

function BaseActorAction:playDie (afterSeconds)
  self:playAct(ActorHelper.ACT.DIE, afterSeconds)
end

function BaseActorAction:playStand (afterSeconds)
  self:playAct(ActorHelper.ACT.STAND, afterSeconds)
end

function BaseActorAction:playHappy (afterSeconds)
  self:playAct(ActorHelper.ACT.HAPPY, afterSeconds)
end

function BaseActorAction:playAct (act, afterSeconds)
  if (afterSeconds) then
    TimeHelper:callFnAfterSecond (function (p)
      ActorHelper:playAct(self.myActor.objid, act)
    end, afterSeconds)
  else
    ActorHelper:playAct(self.myActor.objid, act)
  end
end

-- 生物行动
function BaseActorAction:execute ()
  local want
  if (not(self.myActor.wants) or not(self.myActor.wants[1])) then -- 如果生物没有想法，则给他一个原始的想法，然后再行动
    self.myActor:defaultWant()
  end
  want = self.myActor.wants[1]
  if (want.currentRestTime > 0) then -- 如果生物还想休息，则让生物继续休息
    want.currentRestTime = want.currentRestTime - 1
    if (want.style == 'sleep') then
      self.myActor:setFaceYaw(want.faceYaw)
    elseif (want.style == 'lookAt') then
      want.style = 'lookingAt'
      TimeHelper:callFnContinueRuns(function ()
        self.myActor:lookAt(want.dst)
      end, want.restTime, self.myActor.objid .. 'lookat')
    elseif (want.style == 'forceDoNothing') then
      self.myActor:stopRun()
    end
  else
    if (want.style == 'move' or want.style == 'patrol' or want.style == 'freeInArea' or want.style == 'approach') then -- 如果生物想移动/巡逻，则让生物移动/巡逻
      if (self.myActor.cantMoveTime > self.maxCantMoveTime) then
        self:transmitTo(want.toPos)
        self.myActor.cantMoveTime = 0
      else
        -- if (self.myActor.cantMoveTime > 0) then
        --   self.myActor:setWalkSpeed(-1)
        -- end
        self:runTo(want.toPos, want.speed)
      end
    elseif (want.style == 'dontMove') then -- 如果生物想原地不动，则不让生物移动

    elseif (want.style == 'freeTime') then -- 自由活动
      self:freeTime(want)
    elseif (want.style == 'freeAndAlert') then -- 自由警戒
      self:freeAndAlert(want)
    elseif (want.style == 'sleep') then
      want.style = 'sleeping'
      self:playSleep()
    elseif (want.style == 'wake') then
      self.myActor:doItNow()
      -- self.myActor:putOutCandleAndGoToBed()
    elseif (want.style == 'lightCandle' or want.style == 'putOutCandle') then
      self.myActor:lookAt(want.toPos)
    elseif (want.style == 'lookingAt') then
      if (self.myActor.wants[2]) then
        ActorHelper:handleNextWant(self.myActor)
      else -- 没有想法
        -- self.myActor:openAI()
      end
    elseif (want.style == 'battle') then -- 战斗
      self.myActor:doItNow()
    else -- 生物不想做什么，则生物自由安排
      -- do nothing
    end
  end
end

-- 生物表达
function BaseActorAction:express (targetuin, startStr, finishStr, ...)
  local content = StringHelper:concat(...)
  local message = StringHelper:concat(self.myActor:getName(), startStr, content, finishStr)
  ChatHelper:sendSystemMsg(message, targetuin)
end

-- 生物说话
function BaseActorAction:speak (targetuin, ...)
  self:express(targetuin, '：#W', '', ...)
end

function BaseActorAction:speakToAll (...)
  self:speak(nil, ...)
end

-- 生物心想
function BaseActorAction:speakInHeart (targetuin, ...)
  self:express(targetuin, '：#W（', '#W）', ...)
end

function BaseActorAction:speakInHeartToAll (...)
  self:speakInHeart(nil, ...)
end

-- 生物几秒后表达
function BaseActorAction:expressAfterSecond (targetuin, startStr, finishStr, second, ...)
  local content = StringHelper:concat(...)
  local message = StringHelper:concat(self.myActor:getName(), startStr, content, finishStr)
  TimeHelper:callFnAfterSecond (function (p)
    ChatHelper:sendSystemMsg(p.message, p.targetuin)
  end, second, { targetuin = targetuin, message = message })
end

-- 生物几秒后说话
function BaseActorAction:speakAfterSecond (targetuin, second, ...)
  self:expressAfterSecond(targetuin, '：#W', '', second, ...)
end

function BaseActorAction:speakToAllAfterSecond (second, ...)
  self:speakAfterSecond(nil, second, ...)
end

-- 生物几秒后心想
function BaseActorAction:speakInHeartAfterSecond (targetuin, second, ...)
  self:expressAfterSecond(targetuin, '：#W（', '#W）', second, ...)
end

function BaseActorAction:speakInHeartToAllAfterSecond (second, ...)
  self:speakInHeartAfterSecond(nil, second, ...)
end

function BaseActorAction:lightCandle (think, isNow, candlePositions)
  candlePositions = candlePositions or self.myActor.candlePositions
  local index = 1
  for i, v in ipairs(candlePositions) do
    local candle = BlockHelper:getCandle(v)
    if (not(candle) or not(candle.isLit)) then
      if (index == 1 and isNow) then
        self:toggleCandle(think, v, true, true)
      else
        self:toggleCandle(think, v, true)
      end
      index = index + 1
    end
  end
  return index
end

function BaseActorAction:putOutCandle (think, isNow, candlePositions)
  candlePositions = candlePositions or self.myActor.candlePositions
  local index = 1
  for i, v in ipairs(candlePositions) do
    local candle = BlockHelper:getCandle(v)
    if (not(candle) or candle.isLit) then
      if (index == 1 and isNow) then
        self:toggleCandle(think, v, false, true)
      else
        self:toggleCandle(think, v, false)
      end
      index = index + 1
    end
  end
  return index
end

function BaseActorAction:putOutCandleAndGoToBed (candlePositions)
  local index = self:putOutCandle('putOutCandle', true, candlePositions)
  self:goToBed(index == 1)
end

function BaseActorAction:toggleCandle (think, myPosition, isLitCandle, isNow)
  if (not(think)) then
    if (isLitCandle) then
      think = 'lightCandle'
    else
      think = 'putOutCandle'
    end
  end
  if (isNow) then
    self.myActor:wantApproach(think, { myPosition })
  else
    self.myActor:nextWantApproach(think, { myPosition })
  end
  self.myActor:nextWantToggleCandle(think, isLitCandle)
end

function BaseActorAction:goToBed (isNow)
  if (isNow) then
    self.myActor:wantGoToSleep(self.myActor.bedData)
  else
    self.myActor:nextWantGoToSleep(self.myActor.bedData)
  end
end

function BaseActorAction:lookAt (objid)
  local x, y, z
  if (type(objid) == 'table') then
    x, y, z = objid.x, objid.y, objid.z
  else
    x, y, z = ActorHelper:getPosition(objid)
    y = y + ActorHelper:getEyeHeight(objid) - 1
  end
  local x0, y0, z0 = ActorHelper:getPosition(self.myActor.objid)
  if (x == x0 and z == z0) then -- 如果人物就在需要看向的位置上，则不做什么

  else
    y0 = y0 + ActorHelper:getEyeHeight(self.myActor.objid) - 1 -- 生物位置y是地面上一格，所以要减1
    local myVector3 = MyVector3:new(x0, y0, z0, x, y, z)
    local faceYaw = MathHelper:getActorFaceYaw(myVector3)
    local facePitch = MathHelper:getActorFacePitch(myVector3)
    self.myActor:setFaceYaw(faceYaw)
    self.myActor:setFacePitch(facePitch)
  end
end

function BaseActorAction:freeTime (want)
  self.myActor:openAI()
  want.currentRestTime = math.random(10, 20)
  local pos = self.myActor:getMyPosition()
  if (not(pos)) then
    return
  end
  local areaid = AreaHelper:createFreeTimeArea(pos)
  pos = AreaHelper:getRandomPos(areaid)
  AreaHelper:destroyArea(areaid)
  self:runTo(pos)
end

function BaseActorAction:freeAndAlert (want)
  self.myActor:closeAI()
  want.currentRestTime = math.random(10, 20)
  local pos = self.myActor:getMyPosition()
  if (not(pos)) then
    return
  end
  local areaid = AreaHelper:createFreeTimeArea(pos)
  pos = AreaHelper:getRandomPos(areaid)
  AreaHelper:destroyArea(areaid)
  self:runTo(pos, want.speed)
end