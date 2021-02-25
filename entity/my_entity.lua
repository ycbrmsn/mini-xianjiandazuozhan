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
  self.__index = self
  setmetatable(o, self)
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
  self.__index = self
  setmetatable(o, self)
  return o
end

function MyPosition.__add (o1, o2)
  if (type(o2) == 'number') then
    return MyPosition:new(o1.x + o2, o1.y + o2, o1.z + o2)
  elseif (type(o2) == 'table') then
    return MyPosition:new(o1.x + o2.x, o1.y + o2.y, o1.z + o2.z)
  else
    error('运算对象是' .. type(o2) .. ', 不是数字或位置', 2)
  end
end

function MyPosition.__sub (o1, o2)
  if (type(o2) == 'number') then
    return MyPosition:new(o1.x - o2, o1.y - o2, o1.z - o2)
  elseif (type(o2) == 'table') then
    return MyPosition:new(o1.x - o2.x, o1.y - o2.y, o1.z - o2.z)
  else
    error('运算对象是' .. type(o2) .. ', 不是数字或位置', 2)
  end
end

function MyPosition.__mul (o1, o2)
  if (type(o2) == 'number') then
    return MyPosition:new(o1.x * o2, o1.y * o2, o1.z * o2)
  elseif (type(o2) == 'table') then
    return MyPosition:new(o1.x * o2.x, o1.y * o2.y, o1.z * o2.z)
  else
    error('运算对象是' .. type(o2) .. ', 不是数字或位置', 2)
  end
end

function MyPosition.__div (o1, o2)
  if (type(o2) == 'number') then
    return MyPosition:new(o1.x / o2, o1.y / o2, o1.z / o2)
  elseif (type(o2) == 'table') then
    return MyPosition:new(o1.x / o2.x, o1.y / o2.y, o1.z / o2.z)
  else
    error('运算对象是' .. type(o2) .. ', 不是数字或位置', 2)
  end
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
  local x1, y1, z1 = self:floor():get()
  local x2, y2, z2 = math.floor(pos.x), math.floor(pos.y), math.floor(pos.z)
  return x1 == x2 and y1 == y2 and z1 == z2
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
  self.__index = self
  setmetatable(o, self)
  return o
end

MyVector3.ZERO = MyVector3:new(0, 0, 0)
MyVector3.ONE = MyVector3:new(1, 1, 1)
MyVector3.LEFT = MyVector3:new(-1, 0, 0)
MyVector3.RIGHT = MyVector3:new(1, 0, 0)
MyVector3.UP = MyVector3:new(0, 1, 0)
MyVector3.DOWN = MyVector3:new(0, -1, 0)
MyVector3.FORWARD = MyVector3:new(0, 0, 1)
MyVector3.BACK = MyVector3:new(0, 0, -1)

function MyVector3.__add (o1, o2)
  if (type(o2) == 'number') then
    return MyVector3:new(o1.x + o2, o1.y + o2, o1.z + o2)
  elseif (type(o2) == 'table') then
    return MyVector3:new(o1.x + o2.x, o1.y + o2.y, o1.z + o2.z)
  else
    error('运算对象是' .. type(o2) .. ', 不是数字或位置', 2)
  end
end

function MyVector3.__sub (o1, o2)
  if (type(o2) == 'number') then
    return MyVector3:new(o1.x - o2, o1.y - o2, o1.z - o2)
  elseif (type(o2) == 'table') then
    return MyVector3:new(o1.x - o2.x, o1.y - o2.y, o1.z - o2.z)
  else
    error('运算对象是' .. type(o2) .. ', 不是数字或位置', 2)
  end
end

function MyVector3.__mul (o1, o2)
  if (type(o2) == 'number') then
    return MyVector3:new(o1.x * o2, o1.y * o2, o1.z * o2)
  elseif (type(o2) == 'table') then
    return MyVector3:new(o1.x * o2.x, o1.y * o2.y, o1.z * o2.z)
  else
    error('运算对象是' .. type(o2) .. ', 不是数字或位置', 2)
  end
end

