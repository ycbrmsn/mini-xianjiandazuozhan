-- 玩家基类
BasePlayer = {
  objid = nil,
  nickname = nil,
  action = nil,
  wants = nil,  -- 想做什么
  moveMotion = nil,
  prevAreaId = nil, -- 上一进入区域id
  hold = nil, -- 手持物品
  clickActor = nil, -- 最近点击的actor
  active = true, -- 是否活跃，即未离开房间
  talkWithActor = nil, -- 与生物交谈
  whichChoose = nil, -- 在选择什么
}

function BasePlayer:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function BasePlayer:init ()
  self.hold = PlayerHelper:getCurToolID(self.objid)
  self.attr.level = PlayerHelper:getLevel(self.objid) or 0
  self:initMyPlayer()
  -- body
end

-- 初始化方法，用于重写
function BasePlayer:initMyPlayer ()
  -- body
end

-- 是否是房主
function BasePlayer:isHostPlayer ()
  return PlayerHelper:isMainPlayer(self.objid)
end

function BasePlayer:speak (afterSeconds, ...)
  if (afterSeconds > 0) then
    self.action:speakAfterSeconds(afterSeconds, ...)
  else
    self.action:speakToAll(...)
  end
end

function BasePlayer:speakTo (playerids, afterSeconds, ...)
  if (type(playerids) == 'number') then
    if (afterSeconds > 0) then
      self.action:speakToAfterSeconds(playerids, afterSeconds, ...)
    else
      self.action:speak(playerids, ...)
    end
  elseif (type(playerids) == 'table') then
    for i, v in ipairs(playerids) do
      self:speakTo(v)
    end
  end
end

function BasePlayer:speakSelf (afterSeconds, ...)
  self:speakTo(self.objid, afterSeconds, ...)
end

function BasePlayer:thinks (afterSeconds, ...)
  if (afterSeconds > 0) then
    self.action:thinkAfterSeconds(afterSeconds, ...)
  else
    self.action:think(...)
  end
end

function BasePlayer:thinkTo (playerids, afterSeconds, ...)
  if (type(playerids) == 'number') then
    if (afterSeconds > 0) then
      self.action:thinkToAfterSeconds(playerids, afterSeconds, ...)
    else
      self.action:thinkTo(playerids, ...)
    end
  elseif (type(playerids) == 'table') then
    for i, v in ipairs(playerids) do
      self:thinkTo(v, afterSeconds, ...)
    end
  end
end

function BasePlayer:thinkSelf (afterSeconds, ...)
  self:thinkTo(self.objid, afterSeconds, ...)
end

function BasePlayer:updatePositions ()
  self.attr:updatePositions()
end

function BasePlayer:getName ()
  if (not(self.nickname)) then
    self.nickname = PlayerHelper:getNickname(self.objid)
  end
  return self.nickname
end

function BasePlayer:isActive ()
  return self.active
end

function BasePlayer:setActive (isActive)
  self.active = isActive
end

function BasePlayer:getPrevLevel ()
  return self.attr.level
end

function BasePlayer:setPrevLevel (level)
  self.attr.level = level
end

function BasePlayer:getLevel ()
  return PlayerHelper:getLevel(self.objid)
end

function BasePlayer:setLevel (level)
  return PlayerHelper:setLevel(self.objid, level)
end

function BasePlayer:getExp ()
  return PlayerHelper:getExp(self.objid)
end

function BasePlayer:setExp (exp)
  return PlayerHelper:setExp(self.objid, exp)
end

-- 玩家被击败的基础经验
function BasePlayer:getBaseExp ()
  return self.attr.expData.exp
end

function BasePlayer:enableMove (enable, showMsg)
  self.attr:enableMove(enable, showMsg)
end

function BasePlayer:enableBeAttacked (enable)
  return PlayerHelper:setPlayerEnableBeAttacked(self.objid, enable)
end

function BasePlayer:getPosition ()
  return ActorHelper:getPosition(self.objid)
end

function BasePlayer:getMyPosition ()
  return MyPosition:new(self:getPosition())
end

function BasePlayer:setPosition (x, y, z)
  return ActorHelper:setMyPosition(self.objid, x, y, z)
end

function BasePlayer:setMyPosition (x, y, z)
  return self:setPosition(x, y, z)
  -- return ActorHelper:setMyPosition(self.objid, pos.x, pos.y, pos.z)
end

function BasePlayer:getDistancePosition (distance, angle)
  return ActorHelper:getDistancePosition(self.objid, distance, angle)
end

function BasePlayer:setDistancePosition (objid, distance, angle)
  self:setPosition(ActorHelper:getDistancePosition(objid, distance, angle))
end

function BasePlayer:getFaceYaw ()
  return ActorHelper:getFaceYaw(self.objid)
end

function BasePlayer:getFacePitch ()
  return ActorHelper:getFacePitch(self.objid)
end

-- 获取准星位置
function BasePlayer:getAimPos ()
  return MyPosition:new(PlayerHelper:getAimPos(self.objid))
end

function BasePlayer:gainExp (exp)
  self.attr:gainExp(exp)
end

-- 获得被击败经验
function BasePlayer:gainDefeatedExp ()
  self.attr:gainDefeatedExp()
end

function BasePlayer:upgrade (addLevel)
  return self.attr:upgrade(addLevel)
end

