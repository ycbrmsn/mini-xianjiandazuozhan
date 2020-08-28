-- 角色工具类
ActorHelper = {
  ACT = {
    HI = 1, -- 打招呼
    THINK = 2, -- 低头思考
    CRY = 3, -- 哭泣
    ANGRY = 4, -- 生气
    STRETCH = 5,  -- 伸懒腰
    HAPPY = 6, -- 胜利（高兴）
    THANK = 7, -- 感谢
    FREE = 8, -- 休闲动作
    DOWN = 9, -- 倒地
    POSE = 10, -- 摆姿势
    STAND = 11, -- 站立
    RUN = 12, -- 跑
    SLEEP = 13, -- 躺下睡觉
    SIT = 14, -- 坐下
    SWIM = 15, -- 游泳
    ATTACK = 16, -- 攻击
    DIE = 17, -- 死亡
    BEAT = 18, -- 受击
    FREE2 = 19, -- 休闲
    JUMP = 20 -- 跳
  },
  BUFF = {
    FASTER_RUN = 4, -- 疾跑
    NIGHT_LOOK = 16 -- 夜视
  },
  FACE_YAW = {
    EAST = -90,
    WEST = 90,
    SOUTH = 0,
    NORTH = 180
  },
  FLY_SPEED = 0.0785, -- 飞行速度
  actors = {}, -- objid -> actor
  clickActors = {} -- 玩家点击的actor：objid -> actor
}

function ActorHelper:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 新增person
function ActorHelper:addActor (o)
  o.action = BaseActorAction:new(o)
  o.want = BaseActorWant:new(o)
  self.actors[o['objid']] = o
end

-- 根据objid删除actor
function ActorHelper:delActor (objid)
  self.actors[objid] = nil
end

-- 根据actorid删除actor
function ActorHelper:delAcotrsByActorid (actorid)
  for k, v in pairs(self.actors) do
    if (v.actorid == actorid) then
      self.actors[k] = nil
    end
  end
end

-- 根据objid查询actor
function ActorHelper:getActor (objid)
  return self.actors[objid]
end

function ActorHelper:getAllActors ()
  return self.actors
end

function ActorHelper:getMyPosition (objid)
  return MyPosition:new(self:getPosition(objid))
end

function ActorHelper:setMyPosition (objid, x, y, z)
  local pos
  if (type(x) == 'table') then
    pos = x 
  elseif (type(x) == 'number') then
    pos = MyPosition:new(x, y, z)
  else
    LogHelper:debug('设置位置参数类型为：', type(x))
    return false
  end
  if (ActorHelper:isPlayer(objid)) then
    return PlayerHelper:setPosition(objid, pos.x, pos.y, pos.z)
  else
    return ActorHelper:setPosition(objid, pos.x, pos.y, pos.z)
  end
end

--[[  获取距离生物多远的位置，因生物的朝向变化
      参数distance，正数表示前方，负数表示背后；参数angle表示偏转角度顺时针方向偏转]]--
function ActorHelper:getDistancePosition (objid, distance, angle)
  angle = angle or 0
  local pos = self:getMyPosition(objid)
  local angle = ActorHelper:getFaceYaw(objid) + angle
  if (angle > 180) then
    angle = angle - 360
  elseif (angle < -180) then
    angle = angle + 360
  end
  return MathHelper:getDistancePosition(pos, angle, distance)
end

-- 获取距离生物多远的位置，不因生物的朝向变化，默认在南方
function ActorHelper:getFixedDistancePosition (objid, distance, angle)
  angle = angle or 0
  local pos = self:getMyPosition(objid)
  return MathHelper:getDistancePosition(pos, angle, distance)
end

function ActorHelper:lookToward (objid, dir)
  dir = string.upper(dir)
  local yaw
  if (dir == 'N') then
    yaw = ActorHelper.FACE_YAW.NORTH
  elseif (dir == 'S') then
    yaw = ActorHelper.FACE_YAW.SOUTH
  elseif (dir == 'W') then
    yaw = ActorHelper.FACE_YAW.WEST
  else
    yaw = ActorHelper.FACE_YAW.EAST
  end
  ActorHelper:setFaceYaw(objid, yaw)
end

-- 设置actor（非玩家）看向某人/某处的横向偏移
function ActorHelper:setLookAtFaceYaw (objid, toobjid, angle)
  angle = angle or 0
  local pos = ActorHelper:getMyPosition(objid)
  local dstPos = toobjid
  if (type(toobjid) == 'number') then
    dstPos = ActorHelper:getMyPosition(toobjid)
  end
  local myVector3 = MyVector3:new(pos, dstPos)
  return ActorHelper:setFaceYaw(objid, MathHelper:getActorFaceYaw(myVector3) + angle)
