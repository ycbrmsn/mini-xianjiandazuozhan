-- 对话详情

-- 池末
chimoTalkInfos = {
  TalkInfo:new({
    id = 1,
    ants = {
      TalkAnt:excludeTask(lineOneTask),
      TalkAnt:excludeTask(lineTwoTask),
      TalkAnt:excludeTask(lineThreeTask),
    },
    progress = {
      [0] = {
        TalkSession:reply('你好，外地人。'),
        TalkSession:speak('你好。'),
        TalkSession:think('要不要借宿一宿呢？'),
        TalkSession:choose({
          PlayerTalk:continue('要'):call(function (player)
            TaskHelper:addTask(player.objid, lineOneTask)
            player:resetTalkIndex(0)
          end),
          PlayerTalk:continue('不要'),
        }),
        TalkSession:speak('我不小心走错门了，抱歉。'),
      }
    }
  }),
  TalkInfo:new({
    id = 24,
    ants = {
      TalkAnt:includeTask(lineOneTask),
      TalkAnt:includeItem(MyMap.ITEM.SWORD1),
      TalkAnt:includeItem(MyMap.ITEM.SWORD3),
      TalkAnt:includeItem(MyMap.ITEM.SWORD4),
    },
    progress = {
      [1] = {
        TalkSession:reply('怎么样了。'),
        TalkSession:speak('我终于拿到三把剑了。我这就去布置剑阵。'),
        TalkSession:reply('太好了……不过不必急于一时。'),
        TalkSession:reply('你奔波忙碌了这么久，也饿了吧。吃点东西，有力气了再去做事。'),
        TalkSession:speak('听你这么一说，确实有点饿了。也对，磨刀不误砍柴工。'),
        TalkSession:reply('嗯，你稍等。'):call(function (player)
          local want = chimo:wantApproach('forceDoNothing', { chimo.cakePos })
          ActorActionHelper:callback(want, function ()
            BlockHelper:placeBlock(830, chimo.cakePos.x, chimo.cakePos.y, chimo.cakePos.z) -- 放置蛋糕
            local want2 = chimo:wantApproach('forceDoNothing', { player:getMyPosition() })
            ActorActionHelper:callback(want2, function ()
              TalkHelper:setProgress(player.objid, 2, 25)
              chimo:forceDoNothing()
              chimo:wantLookAt('forceDoNothing', player, 100)
              chimo:speakTo(player.objid, 0, '你看看味道怎样。')
              ChatHelper:showEndSeparate(player.objid)
              player:resetTalkIndex(1)
              Story1:comeToEatCake(player)
            end)
          end)
        end),
      },
    },
  }),
  TalkInfo:new({
    id = 14,
    ants = {
      TalkAnt:includeTask(lineOneTask),
      TalkAnt:excludeTask(task5),
      TalkAnt:includeItem(MyMap.ITEM.SWORD1),
      TalkAnt:includeItem(MyMap.ITEM.SWORD3),
    },
    progress = {
      [1] = {
        TalkSession:speak('终于又借来一把。'),
        TalkSession:reply('真是太好了。'),
        TalkSession:speak('我感觉邪气又浓了一些。'),
        TalkSession:reply('啊，是吗？还有一把也摆脱你了。在东南方的莫家。'),
        TalkSession:speak('事不宜迟，我这就前往。'):call(function (player)
          TaskHelper:addTask(player.objid, task5)
          TalkHelper:setProgress(player.objid, 2, 20)
          TalkHelper:resetProgressContent(chimo, 2, 0, {
            TalkSession:reply('怎么样，在莫家借到剑了吗？'),
            TalkSession:speak('还没。'),
          })
        end),
      },
    },
  }),
  TalkInfo:new({
    id = 2,
    ants = {
      TalkAnt:includeTask(lineOneTask),
    },
    progress = {
      [1] = {
        TalkSession:speak('我想要借宿一宿。'),
        TalkSession:reply('客房正好空着，你自便。'),
      },
      [2] = {
        TalkSession:reply('你有事吗？'),
        TalkSession:speak('我略懂观气之术，见村子上方似乎汇聚了一股邪气。'),
        TalkSession:reply('邪气！'),
        TalkSession:speak('是的。不知最近村子里可有什么事情发生。'),
        TalkSession:reply('嗯，听你这么一说，我也觉得最近有些心绪不宁。不过近期村子里很太平。'),
        TalkSession:reply('对了，我听说村子里有几把极品桃木剑，不知可否用来驱散邪气。'),
        TalkSession:speak('极品桃木剑？如果有三四把，我可以摆出剑阵，驱散邪气，并找出来源。'),
        TalkSession:reply('那太好了。请你一定要帮助我们。'),
        TalkSession:reply('我隔壁的甄家就有一把，不过那似乎是他的传家宝，想要借来可不容易。'),
        TalkSession:speak('甄家吗？那我去试试看。'):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 3)
        end),
      },
      [3] = {
        TalkSession:reply('你去甄家借来桃木剑了吗？'),
        TalkSession:speak('还没。'),
      },
      [4] = {
        TalkSession:reply('你借来桃木剑了吗？'),
        TalkSession:speak('没有。我刚表露出借的意思他就回绝了。'),
        TalkSession:reply('那这可如何是好？'),
        TalkSession:speak('我再想想办法。'),
      },
      [5] = {
        TalkSession:reply('怎么样了？'),
        TalkSession:speak('还没想到什么办法。对了，听说你们每家都有物品柜？'),
        TalkSession:reply('嗯，没错。是了，甄道一定是把剑放柜子里的。'),
        TalkSession:speak('就算是，那也没有办法。'),
        TalkSession:reply('不，如果我们拿到钥匙……'),
        TalkSession:speak('你这不是偷吗？'),
        TalkSession:reply('事急从权。如果能驱散掉邪气，这不算什么。'),
        TalkSession:reply('而且我们只是借用一下，到时候还会还过去。'),
        TalkSession:speak('这……'),
        TalkSession:reply('这邪气不除，我心难安。请你务必帮助我们消灭邪气。'),
        TalkSession:speak('……那好吧。仅此一次，下不为例。用完我就把剑还回去。'),
        TalkSession:reply('太感谢了。钥匙可能在他身上。等到夜间，你可以去看看。'),
        TalkSession:speak('晚上我去看看吧。'):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 6)
        end),
      },
      [6] = {
        TalkSession:reply('怎么样，“借”到剑了吗？'),
        TalkSession:speak('还没。'),
      },
      [7] = {
        TalkSession:reply('怎么样，“借”到剑了吗？'),
        TalkSession:speak('总算是“借”到了。'),
        TalkSession:speak('不过我感觉邪气似乎重了一些。'),
        TalkSession:reply('啊，那得赶紧拿到另外几把剑了。'),
        TalkSession:reply('储依家里也有一把。她家在村子的东北方向。'),
        TalkSession:speak('我去看看。'):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 8)
          TalkHelper:resetProgressContent(chimo, 2, 0, {
            TalkSession:reply('怎么样，去储家借到剑了吗？'),
            TalkSession:speak('还没。'),
          })
        end),
      },
      [10] = {
        TalkSession:reply('怎么样，借到剑了吗？'),
        TalkSession:speak('储依答应借剑，不过需要借来梅膏的包作为交换条件。'),
        TalkSession:speak('而要借来梅膏的包，需要答对她的问题。可惜我答错了。'),
        TalkSession:reply('梅膏吗？我跟她关系还不错。这样，我休书一封，她看后会借给你的。'),
        TalkSession:speak('那真是太好了。'),
        TalkSession:reply('你稍等一下。'):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 11)
        end),
      },
      [11] = {
        TalkSession:reply('好了，你拿去吧。'):call(function (player)
          local itemid = MyMap.ITEM.LETTER
          if (BackpackHelper:gainItem(player.objid, itemid, 1)) then
            TalkHelper:setProgress(player.objid, 2, 12)
            chimo.lostLetter = true
            PlayerHelper:showToast(player.objid, '获得', ItemHelper:getItemName(itemid))
          end
        end),
      },
      [21] = {
        TalkSession:speak('听说村里有四把剑？'),
        TalkSession:reply('是的，不过一次搬房子的时候，姚家的剑遗失了。'),
        TalkSession:speak('那有可能找到吗？'),
        TalkSession:reply('这么多年来都没听说过，要找到不太可能。莫家那里如何？'),
        TalkSession:speak('他说需要一件有类似功能的道具作为交换，才能借给我。'),
        TalkSession:reply('类似功能的道具？'),
        TalkSession:reply('对了，前段时间，我去梁家玩的时候，他说他在房子里找到了一件可以辟邪的道具。'),
        TalkSession:speak('真的吗？'),
        TalkSession:reply('当时我也没在意，刚刚听你一提，突然想起来了。'),
        TalkSession:reply('你可以向他借来。我跟他关系还行，你就说我向他借，应该没问题。'),
        TalkSession:speak('如果真是这样，那就太好了。我这就去看看。'):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 22)
          TalkHelper:resetProgressContent(chimo, 2, 0, {
            TalkSession:reply('你就说我向他借，应该没问题。'),
            TalkSession:speak('我知道了。'),
          })
        end),
      }
    },
  }),
}

