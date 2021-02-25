-- 人物行为工具类
ActorActionHelper = {
  maxCantMoveTime = 5,
}

--[[  移动行为数据，参数:
      think想法,
      positions位置数组，即{{ x = x, y = y, z = z }, { x = x, y = y, z = z }},
      isNegDir是否是负向行动，默认是否,
      index位置序数，从1~#t，默认是1，负向则是负方向的第一个,
      restTime巡逻到达一个位置后停留时间，默认是0
      speed奔跑速度（倍速）
--]] 
function ActorActionHelper:getMoveData (think, positions, isNegDir, index, restTime, speed)
  index = index or 1
  restTime = restTime or 0
  local data = { style = 'move', restTime = restTime, currentRestTime = 0, positions = positions, 
    index = index, isNegDir = isNegDir, think = think }
  if (speed) then
    data.speed = speed
  end
  local toPos = self:getToPos(positions, isNegDir, index)
  data.toPos = toPos
  return data
end

-- 靠近行为数据
function ActorActionHelper:getApproachData (think, positions, isNegDir, index, restTime, speed)
  local data = self:getMoveData(think, positions, isNegDir, index, restTime, speed)
  data.style = 'approach'
  return data
end

-- 不移动行为数据
function ActorActionHelper:getDontMoveData (think)
  return { style = 'dontMove', restTime = 0, currentRestTime = 0, think = think }
end

-- 巡逻行为数据
function ActorActionHelper:getPatrolData (think, positions, isNegDir, index, restTime)
  index = index or 1
  restTime = restTime or 5
  local data = { style = 'patrol', restTime = restTime, currentRestTime = 0, positions = positions, 
    index = index, isNegDir = isNegDir, think = think }
  local toPos = self:getToPos(positions, isNegDir, index)
  data.toPos = toPos
  return data
end

-- 自由活动数据
function ActorActionHelper:getFreeTimeData (think)
  return { style = 'freeTime', restTime = 0, currentRestTime = 0, think = think }
end

-- 自由活动并警戒数据
function ActorActionHelper:getFreeAndAlertData (think, speed)
  local data = { style = 'freeAndAlert', restTime = 0, currentRestTime = 0, think = think }
  if (speed) then
    data.speed = speed
  end
  return data
end

-- 在区域内自由活动数据
function ActorActionHelper:getFreeInAreaData (think, restTime)
  restTime = restTime or 5
  return { style = 'freeInArea', restTime = restTime, currentRestTime = 0, think = think }
end

-- 在区域内自由攻击数据
function ActorActionHelper:getFreeAttackData (think, restTime)
  restTime = restTime or 5
  return { style = 'freeAttack', restTime = restTime, currentRestTime = 0, think = think }
end

-- 生物想不做事数据
function ActorActionHelper:getDoNothingData (think)
  return { style = 'doNothing', restTime = 0, currentRestTime = 0, think = think }
end

-- 生物睡觉数据
function ActorActionHelper:getSleepData (think, faceYaw)
  return { style = 'sleep', restTime = 0, currentRestTime = 0, faceYaw = faceYaw, think = think }
end

-- 生物等待数据
function ActorActionHelper:getWaitData (think, restTime)
  restTime = restTime or 5
  return { style = 'wait', restTime = restTime, currentRestTime = 0, think = think }
end

-- 生物处理蜡烛数据
function ActorActionHelper:getToggleCandleData (think, isLitCandle)
  local style
  if (isLitCandle) then
    style = 'lightCandle'
  else
    style = 'putOutCandle'
  end
  return { style = style, restTime = 2, currentRestTime = 0, think = think }
end

-- 生物看向某人/某物数据
function ActorActionHelper:getLookAtData (think, myPosition, restTime)
  restTime = restTime or 5
  return { style = 'lookAt', restTime = restTime, currentRestTime = restTime, dst = myPosition, think = think }
end

-- 强制生物不做事数据
function ActorActionHelper:getForceDoNothing (think)
  return { style = 'forceDoNothing', restTime = 1, currentRestTime = 1, think = think, times = 1 }
end

-- 生物战斗数据
function ActorActionHelper:getBattleData (think)
  return { style = 'battle', restTime = 0, currentRestTime = 0, think = think }
end

function ActorActionHelper:runTo (actor, pos, speed)
  speed = speed or actor.defaultSpeed
  local x, y, z = math.floor(pos.x) + 0.5, math.floor(pos.y) + 0.5, math.floor(pos.z) + 0.5
  return ActorHelper:tryMoveToPos(actor.objid, x, y, z, speed)
end

