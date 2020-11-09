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
  clickActors = {}, -- 玩家点击的actor：objid -> actor
  actormotions = {}, -- 生物及其当前对应的状态 { objid -> motion }
  initActorObjids = {}, -- 初始化生物时，每个玩家附近的所有生物的id数组 { time -> objids }
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

-- 获得生物行为
function ActorHelper:getActorMontion (objid)
  return self.actormotions[objid]
end

-- 设置生物行为
function ActorHelper:setActorMotion (objid, actormotion)
  self.actormotions[objid] = actormotion
end

-- 获取初始化生物时玩家附近找到的生物数组
function ActorHelper:getInitActorObjids ()
  local time = TimeHelper:getTime()
  local objids = self.initActorObjids[time]
  if (not(objids)) then
    objids = {}
    PlayerHelper:everyPlayerDoSomeThing(function (player)
      local pos = player:getMyPosition()
      if (pos) then
        local ids = WorldHelper:getCreaturesAroundPos(pos)
        if (ids and #ids > 0) then
          for i, objid in ipairs(ids) do
            table.insert(objids, objid)
          end
        end
      end
    end)
    self.initActorObjids[time] = objids
    TimeHelper:callFnAfterSecond(function ()
      self.initActorObjids[time] = nil
    end, 1)
  end
  return objids
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

-- 获取角色朝向多远的位置
function ActorHelper:getFaceDistancePosition (objid, distance)
  local pos = MyPosition:new(ActorHelper:getEyePosition(objid))
  local x, y, z = ActorHelper:getFaceDirection(objid)
  local len = MathHelper:getVector3Length(x, y, z)
  local ratio = distance / len
  pos.x, pos.y, pos.z = pos.x + x * ratio, pos.y + y * ratio, pos.z + z * ratio
  return pos
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
    ActorActionHelper:createMoveToPos(nextWant)
    myActor.action:execute()
    -- LogHelper:debug('开始移动')
  elseif (nextWant.style == 'approach') then
    ActorActionHelper:createApproachToPos(nextWant)
    myActor.action:execute()
  elseif (nextWant.style == 'freeInArea' or nextWant.style == 'freeAttack') then
    nextWant.toPos = ActorActionHelper:getFreeInAreaPos(myActor.freeInAreaIds)
    ActorActionHelper:createMoveToPos(nextWant)
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
    nextWant.currentRestTime = nextWant.restTime
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
  local prevActor = player:getClickActor()
  if (not(prevActor) or prevActor ~= myActor) then -- 点击生物不同
    player:breakTalk()
  end
  player:setClickActor(myActor)
end

-- 准备恢复被点击的生物之前的行为，并终止对话
function ActorHelper:resumeClickActor (objid)
  local myActor = self.clickActors[objid]
  if (myActor) then
    if (myActor.wants and #myActor.wants > 0) then
      local want = myActor.wants[1]
      local t = myActor.objid .. 'lookat'
      if (TimeHelper:isFnContinueRuns(t)) then -- 正在看，就停止
        TimeHelper:delFnContinueRuns(t)
        want.currentRestTime = 3
        self.clickActors[objid] = nil
      end
    end
    -- 终止对话
    local player = PlayerHelper:getPlayer(objid)
    player:breakTalk()
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
  for k, actor in pairs(self.actors) do
    if (not(actor:isWantsExist()) or actor.wants[1].think ~= 'forceDoNothing') then
      actor:wantAtHour(hour)
    end
  end
end

-- 所有特定生物重新开始干现在应该干的事情
function ActorHelper:doItNow ()
  for k, actor in pairs(self.actors) do
    if (not(actor:isWantsExist()) or actor.wants[1].think ~= 'forceDoNothing') then
      actor:doItNow()
    end
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
function ActorHelper:isInAir (objid, x, y, z)
  local pos = self:getMyPosition(objid)
  if (not(x)) then
    x, y, z = pos.x, pos.y, pos.z
  end
  local w = ActorHelper:getBodySize(objid)
  local r = w / 2 - 0.001 -- 去掉一点浮点误差
  if (not(BlockHelper:isAirBlock(x, y, z)) or 
    not(BlockHelper:isAirBlock(x - r, y, z)) or
    not(BlockHelper:isAirBlock(x + r, y, z)) or
    not(BlockHelper:isAirBlock(x, y, z - r)) or
    not(BlockHelper:isAirBlock(x, y, z + r))) then -- 生物位置不是空气
    return false
  else
    y = y - 1
    if (BlockHelper:isAirBlock(x, y, z) and
      BlockHelper:isAirBlock(x - r, y, z) and
      BlockHelper:isAirBlock(x + r, y, z) and
      BlockHelper:isAirBlock(x, y, z - r) and
      BlockHelper:isAirBlock(x, y, z + r)) then -- 生物下方位置是空气
      return true
    else -- 下方位置不是空气
      -- 判断玩家位置是不是很接近与整数
      return y - math.floor(y) > 0.1
    end
  end
end

-- 前后左右中下六个位置如果有一个位置不是空气方块，那么就是靠近了方块  是否忽视脚下位置
function ActorHelper:isApproachBlock (objid, ignoreDown)
  local pos = self:getMyPosition(objid)
  return (BlockHelper:isInvisibleBlockOffset(pos)
      and BlockHelper:isInvisibleBlockOffset(pos, -1)
      and BlockHelper:isInvisibleBlockOffset(pos, 1)
      and (ignoreDown or BlockHelper:isInvisibleBlockOffset(pos, 0, -1))
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
function ActorHelper:addGravity (obj)
  local objid = obj.objid
  local t = objid .. 'addGravity'
  TimeHelper:callFnContinueRuns(function ()
    local pos = ActorHelper:getMyPosition(objid)
    if (pos) then
      if (pos:equals(obj.pos)) then -- 没有动
        obj.index = (obj.index or 0) + 1
        if (obj.index > 20) then
          TimeHelper:callFnFastRuns(function ()
            TimeHelper:delFnContinueRuns(t)
            WorldHelper:despawnActor(obj.objid)
          end, 3)
        end
      else
        obj.pos = pos
        obj.index = 0
      end
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

-- 对角色造成伤害  攻击者、被攻击者、造成伤害、使用道具（记录的特殊道具）
function ActorHelper:damageActor (objid, toobjid, val, item)
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
      if (isPlayer) then
        MyPlayerHelper:playerDamageActor(objid, toobjid, val)
      end
      hp = hp - val
      PlayerHelper:setHp(toobjid, hp)
    else -- 玩家可能会死亡，则检测玩家是否可被杀死
      local ableBeKilled = PlayerHelper:getPlayerEnableBeKilled(toobjid)
      if (ableBeKilled) then -- 能被杀死
        if (isPlayer) then -- 攻击者是玩家
          MyPlayerHelper:playerDamageActor(objid, toobjid, val)
          MyPlayerHelper:playerDefeatActor(objid, toobjid, item)
        else -- 攻击者是生物，目前暂不处理
        end
        ActorHelper:killSelf(toobjid)
      else -- 不能被杀死
        if (isPlayer) then -- 攻击者是玩家
          MyPlayerHelper:playerDamageActor(objid, toobjid, hp - 1)
        end
        PlayerHelper:setHp(toobjid, 1)
      end
    end
  else -- 伤害了生物
    local hp = CreatureHelper:getHp(toobjid)
    if (not(hp) or hp <= 0) then -- 未找到生物或生物已经死亡
      return
    end
    if (hp > val) then -- 生物不会死亡
      if (isPlayer) then
        MyPlayerHelper:playerDamageActor(objid, toobjid, val)
      end
      hp = hp - val
      CreatureHelper:setHp(toobjid, hp)
    else -- 生物可能会死亡，则检测生物是否可被杀死
      local ableBeKilled = ActorHelper:getEnableBeKilledState(toobjid)
      if (ableBeKilled) then -- 能被杀死
        if (isPlayer) then -- 攻击者是玩家
          MyPlayerHelper:playerDamageActor(objid, toobjid, val)
          MyPlayerHelper:playerDefeatActor(objid, toobjid, item)
        else -- 攻击者是生物，目前暂不处理
        end
        ActorHelper:killSelf(toobjid)
      else -- 不能被杀死
        if (isPlayer) then -- 攻击者是玩家
          MyPlayerHelper:playerDamageActor(objid, toobjid, hp - 1)
        end
        CreatureHelper:setHp(toobjid, 1)
      end
    end
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
    if (hp and hp > 0) then
      table.insert(aliveObjids, v)
    end
  end
  return aliveObjids
end

-- 获取有攻击目标的生物
function ActorHelper:getHasTargetActors (objids)
  local arr = {}
  if (type(objids) == 'table') then
    for i, objid in ipairs(objids) do
      local actor = ActorHelper:getActor(objid)
      if (actor) then -- 特定生物，则加入
        table.insert(arr, objid)
      else -- 非特定生物
        local motion = ActorHelper:getActorMontion(objid)
        if (motion and (motion == CREATUREMOTION.ATK_MELEE or 
          motion == CREATUREMOTION.ATK_REMOTE)) then
          table.insert(arr, objid)
        end
      end
    end
  end
  return arr
end

-- 角色看向 执行者、目标、是否需要旋转镜头（三维视角需要旋转），toobjid可以是objid、位置、玩家、生物
function ActorHelper:lookAt (objid, toobjid, needRotateCamera)
  -- LogHelper:debug('lookat')
  if (type(objid) == 'table') then -- 如果执行者是多个（数组）
    for i, v in ipairs(objid) do
      ActorHelper:lookAt(v, toobjid, needRotateCamera)
    end
  else -- 单个执行者
    local x, y, z
    if (type(toobjid) == 'table') then
      -- 判断是不是玩家或者生物
      if (toobjid.objid) then -- 玩家或生物
        toobjid = toobjid.objid
      else -- 是个位置
        x, y, z = toobjid.x, toobjid.y, toobjid.z
      end
    end
    if (not(x)) then -- 不是位置
      x, y, z = ActorHelper:getPosition(toobjid)
      if (not(x)) then -- 取不到目标角色数据
        return
      end
      y = y + ActorHelper:getEyeHeight(toobjid)
    end
    local x0, y0, z0 = ActorHelper:getPosition(objid)
    if (not(x0)) then -- 取不到执行者数据
      return
    end
    y0 = y0 + ActorHelper:getEyeHeight(objid)
    local myVector3 = MyVector3:new(x0, y0, z0, x, y, z)
    if (ActorHelper:isPlayer(objid) and needRotateCamera) then -- 如果执行者是三维视角玩家
      local faceYaw, facePitch
      if (x ~= x0 or z ~= z0) then -- 不在同一竖直位置上
        faceYaw = MathHelper:getPlayerFaceYaw(myVector3)
        facePitch = MathHelper:getActorFacePitch(myVector3)
      else -- 在同一竖直位置上
        faceYaw = ActorHelper:getFaceYaw(objid)
        if (y0 < y) then -- 向上
          facePitch = -90
        elseif (y0 > y) then -- 向下
          facePitch = 90
        else -- 水平
          facePitch = 0
        end
      end
      PlayerHelper:rotateCamera(objid, faceYaw, facePitch)
    else -- 执行者是生物或二维视角玩家
      local facePitch
      if (x ~= x0 or z ~= z0) then -- 不在同一竖直位置上
        local faceYaw = MathHelper:getActorFaceYaw(myVector3)
        ActorHelper:setFaceYaw(objid, faceYaw)
        facePitch = MathHelper:getActorFacePitch(myVector3)
      else -- 在同一竖直位置上
        if (y0 < y) then -- 向上
          facePitch = -90
        elseif (y0 > y) then -- 向下
          facePitch = 90
        else -- 水平
          facePitch = 0
        end
      end
      local result = ActorHelper:setFacePitch(objid, facePitch)
      if (not(result)) then
        LogHelper:debug(myVector3)
      end
    end
  end
end

-- 是否在水中
function ActorHelper:isInWater (objid)
  local pos = ActorHelper:getMyPosition(objid)
  return AreaHelper:isWaterArea(pos)
end

-- 播放并停止特效
function ActorHelper:playAndStopBodyEffectById (objid, particleId, scale, time)
  scale = scale or 1
  time = time or 3
  ActorHelper:playBodyEffectById(objid, particleId, scale)
  local t = 'stopBodyEffect'
  TimeHelper:callFnLastRun(objid, t, function ()
    ActorHelper:stopBodyEffectById(objid, particleId)
  end, time)
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
  if (doorPos) then -- 确定是门位置，则打开这个门
    BlockHelper:openDoor(doorPos.x, doorPos.y, doorPos.z)
  else -- 不确定是不是门位置，则判断，规定两格大小的都是门位置
    local isDoorArea, pos = AreaHelper:isDoorArea(areaid)
    if (isDoorArea) then
      AreaHelper.allDoorAreas[areaid] = pos
      BlockHelper:openDoor(pos.x, pos.y, pos.z)
    elseif (type(isDoorArea) == 'nil') then
      LogHelper:debug(CreatureHelper:getActorName(objid))
    end
  end
  if (myActor and myActor.wants) then -- 找到了一个actor，并且这个actor有想法
    local want = myActor.wants[1]
    if (want.toAreaId == areaid) then -- 如果是该actor的终点区域，则判断actor是仅仅前往还是巡逻
      if (want.style == 'move' or want.style == 'approach') then -- 如果是仅仅前往，则变更想法，并且停下来
        -- LogHelper:debug(myActor:getName() .. '进入了终点区域' .. areaid)
        AreaHelper:removeToArea(myActor) -- 清除终点区域
        -- AreaHelper:destroyArea(want.toAreaId) 
        local pos = ActorActionHelper:getNextPos(want)
        -- LogHelper:debug(myActor:getName(), pos)
        if (pos) then -- 有下一个行动位置
          want.toPos = pos
          ActorActionHelper:createMoveToPos(want)
          myActor.action:execute()
          -- LogHelper:debug(myActor:getName(), '向下一个位置出发')
        elseif (myActor.wants[2]) then
          if (want.callback) then
            want.callback()
          end
          self:handleNextWant(myActor)
        else
          if (want.callback) then
            want.callback()
          end
          if (not(myActor:isWantsExist()) or myActor.wants[1] == want) then
            myActor:defaultWant()
            myActor:wantStayForAWhile()
          end
        end
      elseif (want.style == 'patrol') then -- 如果是巡逻，则停下来并设定前往目的地
        AreaHelper:removeToArea(myActor) -- 清除终点区域
        -- AreaHelper:destroyArea(want.toAreaId) -- 清除终点区域
        want.currentRestTime = want.restTime
        want.toPos = ActorActionHelper:getNextPos(want)
        -- LogHelper:debug('下一个位置' .. type(want.toPos))
        ActorActionHelper:createMoveToPos(want)
      elseif (want.style == 'freeInArea') then -- 区域内自由移动
        AreaHelper:removeToArea(myActor) -- 清除终点区域
        -- AreaHelper:destroyArea(want.toAreaId) -- 清除终点区域
        want.currentRestTime = want.restTime
        want.toPos = ActorActionHelper:getFreeInAreaPos(myActor.freeInAreaIds)
        ActorActionHelper:createMoveToPos(want)
      elseif (want.style == 'freeAttack') then -- 区域自由攻击
        AreaHelper:removeToArea(myActor) -- 清除终点区域
        want.currentRestTime = want.restTime
        want.toPos = ActorActionHelper:getFreeInAreaPos(myActor.freeInAreaIds)
        ActorActionHelper:createMoveToPos(want)
        myActor.action:playAttack(2)
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
      if (not(actor1:isWantsExist()) or actor1.wants[1].think ~= 'forceDoNothing') then
        actor1:defaultCollidePlayerEvent(toobjid, ActorHelper:isTwoInFrontOfOne(objid, toobjid))
      end
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

-- 生物击败目标
function ActorHelper:actorBeat (objid, toobjid)
  -- body
end

-- 生物行为改变（仅开启AI有效）
function ActorHelper:actorChangeMotion (objid, actormotion)
  local t = objid .. 'actorChangeMotion'
  local motion = ActorHelper:getActorMontion(objid)
  if (not(motion) or motion ~= actormotion) then
    ActorHelper:setActorMotion(objid, actormotion)
    TimeHelper:delFnFastRuns(t)
  end
  -- 保留的记录30秒后删除
  TimeHelper:callFnFastRuns(function ()
    ActorHelper:setActorMotion(objid, nil)
  end, 30, t)

  local actor = ActorHelper:getActor(objid)
  if (actor) then
    actor:changeMotion(actormotion)
  end
end

-- 生物受到伤害
function ActorHelper:actorBeHurt (objid, toobjid, hurtlv)
  local actor = ActorHelper:getActor(objid)
  if (actor) then
    actor:beHurt(toobjid, hurtlv)
  end
  -- body
end

-- 生物死亡
function ActorHelper:actorDie (objid, toobjid)
  MonsterHelper:actorDie(objid, toobjid)
end

-- 生物获得状态效果
function ActorHelper:actorAddBuff (objid, buffid, bufflvl)
  local actor = ActorHelper:getActor(objid)
  if (actor) then
    actor:addBuff(buffid, bufflvl)
  end
  -- body
end

-- 生物失去状态效果
function ActorHelper:actorRemoveBuff (objid, buffid, bufflvl)
  local actor = ActorHelper:getActor(objid)
  if (actor) then
    actor:removeBuff(buffid, bufflvl)
  end
  -- body
end

-- 封装原始接口

-- 向目标位置移动
function ActorHelper:tryMoveToPos (objid, x, y, z, speed)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:tryMoveToPos(objid, x, y, z, speed)
  end, '向目标位置移动', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z, ',speed=', speed)
end

-- 寻路到目标位置
function ActorHelper:tryNavigationToPos (objid, x, y, z, cancontrol, bshowtip)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:tryNavigationToPos(objid, x, y, z, cancontrol, bshowtip)
  end, '寻路到目标位置', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z,
    ',cancontrol=', cancontrol, ',bshowtip=', bshowtip)
end

-- 设置生物行为状态
function ActorHelper:setActionAttrState (objid, actionattr, switch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:setActionAttrState(objid, actionattr, switch)
  end, '设置生物行为状态', 'objid=', objid, ',actionattr=', actionattr, ',switch=', switch)
end

-- 获取生物行为状态
function ActorHelper:getActionAttrState (objid, actionattr)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getActionAttrState(objid, actionattr)
  end, '获取生物行为状态', 'objid=', objid, ',actionattr=', actionattr)
end

-- 获取生物位置，返回x, y, z
function ActorHelper:getPosition (objid)
  return CommonHelper:callThreeResultMethod(function (p)
    return Actor:getPosition(objid)
  end, nil, 'objid=', objid)
end

-- 设置生物位置
function ActorHelper:setPosition (objid, x, y, z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:setPosition(objid, x, y, z)
  end, '设置生物位置', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end

-- 清除生物ID为actorid的生物
function ActorHelper:clearActorWithId (actorid, bkill)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:clearActorWithId(actorid, bkill)
  end, '清除生物ID为actorid的生物', 'actorid=', actorid, ',bkill=', bkill)
end

-- 是否是玩家
function ActorHelper:isPlayer (objid)
  return Actor:isPlayer(objid) == ErrorCode.OK
end

-- 播放动作
function ActorHelper:playAct (objid, actid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:playAct(objid, actid)
  end, '播放动作', 'objid=', objid, ',actid=', actid)
end

-- 获取当前朝向
function ActorHelper:getCurPlaceDir (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getCurPlaceDir(objid)
  end, '获取当前朝向', 'objid=', objid)
end

-- 增加指定BUFF
function ActorHelper:addBuff (objid, buffid, bufflv, customticks)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:addBuff(objid, buffid, bufflv, customticks)
  end, '增加指定BUFF', 'objid=', objid, ',buffid=', buffid, ',bufflv=', bufflv,
    ',customticks=', customticks)
