-- 我的剧情工具类
MyStoryHelper = {
  winPlayer = nil
}

function MyStoryHelper:init ()
  story1 = Story1:new()
  StoryHelper:setStorys({ story1 })
end

-- 事件

-- 世界时间到[n]点
function MyStoryHelper:atHour (hour)
  StoryHelper:atHour(hour)
  -- body
end

-- 玩家进入游戏
function MyStoryHelper:playerEnterGame (objid)
  local player = PlayerHelper:getPlayer(objid)
  local hostPlayer = PlayerHelper:getHostPlayer()
  if (player == hostPlayer) then -- 房主
    TimeHelper:setHour(MyMap.CUSTOM.INIT_HOUR)
    -- TimeHelper:setHour(20)
  end
  -- StoryHelper:recover(player) -- 恢复剧情
end

-- 玩家离开游戏
function MyStoryHelper:playerLeaveGame (objid)
  -- body
end

-- 玩家进入区域
function MyStoryHelper:playerEnterArea (objid, areaid)
  -- body
end

-- 玩家离开区域
function MyStoryHelper:playerLeaveArea (objid, areaid)
  -- body
end

-- 玩家点击方块
function MyStoryHelper:playerClickBlock (objid, blockid, x, y, z)
  -- body
end

-- 玩家点击生物
function MyStoryHelper:playerClickActor (objid, toobjid)
  -- body
end

-- 玩家获得道具
function MyStoryHelper:playerAddItem (objid, itemid, itemnum)
  if (itemid == MyMap.ITEM.GREEN_SOFT_STONE_ID) then -- 判断是否集齐碎片
    BackpackHelper:removeGridItemByItemID(objid, itemid, 1) -- 销毁绿色软石块
    local num = BackpackHelper:getItemNumAndGrid(objid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
    local player = PlayerHelper:getPlayer(objid)
    local actor = player:getClickActor()
    if (num < 100) then
      actor:speakTo(objid, 0, '年轻人勿打诳语啊……')
    else
      actor:speakTo(objid, 0, '好，我这就施展大挪移之术。')
      if (not(self.winPlayer)) then
        self.winPlayer = player
        TimeHelper:callFnFastRuns(function ()
          PlayerHelper:setGameWin(objid)
        end, 2)
      end
    end
  elseif (itemid == MyMap.ITEM.BLUE_SOFT_STONE_ID) then -- 维修仙剑
    BackpackHelper:removeGridItemByItemID(objid, itemid, 1) -- 销毁蓝色软石块
    local itemids = {
      MyWeaponAttr.controlSword.levelIds[1], -- 御仙剑
      MyWeaponAttr.tenThousandsSword.levelIds[1], -- 万仙剑
      MyWeaponAttr.huixianSword.levelIds[1], -- 回仙剑
      MyWeaponAttr.vitalqiSword.levelIds[1] -- 气仙剑
    }
    for i, v in ipairs(itemids) do
      local num, grids = BackpackHelper:getItemNumAndGrid2(objid, v)
      for i, gridid in ipairs(grids) do
        local durcur, durmax = BackpackHelper:getGridDurability(objid, gridid)
        BackpackHelper:setGridItem(objid, gridid, v, 1, durmax)
      end
    end
  elseif (itemid == MyMap.ITEM.PURPLE_SOFT_STONE_ID) then -- 查询碎片数量
    BackpackHelper:removeGridItemByItemID(objid, itemid, 1) -- 销毁紫色软石块
    local teamInfos = { [1] = { max = 0 }, [2] = { max = 0 } }
    for i, v in ipairs(PlayerHelper:getActivePlayers()) do
      local teamid = PlayerHelper:getTeam(v.objid)
      local num = BackpackHelper:getItemNumAndGrid(v.objid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
      local info = teamInfos[teamid]
      if (info.max < num) then
        info.max = num
        info.maxPlayer = v:getName()
      end
    end
    local player = PlayerHelper:getPlayer(objid)
    local actor = player:getClickActor()
    local second = 0
    local info = teamInfos[1]
    if (info.maxPlayer) then
      actor:speakTo(objid, second, '目前红队搜集碎片最多的玩家是#G', info.maxPlayer)
      second = second + 2
      actor:speakTo(objid, second, '嗯，已经搜集了#G', info.max, '#W枚碎片')
    else
      actor:speakTo(objid, second, '目前红队还没有人搜集到碎片')
    end
    second = second + 2
    info = teamInfos[2]
    if (info.maxPlayer) then
      actor:speakTo(objid, second, '目前蓝队搜集碎片最多的玩家是#G', info.maxPlayer)
      second = second + 2
      actor:speakTo(objid, second, '嗯，已经搜集了#G', info.max, '#W枚碎片')
    else
      actor:speakTo(objid, second, '目前蓝队还没有人搜集到碎片')
    end
  end
end

-- 玩家使用道具
function MyStoryHelper:playerUseItem (objid, toobjid, itemid, itemnum)
  -- body
end

-- 玩家攻击命中
function MyStoryHelper:playerAttackHit (objid, toobjid)
  -- body
end

-- 玩家造成伤害
function MyStoryHelper:playerDamageActor (objid, toobjid, hurtlv)
  -- body
end

-- 玩家击败生物
function MyStoryHelper:playerDefeatActor (playerid, objid)
  -- body
end

-- 玩家受到伤害
function MyStoryHelper:playerBeHurt (objid, toobjid, hurtlv)
  -- body
end

-- 玩家死亡
function MyStoryHelper:playerDie (objid, toobjid)
  -- body
end

-- 玩家复活
function MyStoryHelper:playerRevive (objid, toobjid)
  -- body
end

-- 玩家选择快捷栏
function MyStoryHelper:playerSelectShortcut (objid, toobjid, itemid, itemnum)
  -- body
end

-- 玩家快捷栏变化
function MyStoryHelper:playerShortcutChange (objid, toobjid, itemid, itemnum)
  -- body
end

-- 玩家运动状态改变
function MyStoryHelper:playerMotionStateChange (objid, playermotion)
  -- body
end

-- 玩家移动一格
function MyStoryHelper:playerMoveOneBlockSize (objid)
  -- body
end

-- 玩家骑乘
function MyStoryHelper:playerMountActor (objid, toobjid)
  -- body
end

-- 玩家取消骑乘
function MyStoryHelper:playerDismountActor (objid, toobjid)
  -- body
end

-- 聊天输出界面变化
function MyStoryHelper:playerInputContent(objid, content)
  -- body
end

-- 输入字符串
function MyStoryHelper:playerNewInputContent(objid, content)
  -- body
end

-- 生物进入区域
function MyStoryHelper:actorEnterArea (objid, areaid)
  -- body
end

-- 生物离开区域
function MyStoryHelper:actorLeaveArea (objid, areaid)
  -- body
end

-- 生物碰撞
function MyStoryHelper:actorCollide (objid, toobjid)
  -- body
end

-- 生物攻击命中
function MyStoryHelper:actorAttackHit (objid, toobjid)
  -- body
end

-- 生物击败目标
function MyStoryHelper:actorBeat (objid, toobjid)
  -- body
end

-- 生物行为改变
function MyStoryHelper:actorChangeMotion (objid, actormotion)
  -- body
end

-- 生物死亡
function MyStoryHelper:actorDie (objid, toobjid)
  -- body
end