-- 获取前往位置
function ActorActionHelper:getToPos (positions, isNegDir, index)
  if (isNegDir) then 
    return positions[#positions - index + 1]
  else
    return positions[index]
  end
end

-- 创建前往位置
function ActorActionHelper:createMoveToPos (want)
  local areaid = AreaHelper:createMovePosArea(want.toPos)
  want.toAreaId = areaid
end

-- 创建靠近位置
function ActorActionHelper:createApproachToPos (want)
  local areaid = AreaHelper:createApproachPosArea(want.toPos)
  want.toAreaId = areaid
end

-- 获取下一个位置，并修改want.index
function ActorActionHelper:getNextPos (want)
  local style, positions, index, isNegDir = want.style, want.positions, want.index, want.isNegDir
  if (style == 'move') then
    index = index + 1
    want.index = index
    if (index > #positions) then -- index超出边界
      return nil
    else
      return self:getToPos(positions, isNegDir, index)
    end
  elseif (style == 'patrol') then
    index = index + 1
    if (index > #positions) then -- index超出边界
      index = 1
    end
    want.index = index
    return self:getToPos(positions, isNegDir, index)
  else -- 其他行为
    index = index + 1
    want.index = index
    return nil
  end
end

-- 设置区域自由活动
function ActorActionHelper:setFreeInArea (think, actor, posPairs, isAppend)
  if (actor.freeInAreaIds and #actor.freeInAreaIds > 0) then -- 如果自由活动区域已经存在，则销毁
    for i, v in ipairs(actor.freeInAreaIds) do
      AreaHelper:destroyArea(v)
    end
  end
  local want = FreeInAreaAction:new(actor, think)
  if (isAppend) then
    table.insert(actor.wants, want)
  else
    actor.wants = { want }
  end
  actor.freeInAreaIds = self:getFreeInAreaIds(posPairs)
  return want
end

-- 设置区域自由攻击
function ActorActionHelper:setFreeAttack (think, actor, posPairs, isAppend)
  if (actor.freeInAreaIds and #actor.freeInAreaIds > 0) then -- 如果自由活动区域已经存在，则销毁
    for i, v in ipairs(actor.freeInAreaIds) do
      AreaHelper:destroyArea(v)
    end
  end
  local want = FreeAttackAction:new(actor, think)
  if (isAppend) then
    table.insert(actor.wants, want)
  else
    actor.wants = { want }
  end
  actor.freeInAreaIds = self:getFreeInAreaIds(posPairs)
  return want
end

-- 获得区域ids，参数为二维数组{{posBeg, posEnd},{posBeg, posEnd}}
function ActorActionHelper:getFreeInAreaIds (posPairs)
  local areaids = {}
  for i, v in ipairs(posPairs) do
    table.insert(areaids, AreaHelper:createAreaRectByRange(v[1], v[2]))
  end
  return areaids
end

-- 获得区域中的一个位置
function ActorActionHelper:getFreeInAreaPos (freeInAreaIds)
  local num, areaid = #freeInAreaIds
  if (num > 1) then -- 多个位置，则随机一个
    local index = math.random(1, num)
    areaid = freeInAreaIds[index]
  elseif (num == 1) then -- 一个位置
    areaid = freeInAreaIds[1]
  else
    return nil
  end
  return AreaHelper:getRandomAirPositionInArea(areaid)
end

-- 更新生物行为状态
function ActorActionHelper:updateActionState (actor)
  if (actor.wants) then
    local style = actor.wants[1].style
    if (style == 'move' or style == 'patrol' or style == 'freeInArea' or style == 'freeAttack'
      or style == 'doNothing' or style == 'sleep') then
      -- actor:enableMove(true)
      actor:closeAI()
    elseif (style == 'dontMove') then
      -- actor:enableMove(false)
    end
  end
end

-- 想法加上回调事件
function ActorActionHelper:callback (want, f)
  want.callback = f
end

-- 移动
function ActorActionHelper:actionMove (want)
  if (want.currentRestTime > 0) then
    want.currentRestTime = want.currentRestTime - 1
  else
    if (want.actor.cantMoveTime > ActorActionHelper.maxCantMoveTime) then
      want.actor:setPosition(want.toPos)
      want.actor.cantMoveTime = 0
    else
      local selfPos = ActorHelper:getMyPosition(want.actor.objid)
      if (selfPos) then
        ActorActionHelper:runTo(want.actor, want.toPos, want.speed)
      end
    end
  end
end

function ActorActionHelper:freeTime (want)
  want.actor:openAI()
  want.currentRestTime = math.random(10, 20)
  local pos = want.actor:getMyPosition()
  if (not(pos)) then
    return
  end
  ActorActionHelper:runTo(want.actor, AreaHelper:getFreeTimePos(pos), want.speed)
end

function ActorActionHelper:freeAndAlert (want)
  want.actor:closeAI()
  want.currentRestTime = math.random(10, 20)
  local pos = want.actor:getMyPosition()
  if (not(pos)) then
    return
  end
  ActorActionHelper:runTo(want.actor, AreaHelper:getFreeTimePos(pos), want.speed)
end

function ActorActionHelper:playAct (objid, act, afterSeconds)
  if type(objid) == 'table' then -- 可传入actor
    objid = objid.objid
  end
  if (afterSeconds) then
    TimeHelper:callFnAfterSecond (function (p)
      ActorHelper:playAct(objid, act)
    end, afterSeconds)
  else
    ActorHelper:playAct(objid, act)
  end
end

function ActorActionHelper:playHi (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.HI, afterSeconds)
end

function ActorActionHelper:playDown (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.DOWN, afterSeconds)
end

function ActorActionHelper:playSleep (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.SLEEP, afterSeconds)
end

function ActorActionHelper:playSit (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.SIT, afterSeconds)
end

function ActorActionHelper:playAttack (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.ATTACK, afterSeconds)
end

function ActorActionHelper:playFree (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.FREE, afterSeconds)
end

function ActorActionHelper:playFree2 (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.FREE2, afterSeconds)
end

function ActorActionHelper:playPoss (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.POSE, afterSeconds)
end

function ActorActionHelper:playAngry (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.ANGRY, afterSeconds)
end

function ActorActionHelper:playThink (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.THINK, afterSeconds)
end

function ActorActionHelper:playDie (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.DIE, afterSeconds)
end

function ActorActionHelper:playStand (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.STAND, afterSeconds)
end

function ActorActionHelper:playHappy (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.HAPPY, afterSeconds)
end

function ActorActionHelper:playThank (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.THANK, afterSeconds)
end

function ActorActionHelper:playStretch (objid, afterSeconds)
  self:playAct(objid, ActorHelper.ACT.STRETCH, afterSeconds)
end