-- 玩家看向，默认会旋转镜头
function BasePlayer:lookAt (toobjid, needRotateCamera)
  if (type(needRotateCamera) == 'nil') then
    needRotateCamera = true
  end
  ActorHelper:lookAt(self.objid, toobjid, needRotateCamera)
end

function BasePlayer:wantLookAt (objid, seconds)
  TimeHelper:callFnContinueRuns(function ()
    self:lookAt(objid)
  end, seconds)
end

-- 背包数量及背包格数组
function BasePlayer:getItemNum (itemid, containEquip)
  return BackpackHelper:getItemNum(self.objid, itemid, containEquip)
end

-- 拿出道具
function BasePlayer:takeOutItem (itemid, containEquip)
  local num, arr = self:getItemNum(itemid, containEquip)
  if (num == 0) then
    return false
  else
    local grid = BackpackHelper:getCurShotcutGrid(self.objid)
    return BackpackHelper:swapGridItem(self.objid, arr[1], grid)
  end
end

function BasePlayer:holdItem ()
  local itemid = PlayerHelper:getCurToolID(self.objid)
  if (itemid) then
    if (not(self.hold) and itemid == 0) then  -- 变化前后都没有拿东西
      -- do nothing
    elseif (not(self.hold)) then -- 之前没有拿东西
      self:changeHold(itemid)
    elseif (itemid == 0) then -- 之后没有拿东西
      self:changeHold(itemid)
    elseif (self.hold ~= itemid) then -- 换了一件东西拿
      self:changeHold(itemid)
    end -- else是没有换东西，略去
  end
end

function BasePlayer:changeHold (itemid)
  local foundItem = ItemHelper:changeHold(self.objid, self.hold, itemid)
  self.hold = itemid
  if (foundItem) then
    -- self:showAttr(true) -- 目前默认显示近程攻击
    -- 检测技能是否正在释放
    if (ItemHelper:isDelaySkillUsing(self.objid, '坠星')) then -- 技能释放中
      FallStarBow:cancelSkill(self.objid)
      return
    end
    if (SkillHelper:isFlying(self.objid)) then -- 如果在飞行，则退出飞行状态
      SkillHelper:stopFly(self.objid)
    end
  end
end

-- 改变攻防属性
function BasePlayer:changeAttr (meleeAttack, remoteAttack, meleeDefense, remoteDefense, isMinus)
  self.attr:changeAttr(meleeAttack, remoteAttack, meleeDefense, remoteDefense, isMinus)
end

-- 显示攻防属性变化
function BasePlayer:showAttr ()
  self.attr:showAttr()
end

-- 恢复血量（加/减血）
function BasePlayer:recoverHp (hp)
  self.attr:recoverHp(hp)
end

-- 恢复饱食度（加/减饱食度）
function BasePlayer:recoverFoodLevel(foodLevel)
  self.attr:recoverFoodLevel(foodLevel)
end

-- 减体力
function BasePlayer:reduceStrength (strength)
  self.attr:reduceStrength(strength)
end

-- 伤害生物
function BasePlayer:damageActor (toobjid, val, item)
  self.attr:damageActor(toobjid, val, item)
end

-- 设置囚禁状态
function BasePlayer:setImprisoned (active)
  return self.attr:setImprisoned(active)
end

-- 设置封魔状态
function BasePlayer:setSeal (active)
  return self.attr:setSeal(active)
end

-- 是否能够使用技能
function BasePlayer:ableUseSkill (skillname)
  return self.attr:ableUseSkill(skillname)
end

-- 玩家击败actor
function BasePlayer:defeatActor (objid)
  self.attr:defeatActor(objid)
end

-- 击败玩家获得经验
function BasePlayer:getDefeatExp (objid)
  return self.attr:getDefeatExp(objid)
end

-- 被击败获得经验
function BasePlayer:getDefeatedExp (objid)
  return self.attr:getDefeatedExp(objid)
end

-- 设置点击的生物
function BasePlayer:setClickActor (actor)
  self.clickActor = actor
end

-- 获取点击的生物
function BasePlayer:getClickActor ()
  return self.clickActor
end

function BasePlayer:runTo (positions, callback, param)
  self.action:runTo(positions, callback, param)
end

-- 选择选项
function BasePlayer:choose ()
  if (self.whichChoose) then
    if (self.whichChoose == 'talk') then
      TalkHelper:chooseTalk(self.objid)
    else
      local chooseItems = MyPlayerHelper.chooseMap[self.whichChoose]
      if (chooseItems) then
        local index = PlayerHelper:getCurShotcut(self.objid) + 1
        if (index <= #chooseItems) then
          chooseItems[index](self)
        end
      end
    end
  end
end

-- 中止对话
function BasePlayer:breakTalk ()
  local actor = self:getClickActor()
  if (not(actor)) then -- 没有点击特殊生物
    return
  end
  local index = TalkHelper:getTalkIndex(self.objid, actor)
  if (index ~= 1) then -- 表示对话在进行中
    TalkHelper:resetTalkIndex(self.objid, actor)
    ChatHelper:showBreakSeparate(self.objid)
  end
end

-- 重置对话序数
function BasePlayer:resetTalkIndex (index)
  local actor = self:getClickActor()
  if (actor) then
    TalkHelper:resetTalkIndex(self.objid, actor, index)
  end
end