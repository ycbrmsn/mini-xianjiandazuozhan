-- 区域工具类
AreaHelper = {
  movePosDim = { x = 0, y = 0, z = 0 }, -- 移动地点尺寸
  approachPosDim = { x = 1, y = 0, z = 1 }, -- 靠近地点尺寸
  nineCubicDim = { x = 1, y = 1, z = 1 }, -- 扩大1格
  freeTimeDim = { x = 8, y = 8, z = 8 }, -- 自由移动区域尺寸
  allDoorAreas = {}, -- 所有门的区域
  maxRandomTimes = 10, -- 查询空位置的最大循环次数
  showToastAreas = {} -- { areaid1 = { areaid2, name }, ... }
}

function AreaHelper:isAirArea (pos)
  return BlockHelper:isAirBlock(pos.x, pos.y, pos.z) and BlockHelper:isAirBlock(pos.x, pos.y + 1, pos.z)
end

-- 是否是水区域
function AreaHelper:isWaterArea (pos)
  return BlockHelper:isWater(pos.x, pos.y, pos.z) or BlockHelper:isWater(pos.x, pos.y + 1, pos.z)
end

function AreaHelper:removeToArea (myActor)
  if (myActor and myActor.wants) then
    local want = myActor.wants[1]
    if (want.toAreaId) then
      AreaHelper:destroyArea(want.toAreaId)
      want.toAreaId = nil
    end
  end
end

function AreaHelper:getRandomAirPositionInArea (areaid)
  local pos = AreaHelper:getRandomPos(areaid)
  local times = 1
  while (not(self:isAirArea(pos)) and times < self.maxRandomTimes) do
    pos = AreaHelper:getRandomPos(areaid)
    times = times + 1
  end
  return pos
end

-- 新增提示区域
function AreaHelper:addToastArea (areaid, info)
  self.showToastAreas[areaid] = info
end

-- 显示区域提示，如果需要生成怪物并生成怪物
function AreaHelper:showToastArea (objid, areaid)
  local player = PlayerHelper:getPlayer(objid)
  for k, v in pairs(self.showToastAreas) do
    if (k == areaid) then
      if (v[1] == -1 or (player.prevAreaId and player.prevAreaId == v[1])) then
        PlayerHelper:showToast(objid, v[2])
        if (#v == 3) then -- 生成怪物
          v[3]()
        end
      end
      player.prevAreaId = areaid
      return true
    elseif (v[1] == areaid) then
      player.prevAreaId = areaid
      return true
    end
  end
  return false
end

-- 创建移动点区域
function AreaHelper:createMovePosArea (pos)
  return self:createAreaRect(pos, self.movePosDim)
end

-- 创建靠近区域
function AreaHelper:createApproachPosArea (pos)
  return self:createAreaRect(pos, self.approachPosDim)
end

-- 创建扩大1格区域
function AreaHelper:createNineCubicArea (pos)
  return self:createAreaRect(pos, self.nineCubicDim)
end

-- 创建自由移动区域
function AreaHelper:createFreeTimeArea (pos)
  return self:createAreaRect(pos, self.freeTimeDim)
end

-- 创建初始化生物区域
function AreaHelper:createInitActorArea (pos)
  return self:createMovePosArea(pos)
end

-- 清空所有木围栏
function AreaHelper:clearAllWoodenFence (areaid)
  return self:clearAllBlock(areaid, BlockHelper.woodenFenceid)
end

-- 查询areaid内的所有生物
function AreaHelper:getAllCreaturesInAreaId (areaid)
  local posBeg, posEnd = self:getAreaRectRange(areaid)
  return self:getAllCreaturesInAreaRange(posBeg, posEnd)
end

-- 查询areaid内的所有玩家
function AreaHelper:getAllPlayersInAreaId (areaid)
  local posBeg, posEnd = self:getAreaRectRange(areaid)
  return self:getAllPlayersInAreaRange(posBeg, posEnd)
end

-- 查询areaid内的所有生物与玩家，返回生物id数组与玩家id数组
function AreaHelper:getAllCreaturesAndPlayersInAreaId (areaid)
  local posBeg, posEnd = self:getAreaRectRange(areaid)
  local objids1 = self:getAllCreaturesInAreaRange(posBeg, posEnd)
  local objids2 = self:getAllPlayersInAreaRange(posBeg, posEnd)
  return objids1, objids2
end

-- 根据位置数据生成位置对象
function AreaHelper:initPosByPosData (data, positions)
  for i, v in ipairs(data) do
    local pos = MyPosition:new(v[1], v[2], v[3])
    table.insert(positions, pos)
  end
end

-- 根据位置数据初始化区域
function AreaHelper:initAreaByPosData (data, areas)
  for i, v in ipairs(data) do
    local pos = MyPosition:new(v[1], v[2], v[3])
    local areaid = AreaHelper:getAreaByPos(pos)
    table.insert(areas, areaid)
  end
end

-- 是否是门区域，规定水平两格大小的区域都是门区域
function AreaHelper:isDoorArea (areaid)
  local posBeg, posEnd = AreaHelper:getAreaRectRange(areaid)
  if (posBeg) then -- 区域有效
    if (posBeg.y == posEnd.y and MathHelper:getDistance(posBeg, posEnd) == 1) then
      if (BlockHelper:isAirBlock(posBeg.x, posBeg.y, posBeg.z)) then
        return true, posEnd
      elseif (BlockHelper:isAirBlock(posEnd.x, posEnd.y, posEnd.z)) then
        return true, posBeg
      else
        return false
      end
    else
      return false
    end 
  else
    return nil
  end
  return false
end

-- 获得附近的一个随机位置
function AreaHelper:getRandomPosAround (pos, range)
  local x = pos.x + math.random() * range * 2 - range
  local y = pos.y + math.random() * range * 2 - range
  local z = pos.z + math.random() * range * 2 - range
  return MyPosition:new(x, y, z)
end

-- 获得自由移动位置
function AreaHelper:getFreeTimePos (pos)
  return AreaHelper:getRandomPosAround(pos, 10)
end

-- 获取特定位置附近的方块位置
function AreaHelper:getBlockPositionsAround (pos, dim, blockid)
  local positions = {}
  for i = math.floor(pos.x) - dim.x, math.floor(pos.x) + dim.x do
    for k = math.floor(pos.z) - dim.z, math.floor(pos.z) + dim.z do
      for j = math.floor(pos.y) + dim.y, math.floor(pos.y) - dim.y, -1 do -- 从上往下
        local id = BlockHelper:getBlockID(i, j, k)
        if (id and id == blockid) then
          table.insert(positions, MyPosition:new(i, j, k))
        end
      end
    end
  end
  return positions
end

-- 获得一个可以站人的位置
function AreaHelper:getEmptyPos (player)
  local pos
  for i = 3, 2, -1 do
    for j = 90, 360, 30 do
      pos = player:getDistancePosition(i, j)
      if (AreaHelper:isAirArea(pos) and not(BlockHelper:isWater(pos.x, pos.y - 1, pos.z))) then
        return pos
      end
    end
  end
  return pos
end

-- 封装原始接口

-- 根据中心位置创建矩形区域
function AreaHelper:createAreaRect (pos, dim)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:createAreaRect(pos, dim)
  end, '根据中心位置创建矩形区域', 'pos=', pos, ',dim=', dim)
