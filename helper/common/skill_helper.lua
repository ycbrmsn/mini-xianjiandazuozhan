-- 技能工具类
SkillHelper = {
  FLY_DOWN_SPEED = -0.02,
  flyData = {}, -- { objid -> { state = state, flySwordId = flySwordId, position = pos, speed = 0 } }
  huitianData = {}, -- { objid -> {} }
  airArmourData = {
    bodyEffect = BaseConstant.BODY_EFFECT.LIGHT64
  }
}

function SkillHelper:getItem (item, weaponName)
  if (not(item)) then
    item = ItemHelper:getItem(MyWeaponAttr[weaponName].levelIds[1])
  elseif (type(item) == 'number') then
    item = ItemHelper:getItem(MyWeaponAttr[weaponName].levelIds[item + 1])
  end
  return item
end

-- 囚禁actor，用于慑魂枪效果
function SkillHelper:imprisonActor (objid)
  ActorHelper:playBodyEffect(objid, BaseConstant.BODY_EFFECT.LIGHT22)
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
    ActorHelper:stopBodyEffectById(objid, BaseConstant.BODY_EFFECT.LIGHT22)
  end
end

-- 封魔actor
function SkillHelper:sealActor (objid)
  ActorHelper:playBodyEffect(objid, BaseConstant.BODY_EFFECT.LIGHT47)
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
    ActorHelper:stopBodyEffectById(objid, BaseConstant.BODY_EFFECT.LIGHT47)
  end
end

-- 获取御剑状态（-1：御剑失控；0：可御剑；1：御剑静止；2：御剑前行）
function SkillHelper:getFlyState (objid)
  local flyData = self.flyData[objid]
  if (not(flyData)) then
    self.flyData[objid] = { speed = 0, state = 0 }
  end
  return self.flyData[objid].state
end

-- 设置御剑状态
function SkillHelper:setFlyState (objid, state)
  local flyData = self.flyData[objid]
  if (not(flyData)) then
    self.flyData[objid] = { speed = 0 }
  end
  self.flyData[objid].state = state
end

-- 是否在御剑
function SkillHelper:isFlying (objid)
  local flyType = objid .. 'fly'
  return TimeHelper:isFnContinueRuns(flyType), flyType
end

-- 是否在御剑前行
function SkillHelper:isFlyingAdvance (objid)
  local flyAdvanceType = objid .. 'flyAdvance'
  return TimeHelper:isFnContinueRuns(flyAdvanceType), flyAdvanceType
end

-- 御剑静止
function SkillHelper:flyStatic (objid)
  local pos = ActorHelper:getMyPosition(objid)
  if (not(ActorHelper:isInAir(objid))) then -- 不在空中
    pos.y = pos.y + 2
    ActorHelper:setMyPosition(objid, pos)
  end
  -- ActorHelper:setFaceYaw(objid, ActorHelper:getFaceYaw(objid))
  if (not(self.flyData[objid])) then
    self.flyData[objid] = { speed = 0 }
  end
  local flySwordId
  if (not(self.flyData[objid].flySwordId)) then
    flySwordId = WorldHelper:spawnProjectileByDirPos(objid, MyWeaponAttr.controlSword.projectileid, pos, pos, 0)
    self.flyData[objid].flySwordId = flySwordId
  end
  local isFlying, flyType = self:isFlying(objid)
  local isFlyingAdvance, flyAdvanceType = self:isFlyingAdvance(objid)
  if (not(isFlying)) then -- 如果没有飞，则飞起来
    local idx = 1
    -- local staticIndex, notMoveIndex = 1, 1
    ActorHelper:addBuff(objid, MyMap.BUFF.FLY_STYLE, 1, 0) -- 泡泡包裹
    ActorHelper:stopBodyEffectById(objid, BaseConstant.BODY_EFFECT.PARTICLE18) -- 去掉特效
    TimeHelper:callFnContinueRuns(function ()
      -- local state = self:getFlyState(objid)
      -- if (state ~= 1) then
      --   staticIndex, notMoveIndex = 1, 1
      -- end
      ActorHelper:appendSpeed(objid, 0, self.FLY_DOWN_SPEED, 0)
      -- ActorHelper:appendSpeed(objid, 0, self.FLY_DOWN_SPEED + 0.01, 0)
      local p = ActorHelper:getMyPosition(objid) -- 角色位置
      local faceYaw = ActorHelper:getFaceYaw(objid)
      -- local facePitch = ActorHelper:getFacePitch(objid)

      -- if (state == 1 and PlayerHelper:getHostPlayer().objid ~= objid) then -- 非房主御剑静止
      --   -- 处理多人游戏下玩家飞行抖动
      --   if (staticIndex == 1) then -- 刚进入御剑静止状态
      --     self.flyData[objid].positions = { p, p }
      --     -- BlockHelper:placeAirBlock(MyPosition:new(p.x, p.y - 1, p.z))
      --   else
      --     local diff1 = self.flyData[objid].positions[1].y - p.y -- 与初始的高度差
      --     local diff2 = self.flyData[objid].positions[2].y - p.y -- 与上个位置的高度差
      --     if (diff1 ~= 0) then -- 位置变化了
      --       p.y = self.flyData[objid].positions[1].y
      --       ActorHelper:setMyPosition(objid, p)
      --       ActorHelper:setFaceYaw(objid, faceYaw)
      --       ActorHelper:setFacePitch(objid, facePitch)
      --       self.flyData[objid].speed = self.flyData[objid].speed + diff1 / 1000
      --       -- LogHelper:debug('handle', math.floor(self.flyData[objid].speed * 1000))
      --     end
      --     self.flyData[objid].positions[2] = p
      --   end
        
      --   -- LogHelper:debug(notMoveIndex)
      --   staticIndex = staticIndex + 1
      -- end
      -- LogHelper:debug(p.y)

      local swordPos = ActorHelper:getMyPosition(flySwordId) -- 御仙剑位置
      if (swordPos) then -- 如果御仙剑还在脚下
        ActorHelper:setMyPosition(flySwordId, p.x, p.y - 0.1, p.z)
        ActorHelper:setFaceYaw(flySwordId, faceYaw)

        -- 每15秒(300/20)随意更新一条数据，用于使御仙剑队伍信息不会被删除
        if (idx % 300 == 0) then
          ItemHelper:recordMissile(flySwordId, 'objid', flySwordId)
        end
        idx = idx + 1
      end
    end, -1, flyType)
  end
  if (isFlyingAdvance) then -- 如果在向前飞，则停止
    TimeHelper:delFnContinueRuns(flyAdvanceType)
  end
  self:setFlyState(objid, 1)
