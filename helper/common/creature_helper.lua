-- 生物工具类
CreatureHelper = {}

-- 获取当前生命值
function CreatureHelper:getHp (objid)
  return self:getAttr(objid, CREATUREATTR.CUR_HP)
end

-- 获取最大生命值
function CreatureHelper:getMaxHp (objid)
  return self:getAttr(objid, CREATUREATTR.MAX_HP)
end

-- 设置当前生命值
function CreatureHelper:setHp (objid, hp)
  return self:setAttr(objid, CREATUREATTR.CUR_HP, hp)
end

-- 设置最大生命值
function CreatureHelper:setMaxHp (objid, maxHp)
  return self:setAttr(objid, CREATUREATTR.MAX_HP, maxHp)
end

-- 关闭AI
function CreatureHelper:closeAI (objid)
  return CreatureHelper:setAIActive(objid, false)
end

-- 开启AI
function CreatureHelper:openAI (objid)
  return CreatureHelper:setAIActive(objid, true)
end

-- 停止跑
function CreatureHelper:stopRun (objid, speed)
  self:closeAI(objid)
  -- if (motion == 1) then
  --   local x, y, z = ActorHelper:getFaceDirection(objid)
  --   local pos = ActorHelper:getMyPosition(objid)
  --   if (pos and x) then
  --     ActorHelper:tryMoveToPos(objid, pos.x + x, pos.y + y, pos.z + z, speed)
  --   end
  -- end
  local pos = ActorHelper:getMyPosition(objid)
  if (pos) then
    local yaw = ActorHelper:getFaceYaw(objid)
    local pitch = ActorHelper:getFacePitch(objid)
    ActorHelper:tryMoveToPos(objid, pos.x, pos.y, pos.z, speed)
    ActorHelper:setFaceYaw(objid, yaw)
    ActorHelper:setFacePitch(objid, pitch)
  end
end

-- 关门
function CreatureHelper:closeDoor (objid, areaid)
  local doorPos = AreaHelper.allDoorAreas[areaid]
  if (doorPos) then -- 如果门位置存在，说明这是门区域，则判断该区域内是否还有其他生物
    local creaturelist = AreaHelper:getAllCreaturesInAreaId(areaid)
    if (creaturelist and #creaturelist > 0) then -- 如果区域内还有其他生物，则不关门
      -- do nothing
    else
      BlockHelper:closeDoor(doorPos.x, doorPos.y, doorPos.z)
    end
  else -- 不确定是不是门的位置
    local isDoorArea, pos = AreaHelper:isDoorArea(areaid)
    if (isDoorArea) then
      AreaHelper.allDoorAreas[areaid] = pos
      CreatureHelper:closeDoor(objid, areaid)
    end
  end
end

-- 重置生命值
function CreatureHelper:resetHp (objid, hp)
  hp = hp or CreatureHelper:getMaxHp(objid)
  return CreatureHelper:setHp(objid, hp)
end

-- 封装原始接口

-- 设置生物AI是否生效
function CreatureHelper:setAIActive (objid, isActive)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Creature:setAIActive(objid, isActive)
  end, '设置生物AI是否生效', 'objid=', objid, ',isActive=', isActive)
end

-- 获取生物行走速度，原始速度是-1，目前是10
function CreatureHelper:getWalkSpeed (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Creature:getWalkSpeed(objid)
  end, '获取生物行走速度', 'objid=', objid)
end

-- 设置生物行走速度
function CreatureHelper:setWalkSpeed (objid, speed)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Creature:setWalkSpeed(objid, speed)
  end, '设置生物行走速度', 'objid=', objid, ',speed=', speed)
end

-- 获取生物的actorid
function CreatureHelper:getActorID (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Creature:getActorID(objid)
  end, nil, 'objid=', objid)
end

-- 获取生物名称
function CreatureHelper:getActorName (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Creature:getActorName(objid)
  end, '获取生物名称', 'objid=', objid)
end

-- 获取生物属性
function CreatureHelper:getAttr (objid, attrtype)
  return CommonHelper:callOneResultMethod(function (p)
    return Creature:getAttr(objid, attrtype)
  end, '获取生物属性', 'objid=', objid, ',attrtype=', attrtype)
end

-- 设置生物属性
function CreatureHelper:setAttr (objid, attrtype, val)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Creature:setAttr(objid, attrtype, val)
  end, '设置生物属性', 'objid=', objid, ',attrtype=', attrtype, ',val=', val)
end

-- 获取生物队伍
function CreatureHelper:getTeam (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Creature:getTeam(objid)
  end, '获取生物队伍', 'objid=', objid)
end