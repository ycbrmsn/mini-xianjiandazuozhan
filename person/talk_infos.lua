-- 对话详情

-- 林千树
linqianshuTalkInfos = {
  TalkInfo:new({
    id = 11,
    ants = {
      TalkAnt:includeTask(11),
    },
    progress = {
      [0] = {
        TalkSession:speak('嗯，你好。请问这是哪儿？'),
        TalkSession:reply('这里是修仙界。因为某种原因，你来到了这里。'),
        TalkSession:speak('啊！那我还能回去吗？'),
        TalkSession:reply('当然，但是很难。你需要收集100枚能量碎片。'),
        TalkSession:speak('能量碎片是什么？'),
        TalkSession:reply('在修仙界，生物死后会产生少量碎片，其中蕴含着一定的能量。这碎片就是能量碎片。'),
        TalkSession:speak('只要我集齐碎片就行了吗？'),
        TalkSession:reply('嗯，你集齐碎片后来找我，我用其中的能量施展大挪移之术，就可以送你回去了。'),
        TalkSession:speak('那能量碎片好收集吗？'),
        TalkSession:reply('杀死修仙界的生物视等级可以获得1~9枚碎片，杀死玩家可以获得5~9枚碎片。'),
        TalkSession:speak('呃，确实好难。'),
        TalkSession:reply('加油吧，年轻人。隔壁的小龙那里有几把不错的仙器，如果你能获得将事半功倍。'),
        TalkSession:speak('仙器！我去试试看。'),
      },
    }
  }),
  TalkInfo:new({
    id = 12,
    ants = {
      TalkAnt:includeTask(12),
    },
    progress = {
      [0] = {
        TalkSession:speak('嗯，你好。我想要查询一下目前玩家的碎片搜集情况。'),
        TalkSession:reply('好。我来查查看。'):call(function (player, actor)
          MyTalkHelper.queryFragment(actor)
        end),
      },
    },
  }),
  TalkInfo:new({
    id = 13,
    ants = {
      TalkAnt:includeTask(13),
    },
    progress = {
      [0] = {
        TalkSession:speak('现在我已经集齐了能量碎片。'),
        TalkSession:reply('年轻人勿打诳语啊……'),
      },
    },
  }),
  TalkInfo:new({
    id = 14,
    ants = {
      TalkAnt:includeTask(14),
    },
    progress = {
      [0] = {
        TalkSession:speak('现在我已经集齐了能量碎片。'),
        TalkSession:reply('好，我这就施展大挪移之术。'):call(function (player, actor)
          MyTalkHelper.setWinPlayer(player, actor)
        end),
      },
    },
  }),
  TalkInfo:new({
    id = 1,
    progress = {
      [0] = {
        TalkSession:reply('有事吗？'),
        TalkSession:think('现在我要问点什么吗？'),
        TalkSession:choose({
          PlayerTalk:continue('这是哪里'):call(function (player)
            TaskHelper.addTempTask(player.objid, 11)
            player:resetTalkIndex(0)
          end),
          PlayerTalk:continue('查询碎片搜集情况'):call(function (player)
            TaskHelper.addTempTask(player.objid, 12)
            player:resetTalkIndex(0)
          end),
          PlayerTalk:continue('集齐碎片'):call(function (player)
            local num = BackpackHelper.getItemNumAndGrid(player.objid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
            if (num < 100) then
              TaskHelper.addTempTask(player.objid, 13)
              player:resetTalkIndex(0)
            else
              TaskHelper.addTempTask(player.objid, 14)
              player:resetTalkIndex(0)
            end
          end),
          PlayerTalk:continue('不问什么'),
        }),
        TalkSession:speak('没什么事，打扰了。'),
      },
    },
  }),
}

-- 林万树
linwanshuTalkInfos = {
  TalkInfo:new({
    id = 11,
    ants = {
      TalkAnt:includeTask(11),
    },
    progress = {
      [0] = {
        TalkSession:speak('嗯，你好。请问这是哪儿？'),
        TalkSession:reply('这里是修仙界。因为某种原因，你来到了这里。'),
        TalkSession:speak('啊！那我还能回去吗？'),
        TalkSession:reply('当然，但是很难。你需要收集100枚能量碎片。'),
        TalkSession:speak('能量碎片是什么？'),
        TalkSession:reply('在修仙界，生物死后会产生少量碎片，其中蕴含着一定的能量。这碎片就是能量碎片。'),
        TalkSession:speak('只要我集齐碎片就行了吗？'),
        TalkSession:reply('嗯，你集齐碎片后来找我，我用其中的能量施展大挪移之术，就可以送你回去了。'),
        TalkSession:speak('那能量碎片好收集吗？'),
        TalkSession:reply('杀死修仙界的生物视等级可以获得1~9枚碎片，杀死玩家可以获得5~9枚碎片。'),
        TalkSession:speak('呃，确实好难。'),
        TalkSession:reply('加油吧，年轻人。隔壁的大龙那里有几把不错的仙器，如果你能获得将事半功倍。'),
        TalkSession:speak('仙器！我去试试看。'),
      },
    }
  }),
  TalkInfo:new({
    id = 12,
    ants = {
      TalkAnt:includeTask(12),
    },
    progress = {
      [0] = {
        TalkSession:speak('嗯，你好。我想要查询一下目前玩家的碎片搜集情况。'),
        TalkSession:reply('好。我来查查看。'):call(function (player, actor)
          MyTalkHelper.queryFragment(actor)
        end),
      },
    },
  }),
  TalkInfo:new({
    id = 13,
    ants = {
      TalkAnt:includeTask(13),
    },
    progress = {
      [0] = {
        TalkSession:speak('现在我已经集齐了能量碎片。'),
        TalkSession:reply('年轻人勿打诳语啊……'),
      },
    },
  }),
  TalkInfo:new({
    id = 14,
    ants = {
      TalkAnt:includeTask(14),
    },
    progress = {
      [0] = {
        TalkSession:speak('现在我已经集齐了能量碎片。'),
        TalkSession:reply('好，我这就施展大挪移之术。'):call(function (player, actor)
          MyTalkHelper.setWinPlayer(player, actor)
        end),
      },
    },
  }),
  TalkInfo:new({
    id = 1,
    progress = {
      [0] = {
        TalkSession:reply('有事吗？'),
        TalkSession:think('现在我要问点什么吗？'),
        TalkSession:choose({
          PlayerTalk:continue('这是哪里'):call(function (player)
            TaskHelper.addTempTask(player.objid, 11)
            player:resetTalkIndex(0)
          end),
          PlayerTalk:continue('查询碎片搜集情况'):call(function (player)
            TaskHelper.addTempTask(player.objid, 12)
            player:resetTalkIndex(0)
          end),
          PlayerTalk:continue('集齐碎片'):call(function (player)
            local num = BackpackHelper.getItemNumAndGrid(player.objid, MyMap.ITEM.ENERGY_FRAGMENT_ID)
            if (num < 100) then
              TaskHelper.addTempTask(player.objid, 13)
              player:resetTalkIndex(0)
            else
              TaskHelper.addTempTask(player.objid, 14)
              player:resetTalkIndex(0)
            end
          end),
          PlayerTalk:continue('不问什么', 1),
        }),
        TalkSession:speak('没什么事，打扰了。'),
      },
    },
  }),
}

-- 叶小龙
yexiaolongTalkInfos = {
  -- 御仙剑
  TaskHelper.generateAcceptTalk(yuTask1, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '在我屋外的树上有一个方南瓜成熟了，你可以帮我摘下来吗？' },
    { '没问题，举手之劳。', '这个，我有点恐高。' },
  }),
  TaskHelper.generateQueryTalk(yuTask1, {
    { 3, '咦，你说的方南瓜我没看到。' },
    { 1, '就在我屋外的树上，一眼就可以看到。' },
  }),
  TaskHelper.generatePayTalk(yuTask1, {
    { 3, '看看，是这个方南瓜吗？' },
    { 1, '做得不错。这是御仙剑了，收好了。' },
  }),
  -- 万仙剑
  TaskHelper.generateAcceptTalk(wanTask1, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '听林老头说我房子上长出了一节竹子，不知是何原因。你可以帮我采一节来吗？' },
    { '没问题，不费吹灰之力。', '这个，我恐怕上不去。' },
  }),
  TaskHelper.generateQueryTalk(wanTask1, {
    { 3, '呃，你说的竹子我没发现。' },
    { 1, '林老头说就在我的屋顶上。' },
  }),
  TaskHelper.generatePayTalk(wanTask1, {
    { 3, '被我找到了，就是这节竹子。' },
    { 1, '很好。这是万仙剑了，收好了。' },
  }),
  -- 回仙剑
  TaskHelper.generateAcceptTalk(huiTask1, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '虚岩谷的幽风之狼数量好像有些多了，恐怕会生出事端，你能够去消灭一些吗？' },
    { '没问题，义不容辞。', '这个，我手无屠狼之力。' },
  }),
  TaskHelper.generateQueryTalk(huiTask1, {
    { 3, '那个，你说的虚岩谷在哪儿？' },
    { 1, '这需要你往上走，有云团阶梯连接着。' },
  }),
  TaskHelper.generatePayTalk(huiTask1, {
    { 3, '哈哈，我清理掉了5匹狼。' },
    { 1, '干得漂亮。这是回仙剑了，收好了。' },
  }),
  -- 气仙剑
  TaskHelper.generateAcceptTalk(qiTask1, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '旷野原的狂浪之牛最近有些异常，我需要一些它的兽骨来研究。你能够帮我吗？' },
    { '没问题，小菜一碟。', '这个，我心有余而力不足。' },
  }),
  TaskHelper.generateQueryTalk(qiTask1, {
    { 3, '那个，你说的旷野原在哪儿？' },
    { 1, '这需要你往上走，有云团阶梯连接着。' },
  }),
  TaskHelper.generatePayTalk(qiTask1, {
    { 3, '这就是5根兽骨了。' },
    { 1, '嗯，我果然没看错你。这是气仙剑了，收好了。' },
  }),
  -- 乱仙剑
  TaskHelper.generateAcceptTalk(luanTask1, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '外面的小动物们身上偶尔会带着苹果，可好吃了，你能帮我找来一些吗？' },
    { '没问题，手到擒来。', '这个，我也要吃。' },
  }),
  TaskHelper.generateQueryTalk(luanTask1, {
    { 3, '咦，我没在小动物身上找到苹果。' },
    { 1, '它们不是每只都带着，需要碰运气。' },
    { 3, '这样啊……' },
  }),
  TaskHelper.generatePayTalk(luanTask1, {
    { 3, '看，我带来了6个苹果。' },
    { 1, '太好了。这是乱仙剑了，收好了。' },
  }),
  -- 瞬仙剑
  TaskHelper.generateAcceptTalk(shunTask1, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '苹果总是不够吃，你能再帮我找来一些吗？' },
    { '没问题，手到擒来。', '这个，我也想吃了。' },
  }),
  TaskHelper.generateQueryTalk(shunTask1, {
    { 3, '咦，我没在小动物身上找到苹果。' },
    { 1, '它们不是每只都带着，需要碰运气。' },
    { 3, '这样啊……' },
  }),
  TaskHelper.generatePayTalk(shunTask1, {
    { 3, '看，我带来了6个苹果。' },
    { 1, '太好了。这是乱仙剑了，收好了。' },
  }),
  TalkInfo:new({ -- 修复仙剑（无仙剑）
    id = 5100,
    ants = {
      TalkAnt:includeTask(5100),
    },
    progress = {
      [0] = {
        TalkSession:speak('突然发现我的仙剑有些不锋利了，我想要修复一下。'),
        TalkSession:reply('可是我见你身上并没有仙剑需要修复。'),
      },
    },
  }),
  TalkInfo:new({ -- 修复仙剑（有仙剑）
    id = 5101,
    ants = {
      TalkAnt:includeTask(5101),
    },
    progress = {
      [0] = {
        TalkSession:speak('突然发现我的仙剑有些不锋利了，我想要修复一下。'),
        TalkSession:reply('这很简单，看我的……怎么样，是不是又焕然一新了。'):call(function (player)
          for i, itemid in ipairs(MyItemHelper.swords) do
            local num, grids = BackpackHelper.getItemNumAndGrid2(player.objid, itemid)
            for j, gridid in ipairs(grids) do
              local durcur, durmax = BackpackHelper.getGridDurability(player.objid, gridid)
              if (durcur ~= durmax) then
                BackpackHelper.setGridItem(player.objid, gridid, itemid, 1, durmax)
              end
            end
          end
        end),
        TalkSession:speak('非常感谢。'),
      },
    },
  }),
  TalkInfo:new({
    id = 1,
    progress = {
      [0] = {
        TalkSession:reply('修仙界的事太多了。'):call(function (player, actor)
          local playerTalks = {}
          TalkHelper.clearProgressContent(actor, 1, 0, 2)
          TaskHelper.appendPlayerTalk(playerTalks, player, yuTask1)
          TaskHelper.appendPlayerTalk(playerTalks, player, wanTask1)
          TaskHelper.appendPlayerTalk(playerTalks, player, huiTask1)
          TaskHelper.appendPlayerTalk(playerTalks, player, qiTask1)
          TaskHelper.appendPlayerTalk(playerTalks, player, luanTask1)
          TaskHelper.appendPlayerTalk(playerTalks, player, shunTask1)
          -- 其他
          table.insert(playerTalks, PlayerTalk:continue('修复仙剑'):call(function (player)
            local total = 0
            for i, itemid in ipairs(MyItemHelper.swords) do
              local num, grids = BackpackHelper.getItemNumAndGrid2(player.objid, itemid)
              for j, gridid in ipairs(grids) do
                local durcur, durmax = BackpackHelper.getGridDurability(player.objid, gridid)
                if (durcur ~= durmax) then
                  total = total + 1
                end
              end
            end
            if (total == 0) then
              TaskHelper.addTempTask(player.objid, 5100)
            else
              TaskHelper.addTempTask(player.objid, 5101)
            end
            player:resetTalkIndex(0)
          end))
          table.insert(playerTalks, PlayerTalk:continue('不做什么'))
          TalkHelper.addProgressContent(actor, 1, 0, TalkSession:choose(playerTalks))
          TalkHelper.addProgressContent(actor, 1, 0, TalkSession:speak('是的，我也有一堆事情要做。'))
        end),
      },
    },
  }),
}

