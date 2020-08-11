-- 道具工具类
ItemHelper = {
  missiles = {}, -- 投掷物队伍数组 { missileid = { ['teamid'] = teamid, ['speedVector3'] = speedVector3 } }
  item = {}, -- 特殊自定义道具 itemid -> item
  projectiles = {}, -- 技能投掷物 projectileid -> info
  itemcds = {}, -- 道具cd objid -> { itemid -> time }
  delaySkills = {} -- 当前技能 objid - > { 'time' -> time, 'index' -> index }
}

function ItemHelper:register (item)
  self.item[item.id] = item
end

function ItemHelper:getItem (itemid)
  return self.item[itemid]
end

-- 手持物也许变化
function ItemHelper:changeHold (objid, itemid1, itemid2)
  local item1 = self:getItem(itemid1)
  local item2 = self:getItem(itemid2)
  local foundItem = false
  if (item1) then -- 之前手持物是自定义特殊道具
    item1:putDown(objid)
    foundItem = true
  end
  if (item2) then -- 当前手持物是自定义特殊道具
    item2:pickUp(objid)
    foundItem = true
  end
  return foundItem
end

function ItemHelper:useItem (objid, itemid)
  local item = self:getItem(itemid)
  if (item) then -- 使用自定义特殊道具
    item:useItem(objid)
  end
end

function ItemHelper:useItem2 (objid)
  local itemid = PlayerHelper:getCurToolID(objid)
  local item = self:getItem(itemid)
  if (item) then -- 使用自定义特殊道具
    item:useItem2(objid)
  end
end

-- 记录投掷物伤害 投掷物id、人物id、道具、伤害
function ItemHelper:recordProjectile (projectileid, objid, item, o)
  o = o or {}
  o.projectileid = projectileid
  o.objid = objid
  o.item = item
  self.projectiles[projectileid] = o
  -- 一定时间后清除数据
  TimeHelper:callFnAfterSecond(function ()
    self.projectiles[projectileid] = nil
  end, 30)
end

-- 记录使用技能
function ItemHelper:recordUseSkill (objid, itemid, cd, dontSetCD)
  if (objid and itemid and cd) then
    if (not(self.itemcds[objid])) then
      self.itemcds[objid] = {}
    end
    self.itemcds[objid][itemid] = os.time()
    if (not(dontSetCD)) then
      PlayerHelper:setSkillCD(objid, itemid, cd)
    end
  else
    if (not(objid)) then
      LogHelper:debug('objid不存在')
    elseif (not(itemid)) then
      LogHelper:debug('itemid不存在')
    else
      LogHelper:debug('cd不存在')
    end
  end
end

-- 是否能够使用技能
function ItemHelper:ableUseSkill (objid, itemid, cd)
  if (not(cd) or cd <= 0) then -- cd值有误
    return true
  end
  if (objid and itemid) then
    local info = self.itemcds[objid]
    if (not(info)) then -- 玩家未使用过技能
      return true
    else
      local time = info[itemid]
      if (not(time)) then -- 该技能未使用过
        return true
      else -- 技能使用过
        local remainingTime = cd + time - os.time()
        if (remainingTime <= 0) then
          return true
        else
          return false, remainingTime
        end
      end
    end
  else
    if (objid) then
      LogHelper:debug('itemid不存在')
    else
      LogHelper:debug('objid不存在')
    end
    return true
  end
end

-- 记录延迟技能
function ItemHelper:recordDelaySkill (objid, time, index, name)
  self.delaySkills[objid] = { time = time, index = index, name = name }
end

-- 延迟技能是否正在释放
function ItemHelper:isDelaySkillUsing (objid, name)
  if (self.delaySkills[objid] and self.delaySkills[objid].name == name) then
    return true
  else
    return false
  end
end

-- 删除延迟技能记录
function ItemHelper:delDelaySkillRecord (objid)
  self.delaySkills[objid] = nil
end

-- 取消延迟技能
function ItemHelper:cancelDelaySkill (objid)
  local delaySkillInfo = self.delaySkills[objid]
  if (delaySkillInfo and delaySkillInfo.index) then
    TimeHelper:delFn(delaySkillInfo.time, delaySkillInfo.index)
    self:delDelaySkillRecord(objid)
    ChatHelper:sendSystemMsg('取消' .. delaySkillInfo.name .. '技能', objid)
  end
end

-- 移除玩家当前手持物
function ItemHelper:removeCurTool (objid)
  local gridid = BackpackHelper:getCurShotcutGrid(objid)
  BackpackHelper:removeGridItem(objid, gridid)
end

-- 记录投掷物属性
function ItemHelper:recordMissile (objid, attr, val)
  local t = objid .. 'recordMissile'
  if (self.missiles[objid]) then -- 已存在
    self.missiles[objid][attr] = val
    TimeHelper:delFnFastRuns(t)
  else -- 不存在
    self.missiles[objid] = { [attr] = val }
  end
  -- 保留的记录30秒后删除
  TimeHelper:callFnFastRuns(function ()
    self.missiles[objid] = nil
  end, 30, t)
end

-- 记录投掷物队伍
function ItemHelper:recordMissileTeam (objid, teamid)
  self:recordMissile(objid, 'teamid', teamid)
end

-- 记录投掷物速度
function ItemHelper:recordMissileSpeed (objid, speed)
  self:recordMissile(objid, 'speed', speed)
end

-- 获取投掷物信息
function ItemHelper:getMissile (objid)
  return self.missiles[objid] or {}
end

-- 获取投掷物所属队伍，找不到队伍则返回-1
function ItemHelper:getMissileTeam (objid)
  return self:getMissile(objid).teamid or -1
end

-- 获取投掷物速度
function ItemHelper:getMissileSpeed (objid)
  return self:getMissile(objid).speed
end

-- 事件

-- 投掷物命中
function ItemHelper:projectileHit (projectileid, toobjid, blockid, x, y, z)
  local projectileInfo = self.projectiles[projectileid]
  if (projectileInfo) then
    local item = projectileInfo.item
    local pos = MyPosition:new(x, y, z)
    item:projectileHit(projectileInfo, toobjid, blockid, pos)
  end
end

-- 投掷物被创建
function ItemHelper:missileCreate (objid, toobjid, itemid, x, y, z)
  local teamid = ActorHelper:getTeam(objid)
  ItemHelper:recordMissileTeam(toobjid, teamid)
end

-- 封装原始接口

-- 获取itemid
function ItemHelper:getItemId (objid)
  local onceFailMessage = '获取itemid失败一次'
  local finillyFailMessage = StringHelper:concat('获取itemid失败，参数objid=', objid)
  return CommonHelper:callOneResultMethod(function (p)
    return Item:getItemId(objid)
  end, nil, onceFailMessage, finillyFailMessage)
end