-- 修仙者

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
  self:lightCandle('goHome')
  self:nextWantFreeInArea('goHome', self.homeAreaPositions)
end

function Linqianshu:collidePlayer (playerid, isPlayerInFront)
  local nickname = PlayerHelper:getNickname(playerid)
  if (self.wants and self.wants[1].currentRestTime > 0) then
    local num = BackpackHelper:getItemNumAndGrid(playerid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
    if (num) then
      if (num == 0) then
        self:speakTo(playerid, 0, '你可以通过击败玩家或者生物获得碎片')
      elseif (num < 30) then
        self:speakTo(playerid, 0, '你怎么才这么点碎片')
      elseif (num < 70) then
        self:speakTo(playerid, 0, '搜集碎片也不是一件容易的事情')
      elseif (num < 100) then
        self:speakTo(playerid, 0, '看来你快集齐碎片了')
      else
        self:speakTo(playerid, 0, '你已经集齐碎片了，想要我送你回去了吗')
      end
    else
      self:speakTo(playerid, 0, '嗯……')
    end
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
  self:lightCandle('goHome')
  self:nextWantFreeInArea('goHome', self.homeAreaPositions)
end

function Linwanshu:collidePlayer (playerid, isPlayerInFront)
  local nickname = PlayerHelper:getNickname(playerid)
  if (self.wants and self.wants[1].currentRestTime > 0) then
    local num = BackpackHelper:getItemNumAndGrid(playerid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
    if (num) then
      if (num == 0) then
        self:speakTo(playerid, 0, '你可以通过击败玩家或者生物获得碎片')
      elseif (num < 30) then
        self:speakTo(playerid, 0, '你怎么才这么点碎片')
      elseif (num < 70) then
        self:speakTo(playerid, 0, '搜集碎片也不是一件容易的事情')
      elseif (num < 100) then
        self:speakTo(playerid, 0, '看来你快集齐碎片了')
      else
        self:speakTo(playerid, 0, '你已经集齐碎片了，想要我送你回去了吗')
      end
    else
      self:speakTo(playerid, 0, '嗯……')
    end
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
  self:lightCandle('goHome')
  self:nextWantFreeInArea('goHome', self.homeAreaPositions)
end

function Yexiaolong:collidePlayer (playerid, isPlayerInFront)
  local nickname = PlayerHelper:getNickname(playerid)
  if (self.wants and self.wants[1].currentRestTime > 0) then
    local num1 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.controlSword.levelIds[1])
    local num2 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.tenThousandsSword.levelIds[1])
    local num3 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.huixianSword.levelIds[1])
    local num4 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.vitalqiSword.levelIds[1])
    if (num1 and num2 and num3 and num4) then
      if (num1 + num2 + num3 + num4 == 0) then
        self:speakTo(playerid, 0, '你可以通过做我的任务获得仙剑')
      else
        self:speakTo(playerid, 0, '怎么样，是不是仙剑在手，天下我有')
      end
    else
      self:speakTo(playerid, 0, '嗯……')
    end
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
  self:lightCandle('goHome')
  self:nextWantFreeInArea('goHome', self.homeAreaPositions)
end

function Yedalong:collidePlayer (playerid, isPlayerInFront)
  local nickname = PlayerHelper:getNickname(playerid)
  if (self.wants and self.wants[1].currentRestTime > 0) then
    local num1 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.controlSword.levelIds[1])
    local num2 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.tenThousandsSword.levelIds[1])
    local num3 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.huixianSword.levelIds[1])
    local num4 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.vitalqiSword.levelIds[1])
    if (num1 and num2 and num3 and num4) then
      if (num1 + num2 + num3 + num4 == 0) then
        self:speakTo(playerid, 0, '你可以通过做我的任务获得仙剑')
      else
        self:speakTo(playerid, 0, '怎么样，是不是仙剑在手，天下我有')
      end
    else
      self:speakTo(playerid, 0, '嗯……')
    end
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