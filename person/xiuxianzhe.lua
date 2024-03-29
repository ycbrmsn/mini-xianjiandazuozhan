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
    },
    talkInfos = linqianshuTalkInfos,
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
  local hour = TimeHelper.getHour()
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
    MyActorHelper.initLinqianshu(self)
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
  TimeHelper.callFnCanRun(function () -- 中间部分代码林千树与林万树相同，建议提取出来
    if (self.think) then
      if (self.think == 'free') then
        local num = BackpackHelper.getItemNumAndGrid(playerid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
        if (num) then
          if (num == 0) then
            self:toastSpeak('你可以通过击败玩家或者生物获得碎片')
            -- self:speakTo(playerid, 0, '你可以通过击败玩家或者生物获得碎片')
          elseif (num < 30) then
            self:toastSpeak('你怎么才这么点碎片')
            -- self:speakTo(playerid, 0, '你怎么才这么点碎片')
          elseif (num < 70) then
            self:toastSpeak('搜集碎片也不是一件容易的事情')
            -- self:speakTo(playerid, 0, '搜集碎片也不是一件容易的事情')
          elseif (num < 100) then
            self:toastSpeak('看来你快集齐碎片了')
            -- self:speakTo(playerid, 0, '看来你快集齐碎片了')
          else
            self:toastSpeak('你已经集齐碎片了，想要我送你回去了吗')
            -- self:speakTo(playerid, 0, '你已经集齐碎片了，想要我送你回去了吗')
          end
        else
          self:toastSpeak('嗯……')
          -- self:speakTo(playerid, 0, '嗯……')
        end
      elseif (self.think == 'goHome') then
        self:toastSpeak('天黑了就不想动了')
        -- self:speakTo(playerid, 0, '天黑了就不想动了')
      elseif (self.think == 'sleep') then
        self:toastSpeak('修仙也要适当地休息')
        -- self:speakTo(playerid, 0, '修仙也要适当地休息')
      end
    end
  end, 10, self.actorid .. 'chat' .. playerid)
end

function Linqianshu:defaultPlayerClickEvent (playerid)
  local actorTeam = CreatureHelper.getTeam(self.objid)
  local playerTeam = PlayerHelper.getTeam(playerid)
  if (actorTeam ~= 0 and actorTeam == playerTeam) then -- 有队伍并且同队
    if (self.wants and self.wants[1].style == 'sleeping') then
      self.action:playStretch()
    else
      self.action:stopRun()
    end
    self:lookAt(playerid)
    self:wantLookAt(nil, playerid, 60)
    TalkHelper.talkWith(playerid, self)
  elseif (self.think and (self.think == 'goHome' or self.think == 'sleep')) then
    self:toastSpeak('啊，你竟敢打我！')
    -- self:speakAround(nil, 0, '啊，你竟敢打我！')
    self:defaultWant()
    TimeHelper.callFnAfterSecond(function ()
      self:doItNow()
    end, 30)
  end
end

function Linqianshu:candleEvent (player, candle)
  local nickname = player:getName()
  if (self.think == 'sleep' and candle.isLit) then
    self:toastSpeak('咳咳')
    -- self:speakTo(player.objid, 0, '咳咳')
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
    },
    talkInfos = linwanshuTalkInfos,
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
  local hour = TimeHelper.getHour()
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
    MyActorHelper.initLinqianshu(self)
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
  TimeHelper.callFnCanRun(function ()
    if (self.think) then
      if (self.think == 'free') then
        local num = BackpackHelper.getItemNumAndGrid(playerid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
        if (num) then
          if (num == 0) then
            self:toastSpeak('你可以通过击败玩家或者生物获得碎片')
            -- self:speakTo(playerid, 0, '你可以通过击败玩家或者生物获得碎片')
          elseif (num < 30) then
            self:toastSpeak('你怎么才这么点碎片')
            -- self:speakTo(playerid, 0, '你怎么才这么点碎片')
          elseif (num < 70) then
            self:toastSpeak('搜集碎片也不是一件容易的事情')
            -- self:speakTo(playerid, 0, '搜集碎片也不是一件容易的事情')
          elseif (num < 100) then
            self:toastSpeak('看来你快集齐碎片了')
            -- self:speakTo(playerid, 0, '看来你快集齐碎片了')
          else
            self:toastSpeak('你已经集齐碎片了，想要我送你回去了吗')
            -- self:speakTo(playerid, 0, '你已经集齐碎片了，想要我送你回去了吗')
          end
        else
          self:toastSpeak('嗯……')
          -- self:speakTo(playerid, 0, '嗯……')
        end
      elseif (self.think == 'goHome') then
        self:toastSpeak('天黑了就不想动了')
        -- self:speakTo(playerid, 0, '天黑了就不想动了')
      elseif (self.think == 'sleep') then
        self:toastSpeak('修仙也要适当地休息')
        -- self:speakTo(playerid, 0, '修仙也要适当地休息')
      end
    end
  end, 10, self.actorid .. 'chat' .. playerid)
end

function Linwanshu:candleEvent (player, candle)
  local nickname = player:getName()
  if (self.think == 'sleep' and candle.isLit) then
    self:toastSpeak('咳咳')
    -- self:speakTo(player.objid, 0, '咳咳')
  end
end

function Linwanshu:defaultPlayerClickEvent (playerid)
  local actorTeam = CreatureHelper.getTeam(self.objid)
  local playerTeam = PlayerHelper.getTeam(playerid)
  if (actorTeam ~= 0 and actorTeam == playerTeam) then -- 有队伍并且同队
    if (self.wants and self.wants[1].style == 'sleeping') then
      self.action:playStretch()
    else
      self.action:stopRun()
    end
    self:lookAt(playerid)
    self:wantLookAt(nil, playerid, 60)
    TalkHelper.talkWith(playerid, self)
  elseif (self.think and (self.think == 'goHome' or self.think == 'sleep')) then
    self:toastSpeak('啊，你竟敢打我！')
    -- self:speakAround(nil, 0, '啊，你竟敢打我！')
    self:defaultWant()
    TimeHelper.callFnAfterSecond(function ()
      self:doItNow()
    end, 30)
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
    },
    talkInfos = yexiaolongTalkInfos,
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
  local hour = TimeHelper.getHour()
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
    MyActorHelper.initYexiaolong(self)
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
  TimeHelper.callFnCanRun(function () -- 中间部分代码叶小龙与叶大龙相同，建议提取出来
    if (self.think) then
      if (self.think == 'free') then
        local num1 = BackpackHelper.getItemNumAndGrid(playerid, MyWeaponAttr.controlSword.levelIds[1])
        local num2 = BackpackHelper.getItemNumAndGrid(playerid, MyWeaponAttr.tenThousandsSword.levelIds[1])
        local num3 = BackpackHelper.getItemNumAndGrid(playerid, MyWeaponAttr.huixianSword.levelIds[1])
        local num4 = BackpackHelper.getItemNumAndGrid(playerid, MyWeaponAttr.vitalqiSword.levelIds[1])
        if (num1 and num2 and num3 and num4) then
          if (num1 + num2 + num3 + num4 == 0) then
            self:toastSpeak('没有仙剑，你想欺负一只鸡都很难')
            -- self:speakTo(playerid, 0, '没有仙剑，你想欺负一只鸡都很难')
          else
            self:toastSpeak('怎么样，是不是仙剑在手，天下我有')
            -- self:speakTo(playerid, 0, '怎么样，是不是仙剑在手，天下我有')
          end
        else
          self:toastSpeak('嗯……')
          -- self:speakTo(playerid, 0, '嗯……')
        end
      elseif (self.think == 'goHome') then
        self:toastSpeak('天黑了准备休息了')
        -- self:speakTo(playerid, 0, '天黑了准备休息了')
      elseif (self.think == 'sleep') then
        self:toastSpeak('睡觉睡觉')
        -- self:speakTo(playerid, 0, '睡觉睡觉')
      end
    end
  end, 10, self.actorid .. 'chat' .. playerid)
