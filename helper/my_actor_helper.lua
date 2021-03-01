-- 我的角色工具类
MyActorHelper = {
  checkDim = { x = 16, y = 50, z = 16 }, -- 检测范围
  speakDim = { x = 12, y = 12, z = 12 },
  attackRunSpeed = 500 -- 攻击时的移动速度
}

-- 初始化actors
function MyActorHelper.init ()
  linqianshu = Linqianshu:new()
  linwanshu = Linwanshu:new()
  yexiaolong = Yexiaolong:new()
  yedalong = Yedalong:new()
  local myActors = { linqianshu, linwanshu, yexiaolong, yedalong }
  for i, v in ipairs(myActors) do
    TimeHelper.initActor(v)
    -- LogHelper.debug('创建', v:getName(), '完成')
  end
end

-- 初始化林千树与林万树每秒行为
function MyActorHelper.initLinqianshu (actor)
  TimeHelper.repeatUtilSuccess(actor.objid, 'doPerSecond', function ()
    -- 位置过高或过低则回到初始位置
    local pos = actor:getMyPosition()
    if (not(pos)) then
      return false
    elseif (pos.y < 7 or pos.y > 15) then
      WorldHelper.playBodyEffect(pos, BaseConstant.BODY_EFFECT.LIGHT30)
      actor:setPosition(actor.initPosition)
      ActorHelper.playAndStopBodyEffect(actor.objid, BaseConstant.BODY_EFFECT.LIGHT1, 1, 2)
      return false
    end
    if (actor.think and (actor.think == 'goHome' or actor.think == 'sleep')) then
      actor:closeAI()
    else -- 人物在闲逛
      local playerids = ActorHelper.getAllPlayersArroundPos(pos, MyActorHelper.checkDim, 
        actor.objid, false)
      playerids = ActorHelper.getAliveActors(playerids)
      if (playerids and #playerids > 0) then -- 发现敌方玩家
        local targetObjid = ActorHelper.getNearestActor(playerids, pos)
        local dstPos = ActorHelper.getMyPosition(targetObjid)
        local distance = MathHelper.getDistance(pos, dstPos)
        if (distance > 10) then
          actor:closeAI()
        else
          actor:openAI()
        end
        actor:runTo(dstPos, MyActorHelper.attackRunSpeed)
        if (not(actor.target.objid) or actor.target.objid ~= targetObjid) then
          actor.target.objid = targetObjid
          actor.target.time = 0
          actor:speakTo(targetObjid, 0, '速速离去，休怪我不客气')
        else -- 相同目标
          if (actor.target.time % 5 == 0 and 
            not(SkillHelper.hasHuitianCircle(actor.objid))) then -- 每5秒一次回天剑诀
            actor.action:playAttack()
            SkillHelper.huitian(actor.objid, 1)
          end
          actor.target.time = actor.target.time + 1
          if (actor.target.time % 5 == 0) then -- 每5秒一次万剑诀
            SkillHelper.tenThousandsSwordcraft(actor.objid, 0, dstPos)
          end
        end
      else
        actor:openAI()
        SkillHelper.clearHuitian(actor.objid)
        actor.target.objid = nil -- 清除目标
      end
    end
    return false
  end, 1)
end

-- 初始化叶小龙与叶大龙每秒行为
function MyActorHelper.initYexiaolong (actor)
  TimeHelper.repeatUtilSuccess(actor.objid, 'doPerSecond', function ()
    -- 位置过高或过低则回到初始位置
    local pos = actor:getMyPosition()
    if (not(pos)) then
      return false
    elseif (pos.y < 7 or pos.y > 15) then
      WorldHelper.playBodyEffect(pos, BaseConstant.BODY_EFFECT.LIGHT30)
      actor:setPosition(actor.initPosition)
      ActorHelper.playAndStopBodyEffect(actor.objid, BaseConstant.BODY_EFFECT.LIGHT1, 1, 2)
      return false
    end
    if (actor.think and (actor.think == 'goHome' or actor.think == 'sleep')) then
      actor:closeAI()
    else -- 人物在闲逛
      local playerids = ActorHelper.getAllPlayersArroundPos(pos, MyActorHelper.checkDim, 
        actor.objid, false)
      playerids = ActorHelper.getAliveActors(playerids)
      if (playerids and #playerids > 0) then -- 发现敌方玩家
        local targetObjid = ActorHelper.getNearestActor(playerids, pos)
        local dstPos = ActorHelper.getMyPosition(targetObjid)
        local distance = MathHelper.getDistance(pos, dstPos)
        if (distance > 10) then
          actor:closeAI()
        else
          actor:openAI()
        end
        actor:runTo(dstPos, MyActorHelper.attackRunSpeed)
        if (not(actor.target.objid) or actor.target.objid ~= targetObjid) then
          actor.target.objid = targetObjid
          actor.target.time = 0
          actor:speakTo(targetObjid, 0, '逃跑趁早，不然小命不保')
        else -- 相同目标
          if (actor.target.time % 5 == 0 and 
            not(SkillHelper.hasHuitianCircle(actor.objid))) then -- 每5秒一次回天剑诀
            actor.action:playAttack()
            SkillHelper.huitian(actor.objid, 2)
          end
          actor.target.time = actor.target.time + 1
          if (actor.target.time % 5 == 0) then -- 每5秒一次万剑诀
            SkillHelper.tenThousandsSwordcraft(actor.objid, 0, dstPos)
          end
        end
      else
        actor:openAI()
        SkillHelper.clearHuitian(actor.objid)
        actor.target.objid = nil -- 清除目标
      end
    end
    return false
  end, 1)
end

function MyActorHelper.updateHp (objid)
  local offset
  local monsterModel = MonsterHelper.getMonsterModel(objid)
  if (monsterModel) then
    offset = monsterModel.offset
  else
    offset = 110
  end
  ActorHelper.updateHp(objid, offset)
end

-- 事件

-- 生物被创建
function MyActorHelper.actorCreate (objid, toobjid)
  ActorHelper.actorCreate(objid, toobjid)
  MyStoryHelper.actorCreate(objid, toobjid)
  -- body
  MyActorHelper.updateHp(objid)
end

-- actor进入区域
function MyActorHelper.actorEnterArea (objid, areaid)
  ActorHelper.actorEnterArea(objid, areaid)
  MyStoryHelper.actorEnterArea(objid, areaid)
end

-- actor离开区域
function MyActorHelper.actorLeaveArea (objid, areaid)
  ActorHelper.actorLeaveArea(objid, areaid)
  MyStoryHelper.actorLeaveArea(objid, areaid)
end

-- 生物碰撞
function MyActorHelper.actorCollide (objid, toobjid)
  ActorHelper.actorCollide(objid, toobjid)
  MyStoryHelper.actorCollide(objid, toobjid)
end

-- 生物攻击命中
function MyActorHelper.actorAttackHit (objid, toobjid)
  ActorHelper.actorAttackHit(objid, toobjid)
  MyStoryHelper.actorAttackHit(objid, toobjid)
end

-- 生物击败目标
function MyActorHelper.actorBeat (objid, toobjid)
  ActorHelper.actorBeat(objid, toobjid)
  MyStoryHelper.actorBeat(objid, toobjid)
  -- body
  if (ActorHelper.isPlayer(toobjid)) then -- 击败玩家
    local monsterModel = MonsterHelper.getMonsterModel(objid)
    if (monsterModel and monsterModel.attackSpeak) then
      monsterModel:attackSpeak(toobjid)
    end
  end
end

-- 生物行为改变
function MyActorHelper.actorChangeMotion (objid, actormotion)
  ActorHelper.actorChangeMotion(objid, actormotion)
  MyStoryHelper.actorChangeMotion(objid, actormotion)
  -- body
end

-- 生物受到伤害
function MyActorHelper.actorBeHurt (objid, toobjid, hurtlv)
  ActorHelper.actorBeHurt(objid, toobjid, hurtlv)
  MyStoryHelper.actorBeHurt(objid, toobjid, hurtlv)
  -- body
end

-- 生物死亡
function MyActorHelper.actorDie (objid, toobjid)
  ActorHelper.actorDie(objid, toobjid)
  MyStoryHelper.actorDie(objid, toobjid)
  -- body
  -- MyActorHelper.updateHp(objid)
end

-- 生物获得状态效果
function MyActorHelper.actorAddBuff (objid, buffid, bufflvl)
  ActorHelper.actorAddBuff(objid, buffid, bufflvl)
  MyStoryHelper.actorAddBuff(objid, buffid, bufflvl)
  -- body
end

-- 生物失去状态效果
function MyActorHelper.actorRemoveBuff (objid, buffid, bufflvl)
  ActorHelper.actorRemoveBuff(objid, buffid, bufflvl)
  MyStoryHelper.actorRemoveBuff(objid, buffid, bufflvl)
  -- body
end

-- 生物属性变化
function MyActorHelper.actorChangeAttr (objid, actorattr)
  ActorHelper.actorChangeAttr(objid, actorattr)
  MyStoryHelper.actorChangeAttr(objid, actorattr)
  -- body
  if (actorattr == CREATUREATTR.CUR_HP) then
    MyActorHelper.updateHp(objid)
  end
end