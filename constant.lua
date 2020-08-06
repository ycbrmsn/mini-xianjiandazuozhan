-- 常量
MyConstant = {
  INIT_HOUR = 7, -- 初始时间
  FLY_SPEED = 0.0785, -- 飞行速度
  FLY_ADVANCE_SPEED = 0.05, -- 飞行前进速度
  PROJECTILE_HURT = 6, -- 通用投掷物固定伤害
  
  -- 人物ID

  -- 怪物ID

  -- boss

  -- 道具ID
  ITEM = {
    GAME_DATA_MAIN_INDEX_ID = 4112, -- 主线剧情序号
    GAME_DATA_MAIN_PROGRESS_ID = 4113, -- 主线剧情进度数据
    GAME_DATA_LEVEL_ID = 4114, -- 人物等级数据
    GAME_DATA_EXP_ID = 4115 -- 人物经验数据
  },
  BODY_EFFECT = {
    SMOG1 = 1226, -- 一团小烟雾随即消失

    BOOM1 = 1186, -- 黄色的小爆炸脚下一个圈

    LIGHT3 = 1008, -- 一颗心加血特效
    LIGHT4 = 1023, -- 三格大小四散旋转的黄光
    LIGHT9 = 1150, -- 一堆心加血特效
    LIGHT10 = 1185, -- 两格大小的两个气旋不停旋转
    LIGHT19 = 1223, -- 一格大小的淡蓝色方框气流圈住流动
    LIGHT22 = 1227, -- 一圈紫色光幕围住并盘旋着锁链
    LIGHT24 = 1231, -- 黄色的无敌盾保护圈
    LIGHT26 = 1235, -- 红十字加血特效
    LIGHT47 = 1337, -- 接近一格大小的一团蓝色光雾周围一些小蓝点
    LIGHT62 = 1495, -- 一个三格大小的蓝色护罩
    LIGHT63 = 1497, -- 一个三格大小的红色护罩
    LIGHT64 = 1498, -- 一个三格大小的白色护罩

    PARTICLE24 = 1341 -- 两格大小的一个黄色小光源
  },
  SOUND_EFFECT = {
    SKILL9 = 10086 -- 一阵风的声音
  }
}

-- 模板
Template = {
  GAIN_EXP_MSG = '你获得{exp}点经验', -- exp（获得经验）
  GAIN_DEFEATED_EXP_MSG = '历经生死，你获得{exp}点经验', -- exp（获得经验）
  UPGRADE_MSG = '你升级了。当前为{totalLevel}级', -- totalLevel（玩家等级）
  UNUPGRADE_MSG = '当前为{totalLevel}级。还差{needExp}点经验升级' -- totalLevel（玩家等级）、needExp（升级还需要的经验）
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
    hurt = 8,
    addAttPerLevel = 40,
    addDefPerLevel = 10,
    addHurtPerLevel = 2
  },
  huixianSword = { -- 回仙剑
    attack = 80,
    defense = 10,
    cd = 15,
    cdReason = '回天剑诀技能冷却中',
    skillname = '回天剑诀',
    hurt = 20,
    addAttPerLevel = 20,
    addDefPerLevel = 30,
    addHurtPerLevel = 5
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
MyWeaponAttr.controlSword.levelIds = { 4105 } -- 御仙剑
MyWeaponAttr.controlSword.projectileid = 4109 -- 飞行的御仙剑
MyWeaponAttr.tenThousandsSword.levelIds = { 4106 } -- 万仙剑
MyWeaponAttr.tenThousandsSword.projectileid = 4110 -- 飞行的万仙剑
MyWeaponAttr.huixianSword.levelIds = { 4107 } -- 回仙剑
MyWeaponAttr.huixianSword.projectileid = 4111 -- 飞行的回仙剑
MyWeaponAttr.vitalqiSword.levelIds = { 4108 } -- 气仙剑