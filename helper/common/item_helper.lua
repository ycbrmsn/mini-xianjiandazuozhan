-- 道具工具类
ItemHelper = {
  missiles = {}, -- 投掷物队伍数组 { missileid = { ['teamid'] = teamid, ['speedVector3'] = speedVector3 } }
  item = {}, -- 特殊自定义道具 itemid -> item
  projectiles = {}, -- 技能投掷物 projectileid -> info
  itemcds = {}, -- 道具cd objid -> { itemid -> time }
  delaySkills = {} -- 当前技能 objid - > { 'time' -> time, 'index' -> index }
}

function ItemHelper.register (item)
  ItemHelper.item[item.id] = item
end

function ItemHelper.getItem (itemid)
  return ItemHelper.item[itemid]
end

-- 手持物也许变化
function ItemHelper.changeHold (objid, itemid1, itemid2)
  local item1 = ItemHelper.getItem(itemid1)
  local item2 = ItemHelper.getItem(itemid2)
  local foundItem = false
  if (item1) then -- 之前手持物是自定义特殊道具
    item1:putDown(objid)
    foundItem = true
  end
  if (item2) then -- 当前手持物是自定义特殊道具
    item2:pickUp(objid)
    foundItem = true
  end
  return foundItem, item1, item2
end

function ItemHelper.useItem (objid, itemid)
  local item = ItemHelper.getItem(itemid)
  if (item) then -- 使用自定义特殊道具
    item:useItem(objid)
  end
end

function ItemHelper.useItem2 (objid)
  local itemid = PlayerHelper.getCurToolID(objid)
  local item = ItemHelper.getItem(itemid)
  if (item) then -- 使用自定义特殊道具
    item:useItem2(objid)
  end
end

function ItemHelper.selectItem (objid, itemid)
  local item = ItemHelper.getItem(itemid)
  if (item) then -- 选择自定义特殊道具
    item:selectItem(objid, PlayerHelper.getCurShotcut(objid))
  end
end

function ItemHelper.clickBlock (objid, blockid, x, y, z)
  local itemid = PlayerHelper.getCurToolID(objid)
  local item = ItemHelper.getItem(itemid)
  if (item) then -- 手持自定义特殊道具点击方块
    item:clickBlock(objid, blockid, x, y, z)
  end
end

-- 记录投掷物伤害 投掷物id、人物id、道具、伤害
function ItemHelper.recordProjectile (projectileid, objid, item, o)
  o = o or {}
  o.projectileid = projectileid
  o.objid = objid
  o.item = item
  ItemHelper.projectiles[projectileid] = o
  -- 一定时间后清除数据
  TimeHelper.callFnAfterSecond(function ()
    ItemHelper.projectiles[projectileid] = nil
  end, 30)
end

-- 记录使用技能
function ItemHelper.recordUseSkill (objid, itemid, cd, dontSetCD)
  if (objid and itemid and cd) then -- 确保玩家、道具类型、冷却时间必须存在
    if (not(ItemHelper.itemcds[objid])) then -- 如果玩家对应的道具冷却信息不存在，则创建一个
      ItemHelper.itemcds[objid] = {}
    end
    ItemHelper.itemcds[objid][itemid] = os.time() -- 将道具技能使用时间记录下来，记录为当前系统时间
    if (not(dontSetCD)) then -- 需要进入冷却
      PlayerHelper.setSkillCD(objid, itemid, cd) -- 使道具开始冷却
    end
  else
    if (not(objid)) then
      LogHelper.debug('objid不存在')
    elseif (not(itemid)) then
      LogHelper.debug('itemid不存在')
    else
      LogHelper.debug('cd不存在')
    end
  end
end

-- 是否能够使用技能
function ItemHelper.ableUseSkill (objid, itemid, cd)
  if (not(cd) or cd <= 0) then -- cd值有误
    return true
  end
  if (objid and itemid) then
    local info = ItemHelper.itemcds[objid]
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
      LogHelper.debug('itemid不存在')
    else
      LogHelper.debug('objid不存在')
    end
    return true
  end
end

