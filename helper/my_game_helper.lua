-- 我的游戏工具类
MyGameHelper = {
  announce = '公告',
  isAnnounceOpen = false
}

function MyGameHelper:setGBattleUI ()
  local player = MyStoryHelper.winPlayer
  if (player) then
    local color = TeamHelper:getTeamColor(player.objid) or '#G'
    UIHelper:setLeftDesc('经过努力，', color, player:getName(), '#n成功回到了现实')
    UIHelper:setLeftLittleDesc('击败玩家：', player.killPlayerNum)
    UIHelper:setRightLittleDesc('击败生物：', player.KillMonsterNum)
    local title
    if (player.killPlayerNum == 0 and player.KillMonsterNum == 0) then
      title = '和平爱好者'
    elseif (player.killPlayerNum > player.KillMonsterNum) then
      title = '玩家终结者'
    else
      title = '动物残虐者'
    end
    UIHelper:setLeftTitle('获得称号：')
    UIHelper:setRightTitle(title)
  end
end

-- 显示更新内容
function MyGameHelper:showUpdateContent (objid)
  TimeHelper:callFnFastRuns(function ()
    local contents = {
      'v1.6.0更新内容：\t\t\t\t\t\t\t\t\t\t',
      '\t\t1.商店新增道具：时间轮盘。\t\t\t',
      '\t\t2.调整了回天剑诀的效果，不会攻击',
      '无所事事的生物。\t\t\t\t\t\t\t\t\t\t',
      '\t\t3.调整了升级后增加的属性。\t\t\t',
      '\t\t4.增加了一些对话与说明。\t\t\t\t',
      '如果有好的建议可以来社区里留言，在触',
      '发器玩法大全圈子里很容易可以找到我。'
    }
    for i, v in ipairs(contents) do
      ChatHelper:sendMsg(objid, v)
    end
  end, 1, objid .. 'showUpdateContent')
end

-- 事件

-- 开始游戏
function MyGameHelper:startGame ()
  GameHelper:startGame()
  MyBlockHelper:init()
  MyMonsterHelper:init()
  MyAreaHelper:init()
  MyActorHelper:init()
  -- body
  TimeHelper:setHour(MyMap.CUSTOM.INIT_HOUR)
end

-- 游戏运行时
function MyGameHelper:runGame ()
  GameHelper:runGame()
end

-- 结束游戏
function MyGameHelper:endGame ()
  GameHelper:endGame()
  -- body
  MyGameHelper:setGBattleUI()
end

-- 世界时间到[n]点
function MyGameHelper:atHour (hour)
  GameHelper:atHour(hour)
  MyStoryHelper:atHour(hour)
end

-- 世界时间到[n]秒
function MyGameHelper:atSecond (second)
  GameHelper:atSecond(second)
  -- body
  if (second == 1) then
    -- local player = PlayerHelper:getHostPlayer()
    -- player:setPosition(3, 9, 43)
  end
end

-- 任意计时器发生变化
function MyGameHelper:minitimerChange (timerid, timername)
  GameHelper:minitimerChange(timerid, timername)
end