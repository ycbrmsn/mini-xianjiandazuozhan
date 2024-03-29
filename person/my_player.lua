-- 我的玩家类
MyPlayer = BasePlayer:new()

function MyPlayer:new (objid)
  local o = {
    objid = objid,
    isTooHigh = false, -- 是否飞得过高
    isTooFar = false, -- 是否飞得过远
    killPlayerNum = 0, -- 击杀玩家数
    KillMonsterNum = 0, -- 击杀怪物数
    isKilled = false, -- 是否被击败
  }
  o.action = BasePlayerAction:new(o)
  o.attr = BasePlayerAttr:new(o)
  -- o.attr.expData = { exp = 50 }
  o.attr.defeatedExp = 20
  o.attr.addMeleeAttack = 6 -- 近战攻击
  o.attr.addRemoteAttack = 6 -- 远程攻击
  o.attr.addMaxHp = 20 -- 最大生命
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 更新属性
function MyPlayer:updateMaxHp ()
  local level = self:getLevel()
  if (level) then
    local maxHp = 300 + level * self.attr.addMaxHp
    PlayerHelper.setMaxHp(self.objid, maxHp)
    PlayerHelper.setHp(self.objid, maxHp)
  end
end

-- 手持自定义道具变化
function MyPlayer:changeMyItem (item1, item2)
  if (SkillHelper.isFlying(self.objid)) then -- 如果在飞行，则退出飞行状态
    SkillHelper.stopFly(self.objid)
  end
end