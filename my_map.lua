-- 地图相关数据
MyMap = {
  BLOCK = {
    
  },
  ITEM = {
    GAME_DATA_MAIN_INDEX_ID = 4112, -- 主线剧情序号
    GAME_DATA_MAIN_PROGRESS_ID = 4113, -- 主线剧情进度数据
    GAME_DATA_LEVEL_ID = 4114, -- 人物等级数据
    GAME_DATA_EXP_ID = 4115, -- 人物经验数据
    APPLE_ID = 4116, -- 苹果
    ENERGY_FRAGMENT_ID = 4117, -- 能量碎片
    GREEN_SOFT_STONE_ID = 4118, -- 绿色软石块
    BLUE_SOFT_STONE_ID = 4120, -- 蓝色软石块
    MUSIC_PLAYER_ID = 4121, -- 音乐播放器
    PURPLE_SOFT_STONE_ID = 4122, -- 紫色软石块
    ANIMAL_BONE_ID = 4123, -- 兽骨
    TIME_TURNTABLE_ID = 4125, -- 时间轮盘
  },
  ACTOR = {
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
  },
  BUFF = {
    FLY_STYLE = 50000001, -- 飞行模式
  },
  CUSTOM = {
    INIT_HOUR = 7, -- 初始时间
    FLY_SPEED = 0.0785, -- 飞行速度
    PROJECTILE_HURT = 6, -- 通用投掷物固定伤害
  }
}

-- 模板
MyTemplate = {
  GAIN_EXP_MSG = '你获得{exp}点经验', -- exp（获得经验）
  GAIN_DEFEATED_EXP_MSG = '历经生死，你获得{exp}点经验', -- exp（获得经验）
  UPGRADE_MSG = '你升级了', -- level（玩家等级）
  -- UNUPGRADE_MSG = '当前为{level}级。还差{needExp}点经验升级' -- level（玩家等级）、needExp（升级还需要的经验）
  TEAM_MSG = '当前红队有{1}人，蓝队有{2}人，准备玩家有{0}人', -- 0（无队伍人数）、1（红队人数）、2（蓝队人数）
}

-- 武器属性
MyWeaponAttr = {
  -- 剑
  controlSword = { -- 御仙剑
    meleeAttack = 70,
    meleeDefense = 20,
    remoteDefense = 20,
    cd = 15,
    cdReason = '御仙剑失控，短时间内无法再次御剑飞行',
    skillname = '御剑飞行',
    addAttPerLevel = 30,
    addDefPerLevel = 20
  },
  tenThousandsSword = { -- 万仙剑
    meleeAttack = 90,
    meleeDefense = 0,
    remoteDefense = 0,
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
    meleeAttack = 80,
    meleeDefense = 10,
    remoteDefense = 10,
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
    meleeAttack = 60,
    meleeDefense = 30,
    remoteDefense = 30,
    cd = 15,
    cdReason = '气甲术技能冷却中',
    skillname = '气甲术',
    addAttPerLevel = 10,
    addDefPerLevel = 40
  },
  luanSword = { -- 乱仙剑
    meleeAttack = 88,
    meleeDefense = 2,
    remoteDefense = 2,
    cd = 15,
    cdReason = '乱剑诀技能冷却中',
    skillname = '乱剑诀',
    num = 12, -- 飞剑数量
    hurt = 30,
    addAttPerLevel = 40,
    addDefPerLevel = 10,
    addNumPerLevel = 5,
    addHurtPerLevel = 5
  },
}

-- 武器id
MyWeaponAttr.controlSword.levelIds = { 4105, -1, -11, -111 } -- 御仙剑
MyWeaponAttr.controlSword.projectileid = 4109 -- 飞行的御仙剑
MyWeaponAttr.tenThousandsSword.levelIds = { 4106, -2, -22, -222 } -- 万仙剑
MyWeaponAttr.tenThousandsSword.projectileid = 4110 -- 飞行的万仙剑
MyWeaponAttr.huixianSword.levelIds = { 4107, -3, -33, -333 } -- 回仙剑
MyWeaponAttr.huixianSword.projectileid = 4111 -- 飞行的回仙剑
MyWeaponAttr.vitalqiSword.levelIds = { 4108, -4, -44, -444 } -- 气仙剑
MyWeaponAttr.luanSword.levelIds = { 4128, -6, -66, -666 } -- 乱仙剑
MyWeaponAttr.luanSword.projectileid = 4129 -- 飞行的乱仙剑
