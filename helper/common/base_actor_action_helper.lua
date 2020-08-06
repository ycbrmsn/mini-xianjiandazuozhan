-- 人物行为工具类
BaseActorActionHelper = {}

--[[  移动行为数据，参数:
      think想法,
      positions位置数组，即{{ x = x, y = y, z = z }, { x = x, y = y, z = z }},
      isNegDir是否是负向行动，默认是否,
      index位置序数，从1~#t，默认是1，负向则是负方向的第一个,
      restTime巡逻到达一个位置后停留时间，默认是0
      speed奔跑速度（倍速）
--]] 
function BaseActorActionHelper:getMoveData (think, positions, isNegDir, index, restTime, speed)
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
function BaseActorActionHelper:getApproachData (think, positions, isNegDir, index, restTime)
  local data = self:getMoveData(think, positions, isNegDir, index, restTime)
  data.style = 'approach'
  return data
end

-- 不移动行为数据
function BaseActorActionHelper:getDontMoveData (think)
  return { style = 'dontMove', restTime = 0, currentRestTime = 0, think = think }
end

-- 巡逻行为数据
function BaseActorActionHelper:getPatrolData (think, positions, isNegDir, index, restTime)
  index = index or 1
  restTime = restTime or 5
  local data = { style = 'patrol', restTime = restTime, currentRestTime = 0, positions = positions, 
    index = index, isNegDir = isNegDir, think = think }
  local toPos = self:getToPos(positions, isNegDir, index)
  data.toPos = toPos
  return data
end

-- 自由活动数据
function BaseActorActionHelper:getFreeTimeData (think)
  return { style = 'freeTime', restTime = 0, currentRestTime = 0, think = think }
end

-- 自由活动并警戒数据
function BaseActorActionHelper:getFreeAndAlertData (think, speed)
  local data = { style = 'freeAndAlert', restTime = 0, currentRestTime = 0, think = think }
  if (speed) then
    data.speed = speed
  end
  return data
end

-- 在区域内自由活动数据
function BaseActorActionHelper:getFreeInAreaData (think, restTime)
  restTime = restTime or 5
  return { style = 'freeInArea', restTime = restTime, currentRestTime = 0, think = think }
end

-- 生物想不做事数据
function BaseActorActionHelper:getDoNothingData (think)
  return { style = 'doNothing', restTime = 0, currentRestTime = 0, think = think }
end

-- 生物睡觉数据
function BaseActorActionHelper:getSleepData (think, faceYaw)
  return { style = 'sleep', restTime = 0, currentRestTime = 0, faceYaw = faceYaw, think = think }
end

-- 生物等待数据
function BaseActorActionHelper:getWaitData (think, restTime)
  restTime = restTime or 5
  return { style = 'wait', restTime = restTime, currentRestTime = 0, think = think }
end

-- 生物处理蜡烛数据
function BaseActorActionHelper:getToggleCandleData (think, isLitCandle)
  local style
  if (isLitCandle) then
    style = 'lightCandle'
  else
    style = 'putOutCandle'
  end
  return { style = style, restTime = 0, currentRestTime = 0, think = think }
end

-- 生物看向某人/某物数据
function BaseActorActionHelper:getLookAtData (think, myPosition, restTime)
  restTime = restTime or 5
  return { style = 'lookAt', restTime = restTime, currentRestTime = restTime, dst = myPosition, think = think }
end

-- 强制生物不做事数据
function BaseActorActionHelper:getForceDoNothing (think)
  return { style = 'forceDoNothing', restTime = 1, currentRestTime = 1, think = think, times = 1 }
end

-- 生物战斗数据
function BaseActorActionHelper:getBattleData (think)
  return { style = 'battle', restTime = 0, currentRestTime = 0, think = think }
end

-- 获取前往位置
function BaseActorActionHelper:getToPos (positions, isNegDir, index)
  if (isNegDir) then 
    return positions[#positions - index + 1]
  else
    return positions[index]
  end
end

-- 创建前往位置
function BaseActorActionHelper:createMoveToPos (want)
  local areaid = AreaHelper:createMovePosArea(want.toPos)
  want.toAreaId = areaid
end

-- 创建靠近位置
function BaseActorActionHelper:createApproachToPos (want)
  local areaid = AreaHelper:createApproachPosArea(want.toPos)
  want.toAreaId = areaid
end

-- 获取下一个位置，并修改want.index
function BaseActorActionHelper:getNextPos (want)
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
function BaseActorActionHelper:setFreeInArea (think, myActor, posPairs, isAppend)
  if (myActor.freeInAreaIds and #myActor.freeInAreaIds > 0) then -- 如果自由活动区域已经存在，则销毁
    for i, v in ipairs(myActor.freeInAreaIds) do
      AreaHelper:destroyArea(v)
    end
  end
  local want = self:getFreeInAreaData(think)
  if (isAppend) then
    table.insert(myActor.wants, want)
  else
    myActor.wants = { want }
  end
  myActor.freeInAreaIds = self:getFreeInAreaIds(posPairs)
  return want
end

-- 获得区域ids，参数为二维数组{{posBeg, posEnd},{posBeg, posEnd}}
function BaseActorActionHelper:getFreeInAreaIds (posPairs)
  local areaids = {}
  for i, v in ipairs(posPairs) do
    table.insert(areaids, AreaHelper:createAreaRectByRange(v[1], v[2]))
  end
  return areaids
end

-- 获得区域中的一个位置
function BaseActorActionHelper:getFreeInAreaPos (freeInAreaIds)
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
function BaseActorActionHelper:updateActionState (myActor)
  if (myActor.wants) then
    local style = myActor.wants[1].style
    if (style == 'move' or style == 'patrol' or style == 'freeInArea' or style == 'doNothing' or style == 'sleep') then
      -- myActor:enableMove(true)
      myActor:closeAI()
    elseif (style == 'dontMove') then
      -- myActor:enableMove(false)
    end
  end
end
