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

-- 封装原始接口

-- 根据中心位置创建矩形区域
function AreaHelper:createAreaRect (pos, dim)
  local onceFailMessage = '创建区域失败一次'
  local finillyFailMessage = StringHelper:concat('创建矩形区域失败，参数：pos=', pos, ', dim=', dim)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:createAreaRect(pos, dim)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 根据起始点创建矩形区域
function AreaHelper:createAreaRectByRange (posBeg, posEnd)
  local onceFailMessage = '创建矩形区域失败一次'
  local finillyFailMessage = StringHelper:concat('创建矩形区域失败，参数：posBeg=', 
    posBeg, ', posEnd=', posEnd)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:createAreaRectByRange(posBeg, posEnd)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 销毁区域
function AreaHelper:destroyArea (areaid)
  local onceFailMessage = '销毁区域失败一次'
  local finillyFailMessage = StringHelper:concat('销毁区域失败，参数：areaid=', areaid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Area:destroyArea(areaid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取区域中的生物 该接口第二次调用会报错，不使用
-- function AreaHelper:getAreaCreatures (areaid)
--   local onceFailMessage = '获取区域中的生物失败一次'
--   local finillyFailMessage = StringHelper:concat('获取区域中的生物失败，参数：areaid=', areaid)
--   return CommonHelper:callOneResultMethod(function (p)
--     return Area:getAreaCreatures(areaid)
--   end, nil, onceFailMessage, finillyFailMessage)
-- end

-- 获取随机区域内的位置
function AreaHelper:getRandomPos (areaid)
  local onceFailMessage = '获取随机区域内的位置失败一次'
  local finillyFailMessage = StringHelper:concat('获取随机区域内的位置失败，参数：areaid=', areaid)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:getRandomPos(areaid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 清空区域内的全部方块
function AreaHelper:clearAllBlock (areaid, blockid)
  local onceFailMessage = '清空区域内的全部方块失败一次'
  local finillyFailMessage = StringHelper:concat('清空区域内的全部方块失败，参数：areaid=', 
    areaid, '，blockid=', blockid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Area:clearAllBlock(areaid, blockid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 通过位置查找区域
function AreaHelper:getAreaByPos (pos)
  local onceFailMessage = '通过位置查找区域失败一次'
  local finillyFailMessage = StringHelper:concat('通过位置查找区域失败，参数：pos=', pos)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:getAreaByPos(pos)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取区域范围内全部生物
function AreaHelper:getAllCreaturesInAreaRange (posBeg, posEnd)
  local onceFailMessage = '获取区域范围内全部生物失败一次'
  local finillyFailMessage = StringHelper:concat('获取区域范围内全部生物失败，参数：posBeg=',
    posBeg, ', posEnd=', posEnd)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:getAllCreaturesInAreaRange(posBeg, posEnd)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取区域范围内全部玩家
function AreaHelper:getAllPlayersInAreaRange (posBeg, posEnd)
  local onceFailMessage = '获取区域范围内全部玩家失败一次'
  local finillyFailMessage = StringHelper:concat('获取区域范围内全部玩家失败，参数：posBeg=',
    posBeg, ', posEnd=', posEnd)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:getAllPlayersInAreaRange(posBeg, posEnd)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取区域范围
function AreaHelper:getAreaRectRange (areaid)
  local onceFailMessage = '获取区域范围失败一次'
  local finillyFailMessage = StringHelper:concat('获取区域范围失败，参数：areaid=', areaid)
  return CommonHelper:callTwoResultMethod(function (p)
    return Area:getAreaRectRange(areaid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 位置是否在区域内
function AreaHelper:posInArea (pos, areaid)
  return Area:posInArea(pos, areaid) == ErrorCode.OK
end

-- 替换方块类型为新的方块类型
function AreaHelper:replaceAreaBlock (areaid, srcblockid, destblockid, face)
  local onceFailMessage = '替换方块类型为新的方块类型失败一次'
  local finillyFailMessage = StringHelper:concat('替换方块类型为新的方块类型失败，参数：areaid=', 
    areaid, ',srcblockid=', srcblockid, ',destblockid=', destblockid, ',face=', face)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Area:replaceAreaBlock(areaid, srcblockid, destblockid, face)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 检测obj是否在区域内
function AreaHelper:objInArea (areaid, objid)
  return Area:objInArea(areaid, objid) == ErrorCode.OK
end

-- 获取区域中间点 pos:table中心位置 报错？
function AreaHelper:getAreaCenter (areaid)
  local onceFailMessage = '获取区域中间点失败一次'
  local finillyFailMessage = StringHelper:concat('获取区域中间点失败，参数：areaid=', areaid)
  return CommonHelper:callOneResultMethod(function (p)
    return Area:getAreaCenter(areaid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 用方块填充区域
function AreaHelper:fillBlock (areaid, blockid, face)
  local onceFailMessage = '用方块填充区域失败一次'
  local finillyFailMessage = StringHelper:concat('用方块填充区域失败，参数：areaid=', 
    areaid, ',blockid=', blockid, ',face=', face)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Area:fillBlock(areaid, blockid, face)
  end, nil, onceFailMessage, finillyFailMessage)
end