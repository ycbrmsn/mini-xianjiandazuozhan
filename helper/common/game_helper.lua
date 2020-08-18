-- 游戏工具类
GameHelper = {}

-- 事件

-- 开始游戏
function GameHelper:startGame ()
  -- body
end

-- 游戏运行时
function GameHelper:runGame ()
  TimeHelper:addFrame()
  TimeHelper:runFnFastRuns()
  TimeHelper:runFnContinueRuns()
  MonsterHelper:runBosses()
end

-- 结束游戏
function GameHelper:endGame ()
  -- body
end

-- 世界时间到[n]点
function GameHelper:atHour (hour)
  TimeHelper:updateHour(hour)
  ActorHelper:atHour(hour)
  StoryHelper:atHour(hour)
end

-- 世界时间到[n]秒
function GameHelper:atSecond (second)
  TimeHelper:doPerSecond(second)
  PlayerHelper:updateEveryPlayerPositions()
  ActorHelper:runActors()
  PlayerHelper:runPlayers()
end

-- 任意计时器发生变化
function GameHelper:minitimerChange(timerid, timername)
  TimerHelper:minitimerChange(timerid, timername)
end