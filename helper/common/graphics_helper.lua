-- 文字板工具类
GraphicsHelper = {
  defaultFont = 16,
  defaultAlpha = 0,
  defaultColor = 0xFFFFFF,
  defaultItype = 1,
  defaultDir = { x = 0, y = 1, z = 0 },
  defaultOffset = 100,
  hpMap = {}, -- objid -> graphid
}

local mt = { __mode = 'k' }
setmetatable(GraphicsHelper.hpMap, mt)

function GraphicsHelper.updateHp (objid, hp, maxHp, offset)
  -- local graphid = GraphicsHelper.hpMap[objid]
  -- if (graphid) then
  --   return GraphicsHelper.updateGraphicsProgressById(graphid, hp, maxHp)
  -- else
    GraphicsHelper.removeGraphicsByObjID(objid, GraphicsHelper.defaultItype, GRAPHICS.GRAPHICS_PROGRESS)
    graphid = GraphicsHelper.createProgressByActor(objid, hp, maxHp, nil, offset, 0x04B431, GraphicsHelper.defaultItype)
    GraphicsHelper.hpMap[objid] = graphid
  -- end
end

-- 文字板
function GraphicsHelper.makeTxt (title, font, alpha, itype)
  font = font or GraphicsHelper.defaultFont
  alpha = alpha or GraphicsHelper.defaultAlpha
  itype = itype or GraphicsHelper.defaultItype
  return Graphics:makeGraphicsText(title, font, alpha, itype)
end

-- 漂浮文字
function GraphicsHelper.makeFTxt (title, font, itype)
  font = font or GraphicsHelper.defaultFont
  itype = itype or GraphicsHelper.defaultItype
  return Graphics:makeflotageText(title, font, itype)
end

-- 进度条
function GraphicsHelper.makeProgress (v1, v2, color, itype)
  color = color or GraphicsHelper.defaultColor
  itype = itype or GraphicsHelper.defaultItype
  return Graphics:makeGraphicsProgress(v1, v2, color, itype)
end

-- 在位置上创建文字板
function GraphicsHelper.createTextByPos (x, y, z, title, font, alpha, itype)
  local info = GraphicsHelper.makeTxt(title, font, alpha, itype)
  if (info) then
    return GraphicsHelper.createGraphicsTxtByPos(x, y, z, info)
  end
end

-- 在生物身上创建文字板
function GraphicsHelper.createTxtByActor (objid, title, dir, offest, font, alpha, itype)
  local info = GraphicsHelper.makeTxt(title, font, alpha, itype)
  if (info) then
    dir = dir or GraphicsHelper.defaultDir
    offest = offest or GraphicsHelper.defaultOffset
    return GraphicsHelper.createGraphicsTxtByActor(objid, info, dir, offest)
  end
end

-- 在位置上创建漂浮文字
function GraphicsHelper.createFTxtByPos (x, y, z, title, font, itype)
  local info = GraphicsHelper.makeFTxt(title, font, itype)
  if (info) then
    return GraphicsHelper.createflotageTextByPos(x, y, z, info)
  end
end

-- 在生物身上创建漂浮文字
function GraphicsHelper.createFTxtByActor (objid, title, dir, offest, font, itype)
  local info = GraphicsHelper.makeFTxt(title, font, itype)
  if (info) then
    dir = dir or GraphicsHelper.defaultDir
    offest = offest or GraphicsHelper.defaultOffset
    return GraphicsHelper.createflotageTextByActor(objid, info, dir, offest)
  end
end

-- 在位置上创建进度条
function GraphicsHelper.createProgressByPos (x, y, z, v1, v2, color, itype)
  local info = GraphicsHelper.makeProgress(v1, v2, color, itype)
  if (info) then
    return GraphicsHelper.createGraphicsProgressByPos(x, y, z, info)
  end
end

-- 在生物身上创建进度条
function GraphicsHelper.createProgressByActor (objid, v1, v2, dir, offest, color, itype)
  local info = GraphicsHelper.makeProgress(v1, v2, color, itype)
  if (info) then
    dir = dir or GraphicsHelper.defaultDir
    offest = offest or GraphicsHelper.defaultOffset
    return GraphicsHelper.createGraphicsProgressByActor(objid, info, dir, offest)
  end
end

-- 封装原始接口

