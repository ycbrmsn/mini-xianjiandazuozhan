-- 玩家属性类
BasePlayerAttr = {
  level = 0, -- 当前等级，已废弃
  totalLevel = 0, -- 总等级，已废弃
  exp = 0,  -- 当前经验
  levelExp = 100, -- 每升一级需要的经验
  defeatedExp = 0, -- 被击败获得经验
  positions = nil, -- 最近几秒的位置
  hurtReason = nil, -- 受伤原因，目前没用
  attack = 0, -- 手持武器攻击
  defense = 0, -- 手持武器防御
  strength = 100, -- 体力，用于使枪消耗
  expData = {
    exp = 50 -- 击败玩家获得的基础经验
  }
}

function BasePlayerAttr:new (player)
  local o = {
    myActor = player,
    cantUseSkillReasons = {
      seal = 0, -- 封魔叠加数
      imprisoned = 0 -- 慑魂叠加数
    } -- 无法使用技能原因, { string -> times }
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 设置能否移动
function BasePlayerAttr:enableMove (enable, showMsg)
  local objid = self.myActor.objid
  if (enable) then
    if (showMsg) then
      PlayerHelper:notifyGameInfo2Self(objid, '恢复移动')
    end
    PlayerHelper:setAttr(objid, PLAYERATTR.WALK_SPEED, -1)
    PlayerHelper:setAttr(objid, PLAYERATTR.RUN_SPEED, -1)
    PlayerHelper:setAttr(objid, PLAYERATTR.SNEAK_SPEED, -1)
    PlayerHelper:setAttr(objid, PLAYERATTR.SWIN_SPEED, -1)
    PlayerHelper:setAttr(objid, PLAYERATTR.JUMP_POWER, -1)
  else
    if (showMsg) then
      PlayerHelper:notifyGameInfo2Self(objid, '当前不可移动')
    end
    PlayerHelper:setAttr(objid, PLAYERATTR.WALK_SPEED, 0)
    PlayerHelper:setAttr(objid, PLAYERATTR.RUN_SPEED, 0)
    PlayerHelper:setAttr(objid, PLAYERATTR.SNEAK_SPEED, 0)
    PlayerHelper:setAttr(objid, PLAYERATTR.SWIN_SPEED, 0)
    PlayerHelper:setAttr(objid, PLAYERATTR.JUMP_POWER, 0)
  end
end

-- 更新玩家位置
function BasePlayerAttr:updatePositions ()
  if (not(self.positions)) then
    self.positions = {}
  end
  local myPosition = self.myActor:getMyPosition()
  if (myPosition) then
    table.insert(self.positions, 1, myPosition)
    if (#self.positions > 3) then
      table.remove(self.positions)
    end
  end
end

-- 玩家获得经验
function BasePlayerAttr:gainExp (exp)
  if (not(exp) or exp <= 0) then
    return
  end
  -- local isUpgrade
  -- self.exp = self.exp + exp
  -- local needExp = (self.totalLevel + 1) * self.levelExp - self.exp
  -- if (needExp <= 0) then
  --   repeat
  --     self:upgrade(1)
  --     needExp = needExp + self.levelExp
  --   until (needExp > 0)
  --   isUpgrade = true
  -- else
  --   isUpgrade = false
  -- end
  local prevLevel = self.myActor:getLevel()
  PlayerHelper:addExp(self.myActor.objid, exp)
  local curLevel = self.myActor:getLevel()
  self:upgrade(curLevel - prevLevel)
  return curLevel, curLevel > prevLevel 
end

-- 玩家获得被击败经验
function BasePlayerAttr:gainDefeatedExp ()
  local defeatedExp = self:getDefeatedExp()
  if (defeatedExp > 0) then
    local level, isUpgrade = self:gainExp(self.defeatedExp) -- 获得经验
    if (level) then
      local map = { exp = defeatedExp, level = level }
      if (isUpgrade) then
        local msg1 = StringHelper:getTemplateResult(MyTemplate.GAIN_DEFEATED_EXP_MSG, map)
        local msg2 = StringHelper:getTemplateResult(MyTemplate.UPGRADE_MSG, map)
        ChatHelper:sendMsg(self.myActor.objid, msg1, '。', msg2)
      --   ChatHelper:sendTemplateMsg(MyTemplate.UPGRADE_MSG, map, self.myActor.objid)
      else
        ChatHelper:sendTemplateMsg(MyTemplate.GAIN_DEFEATED_EXP_MSG, map, self.myActor.objid)
      --   ChatHelper:sendTemplateMsg(MyTemplate.UNUPGRADE_MSG, map, self.myActor.objid)
      end
    end
  end
end

-- 玩家升级
function BasePlayerAttr:upgrade (addLevel)
  if (addLevel > 0) then
    self.totalLevel = self.totalLevel + addLevel
    self:changeAttr(2 * addLevel, 2 * addLevel)
    -- local attrtype1 = { PLAYERATTR.ATK_MELEE, PLAYERATTR.ATK_REMOTE, PLAYERATTR.DEF_MELEE, PLAYERATTR.DEF_REMOTE }
    -- for i, v in ipairs(attrtype1) do
    --   PlayerHelper:addAttr(self.objid, v, 2 * addLevel)
    -- end
    local objid = self.myActor.objid
    local maxHp = PlayerHelper:getMaxHp(objid) + 10 * addLevel
    PlayerHelper:setMaxHp(objid, maxHp)
    PlayerHelper:setHp(objid, maxHp)
    PlayerHelper:setFoodLevel(objid, 100)
  end
end

-- 改变属性
function BasePlayerAttr:changeAttr (attack, defense, dodge)
  local attrMap = {}
  if (attack and attack ~= 0) then
    attrMap[PLAYERATTR.ATK_MELEE] = attack
    attrMap[PLAYERATTR.ATK_REMOTE] = attack
  end
  if (defense and defense ~= 0) then
    attrMap[PLAYERATTR.DEF_MELEE] = defense
    attrMap[PLAYERATTR.DEF_REMOTE] = defense
  end
  if (dodge and dodge ~= 0) then
    attrMap[PLAYERATTR.DODGE] = dodge
  end
  for k, v in pairs(attrMap) do
    PlayerHelper:addAttr(self.myActor.objid, k, v)
  end
end

-- 显示属性
function BasePlayerAttr:showAttr (isMelee)
  local objid, attack = self.myActor.objid
  if (isMelee) then
    attack = PlayerHelper:getAttr(objid, PLAYERATTR.ATK_MELEE)
  else
    attack = PlayerHelper:getAttr(objid, PLAYERATTR.ATK_REMOTE)
  end
  local defense = PlayerHelper:getAttr(objid, PLAYERATTR.DEF_MELEE)
  local att, def = attack - self.attack, defense - self.defense
  if (att >= 0) then
    att = '+' .. att
  end
  if (def >= 0) then
    def = '+' .. def
  end
  local content = StringHelper:concat('攻击', att, '，防御', def)
  ChatHelper:sendSystemMsg(content, objid)
  self.attack = attack
  self.defense = defense
end

-- 恢复生命
function BasePlayerAttr:recoverHp (hp)
  if (hp == 0) then
    return
  end
  local objid = self.myActor.objid
  local curHp = PlayerHelper:getHp(objid)
  if (hp > 0) then -- 加血
    local maxHp = PlayerHelper:getMaxHp(objid)
    if (curHp == maxHp) then -- 满血量不处理
      return
    end
    curHp = curHp + hp
    if (curHp > maxHp) then
      curHp = maxHp
    end
  else -- 减血
    local minHp = 1
    curHp = curHp + hp
    if (curHp <= 0) then
      local ableBeKilled = PlayerHelper:getPlayerEnableBeKilled(self.myActor.objid)
      if (not(ableBeKilled)) then -- 不能被杀死
        curHp = minHp
      end
    end
  end
  PlayerHelper:setHp(objid, curHp)
end

-- 恢复饱食度
function BasePlayerAttr:recoverFoodLevel(foodLevel)
  if (foodLevel == 0) then
    return
  end
  local curFoodLevel = PlayerHelper:getFoodLevel(self.myActor.objid)
  if (foodLevel > 0) then -- 增加饱食度
    local maxFoodLevel = 100
    if (curFoodLevel == maxFoodLevel) then -- 满饱食度不处理
      return
    end
    curFoodLevel = curFoodLevel + foodLevel
    if (curFoodLevel > maxFoodLevel) then
      curFoodLevel = maxFoodLevel
    end
  else -- 减血
    local minFoodLevel = 0
    if (curFoodLevel == minFoodLevel) then -- 饥饿不处理
      return
    end
    curFoodLevel = curFoodLevel + foodLevel
    if (curFoodLevel < minFoodLevel) then
      curFoodLevel = minFoodLevel
    end
  end
  PlayerHelper:setFoodLevel(self.myActor.objid, curFoodLevel)
end

-- 减少体力
function BasePlayerAttr:reduceStrength (strength)
  self.strength = self.strength - strength
  if (self.strength <= 0) then
    self.strength = 100
    self:recoverFoodLevel(-1)
  end
end

-- 伤害actor
function BasePlayerAttr:damageActor (toobjid, val)
  ActorHelper:damageActor(self.myActor.objid, toobjid, val)
end

function BasePlayerAttr:setImprisoned (active)
  self:enableMove(not(active)) -- 可移动设置
  PlayerHelper:setActionAttrState(self.myActor.objid, PLAYERATTR.ENABLE_ATTACK, not(active)) -- 可攻击设置
  if (active) then
    -- 设置囚禁标志用于不能使用主动技能
    self.cantUseSkillReasons.imprisoned = self.cantUseSkillReasons.imprisoned + 1
    ChatHelper:sendSystemMsg('你被慑魂枪震慑了灵魂，无法做出有效行为', self.myActor.objid)
  else 
    -- 返回true表示已不是囚禁状态
    self.cantUseSkillReasons.imprisoned = self.cantUseSkillReasons.imprisoned - 1
    return self.cantUseSkillReasons.imprisoned <= 0
  end
end

function BasePlayerAttr:setSeal (active)
  if (active) then
    self.cantUseSkillReasons.seal = self.cantUseSkillReasons.seal + 1
    ChatHelper:sendSystemMsg('你被封魔了，当前无法使用技能', self.myActor.objid)
  else
    -- 返回true表示已不是封魔状态
    self.cantUseSkillReasons.seal = self.cantUseSkillReasons.seal - 1
    return self.cantUseSkillReasons.seal <= 0
  end
end

-- 是否能够使用技能
function BasePlayerAttr:ableUseSkill (skillname)
  skillname = skillname or ''
  if (self.cantUseSkillReasons.seal > 0) then
    ChatHelper:sendSystemMsg('你处于封魔状态，当前无法使用' .. skillname .. '技能', self.myActor.objid)
    return false
  end
  if (self.cantUseSkillReasons.imprisoned > 0) then
    ChatHelper:sendSystemMsg('你处于慑魂状态，当前无法使用' .. skillname .. '技能', self.myActor.objid)
    return false
  end
  return true
end

-- 玩家击败actor
function BasePlayerAttr:defeatActor (objid)
  local exp = 1
  if (ActorHelper:isPlayer(objid)) then -- 如果是击败玩家
    exp = self:getDefeatExp(objid)
  else -- 如果是击败生物
    local actorid = CreatureHelper:getActorID(objid)
    if (actorid) then
      for i, v in ipairs(MonsterHelper:getMonsterModels()) do
        if (v.actorid == actorid) then
          exp = MonsterHelper:calcExp(self.myActor:getLevel(), v.expData.level, v.expData.exp)
          break
        end
      end
    end
  end
  local level, isUpgrade = self:gainExp(exp) -- 获得经验
  if (level) then
    local map = { exp = exp, level = level }
    if (isUpgrade) then
      local msg1 = StringHelper:getTemplateResult(MyTemplate.GAIN_EXP_MSG, map)
      local msg2 = StringHelper:getTemplateResult(MyTemplate.UPGRADE_MSG, map)
      ChatHelper:sendMsg(self.myActor.objid, msg1, '。', msg2)
    --   ChatHelper:sendTemplateMsg(MyTemplate.UPGRADE_MSG, map, self.myActor.objid)
    else
      ChatHelper:sendTemplateMsg(MyTemplate.GAIN_EXP_MSG, map, self.myActor.objid)
    --   ChatHelper:sendTemplateMsg(MyTemplate.UNUPGRADE_MSG, map, self.myActor.objid)
    end
  end
end

-- 击败玩家获得经验
function BasePlayerAttr:getDefeatExp (objid)
  local toPlayer = PlayerHelper:getPlayer(objid)
  return MonsterHelper:calcExp(self.myActor:getLevel(), toPlayer:getLevel(), toPlayer:getBaseExp())
end

-- 被击败获得经验
function BasePlayerAttr:getDefeatedExp (objid)
  return self.defeatedExp
end