-- 叶大龙
yedalongTalkInfos = {
  -- 御仙剑
  TaskHelper.generateAcceptTalk(yuTask2, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '在我屋外的树上有一个方南瓜成熟了，你可以帮我摘下来吗？' },
    { '没问题，举手之劳。', '这个，我有点恐高。' },
  }),
  TaskHelper.generateQueryTalk(yuTask2, {
    { 3, '咦，你说的方南瓜我没看到。' },
    { 1, '就在我屋外的树上，一眼就可以看到。' },
  }),
  TaskHelper.generatePayTalk(yuTask2, {
    { 3, '看看，是这个方南瓜吗？' },
    { 1, '做得不错。这是御仙剑了，收好了。' },
  }),
  -- 万仙剑
  TaskHelper.generateAcceptTalk(wanTask2, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '听林老头说我房子上长出了一节竹子，不知是何原因。你可以帮我采一节来吗？' },
    { '没问题，不费吹灰之力。', '这个，我恐怕上不去。' },
  }),
  TaskHelper.generateQueryTalk(wanTask2, {
    { 3, '呃，你说的竹子我没发现。' },
    { 1, '林老头说就在我的屋顶上。' },
  }),
  TaskHelper.generatePayTalk(wanTask2, {
    { 3, '被我找到了，就是这节竹子。' },
    { 1, '很好。这是万仙剑了，收好了。' },
  }),
  -- 回仙剑
  TaskHelper.generateAcceptTalk(huiTask2, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '虚岩谷的幽风之狼数量好像有些多了，恐怕会生出事端，你能够去消灭一些吗？' },
    { '没问题，义不容辞。', '这个，我手无屠狼之力。' },
  }),
  TaskHelper.generateQueryTalk(huiTask2, {
    { 3, '那个，你说的虚岩谷在哪儿？' },
    { 1, '这需要你往上走，有云团阶梯连接着。' },
  }),
  TaskHelper.generatePayTalk(huiTask2, {
    { 3, '哈哈，我清理掉了5匹狼。' },
    { 1, '干得漂亮。这是回仙剑了，收好了。' },
  }),
  -- 气仙剑
  TaskHelper.generateAcceptTalk(qiTask2, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '旷野原的狂浪之牛最近有些异常，我需要一些它的兽骨来研究。你能够帮我吗？' },
    { '没问题，小菜一碟。', '这个，我心有余而力不足。' },
  }),
  TaskHelper.generateQueryTalk(qiTask2, {
    { 3, '那个，你说的旷野原在哪儿？' },
    { 1, '这需要你往上走，有云团阶梯连接着。' },
  }),
  TaskHelper.generatePayTalk(qiTask2, {
    { 3, '这就是5根兽骨了。' },
    { 1, '嗯，我果然没看错你。这是气仙剑了，收好了。' },
  }),
  -- 乱仙剑
  TaskHelper.generateAcceptTalk(luanTask2, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '外面的小动物们身上偶尔会带着苹果，可好吃了，你能帮我找来一些吗？' },
    { '没问题，手到擒来。', '这个，我也要吃。' },
  }),
  TaskHelper.generateQueryTalk(luanTask2, {
    { 3, '咦，我没在小动物身上找到苹果。' },
    { 1, '它们不是每只都带着，需要碰运气。' },
    { 3, '这样啊……' },
  }),
  TaskHelper.generatePayTalk(luanTask2, {
    { 3, '看，我带来了6个苹果。' },
    { 1, '太好了。这是乱仙剑了，收好了。' },
  }),
  -- 瞬仙剑
  TaskHelper.generateAcceptTalk(shunTask2, {
    { 3, '有什么我能帮到你的吗？' },
    { 1, '苹果总是不够吃，你能再帮我找来一些吗？' },
    { '没问题，手到擒来。', '这个，我也想吃了。' },
  }),
  TaskHelper.generateQueryTalk(shunTask2, {
    { 3, '咦，我没在小动物身上找到苹果。' },
    { 1, '它们不是每只都带着，需要碰运气。' },
    { 3, '这样啊……' },
  }),
  TaskHelper.generatePayTalk(shunTask2, {
    { 3, '看，我带来了6个苹果。' },
    { 1, '太好了。这是乱仙剑了，收好了。' },
  }),
  TalkInfo:new({ -- 修复仙剑（无仙剑）
    id = 5200,
    ants = {
      TalkAnt:includeTask(5200),
    },
    progress = {
      [0] = {
        TalkSession:speak('突然发现我的仙剑有些不锋利了，我想要修复一下。'),
        TalkSession:reply('可是我见你身上并没有仙剑需要修复。'),
      },
    },
  }),
  TalkInfo:new({ -- 修复仙剑（有仙剑）
    id = 5201,
    ants = {
      TalkAnt:includeTask(5201),
    },
    progress = {
      [0] = {
        TalkSession:speak('突然发现我的仙剑有些不锋利了，我想要修复一下。'),
        TalkSession:reply('这很简单，看我的……怎么样，是不是又焕然一新了。'):call(function (player)
          for i, itemid in ipairs(MyItemHelper.swords) do
            local num, grids = BackpackHelper.getItemNumAndGrid2(player.objid, itemid)
            for j, gridid in ipairs(grids) do
              local durcur, durmax = BackpackHelper.getGridDurability(player.objid, gridid)
              if (durcur ~= durmax) then
                BackpackHelper.setGridItem(player.objid, gridid, itemid, 1, durmax)
              end
            end
          end
        end),
        TalkSession:speak('非常感谢。'),
      },
    },
  }),
  TalkInfo:new({
    id = 1,
    progress = {
      [0] = {
        TalkSession:reply('修仙界的事太多了。'):call(function (player, actor)
          local playerTalks = {}
          TalkHelper.clearProgressContent(actor, 1, 0, 2)
          TaskHelper.appendPlayerTalk(playerTalks, player, yuTask2)
          TaskHelper.appendPlayerTalk(playerTalks, player, wanTask2)
          TaskHelper.appendPlayerTalk(playerTalks, player, huiTask2)
          TaskHelper.appendPlayerTalk(playerTalks, player, qiTask2)
          TaskHelper.appendPlayerTalk(playerTalks, player, luanTask2)
          TaskHelper.appendPlayerTalk(playerTalks, player, shunTask2)
          -- 其他
          table.insert(playerTalks, PlayerTalk:continue('修复仙剑'):call(function (player)
            local total = 0
            for i, itemid in ipairs(MyItemHelper.swords) do
              local num, grids = BackpackHelper.getItemNumAndGrid2(player.objid, itemid)
              for j, gridid in ipairs(grids) do
                local durcur, durmax = BackpackHelper.getGridDurability(player.objid, gridid)
                if (durcur ~= durmax) then
                  total = total + 1
                end
              end
            end
            if (total == 0) then
              TaskHelper.addTempTask(player.objid, 5200)
            else
              TaskHelper.addTempTask(player.objid, 5201)
            end
            player:resetTalkIndex(0)
          end))
          table.insert(playerTalks, PlayerTalk:continue('不做什么'))
          TalkHelper.addProgressContent(actor, 1, 0, TalkSession:choose(playerTalks))
          TalkHelper.addProgressContent(actor, 1, 0, TalkSession:speak('是的，我也有一堆事情要做。'))
        end),
      },
    },
  }),
}
