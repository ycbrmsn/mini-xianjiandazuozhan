-- 我的技能工具类
MySkillHelper = {
  activeAreas = {}, -- { areaid -> { objid = objid, name = name, index = index } }
  -- heroData = {}, -- { name -> { objid -> { 1, 2, 3 } } }
  heroData = {}, -- { objid -> hero }
}

-- 注册英雄
function MySkillHelper.register (o)
  MySkillHelper.heroData[o.objid] = o
end

-- 获取英雄
function MySkillHelper.getHero (objid)
  return MySkillHelper.heroData[objid]
end

-- 获取英雄技能数据
function MySkillHelper.getSkillData (objid)
  local hero = MySkillHelper.getHero(objid)
  local data = hero.skillData
  if (not(data)) then
    data = {}
    MySkillHelper.heroData[objid].skillData = data
  end
  return data
end

-- 获取某技能信息
function MySkillHelper.getSkillInfo (objid, index)
  local data = MySkillHelper.getSkillData(objid)
  local info = data[index]
  if (not(info)) then
    info = {}
    data[index] = info
  end
  return info
end

-- 设置某技能信息
function MySkillHelper.setSkillInfo (objid, index, info)
  local data = MySkillHelper.getSkillData(objid)
  data[index] = info
end

-- 新增有效区域
function MySkillHelper.addActiveArea (objid, index, areaid)
  MySkillHelper.activeAreas[areaid] = { objid = objid, index = index }
end

-- 删除有效区域
function MySkillHelper.delActiveArea (areaid)
  MySkillHelper.activeAreas[areaid] = nil
end

-- 进入有效区域，查询对应英雄区域作用
function MySkillHelper.enterActiveArea (objid, areaid)
  local info = MySkillHelper.activeAreas[areaid]
  if (info) then
    local hero = MySkillHelper.heroData[info.objid]
    if (info.index == 1) then
      hero:enterSkill1(objid, areaid)
    elseif (info.index == 2) then
      hero:enterSkill2(objid, areaid)
    elseif (info.index == 3) then
      hero:enterSkill3(objid, areaid)
    elseif (info.index == 4) then
      hero:enterSkill4(objid, areaid)
    end
    return true
  else
    return false
  end
end

-- 投掷物攻击
function MySkillHelper.attack (objid, toobjid, speed)
  speed = speed or 5
  local step = speed / 20
  local collideDistance = 0.5
  local pos, toPos = ActorHelper.getMyPosition(objid)
  if (type(toobjid) == 'table') then -- 固定位置
    toPos = toobjid
  else -- 生物
    local build = ActorHelper.getBuild(toobjid)
    if (build) then -- 是建筑

    else -- 不是建筑
      toPos = ActorHelper.getEyeHeightPosition(toobjid)
    end
  end
  if (not(toPos)) then -- 目标消失
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
function MySkillHelper.continueAttack (objid, toobjid, speed, callback)
  local t = objid .. 'remoteAtt'
  TimeHelper.callFnContinueRuns(function ()
    local result = MySkillHelper.attack(objid, toobjid, speed)
    if (result) then -- 命中
      TimeHelper.delFnContinueRuns(t)
      WorldHelper.despawnActor(objid)
      if (callback) then
        callback()
      end
    elseif (type(result) == 'nil') then -- 消失
      TimeHelper.delFnContinueRuns(t)
      WorldHelper.despawnActor(objid)
    end
  end, -1, t)
end