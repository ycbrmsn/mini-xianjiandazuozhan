-- 聊天工具类
ChatHelper = {}

-- 发送模板消息
function ChatHelper:sendTemplateMsg (template, map, objid)
  local msg = StringHelper:getTemplateResult(template, map)
  ChatHelper:sendSystemMsg(msg, objid)
end

-- 发送消息
function ChatHelper:sendMsg (objid, ...)
  ChatHelper:sendSystemMsg(StringHelper:concat(...), objid)
end

-- 封装原始接口

-- 发送系统消息，默认发送给所有玩家
function ChatHelper:sendSystemMsg (content, targetuin)
  targetuin = targetuin or 0
  local onceFailMessage = '发送系统消息失败一次'
  local finillyFailMessage = '发送系统消息失败'
  return CommonHelper:callIsSuccessMethod(function (p)
    return Chat:sendSystemMsg(content, targetuin)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- UI工具类
UIHelper = {}

-- 封装原水接口

-- 世界坐标转换到小地图
function UIHelper:world2RadarPos (x, z)
  local onceFailMessage = '世界坐标转换到小地图失败一次'
  local finillyFailMessage = StringHelper:concat('世界坐标转换到小地图失败，参数：x=', x, ',z=', z)
  return CommonHelper:callTwoResultMethod(function (p)
    return UI:world2RadarPos(x, z)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 世界长度转换到小地图
function UIHelper:world2RadarDist (length)
  local onceFailMessage = '世界长度转换到小地图失败一次'
  local finillyFailMessage = StringHelper:concat('世界长度转换到小地图失败，参数：length=', length)
  return CommonHelper:callOneResultMethod(function (p)
    return UI:world2RadarDist(length)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置线条标记
function UIHelper:setShapeLine (uiname, p1x, p1y, p2x, p2y)
  local onceFailMessage = '设置线条标记失败一次'
  local finillyFailMessage = StringHelper:concat('设置线条标记失败，参数：uiname=', uiname)
  return CommonHelper:callIsSuccessMethod(function (p)
    return UI:setShapeLine(uiname, p1x, p1y, p2x, p2y)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置圆形标记
function UIHelper:setShapeCircle (uiname, x, y, radius)
  local onceFailMessage = '设置圆形标记失败一次'
  local finillyFailMessage = StringHelper:concat('设置圆形标记失败，参数：uiname=', uiname)
  return CommonHelper:callIsSuccessMethod(function (p)
    return UI:setShapeCircle(uiname, x, y, radius)
  end, nil, onceFailMessage, finillyFailMessage)
end