-- 数学工具类
MathHelper = {}

-- 水平旋转角度计算，可以忽略y方向，直接与正南方向向量取夹角即可
function MathHelper:getActorFaceYaw (myVector3)
  local tempAngle = self:getTwoVector2Angle(0, -1, myVector3.x, myVector3.z)
  if (myVector3.x > 0) then
    tempAngle = -tempAngle
  end
  return tempAngle
end

-- 同上，此处计算与正北方向向量夹角（仅使用第一人称视角）
function MathHelper:getPlayerFaceYaw (myVector3)
  local tempAngle = self:getTwoVector2Angle(0, 1, myVector3.x, myVector3.z)
  if (myVector3.x < 0) then
    tempAngle = -tempAngle
  end
  return tempAngle
end

--[[ 
  竖直旋转角度计算，使水平方向上的两个分量对应相同，就可以保证两向量在同一个竖直平面上
  然后取到的夹角就是竖直方向上的夹角
]]--
function MathHelper:getActorFacePitch (myVector3)
  local tempAngle = self:getTwoVector3Angle(myVector3.x, 0, myVector3.z, myVector3:get())
  if (myVector3.y > 0) then
    tempAngle = - tempAngle
  end
  return tempAngle
end

-- x0 * x1 + y0 * y1 = |x0y0| * |x1y1| * cosAngle
function MathHelper:getTwoVector2Angle (x0, y0, x1, y1)
  local cosAngle = (x0 * x1 + y0 * y1) / self:getVector2Length(x0, y0) / self:getVector2Length(x1, y1)
  return math.deg(math.acos(cosAngle))
end

function MathHelper:getTwoVector3Angle (x0, y0, z0, x1, y1, z1)
  local cosAngle = (x0 * x1 + y0 * y1 + z0 * z1) / self:getVector3Length(x0, y0, z0) / self:getVector3Length(x1, y1, z1)
  return math.deg(math.acos(cosAngle))
end

-- 二维向量长度
function MathHelper:getVector2Length (x, y)
  return math.sqrt(math.pow(x, 2) + math.pow(y, 2))
end

-- 三维向量长度
function MathHelper:getVector3Length (x, y, z)
  return math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
end

-- 距离位置多远的另一个位置
function MathHelper:getDistancePosition (pos, angle, distance)
  local x = pos.x - distance * math.sin(math.rad(angle))
  local y = pos.y
  local z = pos.z - distance * math.cos(math.rad(angle))
  return MyPosition:new(x, y, z)
end

-- 距离位置多远的另一排位置 位置、角度、直向距离、横向距离
function MathHelper:getDistancePositions (pos, angle, distance1, distance2, num)
  distance2 = distance2 or 1
  num = num or 1
  local positions = { MathHelper:getDistancePosition(pos, angle, distance1) }
  if (num > 1) then
    for i = 1, num - 1 do
      local tempDistance = distance2 * math.ceil(i / 2)
      local tempAngle
      if (i % 2 == 0) then
        tempAngle = angle + 90
      else
        tempAngle = angle - 90
      end
      table.insert(positions, MathHelper:getDistancePosition(positions[1], tempAngle, tempDistance))
    end
  end
  return positions
end

-- 距离位置多远的另一排位置，位置整齐 位置、角度、距离、数量
function MathHelper:getRegularDistancePositions (pos, angle, distance, num)
  num = num or 1
  local p = MathHelper:getDistancePosition(pos, angle, distance)
  local positions = { p }
  if (num > 1) then
    local tempAngle = angle % 360
    local index = 1
    for i = 22.5, 315, 45 do
      if (tempAngle >= i and tempAngle < i + 45) then
        break
      else
        index = index + 1
      end
    end
    if (index == 1) then -- 西南
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if (i % 2 == 1) then
          table.insert(positions, MyPosition:new(p.x + gap, p.y, p.z - gap))
        else
          table.insert(positions, MyPosition:new(p.x - gap, p.y, p.z + gap))
        end
      end
    elseif (index == 2) then -- 西
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if (i % 2 == 1) then
          table.insert(positions, MyPosition:new(p.x, p.y, p.z - gap))
        else
          table.insert(positions, MyPosition:new(p.x, p.y, p.z + gap))
        end
      end
    elseif (index == 3) then -- 西北
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if (i % 2 == 1) then
          table.insert(positions, MyPosition:new(p.x - gap, p.y, p.z - gap))
        else
          table.insert(positions, MyPosition:new(p.x + gap, p.y, p.z + gap))
        end
      end
    elseif (index == 4) then -- 北
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if (i % 2 == 1) then
          table.insert(positions, MyPosition:new(p.x - gap, p.y, p.z))
        else
          table.insert(positions, MyPosition:new(p.x + gap, p.y, p.z))
        end
      end
    elseif (index == 5) then -- 东北
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if (i % 2 == 1) then
          table.insert(positions, MyPosition:new(p.x - gap, p.y, p.z + gap))
        else
          table.insert(positions, MyPosition:new(p.x + gap, p.y, p.z - gap))
        end
      end
    elseif (index == 6) then -- 东
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if (i % 2 == 1) then
          table.insert(positions, MyPosition:new(p.x, p.y, p.z + gap))
        else
          table.insert(positions, MyPosition:new(p.x, p.y, p.z - gap))
        end
      end
    elseif (index == 7) then -- 东南
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if (i % 2 == 1) then
          table.insert(positions, MyPosition:new(p.x + gap, p.y, p.z + gap))
        else
          table.insert(positions, MyPosition:new(p.x - gap, p.y, p.z - gap))
        end
      end
    elseif (index == 8) then -- 南
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if (i % 2 == 1) then
          table.insert(positions, MyPosition:new(p.x + gap, p.y, p.z))
        else
          table.insert(positions, MyPosition:new(p.x - gap, p.y, p.z))
        end
      end
    end
  end
  return positions
