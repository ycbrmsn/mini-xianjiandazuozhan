-- 剧情工具类
StoryHelper = {
  mainIndex = 1,
  mainProgress = 1,
  progressNames = {},
  storyRemainDays = 0, -- 当前剧情剩余天数
  stories = {}
}

-- 剧情前进
function StoryHelper:forward (progressName, isBranch)
  if (self:isProgressNameExist(progressName)) then
    return
  end
  if (isBranch) then -- 支线，暂未设计
    
  else
    table.insert(self.progressNames, progressName)
    self.mainProgress = self.mainProgress + 1
    if (self.mainProgress > #self.stories[self.mainIndex].tips) then
      self.mainIndex = self.mainIndex + 1
      self.mainProgress = 1
    end
    local hostPlayer = PlayerHelper:getHostPlayer()
    GameDataHelper:updateGameData(hostPlayer)
  end
  if (logPaper) then -- 如果存在日志说明，则更新状态
    logPaper.isChange = true
  end
end

-- 剧情进度名是否存在
function StoryHelper:isProgressNameExist (progressName)
  for i, v in ipairs(self.progressNames) do
    if (v == progressName) then
      return true
    end
  end
  return false
end

-- 获得主线剧情序号
function StoryHelper:getMainStoryIndex ()
  return self.mainIndex
end

-- 更新主线剧情序号
function StoryHelper:setMainStoryIndex (mainIndex)
  self.mainIndex = mainIndex
end

-- 获得主线剧情进度序号
function StoryHelper:getMainStoryProgress ()
  return self.mainProgress
end

-- 更新主线剧情进度序号
function StoryHelper:setMainStoryProgress (mainProgress)
  self.mainProgress = mainProgress
end

-- 获得剩余剧情天数（目前弃用）
function StoryHelper:getMainStoryRemainDays ()
  return self.storyRemainDays
end

-- 获得主线剧情信息
function StoryHelper:getMainStoryInfo ()
  return self.stories[self:getMainStoryIndex()]
end

-- 获得剧情标题和内容
function StoryHelper:getMainStoryTitleAndTip ()
  local story = self:getMainStoryInfo()
  return story.title, story.tips[self:getMainStoryProgress()]
end

-- 减少剩余天数（目前弃用）
function StoryHelper:reduceRemainDay ()
  if (self.storyRemainDays > 0) then
    self.storyRemainDays = self.storyRemainDays - 1
  end
end

-- 获取剧情
function StoryHelper:getStory (index)
  index = index or self:getMainStoryIndex()
  return self.stories[index]
end

-- 新增剧情
function StoryHelper:addStory (story)
  table.insert(self.stories, story)
end

-- 设置剧情
function StoryHelper:setStorys (stories)
  self.stories = stories
end

-- 玩家重新进入游戏时恢复剧情
function StoryHelper:recover (player)
  if (#self.stories == 0) then
    MyStoryHelper:init()
  end
  local story = self:getStory()
  if (story) then -- 如果存在剧情
    story:recover(player)
  end
end

-- 事件

-- 世界时间到[n]点
function StoryHelper:atHour (hour)
  if (hour == 0) then
    self:reduceRemainDay()
  end
end