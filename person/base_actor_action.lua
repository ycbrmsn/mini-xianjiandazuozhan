-- 角色行为类
BaseActorAction = {
  myActor = nil,
  maxCantMoveTime = 5,
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
  return (want.style == 'move' or want.style == 'patrol' or want.style == 'freeInArea' 
    or want.style == 'freeAttack' or want.style == 'approach')
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
  -- self.myActor:closeAI()
  -- self:runTo(MyPosition:new(self.myActor:getPosition()))
  CreatureHelper:stopRun(self.myActor.objid, self.myActor.defaultSpeed or 300)
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

function BaseActorAction:playThank (afterSeconds)
  self:playAct(ActorHelper.ACT.THANK, afterSeconds)
end

function BaseActorAction:playStretch (afterSeconds)
  self:playAct(ActorHelper.ACT.STRETCH, afterSeconds)
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
  if (not(want.execute)) then
    print(want)
  end
  want:execute()
  -- if (want.currentRestTime > 0) then -- 如果生物还想休息，则让生物继续休息
  --   want.currentRestTime = want.currentRestTime - 1
  --   if (want.style == 'sleep') then
  --     self.myActor:setFaceYaw(want.faceYaw)
  --   elseif (want.style == 'lookAt') then
  --     want.style = 'lookingAt'
  --     TimeHelper:callFnContinueRuns(function ()
  --       self.myActor:lookAt(want.dst)
  --     end, want.currentRestTime, self.myActor.objid .. 'lookat')
  --   elseif (want.style == 'forceDoNothing') then
  --     self.myActor:stopRun()
  --   end
  -- else
  --   if (want.style == 'move' or want.style == 'patrol' or want.style == 'freeInArea'
  --     or want.style == 'freeAttack' or want.style == 'approach') then -- 如果生物想移动/巡逻，则让生物移动/巡逻
  --     if (self.myActor.cantMoveTime > self.maxCantMoveTime) then
  --       self:transmitTo(want.toPos)
  --       self.myActor.cantMoveTime = 0
  --     else
  --       -- if (self.myActor.cantMoveTime > 0) then
  --       --   self.myActor:setWalkSpeed(-1)
  --       -- end
  --       self:runTo(want.toPos, want.speed)
  --     end
  --   elseif (want.style == 'follow') then
  --     want:execute()
  --   elseif (want.style == 'dontMove') then -- 如果生物想原地不动，则不让生物移动

  --   elseif (want.style == 'freeTime') then -- 自由活动
  --     self:freeTime(want)
  --   elseif (want.style == 'freeAndAlert') then -- 自由警戒
  --     self:freeAndAlert(want)
  --   elseif (want.style == 'sleep') then
  --     want.style = 'sleeping'
  --     self:playSleep()
  --   elseif (want.style == 'sleeping') then
  --     -- 暂不处理
  --   elseif (want.style == 'wake') then
  --     self.myActor:doItNow()
  --     -- self.myActor:putOutCandleAndGoToBed()
  --   elseif (want.style == 'lightCandle' or want.style == 'putOutCandle') then
  --     local isLit = want.style == 'lightCandle'
  --     want.style = 'handlingCandle'
  --     self.myActor:lookAt(want.toPos)
  --     self:playAttack()
  --     -- 1秒后蜡烛台变化，并执行下一个动作
  --     -- TimeHelper:callFnAfterSecond (function (p)
  --     BlockHelper:handleCandle(want.toPos, isLit)
  --     -- end, 1)
  --   elseif (want.style == 'handlingCandle') then
  --     if (self.myActor.wants[2]) then
  --       ActorHelper:handleNextWant(self.myActor)
  --     end
  --   elseif (want.style == 'lookingAt') then
  --     if (self.myActor.wants[2]) then
  --       ActorHelper:handleNextWant(self.myActor)
  --     else -- 没有想法
  --       -- self.myActor:openAI()
  --     end
  --   elseif (want.style == 'battle') then -- 战斗
  --     self.myActor:doItNow()
  --   else -- 生物不想做什么，则生物自由安排
  --     -- do nothing
  --   end
  -- end
end

-- 生物说话
function BaseActorAction:speak (targetuin, ...)
  ChatHelper:speak(self.myActor:getName(), targetuin, ...)
end

function BaseActorAction:speakToAll (...)
  self:speak(nil, ...)
end

-- 生物心想
function BaseActorAction:thinkTo (targetuin, ...)
  ChatHelper:think(self.myActor:getName(), targetuin, ...)
end

function BaseActorAction:think (...)
  self:thinkTo(nil, ...)
end

-- 生物几秒后说话
function BaseActorAction:speakToAfterSeconds (targetuin, second, ...)
  local content = StringHelper:concat(...)
  TimeHelper:callFnAfterSecond (function (p)
    self:speak(targetuin, content)
  end, second)
end

function BaseActorAction:speakAfterSeconds (second, ...)
  self:speakToAfterSeconds(nil, second, ...)
end

-- 生物几秒后心想
function BaseActorAction:thinkToAfterSeconds (targetuin, second, ...)
  local content = StringHelper:concat(...)
  TimeHelper:callFnAfterSecond (function (p)
    self:thinkTo(targetuin, content)
  end, second)
end

function BaseActorAction:thinkAfterSeconds (second, ...)
  self:thinkToAfterSeconds(nil, second, ...)
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

-- 生物看向
function BaseActorAction:lookAt (toobjid)
  ActorHelper:lookAt(self.myActor.objid, toobjid)
end
