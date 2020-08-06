-- 数学工具类
MathHelper = {}

function MathHelper:getActorFaceYaw (myVector3)
  local tempAngle = self:getTwoVector2Angle(0, -1, myVector3.x, myVector3.z)
  if (myVector3.x > 0) then
    tempAngle = -tempAngle
  end
  return tempAngle
end

function MathHelper:getPlayerFaceYaw (myVector3)
  local tempAngle = self:getTwoVector2Angle(0, 1, myVector3.x, myVector3.z)
  if (myVector3.x < 0) then
    tempAngle = -tempAngle
  end
  return tempAngle
end

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
function MathHelper:getDistancePosition (myPosition, angle, distance)
  local x = myPosition.x - distance * math.sin(math.rad(angle))
  local y = myPosition.y
  local z = myPosition.z - distance * math.cos(math.rad(angle))
  return MyPosition:new(x, y, z)
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
  local angle = self:getActorFaceYaw(myVector3)
  return self:getDistancePosition(pos2, angle, distance)
end

-- 两点之间的距离
function MathHelper:getDistance (pos1, pos2)
  if (type(pos1) == 'number') then
    pos1 = ActorHelper:getMyPosition(pos1)
  end
  if (type(pos2) == 'number') then
    pos2 = ActorHelper:getMyPosition(pos2)
  end
  return self:getVector3Length(pos1.x - pos2.x, pos1.y - pos2.y, pos1.z - pos2.z)
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