end

function Yexiaolong:defaultPlayerClickEvent (playerid)
  local actorTeam = CreatureHelper.getTeam(self.objid)
  local playerTeam = PlayerHelper.getTeam(playerid)
  if (actorTeam ~= 0 and actorTeam == playerTeam) then -- 有队伍并且同队
    if (self.wants and self.wants[1].style == 'sleeping') then
      self.action:playStretch()
    else
      self.action:stopRun()
    end
    self:lookAt(playerid)
    self:wantLookAt(nil, playerid, 60)
    TalkHelper.talkWith(playerid, self)
  elseif (self.think and (self.think == 'goHome' or self.think == 'sleep')) then
    self:toastSpeak('小子，你竟敢打我！')
    -- self:speakAround(nil, 0, '小子，你竟敢打我！')
    self:defaultWant()
    TimeHelper.callFnAfterSecond(function ()
      self:doItNow()
    end, 30)
  end
end

function Yexiaolong:candleEvent (player, candle)
  local nickname = player:getName()
  if (self.think == 'sleep' and candle.isLit) then
    self:toastSpeak('……')
    -- self:speakTo(player.objid, 0, '……')
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
    },
    talkInfos = yedalongTalkInfos,
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
  local hour = TimeHelper.getHour()
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
    MyActorHelper.initYexiaolong(self)
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
  TimeHelper.callFnCanRun(function ()
    if (self.think) then
      if (self.think == 'free') then
        local num1 = BackpackHelper.getItemNumAndGrid(playerid, MyWeaponAttr.controlSword.levelIds[1])
        local num2 = BackpackHelper.getItemNumAndGrid(playerid, MyWeaponAttr.tenThousandsSword.levelIds[1])
        local num3 = BackpackHelper.getItemNumAndGrid(playerid, MyWeaponAttr.huixianSword.levelIds[1])
        local num4 = BackpackHelper.getItemNumAndGrid(playerid, MyWeaponAttr.vitalqiSword.levelIds[1])
        if (num1 and num2 and num3 and num4) then
          if (num1 + num2 + num3 + num4 == 0) then
            self:toastSpeak('没有仙剑，你想欺负一只鸡都很难')
            -- self:speakTo(playerid, 0, '没有仙剑，你想欺负一只鸡都很难')
          else
            self:toastSpeak('怎么样，是不是仙剑在手，天下我有')
            -- self:speakTo(playerid, 0, '怎么样，是不是仙剑在手，天下我有')
          end
        else
          self:toastSpeak('嗯……')
          -- self:speakTo(playerid, 0, '嗯……')
        end
      elseif (self.think == 'goHome') then
        self:toastSpeak('天黑了准备休息了')
        -- self:speakTo(playerid, 0, '天黑了准备休息了')
      elseif (self.think == 'sleep') then
        self:toastSpeak('睡觉睡觉')
        -- self:speakTo(playerid, 0, '睡觉睡觉')
      end
    end
  end, 10, self.actorid .. 'chat' .. playerid)
end

function Yedalong:defaultPlayerClickEvent (playerid)
  local actorTeam = CreatureHelper.getTeam(self.objid)
  local playerTeam = PlayerHelper.getTeam(playerid)
  if (actorTeam ~= 0 and actorTeam == playerTeam) then -- 有队伍并且同队
    if (self.wants and self.wants[1].style == 'sleeping') then
      self.action:playStretch()
    else
      self.action:stopRun()
    end
    self:lookAt(playerid)
    self:wantLookAt(nil, playerid, 60)
    TalkHelper.talkWith(playerid, self)
  elseif (self.think and (self.think == 'goHome' or self.think == 'sleep')) then
    self:toastSpeak('小子，你竟敢打我！')
    -- self:speakAround(nil, 0, '小子，你竟敢打我！')
    self:defaultWant()
    TimeHelper.callFnAfterSecond(function ()
      self:doItNow()
    end, 30)
  end
end

function Yedalong:candleEvent (player, candle)
  local nickname = player:getName()
  if (self.think == 'sleep' and candle.isLit) then
    self:toastSpeak('……')
    -- self:speakTo(player.objid, 0, '……')
  end
end