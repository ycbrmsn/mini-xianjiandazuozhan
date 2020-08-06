-- 我的怪物工具类
MyMonsterHelper = {}

-- 初始化
function MyMonsterHelper:init ()
  wolf = Wolf:new()
  ox = Ox:new()
  local monsterModels = { wolf, ox }
  MonsterHelper:init(monsterModels)
end