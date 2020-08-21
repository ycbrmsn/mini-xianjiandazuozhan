-- 字符串工具类
StringHelper = {
  hourName = { '子时', '丑时', '寅时', '卯时', '辰时', '巳时', '午时', '未时', '申时', '酉时', '戌时', '亥时' },
  numName = { [0] = '', [1] = '一', [2] = '二', [3] = '三', [4] = '四', [5] = '五', 
    [6] = '六', [7] = '七', [8] = '八', [9] = '九', [10] = '拾' }
}

--[[
utf-8编码规则
单字节 - 0起头
   1字节  0xxxxxxx   0 - 127
多字节 - 第一个字节n个1加1个0起头
   2 字节 110xxxxx   192 - 223
   3 字节 1110xxxx   224 - 239
   4 字节 11110xxx   240 - 247
可能有1-4个字节
--]]
-- 转自网上
function StringHelper:getBytes (char)
  if (not(char)) then
    return 0
  end
  local code = string.byte(char)
  if (code < 127) then
    return 1
  elseif (code <= 223) then
    return 2
  elseif (code <= 239) then
    return 3
  elseif (code <= 247) then
    return 4
  else
    -- 讲道理不会走到这里^_^
    return 0
  end
end

-- 转自网上
function StringHelper:sub (str, beginIndex, endIndex)
  local tempStr = str 
  local byteBegin = 1 -- string.sub截取的开始位置
  local byteEnd = -1 -- string.sub截取的结束位置
  local index = 0  -- 字符记数
  local bytes = 0  -- 字符的字节记数

  beginIndex = math.max(beginIndex, 1)
  endIndex = endIndex or -1
  while (string.len(tempStr) > 0) do     
    if (index == beginIndex - 1) then
       byteBegin = bytes + 1
    elseif (index == endIndex) then
       byteEnd = bytes
       break
    end
    bytes = bytes + self:GetBytes(tempStr)
    tempStr = string.sub(str, bytes + 1)

    index = index + 1
  end
  return string.sub(str, byteBegin, byteEnd)
end

-- 截取全中文
function StringHelper:subZh (str, i, j)
  if (i > 1) then
    i = i * 3 - 2
  end
  return string.sub(str, i, j)
end

-- 连接数组中的字符串t:table, c:连接符, k:如果table中的元素是table, k则是元素的键值
function StringHelper:join (t, c, k)
  c = c or ' '
  local str = ''
  local len = #t
  for i, v in ipairs(t) do
    if (k) then
      str = str .. v[k]
    else
      str = str .. v
    end
    if (i ~= len) then
      str = str .. c
    end
  end
  return str
end

-- 显示字符串
function StringHelper:toString (v)
  local t = type(v)
  if (t == 'nil' or t == 'function' or t == 'userdata' or t == 'thread') then
    return t
  elseif (t == 'boolean') then
    if (v) then
      return 'true'
    else
      return 'false'
    end
  elseif (t == 'number' or t == 'string') then
    return v
  elseif (t == 'table') then
    return self:tableToString(v)
  else -- 不会进入这里
    return 'other'
  end
end

-- 显示table字符串
function StringHelper:tableToString (t)
  local str = '{ '
  local index = 1
  for k, v in pairs(t) do
    if (index ~= 1) then
      str = str .. ', '
    end
    str = str .. k .. ' = ' .. self:toString(v)
    index = index + 1
  end
  str = str .. ' }'
  return str
end

-- 拼接所有参数
function StringHelper:concat (...)
  local num = select("#", ...)
  if (num == 1) then
    return self:toString(select(1, ...))
  else
    local str = ''
    for i = 1, num do
      local arg = select(i, ...)
      str = str .. self:toString(arg)
    end
    return str
  end
end

-- 根据小时获得时辰名称
function StringHelper:getHourName (hour)
  if (hour < 1 or hour >= 23) then
    return self.hourName[1]
  else
    for i = 2, 12 do
      if (hour >= i * 2 - 3 and hour < i * 2 - 1) then
        return self.hourName[i]
      end
    end
  end
end

-- 获得模板结果
function StringHelper:getTemplateResult (template, map)
  local temp = template
  if (map) then
    for k, v in pairs(map) do
      temp = string.gsub(temp, '{' .. k .. '}', v)
    end
  end
  return temp
end

-- 数字转化为字符串
function StringHelper:number2String (num)
  if (type(num) == 'number') then
    if (num < 10000) then
      return num .. ''
    elseif (num < 100000000) then
      return '超过' .. math.floor(num / 10000) .. '万'
    end
  else
    return ''
  end
end

-- 拆分字符串
function StringHelper:split (szFullString, szSeparator)
  local nFindStartIndex = 1
  local nSplitIndex = 1
  local nSplitArray = {}
  while (true) do
    local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
    if (not nFindLastIndex) then
      nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
      break
    end
    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
    nFindStartIndex = nFindLastIndex + string.len(szSeparator)
    nSplitIndex = nSplitIndex + 1
  end
  return nSplitArray
end

-- 小整数转中文
function StringHelper:int2Chinese (num)
  local result
  if (num < -99 or num > 99) then
    return num .. ''
  elseif (num == 0) then
    return '零'
  end
  if (num < 0) then
    result = '负'
  else
    result = ''
  end
  local temp = math.abs(num)
  if (temp > 19) then
    result = result .. self.numName[math.floor(temp / 10)]
  end
  if (temp > 9) then
    result = result .. self.numName[10]
  end
  result = result .. self.numName[temp % 10]
  return result
end