-- 游戏事件

-- eventobjid, toobjid
local playerEnterGame = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerEnterGame(event.eventobjid)
    -- PlayerHelper:getHostPlayer().action:runTo({ { x = 0, y = 7, z = 70 } })
  end)
end

-- eventobjid, toobjid
local playerLeaveGame = function (event)
  LogHelper:call(function ()
    MyPlayerHelper:playerLeaveGame(event.eventobjid)
  end)
end

-- 无参数
local startGame = function ()
  -- LogHelper:debug('开始游戏')
  LogHelper:call(function ()
    MyGameHelper:startGame()
  end)
end

-- 无参数
local runGame = function ()
  LogHelper:call(function ()
    MyGameHelper:runGame()
  end)
end

-- 无参数
local endGame = function ()
  LogHelper:call(function ()
    MyGameHelper:endGame()
  end)
end

-- hour
local atHour = function (event)
  local hour = event['hour']
  LogHelper:call(function ()
    MyGameHelper:atHour(hour)
  end)
end

-- second
local atSecond = function (event)
  local second = event['second']
  LogHelper:call(function ()
    MyGameHelper:atSecond(second)
  end)
end

-- timerid, timername
local minitimerChange = function (event)
  LogHelper:call(function ()
    MyGameHelper:minitimerChange(event.timerid, event.timername)
  end)
end

ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=], playerEnterGame) -- 玩家进入游戏
ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.LeaveGame]=], playerLeaveGame) -- 玩家离开游戏
ScriptSupportEvent:registerEvent([=[Game.Start]=], startGame) -- 开始游戏
ScriptSupportEvent:registerEvent([=[Game.End]=], endGame) -- 结束游戏
ScriptSupportEvent:registerEvent([=[Game.Hour]=], atHour) -- 世界时间到[n]点
ScriptSupportEvent:registerEvent([=[Game.Run]=], runGame) -- 游戏运行时
ScriptSupportEvent:registerEvent([=[Game.RunTime]=], atSecond) -- 世界时间到[n]秒
ScriptSupportEvent:registerEvent([=[minitimer.change]=], minitimerChange) -- 任意计时器发生变化
