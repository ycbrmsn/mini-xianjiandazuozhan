-- 容器管理工具类
WorldContainerHelper = {}

-- 是否储物箱是空的
function WorldContainerHelper:isStorageBoxEmpty (x, y, z)
  if (type(x) == 'number') then

  elseif (type(x) == 'table') then
    x, y, z = x.x, x.y, x.z
  else
    LogHelper:error('检测储物箱空时参数错误')
    return nil
  end
  local isEmpty = true
  for i = 0, 29 do
    local itemid = WorldContainerHelper:getStorageItem(x, y, z, i)
    if (itemid and itemid ~= 0) then
      isEmpty = false
      break
    end
  end
  return isEmpty
end

-- 封装原始接口

function WorldContainerHelper:addStorageBox (x, y, z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return WorldContainer:addStorageBox(x, y, z)
  end, '新增储物箱', 'x=', x, ',y=', y, ',z=', z)
end

function WorldContainerHelper:removeStorageBox (x, y, z)
  return CommonHelper:callIsSuccessMethod(function (p)
    return WorldContainer:removeStorageBox(x, y, z)
  end, '移除储物箱', 'x=', x, ',y=', y, ',z=', z)
end

-- 检测是否是储物箱
function WorldContainerHelper:checkStorage (x, y, z)
  return WorldContainer:checkStorage(x, y, z) == ErrorCode.OK
end

function WorldContainerHelper:setStorageItem (x, y, z, offset, itemid, num)
  return CommonHelper:callIsSuccessMethod(function (p)
    return WorldContainer:setStorageItem(x, y, z, offset, itemid, num)
  end, '设置储物箱道具', 'x=', x, ',y=', y, ',z=', z, ',offset=', offset, ',itemid=', itemid, ',num=', num)
end

-- itemid、itemnum 接口不能用，一用就退出游戏 2020-09-25 2020-11-08
function WorldContainerHelper:getStorageItem (x, y, z, offset)
  return CommonHelper:callTwoResultMethod(function (p)
    return WorldContainer:getStorageItem(x, y, z, offset)
  end, '获取储物箱道具ID', 'x=', x, ',y=', y, ',z=', z, ',offset=', offset)
end

function WorldContainerHelper:removeStorageItemByIndex (x, y, z, offset, num)
  return CommonHelper:callIsSuccessMethod(function (p)
    return WorldContainer:removeStorageItemByIndex(x, y, z, offset, num)
  end, '移除储物箱内指定格子的道具', 'x=', x, ',y=', y, ',z=', z, ',offset=', offset, ',num=', num)
end

-- 给储物箱添加道具 返回成功添加数量
function WorldContainerHelper:addStorageItem (x, y, z, itemid, num)
  return CommonHelper:callOneResultMethod(function (p)
    return WorldContainer:addStorageItem(x, y, z, itemid, num)
  end, '给储物箱添加道具', 'x=', x, ',y=', y, ',z=', z, ',itemid=', itemid, ',num=', num)
end

-- 检测储物箱是否有空余格子，传入道具ID则同时检测有无该道具（即有空格或有该道具）
function WorldContainerHelper:checkStorageEmptyGrid (x, y, z, itemid)
  return WorldContainer:checkStorageEmptyGrid(x, y, z, itemid) == ErrorCode.OK
end

function WorldContainerHelper:removeStorageItemByID (x, y, z, itemid, num)
  return CommonHelper:callIsSuccessMethod(function (p)
    return WorldContainer:removeStorageItemByID(x, y, z, itemid, num)
  end, '移除储物箱内指定类型的道具', 'x=', x, ',y=', y, ',z=', z, ',itemid=', itemid, ',num=', num)
end