-- 梅膏
meigaoTalkInfos = {
  TalkInfo:new({
    id = 1,
    ants = {
      TalkAnt:excludeTask(lineOneTask),
      TalkAnt:excludeTask(lineTwoTask),
      TalkAnt:excludeTask(lineThreeTask),
    },
    progress = {
      [0] = {
        TalkSession:speak('你好，我可以借宿一宿吗？'),
        TalkSession:reply('我家里不欢迎陌生人。'),
        TalkSession:speak('抱歉，我这就离开。'),
      },
    },
  }),
  TalkInfo:new({
    id = 12,
    ants = {
      TalkAnt:includeTask(lineOneTask),
      TalkAnt:includeItem(MyMap.ITEM.LETTER),
    },
    progress = {
      [1] = {
        TalkSession:reply('你没答对，包不能借给你。'),
        TalkSession:speak('我这里有池末给你的一封信。'),
        TalkSession:reply('池末那小子……'),
        TalkSession:reply('给我看看。'):call(function (player)
          local itemid = MyMap.ITEM.LETTER
          if (BackpackHelper:removeGridItemByItemID(player.objid, itemid, 1)) then
            TalkHelper:setProgress(player.objid, 2, 13)
            PlayerHelper:showToast(player.objid, '失去', ItemHelper:getItemName(itemid))
          end
        end),
      },
    },
  }),
  TalkInfo:new({
    id = 2,
    ants = {
      TalkAnt:includeTask(lineOneTask),
    },
    progress = {
      [0] = {
        TalkSession:reply('我家里不欢迎陌生人。'),
        TalkSession:speak('抱歉，我这就离开。'),
      },
      [9] = {
        TalkSession:speak('你好，在下有一事相求。'),
        TalkSession:reply('嗯……'),
        TalkSession:speak('听闻小姐有一个好看的包包，可否借在下几天？小姐若有要求，也可提出来。'),
        TalkSession:reply('……'),
        TalkSession:reply('好。问你一个问题，如果你能答对，我就借给你。'),
        TalkSession:speak('一言为定。你说吧。'),
        TalkSession:reply('我们村子里有几扇铁门？'),
        TalkSession:choose({
          PlayerTalk:continue('九扇'),
          PlayerTalk:to('十扇', 10),
          PlayerTalk:to('十一扇', 11),
          PlayerTalk:to('十二扇', 12),
        }),
        TalkSession:speak('有九扇门。'):to(13),
        TalkSession:speak('有十扇门。'):to(13),
        TalkSession:speak('有十一扇门。'):to(14),
        TalkSession:speak('有十二扇门。'):to(13),
        TalkSession:reply('很遗憾，你答错了。包不能借给你了。'):to(-1):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 10)
          TalkHelper:resetProgressContent(meigao, 2, 0, {
            TalkSession:reply('你没答对，包不能借给你。'),
            TalkSession:think('看来只能想其他办法了。'),
          })
        end),
        TalkSession:reply('没错。包就借给你几天。'):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 16)
          player:resetTalkIndex(0)
          meigao.lostBag = true
          local itemid = MyMap.ITEM.BAG
          if (BackpackHelper:gainItem(player.objid, itemid, 1)) then
            PlayerHelper:showToast(player.objid, '获得', ItemHelper:getItemName(itemid))
          end
          TalkHelper:resetProgressContent(meigao, 2, 0, {
            TalkSession:reply('没想到这么难的问题你都能答上来。'),
            TalkSession:speak('侥幸而已。'),
          })
        end),
      },
      [13] = {
        TalkSession:reply('嗯，看在池末的份上，包包就借给你几天。'):call(function (player)
          if (meigao.lostBag) then -- 包包不在
            TalkHelper:setProgress(player.objid, 2, 14)
            player:resetTalkIndex(0)
          else
            local itemid = MyMap.ITEM.BAG
            if (BackpackHelper:gainItem(player.objid, itemid, 1)) then
              PlayerHelper:showToast(player.objid, '获得', ItemHelper:getItemName(itemid))
              TalkHelper:setProgress(player.objid, 2, 16)
              player:resetTalkIndex(0)
              TalkHelper:resetProgressContent(meigao, 2, 0, {
                TalkSession:reply('包就借给你几天。'),
                TalkSession:speak('万分感谢。'),
              })
            end
          end
        end),
      },
      [14] = {
        TalkSession:reply('！！！'),
        TalkSession:reply('我包包不见了……'),
        TalkSession:speak('……'):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 15)
          player:resetTalkIndex(0)
        end),
      },
      [15] = {
        TalkSession:reply('抱歉，我包包不见了，没办法借给你了。'),
        TalkSession:speak('……'),
      },
      [16] = {
        TalkSession:speak('万分感谢。'):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 17)
        end),
      },
    },
  }),
}

