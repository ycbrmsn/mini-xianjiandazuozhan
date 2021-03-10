-- 事件绑定

-- eventobjid, toobjid
local playerEnterGame = function (event)
  LogHelper.call(function ()
    EventHelper.playerEnterGame(event.eventobjid)
    -- PlayerHelper.getHostPlayer().action:runTo({ { x = 0, y = 7, z = 70 } })
  end)
end

-- eventobjid, toobjid
local playerLeaveGame = function (event)
  LogHelper.call(function ()
    EventHelper.playerLeaveGame(event.eventobjid)
  end)
end

-- eventobjid, areaid
local playerEnterArea = function (event)
  local objid = event['eventobjid']
  local areaid = event['areaid']
  -- LogHelper.info('玩家进入区域', areaid % 1000)
  LogHelper.call(function ()
    EventHelper.playerEnterArea(objid, areaid)
  end)
end

-- eventobjid, areaid
local playerLeaveArea = function (event)
  local objid = event['eventobjid']
  local areaid = event['areaid']
  -- LogHelper.debug('玩家离开区域' .. areaid)
  LogHelper.call(function ()
    EventHelper.playerLeaveArea(objid, areaid)
  end)
end

-- eventobjid, blockid, x, y, z
local playerClickBlock = function (event)
  LogHelper.call(function ()
    local x, y, z = event.x, event.y, event.z
    EventHelper.playerClickBlock(event.eventobjid, event.blockid, x, y, z)
  end)
end

-- eventobjid toobjid itemid itemnum
local playerUseItem = function (event)
  local objid = event['eventobjid']
  LogHelper.call(function ()
    EventHelper.playerUseItem(objid, event.toobjid, event.itemid, event.itemnum)
  end)
end

-- eventobjid, toobjid, itemid, itemnum
local playerConsumeItem = function (event)
  LogHelper.call(function ()
    EventHelper.playerConsumeItem(event.eventobjid, event.toobjid, event.itemid, event.itemnum)
  end)
end

-- eventobjid, toobjid
local playerClickActor = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  -- local actorid = CreatureHelper.getActorID(toobjid)
  LogHelper.call(function ()
    EventHelper.playerClickActor(objid, toobjid)
  end)
end

-- eventobjid, toobjid, itemid, itemnum
local playerAddItem = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  local itemid = event['itemid']
  local itemnum = event['itemnum']
  -- LogHelper.info(objid, ',', toobjid, ',', itemid, ',', itemnum)
  LogHelper.call(function ()
    EventHelper.playerAddItem(objid, itemid, itemnum)
  end)
end

-- eventobjid, toobjid
local playerAttackHit = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  LogHelper.call(function ()
    -- LogHelper.debug('攻击命中')
    EventHelper.playerAttackHit(objid, toobjid)
  end)
end

-- eventobjid, toobjid, hurtlv
local playerDamageActor = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  LogHelper.call(function ()
    -- LogHelper.debug('造成伤害')
    EventHelper.playerDamageActor(objid, toobjid, event.hurtlv)
  end)
end