end

-- 根据起始点创建矩形区域
function AreaHelper:createAreaRectByRange (posBeg, posEnd)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:createAreaRectByRange(posBeg, posEnd)
  end, '根据起始点创建矩形区域', 'posBeg=', posBeg, ',posEnd=', posEnd)
end

-- 销毁区域
function AreaHelper:destroyArea (areaid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Area:destroyArea(areaid)
  end, '销毁区域', 'areaid=', areaid)
end

-- 获取区域中的生物 该接口第二次调用会报错，不使用
-- function AreaHelper:getAreaCreatures (areaid)
--   return CommonHelper:callOneResultMethod(function (p)
--     return Area:getAreaCreatures(areaid)
--   end, '获取区域中的生物', 'areaid=', areaid)
-- end

-- 获取随机区域内的位置
function AreaHelper:getRandomPos (areaid)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:getRandomPos(areaid)
  end, '获取随机区域内的位置', 'areaid=', areaid)
end

-- 清空区域内的全部方块
function AreaHelper:clearAllBlock (areaid, blockid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Area:clearAllBlock(areaid, blockid)
  end, '清空区域内的全部方块', 'areaid=', areaid, ',blockid=', blockid)
end

-- 通过位置查找区域
function AreaHelper:getAreaByPos (pos)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:getAreaByPos(pos)
  end, '通过位置查找区域', 'pos=', pos)
end

-- 获取区域范围内全部生物
function AreaHelper:getAllCreaturesInAreaRange (posBeg, posEnd)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:getAllCreaturesInAreaRange(posBeg, posEnd)
  end, '获取区域范围内全部生物', 'posBeg=', posBeg, ',posEnd=', posEnd)
end

-- 获取区域范围内全部玩家
function AreaHelper:getAllPlayersInAreaRange (posBeg, posEnd)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:getAllPlayersInAreaRange(posBeg, posEnd)
  end, '获取区域范围内全部玩家', 'posBeg=', posBeg, ',posEnd=', posEnd)
end

-- 获取区域范围，返回区域起始点位置
function AreaHelper:getAreaRectRange (areaid)
  return CommonHelper:callTwoResultMethod(function (p)
    return Area:getAreaRectRange(areaid)
  end, '获取区域范围', 'areaid=', areaid)
end

-- 位置是否在区域内
function AreaHelper:posInArea (pos, areaid)
  return Area:posInArea(pos, areaid) == ErrorCode.OK
end

-- 替换方块类型为新的方块类型
function AreaHelper:replaceAreaBlock (areaid, srcblockid, destblockid, face)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Area:replaceAreaBlock(areaid, srcblockid, destblockid, face)
  end, '替换方块类型为新的方块类型', 'areaid=', areaid, ',srcblockid=', srcblockid,
    ',destblockid=', destblockid, ',face=', face)
end

-- 检测obj是否在区域内
function AreaHelper:objInArea (areaid, objid)
  return Area:objInArea(areaid, objid) == ErrorCode.OK
end

-- 获取区域中间点 pos:table中心位置 报错？
function AreaHelper:getAreaCenter (areaid)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:getAreaCenter(areaid)
  end, '获取区域中间点', 'areaid=', areaid)
end

-- 用方块填充区域
function AreaHelper:fillBlock (areaid, blockid, face)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Area:fillBlock(areaid, blockid, face)
  end, '用方块填充区域', 'areaid=', areaid, ',blockid=', blockid, ',face=', face)
end

-- 检测区域内是否有某个方块
function AreaHelper:blockInArea (areaid, blockid)
  return Area:blockInArea(areaid, blockid) == ErrorCode.OK
end