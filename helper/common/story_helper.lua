-- 剧情工具类
StoryHelper = {
  mainIndex = 1,
  mainProgress = 1,
  stories = {},
  initKey = {}, -- 剧情重新加载时校验使用
  alreadyLoad = false, -- 是否已经加载了
}

-- 检查剧情前置条件是否满足
function StoryHelper.check (mainIndex, mainProgress)
  mainProgress = StoryHelper.getRealProgress(mainProgress)
  return mainIndex == StoryHelper.mainIndex and mainProgress == StoryHelper.mainProgress
end

-- 剧情前进 两个progress都是要跳到剧情的前置
function StoryHelper.forward (mainIndex, mainProgress, endProgress)
  if (StoryHelper.forward2(mainIndex, mainProgress, endProgress)) then
    local hostPlayer = PlayerHelper.getHostPlayer()
    GameDataHelper.updateGameData(hostPlayer)
    return true
  else
    return false
  end
end

-- 剧情前进，不更新剧情数据道具
function StoryHelper.forward2 (mainIndex, mainProgress, endProgress)
  if (not(StoryHelper.check(mainIndex, mainProgress))) then
    return false
  end
  StoryHelper.setLoad(true)
  if (endProgress) then
    endProgress = StoryHelper.getRealProgress(endProgress)
    StoryHelper.mainProgress = endProgress + 1
  else
    StoryHelper.mainProgress = StoryHelper.mainProgress + 1
  end
  if (StoryHelper.mainProgress > #StoryHelper.stories[StoryHelper.mainIndex].tips) then
    StoryHelper.mainIndex = StoryHelper.mainIndex + 1
    StoryHelper.mainProgress = 1
  end
  return true
end

-- 剧情跳转
function StoryHelper.goTo (mainIndex, mainProgress)
  StoryHelper.mainIndex = mainIndex
  StoryHelper.mainProgress = mainProgress
end

-- 获得实际进度序数
function StoryHelper.getRealProgress (progress)
  if (type(progress) == 'string') then -- 是别名
    local story = StoryHelper.getStory(mainIndex)
    progress = story:getProgressPrepose(progress) or -1 -- 找不到就-1
  end
  return progress
end

-- 获得主线剧情序号
function StoryHelper.getMainStoryIndex ()
  return StoryHelper.mainIndex
end

-- 更新主线剧情序号
function StoryHelper.setMainStoryIndex (mainIndex)
  StoryHelper.mainIndex = mainIndex
end

-- 获得主线剧情进度序号
function StoryHelper.getMainStoryProgress ()
  return StoryHelper.mainProgress
end

-- 更新主线剧情进度序号
function StoryHelper.setMainStoryProgress (mainProgress)
  StoryHelper.mainProgress = mainProgress
end

-- 获得主线剧情序号与进度号
function StoryHelper.getIndexAndProgress ()
  return StoryHelper.getMainStoryIndex(), StoryHelper.getMainStoryProgress()
end

-- 获得剧情标题和内容
function StoryHelper.getMainStoryTitleAndTip (index, progress)
  progress = progress or StoryHelper.getMainStoryProgress()
  LogHelper.debug(index, '-', progress)
  local story = StoryHelper.getStory(index)
  return story.title, story.tips[progress]
end

-- 获取剧情
function StoryHelper.getStory (index)
  index = index or StoryHelper.getMainStoryIndex()
  return StoryHelper.stories[index]
end

-- 新增剧情
function StoryHelper.addStory (story)
  table.insert(StoryHelper.stories, story)
end

-- 获取所有剧情
function StoryHelper.getStorys ()
  return StoryHelper.stories
end

-- 设置剧情
function StoryHelper.setStorys (stories)
  StoryHelper.stories = stories
end

-- 剧情对应的任务id
function StoryHelper.getStoryTaskid (index, progress)
  return index * 100 + progress
end

-- 玩家重新进入游戏时恢复剧情
function StoryHelper.recover (player)
  if (#StoryHelper.stories == 0) then
    MyStoryHelper.init()
  end
  if (player) then -- 非初始化剧情
    if (PlayerHelper.isMainPlayer(player.objid)) then -- 房主
      local story = StoryHelper.getStory()
      if (story) then -- 如果存在剧情
        if (StoryHelper.isLoad()) then
          return false
        else
          StoryHelper.setLoad(true)
          for i, v in ipairs(PlayerHelper.getActivePlayers()) do
            story:recover(v)
            ChatHelper.sendMsg(v.objid, '游戏进度加载完成')
          end
          return true
        end
      end
    else -- 房客
      local story = StoryHelper.getStory()
      if (story) then -- 如果存在剧情
        story:recover(player)
      end
    end
  end
  
end

-- 剧情是否已经加载过
function StoryHelper.isLoad ()
  return StoryHelper.alreadyLoad
end

-- 设置剧情加载情况
function StoryHelper.setLoad (isLoad)
  StoryHelper.alreadyLoad = isLoad
end

-- 显示初始化剧情错误
function StoryHelper.showInitError (key, name)
  key = key or 'defaultInitKey'
  name = name or '必需角色'
  StoryHelper.initKey[key] = StoryHelper.initKey[key] or 1
  if (StoryHelper.initKey[key] % 30 == 5) then
    ChatHelper.sendMsg(nil, '地图错误：', name, '未找到，找到', name, '后方可继续后续剧情')
  end
  StoryHelper.initKey[key] = StoryHelper.initKey[key] + 1
end

-- 进入未加载提示
function StoryHelper.loadTip (objid, seconds)
  seconds = seconds or 30
  if (not(StoryHelper.isLoad())) then
    ChatHelper.sendMsg(objid, '当前游戏进度未加载，请加载进度')
    TimeHelper.callFnAfterSecond(function ()
      StoryHelper.loadTip(objid, seconds)
    end, seconds)
  end
end

-- 事件

-- 世界时间到[n]点
function StoryHelper.atHour (hour)
  -- body
end