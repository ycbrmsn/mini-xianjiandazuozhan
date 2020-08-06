-- 日志工具类
LogHelper = {
  level = 'debug' -- debug info error
}

function LogHelper:debug (...)
  if (self.level == 'debug') then
    local message = ''
    local num = select('#', ...)
    for i = 1, num do
      local arg = select(i, ...)
      message = message .. StringHelper:toString(arg)
    end
    ChatHelper:sendSystemMsg('debug: ' .. message)
    print('debug: ' .. message)
  end
end

function LogHelper:info (...)
  if (self.level == 'debug' or self.level == 'info') then
    local message = ''
    local num = select('#', ...)
    for i = 1, num do
      local arg = select(i, ...)
      message = message .. StringHelper:toString(arg)
    end
    ChatHelper:sendSystemMsg('info: ' .. message)
    print('info: ' .. message)
  end
end

function LogHelper:error (...)
  local message = ''
  local num = select('#', ...)
  for i = 1, num do
    local arg = select(i, ...)
    message = message .. StringHelper:toString(arg)
  end
  ChatHelper:sendSystemMsg('error: ' .. message)
  print('error: ' .. message)
end

function LogHelper:call (f, p)
  xpcall(f, function (err)
    self:error(err)
  end, p)
  -- f(p)
end
