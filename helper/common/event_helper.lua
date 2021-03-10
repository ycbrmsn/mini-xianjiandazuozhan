-- 事件工具类
EventHelper = {
  func = {}, -- eventname -> [函数数组]
}

-- 新增事件
function EventHelper.addEvent (eventname, f)
  if (not(EventHelper.func[eventname])) then
    EventHelper.func[eventname] = { f }
  else
    table.insert(EventHelper.func[eventname], f)
  end
end

-- 自定义方法
function EventHelper.customEvent (eventname, ...)
  local fs = EventHelper.func[eventname]
  if (fs) then
    for i, v in ipairs(fs) do
      v(...)
    end
  end
end

-- 玩家事件

-- 玩家进入游戏
function EventHelper.playerEnterGame (objid)
  PlayerHelper.playerEnterGame(objid)
  EventHelper.customEvent('playerEnterGame', objid)
end

-- 玩家离开游戏
function EventHelper.playerLeaveGame (objid)
  PlayerHelper.playerLeaveGame(objid)
  EventHelper.customEvent('playerLeaveGame', objid)
end

-- 玩家进入区域
function EventHelper.playerEnterArea (objid, areaid)
  PlayerHelper.playerEnterArea(objid, areaid)
  EventHelper.customEvent('playerEnterArea', objid, areaid)
end

-- 玩家离开区域
function EventHelper.playerLeaveArea (objid, areaid)
  PlayerHelper.playerLeaveArea(objid, areaid)
  EventHelper.customEvent('playerLeaveArea', objid, areaid)
end

-- 玩家点击方块
function EventHelper.playerClickBlock (objid, blockid, x, y, z)
  PlayerHelper.playerClickBlock(objid, blockid, x, y, z)
  EventHelper.customEvent('playerClickBlock', objid, blockid, x, y, z)
  -- body
end

-- 玩家点击生物
function EventHelper.playerClickActor (objid, toobjid)
  PlayerHelper.playerClickActor(objid, toobjid)
  EventHelper.customEvent('playerClickActor', objid, toobjid)
end

-- 玩家获得道具
function EventHelper.playerAddItem (objid, itemid, itemnum)
  PlayerHelper.playerAddItem(objid, itemid, itemnum)
  EventHelper.customEvent('playerAddItem', objid, itemid, itemnum)
  TaskHelper.addItem(objid, itemid, true)
end

-- 玩家使用道具
function EventHelper.playerUseItem (objid, toobjid, itemid, itemnum)
  PlayerHelper.playerUseItem(objid, toobjid, itemid, itemnum)
  EventHelper.customEvent('playerUseItem', objid, toobjid, itemid, itemnum)
end

-- 玩家消耗道具
function EventHelper.playerConsumeItem (objid, toobjid, itemid, itemnum)
  PlayerHelper.playerConsumeItem(objid, toobjid, itemid, itemnum)
  EventHelper.customEvent('playerConsumeItem', objid, toobjid, itemid, itemnum)
end

-- 玩家攻击命中
function EventHelper.playerAttackHit (objid, toobjid)
  PlayerHelper.playerAttackHit(objid, toobjid)
  EventHelper.customEvent('playerAttackHit', objid, toobjid)
end

-- 玩家造成伤害
function EventHelper.playerDamageActor (objid, toobjid, hurtlv)
  PlayerHelper.playerDamageActor(objid, toobjid)
  EventHelper.customEvent('playerDamageActor', objid, toobjid, hurtlv)
end

-- 玩家击败目标 item参数是自己加的，为自定义道具
function EventHelper.playerDefeatActor (objid, toobjid, item)
  local realDefeat = PlayerHelper.playerDefeatActor(objid, toobjid)
  if (not(realDefeat)) then -- 是重复击败，则不执行下面的内容
    return
  end
  if (ActorHelper.isPlayer(toobjid)) then -- 击败玩家
    TaskHelper.killActor(objid, -1, true)
  else
    TaskHelper.killActor(objid, CreatureHelper.getActorID(toobjid), true)
  end
  EventHelper.customEvent('playerDefeatActor', objid, toobjid, item)
end

-- 玩家受到伤害
function EventHelper.playerBeHurt (objid, toobjid, hurtlv)
  PlayerHelper.playerBeHurt(objid, toobjid, hurtlv)
  EventHelper.customEvent('playerBeHurt', objid, toobjid, hurtlv)
end

-- 玩家死亡
function EventHelper.playerDie (objid, toobjid)
  PlayerHelper.playerDie(objid, toobjid)
  EventHelper.customEvent('playerDie', objid, toobjid)
end

-- 玩家复活
function EventHelper.playerRevive (objid, toobjid)
  PlayerHelper.playerRevive(objid, toobjid)
  EventHelper.customEvent('playerRevive', objid, toobjid)
end

-- 玩家选择快捷栏
function EventHelper.playerSelectShortcut (objid, toobjid, itemid, itemnum)
  PlayerHelper.playerSelectShortcut(objid, toobjid, itemid, itemnum)
  EventHelper.customEvent('playerSelectShortcut', objid, toobjid, itemid, itemnum)