-- 王毅
wangyiTalkInfos = {
  TalkInfo:new({
    id = 1,
    ants = {
      TalkAnt:excludeTask(lineOneTask),
      TalkAnt:excludeTask(lineTwoTask),
      TalkAnt:excludeTask(lineThreeTask),
    },
    progress = {
      [0] = {
        TalkSession:speak('你好，我可以借宿一宿吗？'),
        TalkSession:reply('我家里不欢迎陌生人。'),
        TalkSession:speak('抱歉，我这就离开。'),
      },
    },
  }),
  TalkInfo:new({
    id = 2,
    ants = {
      TalkAnt:includeTask(lineOneTask),
    },
    progress = {
      [0] = {
        TalkSession:reply('我家里不欢迎陌生人。'),
        TalkSession:speak('抱歉，我这就离开。'),
      },
    },
  }),
}

-- 梁杖
liangzhangTalkInfos = {
  TalkInfo:new({
    id = 1,
    ants = {
      TalkAnt:excludeTask(lineOneTask),
      TalkAnt:excludeTask(lineTwoTask),
      TalkAnt:excludeTask(lineThreeTask),
    },
    progress = {
      [0] = {
        TalkSession:speak('你好，我可以借宿一宿吗？'),
        TalkSession:reply('这你得问村长。'),
        TalkSession:think('？？？'),
        TalkSession:speak('抱歉，我这就离开。'),
      },
    }
  }),
  TalkInfo:new({
    id = 2,
    ants = {
      TalkAnt:includeTask(lineOneTask),
    },
    progress = {
      [22] = {
        TalkSession:speak('你好。冒昧来访，确实是有要事。'),
        TalkSession:reply('……'),
        TalkSession:reply('是要借宿吗？'),
        TalkSession:speak('不是这事。听闻你有一件辟邪的道具。可否……'),
        TalkSession:reply('没有。'),
        TalkSession:speak('呃……'),
        TalkSession:speak('池末说想向你借一件辟邪的道具。'),
        TalkSession:reply('哦，那是什么。'),
        TalkSession:speak('他说是你在屋子里找到的。'),
        TalkSession:reply('……'),
        TalkSession:reply('你等等。'):call(function (player)
          local want = liangzhang:wantApproach('forceDoNothing', { liangzhang.mirrorPos })
          ActorActionHelper:callback(want, function ()
            local want2 = liangzhang:wantApproach('forceDoNothing', { player:getMyPosition() })
            ActorActionHelper:callback(want2, function ()
              local itemid = MyMap.ITEM.MIRROR
              if (BackpackHelper:gainItem(player.objid, itemid, 1)) then
                PlayerHelper:showToast(player.objid, '获得', ItemHelper:getItemName(itemid))
                TalkHelper:setProgress(player.objid, 2, 23)
                TalkHelper:resetProgressContent(liangzhang, 2, 0, {
                  TalkSession:reply('记得还我。'),
                  TalkSession:speak('一定。'),
                })
                liangzhang.wants = nil
              liangzhang:speakTo(player.objid, 0, '拿给你了，让他记得还我。')
              ChatHelper:showEndSeparate(player.objid)
              player:resetTalkIndex(1)
              end
            end)
          end)
        end),
      },
    },
  }),
}

