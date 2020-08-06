-- 方块工具类
BlockHelper = {
  candles = {}, -- 保存所有蜡烛台
  repeatTime = 3, -- 失败重复调用次数
  woodenFenceid = 534, -- 木围栏id
  switchid = 724, -- 开关id
  doorid = 812, -- 果木门id
  bedid = 828 -- 舒适的床
}

-- 门是否开着，参数为x, y, z或者table，最后一个doorid，默认是果木门
function BlockHelper:isDoorOpen (x, y, z, doorid)
  local doorPos, doorid = BlockHelper:getDoorData(x, y, z, doorid)
  local data = BlockHelper:getBlockData(doorPos.x, doorPos.y, doorPos.z)
  return data > 4 -- 观察数据发现关上的门的数据为0, 1, 2, 3
end

-- 开门，参数为x, y, z或者table，最后一个doorid，默认是果木门
function BlockHelper:openDoor (x, y, z, doorid)
  if (BlockHelper:isDoorOpen(x, y, z, doorid)) then -- 门开着
    -- do nothing
  else -- 门没有打开
    local doorPos, doorid = BlockHelper:getDoorData(x, y, z, doorid)
    local data1 = BlockHelper:getBlockData(doorPos.x, doorPos.y, doorPos.z)
    local data2 = BlockHelper:getBlockData(doorPos.x, doorPos.y + 1, doorPos.z)
    BlockHelper:setBlockAll(doorPos.x, doorPos.y, doorPos.z, doorid, data1 + 8)
    BlockHelper:setBlockAll(doorPos.x, doorPos.y + 1, doorPos.z, doorid, data2 + 8)
    WorldHelper:playOpenDoorSoundOnPos(doorPos)
  end
  return true
end

-- 关门，参数为x, y, z或者table，最后一个doorid，默认是果木门
function BlockHelper:closeDoor (x, y, z, doorid)
  if (BlockHelper:isDoorOpen(x, y, z, doorid)) then -- 门开着
    local doorPos, doorid = BlockHelper:getDoorData(x, y, z, doorid)
    local data1 = BlockHelper:getBlockData(doorPos.x, doorPos.y, doorPos.z)
    local data2 = BlockHelper:getBlockData(doorPos.x, doorPos.y + 1, doorPos.z)
    BlockHelper:setBlockAll(doorPos.x, doorPos.y, doorPos.z, doorid, data1 - 8)
    BlockHelper:setBlockAll(doorPos.x, doorPos.y + 1, doorPos.z, doorid, data2 - 8)
    WorldHelper:playCloseDoorSoundOnPos(doorPos)
  else -- 门没有打开
    -- do nothing
  end
  return true
end

-- 开关门，参数为x, y, z或者table，最后一个doorid，默认是果木门
function BlockHelper:toggleDoor (x, y, z, doorid)
  if (BlockHelper:isDoorOpen(x, y, z, doorid)) then
    BlockHelper:closeDoor(x, y, z, doorid)
  else
    BlockHelper:openDoor(x, y, z, doorid)
  end
end

-- 封装处理数据函数
function BlockHelper:getDoorData (x, y, z, doorid)
  local doorPos
  if (type(x) == 'number') then
    doorPos = { x = x, y = y, z = z }
    doorid = doorid or self.doorid
  elseif (type(x) == 'table') then
    doorPos = x
    doorid = y or self.doorid
  else -- 其他数据类型
    LogHelper:debug('openDoor数据类型错误')
    return false
  end
  return doorPos, doorid
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

-- 事件

-- 完成方块挖掘
function BlockHelper:blockDigEnd (objid, blockid, x, y, z)
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
  local onceFailMessage = '设置方块设置属性状态一次'
  local finillyFailMessage = StringHelper:concat('设置方块设置属性状态失败，参数：blockid=', blockid, ', attrtype=', attrtype, ', switch=', switch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Block:setBlockSettingAttState(blockid, attrtype, switch)
  end, nil, onceFailMessage, finillyFailMessage)
end