end

function ActorHelper:handleNextWant (myActor)
  local want = myActor.wants[1]
  table.remove(myActor.wants, 1)
  local nextWant = myActor.wants[1]
  -- LogHelper:debug('下一个行为：', nextWant.style)
  myActor.think = nextWant.think
  if (nextWant.style == 'move' or nextWant.style == 'patrol') then
    BaseActorActionHelper:createMoveToPos(nextWant)
    myActor.action:execute()
    -- LogHelper:debug('开始移动')
  elseif (nextWant.style == 'approach') then
    BaseActorActionHelper:createApproachToPos(nextWant)
    myActor.action:execute()
  elseif (nextWant.style == 'freeInArea') then
    nextWant.toPos = BaseActorActionHelper:getFreeInAreaPos(myActor.freeInAreaIds)
    BaseActorActionHelper:createMoveToPos(nextWant)
    -- LogHelper:debug(myActor:getName() .. '开始闲逛')
  elseif (nextWant.style == 'freeTime') then
    myActor:openAI()
  elseif (nextWant.style == 'wait') then
    local restTime = nextWant.restTime
    table.remove(myActor.wants, 1)
    nextWant = myActor.wants[1]
    nextWant.currentRestTime = restTime
    -- LogHelper:debug('wait')
  elseif (nextWant.style == 'lightCandle' or nextWant.style == 'putOutCandle') then
    nextWant.toPos = want.toPos
    -- 2秒后看，攻击，移除想法
    TimeHelper:callFnAfterSecond (function (p)
      p.myActor:lookAt(p.pos)
      p.myActor.action:playAttack()
    end, 2, { pos = want.toPos, myActor = myActor })
    -- 3秒后蜡烛台变化，并执行下一个动作
    TimeHelper:callFnAfterSecond (function (p)
      BlockHelper:handleCandle(p.pos, p.isLit)
      if (p.myActor.wants[2]) then
        self:handleNextWant(p.myActor)
      end
    end, 3, { pos = want.toPos, isLit = nextWant.style == 'lightCandle', myActor = myActor })
  end
end

-- 记录点击的玩家与被点击的生物之间的一对一关系
function ActorHelper:recordClickActor (objid, myActor)
  for k, v in pairs(self.clickActors) do
    if (v == myActor) then -- 有其他玩家点击过，则替换为当前玩家点击
      self.clickActors[k] = nil
      break
    end
  end
  self.clickActors[objid] = myActor
  local player = PlayerHelper:getPlayer(objid)
  player:setClickActor(myActor)
end

