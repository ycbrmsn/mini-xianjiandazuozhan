-- 玩家行为类
BasePlayerAction = BaseActorAction:new()

function BasePlayerAction:new (player)
  local o = {
    myActor = player
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function BasePlayerAction:playAct (act, afterSeconds)
  if (afterSeconds) then
    TimeHelper:callFnAfterSecond (function (p)
      PlayerHelper:playAct(self.myActor.objid, act)
    end, afterSeconds)
  else
    PlayerHelper:playAct(self.myActor.objid, act)
  end
end

function BasePlayerAction:runTo (positions, callback)
  if (positions and #positions > 0) then
    if (self.myActor.toPos) then -- 之前的行动没有结束又来一个行动
      AreaHelper:destroyArea(self.myActor.toAreaId)
    end
    self.myActor.wants = { positions, callback }
    self:doNext()
  end
end

function BasePlayerAction:doNext ()
  if (not(self.myActor.wants)) then
    return
  end
  if (#self.myActor.wants[1] > 0) then -- 有下一段路程，则继续
    local pos = self.myActor.wants[1][1]
    self.myActor.toPos = pos
    self.myActor.toAreaId = AreaHelper:createMovePosArea(pos)
    table.remove(self.myActor.wants[1], 1)
  else -- 没有则检测回调
    self.myActor.toPos = nil
    if (#self.myActor.wants > 1) then -- 有回调则执行
      self.myActor.wants[2]()
    end
  end
end

function BasePlayerAction:execute ()
  local pos = self.myActor.toPos
  if (pos) then
    ActorHelper:tryNavigationToPos(self.myActor.objid, pos.x, pos.y, pos.z, false)
  end
end