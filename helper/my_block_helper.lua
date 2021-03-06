-- 我的方块工具类
MyBlockHelper = {
  unableBeoperated = {},
  unableDestroyed = {},
  brokenBlockTime = {}, -- { time = true, time = true }
  cloudid = 118, -- 萌眼星云团
  cloudData = {
    -- 红队
    { 2, 6, 19 }, -- 前方第一层
    { -18, 6, 7 }, -- 左方第一层
    -- 蓝队
  }
}

-- 初始化
function MyBlockHelper.init ()
  -- body
  MyBlockHelper.initBlocks()
end

function MyBlockHelper.initBlocks ()
  for i,v in ipairs(MyBlockHelper.unableBeoperated) do
    BlockHelper.setBlockSettingAttState(v, BLOCKATTR.ENABLE_BEOPERATED, false) -- 不可操作  
  end
  for i, v in ipairs(MyBlockHelper.unableDestroyed) do
    BlockHelper.setBlockSettingAttState(v, BLOCKATTR.ENABLE_DESTROYED, false) -- 不可被破坏
  end
  -- MyBlockHelper.initClouds()
end

function MyBlockHelper.initClouds ()
  -- 红队正前方楼梯
  local x, y, z = MyBlockHelper.cloudData[1][1], MyBlockHelper.cloudData[1][2], MyBlockHelper.cloudData[1][3]
  local index = 0
  for i = 0, 8 do
    index = index + 1
    -- TimeHelper.callFnAfterSecond(function ()
      for j = 0, 4 do
        BlockHelper.placeBlock(MyBlockHelper.cloudid, x + j, y + i, z + i)
      end
    -- end, index)
  end
end

-- 事件

-- 完成方块挖掘
EventHelper.addEvent('blockDigEnd', function (objid, blockid, x, y, z)
  if (blockid == 230) then
    BackpackHelper.addItem(objid, blockid, 1)
    PlayerHelper.showToast(objid, '你获得一个方南瓜')
  elseif (blockid == 251) then
    BackpackHelper.addItem(objid, blockid, 1)
    PlayerHelper.showToast(objid, '你获得一节竹子')
  end
end)

-- 方块被移除
EventHelper.addEvent('blockRemove', function (blockid, x, y, z)
  if (blockid == MyBlockHelper.cloudid) then -- 萌眼星云团
    local data = BlockHelper.getBlockData(x, y, z)
    if (data == 0) then -- 破坏
      -- 30秒后重新生成
      local time = TimeHelper.getTime()
      local second = 30
      while (MyBlockHelper.brokenBlockTime[time + second]) do
        second = second + 1
      end
      MyBlockHelper.brokenBlockTime[time + second] = true
      TimeHelper.callFnAfterSecond(function ()
        BlockHelper.placeBlock(blockid, x, y, z)
        MyBlockHelper.brokenBlockTime[time + second] = nil
      end, second)
    end
  end
end)
