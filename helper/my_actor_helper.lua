-- 我的角色工具类
MyActorHelper = {
  checkDim = { x = 16, y = 50, z = 16 }, -- 检测范围
  attackRunSpeed = 500 -- 攻击时的移动速度
}

-- 初始化actors
function MyActorHelper:init ()
  linqianshu = Linqianshu:new()
  linwanshu = Linwanshu:new()
  yexiaolong = Yexiaolong:new()
  yedalong = Yedalong:new()
  local myActors = { linqianshu, linwanshu, yexiaolong, yedalong }
  for i, v in ipairs(myActors) do
    TimeHelper:initActor(v)
    -- LogHelper:debug('创建', v:getName(), '完成')
  end
  -- LogHelper:debug('创建人物完成')
end

-- 初始化林千树与林万树每秒行为
function MyActorHelper:initLinqianshu (actor)
  TimeHelper:repeatUtilSuccess(actor.objid, 'doPerMinute', function ()
    if (actor.think and (actor.think == 'goHome' or actor.think == 'sleep')) then
    else -- 人物在闲逛
      local pos = actor:getMyPosition()
      local playerids = ActorHelper:getAllPlayersArroundPos(pos, self.checkDim, 
        actor.objid, false)
      if (playerids and #playerids > 0) then -- 发现敌方玩家
        local targetObjid = ActorHelper:getNearestActor(playerids, pos)
        local dstPos = ActorHelper:getMyPosition(targetObjid)
        actor:runTo(dstPos, self.attackRunSpeed)
        if (not(actor.target.objid) or actor.target.objid ~= targetObjid) then
          actor.target.objid = targetObjid
          actor.target.time = 0
        else -- 相同目标
          if (actor.target.time % 5 == 0 and 
            not(SkillHelper:hasHuitianCircle(actor.objid))) then -- 每5秒一次回天剑诀
            actor.action:playAttack()
            SkillHelper:huitian(actor.objid, 1)
          end
          actor.target.time = actor.target.time + 1
          if (actor.target.time % 5 == 0) then -- 每5秒一次万剑诀
            SkillHelper:tenThousandsSwordcraft(actor.objid, 0, dstPos)
          end
        end
      else
        SkillHelper:clearHuitian(actor.objid)
        actor.target.objid = nil -- 清除目标
      end
    end
    return false
  end, 1)
end

-- 初始化叶小龙与叶大龙每秒行为
function MyActorHelper:initYexiaolong (actor)
  TimeHelper:repeatUtilSuccess(actor.objid, 'doPerMinute', function ()
    if (actor.think and (actor.think == 'goHome' or actor.think == 'sleep')) then
    else -- 人物在闲逛
      local pos = actor:getMyPosition()
      local playerids = ActorHelper:getAllPlayersArroundPos(pos, self.checkDim, 
        actor.objid, false)
      if (playerids and #playerids > 0) then -- 发现敌方玩家
        local targetObjid = ActorHelper:getNearestActor(playerids, pos)
        local dstPos = ActorHelper:getMyPosition(targetObjid)
        actor:runTo(dstPos, self.attackRunSpeed)
        if (not(actor.target.objid) or actor.target.objid ~= targetObjid) then
          actor.target.objid = targetObjid
          actor.target.time = 0
        else -- 相同目标
          if (actor.target.time % 5 == 0 and 
            not(SkillHelper:hasHuitianCircle(actor.objid))) then -- 每5秒一次回天剑诀
            actor.action:playAttack()
            SkillHelper:huitian(actor.objid, 2)
          end
          actor.target.time = actor.target.time + 1
          if (actor.target.time % 5 == 0) then -- 每5秒一次万剑诀
            SkillHelper:tenThousandsSwordcraft(actor.objid, 1, dstPos)
          end
        end
      else
        SkillHelper:clearHuitian(actor.objid)
        actor.target.objid = nil -- 清除目标
      end
    end
    return false
  end, 1)
end

-- 事件

-- actor进入区域
function MyActorHelper:actorEnterArea (objid, areaid)
  ActorHelper:actorEnterArea(objid, areaid)
  MyStoryHelper:actorEnterArea(objid, areaid)
end

-- actor离开区域
function MyActorHelper:actorLeaveArea (objid, areaid)
  ActorHelper:actorLeaveArea(objid, areaid)
  MyStoryHelper:actorLeaveArea(objid, areaid)
end

-- 生物碰撞
function MyActorHelper:actorCollide (objid, toobjid)
  ActorHelper:actorCollide(objid, toobjid)
  MyStoryHelper:actorCollide(objid, toobjid)
end

-- 生物攻击命中
function MyActorHelper:actorAttackHit (objid, toobjid)
  ActorHelper:actorAttackHit(objid, toobjid)
  MyStoryHelper:actorAttackHit(objid, toobjid)
end

-- 生物行为改变
function MyActorHelper:actorChangeMotion (objid, actormotion)
  ActorHelper:actorChangeMotion(objid, actormotion)
  MyStoryHelper:actorChangeMotion(objid, actormotion)
end

-- 生物死亡
function MyActorHelper:actorDie (objid, toobjid)
  ActorHelper:actorDie(objid, toobjid)
  MyStoryHelper:actorDie(objid, toobjid)
end