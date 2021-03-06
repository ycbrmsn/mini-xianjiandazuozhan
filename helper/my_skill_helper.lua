-- 我的技能工具类
MySkillHelper = {
  huitianData = {}, -- { objid -> {} }
  airArmourData = {
    bodyEffect = BaseConstant.BODY_EFFECT.LIGHT64
  },
  shunData = {}, -- { objid -> {} }
  qiuData = {}, -- { objid -> pos }
}

-- 囚禁actor，用于慑魂枪效果
function MySkillHelper.imprisonActor (objid)
  ActorHelper.playBodyEffect(objid, BaseConstant.BODY_EFFECT.LIGHT22)
  if (ActorHelper.isPlayer(objid)) then -- 玩家
    local player = PlayerHelper.getPlayer(objid)
    player:setImprisoned(true)
  else
    local actor = ActorHelper.getActor(objid)
    if (actor) then
      actor:setImprisoned(true)
    else
      MonsterHelper.imprisonMonster(objid)
    end
  end
end

-- 取消囚禁actor
function MySkillHelper.cancelImprisonActor (objid)
  local canCancel
  if (ActorHelper.isPlayer(objid)) then -- 玩家
    local player = PlayerHelper.getPlayer(objid)
    canCancel = player:setImprisoned(false)
  else
    local actor = ActorHelper.getActor(objid)
    if (actor) then
      canCancel = actor:setImprisoned(false)
    else
      canCancel = MonsterHelper.cancelImprisonMonster(objid)
    end
  end
  if (canCancel) then
    ActorHelper.stopBodyEffectById(objid, BaseConstant.BODY_EFFECT.LIGHT22)
  end
end

-- 封魔actor
function MySkillHelper.sealActor (objid)
  ActorHelper.playBodyEffect(objid, BaseConstant.BODY_EFFECT.LIGHT47)
  if (ActorHelper.isPlayer(objid)) then -- 玩家
    local player = PlayerHelper.getPlayer(objid)
    player:setSeal(true)
  else
    local actor = ActorHelper.getActor(objid)
    if (actor) then
      actor:setSealed(true)
    else
      MonsterHelper.sealMonster(objid)
    end
  end
end

-- 取消封魔actor
function MySkillHelper.cancelSealActor (objid)
  local canCancel
  if (ActorHelper.isPlayer(objid)) then -- 玩家
    local player = PlayerHelper.getPlayer(objid)
    canCancel = player:setSeal(false)
  else
    local actor = ActorHelper.getActor(objid)
    if (actor) then
      canCancel = actor:setSealed(false)
    else
      canCancel = MonsterHelper.cancelSealMonster(objid)
    end
  end
  if (canCancel) then
    ActorHelper.stopBodyEffectById(objid, BaseConstant.BODY_EFFECT.LIGHT47)
  end
end

-- 万剑诀起势 对象、道具（或道具等级）、目标位置、有效范围半边长
function MySkillHelper.tenThousandsSwordcraft (objid, item, dstPos, size)
  item = SkillHelper.getItem(item, 'tenThousandsSword')
  dstPos = dstPos or ActorHelper.getDistancePosition(objid, 6)
  size = size or (item.size + item.level * item.addSizePerLevel)
  local pos = ActorHelper.getDistancePosition(objid, 2)
  pos.y = pos.y + 1
  local projectileid = WorldHelper.spawnProjectileByDirPos(objid, 
    item.projectileid, pos, pos, 0)
  ActorHelper.setFacePitch(projectileid, -135)
  ActorHelper.setFaceYaw(projectileid, ActorHelper.getFaceYaw(objid) + 90)
  local t = 'ten' .. projectileid
  -- 旋转一圈起飞
  TimeHelper.callFnContinueRuns(function ()
    local facePitch = ActorHelper.getFacePitch(projectileid)
    if (not(facePitch)) then
      TimeHelper.delFnContinueRuns(t)
    else
      if (facePitch >= 270) then
        ActorHelper.appendSpeed(projectileid, 0, 1, 0)
        TimeHelper.delFnContinueRuns(t)
        -- 一秒后销毁飞剑
        TimeHelper.callFnFastRuns(function ()
          CacheHelper.despawnActor(projectileid)
        end, 1)
      else
        ActorHelper.turnFacePitch(projectileid, 45)
      end
    end
  end, -1, t)
  -- 两秒后飞剑落下
  TimeHelper.callFnFastRuns(function ()
    MySkillHelper.tenThousandsSwordcraft2(objid, item, dstPos, size)
  end, 2)
end

