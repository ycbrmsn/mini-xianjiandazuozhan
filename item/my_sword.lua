-- 剑

-- 御剑
ControlSword = MyWeapon:new(MyWeaponAttr.controlSword)

function ControlSword:useItem1 (objid)
  local state = SkillHelper:getFlyState(objid)
  if (state == 0) then -- 可御剑，则御剑
    SkillHelper:flyStatic(objid)
  elseif (state == 1) then -- 御剑静止，则前行
    SkillHelper:flyAdvance(objid)
  elseif (state == 2) then -- 御剑前行，则静止
    SkillHelper:flyStatic(objid)
  end
end

-- 潜行
function ControlSword:useItem2 (objid)
  SkillHelper:stopFly(objid)
end

-- 万剑
TenThousandsSword = MyWeapon:new(MyWeaponAttr.tenThousandsSword)

function TenThousandsSword:useItem1 (objid)
  SkillHelper:tenThousandsSwordcraft(objid, self)
  ItemHelper:recordUseSkill(objid, self.id, self.cd)
end

-- 投掷物命中
function TenThousandsSword:projectileHit (projectileInfo, toobjid, blockid, pos)
  local objid = projectileInfo.objid
  local item = projectileInfo.item
  if (toobjid > 0) then -- 命中生物（似乎命中同队生物不会进入这里）
    -- 判断是否是敌对生物
    if (not(ActorHelper:isTheSameTeamActor(objid, toobjid))) then -- 敌对生物，则造成伤害
      local key = PlayerHelper:generateDamageKey(objid, toobjid)
      local isHurt = TimeHelper:getFrameInfo(key)
      local hurt = item.hurt + item.level * item.addHurtPerLevel
      if (isHurt) then -- 造成伤害事件发生了
        hurt = hurt - MyConstant.PROJECTILE_HURT
      end
      if (hurt > 0) then
        ActorHelper:damageActor(objid, toobjid, hurt)
      end
    end
  end
end

-- 回仙剑
HuixianSword = MyWeapon:new(MyWeaponAttr.huixianSword)

function HuixianSword:useItem1 (objid)
  SkillHelper:huitian(objid, self)
  ItemHelper:recordUseSkill(objid, self.id, self.cd)
end

-- 投掷物命中
function HuixianSword:projectileHit (projectileInfo, toobjid, blockid, pos)
  local objid = projectileInfo.objid
  local item = projectileInfo.item
  if (toobjid > 0) then -- 命中生物（似乎命中同队生物不会进入这里）
    -- 判断是否是敌对生物
    if (not(ActorHelper:isTheSameTeamActor(objid, toobjid))) then -- 敌对生物，则造成伤害
      local key = PlayerHelper:generateDamageKey(objid, toobjid)
      local isHurt = TimeHelper:getFrameInfo(key)
      local hurt = item.hurt + item.level * item.addHurtPerLevel
      if (isHurt) then -- 造成伤害事件发生了
        hurt = hurt - MyConstant.PROJECTILE_HURT
      end
      if (hurt > 0) then
        ActorHelper:damageActor(objid, toobjid, hurt)
      end
    end
  end
end

-- 气仙剑
VitalqiSword = MyWeapon:new(MyWeaponAttr.vitalqiSword)

function VitalqiSword:useItem1 (objid)
  SkillHelper:airArmour(objid)
  ItemHelper:recordUseSkill(objid, self.id, self.cd)
end