-- actor想法类
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
  local want = BaseActorActionHelper:getMoveData(think, positions, isNegDir, index, restTime, speed)
  self.myActor.wants = { want }
  -- 创建当前前往区域
  BaseActorActionHelper:createMoveToPos(want)
  self.myActor.action:runTo(want.toPos)
end

function BaseActorWant:wantApproach (think, positions, isNegDir, index, restTime)
  AreaHelper:removeToArea(self.myActor)
  self.myActor:closeAI()
  self.myActor.think = think
  local want = BaseActorActionHelper:getApproachData(think, positions, isNegDir, index, restTime)
  self.myActor.wants = { want }
  -- 创建当前前往区域
  BaseActorActionHelper:createApproachToPos(want)
end

function BaseActorWant:wantDontMove (think)
  AreaHelper:removeToArea(self.myActor)
  think = think or 'dontMove'
  self.myActor.think = think
  self.myActor.wants = { BaseActorActionHelper:getDontMoveData(think) }
  self.myActor:stopRun()
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
  local want = BaseActorActionHelper:getPatrolData(think, positions, isNegDir, index, restTime)
  self.myActor.wants = { want }
  -- 创建当前前往区域
  BaseActorActionHelper:createMoveToPos(want)
end

function BaseActorWant:wantFreeTime (think)
  AreaHelper:removeToArea(self.myActor)
  think = think or 'free'
  self.myActor:openAI()
  self.myActor.think = think
  local want = BaseActorActionHelper:getFreeTimeData(think)
  self.myActor.wants = { want }
  self.myActor.action:freeTime(want)
end

-- 自由移动并且警戒着
function BaseActorWant:wantFreeAndAlert (think, speed)
  AreaHelper:removeToArea(self.myActor)
  think = think or 'alert'
  self.myActor:closeAI()
  self.myActor.think = think
  local want = BaseActorActionHelper:getFreeAndAlertData(think, speed)
  self.myActor.wants = { want }
  self.myActor.action:freeAndAlert(want)
end

function BaseActorWant:wantFreeInArea (think, posPairs)
  AreaHelper:removeToArea(self.myActor)
  if (not(posPairs)) then
    posPairs = think
    think = 'free'
  end
  self.myActor:closeAI()
  self.myActor.think = think
  local want = BaseActorActionHelper:setFreeInArea(think, self.myActor, posPairs)
  want.toPos = BaseActorActionHelper:getFreeInAreaPos(self.myActor.freeInAreaIds)
  -- 创建当前前往区域
  BaseActorActionHelper:createMoveToPos(want)
end

function BaseActorWant:wantDoNothing (think)
  AreaHelper:removeToArea(self.myActor)
  think = think or 'doNothing'
  self.myActor:closeAI()
  self.myActor.think = think
  self.myActor.wants = { BaseActorActionHelper:getDoNothingData(think) }
end

function BaseActorWant:wantLookAt (think, myPosition, restTime)
  restTime = restTime or 5
  self.myActor:closeAI()
  if (self.myActor:isWantsExist()) then
    think = think or self.myActor.think
    local want = BaseActorActionHelper:getLookAtData(think, myPosition, restTime)
    if (self.myActor.wants[1].style == 'lookAt' or self.myActor.wants[1].style == 'lookingAt') then
      self.myActor.wants[1] = want
    else
      table.insert(self.myActor.wants, 1, want)
    end
  else
    think = think or 'lookAt'
    local want = BaseActorActionHelper:getLookAtData(think, myPosition, restTime)
    self.myActor.wants = { want }
  end
  self.myActor.think = think
end

function BaseActorWant:wantGoToSleep (bedData)
  AreaHelper:removeToArea(self.myActor)
  self:wantMove('sleep', { bedData[1] })
  self:nextWantSleep('sleep', bedData[2])
end

