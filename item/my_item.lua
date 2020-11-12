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
    ActorHelper:doItNow()
    local color = TeamHelper:getTeamColor(objid) or ''
    ChatHelper:sendMsg(nil, color, player:getName(), '#n发动了', self.skillname,
      '，时间变为#G', StringHelper:getHourName(realTime))
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

-- 冒险手册
Handbook = BaseItem:new({ id = MyMap.ITEM.HANDBOOK_ID })

function Handbook:useItem (objid)
  local player = PlayerHelper:getPlayer(objid)
  if (not(player.whichChoose) or player.whichChoose == 'talk') then
    ChatHelper:sendMsg(objid, '您打开了手册')
    MyOptionHelper:showOptions(player, 'index')
  else
    player.whichChoose = nil
    ChatHelper:sendMsg(objid, '您关闭了手册')
  end
end