end

-- 获得一个方向速度，用于击退效果
function MathHelper:getSpeedVector3 (srcPos, dstPos, speed)
  local vector3 = MyVector3:new(srcPos, dstPos)
  local ratio = speed / vector3:getLength()
  return vector3:mul(ratio)
end

-- 获得两点连线上距离另一个点（第二个点）多远的位置，distance为正则位置可能在两点之间
function MathHelper:getPos2PosInLineDistancePosition (pos1, pos2, distance)
  local myVector3 = MyVector3:new(pos2, pos1)
  local angle = MathHelper:getActorFaceYaw(myVector3)
  return MathHelper:getDistancePosition(pos2, angle, distance)
end

-- 两点之间的距离
function MathHelper:getDistance (pos1, pos2)
  if (type(pos1) == 'number') then
    pos1 = ActorHelper:getMyPosition(pos1)
  end
  if (type(pos2) == 'number') then
    pos2 = ActorHelper:getMyPosition(pos2)
  end
  return MathHelper:getVector3Length(pos1.x - pos2.x, pos1.y - pos2.y, pos1.z - pos2.z)
end

-- 两点水平方向上的距离
function MathHelper:getDistanceV2 (pos1, pos2)
  if (type(pos1) == 'number') then
    pos1 = ActorHelper:getMyPosition(pos1)
  end
  if (type(pos2) == 'number') then
    pos2 = ActorHelper:getMyPosition(pos2)
  end
  return MathHelper:getVector2Length(pos1.x - pos2.x, pos1.z - pos2.z)
end

-- 矩形区域范围posBeg, posEnd
function MathHelper:getRectRange (pos, dim)
  return MyPosition:new(pos.x - dim.x, pos.y - dim.y, pos.z - dim.z), 
    MyPosition:new(pos.x + dim.x, pos.y + dim.y, pos.z + dim.z)
end

-- 一个生物处于玩家的哪个角度，正前方为0，左负右正，正后方为180
function MathHelper:getRelativePlayerAngle (objid, toobjid)
  local player = PlayerHelper:getPlayer(objid)
  local playerPos = player:getMyPosition()
  local aimPos = MyPosition:new(PlayerHelper:getAimPos(objid))
  local leftPos = player:getDistancePosition(1, -90) -- 左边点
  local pos = ActorHelper:getMyPosition(toobjid)
  local vx, vz = pos.x - playerPos.x, pos.z - playerPos.z
  local angle1 = self:getTwoVector2Angle(aimPos.x - playerPos.x, aimPos.z - playerPos.z, vx, vz) -- 与前方向量夹角
  local angle2 = self:getTwoVector2Angle(leftPos.x - playerPos.x, leftPos.z - playerPos.z, vx, vz) -- 与左方向量夹角
  local angle
  if (angle1 <= 90 and angle2 < 90) then -- 左前
    angle = -angle1
  elseif (angle1 <= 90 and angle2 >= 90) then -- 右前
    angle = angle1
  elseif (angle1 > 90 and angle2 < 90) then -- 左后
    angle = -angle1
  else -- 右后
    angle = angle1
  end
  return math.floor(angle)
end

-- 得到一个固定大小随机方向的向量
function MathHelper:getRandomSpeed (speed)
  local x, y, z = math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)
  local len = MathHelper:getVector3Length(x, y, z)
  local ratio = speed / len
  return MyVector3:new(x * ratio, y * ratio, z * ratio)
end