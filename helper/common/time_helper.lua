-- 时间工具类
TimeHelper = {
  hour = nil,
  globalIndex = 0, -- 一个全局计数
  time = 0,
  frame = 0, -- 帧
  frameInfo = {}, -- 帧对应信息
  fns = {}, -- second -> { { f, p }, { f, p }, ... }
  fnIntervals = {}, -- second -> { objid = { t = { f, p }, t = { f, p } }, objid = { t = { f, p }, t = { f, p } }, ... }
  fnCanRuns = {}, -- second -> { objid = { t, t }, objid = { t, t } ... }
  fnLastRuns = {}, -- second -> { objid = { t = { f, p }, t = { f, p } }, objid = { t = { f, p }, t = { f, p } }, ... }
  fnFastRuns = {}, -- { { second, f, t } }
  fnContinueRuns = {} -- { t = { second, f, p }, t = { second, f, p }, ... }
}

function TimeHelper.updateHour (hour)
  TimeHelper.hour = hour
end

-- 更新时间
function TimeHelper.updateTime (second)
  TimeHelper.time = second
end

-- 获取globalIndex，并且globalIndex自增1
function TimeHelper.getGlobalIndex ()
  local globalIndex = TimeHelper.globalIndex
  TimeHelper.globalIndex = TimeHelper.globalIndex + 1
  return globalIndex
end

function TimeHelper.addFrame ()
  if (TimeHelper.frameInfo[TimeHelper.frame]) then
    TimeHelper.frameInfo[TimeHelper.frame] = nil
  end
  TimeHelper.frame = TimeHelper.frame + 1
end

function TimeHelper.addHour (hour)
  hour = hour + TimeHelper.getHour()
  if (hour >= 24) then
    hour = hour - 24
  end
  TimeHelper.setHour(hour)
end

function TimeHelper.setHour (hour)
  if (WorldHelper.setHours(hour)) then
    TimeHelper.hour = hour
    return true
  end
  return false
end

function TimeHelper.getHour ()
  if (not(TimeHelper.hour)) then
    TimeHelper.hour = WorldHelper.getHours()
  end
  return TimeHelper.hour
end

function TimeHelper.getTime ()
  return TimeHelper.time
end

function TimeHelper.getFrameInfo (key)
  if (not(TimeHelper.frameInfo[TimeHelper.frame])) then
    return nil
  end
  return TimeHelper.frameInfo[TimeHelper.frame][key]
end

function TimeHelper.setFrameInfo (key, val)
  if (not(TimeHelper.frameInfo[TimeHelper.frame])) then
    TimeHelper.frameInfo[TimeHelper.frame] = {}
  end
  TimeHelper.frameInfo[TimeHelper.frame][key] = val
end

-- 添加方法
function TimeHelper.addFn (f, time, p)
  local fs = TimeHelper.fns[time]
  if (not(fs)) then
    fs = {}
    TimeHelper.fns[time] = fs
  end
  table.insert(fs, { f, p })
  return #fs
end

-- 删除方法
function TimeHelper.delFn (time, index)
  if (not(index)) then
    TimeHelper.fns[time] = nil
  else
    if (TimeHelper.fns[time]) then
      TimeHelper.fns[time][index] = nil
    end
  end
end

-- 运行方法，然后删除
function TimeHelper.runFnAfterSecond (time)
  local fs = TimeHelper.fns[time]
  if (fs) then
    for i, v in ipairs(fs) do
      if (v) then
        LogHelper.call(function ()
          v[1](v[2])
        end)
      end
    end
    TimeHelper.delFn(time)
  end
end

-- 参数为：函数、秒、函数的参数table。大致几秒后执行方法
function TimeHelper.callFnAfterSecond (f, second, p)
  if (type(f) ~= 'function') then
    return
  end
  second = second or 1
  local time = TimeHelper.time + second
  local index = TimeHelper.addFn(f, time, p)
  return time, index
end

function TimeHelper.runFnInterval (time)
  local fs = TimeHelper.fnIntervals[time]
  -- LogHelper.info('before run: ', time)
  if (fs) then
    -- LogHelper.info('run: ', time)
    for oid, ts in pairs(fs) do
      for k, v in pairs(ts) do
        LogHelper.call(function ()
          v[1](v[2])
        end)
      end
    end
  end
  -- 清除较长时间间隔的数据
  local longIntervalTime = time - 20
  if (TimeHelper.fnIntervals[longIntervalTime]) then
    TimeHelper.fnIntervals[longIntervalTime] = nil
  end
end

-- 获取最近的间隔时间，如果间隔内找不到，则返回nil
function TimeHelper.getLastFnIntervalTime (objid, t, second)
  for i = TimeHelper.time, TimeHelper.time - second + 1, -1 do
    local fnIs = TimeHelper.fnIntervals[i]
    if (fnIs) then
      local ts = fnIs[objid]
      if (ts and ts[t]) then
        return i
      end
    end
  end
  return nil
