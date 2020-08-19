-- 方块工具类
BlockHelper = {
  candles = {}, -- 保存所有蜡烛台
  repeatTime = 3, -- 失败重复调用次数
  woodenFenceid = 534, -- 木围栏id
  switchid = 724, -- 开关id
  doorid = 812, -- 果木门id 白杨木门856
  bedid = 828, -- 舒适的床
  airBlockid = 1081 -- 空气墙-不挡物理
}

-- 门是否开着，参数为x, y, z或者table
function BlockHelper:isDoorOpen (x, y, z)
  local data = BlockHelper:getBlockData(x, y, z)
  return data > 4 -- 观察数据发现关上的门的数据为0, 1, 2, 3
end

-- 开门，参数为x, y, z或者table
function BlockHelper:openDoor (x, y, z)
  if (BlockHelper:isDoorOpen(x, y, z)) then -- 门开着
    -- do nothing
  else -- 门没有打开
    local blockid = BlockHelper:getBlockID(x, y, z)
    local data1 = BlockHelper:getBlockData(x, y, z)
    local data2 = BlockHelper:getBlockData(x, y + 1, z)
    BlockHelper:setBlockAll(x, y, z, blockid, data1 + 8)
    BlockHelper:setBlockAll(x, y + 1, z, blockid, data2 + 8)
    WorldHelper:playOpenDoorSoundOnPos(MyPosition:new(x, y, z))
  end
  return true
end

-- 关门，参数为x, y, z或者table
function BlockHelper:closeDoor (x, y, z)
  if (BlockHelper:isDoorOpen(x, y, z)) then -- 门开着
    local blockid = BlockHelper:getBlockID(x, y, z)
    local data1 = BlockHelper:getBlockData(x, y, z)
    local data2 = BlockHelper:getBlockData(x, y + 1, z)
    BlockHelper:setBlockAll(x, y, z, blockid, data1 - 8)
    BlockHelper:setBlockAll(x, y + 1, z, blockid, data2 - 8)
    WorldHelper:playCloseDoorSoundOnPos(MyPosition:new(x, y, z))
  else -- 门没有打开
    -- do nothing
  end
  return true
end

-- 开关门，参数为x, y, z或者table
function BlockHelper:toggleDoor (x, y, z)
  if (BlockHelper:isDoorOpen(x, y, z)) then
    BlockHelper:closeDoor(x, y, z)
  else
    BlockHelper:openDoor(x, y, z)
  end
end

-- 指定位置处的蜡烛台加入集合，参数为（myPosition, blockid）或者 如下
function BlockHelper:addCandle (x, y, z, blockid)
  local myPosition
  if (type(x) == 'number') then
    myPosition = MyPosition:new(x, y, z)
  else
    myPosition = x
    blockid = y
  end
  -- local myPos = myPosition:floor()
  local candle = MyCandle:new(myPosition, blockid)
  self.candles[myPosition:toString()] = candle
  return candle
end

-- 查询指定位置处的蜡烛台
function BlockHelper:getCandle (myPosition)
  -- local myPos = myPosition:floor()
  return self.candles[myPosition:toString()]
end

-- 从集合中删除指定位置的蜡烛台
function BlockHelper:removeCandle (myPosition)
  -- local myPos = myPosition:floor()
  self.candles[myPosition:toString()] = nil
end

-- 检查指定位置处是否是蜡烛台
function BlockHelper:checkIsCandle (myPosition)
  local isCandle, blockid = MyCandle:isCandle(myPosition)
  if (isCandle) then
    local candle = BlockHelper:getCandle(myPosition)
    if (not(candle)) then
      candle = BlockHelper:addCandle(myPosition, blockid)
    end
    return true, candle
  else
    return false
  end
end

-- 检查被破坏/移除的方块是否是蜡烛台
function BlockHelper:checkIfRemoveCandle (myPosition, blockid)
  if (MyCandle:isBlockCandle(blockid)) then
    BlockHelper:removeCandle(myPosition)
  end
end

