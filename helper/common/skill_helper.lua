-- 技能工具类
SkillHelper = {
  flyData = {}, -- { objid -> { state = state, flySwordId = flySwordId } }
  huitianData = {} -- { objid -> {} }
}

function SkillHelper:getItem (item, weaponName)
  if (not(item)) then
    item = ItemHelper:getItem(MyWeaponAttr[weaponName].levelIds[1])
  elseif (type(item) == 'number') then
    item = ItemHelper:getItem(MyWeaponAttr[weaponName].levelIds[item])
  end
  return item
end

-- 囚禁actor，用于慑魂枪效果
function SkillHelper:imprisonActor (objid)
  ActorHelper:playBodyEffect(objid, MyConstant.BODY_EFFECT.LIGHT22)
  if (ActorHelper:isPlayer(objid)) then -- 玩家
    local player = PlayerHelper:getPlayer(objid)
    player:setImprisoned(true)
  else
    local actor = ActorHelper:getActor(objid)
    if (actor) then
      actor:setImprisoned(true)
    else
      MonsterHelper:imprisonMonster(objid)
    end
  end
end

-- 取消囚禁actor
function SkillHelper:cancelImprisonActor (objid)
  local canCancel
  if (ActorHelper:isPlayer(objid)) then -- 玩家
    local player = PlayerHelper:getPlayer(objid)
    canCancel = player:setImprisoned(false)
  else
    local actor = ActorHelper:getActor(objid)
    if (actor) then
      canCancel = actor:setImprisoned(false)
    else
      canCancel = MonsterHelper:cancelImprisonMonster(objid)
    end
  end
  if (canCancel) then
    ActorHelper:stopBodyEffectById(objid, MyConstant.BODY_EFFECT.LIGHT22)
  end
end

-- 封魔actor
function SkillHelper:sealActor (objid)
  ActorHelper:playBodyEffect(objid, MyConstant.BODY_EFFECT.LIGHT47)
  if (ActorHelper:isPlayer(objid)) then -- 玩家
    local player = PlayerHelper:getPlayer(objid)
    player:setSeal(true)
  else
    local actor = ActorHelper:getActor(objid)
    if (actor) then
      actor:setSealed(true)
    else
      MonsterHelper:sealMonster(objid)
    end
  end
end

-- 取消封魔actor
function SkillHelper:cancelSealActor (objid)
  local canCancel
  if (ActorHelper:isPlayer(objid)) then -- 玩家
    local player = PlayerHelper:getPlayer(objid)
    canCancel = player:setSeal(false)
  else
    local actor = ActorHelper:getActor(objid)
    if (actor) then
      canCancel = actor:setSealed(false)
    else
      canCancel = MonsterHelper:cancelSealMonster(objid)
    end
  end
  if (canCancel) then
    ActorHelper:stopBodyEffectById(objid, MyConstant.BODY_EFFECT.LIGHT47)
  end
end

-- 获取御剑状态（-1：御剑失控；0：可御剑；1：御剑静止；2：御剑前行）
function SkillHelper:getFlyState (objid)
  local flyData = self.flyData[objid]
  if (not(flyData)) then
    self.flyData[objid] = { state = 0 }
  end
  return self.flyData[objid].state
end

-- 设置御剑状态
function SkillHelper:setFlyState (objid, state)
  local flyData = self.flyData[objid]
  if (not(flyData)) then
    self.flyData[objid] = {}
  end
  self.flyData[objid].state = state
end

function SkillHelper:isFlying (objid)
  local flyType = objid .. 'fly'
  return TimeHelper:isFnContinueRuns(flyType), flyType
end

function SkillHelper:isFlyingAdvance (objid)
  local flyAdvanceType = objid .. 'flyAdvance'
  return TimeHelper:isFnContinueRuns(flyAdvanceType), flyAdvanceType
end

