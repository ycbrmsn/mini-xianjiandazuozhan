-- 我的任务类
BasePumpkinTask = BaseTask:new({
  name = '采集方南瓜',
  desc = '从屋外树上采集一个方南瓜，交给',
  category = 2, -- 交付道具
  -- actorid = MyMap.ACTOR.YEXIAOLONG_ACTOR_ID, -- 交付NPC
  itemInfos = {
    { itemid = 230, num = 1 }, -- 方南瓜一个
  },
  rewards = {
    TaskReward:new({
      desc = '获得御仙剑一柄',
      category = 1,
      itemid = MyWeaponAttr.controlSword.levelIds[1],
      num = 1,
    }),
  },
})

function BasePumpkinTask:new (taskid, actorid, actorname)
  local desc = self.desc .. actorname .. '。'
  local o = {
    id = taskid,
    actorid = actorid,
    desc = desc,
  }
  setmetatable(o, self)
  self.__index = self
  return o
 end 

-- pumpkinTask1 = BasePumpkinTask:new(51, MyMap.ACTOR.YEXIAOLONG_ACTOR_ID, '叶小龙')
-- pumpkinTask2 = BasePumpkinTask:new(52, MyMap.ACTOR.YEDALONG_ACTOR_ID, '叶大龙')