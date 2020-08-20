-- 常量
MyConstant = {
  INIT_HOUR = 7, -- 初始时间
  FLY_SPEED = 0.0785, -- 飞行速度
  FLY_ADVANCE_SPEED = 0.05, -- 飞行前进速度
  PROJECTILE_HURT = 6, -- 通用投掷物固定伤害
  
  -- 人物ID
  LINQIANSHU_ACTOR_ID = 2, -- 林千树
  LINWANSHU_ACTOR_ID = 3, -- 林万树
  YEXIAOLONG_ACTOR_ID = 4, -- 叶小龙
  YEDALONG_ACTOR_ID = 5, -- 叶大龙

  -- 怪物ID
  OX_ACTOR_ID = 6, -- 狂浪之牛
  WOLF_ACTOR_ID = 7, -- 幽风之狼
  DOG_ACTOR_ID = 8, -- 贪玩狗
  CHICK_ACTOR_ID = 9, -- 无聊鸡
  -- boss

  -- 道具ID
  ITEM = {
    GAME_DATA_MAIN_INDEX_ID = 4112, -- 主线剧情序号
    GAME_DATA_MAIN_PROGRESS_ID = 4113, -- 主线剧情进度数据
    GAME_DATA_LEVEL_ID = 4114, -- 人物等级数据
    GAME_DATA_EXP_ID = 4115, -- 人物经验数据
    APPLE_ID = 4116, -- 苹果
    ENERGY_FRAGMENT_ID = 4117, -- 能量碎片
    GREEN_SOFT_STONE_ID = 4118, -- 绿色软石块
    BLUE_SOFT_STONE_ID = 4120 -- 蓝色软石块
  },
  BODY_EFFECT = {
    SMOG1 = 1226, -- 一团小烟雾随即消失

    BOOM1 = 1186, -- 黄色的小爆炸脚下一个圈

    LIGHT1 = 1005, -- 传送黄呼啦圈
    LIGHT3 = 1008, -- 一颗心加血特效
    LIGHT4 = 1023, -- 三格大小四散旋转的黄光
    LIGHT9 = 1150, -- 一堆心加血特效
    LIGHT10 = 1185, -- 两格大小的两个气旋不停旋转
    LIGHT19 = 1223, -- 一格大小的淡蓝色方框气流圈住流动
    LIGHT22 = 1227, -- 一圈紫色光幕围住并盘旋着锁链
    LIGHT24 = 1231, -- 黄色的无敌盾保护圈
    LIGHT26 = 1235, -- 红十字加血特效
    LIGHT30 = 1249, -- 传送旋涡慢慢消失关闭
    LIGHT47 = 1337, -- 接近一格大小的一团蓝色光雾周围一些小蓝点
    LIGHT62 = 1495, -- 一个三格大小的蓝色护罩
    LIGHT63 = 1497, -- 一个三格大小的红色护罩
    LIGHT64 = 1498, -- 一个三格大小的白色护罩

    PARTICLE24 = 1341 -- 两格大小的一个黄色小光源
  },
  SOUND_EFFECT = {
    ACTION4 = 10007, -- 放置/破坏方块的声音
    ACTION5 = 10010, -- 放置/破坏方块的声音
    SKILL9 = 10086 -- 一阵风的声音
  }
}

-- 模板
Template = {
  GAIN_EXP_MSG = '你获得{exp}点经验', -- exp（获得经验）
  GAIN_DEFEATED_EXP_MSG = '历经生死，你获得{exp}点经验', -- exp（获得经验）
  UPGRADE_MSG = '你升级了', -- exp（获得经验）、level（玩家等级）
  -- UNUPGRADE_MSG = '当前为{level}级。还差{needExp}点经验升级' -- level（玩家等级）、needExp（升级还需要的经验）
}

-- 武器属性
MyWeaponAttr = {
  -- 剑
  controlSword = { -- 御仙剑
    attack = 70,
    defense = 20,
    cd = 15,
    cdReason = '御仙剑失控，短时间内无法再次御剑飞行',
    skillname = '御剑飞行',
    addAttPerLevel = 30,
    addDefPerLevel = 20
  },
  tenThousandsSword = { -- 万仙剑
    attack = 90,
    defense = 0,
    cd = 15,
    cdReason = '万剑诀技能冷却中',
    skillname = '万剑诀',
    size = 1, -- 飞剑范围
    hurt = 30,
    addAttPerLevel = 40,
    addDefPerLevel = 10,
    addSizePerLevel = 1,
    addHurtPerLevel = 5
  },
  huixianSword = { -- 回仙剑
    attack = 80,
    defense = 10,
    cd = 15,
    cdReason = '回天剑诀技能冷却中',
    skillname = '回天剑诀',
    num = 4, -- 数量
    size = 5, -- 有效范围
    hurt = 40,
    addAttPerLevel = 20,
    addDefPerLevel = 30,
    addNumPerLevel = 1,
    addSizePerLevel = 1,
    addHurtPerLevel = 10
  },
  vitalqiSword = { -- 气仙剑
    attack = 60,
    defense = 30,
    cd = 15,
    cdReason = '气甲术技能冷却中',
    skillname = '气甲术',
    addAttPerLevel = 10,
    addDefPerLevel = 40
  }
}

-- 武器id
MyWeaponAttr.controlSword.levelIds = { 4105, -1, -11, -111 } -- 御仙剑
MyWeaponAttr.controlSword.projectileid = 4109 -- 飞行的御仙剑
MyWeaponAttr.tenThousandsSword.levelIds = { 4106, -2, -22, -222 } -- 万仙剑
MyWeaponAttr.tenThousandsSword.projectileid = 4110 -- 飞行的万仙剑
MyWeaponAttr.huixianSword.levelIds = { 4107, -3, -33, -333 } -- 回仙剑
MyWeaponAttr.huixianSword.projectileid = 4111 -- 飞行的回仙剑
MyWeaponAttr.vitalqiSword.levelIds = { 4108, -4, -44, -444 } -- 气仙剑