function SkillHelper:flyStatic (objid)
  local pos = ActorHelper:getMyPosition(objid)
  if (not(ActorHelper:isInAir(objid))) then -- 不在空中
    pos.y = pos.y + 2
    ActorHelper:setMyPosition(objid, pos)
  end
  -- ActorHelper:setFaceYaw(objid, ActorHelper:getFaceYaw(objid))
  if (not(self.flyData[objid])) then
    self.flyData[objid] = {}
  end
  local flySwordId
  if (not(self.flyData[objid].flySwordId)) then
    flySwordId = WorldHelper:spawnProjectileByDirPos(objid, MyWeaponAttr.controlSword.projectileid, pos, pos, 0)
    self.flyData[objid].flySwordId = flySwordId
  end
  local isFlying, flyType = self:isFlying(objid)
  local isFlyingAdvance, flyAdvanceType = self:isFlyingAdvance(objid)
  if (not(isFlying)) then -- 如果没有飞，则飞起来
    TimeHelper:callFnContinueRuns(function ()
      ActorHelper:appendSpeed(objid, 0, MyConstant.FLY_SPEED, 0)
      local p = ActorHelper:getMyPosition(objid)
      ActorHelper:setMyPosition(flySwordId, p.x, p.y - 0.1, p.z)
      ActorHelper:setFaceYaw(flySwordId, ActorHelper:getFaceYaw(objid))
    end, -1, flyType)
  end
  if (isFlyingAdvance) then -- 如果在向前飞，则停止
    TimeHelper:delFnContinueRuns(flyAdvanceType)
  end
  self:setFlyState(objid, 1)
end

function SkillHelper:flyAdvance (objid)
  local isFlying, flyType = self:isFlying(objid)
  local isFlyingAdvance, flyAdvanceType = self:isFlyingAdvance(objid)
  if (not(isFlying)) then -- 如果没有飞，则飞起来
    TimeHelper:callFnContinueRuns(function ()
      ActorHelper:appendSpeed(objid, 0, MyConstant.FLY_SPEED, 0)
    end, -1, flyType)
  end
  if (not(isFlyingAdvance)) then -- 如果没有向前飞，则向前飞
    TimeHelper:callFnContinueRuns(function ()
      local speedVector3 = MyVector3:new(ActorHelper:getFaceDirection(objid)):mul(0.1)
      ActorHelper:appendSpeed(objid, speedVector3.x, speedVector3.y, speedVector3.z)
    end, -1, flyAdvanceType)
  end
  self:setFlyState(objid, 2)
end

function SkillHelper:stopFly (objid, item)
  local state = self:getFlyState(objid)
  if (state == 0 or state == -1) then -- 未飞行或已失控
    return
  end
  if (item) then -- 失控
    item = SkillHelper:getItem(item, 'controlSword')
    ItemHelper:recordUseSkill(objid, item.id, MyWeaponAttr.controlSword.cd)
  end
  if (state == 1) then -- 静止
    TimeHelper:delFnContinueRuns(objid .. 'fly')
  elseif (state == 2) then -- 前行
    TimeHelper:delFnContinueRuns(objid .. 'fly')
    TimeHelper:delFnContinueRuns(objid .. 'flyAdvance')
  end
  self:setFlyState(objid, 0)
  WorldHelper:despawnActor(self.flyData[objid].flySwordId)
  -- ActorHelper:killSelf(self.flyData[objid].flySwordId)
  self.flyData[objid].flySwordId = nil
  -- ActorHelper:setImmuneFall(self.myActor.objid, true) -- 免疫跌落
  -- TimeHelper:callFnFastRuns(function ()
  --   ActorHelper:setImmuneFall(self.myActor.objid, false) -- 取消免疫跌落
  -- end, 1)
end