end

-- 记录或删除记录
function TimeHelper.setFnInterval (objid, t, f, time, p)
  local o = TimeHelper.fnIntervals[time]
  if (not(o)) then
    o = {}
    TimeHelper.fnIntervals[time] = o
  end
  if (not(o[objid])) then
    o[objid] = {}
  end
  if (f) then
    o[objid][t] = { f, p }
    -- LogHelper.info('记录：', time)
  else
    o[objid][t] = nil
    -- LogHelper.info('删除：', time)
  end
end

-- 至少间隔多少秒执行一次，如果当前符合条件，则立即执行；不符合，则记录下来，时间到了（间隔上次执行多少秒后）执行
function TimeHelper.callFnInterval (objid, t, f, second, p)
  if (not(objid)) then
    return
  end
  if (type(f) ~= 'function') then
    return
  end
  t = t or 'default'
  second = second or 1
  p = p or {}
  p.objid = objid
  local time, result
  local lastTime = TimeHelper.getLastFnIntervalTime(objid, t, second)
  if (lastTime) then
    time = lastTime + second
  else
    time = TimeHelper.time
    result = f(p)
  end
  TimeHelper.setFnInterval(objid, t, f, time, p)
  return result
end

-- 查询最近间隔内的执行时间，如果没找到，则返回nil
function TimeHelper.getLastFnCanRunTime (objid, t, second)
  for i = TimeHelper.time, TimeHelper.time - second + 1, -1 do
    local fns = TimeHelper.fnCanRuns[i]
    if (fns) then -- 有生物执行过
      local arr = fns[objid]
      if (arr) then -- 对应生物执行过
        for i, v in ipairs(arr) do
          if (v == t) then -- 执行类型相同
            return i
          end
        end
      end
    end
  end
  return nil
end

function TimeHelper.addLastFnCanRunTime (objid, t)
  if (not(TimeHelper.fnCanRuns[TimeHelper.time])) then
    TimeHelper.fnCanRuns[TimeHelper.time] = {}
    TimeHelper.fnCanRuns[TimeHelper.time][objid] = { t }
  elseif (not(TimeHelper.fnCanRuns[TimeHelper.time][objid])) then
    TimeHelper.fnCanRuns[TimeHelper.time][objid] = { t }
  else
    table.insert(TimeHelper.fnCanRuns[TimeHelper.time][objid], t)
  end
end

-- 如果方法能执行（间隔上次执行多少秒之后）则标记，然后执行；否则（间隔时间不够）不执行
function TimeHelper.callFnCanRun (objid, t, f, second, p)
  if (not(objid)) then
    return
  end
  if (type(f) ~= 'function') then
    return
  end
  t = t or 'default'
  second = second or 0
  local lastTime = TimeHelper.getLastFnCanRunTime(objid, t, second)
  if (not(lastTime)) then -- 没找到则标记，然后执行
    TimeHelper.addLastFnCanRunTime(objid, t)
    f(p)
  end
end

function TimeHelper.callIntervalUntilSuccess ()
  return function (param)
    TimeHelper.setFnInterval(param.objid, param.t, nil, TimeHelper.time) -- 删除记录
    local result = TimeHelper.callFnInterval(param.objid, param.t, param.f, param.second, param.p)
    if (type(result) == 'nil') then -- 说明近期执行过，本次未执行，还会再次执行
      -- LogHelper.info(param.objid, ': nil')
    elseif (result) then -- 说明本次执行达到目的
      -- LogHelper.info('true')
    else -- 说明本次执行未达到目的，则准备再次执行
      TimeHelper.setFnInterval(param.objid, param.t, TimeHelper.callIntervalUntilSuccess(),
        TimeHelper.time + param.second, param)
      -- LogHelper.info(param.objid, ': false')
    end
  end
end

-- 定时重复执行直到f返回true
function TimeHelper.repeatUtilSuccess (objid, t, f, second, p)
  TimeHelper.callIntervalUntilSuccess()({ objid = objid, t = t, f = f, second = second, p = p })
end

-- 每两秒初始化一次（绕开有十分之一的概率会产生的世界时间第一秒时不会回调的问题）
function TimeHelper.initActor (myActor)
  TimeHelper.repeatUtilSuccess(myActor.objid, 'initActor', function (myActor)
    return myActor:init()
  end, 2, myActor)
end

function TimeHelper.runFnLastRuns (time)
  local fs = TimeHelper.fnLastRuns[time]
  if (fs) then
    for oid, ts in pairs(fs) do
      for k, v in pairs(ts) do
        LogHelper.call(function ()
          v[1](v[2])
        end)
      end
    end
  end
  -- 清除较长时间间隔的数据
  local longIntervalTime = time - 20
  if (TimeHelper.fnLastRuns[longIntervalTime]) then
    TimeHelper.fnLastRuns[longIntervalTime] = nil
  end
