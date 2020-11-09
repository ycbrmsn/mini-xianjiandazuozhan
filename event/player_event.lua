-- 玩家事件

-- eventobjid, areaid
local playerEnterArea = function (event)
  local objid = event['eventobjid']
  local areaid = event['areaid']
  -- LogHelper:info('玩家进入区域', areaid % 1000)
  LogHelper:call(function ()
    MyPlayerHelper:playerEnterArea(objid, areaid)
  end)
end

-- eventobjid, areaid
local playerLeaveArea = function (event)
  local objid = event['eventobjid']
  local areaid = event['areaid']
  -- LogHelper:debug('玩家离开区域' .. areaid)
  LogHelper:call(function ()
    MyPlayerHelper:playerLeaveArea(objid, areaid)
  end)
end

-- eventobjid, blockid, x, y, z
local playerClickBlock = function (event)
  LogHelper:call(function ()
    local x, y, z = event.x, event.y, event.z
    MyPlayerHelper:playerClickBlock(event.eventobjid, event.blockid, x, y, z)
  end)
end

-- eventobjid toobjid itemid itemnum
local playerUseItem = function (event)
  local objid = event['eventobjid']
  LogHelper:call(function ()
    MyPlayerHelper:playerUseItem(objid, event.toobjid, event.itemid, event.itemnum)
  end)
end

-- eventobjid, toobjid, itemid, itemnum
local playerConsumeItem = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerConsumeItem(event.eventobjid, event.toobjid, event.itemid, event.itemnum)
  end)
end

-- eventobjid, toobjid
local playerClickActor = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  -- local actorid = CreatureHelper:getActorID(toobjid)
  LogHelper:call(function ()
    MyPlayerHelper:playerClickActor(objid, toobjid)
  end)
end

-- eventobjid, toobjid, itemid, itemnum
local playerAddItem = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  local itemid = event['itemid']
  local itemnum = event['itemnum']
  -- LogHelper:info(objid, ',', toobjid, ',', itemid, ',', itemnum)
  LogHelper:call(function ()
    MyPlayerHelper:playerAddItem(objid, itemid, itemnum)
  end)
end

-- eventobjid, toobjid
local playerAttackHit = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  LogHelper:call(function ()
    -- LogHelper:debug('攻击命中')
    MyPlayerHelper:playerAttackHit(objid, toobjid)
  end)
end

-- eventobjid, toobjid, hurtlv
local playerDamageActor = function (event)
  local objid = event['eventobjid']
  local toobjid = event['toobjid']
  LogHelper:call(function ()
    -- LogHelper:debug('造成伤害')
    MyPlayerHelper:playerDamageActor(objid, toobjid, event.hurtlv)
  end)
end

-- eventobjid, toobjid
local playerDefeatActor = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerDefeatActor(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, toobjid, hurtlv
local playerBeHurt = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerBeHurt(event.eventobjid, event.toobjid, event.hurtlv)
  end)
end

-- eventobjid, toobjid
local playerDie = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerDie(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, toobjid
local playerRevive = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerRevive(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, toobjid, itemid, itemnum
local playerSelectShortcut = function (event)
  local objid = event['eventobjid']
  LogHelper:call(function ()
    MyPlayerHelper:playerSelectShortcut(objid, event.toobjid, event.itemid, event.itemnum)
  end)
end

-- eventobjid, toobjid, itemid, itemnum
local playerShortcutChange = function (event)
  local objid = event['eventobjid']
  LogHelper:call(function ()
    MyPlayerHelper:playerShortcutChange(objid, event.toobjid, event.itemid, event.itemnum)
  end)
end

-- eventobjid, playermotion
local playerMotionStateChange = function (event)
  local objid = event['eventobjid']
  local playermotion = event['playermotion']
  LogHelper:call(function ()
    MyPlayerHelper:playerMotionStateChange(objid, playermotion)
  end)
end

-- eventobjid, toobjid
local playerMoveOneBlockSize = function (event)
  local objid = event['eventobjid']
  LogHelper:call(function ()
    MyPlayerHelper:playerMoveOneBlockSize(objid)
  end)
end

-- eventobjid, toobjid
local playerMountActor = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerMountActor(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, toobjid
local playerDismountActor = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerDismountActor(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, content
local playerInputContent = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerInputContent(event.eventobjid, event.content)
  end)
end

-- eventobjid, content
local playerNewInputContent = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerNewInputContent(event.eventobjid, event.content)
  end)
end

-- eventobjid, vkey
local playerInputKeyDown = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerInputKeyDown(event.eventobjid, event.vkey)
  end)
end

-- eventobjid, vkey
local playerInputKeyOnPress = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerInputKeyOnPress(event.eventobjid, event.vkey)
  end)
end

-- eventobjid, vkey
local playerInputKeyUp = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerInputKeyUp(event.eventobjid, event.vkey)
  end)
end

-- eventobjid, toobjid
local playerLevelModelUpgrade = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerLevelModelUpgrade(event.eventobjid, event.toobjid)
  end)
end

-- eventobjid, playerattr
local playerChangeAttr = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerChangeAttr(event.eventobjid, event.playerattr)
  end)
end

-- eventobjid, buffid, bufflvl
local playerAddBuff = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerAddBuff(event.eventobjid, event.buffid, event.bufflvl)
  end)
end

-- eventobjid, buffid, bufflvl
local playerRemoveBuff = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerRemoveBuff(event.eventobjid, event.buffid, event.bufflvl)
  end)
end

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