-- 万剑诀起势 对象、道具（或道具等级）、有效范围半边长
function SkillHelper:tenThousandsSwordcraft (objid, item, size)
  item = SkillHelper:getItem(item, 'tenThousandsSword')
  size = size or 3
  local pos = ActorHelper:getDistancePosition(objid, 2)
  pos.y = pos.y + 1
  local dstPos = ActorHelper:getDistancePosition(objid, 6)
  local projectileid = WorldHelper:spawnProjectileByDirPos(objid, 
    item.projectileid, pos, pos, 0)
  ActorHelper:setFacePitch(projectileid, -135)
  ActorHelper:setFaceYaw(projectileid, ActorHelper:getFaceYaw(objid) + 90)
  local t = 'ten' .. projectileid
  -- 旋转一圈起飞
  TimeHelper:callFnContinueRuns(function ()
    local facePitch = ActorHelper:getFacePitch(projectileid)
    if (not(facePitch)) then
      TimeHelper:delFnContinueRuns(t)
    else
      if (facePitch >= 270) then
        ActorHelper:appendSpeed(projectileid, 0, 1, 0)
        TimeHelper:delFnContinueRuns(t)
        TimeHelper:callFnFastRuns(function ()
          WorldHelper:despawnActor(projectileid)
          SkillHelper:tenThousandsSwordcraft2(objid, item, dstPos, size)
        end, 1)
      else
        ActorHelper:turnFacePitch(projectileid, 45)
      end
    end
  end, -1, t)
end

