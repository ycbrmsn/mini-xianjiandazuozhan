-- 剑

-- 御仙剑
ControlSword = MyWeapon:new(MyWeaponAttr.controlSword)

function ControlSword:useItem1 (objid)
  local state = SkillHelper.getFlyState(objid)
  if (state == 0) then -- 可御剑，则御剑
    SkillHelper.flyStatic(objid, true)
  elseif (state == 1) then -- 御剑静止，则前行
    SkillHelper.flyAdvance(objid)
  elseif (state == 2) then -- 御剑前行，则静止
    SkillHelper.flyStatic(objid, true)
  end
end

-- 潜行
function ControlSword:useItem2 (objid)
  SkillHelper.stopFly(objid)
end

-- 万仙剑
TenThousandsSword = MyWeapon:new(MyWeaponAttr.tenThousandsSword)

function TenThousandsSword:useItem1 (objid)
  MySkillHelper.tenThousandsSwordcraft(objid, self)
  ItemHelper.recordUseSkill(objid, self.id, self.cd)
end

-- 投掷物命中
function TenThousandsSword:projectileHit (projectileInfo, toobjid, blockid, pos)
  local objid = projectileInfo.objid
  local item = projectileInfo.item
  if (toobjid > 0) then -- 命中生物（似乎命中同队生物不会进入这里）
    -- 判断是否是敌对生物
    if (not(ActorHelper.isTheSameTeamActor(objid, toobjid))) then -- 敌对生物，则造成伤害
      local key = PlayerHelper.generateDamageKey(objid, toobjid)
      local alreadyHurt = TimeHelper.getFrameInfo(key)
      local hurt = item.hurt + item.level * item.addHurtPerLevel
      if (not(ActorHelper.isPlayer(toobjid))) then -- 不是玩家则造成双倍伤害
        hurt = hurt * 2
      end
      if (alreadyHurt) then -- 造成伤害事件发生了
        hurt = hurt - alreadyHurt
      end
      if (hurt > 0) then
        ActorHelper.damageActor(objid, toobjid, hurt, self)
      end
    end
  end
end

-- 回仙剑
HuixianSword = MyWeapon:new(MyWeaponAttr.huixianSword)

function HuixianSword:useItem1 (objid)
  if (MySkillHelper.hasHuitianCircle(objid)) then
    MySkillHelper.clearHuitian(objid)
  else
    MySkillHelper.huitian(objid, self)
    ItemHelper.recordUseSkill(objid, self.id, self.cd)
  end
end

-- 投掷物命中
function HuixianSword:projectileHit (projectileInfo, toobjid, blockid, pos)
  local objid = projectileInfo.objid
  local item = projectileInfo.item
  if (toobjid > 0) then -- 命中生物（似乎命中同队生物不会进入这里）
    -- 判断是否是敌对生物
    if (not(ActorHelper.isTheSameTeamActor(objid, toobjid))) then -- 敌对生物，则造成伤害
      local key = PlayerHelper.generateDamageKey(objid, toobjid)
      local isHurt = TimeHelper.getFrameInfo(key)
      local hurt = item.hurt + item.level * item.addHurtPerLevel
      if (not(ActorHelper.isPlayer(toobjid))) then -- 不是玩家则造成双倍伤害
        hurt = hurt * 2
      end
      if (isHurt) then -- 造成伤害事件发生了
        hurt = hurt - MyMap.CUSTOM.PROJECTILE_HURT
      end
      if (hurt > 0) then
        ActorHelper.damageActor(objid, toobjid, hurt, self)
      end
    end
  end
end

-- 气仙剑
VitalqiSword = MyWeapon:new(MyWeaponAttr.vitalqiSword)

function VitalqiSword:useItem1 (objid)
  MySkillHelper.airArmour(objid)
  ItemHelper.recordUseSkill(objid, self.id, self.cd)
end

-- 乱仙剑
LuanSword = MyWeapon:new(MyWeaponAttr.luanSword)

function LuanSword:useItem1 (objid)
  MySkillHelper.luanJianJue(objid, self)
  ItemHelper.recordUseSkill(objid, self.id, self.cd)
end

-- 投掷物命中
function LuanSword:projectileHit (projectileInfo, toobjid, blockid, pos)
  local objid = projectileInfo.objid
  local item = projectileInfo.item
  if (toobjid > 0) then -- 命中生物（似乎命中同队生物不会进入这里）
    -- 判断是否是敌对生物
    if (not(ActorHelper.isTheSameTeamActor(objid, toobjid))) then -- 敌对生物，则造成伤害
      local key = PlayerHelper.generateDamageKey(objid, toobjid)
      local alreadyHurt = TimeHelper.getFrameInfo(key)
      local hurt = item.hurt + item.level * item.addHurtPerLevel
      if (not(ActorHelper.isPlayer(toobjid))) then -- 不是玩家则造成双倍伤害
        hurt = hurt * 2
      end
      if (alreadyHurt) then -- 造成伤害事件发生了
        hurt = hurt - alreadyHurt
      end
      if (hurt > 0) then
        ActorHelper.damageActor(objid, toobjid, hurt, self)
      end
    end
  end
end

-- 瞬仙剑
ShunSword = MyWeapon:new(MyWeaponAttr.shunSword)

function ShunSword:useItem1 (objid)
  MySkillHelper.shunyi(objid, self)
end

-- 囚仙剑
QiuSword = MyWeapon:new(MyWeaponAttr.qiuSword)

function QiuSword:useItem1 (objid)
  if (MySkillHelper.useQiuSword(objid, self)) then
    ItemHelper.recordUseSkill(objid, self.id, self.cd)
  else
    ChatHelper.sendMsg(objid, '前方无目标')
  end
end

-- 封仙剑
FengSword = MyWeapon:new(MyWeaponAttr.fengSword)

function FengSword:useItem1 (objid)
  if (MySkillHelper.useFengSword(objid, self)) then
    ItemHelper.recordUseSkill(objid, self.id, self.cd)
  else
    ChatHelper.sendMsg(objid, '周围无目标')
  end
end
