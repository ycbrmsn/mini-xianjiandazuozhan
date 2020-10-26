-- 聊天工具类
ChatHelper = {}

-- 发送模板消息
function ChatHelper:sendTemplateMsg (template, map, objid)
  local msg = StringHelper:getTemplateResult(template, map)
  return ChatHelper:sendSystemMsg(msg, objid)
end

-- 发送消息
function ChatHelper:sendMsg (objid, ...)
  return ChatHelper:sendSystemMsg(StringHelper:concat(...), objid)
end

-- 说
function ChatHelper:speak (name, toobjid, ...)
  return ChatHelper:sendMsg(toobjid, name, '：', StringHelper.speakColor, ...)
end

-- 想
function ChatHelper:think (name, toobjid, ...)
  local content = StringHelper:concat(...)
  return ChatHelper:sendMsg(toobjid, name, '：', StringHelper.speakColor, '（', content, StringHelper.speakColor, '）')
end

-- 等待后说
function ChatHelper:waitSpeak (name, toobjid, seconds, ...)
  local content = StringHelper:concat(...)
  TimeHelper:callFnAfterSecond(function ()
    ChatHelper:speak(name, toobjid, content)
  end, seconds)
end

-- 等待后想
function ChatHelper:waitThink (name, toobjid, seconds, ...)
  local content = StringHelper:concat(...)
  TimeHelper:callFnAfterSecond(function ()
    ChatHelper:think(name, toobjid, content)
  end, seconds)
end

-- 显示选项
function ChatHelper:showChooseItems (objid, arr, key)
  ChatHelper:showSelectSeparate(objid)
  for i, v in ipairs(arr) do
    if (key) then
      ChatHelper:sendMsg(objid, i .. '.' .. v[key])
    else
      ChatHelper:sendMsg(objid, i .. '.' .. v)
    end
  end
end

-- 显示分隔
function ChatHelper:showSeparate (objid, char)
  char = char or ''
  ChatHelper:sendMsg(objid, '-------', char, '-------')
end

function ChatHelper:showSelectSeparate (objid)
  ChatHelper:showSeparate(objid, '选项')
end

function ChatHelper:showEndSeparate (objid)
  ChatHelper:showSeparate(objid, '对话结束')
end

function ChatHelper:showBreakSeparate (objid)
  ChatHelper:showSeparate(objid, '对话中止')
end

-- 封装原始接口

-- 发送系统消息，默认发送给所有玩家
function ChatHelper:sendSystemMsg (content, targetuin)
  targetuin = targetuin or 0
  return CommonHelper:callIsSuccessMethod(function (p)
    return Chat:sendSystemMsg(content, targetuin)
  end, '发送系统消息')
end

-- UI工具类
UIHelper = {}

-- 设置左标题
function UIHelper:setLeftTitle (...)
  UIHelper:setGBattleUI('left_title', StringHelper:concat(...))
end

-- 设置右标题
function UIHelper:setRightTitle (...)
  UIHelper:setGBattleUI('right_title', StringHelper:concat(...))
end

-- 设置左描述
function UIHelper:setLeftDesc (...)
  UIHelper:setGBattleUI('left_desc', StringHelper:concat(...))
end

-- 设置左简述
function UIHelper:setLeftLittleDesc (...)
  UIHelper:setGBattleUI('left_little_desc', StringHelper:concat(...))
end

-- 设置右简述
function UIHelper:setRightLittleDesc (...)
  UIHelper:setGBattleUI('right_little_desc', StringHelper:concat(...))
end

-- 封装原始接口

-- 世界坐标转换到小地图
function UIHelper:world2RadarPos (x, z)
  return CommonHelper:callTwoResultMethod(function (p)
    return UI:world2RadarPos(x, z)
  end, '世界坐标转换到小地图', 'x=', x, ',z=', z)
end

-- 世界长度转换到小地图
function UIHelper:world2RadarDist (length)
  return CommonHelper:callOneResultMethod(function (p)
    return UI:world2RadarDist(length)
  end, '世界长度转换到小地图', 'length=', length)
end

-- 设置线条标记
function UIHelper:setShapeLine (uiname, p1x, p1y, p2x, p2y)
  return CommonHelper:callIsSuccessMethod(function (p)
    return UI:setShapeLine(uiname, p1x, p1y, p2x, p2y)
  end, '设置线条标记', 'uiname=', uiname, ',p1x=', p1x, ',p1y=', p1y, ',p2x=',
    p2x, ',p2y=', p2y)
end

-- 设置圆形标记
function UIHelper:setShapeCircle (uiname, x, y, radius)
  return CommonHelper:callIsSuccessMethod(function (p)
    return UI:setShapeCircle(uiname, x, y, radius)
  end, '设置圆形标记', 'uiname=', uiname, ',x=', x, ',y=', y, ',radius=', radius)
end

--[[ 
  设置战斗总结UI 
  左标题left_title、右标题right_title、左描述left_desc、左简述left_little_desc、右简述right_little_desc
  比分导航栏面板按钮battle_btn、比赛结果result、比赛结果底板result_bkg、再来一局按钮reopen
]]--
function UIHelper:setGBattleUI (name, value)
  return CommonHelper:callIsSuccessMethod(function (p)
    return UI:setGBattleUI(name, value)
  end, '设置战斗总结UI', 'name=', name, ',value=', value)
end