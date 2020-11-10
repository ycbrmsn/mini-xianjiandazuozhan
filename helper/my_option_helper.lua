-- 我的选项工具类
MyOptionHelper = {
  optionMap = {
    ask = { -- 睡觉选项
      { '这是哪里', function (player)
          player:enableMove(true)
          player:thinks(0, '现在还不想休息。')
        end
      },
      { '查询碎片搜集情况', function (player)
          player:enableMove(true)
          TimeHelper:addHour(1)
          PlayerHelper:showToast(player.objid, '时间过去半个时辰')
          MyOptionHelper:storyForward(player)
        end
      },
      { '集齐碎片', function (player)
          player:enableMove(true)
          TimeHelper:addHour(2)
          PlayerHelper:showToast(player.objid, '时间过去一个时辰')
          MyOptionHelper:storyForward(player)
          ActorHelper:doItNow()
        end
      },
    },
    leave = { -- 离开选项
      { '不离开', function (player) -- 不离开
          local story = StoryHelper:getStory(1)
          player:thinks(0, '既然让我遇上了，不解决怎可轻易离开。')
          local ws = WaitSeconds:new(2)
          TimeHelper:callFnAfterSecond(function ()
            player:enableMove(true, true)
            player:runTo(story.inVillagePoses)
          end, ws:get())
        end
      },
      { '离开', function (player) -- 离开
          local story = StoryHelper:getStory(1)
          player:thinks(0, '君子不立于危墙之下。我还是暂且离开。')
          local ws = WaitSeconds:new(2)
          TimeHelper:callFnAfterSecond(function ()
            player:enableMove(true, true)
            player:runTo({ story.initPos })
          end, ws:use())
          ChatHelper:waitSpeak('？？？', nil, ws:use(), '他离开了。')
          ChatHelper:waitSpeak('？？？', nil, ws:use(), '嗯，这样最好了。我可不喜欢变数。')
          ChatHelper:waitSpeak('？？？', nil, ws:use(), '俺也一样。')
          TimeHelper:callFnAfterSecond(function ()
            MyGameHelper:setNameAndDesc('善身者', '三十六计走为上计')
            PlayerHelper:setGameWin(player.objid)
          end, ws:get())
        end
      },
    },
    stealMeigao = {
      { '看看她身上有什么', function (player)
          player:enableMove(true, true)
          if (not(meigao.lostBag)) then -- 有包包
            local itemid = MyMap.ITEM.BAG
            if (BackpackHelper:addItem(playerid, itemid, 1)) then
              meigao.lostBag = true
              PlayerHelper:showToast(playerid, '获得', ItemHelper:getItemName(itemid))
              MyOptionHelper:stealThink(player)
            end
          else
            player:thinkSelf(0, '她身上似乎没有什么特别的东西了。')
          end
        end
      },
      { '不做什么', function (player)
          player:enableMove(true, true)
          player:thinkSelf(0, '还是不要做什么比较好。')
        end
      },
    },
    stealChuyi = {
      { '看看她身上有什么', function (player)
          player:enableMove(true, true)
          if (not(chuyi.lostKey)) then -- 有钥匙
            local itemid = MyMap.ITEM.KEY7
            if (BackpackHelper:addItem(player.objid, itemid, 1)) then
              chuyi.lostKey = true
              PlayerHelper:showToast(player.objid, '获得', ItemHelper:getItemName(itemid))
              MyOptionHelper:stealThink(player)
            end
          else
            player:thinkSelf(0, '她身上似乎没有什么特别的东西了。')
          end
        end
      },
      { '不做什么', function (player)
          player:enableMove(true, true)
          player:thinkSelf(0, '还是不要做什么比较好。')
        end
      },
    },
  }
}

-- 显示选项
function MyOptionHelper:showOptions (player, optionname)
  local arr = self.optionMap[optionname]
  ChatHelper:showChooseItems(player.objid, arr, 1)
  player.whichChoose = optionname
end