end

-- 移除指定BUFF
function ActorHelper:removeBuff (objid, buffid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:removeBuff(objid, buffid)
  end, '移除指定BUFF', 'objid=', objid,',buffid=', buffid)
end

-- 清除全部BUFF
function ActorHelper:clearAllBuff (objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:clearAllBuff(objid)
  end, '清除全部BUFF', 'objid=', objid)
end

-- 清除全部减益BUFF
function ActorHelper:clearAllBadBuff (objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:clearAllBadBuff(objid)
  end, '清除全部减益BUFF', 'objid=', objid)
end

-- 是否已经有了指定BUFF
function ActorHelper:hasBuff (objid, buffid)
  return Actor:hasBuff(objid, buffid) == ErrorCode.OK
end

-- 设置actor原地旋转偏移角度
function ActorHelper:setFaceYaw (objid, yaw)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:setFaceYaw(objid, yaw)
  end, '设置actor原地旋转偏移角度', 'objid=', objid, ',yaw=', yaw)
end

-- 获取actor原地旋转偏移角度
function ActorHelper:getFaceYaw (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getFaceYaw(objid)
  end, '获取actor原地旋转偏移角度', 'objid=', objid)
end

-- 获取眼睛位置
function ActorHelper:getEyePosition (objid)
  return CommonHelper:callThreeResultMethod(function (p)
    return Actor:getEyePosition(objid)
  end, '获取眼睛位置', 'objid=', objid)