function BaseActorWant:wantBattle (think)
  AreaHelper:removeToArea(self.myActor)
  think = think or 'battle'
  self.myActor.think = think
  self.myActor.wants = { BaseActorActionHelper:getBattleData(think) }
end

function BaseActorWant:nextWantMove (think, positions, isNegDir, index, restTime, speed)
  if (self.myActor:isWantsExist()) then
    local want = BaseActorActionHelper:getMoveData(think, positions, isNegDir, index, restTime, speed)
    table.insert(self.myActor.wants, want)
  else
    self:wantMove(think, positions, isNegDir, index, restTime, speed)
  end
end

function BaseActorWant:nextWantApproach (think, positions, isNegDir, index, restTime)
  if (self.myActor:isWantsExist()) then
    local want = BaseActorActionHelper:getApproachData(think, positions, isNegDir, index, restTime)
    table.insert(self.myActor.wants, want)
  else
    self:wantApproach(think, positions, isNegDir, index, restTime)
  end
end

function BaseActorWant:nextWantPatrol (think, positions, isNegDir, index, restTime)
  if (self.myActor:isWantsExist()) then
    local want = BaseActorActionHelper:getPatrolData(think, positions, isNegDir, index, restTime)
    table.insert(self.myActor.wants, want)
  else
    self:wantPatrol(think, positions, isNegDir, index, restTime)
  end
end

function BaseActorWant:nextWantFreeInArea (think, posPairs)
  if (self.myActor:isWantsExist()) then
    if (not(posPairs)) then
      posPairs = think
      think = 'free'
    end
    BaseActorActionHelper:setFreeInArea(think, self.myActor, posPairs, true)
  else
    self:wantFreeInArea(think, posPairs)
  end
end

function BaseActorWant:nextWantDoNothing (think)
  if (self.myActor:isWantsExist()) then
    think = think or 'doNothing'
    table.insert(self.myActor.wants, BaseActorActionHelper:getDoNothingData(think))
  else
    self:wantDoNothing(think)
  end
end

function BaseActorWant:nextWantLookAt (think, pos, restTime)
  restTime = restTime or 5
  if (self.myActor:isWantsExist()) then
    think = think or self.myActor.wants[#self.myActor.wants].think or 'lookAt'
    table.insert(self.myActor.wants, BaseActorActionHelper:getLookAtData(think, pos, restTime))
  else
    self:wantLookAt(think, pos, restTime)
  end
end

function BaseActorWant:nextWantSleep (think, faceYaw)
  self:nextWantWait(think, 2)
  table.insert(self.myActor.wants, BaseActorActionHelper:getSleepData(think, faceYaw))
end

function BaseActorWant:nextWantWait (think, second)
  table.insert(self.myActor.wants, BaseActorActionHelper:getWaitData(think, second))
end

function BaseActorWant:nextWantGoToSleep (bedData)
  if (self.myActor:isWantsExist()) then
    self:nextWantMove('sleep', { bedData[1] })
    self:nextWantSleep('sleep', bedData[2])
  else
    self:wantGoToSleep(bedData)
  end
end

function BaseActorWant:nextWantToggleCandle (think, isLitCandle)
  table.insert(self.myActor.wants, BaseActorActionHelper:getToggleCandleData(think, isLitCandle))
end

function BaseActorWant:forceDoNothing (think)
  self.myActor:closeAI()
  if (self.myActor:isWantsExist()) then
    if (self.myActor.wants[1].style == 'forceDoNothing') then -- 如果已经存在，则次数叠加
      self.myActor.wants[1].times = self.myActor.wants[1].times + 1
    else
      think = think or self.myActor.think
      local want = BaseActorActionHelper:getForceDoNothing(think)
      table.insert(self.myActor.wants, 1, want)
    end
  else
    think = think or 'forceDoNothing'
    local want = BaseActorActionHelper:getForceDoNothing(think)
    self.myActor.wants = { want }
  end
  self.myActor.think = think
end