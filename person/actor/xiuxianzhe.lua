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
    talkInfos = {
      TalkInfo:new({
        id = 11,
        ants = {
          TalkAnt:new({ t = 1, taskid = 11 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '你好。请问这是哪儿？'),
            TalkSession:new(1, '这里是修仙界。因为某种原因，你来到了这里。'),
            TalkSession:new(3, '啊！那我还能回去吗？'),
            TalkSession:new(1, '当然，但是很难。你需要收集100个能量碎片。'),
            TalkSession:new(3, '能量碎片是什么？'),
            TalkSession:new(1, '在修仙界，生物死后会产生少量碎片，其中蕴含着一定的能量。这碎片就是能量碎片。'),
            TalkSession:new(3, '我集齐碎片就行了吗？'),
            TalkSession:new(1, '嗯，你集齐碎片后来找我，我用其中的能量施展大挪移之术，就可以送你回去了。'),
            TalkSession:new(3, '那能量碎片好收集吗？'),
            TalkSession:new(1, '杀死修仙界的生物视等级可以获得1~9枚碎片，杀死玩家可以获得5~9枚碎片。'),
            TalkSession:new(3, '呃，确实好难。'),
            TalkSession:new(1, '加油吧，年轻人。隔壁的小龙那里有几把不错的仙器，如果你能获得将事半功倍。'),
            TalkSession:new(3, '仙器！我去试试看。'),
          },
        }
      }),
      TalkInfo:new({
        id = 12,
        ants = {
          TalkAnt:new({ t = 1, taskid = 12 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '你好。我想要查询一下目前玩家的碎片搜集情况。'),
            TalkSession:new(1, '好。我来查查看。', function (player)
              local teamInfos = { [1] = { max = 0 }, [2] = { max = 0 } }
              for i, v in ipairs(PlayerHelper:getActivePlayers()) do
                local teamid = PlayerHelper:getTeam(v.objid)
                if (teamid) then
                  local num = BackpackHelper:getItemNumAndGrid(v.objid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
                  local info = teamInfos[teamid]
                  if (info.max < num) then
                    info.max = num
                    info.maxPlayer = v:getName()
                  end
                end
              end
              local actor = player:getClickActor()
              TalkHelper:clearProgressContent(actor, 12, 0, 3)
              local sessions = {}
              local info = teamInfos[1]
              if (info.maxPlayer) then
                table.insert(sessions, TalkSession:new(1, '目前红队搜集碎片最多的玩家是#G' .. info.maxPlayer))
                table.insert(sessions, TalkSession:new(1, '嗯，已经搜集了#G' .. info.max .. '#W枚碎片'))
              else
                table.insert(sessions, TalkSession:new(1, '目前红队还没有人搜集到碎片'))
              end
              info = teamInfos[2]
              if (info.maxPlayer) then
                table.insert(sessions, TalkSession:new(1, '目前蓝队搜集碎片最多的玩家是#G' .. info.maxPlayer))
                table.insert(sessions, TalkSession:new(1, '嗯，已经搜集了#G' .. info.max .. '#W枚碎片'))
              else
                table.insert(sessions, TalkSession:new(1, '目前蓝队还没有人搜集到碎片'))
              end
              TalkHelper:addProgressContents(actor, 12, 0, sessions)
            end),
          },
        },
      }),
      TalkInfo:new({
        id = 13,
        ants = {
          TalkAnt:new({ t = 1, taskid = 13 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '我已经集齐了能量碎片。'),
            TalkSession:new(1, '年轻人勿打诳语啊……'),
          },
        },
      }),
      TalkInfo:new({
        id = 14,
        ants = {
          TalkAnt:new({ t = 1, taskid = 14 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '我已经集齐了能量碎片。'),
            TalkSession:new(1, '好，我这就施展大挪移之术。', function (player)
              if (not(MyStoryHelper.winPlayer)) then
                MyStoryHelper.winPlayer = player
                TimeHelper:callFnFastRuns(function ()
                  PlayerHelper:setGameWin(player.objid)
                end, 2)
              end
            end),
          },
        },
      }),
      TalkInfo:new({
        id = 1,
        progress = {
          [0] = {
            TalkSession:new(1, '有事吗？'),
            TalkSession:new(4, '我要问点什么吗？'),
            TalkSession:new(5, {
              PlayerTalk:new('这是哪里', 1, nil, function (player)
                TaskHelper:addTask(player.objid, 11)
                player:resetTalkIndex(0)
              end),
              PlayerTalk:new('查询碎片搜集情况', 1, nil, function (player)
                TaskHelper:addTask(player.objid, 12)
                player:resetTalkIndex(0)
              end),
              PlayerTalk:new('集齐碎片', 1, nil, function (player)
                local num = BackpackHelper:getItemNumAndGrid(player.objid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
                if (num < 100) then
                  TaskHelper:addTask(player.objid, 13)
                  player:resetTalkIndex(0)
                else
                  TaskHelper:addTask(player.objid, 14)
                  player:resetTalkIndex(0)
                end
              end),
              PlayerTalk:new('不问什么', 1),
            }),
            TalkSession:new(3, '没什么事，打扰了。'),
          },
        },
      }),
    },
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
  TimeHelper:callFnCanRun(self.actorid, 'chat' .. playerid, function ()
    if (self.think) then
      if (self.think == 'free') then
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
      elseif (self.think == 'goHome') then
        self:speakTo(playerid, 0, '天黑了就不想动了')
      elseif (self.think == 'sleep') then
        self:speakTo(playerid, 0, '修仙也要适当地休息')
      end
    end
  end, 10)
end

function Linqianshu:defaultPlayerClickEvent (playerid)
  local actorTeam = CreatureHelper:getTeam(self.objid)
  local playerTeam = PlayerHelper:getTeam(playerid)
  if (actorTeam ~= 0 and actorTeam == playerTeam) then -- 有队伍并且同队
    if (self.wants and self.wants[1].style == 'sleeping') then
      self.action:playStretch()
    else
      self.action:stopRun()
    end
    self:lookAt(playerid)
    self:wantLookAt(nil, playerid, 60)
    TalkHelper:talkWith(playerid, self)
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
  TimeHelper:callFnCanRun(self.actorid, 'chat' .. playerid, function ()
    if (self.think) then
      if (self.think == 'free') then
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
      elseif (self.think == 'goHome') then
        self:speakTo(playerid, 0, '天黑了就不想动了')
      elseif (self.think == 'sleep') then
        self:speakTo(playerid, 0, '修仙也要适当地休息')
      end
    end
  end, 10)
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
    },
    talkInfos = {
      TalkInfo:new({ -- 接任务
        id = 21,
        ants = {
          TalkAnt:new({ t = 1, taskid = 21 }),
          TalkAnt:new({ t = 2, taskid = 210 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '有什么我能帮到你的吗？'),
            TalkSession:new(1, '我屋外的树上有一个方南瓜成熟了，你可以帮我摘下来吗？'),
            TalkSession:new(5, {
              PlayerTalk:new('接受', 3, nil, function (player, actor)
                local task = BasePumpkinTask:new(210, actor.actorid, actor:getName())
                TaskHelper:addTask(player.objid, task.id, task)
                player:speakSelf(0, '没问题，举手之劳。')
              end),
              PlayerTalk:new('拒绝', 3, nil, function (player, actor)
                player:speakSelf(0, '这个，我有点恐高。')
              end),
            }),
          },
        }
      }),
      TalkInfo:new({ -- 查询任务
        id = 2100,
        ants = {
          TalkAnt:new({ t = 1, taskid = 2100 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '你说的方南瓜我没看到。'),
            TalkSession:new(1, '就在我屋外的树上，一眼就可以看到。'),
          },
        },
      }),
      TalkInfo:new({ -- 交付任务
        id = 2101,
        ants = {
          TalkAnt:new({ t = 1, taskid = 2101 }),
          TalkAnt:new({ t = 1, taskid = 210, state = 2 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '你看看是这个方南瓜吗？'),
            TalkSession:new(1, '做得不错。这是御仙剑了，收好了。', function (player)
              TaskHelper:finishTask(player.objid, 210)
              -- local itemid = MyWeaponAttr.controlSword.levelIds[1]
              -- if (BackpackHelper:addItem(player.objid, itemid, 1)) then -- 获得仙剑
              --   BackpackHelper:removeGridItemByItemID(player.objid, 230, 1) -- 移除方南瓜
              --   TaskHelper:finishTask(player.objid, 210)
              --   PlayerHelper:showToast(player.objid, '获得', ItemHelper:getItemName(itemid))
              -- end
            end),
          },
        },
      }),
      TalkInfo:new({
        id = 22,
        ants = {
          TalkAnt:new({ t = 1, taskid = 22 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '你好。我想要查询一下目前玩家的碎片搜集情况。'),
            TalkSession:new(1, '好。我来查查看。', function (player)
              local teamInfos = { [1] = { max = 0 }, [2] = { max = 0 } }
              for i, v in ipairs(PlayerHelper:getActivePlayers()) do
                local teamid = PlayerHelper:getTeam(v.objid)
                if (teamid) then
                  local num = BackpackHelper:getItemNumAndGrid(v.objid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
                  local info = teamInfos[teamid]
                  if (info.max < num) then
                    info.max = num
                    info.maxPlayer = v:getName()
                  end
                end
              end
              local actor = player:getClickActor()
              TalkHelper:clearProgressContent(actor, 12, 0, 3)
              local sessions = {}
              local info = teamInfos[1]
              if (info.maxPlayer) then
                table.insert(sessions, TalkSession:new(1, '目前红队搜集碎片最多的玩家是#G' .. info.maxPlayer))
                table.insert(sessions, TalkSession:new(1, '嗯，已经搜集了#G' .. info.max .. '#W枚碎片'))
              else
                table.insert(sessions, TalkSession:new(1, '目前红队还没有人搜集到碎片'))
              end
              info = teamInfos[2]
              if (info.maxPlayer) then
                table.insert(sessions, TalkSession:new(1, '目前蓝队搜集碎片最多的玩家是#G' .. info.maxPlayer))
                table.insert(sessions, TalkSession:new(1, '嗯，已经搜集了#G' .. info.max .. '#W枚碎片'))
              else
                table.insert(sessions, TalkSession:new(1, '目前蓝队还没有人搜集到碎片'))
              end
              TalkHelper:addProgressContents(actor, 12, 0, sessions)
            end),
          },
        },
      }),
      TalkInfo:new({
        id = 23,
        ants = {
          TalkAnt:new({ t = 1, taskid = 23 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '我已经集齐了能量碎片。'),
            TalkSession:new(1, '年轻人勿打诳语啊……'),
          },
        },
      }),
      TalkInfo:new({
        id = 24,
        ants = {
          TalkAnt:new({ t = 1, taskid = 24 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '我已经集齐了能量碎片。'),
            TalkSession:new(1, '好，我这就施展大挪移之术。', function (player)
              if (not(MyStoryHelper.winPlayer)) then
                MyStoryHelper.winPlayer = player
                TimeHelper:callFnFastRuns(function ()
                  PlayerHelper:setGameWin(player.objid)
                end, 2)
              end
            end),
          },
        },
      }),
      TalkInfo:new({
        id = 1,
        progress = {
          [0] = {
            TalkSession:new(1, '修仙界的事太多了。', function (player, actor)
              local playerTalks = {}
              TalkHelper:clearProgressContent(actor, 1, 0, 2)
              -- 御仙剑
              if (TaskHelper:hasTask(player.objid, 210)) then -- 已有任务
                local state = TaskHelper:getTaskState(player.objid, 210)
                if (state == 1) then -- 未完成
                  table.insert(playerTalks, PlayerTalk:new('询问御仙剑任务', 1, nil, function (player)
                    TaskHelper:addTask(player.objid, 2100)
                    player:resetTalkIndex(0)
                  end))
                elseif (state == 2) then -- 已完成
                  table.insert(playerTalks, PlayerTalk:new('交付御仙剑任务', 1, nil, function (player)
                    TaskHelper:addTask(player.objid, 2101)
                    player:resetTalkIndex(0)
                  end))
                else -- 已结束
                end
              else -- 未接任务
                table.insert(playerTalks, PlayerTalk:new('御仙剑任务', 1, nil, function (player)
                  TaskHelper:addTask(player.objid, 21)
                  player:resetTalkIndex(0)
                end))
              end
              -- 万仙剑任务
              if (TaskHelper:hasTask(player.objid, 230)) then -- 已有任务
                local state = TaskHelper:getTaskState(player.objid, 230)
                if (state == 1) then -- 未完成
                  table.insert(playerTalks, PlayerTalk:new('询问万仙剑任务', 1, nil, function (player)
                    TaskHelper:addTask(player.objid, 2300)
                    player:resetTalkIndex(0)
                  end))
                elseif (state == 2) then -- 已完成
                  table.insert(playerTalks, PlayerTalk:new('交付万仙剑任务', 1, nil, function (player)
                    TaskHelper:addTask(player.objid, 2301)
                    player:resetTalkIndex(0)
                  end))
                else -- 已结束
                end
              else -- 未接任务
                table.insert(playerTalks, PlayerTalk:new('万仙剑任务', 1, nil, function (player)
                  TaskHelper:addTask(player.objid, 23)
                  player:resetTalkIndex(0)
                end))
              end
              -- 其他
              table.insert(playerTalks, PlayerTalk:new('不做什么', 1))
              TalkHelper:addProgressContent(actor, 1, 0, TalkSession:new(5, playerTalks))
              TalkHelper:addProgressContent(actor, 1, 0, TalkSession:new(3, '是的，我也有一堆事情要做。'))
            end),
          },
        },
      }),
    },
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
  TimeHelper:callFnCanRun(self.actorid, 'chat' .. playerid, function ()
    if (self.think) then
      if (self.think == 'free') then
        local num1 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.controlSword.levelIds[1])
        local num2 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.tenThousandsSword.levelIds[1])
        local num3 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.huixianSword.levelIds[1])
        local num4 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.vitalqiSword.levelIds[1])
        if (num1 and num2 and num3 and num4) then
          if (num1 + num2 + num3 + num4 == 0) then
            self:speakTo(playerid, 0, '没有仙剑，你想欺负一只鸡都很难')
          else
            self:speakTo(playerid, 0, '怎么样，是不是仙剑在手，天下我有')
          end
        else
          self:speakTo(playerid, 0, '嗯……')
        end
      elseif (self.think == 'goHome') then
        self:speakTo(playerid, 0, '天黑了准备休息了')
      elseif (self.think == 'sleep') then
        self:speakTo(playerid, 0, '睡觉睡觉')
      end
    end
  end, 10)
