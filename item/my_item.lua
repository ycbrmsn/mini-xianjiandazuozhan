-- 道具类
MyItem = {}

function MyItem:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  if (o.id) then
    ItemHelper:register(o)
  end
  return o
end

-- 创建道具
function MyItem:newItem (playerid, num, disableThrow)
  num = num or 1
  BackpackHelper:addItem(playerid, self.id, num)
  if (disableThrow) then -- 不可丢弃
    PlayerHelper:setItemDisableThrow(playerid, self.id)
  end
end

-- 是否有道具
function MyItem:hasItem (playerid, containEquip)
  return BackpackHelper:hasItem(playerid, self.id, containEquip)
end

-- 更新道具数量
function MyItem:updateNum (playerid, num, disableThrow)
  local curNum, arr1, arr2 = BackpackHelper:getItemNumAndGrid(playerid, self.id)
  if (num == curNum) then -- 数量相同则不作处理
    return
  else
    if (num > curNum) then -- 比当前多
      self:newItem(playerid, num - curNum, disableThrow)
    else -- 比当前少
      BackpackHelper:removeGridItemByItemID(playerid, self.id, curNum - num)
    end
  end
end

-- 拿起道具(手上)
function MyItem:pickUp (objid)
  -- body
end

-- 放下道具(手上)
function MyItem:putDown (objid)
  -- body
end

-- 使用道具
function MyItem:useItem (objid)
  -- body
end

-- 进入潜行
function MyItem:useItem2 (objid)
  if (self.skillname) then
    local player = PlayerHelper:getPlayer(objid)
    if (not(player:ableUseSkill(self.skillname))) then
      return
    end
  end
  if (self.cd) then
    local ableUseSkill = ItemHelper:ableUseSkill(objid, self.id, self.cd)
    if (not(ableUseSkill)) then
      self.cdReason = self.cdReason or '技能冷却中'
      ChatHelper:sendSystemMsg(self.cdReason, objid)
      return
    end
  end
  if (self.useItem3) then
    self:useItem3(objid)
  end
end

-- 投掷物命中
function MyItem:projectileHit(projectileInfo, toobjid, blockid, pos)
  -- body
end

-- 攻击命中
function MyItem:attackHit (objid, toobjid)
  -- body
end

-- 武器类
MyWeapon = MyItem:new()

function MyWeapon:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o:newLevels()
  return o
end

function MyWeapon:newLevel (id, level)
  local o = {
    id = id,
    level = level,
    attack = self.attack + math.floor(self.addAttPerLevel * level),
    defense = self.defense + math.floor(self.addDefPerLevel * level)
  }
  setmetatable(o, self)
  self.__index = self
  if (o.id) then
    ItemHelper:register(o)
  end
  return o
end

function MyWeapon:newLevels ()
  for i, v in ipairs(self.levelIds) do
    self:newLevel(v, i - 1)
  end
end

function MyWeapon:pickUp (objid)
  local player = PlayerHelper:getPlayer(objid)
  player:changeAttr(self.attack, self.defense)
end

function MyWeapon:putDown (objid)
  local player = PlayerHelper:getPlayer(objid)
  player:changeAttr(-self.attack, -self.defense)
end

function MyWeapon:useItem (objid)
  if (self.skillname) then
    local player = PlayerHelper:getPlayer(objid)
    if (not(player:ableUseSkill(self.skillname))) then
      return
    end
  end
  if (self.cd) then
    local ableUseSkill = ItemHelper:ableUseSkill(objid, self.id, self.cd)
    if (not(ableUseSkill)) then
      self.cdReason = self.cdReason or '技能冷却中'
      ChatHelper:sendSystemMsg(self.cdReason, objid)
      return
    end
  end
  if (self.useItem1) then
    self:useItem1(objid)
  end
end

-- 减少体力
function MyWeapon:reduceStrength (objid)
  local player = PlayerHelper:getPlayer(objid)
  player:reduceStrength(self.strength)
end

-- 江湖日志类
LogPaper = MyItem:new()

function LogPaper:new ()
  local o = {
    id = MyMap.CUSTOM.ITEM.LOG_PAPER_ID,
    title = '江湖经历:',
    content = '',
    isChange = true -- 日志是否改变
  }
  setmetatable(o, self)
  self.__index = self
  ItemHelper:register(o)
  return o
end

-- 更新日志 self.title .. 
function LogPaper:updateLogs ()
  local title, content = StoryHelper:getMainStoryTitleAndTip()
  self.content = title .. '\n\t\t' .. content
  self.isChange = false
end

-- 获取日志
function LogPaper:getContent ()
  if (self.isChange) then
    self:updateLogs()
  end
  return self.content
end

-- 显示日志
function LogPaper:showContent (objid)
  ChatHelper:sendSystemMsg(self:getContent(), objid)
end

function LogPaper:useItem (objid)
  self:showContent(objid)
end