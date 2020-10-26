-- 游戏数据工具类
GameDataHelper = {}

-- 更新剧情数据
function GameDataHelper:updateStoryData ()
  local player = PlayerHelper:getHostPlayer()
  local mainIndex = BackpackHelper:getItemNumAndGrid(player.objid, MyMap.ITEM.GAME_DATA_MAIN_INDEX_ID)
  local mainProgress = BackpackHelper:getItemNumAndGrid(player.objid, MyMap.ITEM.GAME_DATA_MAIN_PROGRESS_ID)
  if (mainIndex == 0 or mainProgress == 0) then -- 未找到游戏数据文件
    -- self:updateMainIndex()
    -- self:updateMainProgress()
    return false
  else -- 再次回到游戏
    StoryHelper:setMainStoryIndex(mainIndex)
    StoryHelper:setMainStoryProgress(mainProgress)
    return true
  end
end

-- 更新主线剧情序号道具
function GameDataHelper:updateMainIndex ()
  local player = PlayerHelper:getHostPlayer()
  local itemid = MyMap.ITEM.GAME_DATA_MAIN_INDEX_ID
  local gridid = 28
  local num = StoryHelper:getMainStoryIndex()
  return self:updateDataItem(player.objid, itemid, gridid, num)
end

-- 更新主线剧情进度道具
function GameDataHelper:updateMainProgress ()
  local player = PlayerHelper:getHostPlayer()
  local itemid = MyMap.ITEM.GAME_DATA_MAIN_PROGRESS_ID
  local gridid = 29
  local num = StoryHelper:getMainStoryProgress()
  return self:updateDataItem(player.objid, itemid, gridid, num)
end

-- 丢弃非游戏数据道具
function GameDataHelper:discardOtherItem (playerid, gridid)
  local itemid = BackpackHelper:getGridItemID(playerid, gridid)
  if (itemid ~= MyMap.ITEM.GAME_DATA_MAIN_INDEX_ID and 
    itemid ~= MyMap.ITEM.GAME_DATA_MAIN_PROGRESS_ID and 
    itemid ~= MyMap.ITEM.GAME_DATA_LEVEL_ID and 
    itemid ~= MyMap.ITEM.GAME_DATA_EXP_ID) then
    BackpackHelper:discardItem(playerid, gridid, 99)
  end
end

-- 更新游戏数据道具
function GameDataHelper:updateGameData (player)
  local hostPlayer = PlayerHelper:getHostPlayer()
  if (player == hostPlayer) then
    self:updateMainIndex()
    self:updateMainProgress()
  end
end

function GameDataHelper:updateDataItem (objid, itemid, gridid, num)
  local curNum, arr1, arr2 = BackpackHelper:getItemNumAndGrid(objid, itemid)
  -- if (num == curNum) then
  --   return
  -- end
  -- if (num < curNum) then -- 减少
  --   BackpackHelper:removeGridItemByItemID(objid, itemid, curNum - num)
  -- else -- 增加
  --   if (curNum == 0) then -- 当前一件都没有
  --     self:discardOtherItem(objid, gridid)
  --     BackpackHelper:setGridItem(objid, gridid, itemid, num)
  --     PlayerHelper:setItemDisableThrow(objid, itemid)
  --   else -- 已经有了
  --     if (#arr1 > 0) then
  --       gridid = arr1[1]
  --     else
  --       gridid = arr2[1]
  --     end
  --     local gridNum = BackpackHelper:getGridNum(objid, gridid)
  --     BackpackHelper:setGridItem(objid, gridid, itemid, num - curNum + gridNum)
  --   end
  -- end
  local f1, f2, f3, f4, f5 = true, true, true, true, true
  local theItemid, theNum = BackpackHelper:getGridItemID(objid, gridid)
  if (theItemid == itemid) then -- 同一道具
    if (theNum == num) then -- 数目相同
    else -- 数目不同
      if (theNum ~= curNum) then -- 不相等，表示还有其他格子有该道具
        f1 = BackpackHelper:removeGridItemByItemID(objid, itemid)
      end
      if (f1) then
        f2 = BackpackHelper:setGridItem(objid, gridid, itemid, num) -- 设置
      end
    end
  else -- 不同道具
    f3 = BackpackHelper:removeGridItemByItemID(objid, itemid)
    if (f3) then
      if (theItemid == 0) then -- 空
      else -- 有东西
        local emptyGridid = BackpackHelper:getFirstEmptyGrid(objid)
        if (emptyGridid) then -- 有空格子
          f4 = BackpackHelper:moveGridItem(objid, gridid, emptyGridid) -- 移动
        else -- 没有空格子
          f4 = GameDataHelper:discardOtherItem(objid, gridid) -- 丢弃
        end
      end
      if (f4) then
        f5 = BackpackHelper:setGridItem(objid, gridid, itemid, num) -- 设置
      end
    end
  end
  PlayerHelper:setItemDisableThrow(objid, itemid)
  return f1 and f2 and f3 and f4 and f5
end