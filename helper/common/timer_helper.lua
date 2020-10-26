-- 计时器工具类
TimerHelper = {
  timerPool = {} -- 计时器池 { timerid = { id = timerid, timername = timername, isOver = isOver } }
}

-- 如果timerid不存在就创建计时器
function TimerHelper:createTimerIfNotExist (timername, timerid)
  if (timerid) then
    if (not(self:isExist(timerid))) then -- 计时器不存在
      timerid = self:createTimer(timername)
    end
    return timerid
  else
    return self:createTimer(timername)
  end
end

-- 获得一个计时器id
function TimerHelper:getTimer (timername)
  timername = timername or 'default'
  local timerid
  -- 查找一个停止的计时器
  for k, v in pairs(self.timerPool) do
    if (v.isOver and v.timername == timername) then
      v.isOver = false -- 设置计时器开始工作标识isOver
      timerid = k
      break
    end
  end
  -- 没找到则创建一个计时器，并加入计时器池中
  if (not(timerid)) then
    timerid = TimerHelper:createTimer(timername)
    self.timerPool[timerid] = { timerid = timerid, timername = timername, isOver = false }
  end
  return timerid, self.timerPool[timerid]
end

-- 几秒后执行
function TimerHelper:doAfterSeconds (f, seconds, t)
  t = t or 'default'
  local timerid, timerInfo = TimerHelper:getTimer(t)
  timerInfo.f = f
  TimerHelper:startBackwardTimer(timerid, seconds)
  return timerid
end

-- 显示计时器窗口
function TimerHelper:showTips (objids, timerid, title)
  TimerHelper:showTimerTips(objids, timerid, title, true)
end

-- 隐藏计时器窗口
function TimerHelper:hideTips (objids, timerid)
  TimerHelper:showTimerTips(objids, timerid, nil, false)
end

-- 事件

-- 任意计时器发生变化
function TimerHelper:minitimerChange(timerid, timername)
  local time = TimerHelper:getTimerTime(timerid)
  if (time == 0) then
    local timerInfo = self.timerPool[timerid]
    if (timerInfo) then
      timerInfo.isOver = true
      if (timerInfo.f) then
        timerInfo.f()
        timerInfo.f = nil
      end
    end
  end
end

-- 封装原始接口

-- 判断计时器是否存在
function TimerHelper:isExist (timerid)
  return MiniTimer:isExist(timerid)
end

-- 创建计时器
function TimerHelper:createTimer (timername)
  return CommonHelper:callOneResultMethod(function (p)
    return MiniTimer:createTimer(timername)
  end, '创建计时器', 'timename=', timername)
end

-- 启动正向计时器
function TimerHelper:startForwardTimer (timerid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return MiniTimer:startForwardTimer(timerid)
  end, '启动正向计时器', 'timerid=', timerid)
end

-- 启动倒计时
function TimerHelper:startBackwardTimer (timerid, interval, repeated)
  return CommonHelper:callIsSuccessMethod(function (p)
    return MiniTimer:startBackwardTimer(timerid, interval, repeated)
  end, '启动倒计时', 'timerid=', timerid, ',interval=', interval, ',repeated=',
    repeated)
end

-- 获取计时器时间
function TimerHelper:getTimerTime (timerid)
  return CommonHelper:callOneResultMethod(function (p)
    return MiniTimer:getTimerTime(timerid)
  end, '获取计时器时间', 'timerid=', timerid)
end

-- 停止计时器
function TimerHelper:stopTimer (timerid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return MiniTimer:stopTimer(timerid)
  end, '停止计时器', 'timerid=', timerid)
end

-- 显示计时器窗口
function TimerHelper:showTimerTips (objids, timerid, title, isShow)
  return CommonHelper:callIsSuccessMethod(function (p)
    return MiniTimer:showTimerTips(objids, timerid, title, isShow)
  end, '显示计时器窗口', 'objids=', objids, ',timerid=', timerid, ',title=',
    title, ',isShow=', isShow)
end

-- 暂停计时器
function TimerHelper:pauseTimer (timerid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return MiniTimer:pauseTimer(timerid)
  end, '停止计时器', 'timerid=', timerid)
end

function TimerHelper:changeTimerTime (timerid, curtime)
  return CommonHelper:callIsSuccessMethod(function (p)
    return MiniTimer:changeTimerTime(timerid, curtime)
  end, '改变计时器计时', 'timerid=', timerid, ',curtime=', curtime)
end