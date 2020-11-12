-- 任务类
BaseTask = {}

--[[
  id
  name(任务名称)
  desc(任务描述)
  category(任务类型：1击败生物；2交付道具)
  beatInfos(击败生物信息) { actorid = actorid, actorname = actorname, num = num, curnum = curnum }
  itemInfos(交付道具信息) { itemid = itemid, num = num }
  rewards(任务奖励)
]]-- 
function BaseTask:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
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
  setmetatable(o, self)
  self.__index = self
  return o
end