end

-- 删除最后执行时间之前的相同类型的数据
function TimeHelper.delLastFnLastRunTime (objid, t, second)
  for i = TimeHelper.time + second - 1, TimeHelper.time, -1 do
    local fnIs = TimeHelper.fnLastRuns[i]
    if (fnIs) then
      local ts = fnIs[objid]
      if (ts and ts[t]) then
        ts[t] = nil
      end
    end
  end
end

function TimeHelper.setFnLastRun (objid, t, f, time, p)
  local o = TimeHelper.fnLastRuns[time]
  if (not(o)) then
    o = {}
    TimeHelper.fnLastRuns[time] = o
  end
  if (not(o[objid])) then
    o[objid] = {}
  end
  if (f) then
    o[objid][t] = { f, p }
  else
    o[objid][t] = nil
  end
end

-- 多少秒之后（时间点）执行一次，记录下来，时间点到了执行。记录时如果该时间点之前有该类型数据，则删除
function TimeHelper.callFnLastRun (objid, t, f, second, p)
  if (not(objid)) then
    return
  end
  if (type(f) ~= 'function') then
    return
  end
  t = t or 'default'
  second = second or 1
  p = p or {}
  p.objid = objid
  TimeHelper.delLastFnLastRunTime(objid, t, second)
  TimeHelper.setFnLastRun(objid, t, f, TimeHelper.time + second, p)
end

-- 添加方法
function TimeHelper.addFnFastRuns (f, second, t)
  table.insert(TimeHelper.fnFastRuns, { second * 1000, f, t })
end

-- 删除方法
function TimeHelper.delFnFastRuns (t)
  local isDel = false
  for i = #TimeHelper.fnFastRuns, 1, -1 do
    if (TimeHelper.fnFastRuns[i] and TimeHelper.fnFastRuns[i][3] and TimeHelper.fnFastRuns[i][3] == t) then
      -- table.remove(TimeHelper.fnFastRuns, i)
      TimeHelper.fnFastRuns[i] = false
      isDel = true
    end
  end
  return isDel
end

-- 运行方法，然后删除
function TimeHelper.runFnFastRuns ()
  for i = #TimeHelper.fnFastRuns, 1, -1 do
    if (TimeHelper.fnFastRuns[i]) then -- 没有被删除
      TimeHelper.fnFastRuns[i][1] = TimeHelper.fnFastRuns[i][1] - 50
      if (TimeHelper.fnFastRuns[i][1] <= 0) then
        LogHelper.call(function ()
          TimeHelper.fnFastRuns[i][2]()
        end)
        table.remove(TimeHelper.fnFastRuns, i)
      end
    else
      table.remove(TimeHelper.fnFastRuns, i)
    end
  end
end

-- 参数为：函数、秒、类型。精确几秒后执行方法，精确到0.05秒
function TimeHelper.callFnFastRuns (f, second, t)
  if (type(f) ~= 'function') then
    return
  end
  second = second or 1
  t = t or TimeHelper.getGlobalIndex()
  TimeHelper.addFnFastRuns(f, second, t)
  return t
end

-- 添加方法
function TimeHelper.addFnContinueRuns (f, second, t, p)
  TimeHelper.fnContinueRuns[t] = { second * 1000, f, p }
end

-- 删除方法
function TimeHelper.delFnContinueRuns (t)
  if (TimeHelper.fnContinueRuns[t]) then
    TimeHelper.fnContinueRuns[t] = nil
    return true
  else
    return false
  end
end

-- 是否持续执行
function TimeHelper.isFnContinueRuns (t)
  return type(TimeHelper.fnContinueRuns[t]) ~= 'nil'
end

-- 运行方法，然后删除
function TimeHelper.runFnContinueRuns ()
  for k, v in pairs(TimeHelper.fnContinueRuns) do
    LogHelper.call(function ()
      v[2](v[3])
    end)
    if (v[1] ~= -1000) then -- 永久执行
      v[1] = v[1] - 50
      if (v[1] <= 0) then
        TimeHelper.delFnContinueRuns(k)
      end
    end
  end
end

-- 参数为：函数、秒、函数的参数table。持续执行方法，精确到0.05秒
function TimeHelper.callFnContinueRuns (f, second, t, p)
  if (type(f) ~= 'function') then
    return
  end
  second = second or 1
  t = t or TimeHelper.getGlobalIndex()
  TimeHelper.addFnContinueRuns(f, second, t, p)
  return t
end

function TimeHelper.doPerSecond (second)
  TimeHelper.updateTime(second)
  TimeHelper.runFnAfterSecond(second)
  TimeHelper.runFnInterval(second)
  TimeHelper.runFnLastRuns(second)
end