-- 万剑诀 落势
function MySkillHelper.tenThousandsSwordcraft2 (objid, item, dstPos, size)
  local y = dstPos.y + 20
  local arr, projectiles = {}, {}
  for i = dstPos.x - size, dstPos.x + size do
    for ii = dstPos.z - size, dstPos.z + size do
      table.insert(arr, MyPosition:new(i, y, ii))
    end
  end
  MySkillHelper.tenThousandsSwordcraft3(objid, item, arr, projectiles)
  local dim = MyPosition:new(5, 10, 5)
  TimeHelper.callFnContinueRuns(function ()
    for i, v in ipairs(projectiles) do
      if (v[1]) then
        local pos = CacheHelper.getMyPosition(v[2])
        if (pos) then -- 飞剑存在，则搜索飞剑周围目标
          if (pos:equals(v[4])) then -- 位置没变
            v[5] = (v[5] or 0) + 1
            if (v[5] > 20) then
              v[1] = false
              TimeHelper.callFnFastRuns(function ()
                CacheHelper.despawnActor(v[2])
              end, 3)
            end
          else -- 位置变化
            v[4] = pos
            v[5] = 0
          end
          local objids = ActorHelper.getAllCreaturesArroundPos(pos, dim, objid)
          if (not(objids) or #objids == 0) then
            objids = ActorHelper.getAllPlayersArroundPos(pos, dim, objid)
          end
          objids = ActorHelper.getAliveActors(objids)
          if (objids and #objids > 0) then -- 如果发现目标则跟踪目标
            local targetObjid = ActorHelper.getNearestActor(objids, pos) -- 最近的目标
            ActorHelper.appendSpeed(v[2], -v[3].x, -v[3].y, -v[3].z)
            local speedVector3 = ActorHelper.appendFixedSpeed(v[2], 1, pos, 
              CacheHelper.getMyPosition(targetObjid))
            v[3] = speedVector3
            ItemHelper.recordMissileSpeed(v[2], speedVector3)
          end
        else
          v[1] = false
        end
      end
    end
  end, 5)
end

function MySkillHelper.tenThousandsSwordcraft3 (objid, item, arr, projectiles)
  if (#arr > 0) then
    local index = math.random(1, #arr)
    local speedVector3 = MyVector3:new(0, -0.8, 0)
    local projectileid = WorldHelper.spawnProjectileByDirPos(objid, 
      item.projectileid, arr[index], speedVector3, 0)
    ActorHelper.appendSpeed(projectileid, speedVector3.x, speedVector3.y, speedVector3.z)
    table.insert(projectiles, { true, projectileid, speedVector3, arr[index], 0 }) -- 是否存在、id、速度、位置，不动次数
    table.remove(arr, index)
    ItemHelper.recordProjectile(projectileid, objid, item, {})
    ItemHelper.recordMissileSpeed(projectileid, speedVector3)
    TimeHelper.callFnFastRuns(function ()
      MySkillHelper.tenThousandsSwordcraft3(objid, item, arr, projectiles)
    end, 0.1)
  end
end

-- 气甲术 对象、范围大小、持续时间
function MySkillHelper.airArmour (objid, size, time)
  size = size or 3
  time = time or 5
  local dim = { x = size + 1, y = size + 1, z = size + 1 }
  local teamid = ActorHelper.getTeam(objid)
  local idx = 1
  ActorHelper.playBodyEffect(objid, MySkillHelper.airArmourData.bodyEffect)
  local t = objid .. 'airArmour'
  TimeHelper.callFnContinueRuns(function ()
    local pos = CacheHelper.getMyPosition(objid)
    pos.y = pos.y + 1
    local missiles
    if (teamid == 0) then -- 无队伍情况下获取所有投掷物
      missiles = ActorHelper.getAllMissilesArroundPos(pos, dim)
    else -- 有队伍情况下获取其他队伍的投掷物
      missiles = ActorHelper.getAllMissilesArroundPos(pos, dim, objid, false)
    end
    -- LogHelper.debug('idx', idx, ': ', #missiles)
    idx = idx + 1
    if (missiles and #missiles > 0) then
      for i, v in ipairs(missiles) do
        local itemid = ItemHelper.getItemId(v)
        if (itemid == MyWeaponAttr.controlSword.projectileid) then -- 御仙剑不作处理
        elseif (itemid == MyWeaponAttr.shunSword.projectileid) then -- 瞬仙剑不作处理
        elseif (itemid == MyWeaponAttr.huixianSword.projectileid 
          and ItemHelper.getMissileTeam(v) == -1) then -- 找不到队伍信息的回仙剑不作处理
        elseif (itemid == MyWeaponAttr.fengSword.projectileid
          and ItemHelper.getMissileTeam(v) == -1) then -- 找不到队伍信息的封仙剑不作处理
        else
          local missilePos = CacheHelper.getMyPosition(v)
          if (missilePos) then
            local distance = MathHelper.getDistance(pos, missilePos)
            if (distance < size) then
              CacheHelper.despawnActor(v)
              local projectileid = WorldHelper.spawnProjectileByDirPos(objid, itemid, missilePos, missilePos, 0)
              local sv3 = ActorHelper.appendFixedSpeed(projectileid, 0.8, pos)
              ItemHelper.recordMissileSpeed(projectileid, sv3)
              ActorHelper.addGravity({ objid = projectileid, pos = pos, index = 0 })
            end
          end
        end
      end
    end
  end, -1, t)
  TimeHelper.callFnFastRuns(function ()
    MySkillHelper.stopAirArmour(objid)
  end, time)
end

-- 停止气甲术
function MySkillHelper.stopAirArmour (objid)
  TimeHelper.delFnContinueRuns(objid .. 'airArmour')
  ActorHelper.stopBodyEffectById(objid, MySkillHelper.airArmourData.bodyEffect)
end

-- 回天 对象、道具（或道具等级）、飞剑数量、有效范围、角度改变、飞剑距离
function MySkillHelper.huitian (objid, item, num, size, changeAngle, distance)
  item = SkillHelper.getItem(item, 'huixianSword')
  num = num or (item.num + item.level * item.addNumPerLevel)
  size = size or (item.size + item.level * item.addSizePerLevel)
  changeAngle = changeAngle or 5
  distance = distance or 2
  local dim = { x = size, y = size, z = size }
  local projectiles = MySkillHelper.clearHuitian(objid)
  for i = 1, num do
    local angle = 360 / num * i
    local pos = ActorHelper.getFixedDistancePosition(objid, distance, angle)
    pos.y = pos.y + 1
    local projectileid = WorldHelper.spawnProjectileByDirPos(objid, 
      item.projectileid, pos, pos, 0)
    ItemHelper.recordProjectile(projectileid, objid, item, {})
    table.insert(projectiles, { flag = 0, objid = projectileid, angle = angle, pos = pos, index = 0 })
  end
  local t = objid .. 'huitian'
  TimeHelper.callFnContinueRuns(function ()
    local num = 0
    local objPos = CacheHelper.getMyPosition(objid)
    -- 查询生物周围是否有目标
    local objids = ActorHelper.getAllCreaturesArroundPos(objPos, dim, objid)
    objids = ActorHelper.getHasTargetActors(objids)
    if (not(objids) or #objids == 0) then
      objids = ActorHelper.getAllPlayersArroundPos(objPos, dim, objid)
    end
    objids = ActorHelper.getAliveActors(objids)
    local targetObjid, targetPos
    if (objids and #objids > 0) then -- 发现目标
      targetObjid = ActorHelper.getNearestActor(objids, objPos) -- 取最近目标
      targetPos = CacheHelper.getMyPosition(targetObjid)
    end
    for i, v in ipairs(projectiles) do
      local p = CacheHelper.getMyPosition(v.objid)
      if (not(p)) then -- 找不到飞剑则标记状态为2
        v.flag = 2
      else
        if (targetObjid) then -- 发现目标
          if (v.flag == 0) then -- 环绕状态
            -- 判断玩家怪与玩家飞剑之间的夹角是否小于一定度数
            local angle = MathHelper.getTwoVector2Angle(targetPos.x - objPos.x, 
              targetPos.z - objPos.z, p.x - objPos.x, p.z - objPos.z)
            if (angle <= 120) then -- 小于等于120度飞剑出击
              v.flag = 1
              local sv3 = ActorHelper.appendFixedSpeed(v.objid, 0.8, p, CacheHelper.getMyPosition(targetObjid))
              ItemHelper.recordMissileSpeed(v.objid, sv3)
            else
              MySkillHelper.huitianCircle(objid, distance, v, changeAngle)
            end
          else -- 追击状态
            if (p:equals(v.pos)) then -- 没有动
              v.index = (v.index or 0) + 1
              if (v.index > 20) then
                v.flag = 2
                TimeHelper.callFnFastRuns(function ()
                  CacheHelper.despawnActor(v.objid)
                end, 3)
              end
            else
              v.pos = p
              v.index = 0
              local speedVector3 = ItemHelper.getMissileSpeed(v.objid)
              if (speedVector3) then
                ActorHelper.appendSpeed(v.objid, -speedVector3.x, -speedVector3.y, -speedVector3.z)
              end
              local sv3 = ActorHelper.appendFixedSpeed(v.objid, 0.8, p,
                ActorHelper.getEyeHeightPosition(targetObjid))
              ItemHelper.recordMissileSpeed(v.objid, sv3)
            end
          end
        else -- 未发现目标，追击状态不处理
          if (v.flag == 0) then -- 环绕状态
            MySkillHelper.huitianCircle(objid, distance, v, changeAngle)
          end
        end
        num = num + 1
      end
    end
    if (num == 0) then -- 飞剑皆毁
      TimeHelper.delFnContinueRuns(t)
    end
  end, -1, t)
end

-- 更新回天剑的环绕位置
function MySkillHelper.huitianCircle (objid, distance, projectile, changeAngle)
  projectile.angle = projectile.angle + changeAngle
  local dstPos = ActorHelper.getFixedDistancePosition(objid, distance, projectile.angle)
  dstPos.y = dstPos.y + 1
  ActorHelper.setMyPosition(projectile.objid, dstPos)
  ActorHelper.setLookAtFaceYaw(projectile.objid, objid, -70)
  -- 随便更新一条数据，用于使飞剑队伍信息不会被删除
  if (projectile.angle % 1000 == 0) then
    ItemHelper.recordMissile(projectile.objid, 'objid', projectile.objid)
  end
end

-- 清除环绕飞剑
function MySkillHelper.clearHuitian (objid)
  local projectiles = MySkillHelper.huitianData[objid]
  if (projectiles and #projectiles > 0) then
    for i, v in ipairs(projectiles) do
      if (v.flag == 0) then
        CacheHelper.despawnActor(v.objid)
      end
    end
    TimeHelper.delFnContinueRuns(objid .. 'huitian')
  end
  MySkillHelper.huitianData[objid] = {}
  return MySkillHelper.huitianData[objid]
end

-- 是否有回天剑环绕
function MySkillHelper.hasHuitianCircle (objid)
  local projectiles = MySkillHelper.huitianData[objid]
  if (projectiles) then
    for i, v in ipairs(projectiles) do
      if (v.flag == 0) then
        return true
      end
    end
  end
  return false
end

-- 乱剑诀
function MySkillHelper.luanJianJue (objid, item, dstPos, num)
  item = SkillHelper.getItem(item, 'luanSword')
  dstPos = dstPos or ActorHelper.getFaceDistancePosition(objid, 6)
  dstPos.x = math.floor(dstPos.x) + 0.5
  dstPos.y = math.floor(dstPos.y) + 0.3
  dstPos.z = math.floor(dstPos.z) + 0.5
  num = num or (item.num + item.level * item.addNumPerLevel)
  -- local pos = ActorHelper.getDistancePosition(objid, 3)
  WorldHelper.playAndStopBodyEffectById(dstPos, BaseConstant.BODY_EFFECT.LIGHT34, 1, 2)
  TimeHelper.callFnFastRuns(function ()
    WorldHelper.playBodyEffect(dstPos, BaseConstant.BODY_EFFECT.LIGHT40)
  end, 1.5)
  -- -- 两秒后飞剑落下
  TimeHelper.callFnFastRuns(function ()
    MySkillHelper.luanJianJue2(objid, item, dstPos, num)
  end, 2)
end

function MySkillHelper.luanJianJue2 (objid, item, dstPos, num)
  local y = dstPos.y + 20
  local arr, projectiles = {}, {}
  for i = 1, num do
    table.insert(arr, dstPos)
  end
  MySkillHelper.luanJianJue3(objid, item, arr, projectiles)
  local dim = MyPosition:new(5, 10, 5)
  TimeHelper.callFnContinueRuns(function ()
    for i, v in ipairs(projectiles) do
      if (v[1]) then
        local pos = CacheHelper.getMyPosition(v[2])
        if (pos) then -- 飞剑存在，则搜索飞剑周围目标
          if (pos:equals(v[4])) then -- 位置没变
            v[5] = (v[5] or 0) + 1
            if (v[5] > 20) then
              v[1] = false
              TimeHelper.callFnFastRuns(function ()
                CacheHelper.despawnActor(v[2])
              end, 3)
            end
          else -- 位置变化
            v[4] = pos
            v[5] = 0
          end
          local objids = ActorHelper.getAllCreaturesArroundPos(pos, dim, objid)
          if (not(objids) or #objids == 0) then
            objids = ActorHelper.getAllPlayersArroundPos(pos, dim, objid)
          end
          objids = ActorHelper.getAliveActors(objids)
          if (objids and #objids > 0) then -- 如果发现目标则跟踪目标
            local targetObjid = ActorHelper.getNearestActor(objids, pos) -- 最近的目标
            ActorHelper.appendSpeed(v[2], -v[3].x, -v[3].y, -v[3].z)
            local speedVector3 = ActorHelper.appendFixedSpeed(v[2], 1, pos, 
              CacheHelper.getMyPosition(targetObjid))
            v[3] = speedVector3
            ItemHelper.recordMissileSpeed(v[2], speedVector3)
          end
        else
          v[1] = false
        end
      end
    end
  end, 5)
end

function MySkillHelper.luanJianJue3 (objid, item, arr, projectiles)
  if (#arr > 0) then
    if (#arr == 1) then
      WorldHelper.stopBodyEffect(arr[1], BaseConstant.BODY_EFFECT.LIGHT40)
    end
    local speedVector3 = MathHelper.getRandomSpeed(0.8)
    local projectileid = WorldHelper.spawnProjectileByDirPos(objid, 
      item.projectileid, arr[1], speedVector3, 0)
    ActorHelper.appendSpeed(projectileid, speedVector3.x, speedVector3.y, speedVector3.z)
    table.insert(projectiles, { true, projectileid, speedVector3, arr[1], 0 }) -- 是否存在、id、速度、位置，不动次数
    table.remove(arr)
    ItemHelper.recordProjectile(projectileid, objid, item, {})
    ItemHelper.recordMissileSpeed(projectileid, speedVector3)
    TimeHelper.callFnFastRuns(function ()
      MySkillHelper.luanJianJue3(objid, item, arr, projectiles)
    end, 0.1)
  end
end

-- 瞬仙剑分身是否存在
function MySkillHelper.shunExists (objid)
  local data = MySkillHelper.getShunData(objid)
  return data.projectileid and CacheHelper.getMyPosition(data.projectileid)
end

function MySkillHelper.getShunData (objid)
  local data = MySkillHelper.shunData[objid]
  if (not(data)) then
    data = {}
    MySkillHelper.shunData[objid] = data
  end
  return data
end

-- 瞬移术
function MySkillHelper.shunyi (objid, item, dstPos)
  item = SkillHelper.getItem(item, 'shunSword')
  local data = MySkillHelper.getShunData(objid)
  local player = PlayerHelper.getPlayer(objid)
  if (data.projectileid) then
    local pos = CacheHelper.getMyPosition(data.projectileid)
    if (pos) then
      if (player:setMyPosition(pos)) then
        CacheHelper.despawnActor(data.projectileid)
        ItemHelper.recordUseSkill(objid, item.id, item.cd)
      end
    end
  else
    local pos = ActorHelper.getEyeHeightPosition(objid)
    if (not(dstPos)) then
      if (ActorHelper.isPlayer(objid)) then -- 玩家
        dstPos = player:getAimPos(objid)
      else
        dstPos = ActorHelper.getFaceDistancePosition(objid, 20)
      end
    end
    local projectileid = WorldHelper.spawnProjectileByDirPos(objid, 
      item.projectileid, pos, pos, 0)
    data.projectileid = projectileid -- 记录剑分身
    local speedVector3 = ActorHelper.appendFixedSpeed(projectileid, 0.8, pos, dstPos)
    ItemHelper.recordMissileSpeed(projectileid, speedVector3)
    local existTime = item.existTime + item.level * item.addExistTimePerLevel
    PlayerHelper.setSkillCD(objid, item.id, existTime)
    -- 时间到删除剑分身
    TimeHelper.callFnFastRuns(function ()
      local pos = CacheHelper.getMyPosition(data.projectileid)
      if (pos) then
        CacheHelper.despawnActor(data.projectileid)
      end
      data.projectileid = nil
    end, existTime)
  end
end

-- 使用囚仙剑
function MySkillHelper.useQiuSword (objid, item)
  item = SkillHelper.getItem(item, 'qiuSword')
  local toobjid = MySkillHelper.searchQiuEmeny(objid, item)
  if (toobjid) then
    local pos = CacheHelper.getMyPosition(toobjid)
    if (pos) then
      ActorHelper.playAndStopBodyEffectById(toobjid, BaseConstant.BODY_EFFECT.LIGHT31)
      TimeHelper.callFnFastRuns(function ()
        pos = CacheHelper.getMyPosition(toobjid)
        if (pos) then
          local fixPos
          if (BlockHelper.isArroundFloor(pos)) then -- 在地上则位置上移两格
            pos.y = pos.y + 2
            fixPos = MyPosition:new(pos.x, pos.y - 1, pos.z)
          else
            fixPos = pos
          end
          MySkillHelper.convergeCage(pos, item, fixPos, toobjid)
        end
      end, 1)
      return true
    end
  end
  return false
end

-- 囚仙剑搜索敌人
function MySkillHelper.searchQiuEmeny (objid, item)
  local distance = item.distance + item.level * item.addDistancePerLevel
  local player = PlayerHelper.getPlayer(objid)
  local pos = player:getMyPosition()
  local dim = { x = distance, y = distance, z = distance }
  local objids = ActorHelper.getAllPlayersArroundPos(pos, dim, objid, false)
  if (objids and #objids > 0) then -- 找到玩家，则验证位置
    objids = ActorHelper.getFrontAngleActors(objids, objid, 60, true)
  end
  if (not(objids) or #objids == 0) then -- 没找到玩家，则找生物
    objids = ActorHelper.getAllCreaturesArroundPos(pos, dim, objid, false)
    if (objids and #objids > 0) then -- 找到生物，则验证位置
      objids = ActorHelper.getFrontAngleActors(objids, objid, 60, true)
    end
  end
  if (objids and #objids > 0) then
    return objids[1]
  else
    return nil
  end
end

-- 汇聚囚笼
function MySkillHelper.convergeCage (pos, item, fixPos, toobjid)
  local arr = {}
  local len, step = 4, 2
  local x, z = math.floor(pos.x), math.floor(pos.z)
  -- 第一层
  local y = math.floor(pos.y - 2) + 0.5
  -- 四角
  local face = -90
  local ft = -90
  for i = 0, 1 do
    face = face - 90
    ft = ft * -1
    for j = 0, 1 do
      face = face + ft
      local finalPos = MyPosition:new(x - 2 + i * 4 + 0.5, y, z - 2 + j * 4 + 0.5)
      local vc3 = MyVector3:new(pos, finalPos)
      local arr2 = {}
      for k = 0, len, step do
        local dstPos = MyPosition:new(finalPos.x + vc3.x * k, finalPos.y + vc3.y * k, finalPos.z + vc3.z * k)
        table.insert(arr2, dstPos)
      end
      local projectileid = WorldHelper.spawnProjectileByPos(nil, MyMap.ITEM.QIU1, arr2[#arr2], arr2[#arr2], 0)
      ActorHelper.setFaceYaw(projectileid, face)
      ActorHelper.setFacePitch(projectileid, -90)
      table.insert(arr, { id = projectileid, arr = arr2 })
    end
  end
  -- 四边
  face = -180
  ft = 90
  for i = 0, 1 do
    for j = 0, 1 do
      face = face + ft
      for k = 1, 3 do
        local finalPos
        if (j == 0) then
          finalPos = MyPosition:new(x - 2 + k + 0.5, y, z - 2 + i * 4 + 0.5)
        else
          finalPos = MyPosition:new(x - 2 + i * 4 + 0.5, y, z - 2 + k + 0.5)
        end
        local vc3 = MyVector3:new(pos, finalPos)
        local arr2 = {}
        for l = 0, len, step do
          local dstPos = MyPosition:new(finalPos.x + vc3.x * l, finalPos.y + vc3.y * l, finalPos.z + vc3.z * l)
          table.insert(arr2, dstPos)
        end
        local projectileid = WorldHelper.spawnProjectileByPos(nil, MyMap.ITEM.QIU2, arr2[#arr2], arr2[#arr2], 0)
        ActorHelper.setFaceYaw(projectileid, face)
        ActorHelper.setFacePitch(projectileid, -90)
        table.insert(arr, { id = projectileid, arr = arr2 })
      end
    end
  end
  -- 中一层四角
  y = math.floor(pos.y - 2) + 0.3
  face = 90
  ft = -90
  for i = 0, 1 do
    face = face - 90
    ft = ft * -1
    for j = 0, 1 do
      face = face + ft
      local finalPos = MyPosition:new(x - 1 + i * 2 + 0.5, y, z - 1 + j * 2 + 0.5)
      local vc3 = MyVector3:new(pos, finalPos)
      local arr2 = {}
      for k = 0, len, step do
        local dstPos = MyPosition:new(finalPos.x + vc3.x * k, finalPos.y + vc3.y * k, finalPos.z + vc3.z * k)
        table.insert(arr2, dstPos)
      end
      local projectileid = WorldHelper.spawnProjectileByPos(nil, MyMap.ITEM.QIU8, arr2[#arr2], arr2[#arr2], 0)
      ActorHelper.setFaceYaw(projectileid, face)
      ActorHelper.setFacePitch(projectileid, -90)
      table.insert(arr, { id = projectileid, arr = arr2 })
    end
  end
  -- 中一层中
  face = 0
  ft = 90
  for i = 0, 1 do
    for j = 0, 1 do
      face = face + ft
      if (j == 0) then
        finalPos = MyPosition:new(x + 0.5, y, z - 1 + i * 2 + 0.5)
      else
        finalPos = MyPosition:new(x - 1 + i * 2 + 0.5, y, z + 0.5)
      end
      vc3 = MyVector3:new(pos, finalPos)
      arr2 = {}
      for k = 0, len, step do
        local dstPos = MyPosition:new(finalPos.x + vc3.x * k, finalPos.y + vc3.y * k, finalPos.z + vc3.z * k)
        table.insert(arr2, dstPos)
      end
      local projectileid = WorldHelper.spawnProjectileByPos(nil, MyMap.ITEM.QIU7, arr2[#arr2], arr2[#arr2], 0)
      ActorHelper.setFaceYaw(projectileid, face)
      ActorHelper.setFacePitch(projectileid, -90)
      table.insert(arr, { id = projectileid, arr = arr2 })
    end
  end
  -- 中心
  local finalPos = MyPosition:new(x + 0.5, y, z + 0.5)
  local vc3 = MyVector3:new(pos, finalPos)
  local arr2 = {}
  for k = 0, len, step do
    local dstPos = MyPosition:new(finalPos.x + vc3.x * k, finalPos.y + vc3.y * k, finalPos.z + vc3.z * k)
    table.insert(arr2, dstPos)
  end
  local projectileid = WorldHelper.spawnProjectileByPos(nil, MyMap.ITEM.QIU9, arr2[#arr2], arr2[#arr2], 0)
  ActorHelper.setFaceYaw(projectileid, face)
  ActorHelper.setFacePitch(projectileid, -90)
  table.insert(arr, { id = projectileid, arr = arr2 })
  -- 第二三四层
  for i = 1, 3 do
    y = math.floor(pos.y - 2 + i) + 0.5
    -- 四角
    face = -90
    ft = -90
    for j = 0, 1 do
      face = face - 90
      ft = ft * -1
      for k = 0, 1 do
        face = face + ft
        local finalPos = MyPosition:new(x - 2 + j * 4 + 0.65 - 0.3 * j, y,
          z - 2 + k * 4 + 0.65 - 0.3 * k)
        local vc3 = MyVector3:new(pos, finalPos)
        local arr2 = {}
        for l = 0, len, step do
          local dstPos = MyPosition:new(finalPos.x + vc3.x * l, finalPos.y + vc3.y * l, finalPos.z + vc3.z * l)
          table.insert(arr2, dstPos)
        end
        local projectileid = WorldHelper.spawnProjectileByPos(nil, MyMap.ITEM.QIU3, arr2[#arr2], arr2[#arr2], 0)
        ActorHelper.setFaceYaw(projectileid, face)
        ActorHelper.setFacePitch(projectileid, -90)
        table.insert(arr, { id = projectileid, arr = arr2 })
      end
    end
    -- 四边
    face = -180
    ft = 90
    for j = 0, 1 do
      for k = 0, 1 do
        face = face + ft
        for l = 1, 3 do
          local finalPos
          if (k == 0) then
            finalPos = MyPosition:new(x - 2 + l + 0.5, y, z - 2 + j * 4 + 0.5)
          else
            finalPos = MyPosition:new(x - 2 + j * 4 + 0.5, y, z - 2 + l + 0.5)
          end
          local vc3 = MyVector3:new(pos, finalPos)
          local arr2 = {}
          for m = 0, len, step do
            local dstPos = MyPosition:new(finalPos.x + vc3.x * m, finalPos.y + vc3.y * m, finalPos.z + vc3.z * m)
            table.insert(arr2, dstPos)
          end
          local projectileid = WorldHelper.spawnProjectileByPos(nil, MyMap.ITEM.QIU4, arr2[#arr2], arr2[#arr2], 0)
          ActorHelper.setFaceYaw(projectileid, face)
          ActorHelper.setFacePitch(projectileid, -90)
          table.insert(arr, { id = projectileid, arr = arr2 })
        end
      end
    end
  end
  -- 第五层
  y = math.floor(pos.y + 2) + 0.5
  -- 四角
  face = -90
  ft = -90
  for i = 0, 1 do
    face = face - 90
    ft = ft * -1
    for j = 0, 1 do
      face = face + ft
      local finalPos = MyPosition:new(x - 2 + i * 4 + 0.5, y, z - 2 + j * 4 + 0.5)
      local vc3 = MyVector3:new(pos, finalPos)
      local arr2 = {}
      for k = 0, len, step do
        local dstPos = MyPosition:new(finalPos.x + vc3.x * k, finalPos.y + vc3.y * k, finalPos.z + vc3.z * k)
        table.insert(arr2, dstPos)
      end
      local projectileid = WorldHelper.spawnProjectileByPos(nil, MyMap.ITEM.QIU5, arr2[#arr2], arr2[#arr2], 0)
      ActorHelper.setFaceYaw(projectileid, face)
      ActorHelper.setFacePitch(projectileid, -90)
      table.insert(arr, { id = projectileid, arr = arr2 })
    end
  end
  -- 四边
  face = -180
  ft = 90
  for i = 0, 1 do
    for j = 0, 1 do
      face = face + ft
      for k = 1, 3 do
        local finalPos
        if (j == 0) then
          finalPos = MyPosition:new(x - 2 + k + 0.5, y, z - 2 + i * 4 + 0.5)
        else
          finalPos = MyPosition:new(x - 2 + i * 4 + 0.5, y, z - 2 + k + 0.5)
        end
        local vc3 = MyVector3:new(pos, finalPos)
        local arr2 = {}
        for l = 0, len, step do
          local dstPos = MyPosition:new(finalPos.x + vc3.x * l, finalPos.y + vc3.y * l, finalPos.z + vc3.z * l)
          table.insert(arr2, dstPos)
        end
        local projectileid = WorldHelper.spawnProjectileByPos(nil, MyMap.ITEM.QIU6, arr2[#arr2], arr2[#arr2], 0)
        ActorHelper.setFaceYaw(projectileid, face)
        ActorHelper.setFacePitch(projectileid, -90)
        table.insert(arr, { id = projectileid, arr = arr2 })
      end
    end
  end
  -- 中央
  y = y + 0.2
  for i = 0, 2 do
    for j = 0, 2 do
      local finalPos = MyPosition:new(x - 1 + i + 0.5, y, z - 1 + j + 0.5)
      local vc3 = MyVector3:new(pos, finalPos)
      local arr2 = {}
      for k = 0, len, step do
        local dstPos = MyPosition:new(finalPos.x + vc3.x * k, finalPos.y + vc3.y * k, finalPos.z + vc3.z * k)
        table.insert(arr2, dstPos)
      end
      local projectileid = WorldHelper.spawnProjectileByPos(nil, MyMap.ITEM.QIU10, arr2[#arr2], arr2[#arr2], 0)
      ActorHelper.setFaceYaw(projectileid, face)
      ActorHelper.setFacePitch(projectileid, -90)
      table.insert(arr, { id = projectileid, arr = arr2 })
    end
  end
  -- TimeHelper.callFnFastRuns(function ()
    local tmap = {}
    local num = 0
    tmap.t = TimeHelper.callFnContinueRuns(function ()
      -- if (num < #arr) then
        for i = #arr, 1, -1 do
          local v = arr[i]
          local arr2 = v.arr
          if (num < #arr2) then
            ActorHelper.setMyPosition(v.id, arr2[#arr2 - num])
            -- table.remove(arr2)
          else
            TimeHelper.delFnContinueRuns(tmap.t)
            MySkillHelper.constructCage(pos, item, arr)
            ActorHelper.setMyPosition(toobjid, fixPos)
            -- 造成伤害
            ActorHelper.playHurt(toobjid)
            local hurt = item.hurt + item.level * item.addHurtPerLevel
            if (not(ActorHelper.isPlayer(toobjid))) then -- 不是玩家则造成双倍伤害
              hurt = hurt * 2
            end
            if (hurt > 0) then
              ActorHelper.damageActor(objid, toobjid, hurt, item)
            end
            break
            -- TimeHelper.callFnFastRuns(function ()
            --   CacheHelper.despawnActor(v.id)
            -- end, 1)
            -- table.remove(arr)
          end
        end
      -- else
      --   TimeHelper.delFnContinueRuns(tmap.t)
      --   MySkillHelper.constructCage(pos, item, arr)
      -- end
      num = num + 1
    end, -1)
  -- end, 0.2)
end

-- 组装囚笼
function MySkillHelper.constructCage (pos, item, arr)
  local arr2 = {}
  local tempPos
  -- 第一层
  local y = pos.y - 2
  tempPos = MyPosition:new(pos.x - 2, y, pos.z - 2)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU1, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_NEG_Z)) then -- 西南
    table.insert(arr2, tempPos)
  end
  for i = 1, 3 do
    tempPos = MyPosition:new(pos.x - 2 + i, y, pos.z - 2)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU2, tempPos.x, tempPos.y, tempPos.z,
      FACE_DIRECTION.DIR_NEG_Z)) then
      table.insert(arr2, tempPos)
    end
  end
  tempPos = MyPosition:new(pos.x - 2, y, pos.z + 2)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU1, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_NEG_X)) then -- 西北
    table.insert(arr2, tempPos)
  end
  for i = 1, 3 do
    tempPos = MyPosition:new(pos.x - 2, y, pos.z + 2 - i)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU2, tempPos.x, tempPos.y, tempPos.z,
      FACE_DIRECTION.DIR_NEG_X)) then
      table.insert(arr2, tempPos)
    end
  end
  tempPos = MyPosition:new(pos.x + 2, y, pos.z + 2)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU1, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_POS_Z)) then -- 东北
    table.insert(arr2, tempPos)
  end
  for i = 1, 3 do
    tempPos = MyPosition:new(pos.x + 2 - i, y, pos.z + 2)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU2, tempPos.x, tempPos.y, tempPos.z,
      FACE_DIRECTION.DIR_POS_Z)) then
      table.insert(arr2, tempPos)
    end
  end
  tempPos = MyPosition:new(pos.x + 2, y, pos.z - 2)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU1, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_POS_X)) then
    table.insert(arr2, tempPos)
  end -- 东南
  for i = 1, 3 do
    tempPos = MyPosition:new(pos.x + 2, y, pos.z - 2 + i)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU2, tempPos.x, tempPos.y, tempPos.z,
      FACE_DIRECTION.DIR_POS_X)) then
      table.insert(arr2, tempPos)
    end
  end
  tempPos = MyPosition:new(pos.x - 1, y, pos.z)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU7, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_POS_X)) then
    table.insert(arr2, tempPos)
  end -- 中西
  tempPos = MyPosition:new(pos.x - 1, y, pos.z + 1)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU8, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_POS_X)) then
    table.insert(arr2, tempPos)
  end -- 西北
  tempPos = MyPosition:new(pos.x, y, pos.z + 1)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU7, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_NEG_Z)) then
    table.insert(arr2, tempPos)
  end -- 中北
  tempPos = MyPosition:new(pos.x + 1, y, pos.z + 1)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU8, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_NEG_Z)) then
    table.insert(arr2, tempPos)
  end -- 东北
  tempPos = MyPosition:new(pos.x + 1, y, pos.z)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU7, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_NEG_X)) then
    table.insert(arr2, tempPos)
  end -- 中东
  tempPos = MyPosition:new(pos.x + 1, y, pos.z - 1)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU8, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_NEG_X)) then
    table.insert(arr2, tempPos)
  end -- 东南
  tempPos = MyPosition:new(pos.x, y, pos.z - 1)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU7, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_POS_Z)) then
    table.insert(arr2, tempPos)
  end -- 中南
  tempPos = MyPosition:new(pos.x - 1, y, pos.z - 1)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU8, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_POS_Z)) then
    table.insert(arr2, tempPos)
  end -- 西南
  tempPos = MyPosition:new(pos.x, y, pos.z)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU9, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_POS_X)) then
    table.insert(arr2, tempPos)
  end -- 中
  -- 第二三四层
  for i = 1, 3 do
    y = pos.y - 2 + i
    tempPos = MyPosition:new(pos.x - 2, y, pos.z - 2)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU3, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_NEG_Z)) then
      table.insert(arr2, tempPos)
    end -- 西南
    for j = 1, 3 do
      tempPos = MyPosition:new(pos.x - 2 + j, y, pos.z - 2)
      if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU4, tempPos.x, tempPos.y, tempPos.z,
        FACE_DIRECTION.DIR_NEG_Z)) then
        table.insert(arr2, tempPos)
      end
    end
    tempPos = MyPosition:new(pos.x - 2, y, pos.z + 2)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU3, tempPos.x, tempPos.y, tempPos.z,
      FACE_DIRECTION.DIR_NEG_X)) then
      table.insert(arr2, tempPos)
    end -- 西北
    for j = 1, 3 do
      tempPos = MyPosition:new(pos.x - 2, y, pos.z + 2 - j)
      if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU4, tempPos.x, tempPos.y, tempPos.z,
        FACE_DIRECTION.DIR_NEG_X)) then
        table.insert(arr2, tempPos)
      end
    end
    tempPos = MyPosition:new(pos.x + 2, y, pos.z + 2)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU3, tempPos.x, tempPos.y, tempPos.z,
      FACE_DIRECTION.DIR_POS_Z)) then
      table.insert(arr2, tempPos)
    end -- 东北
    for j = 1, 3 do
      tempPos = MyPosition:new(pos.x + 2 - j, y, pos.z + 2)
      if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU4, tempPos.x, tempPos.y, tempPos.z,
        FACE_DIRECTION.DIR_POS_Z)) then
        table.insert(arr2, tempPos)
      end
    end
    tempPos = MyPosition:new(pos.x + 2, y, pos.z - 2)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU3, tempPos.x, tempPos.y, tempPos.z,
      FACE_DIRECTION.DIR_POS_X)) then
      table.insert(arr2, tempPos)
    end -- 东南
    for j = 1, 3 do
      tempPos = MyPosition:new(pos.x + 2, y, pos.z - 2 + j)
      if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU4, tempPos.x, tempPos.y, tempPos.z,
        FACE_DIRECTION.DIR_POS_X)) then
        table.insert(arr2, tempPos)
      end
    end
  end
  -- 第五层
  y = pos.y + 2
  tempPos = MyPosition:new(pos.x - 2, y, pos.z - 2)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU5, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_NEG_Z)) then
    table.insert(arr2, tempPos)
  end -- 西南
  for i = 1, 3 do
    tempPos = MyPosition:new(pos.x - 2 + i, y, pos.z - 2)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU6, tempPos.x, tempPos.y, tempPos.z,
      FACE_DIRECTION.DIR_NEG_Z)) then
      table.insert(arr2, tempPos)
    end
  end
  tempPos = MyPosition:new(pos.x - 2, y, pos.z + 2)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU5, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_NEG_X)) then
    table.insert(arr2, tempPos)
  end -- 西北
  for i = 1, 3 do
    tempPos = MyPosition:new(pos.x - 2, y, pos.z + 2 - i)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU6, tempPos.x, tempPos.y, tempPos.z,
      FACE_DIRECTION.DIR_NEG_X)) then
      table.insert(arr2, tempPos)
    end
  end
  tempPos = MyPosition:new(pos.x + 2, y, pos.z + 2)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU5, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_POS_Z)) then
    table.insert(arr2, tempPos)
  end -- 东北
  for i = 1, 3 do
    tempPos = MyPosition:new(pos.x + 2 - i, y, pos.z + 2)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU6, tempPos.x, tempPos.y, tempPos.z,
      FACE_DIRECTION.DIR_POS_Z)) then
      table.insert(arr2, tempPos)
    end
  end
  tempPos = MyPosition:new(pos.x + 2, y, pos.z - 2)
  if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU5, tempPos.x, tempPos.y, tempPos.z,
    FACE_DIRECTION.DIR_POS_X)) then
    table.insert(arr2, tempPos)
  end -- 东南
  for i = 1, 3 do
    tempPos = MyPosition:new(pos.x + 2, y, pos.z - 2 + i)
    if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU6, tempPos.x, tempPos.y, tempPos.z,
      FACE_DIRECTION.DIR_POS_X)) then
      table.insert(arr2, tempPos)
    end
  end
  for i = 1, 3 do
    for j = 1, 3 do
      tempPos = MyPosition:new(pos.x - 2 + i, y, pos.z - 2 + j)
      if (BlockHelper.placeBlockWhenEmpty(MyMap.BLOCK.QIU10, tempPos.x, tempPos.y, tempPos.z,
        FACE_DIRECTION.DIR_NEG_X)) then
      table.insert(arr2, tempPos)
    end
    end
  end
  TimeHelper.callFnFastRuns(function ()
    -- 移除投掷物
    for i, v in ipairs(arr) do
      CacheHelper.despawnActor(v.id)
    end
    -- 移除方块
    for i, v in ipairs(arr2) do
      BlockHelper.destroyBlock(v.x, v.y, v.z)
    end
  end, item.existTime + item.level * item.addExistTimePerLevel)
