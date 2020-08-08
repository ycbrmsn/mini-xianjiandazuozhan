-- 背包工具类
BackpackHelper = {}

-- 玩家背包里是否有某道具
function BackpackHelper:hasItem (playerid, itemid, containEquip)
  local r1 = BackpackHelper:hasItemByBackpackBar(playerid, BACKPACK_TYPE.SHORTCUT, itemid) -- 快捷栏
  if (r1) then
    return r1, BACKPACK_TYPE.SHORTCUT
  else
    local r2 = BackpackHelper:hasItemByBackpackBar(playerid, BACKPACK_TYPE.INVENTORY, itemid) -- 存储栏
    if (r2) then
      return r2, BACKPACK_TYPE.INVENTORY
    else
      if (containEquip) then
        return BackpackHelper:hasItemByBackpackBar(playerid, BACKPACK_TYPE.EQUIP, itemid), BACKPACK_TYPE.EQUIP -- 装备栏
      else
        return false
      end
    end
  end
end

-- 单一背包栏道具总数及背包格数组
function BackpackHelper:getItemNum (playerid, itemid, containEquip)
  local r, bartype = self:hasItem(playerid, itemid, containEquip)
  if (r) then
    return self:getItemNumByBackpackBar(playerid, bartype, itemid)
  else
    return 0, {}
  end
end

-- 获取快捷栏某个道具总数及背包格数组
function BackpackHelper:getItemNumByShortcut (playerid, itemid)
  return self:getItemNumByBackpackBar(playerid, BACKPACK_TYPE.SHORTCUT, itemid)
end

-- 获取存储栏某个道具总数及背包格数组
function BackpackHelper:getItemNumByInventory (playerid, itemid)
  return self:getItemNumByBackpackBar(playerid, BACKPACK_TYPE.INVENTORY, itemid)
end

-- 获取快捷、存储栏某个道具的总数及背包格数组 返回值 number, table, table
function BackpackHelper:getItemNumAndGrid (playerid, itemid)
  local num1, arr1 = self:getItemNumByShortcut(playerid, itemid)
  local num2, arr2 = self:getItemNumByInventory(playerid, itemid)
  return num1 + num2, arr1, arr2
end

-- 获取快捷、存储栏某个道具的总数及背包格数组 返回值 number, table
function BackpackHelper:getItemNumAndGrid2 (playerid, itemid)
  local num, arr1, arr2 = self:getItemNumAndGrid(playerid, itemid)
  local arr = {}
  for i, v in ipairs(arr1) do
    table.insert(arr, v)
  end
  for i, v in ipairs(arr2) do
    table.insert(arr, v)
  end
  return num, arr
end

-- 获取玩家当前手持道具的背包格
function BackpackHelper:getCurShotcutGrid (playerid)
  return PlayerHelper:getCurShotcut(playerid) + 1000
end

-- 封装原始接口

-- 添加道具到背包
function BackpackHelper:addItem (playerid, itemid, num)
  local onceFailMessage = '添加道具到背包失败一次'
  local finillyFailMessage = StringHelper:concat('添加道具到背包失败，参数：playerid=', playerid, ',itemid=', itemid, ',num=', num)
  return CommonHelper:callOneResultMethod(function (p)
    return Backpack:addItem(playerid, itemid, num)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 检测背包是否持有某个道具
function BackpackHelper:hasItemByBackpackBar (playerid, bartype, itemid)
  return Backpack:hasItemByBackpackBar(playerid, bartype, itemid) == ErrorCode.OK
end

-- 获取背包持有某个道具总数量，同时返回装有道具的背包格数组
function BackpackHelper:getItemNumByBackpackBar (playerid, bartype, itemid)
  local onceFailMessage = '获取背包持有某个道具总数量失败一次'
  local finillyFailMessage = StringHelper:concat('获取背包持有某个道具总数量失败，参数：playerid=', playerid, ',bartype=', bartype, ', itemid=', itemid)
  return CommonHelper:callTwoResultMethod(function (p)
    return Backpack:getItemNumByBackpackBar(playerid, bartype, itemid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 交换背包道具
function BackpackHelper:swapGridItem (playerid, gridsrc, griddst)
  local onceFailMessage = '交换背包道具失败一次'
  local finillyFailMessage = StringHelper:concat('交换背包道具失败，参数：playerid=', playerid, ',gridsrc=', gridsrc, ',griddst=', griddst)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Backpack:swapGridItem(playerid, gridsrc, griddst)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 通过道具格移除道具
function BackpackHelper:removeGridItem (playerid, gridid, num)
  local onceFailMessage = '通过道具格移除道具失败一次'
  local finillyFailMessage = StringHelper:concat('通过道具格移除道具失败，参数：playerid=', playerid, ',gridid=', gridid, ',num=', num)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Backpack:removeGridItem(playerid, gridid, num)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 移除背包内道具
function BackpackHelper:removeGridItemByItemID (playerid, itemid, num)
  local onceFailMessage = '移除背包内道具失败一次'
  local finillyFailMessage = StringHelper:concat('移除背包内道具失败，参数：playerid=', playerid, ',itemid=', itemid, ',num=', num)
  return CommonHelper:callOneResultMethod(function (p)
    return Backpack:removeGridItemByItemID(playerid, itemid, num)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取背包格道具耐久度(返回durcur, durmax)
function BackpackHelper:getGridDurability (playerid, gridid)
  local onceFailMessage = '获取背包格道具耐久度失败一次'
  local finillyFailMessage = StringHelper:concat('获取背包格道具耐久度失败，参数：playerid=', playerid, ',gridid=', gridid)
  return CommonHelper:callTwoResultMethod(function (p)
    return Backpack:getGridDurability(playerid, gridid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 设置背包格道具
function BackpackHelper:setGridItem (playerid, gridid, itemid, num, durability)
  local onceFailMessage = '设置背包格道具失败一次'
  local finillyFailMessage = StringHelper:concat('设置背包格道具失败，参数：gridid=', gridid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Backpack:setGridItem(playerid, gridid, itemid, num, durability)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 丢弃背包某个格子里的道具
function BackpackHelper:discardItem (playerid, gridid, num)
  local onceFailMessage = '丢弃道具失败一次'
  local finillyFailMessage = StringHelper:concat('丢弃道具失败，参数：gridid=', gridid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Backpack:discardItem(playerid, gridid, num)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取背包格道具ID(返回itemid, num)
function BackpackHelper:getGridItemID (playerid, gridid)
  local onceFailMessage = '获取背包格道具ID失败一次'
  local finillyFailMessage = StringHelper:concat('获取背包格道具ID失败，参数：playerid=', playerid, ',gridid=', gridid)
  return CommonHelper:callTwoResultMethod(function (p)
    return Backpack:getGridItemID(playerid, gridid)
  end, nil, onceFailMessage, finillyFailMessage)
end

-- 获取背包某个格子的道具数量
function BackpackHelper:getGridNum (playerid, gridid)
  local onceFailMessage = '获取背包某个格子的道具数量失败一次'
  local finillyFailMessage = StringHelper:concat('获取背包某个格子的道具数量失败，参数：playerid=', playerid, ',gridid=', gridid)
  return CommonHelper:callOneResultMethod(function (p)
    return Backpack:getGridNum(playerid, gridid)
  end, nil, onceFailMessage, finillyFailMessage)
end