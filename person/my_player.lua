-- 我的玩家类
MyPlayer = BasePlayer:new()

function MyPlayer:new (objid)
  local o = {
    objid = objid,
    isTooHigh = false, -- 是否飞得过高
    isTooFar = false, -- 是否飞得过远
    killPlayerNum = 0, -- 击杀玩家数
    KillMonsterNum = 0 -- 击杀怪物数
  }
  o.action = BasePlayerAction:new(o)
  o.attr = BasePlayerAttr:new(o)
  -- o.attr.expData = { exp = 50 }
  o.attr.defeatedExp = 20
  o.attr.addMeleeAttack = 6 -- 近战攻击
  o.attr.addRemoteAttack = 6 -- 远程攻击
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 更新属性
function MyPlayer:updateMaxHp ()
  local level = self:getLevel()
  if (level) then
    local maxHp = 300 + level * self.attr.addMaxHp
    PlayerHelper:setMaxHp(self.objid, maxHp)
    PlayerHelper:setHp(self.objid, maxHp)
  end
end