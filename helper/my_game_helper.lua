-- 我的游戏工具类
MyGameHelper = {
  announce = '公告',
  isAnnounceOpen = false
}

function MyGameHelper.setGBattleUI ()
  local player = MyStoryHelper.winPlayer
  if (player) then
    local color = TeamHelper.getTeamColor(player.objid) or '#G'
    UIHelper.setLeftDesc('经过努力，', color, player:getName(), '#n成功回到了现实')
    UIHelper.setLeftLittleDesc('击败玩家：', player.killPlayerNum)
    UIHelper.setRightLittleDesc('击败生物：', player.KillMonsterNum)
    local title
    if (player.killPlayerNum == 0 and player.KillMonsterNum == 0) then
      title = '和平爱好者'
    elseif (player.killPlayerNum > player.KillMonsterNum) then
      title = '玩家终结者'
    else
      title = '动物残虐者'
    end
    UIHelper.setLeftTitle('获得称号：')
    UIHelper.setRightTitle(title)
  end
end

-- 显示更新内容
function MyGameHelper.showUpdateContent (objid)
  TimeHelper.callFnFastRuns(function ()
    -- local contents = {
    --   'v1.6.2更新内容：\t\t\t\t\t\t\t\t\t\t',
    --   '\t\t1.修复零时报错与消耗道具报错问题',
    --   '。\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t',
    --   '如果有好的建议可以来社区里留言，在触',
    --   '发器玩法大全圈子里可以很容易找到我。'
    -- }
    local contents = {
      'v1.7.0更新内容：\t\t\t\t\t\t\t\t\t\t',
      '\t\t1.新增乱仙剑。\t\t\t\t\t\t\t\t\t',
      '\t\t2.缩短了所有仙剑的技能冷却时间。',
      '\t\t3.稍微增加了回天剑诀的伤害。\t\t',
    }
    for i, v in ipairs(contents) do
      ChatHelper.sendMsg(objid, v)
    end
  end, 1, objid .. 'showUpdateContent')
end

-- 事件

-- 开始游戏
EventHelper.addEvent('startGame', function ()
  TimeHelper.setHour(MyMap.CUSTOM.INIT_HOUR)
end)

-- 结束游戏
EventHelper.addEvent('endGame', function ()
  MyGameHelper.setGBattleUI()
end)