-- function GraphicsHelper.makeGraphicsText (title, font, alpha, itype)
--   return CommonHelper.callResultMethod(function ()
--     return Graphics:makeGraphicsText(title, font, alpha, itype)
--   end, '创建文字板信息', 'title=', title, ',font=', font, ',alpha=', alpha, ',itype=', itype)
-- end

-- function GraphicsHelper.makeflotageText (title, font, itype)
--   return CommonHelper.callResultMethod(function ()
--     return Graphics:makeflotageText(title, font, itype)
--   end, '创建漂浮文字信息', 'title=', title, ',font=', font, ',itype=', itype)
-- end

-- function GraphicsHelper.makeGraphicsProgress (v1, v2, color, itype)
--   return CommonHelper.callResultMethod(function ()
--     return Graphics:makeGraphicsProgress(v1, v2, color, itype)
--   end, '创建进度条信息', 'v1=', v1, ',v2=', v2, ',color=', color, ',itype=', itype)
-- end

function GraphicsHelper.createGraphicsTxtByPos (x, y, z, graphicInfo)
  return CommonHelper.callResultMethod(function ()
    return Graphics:createGraphicsTxtByPos(x, y, z, graphicInfo)
  end, '在位置上创建文字板', 'x=', x, ',y=', y, ',z=', z, ',graphicInfo=', graphicInfo)
end

function GraphicsHelper.createGraphicsTxtByActor (objid, graphicInfo, dir, offest)
  return CommonHelper.callResultMethod(function ()
    return Graphics:createGraphicsTxtByActor(objid, graphicInfo, dir, offest)
  end, '在生物身上创建文字板', 'objid=', objid, ',graphicInfo=', graphicInfo, ',dir=', dir, ',offest=', offest)
end

function GraphicsHelper.createflotageTextByPos (x, y, z, graphicInfo)
  return CommonHelper.callResultMethod(function ()
    return Graphics:createflotageTextByPos(x, y, z, graphicInfo)
  end, '在位置上创建漂浮文字', 'x=', x, ',y=', y, ',z=', z, ',graphicInfo=', graphicInfo)
end

function GraphicsHelper.createflotageTextByActor (objid, graphicInfo, dir, offest)
  return CommonHelper.callResultMethod(function ()
    return Graphics:createflotageTextByActor(objid, graphicInfo, dir, offest)
  end, '在生物身上创建漂浮文字', 'objid=', objid, ',graphicInfo=', graphicInfo, ',dir=', dir, ',offest=', offest)
end

function GraphicsHelper.createGraphicsProgressByPos (x, y, z, graphicInfo)
  return CommonHelper.callResultMethod(function ()
    return Graphics:createGraphicsProgressByPos(x, y, z, graphicInfo)
  end, '在位置上创建进度条', 'x=', x, ',y=', y, ',z=', z, ',graphicInfo=', graphicInfo)
end

function GraphicsHelper.createGraphicsProgressByActor (objid, graphicInfo, dir, offest)
  return CommonHelper.callResultMethod(function ()
    return Graphics:createGraphicsProgressByActor(objid, graphicInfo, dir, offest)
  end, '在生物身上创建进度条', 'objid=', objid, ',graphicInfo=', graphicInfo, ',dir=', dir, ',offest=', offest)
end

function GraphicsHelper.removeGraphicsByPos (x, y, z, itype, graphType)
  return CommonHelper.callIsSuccessMethod(function ()
    return Graphics:removeGraphicsByPos(x, y, z, itype, graphType)
  end, '删除位置上的图文信息', 'x=', x, ',y=', y, ',z=', z, ',itype=', itype, ',graphType=', graphType)
end

function GraphicsHelper.removeGraphicsByObjID (objid, itype, graphType)
  return CommonHelper.callIsSuccessMethod(function ()
    return Graphics:removeGraphicsByObjID(objid, itype, graphType)
  end, '删除生物的图文信息', 'objid=', objid, ',itype=', itype, ',graphType=', graphType)
end

function GraphicsHelper.updateGraphicsTextById (graphid, title)
  return CommonHelper.callIsSuccessMethod(function ()
    return Graphics:updateGraphicsTextById(graphid, title)
  end, '更新图文信息的文字内容', 'graphid=', graphid, ',title=', title)
end

function GraphicsHelper.updateGraphicsProgressById (graphid, val1, val2)
  return CommonHelper.callIsSuccessMethod(function ()
    return Graphics:updateGraphicsProgressById(graphid, val1, val2)
  end, '更新进度条的进度', 'graphid=', graphid, ',val1=', val1, ',val2=', val2)
end