-- 游戏数据工具类
GameDataHelper = {}

-- 更新剧情数据
function GameDataHelper:updateStoryData ()
  local player = PlayerHelper:getHostPlayer()
  local mainIndex = BackpackHelper:getItemNumAndGrid(player.objid, MyMap.ITEM.GAME_DATA_MAIN_INDEX_ID)
  local mainProgress = BackpackHelper:getItemNumAndGrid(player.objid, MyMap.ITEM.GAME_DATA_MAIN_PROGRESS_ID)
  if (mainIndex == 0) then -- 游戏刚开始
    self:updateMainIndex()
    self:updateMainProgress()
    return false
  else -- 再次回到游戏
    StoryHelper:setMainStoryIndex(mainIndex)
    StoryHelper:setMainStoryProgress(mainProgress)
    return true
  end
end

-- 更新玩家数据，目前废弃
function GameDataHelper:updatePlayerData (player)
  local level = BackpackHelper:getItemNumAndGrid(player.objid, MyMap.ITEM.GAME_DATA_LEVEL_ID)
  local exp = (level - 1) * 100 + 
      BackpackHelper:getItemNumAndGrid(player.objid, MyMap.ITEM.GAME_DATA_EXP_ID)
  if (level == 0) then -- 刚进入游戏
    self:updateLevel(player)
    self:updateExp(player)
    return false
  else -- 再次回到游戏
    player:setLevel(level)
    player:setExp(exp)
    return true
  end
end

-- 更新主线剧情序号道具
function GameDataHelper:updateMainIndex ()
  local player = PlayerHelper:getHostPlayer()
  local itemid = MyMap.ITEM.GAME_DATA_MAIN_INDEX_ID
  local gridid = 28
  local num = StoryHelper:getMainStoryIndex()
  self:updateDataItem(player.objid, itemid, gridid, num)
end

-- 更新主线剧情进度道具
function GameDataHelper:updateMainProgress ()
  local player = PlayerHelper:getHostPlayer()
  local itemid = MyMap.ITEM.GAME_DATA_MAIN_PROGRESS_ID
  local gridid = 29
  local num = StoryHelper:getMainStoryProgress()
  self:updateDataItem(player.objid, itemid, gridid, num)
end

-- 更新玩家等级道具，目前废弃
function GameDataHelper:updateLevel (player)
  local itemid = MyMap.ITEM.GAME_DATA_LEVEL_ID
  local gridid = 28
  local num = player:getLevel()
  self:updateDataItem(player.objid, itemid, gridid, num)
end

-- 更新玩家经验道具，目前废弃
function GameDataHelper:updateExp (player)
  local itemid = MyMap.ITEM.GAME_DATA_EXP_ID
  local gridid = 29
  local num = player:getExp() % 100
  self:updateDataItem(player.objid, itemid, gridid, num)
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
  -- self:updateLevel(player)
  -- self:updateExp(player)
end

function GameDataHelper:updateDataItem (objid, itemid, gridid, num)
  local curNum, arr1, arr2 = BackpackHelper:getItemNumAndGrid(objid, itemid)
  if (num == curNum) then
    return
  end
  if (num < curNum) then -- 减少
    BackpackHelper:removeGridItemByItemID(objid, itemid, curNum - num)
  else -- 增加
    if (curNum == 0) then -- 当前一件都没有
      self:discardOtherItem(objid, gridid)
      BackpackHelper:setGridItem(objid, gridid, itemid, num)
      PlayerHelper:setItemDisableThrow(objid, itemid)
    else -- 已经有了
      if (#arr1 > 0) then
        gridid = arr1[1]
      else
        gridid = arr2[1]
      end
      local gridNum = BackpackHelper:getGridNum(objid, gridid)
      BackpackHelper:setGridItem(objid, gridid, itemid, num - curNum + gridNum)
    end
  end
end