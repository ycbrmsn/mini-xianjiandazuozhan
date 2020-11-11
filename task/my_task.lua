-- 我的任务类

-- 御仙剑任务
YuTask = BaseTask:new({
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

function YuTask:new (taskid, actorid, actorname)
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

-- 万仙剑任务
WanTask = BaseTask:new({
  name = '采集竹子',
  desc = '从屋顶上采集一节竹子，交给',
  category = 2, -- 交付道具
  -- actorid = MyMap.ACTOR.YEXIAOLONG_ACTOR_ID, -- 交付NPC
  itemInfos = {
    { itemid = 251, num = 1 }, -- 竹子一节
  },
  rewards = {
    TaskReward:new({
      desc = '获得万仙剑一柄',
      category = 1,
      itemid = MyWeaponAttr.tenThousandsSword.levelIds[1],
      num = 1,
    }),
  },
})

function WanTask:new (taskid, actorid, actorname)
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