-- eventobjid, toobjid
local playerDefeatActor = function (event)
  LogHelper.call(function ()
    EventHelper.playerDefeatActor(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, toobjid, hurtlv
local playerBeHurt = function (event)
  LogHelper.call(function ()
    EventHelper.playerBeHurt(event.eventobjid, event.toobjid, event.hurtlv)
  end)
end

-- eventobjid, toobjid
local playerDie = function (event)
  LogHelper.call(function ()
    EventHelper.playerDie(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, toobjid
local playerRevive = function (event)
  LogHelper.call(function ()
    EventHelper.playerRevive(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, toobjid, itemid, itemnum
local playerSelectShortcut = function (event)
  local objid = event['eventobjid']
  LogHelper.call(function ()
    EventHelper.playerSelectShortcut(objid, event.toobjid, event.itemid, event.itemnum)
  end)
end

-- eventobjid, toobjid, itemid, itemnum
local playerShortcutChange = function (event)
  local objid = event['eventobjid']
  LogHelper.call(function ()
    EventHelper.playerShortcutChange(objid, event.toobjid, event.itemid, event.itemnum)
  end)
end

-- eventobjid, playermotion
local playerMotionStateChange = function (event)
  local objid = event['eventobjid']
  local playermotion = event['playermotion']
  LogHelper.call(function ()
    EventHelper.playerMotionStateChange(objid, playermotion)
  end)
end

-- eventobjid, toobjid
local playerMoveOneBlockSize = function (event)
  LogHelper.call(function ()
    EventHelper.playerMoveOneBlockSize(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, toobjid
local playerMountActor = function (event)
  LogHelper.call(function ()
    EventHelper.playerMountActor(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, toobjid
local playerDismountActor = function (event)
  LogHelper.call(function ()
    EventHelper.playerDismountActor(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, content
local playerInputContent = function (event)
  LogHelper.call(function ()
    EventHelper.playerInputContent(event.eventobjid, event.content)
  end)
end

-- eventobjid, content
local playerNewInputContent = function (event)
  LogHelper.call(function ()
    EventHelper.playerNewInputContent(event.eventobjid, event.content)
  end)
end

-- eventobjid, vkey
local playerInputKeyDown = function (event)
  LogHelper.call(function ()
    EventHelper.playerInputKeyDown(event.eventobjid, event.vkey)
  end)
end

-- eventobjid, vkey
local playerInputKeyOnPress = function (event)
  LogHelper.call(function ()
    EventHelper.playerInputKeyOnPress(event.eventobjid, event.vkey)
  end)
end

-- eventobjid, vkey
local playerInputKeyUp = function (event)
  LogHelper.call(function ()
    EventHelper.playerInputKeyUp(event.eventobjid, event.vkey)
  end)
end

-- eventobjid, toobjid
local playerLevelModelUpgrade = function (event)
  LogHelper.call(function ()
    EventHelper.playerLevelModelUpgrade(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, playerattr
local playerChangeAttr = function (event)
  LogHelper.call(function ()
    EventHelper.playerChangeAttr(event.eventobjid, event.playerattr)
  end)
end

-- eventobjid, buffid, bufflvl
local playerAddBuff = function (event)
  LogHelper.call(function ()
    EventHelper.playerAddBuff(event.eventobjid, event.buffid, event.bufflvl)
  end)
end

-- eventobjid, buffid, bufflvl
local playerRemoveBuff = function (event)
  LogHelper.call(function ()
    EventHelper.playerRemoveBuff(event.eventobjid, event.buffid, event.bufflvl)
  end)
end

-- eventobjid, toobjid
local actorCreate = function (event)
  LogHelper.call(function ()
    EventHelper.actorCreate(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, areaid
local actorEnterArea = function (event)
  local objid = event['eventobjid']
  local areaid = event['areaid']
  -- LogHelper.debug(objid .. '进入了区域' .. areaid)
  LogHelper.call(function ()
    EventHelper.actorEnterArea(objid, areaid)
  end)
end

-- eventobjid, areaid
local actorLeaveArea = function (event)
  local objid = event['eventobjid']
  local areaid = event['areaid']
  -- LogHelper.debug(objid .. '离开了区域' .. areaid)
  LogHelper.call(function ()
    EventHelper.actorLeaveArea(objid, areaid)
  end)
end

-- eventobjid, toobjid
local actorCollide = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  LogHelper.call(function ()
    EventHelper.actorCollide(objid, toobjid)
  end)
end

-- eventobjid, toobjid
local actorAttackHit = function (event)
  LogHelper.call(function ()
    EventHelper.actorAttackHit(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, toobjid
local actorBeat = function (event)
  LogHelper.call(function ()
    EventHelper.actorBeat(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, actormotion
local actorChangeMotion = function (event)
  LogHelper.call(function ()
    EventHelper.actorChangeMotion(event.eventobjid, event.actormotion)
  end)
end

-- eventobjid, toobjid, hurtlv
local actorBeHurt = function (event)
  LogHelper.call(function ()
    EventHelper.actorBeHurt(event.eventobjid, event.toobjid, event.hurtlv)
  end)
end

-- eventobjid, toobjid
local actorDie = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  LogHelper.call(function ()
    EventHelper.actorDie(objid, toobjid)
  end)
end

-- eventobjid, buffid, bufflvl
local actorAddBuff = function (event)
  LogHelper.call(function ()
    EventHelper.actorAddBuff(event.eventobjid, event.buffid, event.bufflvl)
  end)
end

-- eventobjid, buffid, bufflvl
local actorRemoveBuff = function (event)
  LogHelper.call(function ()
    EventHelper.actorRemoveBuff(event.eventobjid, event.buffid, event.bufflvl)
  end)
end

-- eventobjid, actorattr
local actorChangeAttr = function (event)
  LogHelper.call(function ()
    EventHelper.actorChangeAttr(event.eventobjid, event.actorattr)
  end)
end

-- eventobjid, toobjid(opt), blockid(opt), x, y, z
local actorProjectileHit = function (event)
  local projectileid, toobjid, blockid = event.eventobjid, event.toobjid, event.blockid
  local x, y, z = event.x, event.y, event.z
  LogHelper.call(function ()
    -- LogHelper.debug('投掷物命中')
    EventHelper.projectileHit(projectileid, toobjid, blockid, x, y, z)
  end)
end

-- eventobjid, toobjid, itemid, x, y, z
local missileCreate = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper.call(function ()
    EventHelper.missileCreate(event.eventobjid, event.toobjid, event.itemid, x, y, z)
  end)
end

-- eventobjid(opt), blockid, x, y, z
local blockDestroyBy = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper.call(function ()
    EventHelper.blockDestroyBy(event.eventobjid, event.blockid, x, y, z)
  end)
end

-- eventobjid, blockid, x, y, z
local blockDigEnd = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper.call(function ()
    EventHelper.blockDigEnd(event.eventobjid, event.blockid, x, y, z)
  end)
end

-- eventobjid, blockid, x, y, z
local blockPlaceBy = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper.call(function ()
    EventHelper.blockPlaceBy(event.eventobjid, event.blockid, x, y, z)
  end)
end

-- blockid, x, y, z
local blockRemove = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper.call(function ()
    EventHelper.blockRemove(event.blockid, x, y, z)
  end)
end

-- eventobjid, blockid, x, y, z
local blockTrigger = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper.call(function ()
    EventHelper.blockTrigger(event.eventobjid, event.blockid, x, y, z)
  end)
end

-- blockid, x, y, z, itemid, itemnum
local backpackItemTakeOut = function (event)
  local x, y, z = event.x, event.y, event.z
  LogHelper.call(function ()
    EventHelper.backpackItemTakeOut(event.blockid, x, y, z, event.itemid, event.itemnum)
  end)
end

-- 无参数
local startGame = function ()
  -- LogHelper.debug('开始游戏')
  LogHelper.call(function ()
    EventHelper.startGame()
  end)
end

-- 无参数
local runGame = function ()
  LogHelper.call(function ()
    EventHelper.runGame()
  end)
end

-- 无参数
local endGame = function ()
  LogHelper.call(function ()
    EventHelper.endGame()
  end)
end

-- hour
local atHour = function (event)
  local hour = event['hour']
  LogHelper.call(function ()
    EventHelper.atHour(hour)
  end)
end

-- second
local atSecond = function (event)
  local second = event['second']
  LogHelper.call(function ()
    EventHelper.atSecond(second)
  end)
end

-- timerid, timername
local minitimerChange = function (event)
  LogHelper.call(function ()
    EventHelper.minitimerChange(event.timerid, event.timername)
  end)
end

ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=], playerEnterGame) -- 玩家进入游戏
ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.LeaveGame]=], playerLeaveGame) -- 玩家离开游戏
ScriptSupportEvent:registerEvent([=[Player.AreaIn]=], playerEnterArea) -- 玩家进入区域
ScriptSupportEvent:registerEvent([=[Player.AreaOut]=], playerLeaveArea) -- 玩家离开区域
ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], playerClickBlock) -- 点击方块
ScriptSupportEvent:registerEvent([=[Player.UseItem]=], playerUseItem) -- 玩家使用物品
ScriptSupportEvent:registerEvent([=[Player.ConsumeItem]=], playerConsumeItem) -- 玩家消耗道具
ScriptSupportEvent:registerEvent([=[Player.ClickActor]=], playerClickActor) -- 玩家点击生物
ScriptSupportEvent:registerEvent([=[Player.AddItem]=], playerAddItem) -- 玩家新增道具
ScriptSupportEvent:registerEvent([=[Player.AttackHit]=], playerAttackHit) -- 玩家攻击命中
ScriptSupportEvent:registerEvent([=[Player.DamageActor]=], playerDamageActor) -- 玩家给对方造成伤害
ScriptSupportEvent:registerEvent([=[Player.DefeatActor]=], playerDefeatActor) -- 打败目标
ScriptSupportEvent:registerEvent([=[Player.BeHurt]=], playerBeHurt) -- 受到伤害
ScriptSupportEvent:registerEvent([=[Player.Die]=], playerDie) -- 玩家死亡
ScriptSupportEvent:registerEvent([=[Player.Revive]=], playerRevive) -- 玩家复活
ScriptSupportEvent:registerEvent([=[Player.SelectShortcut]=], playerSelectShortcut) -- 选择快捷栏
ScriptSupportEvent:registerEvent([=[Player.ShortcutChange]=], playerShortcutChange) -- 快捷栏变化
ScriptSupportEvent:registerEvent([=[Player.MotionStateChange]=], playerMotionStateChange) -- 运动状态改变
ScriptSupportEvent:registerEvent([=[Player.MoveOneBlockSize]=], playerMoveOneBlockSize) -- 移动一格
ScriptSupportEvent:registerEvent([=[Player.MountActor]=], playerMountActor) -- 骑乘坐骑
ScriptSupportEvent:registerEvent([=[Player.DismountActor]=], playerDismountActor) -- 取消骑乘坐骑
ScriptSupportEvent:registerEvent([=[Player.InputContent]=], playerInputContent) -- 聊天输出界面变化
ScriptSupportEvent:registerEvent([=[Player.NewInputContent]=], playerNewInputContent) -- 输入字符串
ScriptSupportEvent:registerEvent([=[Player.InputKeyDown]=], playerInputKeyDown) -- 按键被按下
ScriptSupportEvent:registerEvent([=[Player.InputKeyOnPress]=], playerInputKeyOnPress) -- 按键处于按下状态
ScriptSupportEvent:registerEvent([=[Player.InputKeyUp]=], playerInputKeyUp) -- 按键松开
ScriptSupportEvent:registerEvent([=[Player.LevelModelUpgrade]=], playerLevelModelUpgrade) -- 玩家等级发生改变
ScriptSupportEvent:registerEvent([=[Player.ChangeAttr]=], playerChangeAttr) -- 属性变化
ScriptSupportEvent:registerEvent([=[Player.AddBuff]=], playerAddBuff) -- 玩家获得状态效果
ScriptSupportEvent:registerEvent([=[Player.RemoveBuff]=], playerRemoveBuff) -- 玩家失去状态效果

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

ScriptSupportEvent:registerEvent([=[Game.Start]=], startGame) -- 开始游戏
ScriptSupportEvent:registerEvent([=[Game.End]=], endGame) -- 结束游戏
ScriptSupportEvent:registerEvent([=[Game.Hour]=], atHour) -- 世界时间到[n]点
ScriptSupportEvent:registerEvent([=[Game.Run]=], runGame) -- 游戏运行时
ScriptSupportEvent:registerEvent([=[Game.RunTime]=], atSecond) -- 世界时间到[n]秒
ScriptSupportEvent:registerEvent([=[minitimer.change]=], minitimerChange) -- 任意计时器发生变化