-- 记录延迟技能
function ItemHelper.recordDelaySkill (objid, time, index, name)
  ItemHelper.delaySkills[objid] = { time = time, index = index, name = name }
end

-- 延迟技能是否正在释放
function ItemHelper.isDelaySkillUsing (objid, name)
  if (ItemHelper.delaySkills[objid] and ItemHelper.delaySkills[objid].name == name) then
    return true
  else
    return false
  end
end

-- 删除延迟技能记录
function ItemHelper.delDelaySkillRecord (objid)
  ItemHelper.delaySkills[objid] = nil
end

-- 取消延迟技能
function ItemHelper.cancelDelaySkill (objid)
  local delaySkillInfo = ItemHelper.delaySkills[objid]
  if (delaySkillInfo and delaySkillInfo.index) then
    TimeHelper.delFn(delaySkillInfo.time, delaySkillInfo.index)
    ItemHelper.delDelaySkillRecord(objid)
    ChatHelper.sendSystemMsg('取消' .. delaySkillInfo.name .. '技能', objid)
  end
end

-- 移除玩家当前手持物
function ItemHelper.removeCurTool (objid)
  local gridid = BackpackHelper.getCurShotcutGrid(objid)
  BackpackHelper.removeGridItem(objid, gridid)
end

-- 记录投掷物属性
function ItemHelper.recordMissile (objid, attr, val)
  local t = objid .. 'recordMissile'
  if (ItemHelper.missiles[objid]) then -- 已存在
    ItemHelper.missiles[objid][attr] = val
    TimeHelper.delFnFastRuns(t)
  else -- 不存在
    ItemHelper.missiles[objid] = { [attr] = val }
  end
  -- 保留的记录30秒后删除
  TimeHelper.callFnFastRuns(function ()
    ItemHelper.missiles[objid] = nil
  end, 30, t)
end

-- 记录投掷物队伍
function ItemHelper.recordMissileTeam (objid, teamid)
  ItemHelper.recordMissile(objid, 'teamid', teamid)
end

-- 记录投掷物速度
function ItemHelper.recordMissileSpeed (objid, speed)
  ItemHelper.recordMissile(objid, 'speed', speed)
end

-- 记录投掷物类型
function ItemHelper.recordMissileItemid (objid, itemid)
  ItemHelper.recordMissile(objid, 'itemid', itemid)
end

-- 获取投掷物信息
function ItemHelper.getMissile (objid)
  return ItemHelper.missiles[objid] or {}
end

-- 获取投掷物所属队伍，找不到队伍则返回-1
function ItemHelper.getMissileTeam (objid)
  return ItemHelper.getMissile(objid).teamid or -1
end

-- 获取投掷物速度
function ItemHelper.getMissileSpeed (objid)
  return ItemHelper.getMissile(objid).speed
end

-- 获取投掷物类型
function ItemHelper.getMissileItemid (objid)
  return ItemHelper.getMissile(objid).itemid
end

-- 事件

-- 投掷物命中
function ItemHelper.projectileHit (projectileid, toobjid, blockid, x, y, z)
  local projectileInfo = ItemHelper.projectiles[projectileid]
  if (projectileInfo) then
    local item = projectileInfo.item
    local pos = MyPosition:new(x, y, z)
    item:projectileHit(projectileInfo, toobjid, blockid, pos)
  end
end

-- 投掷物被创建
function ItemHelper.missileCreate (objid, toobjid, itemid, x, y, z)
  local teamid = ActorHelper.getTeam(objid)
  ItemHelper.recordMissileTeam(toobjid, teamid)
  ItemHelper.recordMissileItemid(toobjid, itemid)
end

-- 封装原始接口

-- 获取itemid
function ItemHelper.getItemId (objid)
  return CommonHelper.callOneResultMethod(function (p)
    return Item:getItemId(objid)
  end, '获取itemid', 'objid=', objid)
end

function ItemHelper.getItemName (itemid)
  return CommonHelper.callOneResultMethod(function (p)
    return Item:getItemName(itemid)
  end, '获取道具名称', 'itemid=', itemid)
end