end

-- 玩家快捷栏变化
function EventHelper.playerShortcutChange (objid, toobjid, itemid, itemnum)
  PlayerHelper.playerShortcutChange(objid, toobjid, itemid, itemnum)
  EventHelper.customEvent('playerShortcutChange', objid, toobjid, itemid, itemnum)
end

-- 玩家运动状态改变
function EventHelper.playerMotionStateChange (objid, playermotion)
  PlayerHelper.playerMotionStateChange(objid, playermotion)
  EventHelper.customEvent('playerMotionStateChange', objid, playermotion)
end

-- 玩家移动一格
function EventHelper.playerMoveOneBlockSize (objid, toobjid)
  PlayerHelper.playerMoveOneBlockSize(objid, toobjid)
  EventHelper.customEvent('playerMoveOneBlockSize', objid, toobjid)
end

-- 玩家骑乘
function EventHelper.playerMountActor (objid, toobjid)
  PlayerHelper.playerMountActor(objid, toobjid)
  EventHelper.customEvent('playerMountActor', objid, toobjid)
end

-- 玩家取消骑乘
function EventHelper.playerDismountActor (objid, toobjid)
  PlayerHelper.playerDismountActor(objid, toobjid)
  EventHelper.customEvent('playerDismountActor', objid, toobjid)
end

-- 聊天输出界面变化
function EventHelper.playerInputContent(objid, content)
  PlayerHelper.playerInputContent(objid, content)
  EventHelper.customEvent('playerInputContent', objid, content)
end

-- 输入字符串
function EventHelper.playerNewInputContent(objid, content)
  PlayerHelper.playerNewInputContent(objid, content)
  EventHelper.customEvent('playerNewInputContent', objid, content)
end

-- 按键被按下
function EventHelper.playerInputKeyDown (objid, vkey)
  PlayerHelper.playerInputKeyDown(objid, vkey)
  EventHelper.customEvent('playerInputKeyDown', objid, vkey)
end

-- 按键处于按下状态
function EventHelper.playerInputKeyOnPress (objid, vkey)
  PlayerHelper.playerInputKeyOnPress(objid, vkey)
  EventHelper.customEvent('playerInputKeyOnPress', objid, vkey)
end

-- 按键松开
function EventHelper.playerInputKeyUp (objid, vkey)
  PlayerHelper.playerInputKeyUp(objid, vkey)
  EventHelper.customEvent('playerInputKeyUp', objid, vkey)
end

-- 等级发生变化
function EventHelper.playerLevelModelUpgrade (objid, toobjid)
  PlayerHelper.playerLevelModelUpgrade(objid, toobjid)
  EventHelper.customEvent('playerLevelModelUpgrade', objid, toobjid)
end

-- 属性变化
function EventHelper.playerChangeAttr (objid, playerattr)
  PlayerHelper.playerChangeAttr(objid, playerattr)
  EventHelper.customEvent('playerChangeAttr', objid, playerattr)
end

-- 玩家获得状态效果
function EventHelper.playerAddBuff (objid, buffid, bufflvl)
  PlayerHelper.playerAddBuff(objid, buffid, bufflvl)
  EventHelper.customEvent('playerAddBuff', objid, buffid, bufflvl)
end

-- 玩家失去状态效果
function EventHelper.playerRemoveBuff (objid, buffid, bufflvl)
  PlayerHelper.playerRemoveBuff(objid, buffid, bufflvl)
  EventHelper.customEvent('playerRemoveBuff', objid, buffid, bufflvl)
end

-- 生物事件

-- 生物被创建
function EventHelper.actorCreate (objid, toobjid)
  ActorHelper.actorCreate(objid, toobjid)
  EventHelper.customEvent('actorCreate', objid, toobjid)
end

-- actor进入区域
function EventHelper.actorEnterArea (objid, areaid)
  ActorHelper.actorEnterArea(objid, areaid)
  EventHelper.customEvent('actorEnterArea', objid, areaid)
end

-- actor离开区域
function EventHelper.actorLeaveArea (objid, areaid)
  ActorHelper.actorLeaveArea(objid, areaid)
  EventHelper.customEvent('actorLeaveArea', objid, areaid)
end

-- 生物碰撞
function EventHelper.actorCollide (objid, toobjid)
  ActorHelper.actorCollide(objid, toobjid)
  EventHelper.customEvent('actorCollide', objid, toobjid)
end

-- 生物攻击命中
function EventHelper.actorAttackHit (objid, toobjid)
  ActorHelper.actorAttackHit(objid, toobjid)
  EventHelper.customEvent('actorAttackHit', objid, toobjid)
end

-- 生物击败目标
function EventHelper.actorBeat (objid, toobjid)
  ActorHelper.actorBeat(objid, toobjid)
  EventHelper.customEvent('actorBeat', objid, toobjid)