-- 甄道
zhendaoTalkInfos = {
  TalkInfo:new({
    id = 1,
    ants = {
      TalkAnt:excludeTask(lineOneTask),
      TalkAnt:excludeTask(lineTwoTask),
      TalkAnt:excludeTask(lineThreeTask),
    },
    progress = {
      [0] = {
        TalkSession:reply('你好，外地人。'),
        TalkSession:speak('你好。'),
        TalkSession:reply('我正忙着，如果没事不要打扰我。'),
        -- TalkSession:think('要不要借宿一宿呢？'),
        -- TalkSession:choose({
        --   PlayerTalk:continue('要'):call(function (player)
        --     TaskHelper:addTask(player.objid, 3)
        --     player:resetTalkIndex(0)
        --   end),
        --   PlayerTalk:continue('不要'),
        -- }),
        TalkSession:speak('抱歉，我这就离开。'),
      }
    }
  }),
  TalkInfo:new({
    id = 2,
    ants = {
      TalkAnt:includeTask(lineOneTask),
    },
    progress = {
      [3] = {
        TalkSession:reply('你好。'),
        TalkSession:speak('你好。我见你们村上被一股邪气笼罩。'),
        TalkSession:reply('……'),
        TalkSession:reply('你有办法解决吗？'),
        TalkSession:speak('听说你有一把桃木剑。'),
        TalkSession:reply('那又如何？'),
        TalkSession:speak('可否借我一用，待我完成剑阵驱散邪气即可还你。'),
        TalkSession:reply('不可能。'),
        TalkSession:speak('邪气不除，恐生祸端。'),
        TalkSession:reply('我自有打算。不送。'):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 4)
          TalkHelper:resetProgressContent(zhendao, 2, 0, {
            TalkSession:reply('我是不会借剑给你的。'),
            TalkSession:speak('……'),
          })
        end),
      },
      [4] = {
        TalkSession:reply('我自有打算。不送。'),
        TalkSession:think('很有主见啊……'),
      },
    },
  }),
}

