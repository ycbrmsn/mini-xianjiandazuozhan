-- 基本行为
BaseAction = {
  restTime = 0,
  currentRestTime = 0,
}

function BaseAction:new (o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end

function BaseAction:execute ()
  if (self.currentRestTime > 0) then
    self.currentRestTime = self.currentRestTime - 1
  else
    -- do nothing
  end
end

-- 移动行为
MoveAction = BaseAction:new()

function MoveAction:new (actor, think, positions, isNegDir, index, restTime, speed)
  local style = 'move'
  think = think or style
  index = index or 1
  restTime = restTime or 0
  local toPos = ActorActionHelper:getToPos(positions, isNegDir, index)
  local o = {
    actor = actor,
    think = think,
    style = style,
    positions = positions,
    isNegDir = isNegDir,
    index = index,
    restTime = restTime,
    speed = speed,
    toPos = toPos,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function MoveAction:execute ()
  ActorActionHelper:actionMove(self)
end

-- 靠近行为
ApproachAction = BaseAction:new()

function ApproachAction:new (actor, think, positions, isNegDir, index, restTime, speed)
  local style = 'approach'
  think = think or style
  index = index or 1
  restTime = restTime or 0
  local toPos = ActorActionHelper:getToPos(positions, isNegDir, index)
  local o = {
    actor = actor,
    think = think,
    style = style,
    positions = positions,
    isNegDir = isNegDir,
    index = index,
    restTime = restTime,
    speed = speed,
    toPos = toPos,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function ApproachAction:execute ()
  ActorActionHelper:actionMove(self)
end

-- 巡逻行为
PatrolAction = BaseAction:new()

function PatrolAction:new (actor, think, positions, isNegDir, index, restTime, speed)
  local style = 'patrol'
  think = think or style
  index = index or 1
  restTime = restTime or 5
  local toPos = ActorActionHelper:getToPos(positions, isNegDir, index)
  local o = {
    actor = actor,
    think = think,
    style = style,
    positions = positions,
    isNegDir = isNegDir,
    index = index,
    restTime = restTime,
    speed = speed,
    toPos = toPos,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function PatrolAction:execute ()
  ActorActionHelper:actionMove(self)
end

-- 跟随行为
FollowAction = BaseAction:new()

function FollowAction:new (actor, think, toobjid, speed)
  local style = 'follow'
  think = think or style
  local o = {
    actor = actor,
    think = think,
    style = style,
    toobjid = toobjid,
    speed = speed,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function FollowAction:execute ()
  if (self.currentRestTime > 0) then
    self.currentRestTime = self.currentRestTime - 1
  else
    if (self.actor.cantMoveTime > BaseActorAction.maxCantMoveTime) then
      self.actor:setPosition(self.toPos)
      self.actor.cantMoveTime = 0
    else
      local selfPos = ActorHelper:getMyPosition(self.actor.objid)
      if (selfPos) then
        local toPos = ActorHelper:getMyPosition(self.toobjid)
        if (toPos) then
          local distance = MathHelper:getDistance(selfPos, toPos)
          if (distance < 4) then -- 就在附近
            ActorHelper:lookAt(self.actor.objid, self.toobjid)
          else
            ActorActionHelper:runTo(self.actor, toPos, self.speed)
          end
        end
      end
    end
  end
end

-- 不移动行为
DontMoveAction = BaseAction:new()

function DontMoveAction:new (actor, think)
  local style = 'dontMove'
  think = think or style
  local o = {
    actor = actor,
    think = think,
    style = style,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

-- function DontMoveAction:execute ()
--   if (self.currentRestTime > 0) then
--     self.currentRestTime = self.currentRestTime - 1
--   else
--     -- do nothing
--   end
-- end

-- 自由移动行为
FreeTimeAction = BaseAction:new()

function FreeTimeAction:new (actor, think)
  local style = 'freeTime'
  think = think or style
  local o = {
    actor = actor,
    think = think,
    style = style,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function FreeTimeAction:execute ()
  if (self.currentRestTime > 0) then
    self.currentRestTime = self.currentRestTime - 1
  else
    ActorActionHelper:freeTime(self)
  end
end

-- 自由警戒行为
FreeAndAlertAction = BaseAction:new()

function FreeAndAlertAction:new (actor, think, speed)
  local style = 'freeAndAlert'
  think = think or style
  local o = {
    actor = actor,
    think = think,
    style = style,
    speed = speed,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function FreeAndAlertAction:execute ()
  ActorActionHelper:freeAndAlert(self)
end

-- 区域内自由活动
FreeInAreaAction = BaseAction:new()

function FreeInAreaAction:new (actor, think, restTime, speed)
  local style = 'freeInArea'
  think = think or style
  restTime = restTime or 5
  local o = {
    actor = actor,
    think = think,
    style = style,
    restTime = restTime,
    speed = speed,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function FreeInAreaAction:execute ()
  ActorActionHelper:actionMove(self)
end

-- 区域自由攻击
FreeAttackAction = BaseAction:new()

function FreeAttackAction:new (actor, think, restTime, speed)
  local style = 'freeAttack'
  think = think or style
  restTime = restTime or 5
  local o = {
    actor = actor,
    think = think,
    style = style,
    restTime = restTime,
    speed = speed,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function FreeAttackAction:execute ()
  ActorActionHelper:actionMove(self)
end

-- 想不做事
DoNothingAction = BaseAction:new()

function DoNothingAction:new (actor, think)
  local style = 'doNothing'
  think = think or style
  local o = {
    actor = actor,
    think = think,
    style = style,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

-- function DoNothingAction:execute ()
--   -- body
-- end

-- 睡觉行为
SleepAction = BaseAction:new()

function SleepAction:new (actor, think, faceYaw)
  local style = 'sleep'
  think = think or style
  local o = {
    actor = actor,
    think = think,
    style = style,
    faceYaw = faceYaw,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function SleepAction:execute ()
  if (self.currentRestTime > 0) then
    self.currentRestTime = self.currentRestTime - 1
    if (self.style == 'sleep') then
      self.actor:setFaceYaw(self.faceYaw)
    end
  else
    if (self.style == 'sleep') then
      self.style = 'sleeping'
      ActorActionHelper:playSleep(self.actor)
    elseif (self.style == 'wake') then
      self.actor:doItNow()
    end
  end
end

-- 等待行为
WaitAction = BaseAction:new()

function WaitAction:new (actor, think, restTime)
  local style = 'wait'
  think = think or style
  restTime = restTime or 5
  local o = {
    actor = actor,
    think = think,
    style = style,
    restTime = restTime,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

-- function WaitAction:execute ()
--   -- body
-- end

-- 点/熄蜡烛
ToggleCandleAction = BaseAction:new()

function ToggleCandleAction:new (actor, think, isLitCandle)
  local style = isLitCandle and 'lightCandle' or 'putOutCandle'
  think = think or style
  local o = {
    actor = actor,
    think = think,
    style = style,
    restTime = 2,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function ToggleCandleAction:execute ()
  if (self.currentRestTime > 0) then
    self.currentRestTime = self.currentRestTime - 1
  else
    if (self.style ~= 'handlingCandle') then
      local isLit = self.style == 'lightCandle'
      self.style = 'handlingCandle'
      self.actor:lookAt(self.toPos)
      ActorActionHelper:playAttack(self.actor)
      BlockHelper:handleCandle(self.toPos, isLit)
    else
      if (self.actor.wants[2]) then
        ActorHelper:handleNextWant(self.actor)
      end
    end
  end
end

-- 看行为
LookAtAction = BaseAction:new()

function LookAtAction:new (actor, think, myPosition, restTime)
  local style = 'lookAt'
  think = think or style
  restTime = restTime or 5
  local o = {
    actor = actor,
    think = think,
    style = style,
    dst = myPosition,
    restTime = restTime,
    currentRestTime = restTime,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function LookAtAction:execute ()
  -- LogHelper:debug('lookat execute')
  if (self.currentRestTime > 0) then
    self.currentRestTime = self.currentRestTime - 1
    if (self.style == 'lookAt') then
      self.style = 'lookingAt'
      TimeHelper:callFnContinueRuns(function ()
        self.actor:lookAt(self.dst)
        -- LogHelper:debug('looking at')
      end, self.currentRestTime, self.actor.objid .. 'lookat')
    end
  else
    if (self.style == 'lookingAt') then
      if (self.actor.wants[2]) then
        ActorHelper:handleNextWant(self.actor)
      else -- 没有想法
        -- self.myActor:openAI()
      end
    end
  end
end

-- 强制不做事行为
ForceDoNothingAction = BaseAction:new()

function ForceDoNothingAction:new (actor, think)
  local style = 'forceDoNothing'
  think = think or style
  local o = {
    actor = actor,
    think = think,
    style = style,
    restTime = 1,
    currentRestTime = 1,
    times = 1,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function ForceDoNothingAction:execute ()
  if (self.currentRestTime > 0) then
    self.currentRestTime = self.currentRestTime - 1
    self.actor:stopRun()
  else
    -- do nothing
  end
end

-- 战斗行为
BattleAction = BaseAction:new()

function BattleAction:new (actor, think)
  local style = 'battle'
  think = think or style
  local o = {
    actor = actor,
    think = think,
    style = style,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function BattleAction:execute ()
  if (self.currentRestTime > 0) then
    self.currentRestTime = self.currentRestTime - 1
  else
    self.actor:doItNow()
  end
end