end

-- 生物行为改变
function EventHelper.actorChangeMotion (objid, actormotion)
  ActorHelper.actorChangeMotion(objid, actormotion)
  EventHelper.customEvent('actorChangeMotion', objid, actormotion)
end

-- 生物受到伤害
function EventHelper.actorBeHurt (objid, toobjid, hurtlv)
  ActorHelper.actorBeHurt(objid, toobjid, hurtlv)
  EventHelper.customEvent('actorBeHurt', objid, toobjid, hurtlv)
end

-- 生物死亡
function EventHelper.actorDie (objid, toobjid)
  ActorHelper.actorDie(objid, toobjid)
  EventHelper.customEvent('actorDie', objid, toobjid)
end

-- 生物获得状态效果
function EventHelper.actorAddBuff (objid, buffid, bufflvl)
  ActorHelper.actorAddBuff(objid, buffid, bufflvl)
  EventHelper.customEvent('actorAddBuff', objid, buffid, bufflvl)
end

-- 生物失去状态效果
function EventHelper.actorRemoveBuff (objid, buffid, bufflvl)
  ActorHelper.actorRemoveBuff(objid, buffid, bufflvl)
  EventHelper.customEvent('actorRemoveBuff', objid, buffid, bufflvl)
end

-- 生物属性变化
function EventHelper.actorChangeAttr (objid, actorattr)
  ActorHelper.actorChangeAttr(objid, actorattr)
  EventHelper.customEvent('actorChangeAttr', objid, actorattr)
end

-- 道具事件

-- 投掷物命中
function EventHelper.projectileHit (projectileid, toobjid, blockid, x, y, z)
  ItemHelper.projectileHit(projectileid, toobjid, blockid, x, y, z)
  EventHelper.customEvent('projectileHit', projectileid, toobjid, blockid, x, y, z)
end

-- 投掷物被创建
function EventHelper.missileCreate (objid, toobjid, itemid, x, y, z)
  ItemHelper.missileCreate(objid, toobjid, itemid, x, y, z)
  EventHelper.customEvent('missileCreate', objid, toobjid, itemid, x, y, z)
end

-- 方块事件

-- 方块被破坏
function EventHelper.blockDestroyBy (objid, blockid, x, y, z)
  BlockHelper.blockDestroyBy(objid, blockid, x, y, z)
  EventHelper.customEvent('blockDestroyBy', objid, blockid, x, y, z)
end

-- 完成方块挖掘
function EventHelper.blockDigEnd (objid, blockid, x, y, z)
  BlockHelper.blockDigEnd(objid, blockid, x, y, z)
  EventHelper.customEvent('blockDigEnd', objid, blockid, x, y, z)
end

-- 方块被放置
function EventHelper.blockPlaceBy (objid, blockid, x, y, z)
  BlockHelper.blockPlaceBy(objid, blockid, x, y, z)
  EventHelper.customEvent('blockPlaceBy', objid, blockid, x, y, z)
end

-- 方块被移除
function EventHelper.blockRemove (blockid, x, y, z)
  BlockHelper.blockRemove(blockid, x, y, z)
  EventHelper.customEvent('blockRemove', blockid, x, y, z)
end

-- 方块被触发
function EventHelper.blockTrigger (objid, blockid, x, y, z)
  BlockHelper.blockTrigger(objid, blockid, x, y, z)
  EventHelper.customEvent('blockTrigger', objid, blockid, x, y, z)
end

-- 背包事件

-- 容器内有道具取出
function EventHelper.backpackItemTakeOut (blockid, x, y, z, itemid, itemnum)
  BackpackHelper.backpackItemTakeOut(blockid, x, y, z, itemid, itemnum)
  EventHelper.customEvent('backpackItemTakeOut', blockid, x, y, z, itemid, itemnum)
end

-- 游戏事件

-- 开始游戏
function EventHelper.startGame ()
  LogHelper.debug('开始游戏')
  GameHelper.startGame()
  MyBlockHelper.init()
  MyActorHelper.init()
  MyMonsterHelper.init()
  MyAreaHelper.init()
  MyStoryHelper.init()
  EventHelper.customEvent('startGame')
end

-- 游戏运行时
function EventHelper.runGame ()
  GameHelper.runGame()
  EventHelper.customEvent('runGame')
end

-- 结束游戏
function EventHelper.endGame ()
  GameHelper.endGame()
  EventHelper.customEvent('endGame')
end

-- 世界时间到[n]点
function EventHelper.atHour (hour)
  GameHelper.atHour(hour)
  EventHelper.customEvent('atHour', hour)
end

-- 世界时间到[n]秒
function EventHelper.atSecond (second)
  GameHelper.atSecond(second)
  EventHelper.customEvent('atSecond', second)
end

-- 任意计时器发生变化
function EventHelper.minitimerChange (timerid, timername)
  GameHelper.minitimerChange(timerid, timername)
  EventHelper.customEvent('minitimerChange', timerid, timername)
end