function MyVector3.__div (o1, o2)
  if (type(o2) == 'number') then
    return MyVector3:new(o1.x / o2, o1.y / o2, o1.z / o2)
  elseif (type(o2) == 'table') then
    return MyVector3:new(o1.x / o2.x, o1.y / o2.y, o1.z / o2.z)
  else
    error('运算对象是' .. type(o2) .. ', 不是数字或位置', 2)
  end
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
  self.__index = self
  setmetatable(o, self)
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
  self.__index = self
  setmetatable(o, self)
  return o
end

-- 是否满足条件
function TalkInfo:isMeet (playerid)
  if (not(self.ants)) then
    return true
  end
  for i, ant in ipairs(self.ants) do
    if (not(ant:isMeet(playerid))) then
      return false
    end
  end
  return true
end

-- 对话前置条件
--[[
  t(类型：1前置必需任务2前置互斥任务3世界时间4拥有道具)
  taskid(任务id)
  beginHour(开始时间)
  endHour(结束时间)
  itemid(道具id)
  num(道具数量)
  state(任务状态1未完成2已完成3已结束)
]]-- 
TalkAnt = {}

function TalkAnt:new (o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end

-- 前置必需任务
function TalkAnt:includeTask (taskid, state)
  if (type(taskid) == 'table') then
    taskid = taskid.id
  end
  return TalkAnt:new({ t = 1, taskid = taskid, state = state })
end

-- 前置互斥任务
function TalkAnt:excludeTask (taskid)
  if (type(taskid) == 'table') then
    taskid = taskid.id
  end
  return TalkAnt:new({ t = 2, taskid = taskid })
end

-- 世界时间
function TalkAnt:betweenHour (beginHour, endHour)
  return TalkAnt:new({ t = 3, beginHour = beginHour, endHour = endHour })
end

-- 拥有道具
function TalkAnt:includeItem (itemid, num)
  if (type(itemid) == 'table') then
    itemid = itemid.id
  end
  return TalkAnt:new({ t = 4, itemid = itemid, num = num or 1 })
 end

-- 是否满足条件
function TalkAnt:isMeet (playerid)
  if (self.t == 1) then -- 前置必需任务
    -- LogHelper:debug(self)
    if (TaskHelper:hasTask(playerid, self.taskid)) then
      if (self.state) then -- 任务进度
        local state = TaskHelper:getTaskState(playerid, self.taskid)
        return state == self.state
      end
    else
      return false
    end
  elseif (self.t == 2) then -- 前置互斥任务
    -- LogHelper:debug(self)
    if (TaskHelper:hasTask(playerid, self.taskid)) then
      return false
    end
  elseif (self.t == 3) then -- 世界时间
    local hour = TimeHelper:getHour()
    if (not(hour >= self.beginHour and hour < self.endHour)) then
      return false
    end
  elseif (self.t == 4) then -- 拥有道具
    local itemnum = self.num or 1
    local num = BackpackHelper:getItemNumAndGrid(playerid, self.itemid)
    if (num < itemnum) then
      return false
    end
  end
  return true
end

-- 会话
--[[
  t(类型：1npc说, 2npc想, 3player说, 4player想)
  msg(string or arr)
  turnTo(跳到第几句对话，默认nil下一句)
  f(函数)
]]-- 
TalkSession = {}

function TalkSession:new (o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end

function TalkSession:dialogue (t, msg)
  local o = {
    t = t,
    msg = msg,
  }
  return TalkSession:new(o)
end

function TalkSession:reply (msg)
  return self:dialogue(1, msg)
end

function TalkSession:noReply (msg)
  return self:dialogue(2, msg)
end

function TalkSession:speak (msg)
  return self:dialogue(3, msg)
end

function TalkSession:think (msg)
  return self:dialogue(4, msg)
end

function TalkSession:choose (msg)
  return self:dialogue(5, msg)
end

function TalkSession:to (turnTo)
  self.turnTo = turnTo
  return self
end

function TalkSession:call (f)
  self.f = f
  return self
end

-- msg(玩家的话) t(选择: 1继续(默认)；2跳转；3终止；4接受任务) other(对应选项：数字表示跳转项；任务) f(函数)
PlayerTalk = {}

function PlayerTalk:new (msg, t, other, f)
  local o = {
    msg = msg,
    t = t,
    other = other,
    f = f,
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

function PlayerTalk:dialogue (t, msg, o)
  o = o or {}
  o.t = t
  o.msg = msg
  self.__index = self
  setmetatable(o, self)
  return o
end

function PlayerTalk:continue (msg)
  return self:dialogue(1, msg)
end

function PlayerTalk:to (msg, turnTo)
  return self:dialogue(2, msg, { other = turnTo })
end

function PlayerTalk:stop (msg)
  return self:dialogue(3, msg)
end

function PlayerTalk:acceptTask (msg, task)
  return self:dialogue(4, msg, { other = task })
end

function PlayerTalk:call (f)
  self.f = f
  return self
end

-- 任务类
BaseTask = {
  name = '空',
  desc = '无描述',
  category = 3,
  rewards = {},
}

--[[
  id
  name(任务名称)
  desc(任务描述)
  category(任务类型：1击败生物；2交付道具；3不做什么)
  beatInfos(击败生物信息) { actorid = actorid, actorname = actorname, num = num, curnum = curnum }
  itemInfos(交付道具信息) { itemid = itemid, num = num }
  rewards(任务奖励)
]]-- 
function BaseTask:new (o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end

-- 显示任务信息
function BaseTask:show (objid)
  ChatHelper:sendMsg(objid, '任务名称：', self.name, '任务')
  ChatHelper:sendMsg(objid, '任务描述：', self.desc)
  -- 任务奖励
  for i, reward in ipairs(self.rewards) do
    local rewardMsg = reward.desc
    if (i == #self.rewards) then
      rewardMsg = rewardMsg .. '。'
    else
      rewardMsg = rewardMsg .. '，'
    end
    if (i == 1) then
      ChatHelper:sendMsg(objid, '任务奖励：', rewardMsg)
    else
      ChatHelper:sendMsg(objid, '\t\t\t\t\t', rewardMsg)
    end
  end
  -- 任务进度
  local progressMsg = ''
  if (self.category == 1) then -- 击败生物
    for i, beatInfo in ipairs(self.beatInfos) do
      if (i == 1) then
        ChatHelper:sendMsg(objid, '任务进度：', beatInfo.actorname, '（',
          beatInfo.curnum, '/', beatInfo.num, '）')
      else
        ChatHelper:sendMsg(objid, '\t\t\t\t\t', beatInfo.actorname, '（',
          beatInfo.curnum, '/', beatInfo.num, '）')
      end
    end
  elseif (self.category == 2) then -- 交付道具
    for i, itemInfo in ipairs(self.itemInfos) do
      local itemname = ItemHelper:getItemName(itemInfo.itemid)
      local num = BackpackHelper:getItemNumAndGrid(objid, itemInfo.itemid)
      if (i == 1) then
        ChatHelper:sendMsg(objid, '任务进度：', itemname, '（',
          num, '/', itemInfo.num, '）')
      else
        ChatHelper:sendMsg(objid, '\t\t\t\t\t', itemname, '（',
          num, '/', itemInfo.num, '）')
      end
    end
  else
    progressMsg = '不详。'
  end
end

-- 是否完成任务
function BaseTask:isComplete (objid)
  if (self.category == 1) then -- 击败生物
    for i, beatInfo in ipairs(self.beatInfos) do
      if (beatInfo.curnum < beatInfo.num) then
        return false
      end
    end
    return true
  elseif (self.category == 2) then -- 交付道具
    for i, itemInfo in ipairs(self.itemInfos) do
      local num = BackpackHelper:getItemNumAndGrid(objid, itemInfo.itemid)
      if (num < itemInfo.num) then
        return false
      end
    end
    return true
  else -- 其他
    return true
  end
end

TaskReward = {}

--[[
  desc(奖励描述)
  category(奖励类型：1道具；2经验；3其他)
  itemid(道具id)
  num(数值)
]]-- 
function TaskReward:new (o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end