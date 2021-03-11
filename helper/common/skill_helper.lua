-- 技能工具类
SkillHelper = {
  FLY_UP_SPEED = 0.06,
  FLY_DOWN_SPEED = -0.02,
  FLY_JUMP_SPEED = 0.5,
  FLY_ACTOR_JUMP_SPEED = 0.1,
  FLY_STATIC_SPEED = 0.0785,
  flyData = {}, -- { objid -> { state = state, flySwordId = flySwordId, position = pos, isStartFly = false } }
}

function SkillHelper.getItem (item, weaponName)
  if (not(item)) then
    item = ItemHelper.getItem(MyWeaponAttr[weaponName].levelIds[1])
  elseif (type(item) == 'number') then
    item = ItemHelper.getItem(MyWeaponAttr[weaponName].levelIds[item + 1])
  end
  return item
end

-- 投掷物攻击
function SkillHelper.attack (objid, toobjid, speed)
  speed = speed or 5
  local step = speed / 20
  local collideDistance = 0.5
  local pos, toPos = CacheHelper.getMyPosition(objid)
  if (type(toobjid) == 'table') then -- 固定位置
    toPos = toobjid
  else -- 生物
    local build = ActorHelper.getBuild(toobjid)
    if (build) then -- 是建筑

    else -- 不是建筑
      toPos = ActorHelper.getEyeHeightPosition(toobjid)
    end
  end
  if (not(pos) or not(toPos)) then -- 投掷物或目标消失
    return nil
  end
  local tempPos = MyPosition:new(toPos.x, pos.y, toPos.z)
  local distance = MathHelper.getDistance(pos, tempPos) -- 水平的距离
  if (distance <= collideDistance) then
    return true
  else
    distance = distance - step
    local dstPos = MathHelper.getPos2PosInLineDistancePosition(pos, toPos, distance)
    local dh = (toPos.y - pos.y) / (distance / step)
    dstPos.y = pos.y + dh
    ActorHelper.setMyPosition(objid, dstPos)
    return false
  end
end

-- 攻击
function SkillHelper.continueAttack (objid, toobjid, speed, callback)
  local t = objid .. 'remoteAtt'
  TimeHelper.callFnContinueRuns(function ()
    local result = SkillHelper.attack(objid, toobjid, speed)
    if (result) then -- 命中
      TimeHelper.delFnContinueRuns(t)
      CacheHelper.despawnActor(objid)
      if (callback) then
        callback()
      end
    elseif (type(result) == 'nil') then -- 消失
      TimeHelper.delFnContinueRuns(t)
      CacheHelper.despawnActor(objid)
    end
  end, -1, t)
end

-- 获取御剑数据
function SkillHelper.getFlyData (objid)
  local flyData = SkillHelper.flyData[objid]
  if (not(flyData)) then
    flyData = { state = 0, isStartFly = false }
    SkillHelper.flyData[objid] = flyData
  end
  return flyData
end

-- 获取御剑状态（-1：御剑失控；0：可御剑；1：御剑静止；2：御剑前行）
function SkillHelper.getFlyState (objid)
  local flyData = SkillHelper.getFlyData(objid)
  return flyData.state
end

-- 设置御剑状态
function SkillHelper.setFlyState (objid, state)
  local flyData = SkillHelper.getFlyData(objid)
  flyData.state = state
end

-- 是否在御剑
function SkillHelper.isFlying (objid)
  local flyType = objid .. 'fly'
  return TimeHelper.isFnContinueRuns(flyType), flyType
end

-- 是否在御剑前行
function SkillHelper.isFlyingAdvance (objid)
  local flyAdvanceType = objid .. 'flyAdvance'
  return TimeHelper.isFnContinueRuns(flyAdvanceType), flyAdvanceType
end

-- 是否在刚开始御剑
function SkillHelper.isStartFly (objid)
  local flyData = SkillHelper.getFlyData(objid)
  return flyData.isStartFly
end

