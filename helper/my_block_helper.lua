-- 我的方块工具类
MyBlockHelper = {
  unableBeoperated = {
    828 -- 舒适的床
  },
  unableDestroyed = {
    100, -- 草块
    101, -- 土块
    200, -- 果木
    218, -- 果木树叶
    230, -- 方南瓜
    251, -- 竹子
    422, -- 粗制岩石砖
    529, -- 石块楼梯
    534, -- 木围栏
    556, -- 玻璃窗
    812, -- 果木门
    822, -- 草垛
    828, -- 舒适的床
    931, -- 蜡烛台
    932, -- 蜡烛台
    965, -- 果木椅子
    966, -- 果木桌子
    969 -- 果木柜子
  },
  brokenBlockTime = {} -- { time = true, time = true }
}

-- 初始化
function MyBlockHelper:init ()
  -- body
  MyBlockHelper:initBlocks()
end

-- 检查是否是控制城门的开关，如果是则打开城门或关闭城门
function MyBlockHelper:checkCityGates (objid, blockid, pos)
  if (blockid == 724) then -- 开关
    for i, v in ipairs(self.cityGates) do
      if (v[1]:equals(pos)) then -- 找到开关
        if (BlockHelper:getBlockSwitchStatus(v[1])) then -- 打开
          if (BlockHelper:getBlockID(v[4].x, v[4].y, v[4].z) == self.cityGateBlockIds[1]) then
            AreaHelper:replaceAreaBlock(v[5], self.cityGateBlockIds[1], self.cityGateBlockIds[2], 5)
            BlockHelper:replaceBlock(self.cityGateBlockIds[3], v[2].x, v[2].y, v[2].z)
            TimeHelper:callFnFastRuns(function ()
              AreaHelper:replaceAreaBlock(v[5], self.cityGateBlockIds[2], self.cityGateBlockIds[1], 5)
              BlockHelper:replaceBlock(self.cityGateBlockIds[3], v[3].x, v[3].y, v[3].z)
            end, 0.005)
          end
        else
          BlockHelper:replaceBlock(self.cityGateBlockIds[2], v[2].x, v[2].y, v[2].z)
          BlockHelper:replaceBlock(self.cityGateBlockIds[2], v[3].x, v[3].y, v[3].z)
        end
        break
      end
    end
  end
end

function MyBlockHelper:initBlocks ()
  for i,v in ipairs(self.unableBeoperated) do
    BlockHelper:setBlockSettingAttState(v, BLOCKATTR.ENABLE_BEOPERATED, false) -- 不可操作  
  end
  for i, v in ipairs(self.unableDestroyed) do
    BlockHelper:setBlockSettingAttState(v, BLOCKATTR.ENABLE_DESTROYED, false) -- 不可被破坏
  end
end

-- 事件

-- 方块被破坏
function MyBlockHelper:blockDestroyBy (objid, blockid, x, y, z)
  BlockHelper:blockDestroyBy(objid, blockid, x, y, z)
  -- body
end

-- 完成方块挖掘
function MyBlockHelper:blockDigEnd (objid, blockid, x, y, z)
  BlockHelper:blockDigEnd(objid, blockid, x, y, z)
  -- body
  if (blockid == 230) then
    BackpackHelper:addItem(objid, blockid, 1)
    PlayerHelper:showToast(objid, '你获得一个方南瓜')
  elseif (blockid == 251) then
    BackpackHelper:addItem(objid, blockid, 1)
    PlayerHelper:showToast(objid, '你获得一节竹子')
  end
end

-- 方块被放置
function MyBlockHelper:blockPlaceBy (objid, blockid, x, y, z)
  BlockHelper:blockPlaceBy(objid, blockid, x, y, z)
  -- body
end

-- 方块被移除
function MyBlockHelper:blockRemove (blockid, x, y, z)
  BlockHelper:blockRemove(blockid, x, y, z)
  -- body
  if (blockid == 118) then -- 萌眼星云团
    local data = BlockHelper:getBlockData(x, y, z)
    if (data == 0) then -- 破坏
      -- 30秒后重新生成
      local time = TimeHelper:getTime()
      local second = 30
      while (self.brokenBlockTime[time + second]) do
        second = second + 1
      end
      self.brokenBlockTime[time + second] = true
      TimeHelper:callFnAfterSecond(function ()
        BlockHelper:placeBlock(blockid, x, y, z)
        self.brokenBlockTime[time + second] = nil
      end, second)
    end
  end
end

-- 方块被触发
function MyBlockHelper:blockTrigger (objid, blockid, x, y, z)
  BlockHelper:blockTrigger(objid, blockid, x, y, z)
  -- body
  -- local pos = MyPosition:new(x, y, z)
  -- MyBlockHelper:checkCityGates(objid, blockid, pos)
end