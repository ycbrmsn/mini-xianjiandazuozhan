-- 生物事件

-- eventobjid, toobjid
local actorCreate = function (event)
  LogHelper:call(function ()
    MyActorHelper:actorCreate(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, areaid
local actorEnterArea = function (event)
  local objid = event['eventobjid']
  local areaid = event['areaid']
  -- LogHelper:debug(objid .. '进入了区域' .. areaid)
  LogHelper:call(function ()
    MyActorHelper:actorEnterArea(objid, areaid)
  end)
end

-- eventobjid, areaid
local actorLeaveArea = function (event)
  local objid = event['eventobjid']
  local areaid = event['areaid']
  -- LogHelper:debug(objid .. '离开了区域' .. areaid)
  LogHelper:call(function ()
    MyActorHelper:actorLeaveArea(objid, areaid)
  end)
end

-- eventobjid, toobjid
local actorCollide = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  LogHelper:call(function ()
    MyActorHelper:actorCollide(objid, toobjid)
  end)
end

-- eventobjid, toobjid
local actorAttackHit = function (event)
  LogHelper:call(function ()
    MyActorHelper:actorAttackHit(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, toobjid
local actorBeat = function (event)
  LogHelper:call(function ()
    MyActorHelper:actorBeat(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, actormotion
local actorChangeMotion = function (event)
  LogHelper:call(function ()
    MyActorHelper:actorChangeMotion(event.eventobjid, event.actormotion)
  end)
end

-- eventobjid, toobjid, hurtlv
local actorBeHurt = function (event)
  LogHelper:call(function ()
    MyActorHelper:actorBeHurt(event.eventobjid, event.toobjid, event.hurtlv)
  end)
end

-- eventobjid, toobjid
local actorDie = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  LogHelper:call(function ()
    MyActorHelper:actorDie(objid, toobjid)
  end)
end

-- eventobjid, buffid, bufflvl
local actorAddBuff = function (event)
  LogHelper:call(function ()
    MyActorHelper:actorAddBuff(event.eventobjid, event.buffid, event.bufflvl)
  end)
end

-- eventobjid, buffid, bufflvl
local actorRemoveBuff = function (event)
  LogHelper:call(function ()
    MyActorHelper:actorRemoveBuff(event.eventobjid, event.buffid, event.bufflvl)
  end)
end

-- eventobjid, actorattr
local actorChangeAttr = function (event)
  LogHelper:call(function ()
    MyActorHelper:actorChangeAttr(event.eventobjid, event.actorattr)
  end)
end

-- eventobjid, toobjid(opt), blockid(opt), x, y, z
local actorProjectileHit = function (event)
  local projectileid, toobjid, blockid = event.eventobjid, event.toobjid, event.blockid
  local x, y, z = event.x, event.y, event.z
  LogHelper:call(function ()
    -- LogHelper:debug('投掷物命中')
    MyItemHelper:projectileHit(projectileid, toobjid, blockid, x, y, z)
  end)
end

-- eventobjid, toobjid, itemid, x, y, z
local missileCreate = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper:call(function ()
    MyItemHelper:missileCreate(event.eventobjid, event.toobjid, event.itemid, x, y, z)
  end)
end

-- eventobjid(opt), blockid, x, y, z
local blockDestroyBy = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper:call(function ()
    MyBlockHelper:blockDestroyBy(event.eventobjid, event.blockid, x, y, z)
  end)
end

-- eventobjid, blockid, x, y, z
local blockDigEnd = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper:call(function ()
    MyBlockHelper:blockDigEnd(event.eventobjid, event.blockid, x, y, z)
  end)
end

-- eventobjid, blockid, x, y, z
local blockPlaceBy = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper:call(function ()
    MyBlockHelper:blockPlaceBy(event.eventobjid, event.blockid, x, y, z)
  end)
end

-- blockid, x, y, z
local blockRemove = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper:call(function ()
    MyBlockHelper:blockRemove(event.blockid, x, y, z)
  end)
end

-- eventobjid, blockid, x, y, z
local blockTrigger = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper:call(function ()
    MyBlockHelper:blockTrigger(event.eventobjid, event.blockid, x, y, z)
  end)
end

-- blockid, x, y, z, itemid, itemnum
local backpackItemTakeOut = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper:call(function ()
    MyBackpackHelper:backpackItemTakeOut(event.blockid, x, y, z, event.itemid, event.itemnum)
  end)
end

ScriptSupportEvent:registerEvent([=[Actor.Create]=], actorCreate) -- 生物被创建
ScriptSupportEvent:registerEvent([=[Actor.AreaIn]=], actorEnterArea) -- 生物进入区域
ScriptSupportEvent:registerEvent([=[Actor.AreaOut]=], actorLeaveArea) -- 生物离开区域
ScriptSupportEvent:registerEvent([=[Actor.Collide]=], actorCollide) -- 生物发生碰撞
ScriptSupportEvent:registerEvent([=[Actor.AttackHit]=], actorAttackHit) -- 生物攻击命中
ScriptSupportEvent:registerEvent([=[Actor.Beat]=], actorBeat) -- 生物击败玩家/生物
ScriptSupportEvent:registerEvent([=[Actor.ChangeMotion]=], actorChangeMotion) -- 生物行为状态变更
ScriptSupportEvent:registerEvent([=[Actor.BeHurt]=], actorBeHurt) -- 生物受到伤害
ScriptSupportEvent:registerEvent([=[Actor.Die]=], actorDie) -- 生物死亡
ScriptSupportEvent:registerEvent([=[Actor.AddBuff]=], actorAddBuff) -- 生物获得状态效果
ScriptSupportEvent:registerEvent([=[Actor.RemoveBuff]=], actorRemoveBuff) -- 生物失去状态效果
ScriptSupportEvent:registerEvent([=[Actor.ChangeAttr]=], actorChangeAttr) -- 生物属性变化

ScriptSupportEvent:registerEvent([=[Actor.Projectile.Hit]=], actorProjectileHit) -- 投掷物击中
ScriptSupportEvent:registerEvent([=[Missile.Create]=], missileCreate) -- 投掷物被创建
ScriptSupportEvent:registerEvent([=[Block.DestroyBy]=], blockDestroyBy) -- 方块被破坏
ScriptSupportEvent:registerEvent([=[Block.Dig.End]=], blockDigEnd) -- 完成方块挖掘
ScriptSupportEvent:registerEvent([=[Block.PlaceBy]=], blockPlaceBy) -- 方块被放置
ScriptSupportEvent:registerEvent([=[Block.Remove]=], blockRemove) -- 方块被移除
ScriptSupportEvent:registerEvent([=[Block.Trigger]=], blockTrigger) -- 方块被触发
ScriptSupportEvent:registerEvent([=[Backpack.ItemTakeOut]=], backpackItemTakeOut) -- 容器内有道具取出
