-- 叶小龙
Yexiaolong = BaseActor:new(MyMap.ACTOR.YEXIAOLONG_ACTOR_ID)

function Yexiaolong:new ()
  local o = {
    objid = 4296067350,
    maxHp = 250000,
    initPosition = MyPosition:new(-0.5, 8.5, -4.5),
    bedData = {
      MyPosition:new(3.5, 9.5, -3.5), -- 床尾位置
      ActorHelper.FACE_YAW.SOUTH -- 床尾朝向
    },
    candlePositions = {
      MyPosition:new(1.5, 9.5, -2.5) -- 蜡烛台
    },
    homeAreaPositions = {
      {
        MyPosition:new(-4.5, 8.5, -2.5), -- 屋门口边上
        MyPosition:new(0.5, 8.5, -4.5) -- 屋内中央
      },
      {
        MyPosition:new(-1.5, 8.5, -6.5), -- 屋门椅子边上
        MyPosition:new(2.5, 8.5, -3.5) -- 屋内床旁边
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
function Yexiaolong:defaultWant ()
  self:wantFreeInArea(self.homeAreaPositions)
end

-- 在几点想做什么
function Yexiaolong:wantAtHour (hour)
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

function Yexiaolong:doItNow ()
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
function Yexiaolong:init ()
  local initSuc = self:initActor(self.initPosition)
  if (initSuc) then
    self:doItNow()
    MyActorHelper:initYexiaolong(self)
  end
  return initSuc
end

-- 回家
function Yexiaolong:goHome ()
  self:wantMove('goHome', { self.initPosition })
  self:lightCandle()
  self:nextWantFreeInArea(self.homeAreaPositions)
end

function Yexiaolong:collidePlayer (playerid, isPlayerInFront)
  local nickname = PlayerHelper:getNickname(playerid)
  if (self.wants and self.wants[1].currentRestTime > 0) then
    self:speakTo(playerid, 0, '嗯……')
  elseif (self.think == 'sleep') then
    self:speakTo(playerid, 0, '睡觉睡觉。')
  end
end

function Yexiaolong:candleEvent (player, candle)
  local nickname = player:getName()
  if (self.think == 'sleep' and candle.isLit) then
    self:speakTo(player.objid, 0, '……')
  end
end

-- 叶大龙
Yedalong = BaseActor:new(MyMap.ACTOR.YEDALONG_ACTOR_ID)

function Yedalong:new ()
  local o = {
    objid = 4296067351,
    maxHp = 250000,
    initPosition = MyPosition:new(9.5, 8.5, 91.5),
    bedData = {
      MyPosition:new(5.5, 9.5, 89.5), -- 床尾位置
      ActorHelper.FACE_YAW.NORTH -- 床尾朝向
    },
    candlePositions = {
      MyPosition:new(7.5, 9.5, 88.5) -- 蜡烛台
    },
    homeAreaPositions = {
      {
        MyPosition:new(13.5, 8.5, 88.5), -- 屋门口边上
        MyPosition:new(8.5, 8.5, 90.5) -- 屋内中央
      },
      {
        MyPosition:new(10.5, 8.5, 92.5), -- 屋门椅子边上
        MyPosition:new(6.5, 8.5, 89.5) -- 屋内床旁边
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
function Yedalong:defaultWant ()
  self:wantFreeInArea(self.homeAreaPositions)
end

-- 在几点想做什么
function Yedalong:wantAtHour (hour)
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

function Yedalong:doItNow ()
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
function Yedalong:init ()
  local initSuc = self:initActor(self.initPosition)
  if (initSuc) then
    self:doItNow()
    MyActorHelper:initYexiaolong(self)
  end
  return initSuc
end

-- 回家
function Yedalong:goHome ()
  self:wantMove('goHome', { self.initPosition })
  self:lightCandle()
  self:nextWantFreeInArea(self.homeAreaPositions)
end

function Yedalong:collidePlayer (playerid, isPlayerInFront)
  local nickname = PlayerHelper:getNickname(playerid)
  if (self.wants and self.wants[1].currentRestTime > 0) then
    self:speakTo(playerid, 0, '嗯……')
  elseif (self.think == 'sleep') then
    self:speakTo(playerid, 0, '睡觉睡觉。')
  end
end

function Yedalong:candleEvent (player, candle)
  local nickname = player:getName()
  if (self.think == 'sleep' and candle.isLit) then
    self:speakTo(player.objid, 0, '……')
  end
end