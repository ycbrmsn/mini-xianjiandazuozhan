-- 怪物工具类
MonsterHelper = {
  monsters = {}, -- 需要移动控制的怪物 { objid = pos }
  bosses = {}, -- 需要精确控制的生物 { objid = actor }
  delBosses = {}, -- 需要删除的boss { objid = true }
  monsterModels = {}, -- 可击杀的怪物实例数组
  forceDoNothingMonsters = {}, -- objid -> times 禁锢次数
  sealedMonsters = {} -- objid -> times
}

-- 初始化
function MonsterHelper:init (monsterModels)
  self.monsterModels = monsterModels
  for i, v in ipairs(self.monsterModels) do
    if (v.init) then
      TimeHelper:initActor(v)
    end
    if (v.timerGenerate) then
      v:timerGenerate()
    end
  end
end

-- 获取所有怪物模型
function MonsterHelper:getMonsterModels ()
  return self.monsterModels
end

-- 计算击杀获得的经验
function MonsterHelper:calcExp (level, toLevel, exp)
  local levelDiffer = level - toLevel
  if (levelDiffer <= -6) then -- 相差6级双倍经验
    return exp * 2
  elseif (levelDiffer <= -3) then -- 相差3级1.5倍经验
    return math.floor(exp * 1.5)
  elseif (levelDiffer <= 0) then
    return exp
  else
    return math.ceil(exp / math.pow(2, levelDiffer))
  end
end

-- 怪物看向
function MonsterHelper:lookAt (objid, toobjid)
  if (type(objid) == 'table') then
    for i, v in ipairs(objid) do
      self:lookAt(v, toobjid)
    end
  else
    local x, y, z
    if (type(toobjid) == 'table') then
      x, y, z = toobjid.x, toobjid.y, toobjid.z
    else
      x, y, z = ActorHelper:getPosition(toobjid)
      y = y + ActorHelper:getEyeHeight(toobjid) - 1
    end
    local x0, y0, z0 = ActorHelper:getPosition(objid)
    y0 = y0 + ActorHelper:getEyeHeight(objid) - 1 -- 生物位置y是地面上一格，所以要减1
    local myVector3 = MyVector3:new(x0, y0, z0, x, y, z)
    local faceYaw = MathHelper:getActorFaceYaw(myVector3)
    local facePitch = MathHelper:getActorFacePitch(myVector3)
    ActorHelper:setFaceYaw(objid, faceYaw)
    ActorHelper:setFacePitch(objid, facePitch)
  end
end

-- 持续看向
function MonsterHelper:wantLookAt (objid, toobjid, seconds)
  local t = nil
  if (type(objid) == 'number') then
    t = objid .. 'lookat'
  end
  TimeHelper:callFnContinueRuns(function ()
    self:lookAt(objid, toobjid)
  end, seconds, t)
end

-- 怪物做表情
function MonsterHelper:playAct (objid, act, afterSeconds)
  if (afterSeconds) then
    TimeHelper:callFnAfterSecond (function (p)
      ActorHelper:playAct(objid, act)
    end, afterSeconds)
  else
    ActorHelper:playAct(objid, act)
  end
end

-- 创建怪物掉落 fallOff(itemid, min, max, chance)
function MonsterHelper:createFallOff (monster, pos)
  if (monster.fallOff and #monster.fallOff > 0) then
    for i, v in ipairs(monster.fallOff) do
      local r = math.random(1, 100)
      if (v[4] >= r) then
        local num = math.random(v[2], v[3])
        WorldHelper:spawnItem(pos.x, pos.y, pos.z, v[1], num)
      end
    end
  end
end

-- 禁锢怪物
function MonsterHelper:imprisonMonster (objid)
  local times = self.forceDoNothingMonsters[objid]
  if (times) then
    self.forceDoNothingMonsters[objid] = times + 1
  else
    self.forceDoNothingMonsters[objid] = 1
  end
  CreatureHelper:stopRun(objid)
end

-- 取消禁锢怪物，返回true表示已不是囚禁状态
function MonsterHelper:cancelImprisonMonster (objid)
  local times = self.forceDoNothingMonsters[objid]
  if (times) then
    if (times > 1) then
      self.forceDoNothingMonsters[objid] = times - 1
      return false
    else
      self.forceDoNothingMonsters[objid] = nil
      CreatureHelper:openAI(objid)
    end
  end
  return true
end

-- 封魔怪物
function MonsterHelper:sealMonster (objid)
  local times = self.sealedMonsters[objid]
  if (times) then
    self.sealedMonsters[objid] = times + 1
  else
    self.sealedMonsters[objid] = 1
  end
end

-- 取消封魔怪物
function MonsterHelper:cancelSealMonster (objid)
  local times = self.sealedMonsters[objid]
  if (times) then
    if (times > 1) then
      self.sealedMonsters[objid] = times - 1
      return false
    else
      self.sealedMonsters[objid] = nil
    end
  end
  return true
end

-- 获取区域内actorid类型的生物数量
function MonsterHelper:getMonsterNum (areaid, actorid)
  local objids = AreaHelper:getAllCreaturesInAreaId(areaid)
  if (not(objids)) then
    return 0
  end
  if (not(actorid)) then
    return #objids
  end
  local curNum = 0
  for i, v in ipairs(objids) do
    local actid = CreatureHelper:getActorID(v)
    if (actid and actid == actorid) then
      curNum = curNum + 1
    end
  end
  return curNum
end

-- 怪物行动
function MonsterHelper:execute ()
  for k, v in pairs(self.monsters) do
    local pos = ActorHelper:getMyPosition(k)
    if (pos) then -- 怪物有效
      if (type(v) == 'number') then -- 生物objid
        pos = ActorHelper:getMyPosition(v)
      else -- 位置
        pos = v
      end
      ActorHelper:tryMoveToPos(k, pos.x, pos.y, pos.z)
    end
  end
end

-- 怪物靠近
function MonsterHelper:monsterApproach (objids, pos)
  for i, v in ipairs(objids) do
    self.monsters[v] = pos
  end
end

-- 怪物自由
function MonsterHelper:monsterFree (objids)
  for i, v in ipairs(objids) do
    self.monsters[v] = nil
  end
end

-- 跑向
function MonsterHelper:runTo (objid, pos, speed)
  return ActorHelper:tryMoveToPos(objid, pos.x, pos.y, pos.z, speed)
end

-- 新增boss
function MonsterHelper:addBoss (actor)
  actor.isBossStyle = true
  self.bosses[actor.objid] = actor
end

-- 删除boss
function MonsterHelper:delBoss (objid)
  self.delBosses[objid] = true
end

-- 开始boss的精确控制
function MonsterHelper:runBosses ()
  for k, v in pairs(self.bosses) do
    if (v:isActive()) then
      v.action:execute()
    end
  end
  -- 删除boss
  for k, v in pairs(self.delBosses) do
    if (v) then
      self.bosses[k].isBossStyle = false
      self.bosses[k] = nil
      self.delBosses[k] = nil
    end
  end
end

-- 事件

-- 怪物死亡
function MonsterHelper:actorDie (objid, toobjid)
  local actorid = CreatureHelper:getActorID(objid)
  local pos = MyPosition:new(ActorHelper:getPosition(objid))
  for i, v in ipairs(self.monsterModels) do
    if (v.actorid == actorid) then
      self:createFallOff(v, pos)
      break
    end
  end
end