function BlockHelper:getWhoseCandle (myPosition)
  local index = 1
  -- myPosition = myPosition:floor()
  for k, v in pairs(ActorHelper:getAllActors()) do
    if (v.candlePositions and #v.candlePositions > 0) then
      for kk, vv in pairs(v.candlePositions) do
        index = index + 1
        if (vv:equals(myPosition)) then
          return v
        end
      end
    end
  end
  return nil
end

function BlockHelper:handleCandle (myPosition, isLit)
  if (not(MyPosition:isPosition(myPosition))) then
    myPosition = MyPosition:new(myPosition)
  end
  local isCandle, candle = BlockHelper:checkIsCandle(myPosition)
  if (isCandle) then
    if (type(isLit) == 'nil') then
      candle:toggle()
    elseif (isLit) then
      candle:light()
    else
      candle:putOut()
    end
  end
  return candle
end

function BlockHelper:checkCandle (objid, blockid, pos)
  if (MyCandle:isCandle(blockid)) then
    -- 处理蜡烛台
    local candle = BlockHelper:handleCandle(pos)
    if (candle) then
      local myActor = BlockHelper:getWhoseCandle(pos)
      if (myActor) then
        local player = PlayerHelper:getPlayer(objid)
        myActor:candleEvent(player, candle)
      end
    end
    return true
  else
    return false
  end
end

-- 是否是空气方块
function BlockHelper:isAirBlockOffset (pos, dx, dy, dz)
  dx, dy, dz = dx or 0, dy or 0, dz or 0
  return BlockHelper:isAirBlock(pos.x + dx, pos.y + dy, pos.z + dz)
end

-- 是否是不可见方块
function BlockHelper:isInvisibleBlockOffset (pos, dx, dy, dz)
  dx, dy, dz = dx or 0, dy or 0, dz or 0
  local blockid = BlockHelper:getBlockID(pos.x + dx, pos.y + dy, pos.z + dz)
  return (blockid == BLOCKID.AIR) or (blockid == self.airBlockid)
end

-- 事件

-- 方块被破坏
function BlockHelper:blockDestroyBy (objid, blockid, x, y, z)
  -- body
end

-- 完成方块挖掘
function BlockHelper:blockDigEnd (objid, blockid, x, y, z)
  -- body
end

-- 方块被放置
function BlockHelper:blockPlaceBy (objid, blockid, x, y, z)
  -- body
end

-- 方块被移除
function BlockHelper:blockRemove (blockid, x, y, z)
  -- body
end

-- 方块被触发
function BlockHelper:blockTrigger (objid, blockid, x, y, z)
  -- body
end

-- 封装原始接口

-- 获取方块数据
function BlockHelper:getBlockData (x, y, z)
  local onceFailMessage = '获取方块数据失败一次'
  local finillyFailMessage = StringHelper:concat('获取方块数据失败，参数：x=', x, ', y=', y, ', z=', z)
  return CommonHelper:callOneResultMethod(function (p)
    return Block:getBlockData(x, y, z)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置方块数据
function BlockHelper:setBlockAll (x, y, z, blockid, data)
  local onceFailMessage = '设置方块数据失败一次'
  local finillyFailMessage = StringHelper:concat('设置方块数据失败，参数：x=', x, ', y=', y, ', z=', z, ', blockid=', blockid, ', data=', data)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Block:setBlockAll(x, y, z, blockid, data)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置blockalldata更新当前位置方块
function BlockHelper:setBlockAllForNotify (x, y, z, blockid)
  local onceFailMessage = '设置blockalldata更新当前位置方块失败一次'
  local finillyFailMessage = StringHelper:concat('设置blockalldata更新当前位置方块失败，参数：x=', x, ', y=', y, ', z=', z, ', blockid=', blockid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Block:setBlockAllForNotify(x, y, z, blockid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取block对应id
function BlockHelper:getBlockID (x, y, z)
  local onceFailMessage = '获取block对应id失败一次'
  local finillyFailMessage = StringHelper:concat('获取block对应id失败，参数：x=', x, ', y=', y, ', z=', z)
  return CommonHelper:callOneResultMethod(function (p)
    return Block:getBlockID(x, y, z)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 放置方块
function BlockHelper:placeBlock (blockid, x, y, z, face)
  local onceFailMessage = '放置方块失败一次'
  local finillyFailMessage = StringHelper:concat('放置方块失败，参数：blockid=', blockid, ', x=', x, ', y=', y, ', z=', z, ', face=', face)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Block:placeBlock(blockid, x, y, z, face)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 替换方块
function BlockHelper:replaceBlock (blockid, x, y, z, face)
  local onceFailMessage = '替换方块失败一次'
  local finillyFailMessage = StringHelper:concat('替换方块失败，参数：blockid=', blockid, ', x=', x, ', y=', y, ', z=', z, ', face=', face)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Block:replaceBlock(blockid, x, y, z, face)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 是否是气体方块
function BlockHelper:isAirBlock (x, y, z)
  return Block:isAirBlock(x, y, z) == ErrorCode.OK
end

-- 获取功能方块的开关状态
function BlockHelper:getBlockSwitchStatus (pos)
  local onceFailMessage = '获取功能方块的开关状态失败一次'
  local finillyFailMessage = StringHelper:concat('获取功能方块的开关状态失败，参数：pos=', pos)
  return CommonHelper:callOneResultMethod(function (p)
    return Block:getBlockSwitchStatus(pos)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置方块设置属性状态
function BlockHelper:setBlockSettingAttState (blockid, attrtype, switch)
  local onceFailMessage = '设置方块设置属性状态失败一次'
  local finillyFailMessage = StringHelper:concat('设置方块设置属性状态失败，参数：blockid=',
    blockid, ', attrtype=', attrtype, ', switch=', switch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Block:setBlockSettingAttState(blockid, attrtype, switch)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 摧毁方块 dropitem:掉落道具(默认false,不掉落)
function BlockHelper:destroyBlock (x, y, z, dropitem)
  local onceFailMessage = '摧毁方块失败一次'
  local finillyFailMessage = StringHelper:concat('摧毁方块失败，参数：x=', x, ', y=', y,
    ', z=', z, ',dropitem=', dropitem)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Block:destroyBlock(x, y, z, dropitem)
  end, nil, onceFailMessage, finillyFailMessage)
end