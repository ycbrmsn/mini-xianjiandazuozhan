-- 我的道具

-- 时间轮盘
TimeTurntable = BaseItem:new(
  {
    id = MyMap.ITEM.TIME_TURNTABLE_ID,
    skillname = '白驹过隙',
    cd = 180,
    cdReason = '白驹过隙技能冷却中'
  }
)

-- 使用道具
function TimeTurntable:useItem (objid, time)
  local isEffective, realTime = TimeTurntable:isEffectiveTime(objid, time)
  if (isEffective) then
    local player = PlayerHelper:getPlayer(objid)
    if (self.skillname) then
      if (not(player:ableUseSkill(self.skillname))) then
        return
      end
    end
    if (self.cd) then
      local ableUseSkill = ItemHelper:ableUseSkill(objid, self.id, self.cd)
      if (not(ableUseSkill)) then
        self.cdReason = self.cdReason or '技能冷却中'
        ChatHelper:sendSystemMsg(self.cdReason, objid)
        return
      end
    end
    TimeHelper:setHour(realTime)
    ItemHelper:recordUseSkill(objid, self.id, self.cd)
    local color = TeamHelper:getTeamColor(objid) or ''
    ChatHelper:sendMsg(nil, '玩家', color, player:getName(), '#n发动了', self.skillname, '，当前时间变为#G', realTime)
  end
end

-- 时间是否有效
function TimeTurntable:isEffectiveTime (objid, time)
  if (type(time) == 'string') then
    time = tonumber(time)
  end
  if (type(time) == 'number') then
    if (time >= 0 and time < 24) then
      return true, math.floor(time)
    else
      ChatHelper:sendSystemMsg('时间只能在0~23之间', objid)
      return false
    end
  else
    return false
  end
end