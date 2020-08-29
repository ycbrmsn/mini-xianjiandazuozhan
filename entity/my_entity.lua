-- 蜡烛台 -- 床 -- 位置类 -- 三维向量
MyCandle = {
  BLOCK_ID = {
    CANDLE = 931, -- 熄灭的蜡烛台
    LIT_CANDLE = 932 -- 点燃的蜡烛台
  },
  pos = nil,
  isLit = false
}

function MyCandle:new (myPosition, blockid)
  blockid = blockid or self.BLOCK_ID.CANDLE
  local o = {
    pos = myPosition,
    isLit = blockid == self.BLOCK_ID.LIT_CANDLE
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 位置上是否是蜡烛台
function MyCandle:isCandle (pos)
  local blockid
  if (type(pos) == 'table') then
    blockid = BlockHelper:getBlockID(pos.x, pos.y, pos.z)
  else
    blockid = pos
  end
  return self:isBlockCandle(blockid)
end

-- 方块是否是蜡烛台
function MyCandle:isBlockCandle (blockid)
  return blockid == self.BLOCK_ID.CANDLE or blockid == self.BLOCK_ID.LIT_CANDLE, blockid
end

-- 是否是同一个
function MyCandle:isSameOne (myPosition)
  if (type(myPosition) == 'table') then
    return myPosition.x == self.pos.x and myPosition.y == self.pos.y and myPosition.z == self.pos.z
  else
    return false
  end
end

-- 点燃
function MyCandle:light ()
  self.isLit = true
  return BlockHelper:setBlockAllForNotify(self.pos.x, self.pos.y, self.pos.z, self.BLOCK_ID.LIT_CANDLE)
end

-- 熄灭
function MyCandle:putOut ()
  self.isLit = false
  return BlockHelper:setBlockAllForNotify(self.pos.x, self.pos.y, self.pos.z, self.BLOCK_ID.CANDLE)
end

-- 切换
function MyCandle:toggle ()
  if (self.isLit) then
    self:putOut()
  else
    self:light()
  end
end

-- 床
MyBed = {
  BLOCK_ID = 828 -- 舒适的床
}

function MyBed:isBed (pos)
  local blockid
  if (type(pos) == 'table') then
    blockid = BlockHelper:getBlockID(pos.x, pos.y, pos.z)
  else
    blockid = pos
  end
  return blockid and blockid == self.BLOCK_ID
end

-- 位置类
MyPosition = {
  TYPE = 'POS'
}

function MyPosition:new (x, y, z)
  if (not(x)) then
    return nil
  end
  local o
  if (type(x) == 'table') then
    o = { x = x.x, y = x.y, z = x.z }
  else
    o = { x = x, y = y, z = z }
  end
  setmetatable(o, self)
  self.__index = self
  return o
end

function MyPosition:floor ()
  return MyPosition:new(math.floor(self.x), math.floor(self.y), math.floor(self.z))
end

function MyPosition:get ()
  return self.x, self.y, self.z
end

function MyPosition:isPosition (pos)
  return pos and pos.TYPE and pos.TYPE == self.TYPE
end

function MyPosition:equals (myPosition)
  if (type(myPosition) ~= 'table') then
    return false
  end
  return myPosition.x == self.x and myPosition.y == self.y and myPosition.z == self.z
end

-- 从右起每四位代表一个坐标值（负数有问题）
function MyPosition:toNumber ()
  return self.x * 100000000 + self.y * 10000 + self.z
end

function MyPosition:toString ()
  return StringHelper:concat('{x=', self.x, ',y=', self.y, ',z=', self.z, '}')
end

function MyPosition:toSimpleString ()
  return StringHelper:concat(self.x, ',', self.y, ',', self.z)
end

-- 三维向量
MyVector3 = {}

-- 参数：六个number/三个number/两个table/一个table
function MyVector3:new (x0, y0, z0, x1, y1, z1)
  local o
  if (x1) then
    o = { x = x1 - x0, y = y1 - y0, z = z1 - z0 }
  elseif (z0) then
    o = { x = x0, y = y0, z = z0 }
  elseif (y0) then
    o = { x = y0.x - x0.x, y = y0.y - x0.y, z = y0.z - x0.z }
  else
    o = { x = x0.x, y = x0.y, z = x0. z }
  end
  setmetatable(o, self)
  self.__index = self
  return o
end

function MyVector3:mul (s)
  return self:new(0, 0, 0, self.x * s, self.y * s, self.z * s)
end

function MyVector3:getLength ()
  return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2) + math.pow(self.z, 2))
end

function MyVector3:get ()
  return self.x, self.y, self.z
end

function MyVector3:isZero ()
  return self.x == 0 and self.y == 0 and self.z == 0
end

-- 剧情类
MyStory = {
  title = nil,
  name = nil,
  desc = nil,
  tips = nil
}

function MyStory:new ()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function MyStory:checkData (data)
  if (not(data)) then
    LogHelper:debug('剧情数据为空')
  elseif (not(data.title)) then
    LogHelper:debug('剧情标题为空')
  elseif (not(data.name)) then
    LogHelper:debug(data.title, '剧情名称为空')
  elseif (not(data.desc)) then
    LogHelper:debug(data.title, '剧情描述为空')
  elseif (not(data.tips)) then
    LogHelper:debug(data.title, '剧情提示为空')
  end
end
