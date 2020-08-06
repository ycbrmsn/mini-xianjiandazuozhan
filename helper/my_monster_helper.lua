-- 我的怪物工具类
MyMonsterHelper = {}

-- 初始化
function MyMonsterHelper:init ()
  chick = Chick:new()
  dog = Dog:new()
  wolf = Wolf:new()
  ox = Ox:new()
  local monsterModels = { chick, dog, wolf, ox }
  MonsterHelper:init(monsterModels)
end