-- 万剑诀 落势
function SkillHelper:tenThousandsSwordcraft2 (objid, item, dstPos, size)
  local y = dstPos.y + 20
  local arr, projectiles = {}, {}
  for i = dstPos.x - size, dstPos.x + size do
    for ii = dstPos.z - size, dstPos.z + size do
      table.insert(arr, MyPosition:new(i, y, ii))
    end
  end
  SkillHelper:tenThousandsSwordcraft3(objid, item, arr, projectiles)
  local dim = MyPosition:new(5, 10, 5)
  TimeHelper:callFnContinueRuns(function ()
    for i, v in ipairs(projectiles) do
      if (v[1]) then
        local pos = ActorHelper:getMyPosition(v[2])
        if (pos) then
          local objids = ActorHelper:getAllCreaturesArroundPos(pos, dim, objid)
          if (not(objids) or #objids == 0) then
            objids = ActorHelper:getAllPlayersArroundPos(pos, dim, objid)
          end
          if (objids and #objids > 0) then
            ActorHelper:appendSpeed(v[2], -v[3].x, -v[3].y, -v[3].z)
            local speedVector3 = ActorHelper:appendFixedSpeed(v[2], 1, pos, ActorHelper:getMyPosition(objids[1]))
            v[3] = speedVector3
            ItemHelper:recordMissileSpeed(v[2], speedVector3)
          end
        else
          v[1] = false
        end
      end
    end
  end, 5)
end

function SkillHelper:tenThousandsSwordcraft3 (objid, item, arr, projectiles)
  if (#arr > 0) then
    local index = math.random(1, #arr)
    local speedVector3 = MyVector3:new(0, -0.8, 0)
    local projectileid = WorldHelper:spawnProjectileByDirPos(objid, 
      item.projectileid, arr[index], speedVector3, 0)
    ActorHelper:appendSpeed(projectileid, speedVector3.x, speedVector3.y, speedVector3.z)
    table.insert(projectiles, { true, projectileid, speedVector3 })
    table.remove(arr, index)
    ItemHelper:recordProjectile(projectileid, objid, item, {})
    ItemHelper:recordMissileSpeed(projectileid, speedVector3)
    TimeHelper:callFnFastRuns(function ()
      SkillHelper:tenThousandsSwordcraft3(objid,item, arr, projectiles)
    end, 0.1)
  end
end

-- 气甲术 对象、范围大小、持续时间
function SkillHelper:airArmour (objid, size, time)
  size = size or 3
  time = time or 10
  local dim = { x = size + 1, y = size + 1, z = size + 1 }
  local teamid = ActorHelper:getTeam(objid)
  local missileMap = {} -- 击落的投掷物 { objid -> true }
  local bodyEffect = MyConstant.BODY_EFFECT.LIGHT64 -- 特效
  local idx = 1
  ActorHelper:playBodyEffect(objid, bodyEffect)
  local t = objid .. 'airArmour'
  TimeHelper:callFnContinueRuns(function ()
    local pos = ActorHelper:getMyPosition(objid)
    pos.y = pos.y + 1
    local missiles
    if (teamid == 0) then
      missiles = ActorHelper:getAllMissilesArroundPos(pos, dim)
    else
      missiles = ActorHelper:getAllMissilesArroundPos(pos, dim, objid, false)
    end
    -- LogHelper:debug('idx', idx, ': ', #missiles)
    idx = idx + 1
    if (missiles and #missiles > 0) then
      for i, v in ipairs(missiles) do
        if (not(missileMap[v])) then -- 未击落
          local distance = MathHelper:getDistance(pos, v)
          if (distance < size) then
            local speedVector3 = ItemHelper:getMissileSpeed(v)
            if (speedVector3) then
              ActorHelper:appendSpeed(v, -speedVector3.x, -speedVector3.y, -speedVector3.z)
              local sv3 = ActorHelper:appendFixedSpeed(v, 0.8, pos)
              ItemHelper:recordMissileSpeed(v, sv3)
              ActorHelper:addGravity(v)
              missileMap[v] = true
            end
          end
        end
      end
    end
  end, time, t)
  TimeHelper:callFnFastRuns(function ()
    ActorHelper:stopBodyEffectById(objid, bodyEffect)
  end, time)
end

-- 回天 对象、道具（或道具等级）、飞剑数量、有效范围、角度改变、飞剑距离
function SkillHelper:huitian (objid, item, num, size, changeAngle, distance)
  item = SkillHelper:getItem(item, 'huixianSword')
  num = num or 4
  size = size or 5
  changeAngle = changeAngle or 5
  distance = distance or 2
  local dim = { x = size, y = size, z = size }
  local projectiles = self:clearHuitian(objid)
  for i = 1, num do
    local angle = 360 / num * i
    local pos = ActorHelper:getFixedDistancePosition(objid, distance, angle)
    pos.y = pos.y + 1
    local projectileid = WorldHelper:spawnProjectileByDirPos(objid, 
      item.projectileid, pos, pos, 0)
    ItemHelper:recordProjectile(projectileid, objid, item, {})
    table.insert(projectiles, { flag = 0, objid = projectileid, angle = angle })
  end
  local t = objid .. 'huitian'
  TimeHelper:callFnContinueRuns(function ()
    local num = 0
    local objPos = ActorHelper:getMyPosition(objid)
    for i, v in ipairs(projectiles) do
      local p = ActorHelper:getMyPosition(v.objid)
      if (not(p)) then
        v.flag = 2
      else
        -- 查询生物周围是否有目标
        local objids = ActorHelper:getAllCreaturesArroundPos(objPos, dim, objid)
        if (not(objids) or #objids == 0) then
          objids = ActorHelper:getAllPlayersArroundPos(objPos, dim, objid)
        end
        if (objids and #objids > 0) then -- 发现目标
          if (v.flag == 0) then -- 环绕状态
            v.flag = 1
          else -- 追击状态
            local speedVector3 = ItemHelper:getMissileSpeed(v.objid)
            if (speedVector3) then
              ActorHelper:appendSpeed(v.objid, -speedVector3.x, -speedVector3.y, -speedVector3.z)
            end
          end
          local sv3 = ActorHelper:appendFixedSpeed(v.objid, 1, p, ActorHelper:getMyPosition(objids[1]))
          ItemHelper:recordMissileSpeed(v.objid, sv3)
        else -- 未发现目标，追击状态不处理
          if (v.flag == 0) then -- 环绕状态
            SkillHelper:huitianCircle(objid, distance, v, changeAngle)
          end
        end
        num = num + 1
      end
    end
    if (num == 0) then -- 飞剑皆毁
      TimeHelper:delFnContinueRuns(t)
    end
  end, -1, t)
end

function SkillHelper:huitianCircle (objid, distance, projectile, changeAngle)
  projectile.angle = projectile.angle + changeAngle
  local dstPos = ActorHelper:getFixedDistancePosition(objid, distance, projectile.angle)
  dstPos.y = dstPos.y + 1
  ActorHelper:setMyPosition(projectile.objid, dstPos)
  ActorHelper:setLookAtFaceYaw(projectile.objid, objid, -70)
end

-- 清除环绕飞剑
function SkillHelper:clearHuitian (objid)
  local projectiles = self.huitianData[objid]
  if (projectiles) then
    for i, v in ipairs(projectiles) do
      if (v.flag == 0) then
        WorldHelper:despawnActor(v.objid)
      end
    end
  end
  self.huitianData[objid] = {}
  return self.huitianData[objid]
end