end

-- 御剑前行
function SkillHelper:flyAdvance (objid)
  local isFlying, flyType = self:isFlying(objid)
  local isFlyingAdvance, flyAdvanceType = self:isFlyingAdvance(objid)
  if (not(isFlying)) then -- 如果没有飞，则飞起来
    TimeHelper:callFnContinueRuns(function ()
      ActorHelper:appendSpeed(objid, 0, self.FLY_DOWN_SPEED, 0)
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

-- 停止御剑
function SkillHelper:stopFly (objid, item)
  local state = self:getFlyState(objid)
  if (state == 0 or state == -1) then -- 未飞行或已失控
    return
  end
  if (item) then -- 失控
    item = SkillHelper:getItem(item, 'controlSword')
    ItemHelper:recordUseSkill(objid, item.id, MyWeaponAttr.controlSword.cd)
  end
  ActorHelper:removeBuff(objid, MyMap.BUFF.FLY_STYLE)
  TimeHelper:delFnContinueRuns(objid .. 'fly')
  if (state == 1) then -- 静止
  elseif (state == 2) then -- 前行
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

-- 万剑诀起势 对象、道具（或道具等级）、目标位置、有效范围半边长
function SkillHelper:tenThousandsSwordcraft (objid, item, dstPos, size)
  item = SkillHelper:getItem(item, 'tenThousandsSword')
  dstPos = dstPos or ActorHelper:getDistancePosition(objid, 6)
  size = size or (item.size + item.level * item.addSizePerLevel)
  local pos = ActorHelper:getDistancePosition(objid, 2)
  pos.y = pos.y + 1
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
        -- 一秒后销毁飞剑
        TimeHelper:callFnFastRuns(function ()
          WorldHelper:despawnActor(projectileid)
        end, 1)
      else
        ActorHelper:turnFacePitch(projectileid, 45)
      end
    end
  end, -1, t)
  -- 两秒后飞剑落下
  TimeHelper:callFnFastRuns(function ()
    SkillHelper:tenThousandsSwordcraft2(objid, item, dstPos, size)
  end, 2)
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
        if (pos) then -- 飞剑存在，则搜索飞剑周围目标
          local objids = ActorHelper:getAllCreaturesArroundPos(pos, dim, objid)
          if (not(objids) or #objids == 0) then
            objids = ActorHelper:getAllPlayersArroundPos(pos, dim, objid)
          end
          objids = ActorHelper:getAliveActors(objids)
          if (objids and #objids > 0) then -- 如果发现目标则跟踪目标
            local targetObjid = ActorHelper:getNearestActor(objids, pos) -- 最近的目标
            ActorHelper:appendSpeed(v[2], -v[3].x, -v[3].y, -v[3].z)
            local speedVector3 = ActorHelper:appendFixedSpeed(v[2], 1, pos, 
              ActorHelper:getMyPosition(targetObjid))
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
  local idx = 1
  ActorHelper:playBodyEffect(objid, self.airArmourData.bodyEffect)
  local t = objid .. 'airArmour'
  TimeHelper:callFnContinueRuns(function ()
    local pos = ActorHelper:getMyPosition(objid)
    pos.y = pos.y + 1
    local missiles
    if (teamid == 0) then -- 无队伍情况下获取所有投掷物
      missiles = ActorHelper:getAllMissilesArroundPos(pos, dim)
    else -- 有队伍情况下获取其他队伍的投掷物
      missiles = ActorHelper:getAllMissilesArroundPos(pos, dim, objid, false)
    end
    -- LogHelper:debug('idx', idx, ': ', #missiles)
    idx = idx + 1
    if (missiles and #missiles > 0) then
      for i, v in ipairs(missiles) do
        local itemid = ItemHelper:getItemId(v)
        if (itemid == MyWeaponAttr.controlSword.projectileid) then -- 御仙剑不作处理
        elseif (itemid == MyWeaponAttr.huixianSword.projectileid 
          and ItemHelper:getMissileTeam(v) == -1) then -- 找不到队伍信息的回仙剑不作处理
        else
          local missilePos = ActorHelper:getMyPosition(v)
          if (missilePos) then
            local distance = MathHelper:getDistance(pos, missilePos)
            if (distance < size) then
              WorldHelper:despawnActor(v)
              local projectileid = WorldHelper:spawnProjectileByDirPos(objid, itemid, missilePos, missilePos, 0)
              local sv3 = ActorHelper:appendFixedSpeed(projectileid, 0.8, pos)
              ItemHelper:recordMissileSpeed(projectileid, sv3)
              ActorHelper:addGravity(projectileid)
            end
          end
        end
      end
    end
  end, -1, t)
  TimeHelper:callFnFastRuns(function ()
    SkillHelper:stopAirArmour(objid)
  end, time)
end

-- 停止气甲术
function SkillHelper:stopAirArmour (objid)
  TimeHelper:delFnContinueRuns(objid .. 'airArmour')
  ActorHelper:stopBodyEffectById(objid, self.airArmourData.bodyEffect)
end

-- 回天 对象、道具（或道具等级）、飞剑数量、有效范围、角度改变、飞剑距离
function SkillHelper:huitian (objid, item, num, size, changeAngle, distance)
  item = SkillHelper:getItem(item, 'huixianSword')
  num = num or (item.num + item.level * item.addNumPerLevel)
  size = size or (item.size + item.level * item.addSizePerLevel)
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
    -- 查询生物周围是否有目标
    local objids = ActorHelper:getAllCreaturesArroundPos(objPos, dim, objid)
    if (not(objids) or #objids == 0) then
      objids = ActorHelper:getAllPlayersArroundPos(objPos, dim, objid)
    end
    objids = ActorHelper:getAliveActors(objids)
    local targetObjid, targetPos
    if (objids and #objids > 0) then -- 发现目标
      targetObjid = ActorHelper:getNearestActor(objids, objPos) -- 取最近目标
      targetPos = ActorHelper:getMyPosition(targetObjid)
    end
    for i, v in ipairs(projectiles) do
      local p = ActorHelper:getMyPosition(v.objid)
      if (not(p)) then -- 找不到飞剑则标记状态为2
        v.flag = 2
      else
        if (targetObjid) then -- 发现目标
          if (v.flag == 0) then -- 环绕状态
            -- 判断玩家怪与玩家飞剑之间的夹角是否小于一定度数
            local angle = MathHelper:getTwoVector2Angle(targetPos.x - objPos.x, 
              targetPos.z - objPos.z, p.x - objPos.x, p.z - objPos.z)
            if (angle <= 120) then -- 小于等于120度飞剑出击
              v.flag = 1
              local sv3 = ActorHelper:appendFixedSpeed(v.objid, 0.8, p, ActorHelper:getMyPosition(targetObjid))
              ItemHelper:recordMissileSpeed(v.objid, sv3)
            else
              SkillHelper:huitianCircle(objid, distance, v, changeAngle)
            end
          else -- 追击状态
            local speedVector3 = ItemHelper:getMissileSpeed(v.objid)
            if (speedVector3) then
              ActorHelper:appendSpeed(v.objid, -speedVector3.x, -speedVector3.y, -speedVector3.z)
            end
            local sv3 = ActorHelper:appendFixedSpeed(v.objid, 0.8, p, ActorHelper:getMyPosition(targetObjid))
            ItemHelper:recordMissileSpeed(v.objid, sv3)
          end
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

-- 更新回天剑的环绕位置
function SkillHelper:huitianCircle (objid, distance, projectile, changeAngle)
  projectile.angle = projectile.angle + changeAngle
  local dstPos = ActorHelper:getFixedDistancePosition(objid, distance, projectile.angle)
  dstPos.y = dstPos.y + 1
  ActorHelper:setMyPosition(projectile.objid, dstPos)
  ActorHelper:setLookAtFaceYaw(projectile.objid, objid, -70)
  -- 随便更新一条数据，用于使飞剑队伍信息不会被删除
  if (projectile.angle % 1000 == 0) then
    ItemHelper:recordMissile(projectile.objid, 'objid', projectile.objid)
  end
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
    TimeHelper:delFnContinueRuns(objid .. 'huitian')
  end
  self.huitianData[objid] = {}
  return self.huitianData[objid]
end

-- 是否有回天剑环绕
function SkillHelper:hasHuitianCircle (objid)
  local projectiles = self.huitianData[objid]
  if (projectiles) then
    for i, v in ipairs(projectiles) do
      if (v.flag == 0) then
        return true
      end
    end
  end
  return false
end