-- 姚羔
yaogaoTalkInfos = {
  TalkInfo:new({
    id = 1,
    ants = {
      TalkAnt:excludeTask(lineOneTask),
      TalkAnt:excludeTask(lineTwoTask),
      TalkAnt:excludeTask(lineThreeTask),
    },
    progress = {
      [0] = {
        TalkSession:speak('你好。我想借宿一宿，不知方不方便？'),
        TalkSession:reply('这要问村长了。'),
        TalkSession:think('？？？'),
        TalkSession:speak('那打扰了。'),
      },
    },
  }),
  TalkInfo:new({
    id = 2,
    ants = {
      TalkAnt:includeTask(lineOneTask),
    },
    progress = {
      [0] = {
        TalkSession:reply('我家的床可能短时间内修不好了。'),
      },
    },
  }),
}

-- 储依
chuyiTalkInfos = {
  TalkInfo:new({
    id = 1,
    ants = {
      TalkAnt:excludeTask(lineOneTask),
      TalkAnt:excludeTask(lineTwoTask),
      TalkAnt:excludeTask(lineThreeTask),
    },
    progress = {
      [0] = {
        TalkSession:speak('你好。我想借宿一宿，不知方不方便？'),
        TalkSession:reply('不太方便。'),
        TalkSession:speak('这样啊，那打扰了。'),
      },
    },
  }),
  TalkInfo:new({
    id = 13,
    ants = {
      TalkAnt:includeTask(lineOneTask),
      TalkAnt:includeItem(MyMap.ITEM.BAG),
    },
    progress = {
      [1] = {
        TalkSession:speak('你看看是这个包吗？'):call(function (player)
          player:takeOutItem(MyMap.ITEM.BAG)
        end),
        TalkSession:reply('没错，就是这个呢。'):call(function (player)
          player:takeOutItem(MyMap.ITEM.BAG)
        end),
        TalkSession:speak('那给你。'):call(function (player)
          player:takeOutItem(MyMap.ITEM.BAG)
        end),
        TalkSession:reply('太好了。你等等，我这就去取剑。'):call(function (player)
          local itemid = MyMap.ITEM.BAG
          if (BackpackHelper:removeGridItemByItemID(player.objid, itemid, 1)) then -- 失去包
            TalkHelper:setProgress(player.objid, 2, 17)
            PlayerHelper:showToast(player.objid, '失去', ItemHelper:getItemName(itemid))
            local want = chuyi:wantApproach('forceDoNothing', { chuyi.boxPos })
            ActorActionHelper:callback(want, function ()
              local want2 = chuyi:wantApproach('forceDoNothing', { player:getMyPosition() })
              local itemid = MyMap.ITEM.SWORD3
              if (not(BackpackHelper:hasItem(player.objid, itemid))) then -- 玩家没有剑
                WorldContainerHelper:removeStorageItemByID(chuyi.boxPos.x, 
                  chuyi.boxPos.y, chuyi.boxPos.z, itemid, 1) -- 删除箱子里的剑
                ActorActionHelper:callback(want2, function ()
                  if (BackpackHelper:gainItem(player.objid, itemid, 1)) then
                    PlayerHelper:showToast(player.objid, '获得', ItemHelper:getItemName(itemid))
                    TalkHelper:setProgress(player.objid, 2, 18)
                    TalkHelper:resetProgressContent(chuyi, 2, 0, {
                      TalkSession:reply('用完记得还给我。'),
                      TalkSession:speak('一定归还。'),
                    })
                    chuyi.wants = nil
                  end
                  chuyi:speakTo(player.objid, 0, '剑借你两天，用完记得还给我。')
                  ChatHelper:showEndSeparate(player.objid)
                  player:resetTalkIndex(1)
                end)
              else -- 无剑
                chuyi:speakAround(nil, 0, '我的剑呢？！！！')
                -- TaskHelper:addTask(player.objid, 8)
                ActorActionHelper:callback(want2, function ()
                  TalkHelper:setProgress(player.objid, 2, 18)
                  TalkHelper:resetProgressContent(chuyi, 2, 0, {
                    TalkSession:reply('这可恶的贼！'),
                    TalkSession:speak('……'),
                  })
                  chuyi.wants = nil
                  chuyi:speakTo(player.objid, 0, '我的剑不见了，暂时不能借你了。别让我找到这个贼！')
                  TimeHelper:callFnAfterSecond(function ()
                    player:speakSelf(0, '……')
                    ChatHelper:showEndSeparate(player.objid)
                  end)
                  player:resetTalkIndex(1)
                end)
              end
            end)
          end
        end),
      },
    },
  }),
  TalkInfo:new({
    id = 2,
    ants = {
      TalkAnt:includeTask(lineOneTask),
    },
    progress = {
      [8] = {
        TalkSession:reply('我家的床还没修好。'),
        TalkSession:speak('今天不是为了借宿的事情。我发现你们村子被一股邪气笼罩。'),
        TalkSession:reply('啊，有吗？'),
        TalkSession:speak('不错，我正是为此而来。你可发现今天天空的阴云更浓了。'),
        TalkSession:reply('啊，好像是的。'),
        TalkSession:speak('那便是受邪气聚集的影响。我需要几把桃木剑，摆出剑阵驱散邪气。'),
        TalkSession:speak('听闻祖上有一把桃木剑，特来借剑一用。'),
        TalkSession:reply('啊，我家的桃木剑不能随便借的。'),
        TalkSession:speak('我只是借用两天，完成剑阵驱散邪气后即可还你。'),
        TalkSession:noReply('两天应该关系不大吧……'),
        TalkSession:reply('要借你也不是不行。我好喜欢梅姐姐的包包，如果你能借来让我背几天，我就借给你。'),
        TalkSession:speak('你的梅姐姐？'),
        TalkSession:reply('梅姐姐家在村的东南方。如果你借来包包，我就借剑给你。'),
        TalkSession:speak('好的，一言为定。'):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 9)
          TalkHelper:resetProgressContent(chuyi, 2, 0, {
            TalkSession:reply('如果你借来梅姐姐的包包，我就借剑给你。'),
          })
        end),
      },
      [17] = {
        TalkSession:reply('我先去取剑。'):call(function (player)
          chuyi:actionRightNow()
        end),
      },
    },
  }),
}

