-- 林千树
Linqianshu = BaseActor:new(MyMap.ACTOR.LINQIANSHU_ACTOR_ID)

function Linqianshu:new ()
  local o = {
    objid = 4295167315,
    maxHp = 120000,
    initPosition = MyPosition:new(16.5, 8.5, -6.5),
    bedData = {
      MyPosition:new(20.5, 9.5, -3.5), -- 床尾位置
      ActorHelper.FACE_YAW.SOUTH -- 床尾朝向
    },
    candlePositions = {
      MyPosition:new(18.5, 9.5, -2.5) -- 蜡烛台
    },
    homeAreaPositions = {
      {
        MyPosition:new(11.5, 9.5, -2.5), -- 屋门口角落
        MyPosition:new(20.5, 9.5, -5.5) -- 柜子床旁边
      }
    },
    target = {
      objid = nil,
      time = 0
    }
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 默认想法
function Linqianshu:defaultWant ()
  self:wantFreeInArea(self.homeAreaPositions)
end

-- 在几点想做什么
function Linqianshu:wantAtHour (hour)
  if (hour == 6) then
    self:defaultWant()
  elseif (hour == 7) then
    self:wantFreeTime()
  elseif (hour == 19) then
    self:goHome()
  elseif (hour == 21) then
    self:putOutCandleAndGoToBed()
  end
end

function Linqianshu:doItNow ()
  local hour = TimeHelper:getHour()
  if (hour >= 6 and hour < 7) then
    self:wantAtHour(6)
  elseif (hour >= 7 and hour < 19) then
    self:wantAtHour(7)
  elseif (hour >= 19 and hour < 21) then
    self:wantAtHour(19)
  else
    self:wantAtHour(21)
  end
end

-- 初始化
function Linqianshu:init ()
  local initSuc = self:initActor(self.initPosition)
  if (initSuc) then
    self:doItNow()
    MyActorHelper:initLinqianshu(self)
  end
  return initSuc
end

-- 回家
function Linqianshu:goHome ()
  self:wantMove('goHome', { self.initPosition })
  self:lightCandle()
  self:nextWantFreeInArea(self.homeAreaPositions)
end

function Linqianshu:collidePlayer (playerid, isPlayerInFront)
  local nickname = PlayerHelper:getNickname(playerid)
  if (self.wants and self.wants[1].currentRestTime > 0) then
    self:speakTo(playerid, 0, '嗯……')
  elseif (self.think == 'sleep') then
    self:speakTo(playerid, 0, '修仙也要适当地休息。')
  end
end

function Linqianshu:candleEvent (player, candle)
  local nickname = player:getName()
  if (self.think == 'sleep' and candle.isLit) then
    self:speakTo(player.objid, 0, '咳咳')
  end
end

-- 林万树
Linwanshu = BaseActor:new(MyMap.ACTOR.LINWANSHU_ACTOR_ID)

function Linwanshu:new ()
  local o = {
    objid = 4295667334,
    maxHp = 120000,
    initPosition = MyPosition:new(-7.5, 8.5, 91.5),
    bedData = {
      MyPosition:new(-11.5, 9.5, 89.5), -- 床尾位置
      ActorHelper.FACE_YAW.NORTH -- 床尾朝向
    },
    candlePositions = {
      MyPosition:new(-9.5, 9.5, 88.5) -- 蜡烛台
    },
    homeAreaPositions = {
      {
        MyPosition:new(-2.5, 9.5, 88.5), -- 屋门口角落
        MyPosition:new(-11.5, 9.5, 91.5) -- 柜子床旁边
      }
    },
    target = {
      objid = nil,
      time = 0
    }
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

-- 默认想法
function Linwanshu:defaultWant ()
  self:wantFreeInArea(self.homeAreaPositions)
end

-- 在几点想做什么
function Linwanshu:wantAtHour (hour)
  if (hour == 6) then
    self:defaultWant()
  elseif (hour == 7) then
    self:wantFreeTime()
  elseif (hour == 19) then
    self:goHome()
  elseif (hour == 21) then
    self:putOutCandleAndGoToBed()
  end
end

function Linwanshu:doItNow ()
  local hour = TimeHelper:getHour()
  if (hour >= 6 and hour < 7) then
    self:wantAtHour(6)
  elseif (hour >= 7 and hour < 19) then
    self:wantAtHour(7)
  elseif (hour >= 19 and hour < 21) then
    self:wantAtHour(19)
  else
    self:wantAtHour(21)
  end
end

-- 初始化
function Linwanshu:init ()
  local initSuc = self:initActor(self.initPosition)
  if (initSuc) then
    self:doItNow()
    MyActorHelper:initLinqianshu(self)
  end
  return initSuc
end

-- 回家
function Linwanshu:goHome ()
  self:wantMove('goHome', { self.initPosition })
  self:lightCandle()
  self:nextWantFreeInArea(self.homeAreaPositions)
end

function Linwanshu:collidePlayer (playerid, isPlayerInFront)
  local nickname = PlayerHelper:getNickname(playerid)
  if (self.wants and self.wants[1].currentRestTime > 0) then
    self:speakTo(playerid, 0, '嗯……')
  elseif (self.think == 'sleep') then
    self:speakTo(playerid, 0, '修仙也要适当地休息。')
  end
end

function Linwanshu:candleEvent (player, candle)
  local nickname = player:getName()
  if (self.think == 'sleep' and candle.isLit) then
    self:speakTo(player.objid, 0, '咳咳')
  end
end