end

-- 设置actor视角仰望角度
function ActorHelper:setFacePitch (objid, pitch)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:setFacePitch(objid, pitch)
  end, '设置actor视角仰望角度', 'objid=', objid, ',pitch=', pitch)
end

-- 获取actor视角仰望角度
function ActorHelper:getFacePitch (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getFacePitch(objid)
  end, '获取actor视角仰望角度', 'objid=', objid)
end

-- 转动actor仰望偏移角度
function ActorHelper:turnFacePitch (objid, offset)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:turnFacePitch(objid, offset)
  end, '转动actor仰望偏移角度', 'objid=', objid, ',offset=', offset)
end

-- 获取眼睛高度
function ActorHelper:getEyeHeight (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getEyeHeight(objid)
  end, '获取眼睛高度', 'objid=', objid)
end

-- 在指定Actor身上播放特效
function ActorHelper:playBodyEffectById (objid, particleId, scale)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:playBodyEffectById(objid, particleId, scale)
  end, '在指定Actor身上播放特效', 'objid=', objid, ',particleId=', particleId,
    ',scale=', scale)
end

-- 停止指定Actor身上的特效
function ActorHelper:stopBodyEffectById (objid, particleId)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:stopBodyEffectById(objid, particleId)
  end, '停止指定Actor身上的特效', 'objid=', objid, ',particleId=', particleId)
