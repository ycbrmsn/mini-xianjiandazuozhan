-- 怪物

-- 无聊鸡
Chick = BaseActor:new(MyConstant.CHICK_ACTOR_ID)

function Chick:new ()
  local o = {
    objid = MyConstant.CHICK_ACTOR_ID,
    expData = {
      level = 5,
      exp = 20
    },
    fallOff = {
      { MyConstant.ITEM.APPLE_ID, 1, 1, 20 }, -- 苹果
      { MyConstant.ITEM.ENERGY_FRAGMENT_ID, 1, 1, 100 } -- 能量碎片
    },
    num = 5,
    monsterPositions = {
      { x = -35, y = 3, z = 8 }, -- 怪物生成区域位置
      { x = 41, y = 3, z = 78 }, -- 怪物生成区域位置
    },
    tipPositions = {},
    monsterAreas = {},
    areaids = {},
    areaName = ''
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Chick:init ()
  -- 怪物定时生成区域
  for i, v in ipairs(self.monsterPositions) do
    table.insert(self.monsterAreas, AreaHelper:getAreaByPos(v))
  end
  self.generate = function ()
    self:generateMonsters()
  end
  return true
end

function Chick:getName ()
  if (not(self.actorname)) then
    self.actorname = '无聊鸡'
  end
  return self.actorname
end

-- 检查各个区域内的怪物数量，少于num只则补充到num只
function Chick:generateMonsters (num)
  num = num or self.num
  for i, v in ipairs(self.monsterAreas) do
    local curNum = MonsterHelper:getMonsterNum(v, self.actorid)
    if (curNum < num) then
      for i = 1, num - curNum do
        local pos = AreaHelper:getRandomAirPositionInArea(v)
        self:newMonster(pos.x, pos.y, pos.z, 1)
      end
    end
  end
end

-- 定时生成怪物
function Chick:timerGenerate (num)
  num = num or self.num
  TimeHelper:repeatUtilSuccess(self.actorid, 'generate', function ()
    self:generateMonsters(num)
    return false
  end, 60)
end

-- 贪玩狗
Dog = BaseActor:new(MyConstant.DOG_ACTOR_ID)

function Dog:new ()
  local o = {
    objid = MyConstant.DOG_ACTOR_ID,
    expData = {
      level = 10,
      exp = 20
    },
    fallOff = {
      { MyConstant.ITEM.APPLE_ID, 1, 1, 20 }, -- 苹果
      { MyConstant.ITEM.ENERGY_FRAGMENT_ID, 1, 3, 100 } -- 能量碎片
    },
    num = 5,
    monsterPositions = {
      { x = 0, y = 17, z = 45 }, -- 怪物生成区域位置
    },
    tipPositions = {},
    monsterAreas = {},
    areaids = {},
    areaName = ''
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Dog:init ()
  -- 怪物定时生成区域
  for i, v in ipairs(self.monsterPositions) do
    table.insert(self.monsterAreas, AreaHelper:getAreaByPos(v))
  end
  self.generate = function ()
    self:generateMonsters()
  end
  return true
end

function Dog:getName ()
  if (not(self.actorname)) then
    self.actorname = '贪玩狗'
  end
  return self.actorname
end

-- 检查各个区域内的怪物数量，少于num只则补充到num只
function Dog:generateMonsters (num)
  num = num or self.num
  for i, v in ipairs(self.monsterAreas) do
    local curNum = MonsterHelper:getMonsterNum(v, self.actorid)
    if (curNum < num) then
      for i = 1, num - curNum do
        local pos = AreaHelper:getRandomAirPositionInArea(v)
        self:newMonster(pos.x, pos.y, pos.z, 1)
      end
    end
  end
end

-- 定时生成怪物
function Dog:timerGenerate (num)
  num = num or self.num
  TimeHelper:repeatUtilSuccess(self.actorid, 'generate', function ()
    self:generateMonsters(num)
    return false
  end, 60)
end

-- 怪物

-- 幽风之狼
Wolf = BaseActor:new(MyConstant.WOLF_ACTOR_ID)

function Wolf:new ()
  local o = {
    objid = MyConstant.WOLF_ACTOR_ID,
    expData = {
      level = 15,
      exp = 30
    },
    fallOff = {
      { MyConstant.ITEM.APPLE_ID, 1, 1, 20 }, -- 苹果
      { MyConstant.ITEM.ENERGY_FRAGMENT_ID, 4, 6, 100 } -- 能量碎片
    },
    num = 5,
    monsterPositions = {
      { x = 50, y = 25, z = 40 } -- 怪物生成区域位置
    },
    tipPositions = {}, -- 提示区域位置
    monsterAreas = {},
    areaids = {},
    areaName = '虚岩谷'
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Wolf:init ()
  -- 怪物定时生成区域
  for i, v in ipairs(self.monsterPositions) do
    table.insert(self.monsterAreas, AreaHelper:getAreaByPos(v))
  end
  self.generate = function ()
    self:generateMonsters()
  end
  return true
end

function Wolf:getName ()
  if (not(self.actorname)) then
    self.actorname = '幽风之狼'
  end
  return self.actorname
end

-- 检查各个区域内的怪物数量，少于num只则补充到num只
function Wolf:generateMonsters (num)
  num = num or self.num
  for i, v in ipairs(self.monsterAreas) do
    local curNum = MonsterHelper:getMonsterNum(v, self.actorid)
    if (curNum < num) then
      for i = 1, num - curNum do
        local pos = AreaHelper:getRandomAirPositionInArea(v)
        self:newMonster(pos.x, pos.y, pos.z, 1)
      end
    end
  end
end

-- 定时生成怪物
function Wolf:timerGenerate (num)
  num = num or self.num
  TimeHelper:repeatUtilSuccess(self.actorid, 'generate', function ()
    self:generateMonsters(num)
    return false
  end, 60)
end

-- 狂浪之牛
Ox = BaseActor:new(MyConstant.OX_ACTOR_ID)

function Ox:new ()
  local o = {
    objid = MyConstant.OX_ACTOR_ID,
    expData = {
      level = 20,
      exp = 40
    },
    fallOff = {
      { MyConstant.ITEM.APPLE_ID, 1, 1, 20 }, -- 苹果
      { MyConstant.ITEM.ENERGY_FRAGMENT_ID, 6, 9, 100 } -- 能量碎片
    },
    num = 5,
    monsterPositions = {
      { x = -49, y = 27, z = 49 }, -- 狂牛区域位置
    },
    tipPositions = {}, -- 提示区域位置
    monsterAreas = {},
    areaids = {},
    areaName = '旷野原'
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Ox:init ()
  -- 怪物定时生成区域
  for i, v in ipairs(self.monsterPositions) do
    table.insert(self.monsterAreas, AreaHelper:getAreaByPos(v))
  end
  self.generate = function ()
    self:generateMonsters()
  end
  return true
end

function Ox:getName ()
  if (not(self.actorname)) then
    self.actorname = '狂浪之牛'
  end
  return self.actorname
end

-- 检查各个区域内的怪物数量，少于num只则补充到num只
function Ox:generateMonsters (num)
  num = num or self.num
  for i, v in ipairs(self.monsterAreas) do
    local curNum = MonsterHelper:getMonsterNum(v, self.actorid)
    if (curNum < num) then
      for i = 1, num - curNum do
        local pos = AreaHelper:getRandomAirPositionInArea(v)
        self:newMonster(pos.x, pos.y, pos.z, 1)
      end
    end
  end
end

-- 定时生成怪物
function Ox:timerGenerate (num)
  num = num or self.num
  TimeHelper:repeatUtilSuccess(self.actorid, 'generate', function ()
    self:generateMonsters(num)
    return false
  end, 60)
end