-- 莫迟
mochiTalkInfos = {
  TalkInfo:new({
    id = 1,
    ants = {
      TalkAnt:excludeTask(lineOneTask),
      TalkAnt:excludeTask(lineTwoTask),
      TalkAnt:excludeTask(lineThreeTask),
    },
    progress = {
      [0] = {
        TalkSession:speak('你好。我想借宿一宿，不知方不方便？'),
        TalkSession:reply('真不巧，我正要准备修床。'),
        TalkSession:speak('这样啊，那打扰了。'),
      },
    },
  }),
  TalkInfo:new({
    id = 13,
    ants = {
      TalkAnt:includeTask(lineOneTask),
      TalkAnt:includeTask(task7),
      TalkAnt:includeItem(MyMap.ITEM.MIRROR)
    },
    progress = {
      [1] = {
        TalkSession:speak('你看这道具行吗？'):call(function (player)
          player:takeOutItem(MyMap.ITEM.MIRROR)
        end),
        TalkSession:reply('这是……八卦镜。没想到你能寻得此物。'),
        TalkSession:reply('若是与此物作为交换，我倒是可以借给你几天。'),
        TalkSession:speak('好，那给你。'),
        TalkSession:reply('你稍等。'):call(function (player)
          local itemid = MyMap.ITEM.MIRROR
          if (BackpackHelper:removeGridItemByItemID(player.objid, itemid, 1)) then -- 失去八卦镜
            TalkHelper:setProgress(player.objid, 2, 24)
            PlayerHelper:showToast(player.objid, '失去', ItemHelper:getItemName(itemid))
            local want = mochi:wantApproach('forceDoNothing', { mochi.boxPos })
            ActorActionHelper:callback(want, function ()
              local want2 = mochi:wantApproach('forceDoNothing', { player:getMyPosition() })
              local itemid = MyMap.ITEM.SWORD4
              if (not(BackpackHelper:hasItem(player.objid, itemid))) then -- 玩家没有剑
                WorldContainerHelper:removeStorageItemByID(mochi.boxPos.x, 
                  mochi.boxPos.y, mochi.boxPos.z, itemid, 1) -- 删除箱子里的剑
                ActorActionHelper:callback(want2, function ()
                  if (BackpackHelper:gainItem(player.objid, itemid, 1)) then
                    PlayerHelper:showToast(player.objid, '获得', ItemHelper:getItemName(itemid))
                    TalkHelper:resetProgressContent(mochi, 2, 0, {
                      TalkSession:reply('记得还给我。'),
                      TalkSession:speak('一定归还。'),
                    })
                    mochi.wants = nil
                  end
                  mochi:speakTo(player.objid, 0, '用完记得还给我。')
                  ChatHelper:showEndSeparate(player.objid)
                  player:resetTalkIndex(1)
                end)
              else
                mochi:speakAround(nil, 0, '岂有此理！！！')
                -- TaskHelper:addTask(player.objid, 9)
                ActorActionHelper:callback(want2, function ()
                  TalkHelper:setProgress(player.objid, 2, 18)
                  TalkHelper:resetProgressContent(chuyi, 2, 0, {
                    TalkSession:reply('这该如何是好？'),
                    TalkSession:speak('……'),
                  })
                  mochi.wants = nil
                  mochi:speakTo(player.objid, 0, '我的剑失踪了，暂时不能借你了。')
                  TimeHelper:callFnAfterSecond(function ()
                    player:speakSelf(0, '……')
                    ChatHelper:showEndSeparate(player.objid)
                  end)
                  player:resetTalkIndex(1)
                end)
              end
            end)
          end
        end),
      },
    },
  }),
  TalkInfo:new({
    id = 2,
    ants = {
      TalkAnt:includeTask(lineOneTask),
    },
    progress = {
      [0] = {
        TalkSession:speak('你好。我想借宿一宿，不知方不方便？'),
        TalkSession:reply('真不巧，我家的床坏了。'),
        TalkSession:speak('这样啊，那打扰了。'),
      },
      [20] = {
        TalkSession:reply('我家的床还没修好。'),
        TalkSession:speak('今天不是为借宿而来。你可知你们村长被邪气笼罩着。'),
        TalkSession:reply('略知一二。'),
        TalkSession:speak('你知道就最好不过了。我想借你的桃木剑一用，摆出三义剑阵驱散邪气。'),
        TalkSession:reply('正是因为知道，所以才不能借给你。'),
        TalkSession:speak('？？？'),
        TalkSession:reply('我们村因处于特殊的位置，很容易招来四方邪气。'),
        TalkSession:reply('为此，村里的先辈们打造出了四把桃木剑，各镇一方，可破诸邪。'),
        TalkSession:think('原来剑有四把。'),
        TalkSession:reply('不过因为某些原因，有一把剑遗失了。于是才有了随后的邪气。'),
        TalkSession:speak('既然如此，那更应该驱散邪气，并找出根源。请相信我。'),
        TalkSession:reply('我说了这么多，你就应该知道，剑不能随便移位。除非你能找到替代品。'),
        TalkSession:speak('替代品？'),
        TalkSession:reply('不错。就是有类似功能的道具。'),
        TalkSession:speak('那我试试吧。'),
        TalkSession:reply('在你没有拿来其他替代品之前，我是不会借的。'),
        TalkSession:think('看来只能找到替代品了。'):call(function (player)
          TaskHelper:addTask(player.objid, task7)
          TalkHelper:setProgress(player.objid, 2, 21)
          TalkHelper:resetProgressContent(mochi, 2, 0, {
            TalkSession:reply('我是不会随便借的。'),
            TalkSession:think('看来只能找到替代品了。'),
          })
        end),
      },
    },
  }),
}