end

-- 在指定Actor身上播放音效
function ActorHelper:playSoundEffectById (objid, soundId, volume, pitch, isLoop)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:playSoundEffectById(objid, soundId, volume, pitch, isLoop)
  end, '在指定Actor身上播放音效', 'objid=', objid, ',soundId=', soundId, ',volume=',
    volume, ',pitch=', pitch, ',isLoop=', isLoop)
end

-- 停止指定Actor身上的音效
function ActorHelper:stopSoundEffectById (objid, soundId)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:stopSoundEffectById(objid, soundId)
  end, '停止指定Actor身上的音效', 'objid=', objid, ',soundId=', soundId)
end

-- 给actor附加一个速度
function ActorHelper:appendSpeed (objid, x, y, z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:appendSpeed(objid, x, y, z)
  end, '给actor附加一个速度', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end

-- 杀死自己
function ActorHelper:killSelf (objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:killSelf(objid)
  end, '杀死自己', 'objid=', objid)
end

-- 是否在空中（2020-09-02测试无效）
-- function ActorHelper:isInAir (objid)
--   return Actor:isInAir(objid) == ErrorCode.OK
-- end

-- 设置免疫伤害类型
function ActorHelper:setImmuneType (objid, immunetype, isadd)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Actor:setImmuneType(objid, immunetype, isadd)
  end, '设置免疫伤害类型', 'objid=', objid, ',immunetype=', immunetype, ',isadd=', isadd)
end

-- 获取对象类型（玩家、生物、投掷物、掉落物等^）
function ActorHelper:getObjType (objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Actor:getObjType(objid)
  end, '获取对象类型', 'objid=', objid)
end

-- 获取actor朝向 返回x,y,z
function ActorHelper:getFaceDirection (objid)
  return CommonHelper:callThreeResultMethod(function (p)
    return Actor:getFaceDirection(objid)
  end, '获取actor朝向', 'objid=', objid)
end

-- 获取身体尺寸 w, h
function ActorHelper:getBodySize (objid)
  return CommonHelper:callTwoResultMethod(function (p)
    return Actor:getBodySize(objid)
  end, '获取身体尺寸', 'objid=', objid)
end