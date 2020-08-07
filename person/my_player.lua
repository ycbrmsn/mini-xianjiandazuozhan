-- 我的玩家类
MyPlayer = BasePlayer:new()

function MyPlayer:new (objid)
  local o = {
    objid = objid,
    isTooHigh = false, -- 是否飞得过高
    isTooFar = false -- 是否飞得过远
  }
  o.action = BasePlayerAction:new(o)
  o.attr = BasePlayerAttr:new(o)
  -- o.attr.expData = { exp = 50 }
  o.attr.defeatedExp = 20
  setmetatable(o, self)
  self.__index = self
  return o
end