-- 陆仁
lurenTalkInfos = {
  TalkInfo:new({
    id = 1,
    ants = {
      TalkAnt:excludeTask(lineOneTask),
      TalkAnt:excludeTask(lineTwoTask),
      TalkAnt:excludeTask(lineThreeTask),
    },
    progress = {
      [0] = {
        TalkSession:speak('你好。我想借宿一宿，不知方不方便？'),
        TalkSession:reply('真不巧，我家的床塌了。'),
        TalkSession:speak('这样啊，那打扰了。'),
      },
    },
  }),
  TalkInfo:new({
    id = 2,
    ants = {
      TalkAnt:includeTask(lineOneTask),
    },
    progress = {
      [0] = {
        TalkSession:reply('我家的床可能短时间内修不好了。'),
      },
      [4] = {
        TalkSession:reply('甄道很认死理的，他决定的事情从来就没有改变过。'),
        TalkSession:think('看来不好办啊……'),
      },
    },
  }),
}

-- 贾义
jiayiTalkInfos = {
  TalkInfo:new({
    id = 1,
    ants = {
      TalkAnt:excludeTask(lineOneTask),
      TalkAnt:excludeTask(lineTwoTask),
      TalkAnt:excludeTask(lineThreeTask),
    },
    progress = {
      [0] = {
        TalkSession:speak('你好。我想借宿一宿，不知方不方便？'),
        TalkSession:reply('真不巧，我家的床烂了。'),
        TalkSession:speak('这样啊，那打扰了。'),
      },
    },
  }),
  TalkInfo:new({
    id = 2,
    ants = {
      TalkAnt:includeTask(lineOneTask),
    },
    progress = {
      [0] = {
        TalkSession:reply('我家的床可能短时间内修不好了。'),
      },
      [4] = {
        TalkSession:reply('我们村的人，就属甄道最固执了。'),
      },
    },
  }),
}

