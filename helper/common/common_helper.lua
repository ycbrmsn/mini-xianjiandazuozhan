-- 公共工具类
CommonHelper = {
  repeatTime = 1 -- 失败重复调用次数
}

-- 参数 f:函数 p:参数 onceFailMessage:一次失败信息 finillyFailMessage:最终失败信息
function CommonHelper:callIsSuccessMethod (f, p, onceFailMessage, finillyFailMessage)
  for i = 1, self.repeatTime do
    local result = f(p)
    if (result == ErrorCode.OK) then
      return true
    else
      if (onceFailMessage) then
        -- LogHelper:debug(onceFailMessage)
      end
    end
  end
  if (finillyFailMessage) then
    LogHelper:debug(finillyFailMessage)
  end
  return false
end

function CommonHelper:callOneResultMethod (f, p, onceFailMessage, finillyFailMessage)
  for i = 1, self.repeatTime do
    local result, r1 = f(p)
    if (result == ErrorCode.OK) then
      return r1
    else
      if (onceFailMessage) then
        -- LogHelper:debug(onceFailMessage)
      end
    end
  end
  if (finillyFailMessage) then
    LogHelper:debug(finillyFailMessage)
  end
  return nil
end

function CommonHelper:callTwoResultMethod (f, p, onceFailMessage, finillyFailMessage)
  for i = 1, self.repeatTime do
    local result, r1, r2 = f(p)
    if (result == ErrorCode.OK) then
      return r1, r2
    else
      if (onceFailMessage) then
        -- LogHelper:debug(onceFailMessage)
      end
    end
  end
  if (finillyFailMessage) then
    LogHelper:debug(finillyFailMessage)
  end
  return nil
end

function CommonHelper:callThreeResultMethod (f, p, onceFailMessage, finillyFailMessage)
  for i = 1, self.repeatTime do
    local result, r1, r2, r3 = f(p)
    if (result == ErrorCode.OK) then
      return r1, r2, r3
    else
      if (onceFailMessage) then
        -- LogHelper:debug(onceFailMessage)
      end
    end
  end
  if (finillyFailMessage) then
    LogHelper:debug(finillyFailMessage)
  end
  return nil
end