-- 御剑静止
function SkillHelper.flyStatic (objid, hasSword)
  local pos = CacheHelper.getMyPosition(objid)
  if (not(pos)) then
    return false
  end
  local flyData = SkillHelper.getFlyData(objid)
  flyData.hasSword = hasSword
  if (not(ActorHelper.isInAir(objid))) then -- 不在空中
    -- pos.y = pos.y + 2
    -- local yaw = ActorHelper.getFaceYaw(objid)
    -- local facePitch = ActorHelper.getFacePitch(objid)
    -- ActorHelper.setMyPosition(objid, pos)
    -- ActorHelper.setFaceYaw(objid, yaw)
    -- ActorHelper.setFacePitch(objid, facePitch)
    if (ActorHelper.isPlayer(objid)) then -- 生物是玩家
      ActorHelper.appendSpeed(objid, 0, SkillHelper.FLY_JUMP_SPEED, 0)
    else
      ActorHelper.appendSpeed(objid, 0, SkillHelper.FLY_ACTOR_JUMP_SPEED, 0)
    end
    flyData.isStartFly = true
    TimeHelper.callFnFastRuns(function ()
      flyData.isStartFly = false
    end, 1, objid .. 'startFly')
  end
  local flySwordId
  if (flyData.hasSword and not(flyData.flySwordId)) then
    flySwordId = WorldHelper.spawnProjectileByDirPos(objid, MyWeaponAttr.controlSword.projectileid, pos, pos, 0)
    flyData.flySwordId = flySwordId
  end
  local isFlying, flyType = SkillHelper.isFlying(objid)
  local isFlyingAdvance, flyAdvanceType = SkillHelper.isFlyingAdvance(objid)
  if (not(isFlying)) then -- 如果没有飞，则飞起来
    local idx = 1
    if (ActorHelper.isPlayer(objid)) then -- 生物是玩家
      ActorHelper.addBuff(objid, MyMap.BUFF.FLY_STYLE, 1, 0) -- 泡泡包裹
      ActorHelper.stopBodyEffectById(objid, BaseConstant.BODY_EFFECT.PARTICLE18) -- 去掉特效
    end
    TimeHelper.callFnContinueRuns(function ()
      if (ActorHelper.isPlayer(objid)) then -- 生物是玩家
        ActorHelper.appendSpeed(objid, 0, SkillHelper.FLY_DOWN_SPEED, 0)
      else
        ActorHelper.appendSpeed(objid, 0, SkillHelper.FLY_STATIC_SPEED, 0)
      end
      local p = CacheHelper.getMyPosition(objid) -- 角色位置
      local faceYaw = ActorHelper.getFaceYaw(objid)
      -- local facePitch = ActorHelper.getFacePitch(objid)

      local swordPos = CacheHelper.getMyPosition(flySwordId) -- 御仙剑位置
      if (flyData.hasSword and swordPos) then -- 如果御仙剑还在脚下
        ActorHelper.setMyPosition(flySwordId, p.x, p.y - 0.1, p.z)
        ActorHelper.setFaceYaw(flySwordId, faceYaw)

        -- 每15秒(300/20)随意更新一条数据，用于使御仙剑队伍信息不会被删除
        if (idx % 300 == 0) then
          ItemHelper.recordMissile(flySwordId, 'objid', flySwordId)
        end
        idx = idx + 1
      end
    end, -1, flyType)
  end
  if (isFlyingAdvance) then -- 如果在向前飞，则停止
    TimeHelper.delFnContinueRuns(flyAdvanceType)
  end
  SkillHelper.setFlyState(objid, 1)
  return true
end

-- 御剑前行
function SkillHelper.flyAdvance (objid)
  local isFlying, flyType = SkillHelper.isFlying(objid)
  local isFlyingAdvance, flyAdvanceType = SkillHelper.isFlyingAdvance(objid)
  -- if (not(isFlying)) then -- 如果没有飞，则飞起来
  --   TimeHelper.callFnContinueRuns(function ()
  --     ActorHelper.appendSpeed(objid, 0, SkillHelper.FLY_DOWN_SPEED, 0)
  --   end, -1, flyType)
  -- end
  if (not(isFlyingAdvance)) then -- 如果没有向前飞，则向前飞
    TimeHelper.callFnContinueRuns(function ()
      local speedVector3 = MyVector3:new(ActorHelper.getFaceDirection(objid)):mul(0.1)
      ActorHelper.appendSpeed(objid, speedVector3.x, speedVector3.y, speedVector3.z)
    end, -1, flyAdvanceType)
  end
  SkillHelper.setFlyState(objid, 2)
end

-- 上升
function SkillHelper.flyUp (objid)
  if (SkillHelper.isFlying(objid)) then
    TimeHelper.callFnContinueRuns(function ()
      ActorHelper.appendSpeed(objid, 0, SkillHelper.FLY_UP_SPEED, 0)
    end, -1, objid .. 'flyUp')
  end
end

-- 停止上升
function SkillHelper.stopFlyUp (objid)
  TimeHelper.delFnContinueRuns(objid .. 'flyUp')
end

-- 停止御剑
function SkillHelper.stopFly (objid, item)
  local state = SkillHelper.getFlyState(objid)
  if (state == 0 or state == -1) then -- 未飞行或已失控
    return
  end
  if (item) then -- 失控
    item = SkillHelper.getItem(item, 'controlSword')
    ItemHelper.recordUseSkill(objid, item.id, MyWeaponAttr.controlSword.cd)
  end
  ActorHelper.removeBuff(objid, MyMap.BUFF.FLY_STYLE)
  TimeHelper.delFnContinueRuns(objid .. 'fly')
  if (state == 1) then -- 静止
  elseif (state == 2) then -- 前行
    TimeHelper.delFnContinueRuns(objid .. 'flyAdvance')
  end
  SkillHelper.stopFlyUp(objid)
  SkillHelper.setFlyState(objid, 0)
  local flyData = SkillHelper.getFlyData(objid)
  if (flyData.hasSword) then
    CacheHelper.despawnActor(flyData.flySwordId)
    flyData.flySwordId = nil
  end
  -- ActorHelper.setImmuneFall(SkillHelper.myActor.objid, true) -- 免疫跌落
  -- TimeHelper.callFnFastRuns(function ()
  --   ActorHelper.setImmuneFall(SkillHelper.myActor.objid, false) -- 取消免疫跌落
  -- end, 1)
end
