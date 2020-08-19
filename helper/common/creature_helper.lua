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
function CreatureHelper:stopRun (objid)
  self:closeAI(objid)
  local pos = ActorHelper:getMyPosition(objid)
  ActorHelper:tryMoveToPos(objid, pos.x, pos.y, pos.z)
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
  end
end

-- 封装原始接口

-- 设置生物AI是否生效
function CreatureHelper:setAIActive (objid, isActive)
  local onceFailMessage = '设置生物AI失败一次'
  local finillyFailMessage = StringHelper:concat('设置生物AI失败，参数：objid=', objid, ', isActive=', isActive)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Creature:setAIActive(objid, isActive)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取生物行走速度，原始速度是-1
function CreatureHelper:getWalkSpeed (objid)
  local onceFailMessage = '获取生物行走速度失败一次'
  local finillyFailMessage = StringHelper:concat('获取生物行走速度失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Creature:getWalkSpeed(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置生物行走速度
function CreatureHelper:setWalkSpeed (objid, speed)
  local onceFailMessage = '设置生物行走速度失败一次'
  local finillyFailMessage = StringHelper:concat('设置生物行走速度失败，参数：objid=', objid, ', speed=', speed)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Creature:setWalkSpeed(objid, speed)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取生物的actorid
function CreatureHelper:getActorID (objid)
  local onceFailMessage = '获取生物的actorid失败一次'
  -- local finillyFailMessage = StringHelper:concat('获取生物的actorid失败，参数：objid=', objid)
  local finillyFailMessage = nil
  return CommonHelper:callOneResultMethod(function (p)
    return Creature:getActorID(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取生物名称
function CreatureHelper:getActorName (objid)
  local onceFailMessage = '获取生物名称失败一次'
  local finillyFailMessage = StringHelper:concat('获取生物名称失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Creature:getActorName(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取生物属性
function CreatureHelper:getAttr (objid, attrtype)
  local onceFailMessage = '获取生物属性失败一次'
  local finillyFailMessage = StringHelper:concat('获取生物属性失败，参数：objid=', objid, ', attrtype=', attrtype)
  return CommonHelper:callOneResultMethod(function (p)
    return Creature:getAttr(objid, attrtype)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置生物属性
function CreatureHelper:setAttr (objid, attrtype, val)
  local onceFailMessage = '设置生物属性失败一次'
  local finillyFailMessage = StringHelper:concat('设置生物属性失败，参数：objid=', objid, ',attrtype=', attrtype, ',val=', val)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Creature:setAttr(objid, attrtype, val)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取生物队伍
function CreatureHelper:getTeam (objid)
  local onceFailMessage = '获取生物队伍失败一次'
  local finillyFailMessage = StringHelper:concat('获取生物队伍失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Creature:getTeam(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end