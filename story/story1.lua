-- 剧情一
Story1 = MyStory:new()

function Story1:new ()
  local data = {
    title = '无题',
    name = '无名称',
    desc = '无描述',
    tips = {
      '无事。',
    }
  }
  self:checkData(data)

  setmetatable(data, self)
  self.__index = self
  return data
end

function Story1:recover (player)
  -- body
end