-- 准备恢复被点击的生物之前的行为
function ActorHelper:resumeClickActor (objid)
  local myActor = self.clickActors[objid]
  if (myActor) then
    if (myActor.wants and #myActor.wants > 0) then
      local want = myActor.wants[1]
      if (want.style == 'lookingAt') then
        want.currentRestTime = 5
        TimeHelper:delFnContinueRuns(myActor.objid .. 'lookat')
      end
    end
    self.clickActors[objid] = nil
  end
end

-- actor行动
function ActorHelper:runActors ()
  for k, v in pairs(self.actors) do
    LogHelper:call(function ()
      if (v:isActive() and not(v.isBossStyle)) then
        v.action:execute()
      end
    end)
  end
end

-- 时间到了
function ActorHelper:atHour (hour)
  hour = hour or TimeHelper:getHour()
  for k, v in pairs(self.actors) do
    v:wantAtHour(hour)
  end
end

-- 是否是同队生物
function ActorHelper:isTheSameTeamActor (objid1, objid2)
  local teamid1, teamid2
  if (ActorHelper:isPlayer(objid1)) then -- 是玩家
    teamid1 = PlayerHelper:getTeam(objid1)
  else
    teamid1 = CreatureHelper:getTeam(objid1)
  end
  if (ActorHelper:isPlayer(objid2)) then -- 是玩家
    teamid2 = PlayerHelper:getTeam(objid2)
  else
    teamid2 = CreatureHelper:getTeam(objid2)
  end
  if (not(teamid1) or not(teamid2)) then -- 如果有生物没有队伍，则不是同队
    return false
  end
  return teamid1 == teamid2
end

-- 获得区域内所有敌对生物
function ActorHelper:getAllOtherTeamActorsInAreaId (objid, areaid)
  local objids1, objids2 = AreaHelper:getAllCreaturesAndPlayersInAreaId(areaid)
  local objids = {}
  if (ActorHelper:isPlayer(objid)) then -- 是玩家
    local teamid = PlayerHelper:getTeam(objid)
    if (objids1 and #objids1 > 0) then -- 发现生物，排除同队生物
      for i, v in ipairs(objids1) do
        local tid = CreatureHelper:getTeam(v)
        if (tid ~= teamid) then -- 非同队生物
          table.insert(objids, v)
        end
      end
    end
    if (objids2 and #objids2 > 0) then -- 发现玩家，排除同队玩家
      for i, v in ipairs(objids2) do
        if (v ~= objid) then -- 非当前玩家
          local tid = PlayerHelper:getTeam(v)
          if (tid ~= teamid) then -- 非同队玩家
            table.insert(objids, v)
          end
        end
      end
    end
  else -- 是生物
    local teamid = CreatureHelper:getTeam(objid)
    if (objids1 and #objids1 > 0) then -- 发现生物，排除同队生物
      for i, v in ipairs(objids1) do
        if (v ~= objid) then -- 非当前生物
          local tid = CreatureHelper:getTeam(v)
          if (tid ~= teamid) then -- 非同队生物
            table.insert(objids, v)
          end
        end
      end
    end
    if (objids2 and #objids2 > 0) then -- 发现玩家，排除同队玩家
      for i, v in ipairs(objids2) do
        local tid = PlayerHelper:getTeam(v)
        if (tid ~= teamid) then -- 非同队玩家
          table.insert(objids, v)
        end
      end
    end
  end
  return objids
end

-- 获取队伍及类型
function ActorHelper:getTeam (objid)
  local teamid
  local objType = ActorHelper:getObjType(objid)
  if (not(objType)) then -- 不存在
    teamid = 0
  elseif (objType == OBJ_TYPE.OBJTYPE_PLAYER) then -- 玩家
    teamid = PlayerHelper:getTeam(objid)
  elseif (objType == OBJ_TYPE.OBJTYPE_CREATURE) then -- 生物
    teamid = CreatureHelper:getTeam(objid)
  elseif (objType == OBJ_TYPE.OBJTYPE_MISSILE) then -- 投掷物
    teamid = ItemHelper:getMissileTeam(objid)
  else -- 掉落物
    teamid = 0
  end
  return teamid, objType
end

-- 位置附近的所有玩家
function ActorHelper:getAllPlayersArroundPos (pos, dim, objid, isTheSame)
  local posBeg, posEnd = MathHelper:getRectRange(pos, dim)
  local objids = AreaHelper:getAllPlayersInAreaRange(posBeg, posEnd)
  return self:getTeamObjs(objids, objid, isTheSame)
end

-- 位置附近的所有生物
function ActorHelper:getAllCreaturesArroundPos (pos, dim, objid, isTheSame)
  local posBeg, posEnd = MathHelper:getRectRange(pos, dim)
  local objids = AreaHelper:getAllCreaturesInAreaRange(posBeg, posEnd)
  return self:getTeamObjs(objids, objid, isTheSame)
end

-- 获取附近的所有投掷物
function ActorHelper:getAllMissilesArroundPos (pos, dim, objid, isTheSame)
  local posBeg, posEnd = MathHelper:getRectRange(pos, dim)
  local num, objids = WorldHelper:getActorsByBox(OBJ_TYPE.OBJTYPE_MISSILE, posBeg.x, 
    posBeg.y, posBeg.z, posEnd.x, posEnd.y, posEnd.z)
  return self:getTeamObjs(objids, objid, isTheSame)
end

function ActorHelper:getTeamObjs (objids, objid, isTheSame)
  if (objids and objid) then
    local arr, tid = {}
    local teamid = self:getTeam(objid)
    for i, v in ipairs(objids) do
      tid = self:getTeam(v)
      if ((isTheSame and teamid == tid) or -- 同队
        (not(isTheSame) and teamid ~= tid)) then -- 不同队
        table.insert(arr, v)
      end
    end
    return arr
  else
    return objids
  end
end

-- 给对象增加一个速度 id、速度大小、起始位置、目标位置
function ActorHelper:appendFixedSpeed (objid, speed, srcPos, dstPos)
  dstPos = dstPos or ActorHelper:getMyPosition(objid)
  local speedVector3 = MathHelper:getSpeedVector3(srcPos, dstPos, speed)
  ActorHelper:appendSpeed(objid, speedVector3.x, speedVector3.y, speedVector3.z)
  return speedVector3
end

-- 生物是否在空气中
function ActorHelper:isInAir (objid)
  local pos = self:getMyPosition(objid)
  if (not(BlockHelper:isAirBlock(pos.x, pos.y, pos.z))) then -- 生物位置不是空气
    return false
  else
    pos.y = pos.y - 1
    if (BlockHelper:isAirBlock(pos.x, pos.y, pos.z)) then -- 生物下方位置是空气
      return true
    else
      return false
    end
  end
end

-- 前后左右中下六个位置如果有一个位置不是空气方块，那么就是靠近了方块
function ActorHelper:isApproachBlock (objid)
  local pos = self:getMyPosition(objid)
  return (BlockHelper:isInvisibleBlockOffset(pos)
      and BlockHelper:isInvisibleBlockOffset(pos, -1)
      and BlockHelper:isInvisibleBlockOffset(pos, 1)
      and BlockHelper:isInvisibleBlockOffset(pos, 0, -1)
      and BlockHelper:isInvisibleBlockOffset(pos, 0, 0, -1)
      and BlockHelper:isInvisibleBlockOffset(pos, 0, 0, 1)) == false
end

function ActorHelper:playBodyEffect (objid, particleId, scale)
  scale = scale or 1
  return self:playBodyEffectById(objid, particleId, scale)
end

-- 播放人物特效然后关闭
function ActorHelper:playAndStopBodyEffect (objid, particleId, scale, time)
  time = time or 3
  self:playBodyEffect(objid, particleId, scale)
  TimeHelper:callFnLastRun(objid, objid .. 'stopBodyEffect' .. particleId, function ()
    ActorHelper:stopBodyEffectById(objid, particleId)
  end, time)
end

-- 播放人物音效
function ActorHelper:playSoundEffect (objid, soundId, isLoop)
  return ActorHelper:playSoundEffectById(objid, soundId, 100, 1, isLoop)
end

-- 播放人物音效然后关闭
function ActorHelper:playAndStopSoundEffect (objid, soundId, isLoop, time)
  time = time or 3
  self:playSoundEffect(objid, soundId, isLoop)
  TimeHelper:callFnLastRun(objid, objid .. 'stopSoundEffect' .. soundId, function ()
    ActorHelper:stopSoundEffectById(objid, soundId)
  end, time)
end

-- 加上重力
function ActorHelper:addGravity (objid)
  local t = objid .. 'addGravity'
  TimeHelper:callFnContinueRuns(function ()
    if (ActorHelper:getMyPosition(objid)) then
      ActorHelper:appendSpeed(objid, 0, -self.FLY_SPEED, 0)
      local speedVector3 = ItemHelper:getMissileSpeed(objid)
      if (speedVector3) then
        speedVector3.y = speedVector3.y - self.FLY_SPEED
      else
        ItemHelper:recordMissileSpeed(objid, MyVector3:new(0, -self.FLY_SPEED, 0))
      end
    else
      TimeHelper:delFnContinueRuns(t)
    end
  end, -1, t)
end

-- 对角色造成伤害
function ActorHelper:damageActor (objid, toobjid, val)
  if (val <= 0) then -- 伤害值无效
    return
  end
  local isPlayer = ActorHelper:isPlayer(objid) -- 攻击者是否是玩家
  if (ActorHelper:isPlayer(toobjid)) then -- 伤害玩家
    local hp = PlayerHelper:getHp(toobjid)
    if (hp <= 0) then -- 生物已经死亡
      return
    end
    if (hp > val) then -- 玩家不会死亡
      hp = hp - val
      PlayerHelper:setHp(toobjid, hp)
    else -- 玩家可能会死亡，则检测玩家是否可被杀死
      local ableBeKilled = PlayerHelper:getPlayerEnableBeKilled(toobjid)
      if (ableBeKilled) then -- 能被杀死
        ActorHelper:killSelf(toobjid)
        if (isPlayer) then -- 攻击者是玩家
          MyPlayerHelper:playerDefeatActor(objid, toobjid)
        else -- 攻击者是生物，目前暂不处理
        end
      else -- 不能被杀死
        hp = 1
        PlayerHelper:setHp(toobjid, hp)
      end
    end
  else -- 伤害了生物
    local hp = CreatureHelper:getHp(toobjid)
    if (not(hp) or hp <= 0) then -- 未找到生物或生物已经死亡
      return
    end
    if (hp > val) then -- 生物不会死亡
      hp = hp - val
      CreatureHelper:setHp(toobjid, hp)
    else -- 生物可能会死亡，则检测生物是否可被杀死
      local ableBeKilled = ActorHelper:getEnableBeKilledState(toobjid)
      if (ableBeKilled) then -- 能被杀死
        ActorHelper:killSelf(toobjid)
        if (isPlayer) then -- 攻击者是玩家
          MyPlayerHelper:playerDefeatActor(objid, toobjid)
        else -- 攻击者是生物，目前暂不处理
        end
      else -- 不能被杀死
        hp = 1
        CreatureHelper:setHp(toobjid, hp)
      end
    end
  end
  if (isPlayer) then
    MyPlayerHelper:playerDamageActor(objid, toobjid)
  end
end

-- 第二人是不是在第一人前面
function ActorHelper:isTwoInFrontOfOne (objid1, objid2)
  local curPlaceDir = ActorHelper:getCurPlaceDir(objid1)
  local x1, y1, z1 = ActorHelper:getPosition(objid1)
  local x2, y2, z2 = ActorHelper:getPosition(objid2)
  -- 获取的方向是反的，不知道是不是bug
  if (curPlaceDir == FACE_DIRECTION.DIR_NEG_X) then -- 东
    return x2 > x1
  elseif (curPlaceDir == FACE_DIRECTION.DIR_POS_X) then -- 西
    return x2 < x1
  elseif (curPlaceDir == FACE_DIRECTION.DIR_NEG_Z) then -- 北
    return z2 > z1
  elseif (curPlaceDir == FACE_DIRECTION.DIR_POS_Z) then -- 南
    return z2 < z1
  else
    return false
  end
end

-- 获取距离最近的actor
function ActorHelper:getNearestActor (objids, pos)
  local tempDistance, objid
  for i, v in ipairs(objids) do
    local p = ActorHelper:getMyPosition(v)
    if (p) then
      local distance = MathHelper:getDistance(p, pos)
      if (not(tempDistance) or tempDistance > distance) then
        distance = tempDistance
        objid = v
      end
    end
  end
  return objid
end

-- 获取数组中活着的actor
function ActorHelper:getAliveActors (objids)
  local aliveObjids = {}
  for i, v in ipairs(objids) do
    local hp
    if (ActorHelper:isPlayer(v)) then -- 玩家
      hp = PlayerHelper:getHp(v)
    else -- 生物
      hp = CreatureHelper:getHp(v)
    end
    if (hp > 0) then
      table.insert(aliveObjids, v)
    end
  end
  return aliveObjids
end

-- 设置生物可移动状态
function ActorHelper:setEnableMoveState (objid, switch)
  return self:setActionAttrState(objid, CREATUREATTR.ENABLE_MOVE, switch)
end

-- 获取生物可移动状态
function ActorHelper:getEnableMoveState (objid)
  return self:getActionAttrState(objid, CREATUREATTR.ENABLE_MOVE)
end

-- 设置生物可被杀死状态
function ActorHelper:setEnableBeKilledState (objid, switch)
  return self:setActionAttrState(objid, CREATUREATTR.ENABLE_BEKILLED, switch)
end

-- 获取生物可被杀死状态
function ActorHelper:getEnableBeKilledState (objid)
  return self:getActionAttrState(objid, CREATUREATTR.ENABLE_BEKILLED)
end

-- 设置生物是否可被攻击状态
function ActorHelper:setEnableBeAttackedState (objid, switch)
  return self:setActionAttrState(objid, CREATUREATTR.ENABLE_BEATTACKED, switch)
end

-- 设置免疫跌落伤害
function ActorHelper:setImmuneFall (objid, isadd)
  return ActorHelper:setImmuneType(objid, HURTTYPE.FALL, isadd)
end

-- 事件

-- actor进入区域
function ActorHelper:actorEnterArea (objid, areaid)
  local myActor = self:getActor(objid)
  local doorPos = AreaHelper.allDoorAreas[areaid]
  if (doorPos) then -- 如果门位置存在，说明这是门区域，则打开这个门
    BlockHelper:openDoor(doorPos.x, doorPos.y, doorPos.z)
  end
  if (myActor and myActor.wants) then -- 找到了一个actor，并且这个actor有想法
    local want = myActor.wants[1]
    if (want.toAreaId == areaid) then -- 如果是该actor的终点区域，则判断actor是仅仅前往还是巡逻
      if (want.style == 'move' or want.style == 'approach') then -- 如果是仅仅前往，则变更想法，并且停下来
        -- LogHelper:debug(myActor:getName() .. '进入了终点区域' .. areaid)
        AreaHelper:destroyArea(want.toAreaId) -- 清除终点区域
        local pos = BaseActorActionHelper:getNextPos(want)
        -- LogHelper:debug(myActor:getName(), pos)
        if (pos) then -- 有下一个行动位置
          want.toPos = pos
          BaseActorActionHelper:createMoveToPos(want)
          myActor.action:execute()
          -- LogHelper:debug(myActor:getName(), '向下一个位置出发')
        elseif (myActor.wants[2]) then
          self:handleNextWant(myActor)
        else
          myActor:defaultWant()
          myActor:wantStayForAWhile()
        end
      elseif (want.style == 'patrol') then -- 如果是巡逻，则停下来并设定前往目的地
        AreaHelper:destroyArea(want.toAreaId) -- 清除终点区域
        want.currentRestTime = want.restTime
        want.toPos = BaseActorActionHelper:getNextPos(want)
        -- LogHelper:debug('下一个位置' .. type(want.toPos))
        BaseActorActionHelper:createMoveToPos(want)
      elseif (want.style == 'freeInArea') then -- 区域内自由移动
        AreaHelper:destroyArea(want.toAreaId) -- 清除终点区域
        want.currentRestTime = want.restTime
        want.toPos = BaseActorActionHelper:getFreeInAreaPos(myActor.freeInAreaIds)
        BaseActorActionHelper:createMoveToPos(want)
      else -- 其他情况，不明
        -- do nothing
      end
    else -- 不是该actor的终点区域，则和该actor没有关系
      -- do nothing
    end
  else -- 没有找到actor，或者该actor没有想法，则不做什么
    -- do nothing
  end
end

-- actor离开区域
function ActorHelper:actorLeaveArea (objid, areaid)
  CreatureHelper:closeDoor(objid, areaid)
end

-- 生物碰撞
function ActorHelper:actorCollide (objid, toobjid)
  local actor1 = ActorHelper:getActor(objid)
  -- LogHelper:info('碰撞了', actor1:getName())
  if (actor1) then -- 生物是特定生物
    if (ActorHelper:isPlayer(toobjid)) then -- 是玩家
      if (actor1.wants and actor1.wants[1].style == 'sleeping') then
        actor1.wants[1].style = 'wake'
      end
      actor1:defaultCollidePlayerEvent(toobjid, ActorHelper:isTwoInFrontOfOne(objid, toobjid))
    else
      local actor2 = ActorHelper:getActor(toobjid)
      if (actor2) then
        -- 先简单处理为actorid小的停下来
        if (actor1.actorid == actor2.actorid) then
          if (objid < toobjid) then
            actor1:wantStayForAWhile()
          else
            actor2:wantStayForAWhile()
          end
        elseif (actor1.actorid < actor2.actorid) then
          actor1:wantStayForAWhile()
        else
          actor2:wantStayForAWhile()
        end
      end
    end
  end
end

-- 生物攻击命中
function ActorHelper:actorAttackHit (objid, toobjid)
  local actor = ActorHelper:getActor(objid)
  if (actor) then
    actor:attackHit(toobjid)
  end
end

-- 生物行为改变（仅开启AI有效）
function ActorHelper:actorChangeMotion (objid, actormotion)
  local actor = ActorHelper:getActor(objid)
  if (actor) then
    actor:changeMotion(actormotion)
  end
end

-- 生物死亡
function ActorHelper:actorDie (objid, toobjid)
  MonsterHelper:actorDie(objid, toobjid)
end

-- 封装原始接口

-- 向目标位置移动
function ActorHelper:tryMoveToPos (objid, x, y, z, speed)
  local onceFailMessage = '向目标移动失败一次'
  local finillyFailMessage = StringHelper:concat('向目标移动失败，参数：objid=', objid,
    ', x=', x, ', y=', y, ', z=', z, ', speed=', speed)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:tryMoveToPos(objid, x, y, z, speed)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 寻路到目标位置
function ActorHelper:tryNavigationToPos (objid, x, y, z, cancontrol)
  local onceFailMessage = '寻路到目标位置失败一次'
  local finillyFailMessage = StringHelper:concat('寻路到目标位置失败，参数：objid=', objid,
    ', x=', x, ', y=', y, ', z=', z, ', cancontrol=', cancontrol)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:tryNavigationToPos(objid, x, y, z, cancontrol)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置生物行为状态
function ActorHelper:setActionAttrState (objid, actionattr, switch)
  local onceFailMessage = '设置生物行为状态失败一次'
  local finillyFailMessage = StringHelper:concat('设置生物行为状态失败，参数：objid=',
    objid, ', actionattr=', actionattr, ', switch=', switch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:setActionAttrState(objid, actionattr, switch)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取生物行为状态
function ActorHelper:getActionAttrState (objid, actionattr)
  local onceFailMessage = '获取生物行为状态失败一次'
  local finillyFailMessage = StringHelper:concat('获取生物行为状态失败，参数：objid=',
    objid, ', actionattr=', actionattr)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getActionAttrState(objid, actionattr)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取生物位置
function ActorHelper:getPosition (objid)
  local onceFailMessage = '获取生物位置失败一次'
  -- local finillyFailMessage = StringHelper:concat('获取生物位置失败，参数：objid=', objid)
  local finillyFailMessage = nil
  return CommonHelper:callThreeResultMethod(function (p)
    return Actor:getPosition(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置生物位置
function ActorHelper:setPosition (objid, x, y, z)
  local onceFailMessage = '设置生物位置失败一次'
  local finillyFailMessage = StringHelper:concat('设置生物位置失败，参数：objid=', objid,
    ', x=', x, ', y=', y, ', z=', z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:setPosition(objid, x, y, z)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 清除生物ID为actorid的生物
function ActorHelper:clearActorWithId (actorid, bkill)
  local onceFailMessage = '清除生物失败一次'
  local finillyFailMessage = StringHelper:concat('清除生物失败，参数：actorid=', actorid,
    ', bkill=', bkill)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:clearActorWithId(actorid, bkill)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 是否是玩家
function ActorHelper:isPlayer (objid)
  return Actor:isPlayer(objid) == ErrorCode.OK
end

-- 播放动作
function ActorHelper:playAct (objid, actid)
  local onceFailMessage = '播放动作失败一次'
  local finillyFailMessage = StringHelper:concat('播放动作失败，参数：objid=', objid, ', actid=', actid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:playAct(objid, actid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取当前朝向
function ActorHelper:getCurPlaceDir (objid)
  local onceFailMessage = '获取当前朝向失败一次'
  local finillyFailMessage = StringHelper:concat('获取当前朝向失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getCurPlaceDir(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 增加指定BUFF
function ActorHelper:addBuff (objid, buffid, bufflv, customticks)
  local onceFailMessage = '增加指定BUFF失败一次'
  local finillyFailMessage = StringHelper:concat('增加指定BUFF失败，参数：objid=', objid,
    ', buffid=', buffid, ', bufflv=', bufflv, ', customticks=', customticks)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:addBuff(objid, buffid, bufflv, customticks)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 移除指定BUFF
function ActorHelper:removeBuff (objid, buffid)
  local onceFailMessage = '移除指定BUFF失败一次'
  local finillyFailMessage = StringHelper:concat('移除指定BUFF失败，参数：objid=', objid,
    ', buffid=', buffid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:removeBuff(objid, buffid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 清除全部BUFF
function ActorHelper:clearAllBuff (objid)
  local onceFailMessage = '清除全部BUFF失败一次'
  local finillyFailMessage = StringHelper:concat('清除全部BUFF失败，参数：objid=', objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:clearAllBuff(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 清除全部减益BUFF
function ActorHelper:clearAllBadBuff (objid)
  local onceFailMessage = '清除全部减益BUFF失败一次'
  local finillyFailMessage = StringHelper:concat('清除全部减益BUFF失败，参数：objid=', objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:clearAllBadBuff(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 是否已经有了指定BUFF
function ActorHelper:hasBuff (objid, buffid)
  return Actor:hasBuff(objid, buffid) == ErrorCode.OK
end

-- 设置actor原地旋转偏移角度
function ActorHelper:setFaceYaw (objid, yaw)
  local onceFailMessage = '设置actor原地旋转偏移角度失败一次'
  local finillyFailMessage = StringHelper:concat('设置actor原地旋转偏移角度失败，参数：objid=',
    objid, ', yaw=', yaw)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:setFaceYaw(objid, yaw)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取actor原地旋转偏移角度
function ActorHelper:getFaceYaw (objid)
  local onceFailMessage = '获取actor原地旋转偏移角度失败一次'
  local finillyFailMessage = StringHelper:concat('获取actor原地旋转偏移角度失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getFaceYaw(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取眼睛位置
function ActorHelper:getEyePosition (objid)
  local onceFailMessage = '获取眼睛位置失败一次'
  local finillyFailMessage = StringHelper:concat('获取眼睛位置失败，参数：objid=', objid)
  return CommonHelper:callThreeResultMethod(function (p)
    return Actor:getEyePosition(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置actor视角仰望角度
function ActorHelper:setFacePitch (objid, pitch)
  local onceFailMessage = '设置actor视角仰望角度失败一次'
  local finillyFailMessage = StringHelper:concat('设置actor视角仰望角度失败，参数：objid=',
    objid, ', pitch=', pitch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:setFacePitch(objid, pitch)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取actor视角仰望角度
function ActorHelper:getFacePitch (objid)
  local onceFailMessage = '获取actor视角仰望角度失败一次'
  local finillyFailMessage = StringHelper:concat('获取actor视角仰望角度失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getFacePitch(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 转动actor仰望偏移角度
function ActorHelper:turnFacePitch (objid, offset)
  local onceFailMessage = '转动actor仰望偏移角度失败一次'
  local finillyFailMessage = StringHelper:concat('转动actor仰望偏移角度失败，参数：objid=',
    objid, ', pitch=', pitch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:turnFacePitch(objid, offset)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取眼睛高度
function ActorHelper:getEyeHeight (objid)
  local onceFailMessage = '获取眼睛高度失败一次'
  local finillyFailMessage = StringHelper:concat('获取眼睛高度失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getEyeHeight(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 在指定Actor身上播放特效
function ActorHelper:playBodyEffectById (objid, particleId, scale)
  local onceFailMessage = '在指定Actor身上播放特效失败一次'
  local finillyFailMessage = StringHelper:concat('在指定玩家身上播放特效失败，参数：objid=',
    objid, ',particleId=', particleId, ',scale=', scale)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:playBodyEffectById(objid, particleId, scale)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 停止指定Actor身上的特效
function ActorHelper:stopBodyEffectById (objid, particleId)
  local onceFailMessage = '停止指定Actor身上的特效失败一次'
  local finillyFailMessage = StringHelper:concat('停止指定玩家身上的特效失败，参数：objid=',
    objid, ',particleId=', particleId)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:stopBodyEffectById(objid, particleId)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 在指定Actor身上播放音效
function ActorHelper:playSoundEffectById (objid, soundId, volume, pitch, isLoop)
  local onceFailMessage = '在指定Actor身上播放音效失败一次'
  local finillyFailMessage = StringHelper:concat('在指定Actor身上播放音效失败，参数：objid=',
    objid, ',soundId=', soundId)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:playSoundEffectById(objid, soundId, volume, pitch, isLoop)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 停止指定Actor身上的音效
function ActorHelper:stopSoundEffectById (objid, soundId)
  local onceFailMessage = '停止指定Actor身上的音效失败一次'
  local finillyFailMessage = StringHelper:concat('停止指定Actor身上的音效失败，参数：objid=',
    objid, ',soundId=', soundId)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:stopSoundEffectById(objid, soundId)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 给actor附加一个速度
function ActorHelper:appendSpeed (objid, x, y, z)
  local onceFailMessage = '给actor附加一个速度失败一次'
  local finillyFailMessage = StringHelper:concat('给actor附加一个速度失败，参数：objid=',
    objid, ',x=', x, ',y=', y, ',z=', z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:appendSpeed(objid, x, y, z)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 杀死自己
function ActorHelper:killSelf (objid)
  local onceFailMessage = '杀死自己失败一次'
  local finillyFailMessage = StringHelper:concat('杀死自己失败，参数：objid=', objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:killSelf(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 是否在空中（无用）
-- function ActorHelper:isInAir (objid)
--   return Actor:isInAir(objid) == ErrorCode.OK
-- end

-- 设置免疫伤害类型
function ActorHelper:setImmuneType (objid, immunetype, isadd)
  local onceFailMessage = '设置免疫伤害类型一次'
  local finillyFailMessage = StringHelper:concat('设置免疫伤害类型失败，参数：objid=', objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:setImmuneType(objid, immunetype, isadd)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取对象类型（玩家、生物、投掷物、掉落物等^）
function ActorHelper:getObjType (objid)
  local onceFailMessage = '获取对象类型失败一次'
  local finillyFailMessage = StringHelper:concat('获取对象类型失败，参数：objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getObjType(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取actor朝向
function ActorHelper:getFaceDirection (objid)
  local onceFailMessage = '获取actor朝向失败一次'
  local finillyFailMessage = StringHelper:concat('获取actor朝向失败，参数：objid=', objid)
  return CommonHelper:callThreeResultMethod(function (p)
    return Actor:getFaceDirection(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取身体尺寸 w, h
function ActorHelper:getBodySize (objid)
  local onceFailMessage = '获取身体尺寸失败一次'
  local finillyFailMessage = StringHelper:concat('获取身体尺寸失败，参数：objid=', objid)
  return CommonHelper:callTwoResultMethod(function (p)
    return Actor:getBodySize(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end