end

function Yexiaolong:defaultPlayerClickEvent (playerid)
  local actorTeam = CreatureHelper:getTeam(self.objid)
  local playerTeam = PlayerHelper:getTeam(playerid)
  if (actorTeam ~= 0 and actorTeam == playerTeam) then -- 有队伍并且同队
    if (self.wants and self.wants[1].style == 'sleeping') then
      self.action:playStretch()
    else
      self.action:stopRun()
    end
    self:lookAt(playerid)
    self:wantLookAt(nil, playerid, 60)
    TalkHelper:talkWith(playerid, self)
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
  TimeHelper:callFnCanRun(self.actorid, 'chat' .. playerid, function ()
    if (self.think) then
      if (self.think == 'free') then
        local num1 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.controlSword.levelIds[1])
        local num2 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.tenThousandsSword.levelIds[1])
        local num3 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.huixianSword.levelIds[1])
        local num4 = BackpackHelper:getItemNumAndGrid(playerid, MyWeaponAttr.vitalqiSword.levelIds[1])
        if (num1 and num2 and num3 and num4) then
          if (num1 + num2 + num3 + num4 == 0) then
            self:speakTo(playerid, 0, '没有仙剑，你想欺负一只鸡都很难')
          else
            self:speakTo(playerid, 0, '怎么样，是不是仙剑在手，天下我有')
          end
        else
          self:speakTo(playerid, 0, '嗯……')
        end
      elseif (self.think == 'goHome') then
        self:speakTo(playerid, 0, '天黑了准备休息了')
      elseif (self.think == 'sleep') then
        self:speakTo(playerid, 0, '睡觉睡觉')
      end
    end
  end, 10)
end

function Yedalong:candleEvent (player, candle)
  local nickname = player:getName()
  if (self.think == 'sleep' and candle.isLit) then
    self:speakTo(player.objid, 0, '……')
  end
end