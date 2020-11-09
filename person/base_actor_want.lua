-- 角色想法类
BaseActorWant = {}

function BaseActorWant:new (myActor)
  local o = {
    myActor = myActor
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function BaseActorWant:wantMove (think, positions, isNegDir, index, restTime, speed)
  AreaHelper:removeToArea(self.myActor)
  self.myActor:closeAI()
  self.myActor.think = think
  local want = ActorActionHelper:getMoveData(think, positions, isNegDir, index, restTime, speed)
  self.myActor.wants = { want }
  -- 创建当前前往区域
  ActorActionHelper:createMoveToPos(want)
  self.myActor.action:runTo(want.toPos)
  return want
end

function BaseActorWant:wantApproach (think, positions, isNegDir, index, restTime, speed)
  AreaHelper:removeToArea(self.myActor)
  self.myActor:closeAI()
  self.myActor.think = think
  local want = ActorActionHelper:getApproachData(think, positions, isNegDir, index, restTime, speed)
  self.myActor.wants = { want }
  -- 创建当前前往区域
  ActorActionHelper:createApproachToPos(want)
  return want
end

function BaseActorWant:wantDontMove (think)
  AreaHelper:removeToArea(self.myActor)
  think = think or 'dontMove'
  self.myActor.think = think
  local want = ActorActionHelper:getDontMoveData(think)
  self.myActor.wants = { want }
  self.myActor:stopRun()
  return want
end

function BaseActorWant:wantStayForAWhile(second)
  second = second or 5 -- 默认休息5秒
  if (not(self.myActor.wants)) then -- 如果生物没有想法，则给他一个原始的想法
    self.myActor:defaultWant()
  end
  self.myActor.wants[1].currentRestTime = second
  self.myActor.action:stopRun()
end

function BaseActorWant:wantPatrol (think, positions, isNegDir, index, restTime)
  AreaHelper:removeToArea(self.myActor)
  -- LogHelper:debug(self:getName() .. '想巡逻')
  self.myActor:closeAI()
  self.myActor.think = think
  local want = ActorActionHelper:getPatrolData(think, positions, isNegDir, index, restTime)
  self.myActor.wants = { want }
  -- 创建当前前往区域
  ActorActionHelper:createMoveToPos(want)
  return want
end

function BaseActorWant:wantFreeTime (think)
  AreaHelper:removeToArea(self.myActor)
  think = think or 'free'
  self.myActor:openAI()
  self.myActor.think = think
  local want = ActorActionHelper:getFreeTimeData(think)
  self.myActor.wants = { want }
  self.myActor.action:freeTime(want)
  return want
end

-- 自由移动并且警戒着
function BaseActorWant:wantFreeAndAlert (think, speed)
  AreaHelper:removeToArea(self.myActor)
  think = think or 'alert'
  self.myActor:closeAI()
  self.myActor.think = think
  local want = ActorActionHelper:getFreeAndAlertData(think, speed)
  self.myActor.wants = { want }
  self.myActor.action:freeAndAlert(want)
  return want
end

function BaseActorWant:wantFreeInArea (think, posPairs)
  AreaHelper:removeToArea(self.myActor)
  if (not(posPairs)) then
    posPairs = think
    think = 'free'
  end
  self.myActor:closeAI()
  self.myActor.think = think
  local want = ActorActionHelper:setFreeInArea(think, self.myActor, posPairs)
  want.toPos = ActorActionHelper:getFreeInAreaPos(self.myActor.freeInAreaIds)
  -- 创建当前前往区域
  ActorActionHelper:createMoveToPos(want)
  return want
end

function BaseActorWant:wantFreeAttack (think, posPairs)
  AreaHelper:removeToArea(self.myActor)
  if (not(posPairs)) then
    posPairs = think
    think = 'freeAttack'
  end
  self.myActor:closeAI()
  self.myActor.think = think
  local want = ActorActionHelper:setFreeAttack(think, self.myActor, posPairs)
  want.toPos = ActorActionHelper:getFreeInAreaPos(self.myActor.freeInAreaIds)
  -- 创建当前前往区域
  ActorActionHelper:createMoveToPos(want)
  return want
end

function BaseActorWant:wantDoNothing (think)
  AreaHelper:removeToArea(self.myActor)
  think = think or 'doNothing'
  self.myActor:closeAI()
  self.myActor.think = think
  local want = ActorActionHelper:getDoNothingData(think)
  self.myActor.wants = { want }
  return want
end

function BaseActorWant:wantLookAt (think, myPosition, restTime)
  restTime = restTime or 5
  self.myActor:closeAI()
  local want
  if (self.myActor:isWantsExist()) then
    think = think or self.myActor.think
    want = ActorActionHelper:getLookAtData(think, myPosition, restTime)
    if (self.myActor.wants[1].style == 'lookAt' or self.myActor.wants[1].style == 'lookingAt') then
      self.myActor.wants[1] = want
    else
      table.insert(self.myActor.wants, 1, want)
    end
  else
    think = think or 'lookAt'
    want = ActorActionHelper:getLookAtData(think, myPosition, restTime)
    self.myActor.wants = { want }
  end
  self.myActor.think = think
  return want
end

function BaseActorWant:wantGoToSleep (bedData)
  AreaHelper:removeToArea(self.myActor)
  self:wantMove('sleep', { bedData[1] })
  return self:nextWantSleep('sleep', bedData[2])
end

function BaseActorWant:wantBattle (think)
  AreaHelper:removeToArea(self.myActor)
  think = think or 'battle'
  self.myActor.think = think
  local want = ActorActionHelper:getBattleData(think)
  self.myActor.wants = { want }
  return want
end

function BaseActorWant:nextWantMove (think, positions, isNegDir, index, restTime, speed)
  local want
  if (self.myActor:isWantsExist()) then
    want = ActorActionHelper:getMoveData(think, positions, isNegDir, index, restTime, speed)
    table.insert(self.myActor.wants, want)
  else
    want = self:wantMove(think, positions, isNegDir, index, restTime, speed)
  end
  return want
end

function BaseActorWant:nextWantApproach (think, positions, isNegDir, index, restTime)
  local want
  if (self.myActor:isWantsExist()) then
    want = ActorActionHelper:getApproachData(think, positions, isNegDir, index, restTime)
    table.insert(self.myActor.wants, want)
  else
    want = self:wantApproach(think, positions, isNegDir, index, restTime)
  end
  return want
end

function BaseActorWant:nextWantPatrol (think, positions, isNegDir, index, restTime)
  local want
  if (self.myActor:isWantsExist()) then
    want = ActorActionHelper:getPatrolData(think, positions, isNegDir, index, restTime)
    table.insert(self.myActor.wants, want)
  else
    want = self:wantPatrol(think, positions, isNegDir, index, restTime)
  end
  return want
end

function BaseActorWant:nextWantFreeInArea (think, posPairs)
  local want
  if (self.myActor:isWantsExist()) then
    if (not(posPairs)) then
      posPairs = think
      think = 'free'
    end
    want = ActorActionHelper:setFreeInArea(think, self.myActor, posPairs, true)
  else
    want = self:wantFreeInArea(think, posPairs)
  end
  return want
end

function BaseActorWant:nextWantFreeAttack (think, posPairs)
  local want
  if (self.myActor:isWantsExist()) then
    if (not(posPairs)) then
      posPairs = think
      think = 'freeAttack'
    end
    want = ActorActionHelper:setFreeAttack(think, self.myActor, posPairs, true)
  else
    want = self:wantFreeAttack(think, posPairs)
  end
  return want
end

function BaseActorWant:nextWantDoNothing (think)
  local want
  if (self.myActor:isWantsExist()) then
    think = think or 'doNothing'
    want = ActorActionHelper:getDoNothingData(think)
    table.insert(self.myActor.wants, want)
  else
    want = self:wantDoNothing(think)
  end
  return want
end

function BaseActorWant:nextWantLookAt (think, pos, restTime)
  restTime = restTime or 5
  local want
  if (self.myActor:isWantsExist()) then
    think = think or self.myActor.wants[#self.myActor.wants].think or 'lookAt'
    want = ActorActionHelper:getLookAtData(think, pos, restTime)
    table.insert(self.myActor.wants, want)
  else
    want = self:wantLookAt(think, pos, restTime)
  end
  return want
end

function BaseActorWant:nextWantSleep (think, faceYaw)
  local want = ActorActionHelper:getSleepData(think, faceYaw)
  self:nextWantWait(think, 2)
  table.insert(self.myActor.wants, want)
  return want
end

function BaseActorWant:nextWantWait (think, second)
  local want = ActorActionHelper:getWaitData(think, second)
  table.insert(self.myActor.wants, want)
  return want
end

function BaseActorWant:nextWantGoToSleep (bedData)
  if (self.myActor:isWantsExist()) then
    self:nextWantMove('sleep', { bedData[1] })
    return self:nextWantSleep('sleep', bedData[2])
  else
    return self:wantGoToSleep(bedData)
  end
end

function BaseActorWant:nextWantToggleCandle (think, isLitCandle)
  local want = ActorActionHelper:getToggleCandleData(think, isLitCandle)
  table.insert(self.myActor.wants, want)
  return want
end

function BaseActorWant:forceDoNothing (think)
  self.myActor:closeAI()
  local want
  if (self.myActor:isWantsExist()) then
    want = self.myActor.wants[1]
    if (want.style == 'forceDoNothing') then -- 如果已经存在，则次数叠加
      want.times = want.times + 1
    else
      think = think or 'forceDoNothing'
      want = ActorActionHelper:getForceDoNothing(think)
      table.insert(self.myActor.wants, 1, want)
    end
  else
    think = think or 'forceDoNothing'
    want = ActorActionHelper:getForceDoNothing(think)
    self.myActor.wants = { want }
  end
  self.myActor.think = think
  return want
end