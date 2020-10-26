-- 任务基类
BaseTask = {}

-- name(任务名称) t(任务类型：1无；2击败生物；3交付道具) rewards(任务奖励) beats(击败生物) items(交付道具)
function BaseTask:new (name, t, rewards, beats, items)
  local o = {
    name = name,
    t = t,
    rewards = rewards,
    beats = beats,
    items = items,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

TaskReward = {}

-- msg(奖励描述) t(奖励类型：1道具；2经验；3其他) num(数值)
function TaskReward:new (msg, t, num)
  local o = {
    msg = msg,
    t = t,
    num = num,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end