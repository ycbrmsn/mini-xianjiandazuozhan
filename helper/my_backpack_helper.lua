-- 我的背包工具类
MyBackpackHelper = {}

-- 事件

-- 容器内有道具取出
function MyBackpackHelper:backpackItemTakeOut (blockid, x, y, z, itemid, itemnum)
  BackpackHelper:backpackItemTakeOut(blockid, x, y, z, itemid, itemnum)
  MyStoryHelper:backpackItemTakeOut(blockid, x, y, z, itemid, itemnum)
  -- body
end