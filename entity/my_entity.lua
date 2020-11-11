-- 常用类

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

function MyPosition:equals (pos)
  if (type(pos) ~= 'table') then
    return false
  end
  return pos.x == self.x and pos.y == self.y and pos.z == self.z
end

function MyPosition:equalBlockPos (pos)
  if (type(pos) ~= 'table') then
    return false
  end
  local x, y, z = math.floor(self.x) + 0.5, math.floor(self.y) + 0.5, math.floor(self.z) + 0.5
  return pos.x == x and pos.y == y and pos.z == z
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

-- 等待时间类，用于剧情对话中
WaitSeconds = {}

function WaitSeconds:new (time)
  time = time or 1
  local o = { time = time }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 增加
function WaitSeconds:add (seconds)
  self.time = self.time + seconds
end

-- 获得当前值
function WaitSeconds:get ()
  return self.time
end

-- 获得当前值后增加
function WaitSeconds:use (seconds)
  seconds = seconds or 2
  local time = self:get()
  self:add(seconds)
  return time
end

-- 会话信息
TalkInfo = {}

--[[
  id(唯一标识)
  ants(前置条件)
  progress(进度{ num -> sessions }，从1开始，0为默认对话)
]]--
function TalkInfo:new (o)
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 对话前置条件
TalkAnt = {}

--[[
  t(类型：1前置必需任务2前置互斥任务3世界时间4拥有道具)
  taskid(任务id)
  beginHour(开始时间)
  endHour(结束时间)
  itemid(道具id)
  num(道具数量)
]]-- 
function TalkAnt:new (o)
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 会话
TalkSession = {}

--[[
  t(类型：1npc说, 2npc想, 3player说, 4player想)
  msg(string or arr)
  turnTo(跳到第几句对话，默认nil下一句)
  f(函数)
]]-- 
function TalkSession:new (t, msg, turnTo, f)
  if (type(turnTo) == 'function') then
    f = turnTo
    turnTo = nil
  end
  local o = {
    t = t,
    msg = msg,
    turnTo = turnTo,
    f = f,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

PlayerTalk = {}

-- msg(玩家的话) t(选择: 1继续(默认)；2跳转；3终止；4任务) other(对应选项：数字表示跳转项；任务) f(函数)
function PlayerTalk:new (msg, t, other, f)
  local o = {
    msg = msg,
    t = t,
    other = other,
    f = f,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end
