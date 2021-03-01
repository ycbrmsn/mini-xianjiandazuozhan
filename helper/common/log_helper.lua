-- 日志工具类
LogHelper = {
  level = 'debug', -- debug info error no
  errorRecords = {}, -- 错误记录
  errorTimes = {} -- 该错误次数
}

function LogHelper.debug (...)
  if (LogHelper.level == 'debug') then
    local message = ''
    local num = select('#', ...)
    for i = 1, num do
      local arg = select(i, ...)
      message = message .. StringHelper.toString(arg)
    end
    ChatHelper.sendSystemMsg('debug: ' .. message)
    print('debug: ' .. message)
  end
end

function LogHelper.info (...)
  if (LogHelper.level == 'debug' or LogHelper.level == 'info') then
    local message = ''
    local num = select('#', ...)
    for i = 1, num do
      local arg = select(i, ...)
      message = message .. StringHelper.toString(arg)
    end
    ChatHelper.sendSystemMsg('info: ' .. message)
    print('info: ' .. message)
  end
end

function LogHelper.error (...)
  local message = ''
  local num = select('#', ...)
  for i = 1, num do
    local arg = select(i, ...)
    message = message .. StringHelper.toString(arg)
  end
  ChatHelper.sendSystemMsg('error: ' .. message)
  print('error: ' .. message)
end

function LogHelper.call (f, p)
  xpcall(f, function (err)
    if (LogHelper.level ~= 'no') then
      LogHelper.error(err)
    end
    local num = LogHelper.errorTimes[err]
    if (not(num)) then
      table.insert(LogHelper.errorRecords, err)
      LogHelper.errorTimes[err] = 1
    else
      LogHelper.errorTimes[err] = LogHelper.errorTimes[err] + 1
    end
  end, p)
  -- f(p)
end

-- 显示错误信息
function LogHelper.showErrorRecords (objid)
  if (#LogHelper.errorRecords == 0) then
    ChatHelper.sendMsg(objid, '太棒了，当前没有错误')
  else
    ChatHelper.sendMsg(objid, '警告，当前有', #LogHelper.errorRecords, '条错误信息，下面开始显示：')
    local t = objid .. 'listErrorRecords'
    TimeHelper.delFnFastRuns(t)
    TimeHelper.callFnFastRuns(function ()
      LogHelper.listErrorRecords(objid)
    end, 1, t)
  end
end

-- 列出错误信息
function LogHelper.listErrorRecords (objid, index)
  index = index or 1
  if (index <= #LogHelper.errorRecords
    and ChatHelper.sendMsg(objid, LogHelper.errorRecords[index])) then
    index = index + 1
    TimeHelper.callFnFastRuns(function ()
      LogHelper.listErrorRecords(objid, index)
    end, 1, objid .. 'listErrorRecords')
  end
end

-- 停止显示错误信息
function LogHelper.stopErrorRecords (objid)
  if (TimeHelper.delFnFastRuns(objid .. 'listErrorRecords')) then
    ChatHelper.sendMsg(objid, '错误信息已停止显示')
  else
    ChatHelper.sendMsg(objid, '当前未显示错误信息')
  end
end