-- 林隐
linyinTalkInfos = {
  TalkInfo:new({
    id = 1,
    ants = {
      TalkAnt:excludeTask(lineOneTask),
      TalkAnt:excludeTask(lineTwoTask),
      TalkAnt:excludeTask(lineThreeTask),
    },
    progress = {
      [0] = {
        TalkSession:reply('你好，外地人。'),
        TalkSession:speak('你好。'),
        TalkSession:reply('我是村里的村长，你有事吗？'),
        -- TalkSession:think('要不要借宿一宿呢？'),
        -- TalkSession:choose({
        --   PlayerTalk:continue('要'):call(function (player)
        --     TaskHelper:addTask(player.objid, 4)
        --     player:resetTalkIndex(0)
        --   end),
        --   PlayerTalk:continue('不要'),
        -- }),
        TalkSession:speak('我不小心走错门了，抱歉。'),
      }
    }
  }),
  TalkInfo:new({
    id = 2,
    ants = {
      TalkAnt:includeTask(lineOneTask),
    },
    progress = {
      [0] = {
        TalkSession:reply('你好，有事吗？'),
        TalkSession:speak('没。'),
      },
      [4] = {
        TalkSession:reply('你好，外地人。'),
        TalkSession:speak('你好。'),
        TalkSession:reply('我是这村的村长。你遇到什么麻烦了吗？'),
        TalkSession:think('是村长。或许我可以问问他。'),
        TalkSession:speak('村长你好。途径贵地，发现你们村子上空弥漫着一股邪气。'),
        TalkSession:reply('此事当真？'),
        TalkSession:think('……我应该不会看错吧？'),
        TalkSession:speak('千真万确。我需要道具来驱散它。'),
        TalkSession:speak('听闻甄村友有一把桃木剑，我想借来一用。'),
        TalkSession:reply('哦……那似乎是他家祖传的，恐怕借来不易。'),
        TalkSession:speak('不错。'),
        TalkSession:reply('不知邪气可有危害？'),
        TalkSession:speak('我观邪气似乎存在已久，不过不知何故，现在依然还未成气候。'),
        TalkSession:speak('不过终究是一隐患。而若邪气成型，后果恐难以预料。'),
        TalkSession:reply('嗯……我村里人每家都有一个物品柜，重要东西放在其内，外有铁门锁着。'),
        TalkSession:reply('钥匙在每人手中，他若不愿借剑给你，那也没有办法。'),
        TalkSession:think('？？？'),
        TalkSession:speak('这样啊……'),
        TalkSession:reply('希望你能找到别的办法。'),
        TalkSession:speak('嗯，我不会放弃的。'):call(function (player)
          TalkHelper:setProgress(player.objid, 2, 5)
        end),
      },
      [5] = {
        TalkSession:reply('希望你能找到别的办法。'),
        TalkSession:speak('嗯，我不会放弃的。'),
      },
    },
  }),
}