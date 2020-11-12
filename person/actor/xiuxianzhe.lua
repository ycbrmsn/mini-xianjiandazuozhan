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
            TalkSession:new(1, '当然，但是很难。你需要收集100枚能量碎片。'),
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
            TalkSession:new(1, '好。我来查查看。', function (player, actor)
              MyTalkHelper:queryFragment(actor)
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
      -- 御仙剑
      TaskHelper:generateAcceptTalk(21, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '我屋外的树上有一个方南瓜成熟了，你可以帮我摘下来吗？' },
        { '没问题，举手之劳。', '这个，我有点恐高。' },
      }, YuTask),
      TaskHelper:generateQueryTalk(21, {
        { 3, '你说的方南瓜我没看到。' },
        { 1, '就在我屋外的树上，一眼就可以看到。' },
      }),
      TaskHelper:generatePayTalk(21, {
        { 3, '你看看是这个方南瓜吗？' },
        { 1, '做得不错。这是御仙剑了，收好了。' },
      }),
      -- 万仙剑
      TaskHelper:generateAcceptTalk(23, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '听林老头说我房子上长出了一节竹子，不知是何原因。你可以帮我采一节来吗？' },
        { '没问题，不费吹灰之力。', '这个，我恐怕上不去。' },
      }, WanTask),
      TaskHelper:generateQueryTalk(23, {
        { 3, '你说的竹子我没发现。' },
        { 1, '林老头说就在我的屋顶上。' },
      }),
      TaskHelper:generatePayTalk(23, {
        { 3, '我找到了，就是这节竹子。' },
        { 1, '很好。这是万仙剑了，收好了。' },
      }),
      -- 回仙剑
      TaskHelper:generateAcceptTalk(25, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '虚岩谷的幽风之狼数量好像有些多了，恐怕会生出事端，你能够去消灭一些吗？' },
        { '没问题，义不容辞。', '这个，我手无屠狼之力。' },
      }, HuiTask),
      TaskHelper:generateQueryTalk(25, {
        { 3, '你说的虚岩谷在哪儿？' },
        { 1, '你需要往上走，有云团阶梯连接着。' },
      }),
      TaskHelper:generatePayTalk(25, {
        { 3, '我清理掉了5匹狼。' },
        { 1, '干得漂亮。这是回仙剑了，收好了。' },
      }),
      -- 气仙剑
      TaskHelper:generateAcceptTalk(27, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '旷野原的狂浪之牛最近有些异常，我需要一些它的兽骨来研究。你能够帮我吗？' },
        { '没问题，小菜一碟。', '这个，我心有余而力不足。' },
      }, QiTask),
      TaskHelper:generateQueryTalk(27, {
        { 3, '你说的旷野原在哪儿？' },
        { 1, '你需要往上走，有云团阶梯连接着。' },
      }),
      TaskHelper:generatePayTalk(27, {
        { 3, '这就是5根兽骨了。' },
        { 1, '我果然没看错你。这是气仙剑了，收好了。' },
      }),
      -- 乱仙剑
      TaskHelper:generateAcceptTalk(29, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '外面的小动物们身上偶尔会带着苹果，可好吃了，你能帮我找来一些吗？' },
        { '没问题，手到擒来。', '这个，我也要吃。' },
      }, LuanTask),
      TaskHelper:generateQueryTalk(29, {
        { 3, '我没在小动物身上找到苹果。' },
        { 1, '它们不是每只都带着，需要碰运气。' },
        { 3, '这样啊……' },
      }),
      TaskHelper:generatePayTalk(29, {
        { 3, '我带来了6个苹果。' },
        { 1, '太好了。这是乱仙剑了，收好了。' },
      }),
      -- 瞬仙剑
      TaskHelper:generateAcceptTalk(31, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '苹果总是不够吃，你能再帮我找来一些吗？' },
        { '没问题，手到擒来。', '这个，我也想吃了。' },
      }, ShunTask),
      TaskHelper:generateQueryTalk(31, {
        { 3, '我没在小动物身上找到苹果。' },
        { 1, '它们不是每只都带着，需要碰运气。' },
        { 3, '这样啊……' },
      }),
      TaskHelper:generatePayTalk(31, {
        { 3, '我带来了6个苹果。' },
        { 1, '太好了。这是乱仙剑了，收好了。' },
      }),
      TalkInfo:new({ -- 修复仙剑（无仙剑）
        id = 5100,
        ants = {
          TalkAnt:new({ t = 1, taskid = 5100 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '我的仙剑有些不锋利了，我想要修复一下。'),
            TalkSession:new(1, '可是我见你身上并没有仙剑需要修复。'),
          },
        },
      }),
      TalkInfo:new({ -- 修复仙剑（有仙剑）
        id = 5101,
        ants = {
          TalkAnt:new({ t = 1, taskid = 5101 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '我的仙剑有些不锋利了，我想要修复一下。'),
            TalkSession:new(1, '这很简单，看我的……怎么样，是不是又焕然一新了。', function (player)
              for i, itemid in ipairs(MyItemHelper.swords) do
                local num, grids = BackpackHelper:getItemNumAndGrid2(player.objid, itemid)
                for j, gridid in ipairs(grids) do
                  local durcur, durmax = BackpackHelper:getGridDurability(player.objid, gridid)
                  if (durcur ~= durmax) then
                    BackpackHelper:setGridItem(player.objid, gridid, itemid, 1, durmax)
                  end
                end
              end
            end),
            TalkSession:new(3, '非常感谢。'),
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
              TaskHelper:appendPlayerTalk(playerTalks, player, 21, '御仙剑')
              TaskHelper:appendPlayerTalk(playerTalks, player, 23, '万仙剑')
              TaskHelper:appendPlayerTalk(playerTalks, player, 25, '回仙剑')
              TaskHelper:appendPlayerTalk(playerTalks, player, 27, '气仙剑')
              TaskHelper:appendPlayerTalk(playerTalks, player, 29, '乱仙剑')
              TaskHelper:appendPlayerTalk(playerTalks, player, 31, '瞬仙剑')
              -- 其他
              table.insert(playerTalks, PlayerTalk:new('修复仙剑', 1, nil, function (player)
                local total = 0
                for i, itemid in ipairs(MyItemHelper.swords) do
                  local num, grids = BackpackHelper:getItemNumAndGrid2(player.objid, itemid)
                  for j, gridid in ipairs(grids) do
                    local durcur, durmax = BackpackHelper:getGridDurability(player.objid, gridid)
                    if (durcur ~= durmax) then
                      total = total + 1
                    end
                  end
                end
                if (total == 0) then
                  TaskHelper:addTask(player.objid, 5100)
                else
                  TaskHelper:addTask(player.objid, 5101)
                end
                player:resetTalkIndex(0)
              end))
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
    },
    talkInfos = {
      -- 御仙剑
      TaskHelper:generateAcceptTalk(22, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '我屋外的树上有一个方南瓜成熟了，你可以帮我摘下来吗？' },
        { '没问题，举手之劳。', '这个，我有点恐高。' },
      }, YuTask),
      TaskHelper:generateQueryTalk(22, {
        { 3, '你说的方南瓜我没看到。' },
        { 1, '就在我屋外的树上，一眼就可以看到。' },
      }),
      TaskHelper:generatePayTalk(22, {
        { 3, '你看看是这个方南瓜吗？' },
        { 1, '做得不错。这是御仙剑了，收好了。' },
      }),
      -- 万仙剑
      TaskHelper:generateAcceptTalk(24, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '听林老头说我房子上长出了一节竹子，不知是何原因。你可以帮我采一节来吗？' },
        { '没问题，不费吹灰之力。', '这个，我恐怕上不去。' },
      }, WanTask),
      TaskHelper:generateQueryTalk(24, {
        { 3, '你说的竹子我没发现。' },
        { 1, '林老头说就在我的屋顶上。' },
      }),
      TaskHelper:generatePayTalk(24, {
        { 3, '我找到了，就是这节竹子。' },
        { 1, '很好。这是万仙剑了，收好了。' },
      }),
      -- 回仙剑
      TaskHelper:generateAcceptTalk(26, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '虚岩谷的幽风之狼数量好像有些多了，恐怕会生出事端，你能够去消灭一些吗？' },
        { '没问题，义不容辞。', '这个，我手无屠狼之力。' },
      }, HuiTask),
      TaskHelper:generateQueryTalk(26, {
        { 3, '你说的虚岩谷在哪儿？' },
        { 1, '你需要往上走，有云团阶梯连接着。' },
      }),
      TaskHelper:generatePayTalk(26, {
        { 3, '我清理掉了5匹狼。' },
        { 1, '干得漂亮。这是回仙剑了，收好了。' },
      }),
      -- 气仙剑
      TaskHelper:generateAcceptTalk(28, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '旷野原的狂浪之牛最近有些异常，我需要一些它的兽骨来研究。你能够帮我吗？' },
        { '没问题，小菜一碟。', '这个，我心有余而力不足。' },
      }, QiTask),
      TaskHelper:generateQueryTalk(28, {
        { 3, '你说的旷野原在哪儿？' },
        { 1, '你需要往上走，有云团阶梯连接着。' },
      }),
      TaskHelper:generatePayTalk(28, {
        { 3, '这就是5根兽骨了。' },
        { 1, '我果然没看错你。这是气仙剑了，收好了。' },
      }),
      -- 乱仙剑
      TaskHelper:generateAcceptTalk(30, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '外面的小动物们身上偶尔会带着苹果，可好吃了，你能帮我找来一些吗？' },
        { '没问题，手到擒来。', '这个，我也要吃。' },
      }, LuanTask),
      TaskHelper:generateQueryTalk(30, {
        { 3, '我没在小动物身上找到苹果。' },
        { 1, '它们不是每只都带着，需要碰运气。' },
        { 3, '这样啊……' },
      }),
      TaskHelper:generatePayTalk(30, {
        { 3, '我带来了6个苹果。' },
        { 1, '太好了。这是乱仙剑了，收好了。' },
      }),
      -- 瞬仙剑
      TaskHelper:generateAcceptTalk(32, {
        { 3, '有什么我能帮到你的吗？' },
        { 1, '苹果总是不够吃，你能再帮我找来一些吗？' },
        { '没问题，手到擒来。', '这个，我也想吃了。' },
      }, ShunTask),
      TaskHelper:generateQueryTalk(32, {
        { 3, '我没在小动物身上找到苹果。' },
        { 1, '它们不是每只都带着，需要碰运气。' },
        { 3, '这样啊……' },
      }),
      TaskHelper:generatePayTalk(32, {
        { 3, '我带来了6个苹果。' },
        { 1, '太好了。这是乱仙剑了，收好了。' },
      }),
      TalkInfo:new({ -- 修复仙剑（无仙剑）
        id = 5200,
        ants = {
          TalkAnt:new({ t = 1, taskid = 5200 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '我的仙剑有些不锋利了，我想要修复一下。'),
            TalkSession:new(1, '可是我见你身上并没有仙剑需要修复。'),
          },
        },
      }),
      TalkInfo:new({ -- 修复仙剑（有仙剑）
        id = 5201,
        ants = {
          TalkAnt:new({ t = 1, taskid = 5201 }),
        },
        progress = {
          [0] = {
            TalkSession:new(3, '我的仙剑有些不锋利了，我想要修复一下。'),
            TalkSession:new(1, '这很简单，看我的……怎么样，是不是又焕然一新了。', function (player)
              for i, itemid in ipairs(MyItemHelper.swords) do
                local num, grids = BackpackHelper:getItemNumAndGrid2(player.objid, itemid)
                for j, gridid in ipairs(grids) do
                  local durcur, durmax = BackpackHelper:getGridDurability(player.objid, gridid)
                  if (durcur ~= durmax) then
                    BackpackHelper:setGridItem(player.objid, gridid, itemid, 1, durmax)
                  end
                end
              end
            end),
            TalkSession:new(3, '非常感谢。'),
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
              TaskHelper:appendPlayerTalk(playerTalks, player, 22, '御仙剑')
              TaskHelper:appendPlayerTalk(playerTalks, player, 24, '万仙剑')
              TaskHelper:appendPlayerTalk(playerTalks, player, 26, '回仙剑')
              TaskHelper:appendPlayerTalk(playerTalks, player, 28, '气仙剑')
              TaskHelper:appendPlayerTalk(playerTalks, player, 30, '乱仙剑')
              TaskHelper:appendPlayerTalk(playerTalks, player, 32, '瞬仙剑')
              -- 其他
              table.insert(playerTalks, PlayerTalk:new('修复仙剑', 1, nil, function (player)
                local total = 0
                for i, itemid in ipairs(MyItemHelper.swords) do
                  local num, grids = BackpackHelper:getItemNumAndGrid2(player.objid, itemid)
                  for j, gridid in ipairs(grids) do
                    local durcur, durmax = BackpackHelper:getGridDurability(player.objid, gridid)
                    if (durcur ~= durmax) then
                      total = total + 1
                    end
                  end
                end
                if (total == 0) then
                  TaskHelper:addTask(player.objid, 5200)
                else
                  TaskHelper:addTask(player.objid, 5201)
                end
                player:resetTalkIndex(0)
              end))
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