end

-- 使用封仙剑
function MySkillHelper.useFengSword (objid, item)
  local objids, pos = MySkillHelper.searchFengEmeny(objid, item)
  if (objids) then
    for i, toobjid in ipairs(objids) do
      MySkillHelper.createFengProjectile(objid, toobjid, pos, item)
    end
    return true
  else
    return false
  end
end

-- 封仙剑搜索敌人
function MySkillHelper.searchFengEmeny (objid, item)
  local distance = item.distance + item.level * item.addDistancePerLevel
  local player = PlayerHelper.getPlayer(objid)
  local pos = player:getMyPosition()
  local dim = { x = distance, y = distance, z = distance }
  local objids = ActorHelper.getAllPlayersArroundPos(pos, dim, objid, false)
  if (not(objids) or #objids == 0) then -- 没找到玩家，则找生物
    objids = ActorHelper.getAllCreaturesArroundPos(pos, dim, objid, false)
  else -- 找到玩家，则加上生物
    local objids2 = ActorHelper.getAllCreaturesArroundPos(pos, dim, objid, false)
    if (objids2 and #objids2 > 0) then
      for i, v in ipairs(objids2) do
        table.insert(objids, v)
      end
    end
  end
  if (objids and #objids > 0) then
    return objids, MyPosition:new(pos.x, pos.y + 4, pos.z)
  else
    return nil
  end
end

-- 创建封仙剑分身
function MySkillHelper.createFengProjectile (objid, toobjid, initPos, item)
  local projectileid = WorldHelper.spawnProjectileByPos(objid, MyWeaponAttr.fengSword.projectileid, initPos, initPos, 0)
  local t = 'feng' .. projectileid
  TimeHelper.callFnContinueRuns(function ()
    local x1 = CacheHelper.getPosition(projectileid)
    local x2 = CacheHelper.getPosition(toobjid)
    if (x1 and x2) then
      ActorHelper.lookAt(projectileid, toobjid)
    else
      CacheHelper.despawnActor(projectileid)
      TimeHelper.delFnContinueRuns(t)
    end
  end, -1, t)
  TimeHelper.callFnFastRuns(function ()
    SkillHelper.continueAttack(projectileid, toobjid, 10, function ()
      MySkillHelper.fengProjectileHit(objid, toobjid, item)
    end)
  end, 2)
end

-- 封仙剑分身命中
function MySkillHelper.fengProjectileHit (objid, toobjid, item)
  ActorHelper.playHurt(toobjid)
  local hurt = item.hurt + item.level * item.addHurtPerLevel
  if (not(ActorHelper.isPlayer(toobjid))) then -- 不是玩家则造成双倍伤害
    hurt = hurt * 2
  else -- 封印
    for i, itemid in ipairs(MyItemHelper.swords) do
      if (ItemHelper.ableUseSkill(toobjid, itemid, item.cd)) then -- 可使用则进入冷却
        ItemHelper.recordUseSkill(toobjid, itemid, item.cd)
      end
    end
  end
  if (hurt > 0) then
    ActorHelper.damageActor(objid, toobjid, hurt, item)
  end
  ActorHelper.playProjectileHit(objid)
end