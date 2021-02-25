-- 公共工具类
CommonHelper = {
  repeatTime = 1 -- 失败重复调用次数
}

do
  if not table.unpack then
    table.unpack = unpack
  end
end

-- 参数 f:函数 p:参数 methodDesc:接口描述 ... 参数名=参数值
function CommonHelper:callIsSuccessMethod (f, methodDesc, ...)
  for i = 1, self.repeatTime do
    local result = f()
    if (result == ErrorCode.OK) then
      return true
    else
      -- if (methodDesc) then
      --   LogHelper:debug(methodDesc, '失败一次')
      -- end
    end
  end
  if (LogHelper.level == 'debug' and methodDesc) then
    local msg = StringHelper:concat(...)
    if (#msg > 0) then
      msg = '，参数：' .. msg
    end
    LogHelper:debug(methodDesc, '失败', msg)
  end
  return false
end

function CommonHelper:callResultMethod (f, methodDesc, ...)
  for i = 1, self.repeatTime do
    local arr = {f(p)}
    if (arr[1] == ErrorCode.OK) then
      return table.unpack(arr, 2)
    else
      -- if (methodDesc) then
      --   LogHelper:debug(methodDesc, '失败一次')
      -- end
    end
  end
  if (LogHelper.level == 'debug' and methodDesc) then
    local msg = StringHelper:concat(...)
    if (#msg > 0) then
      msg = '，参数：' .. msg
    end
    LogHelper:debug(methodDesc, '失败', msg)
  end
  return nil
end

function CommonHelper:callOneResultMethod (f, methodDesc, ...)
  return CommonHelper:callResultMethod(f, methodDesc, ...)
end

function CommonHelper:callTwoResultMethod (f, methodDesc, ...)
  return CommonHelper:callResultMethod(f, methodDesc, ...)
end

function CommonHelper:callThreeResultMethod (f, methodDesc, ...)
  return CommonHelper:callResultMethod(f, methodDesc, ...)
end

-- 深拷贝
function CommonHelper:copy (t)
  local result
  local tp = type(t)
  if (tp == 'table') then
    result = {}
    for k, v in pairs(t) do
      result[k] = CommonHelper:copy(v)
    end
  else
    result = t
  end
  return result
end
