-- 我的剧情类
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

-- 如需恢复剧情信息，则重写此方法
function MyStory:recover (player)
  -- body
end

function MyStory:init ()
  
end

function MyStory:enterArea (objid, areaid)
  return false
end

function MyStory:getProgressPrepose (name)
  return self.prepose[name]
end