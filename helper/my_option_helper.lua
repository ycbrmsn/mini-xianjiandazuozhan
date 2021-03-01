-- 我的选项工具类
MyOptionHelper = {
  optionMap = {
    index = {
      { '游戏简介', function (player)
          local contents = {
            '游戏简介：\t\t\t\t\t\t\t\t\t\t\t\t\t',
            '\t\t你需要与人物对话，了解这个世界。',
          }
          for i, v in ipairs(contents) do
            ChatHelper.sendMsg(player.objid, v)
          end
          ChatHelper.sendMsg(player.objid, '')
          MyOptionHelper.showOptions(player, 'back')
        end
      },
      { '任务查询', function (player)
          local tasks = {}
          for taskid, task in pairs(TaskHelper.getActiveTasks(player.objid)) do
            table.insert(tasks, task)
          end
          if (#tasks == 0) then
            ChatHelper.sendMsg(player.objid, '你目前身上没有任务。')
            MyOptionHelper.showOptions(player, 'back')
          else
            MyOptionHelper.setTaskOption(player, tasks)
            MyOptionHelper.showOptions(player, player.objid .. '')
          end
        end
      },
      { '更新日志', function (player)
          MyOptionHelper.showOptions(player, 'logs')
        end
      },
      { '退出', function (player)
          player.whichChoose = nil
          ChatHelper.sendMsg(player.objid, '您关闭了手册')
        end
      },
    },
    logs = { -- 离开选项
      { 'v1.7.0', function (player)
          local contents = {
            'v1.7.0更新内容：\t\t\t\t\t\t\t\t\t\t',
            '\t\t1.新增乱仙剑。\t\t\t\t\t\t\t\t\t',
            '\t\t2.缩短了所有仙剑的技能冷却时间。',
            '\t\t3.稍微增加了回天剑诀的伤害。\t\t',
          }
          for i, v in ipairs(contents) do
            ChatHelper.sendMsg(player.objid, v)
          end
          MyOptionHelper.showOptions(player, 'back')
        end
      },
      { 'v1.8.0', function (player)
          local contents = {
            'v1.8.0更新内容：\t\t\t\t\t\t\t\t\t\t',
            '\t\t1.新增瞬仙剑。\t\t\t\t\t\t\t\t\t',
            '\t\t2.新增回仙剑收回环绕飞剑的功能。',
            '\t\t3.缩短了气仙剑的技能效果时长。\t',
            '\t\t4.所有仙剑技能对怪物造成的伤害翻',
            '倍。所有怪物提高了伤害。\t\t\t\t\t\t',
            '\t\t5.替换了所有剧情插件。\t\t\t\t\t',
          }
          for i, v in ipairs(contents) do
            ChatHelper.sendMsg(player.objid, v)
          end
          MyOptionHelper.showOptions(player, 'back')
        end
      },
      { 'v1.9.0', function (player)
          local contents = {
            'v1.9.0更新内容：\t\t\t\t\t\t\t\t\t\t',
            '\t\t1.新增囚仙剑。\t\t\t\t\t\t\t\t\t',
          }
          for i, v in ipairs(contents) do
            ChatHelper.sendMsg(player.objid, v)
          end
          MyOptionHelper.showOptions(player, 'back')
        end
      },
      { '返回', function (player)
          MyOptionHelper.showOptions(player, 'index')
        end
      },
    },
    back = {
      { '返回', function (player)
          MyOptionHelper.showOptions(player, 'index')
        end
      },
    }
  }
}

-- 显示选项
function MyOptionHelper.showOptions (player, optionname)
  local arr = MyOptionHelper.optionMap[optionname]
  ChatHelper.showChooseItems(player.objid, arr, 1)
  player.whichChoose = optionname
end

-- 设置选项
function MyOptionHelper.setOption (optionname, chooseItems)
  MyOptionHelper.optionMap[optionname] = chooseItems
end

-- 设置任务选项
function MyOptionHelper.setTaskOption (player, tasks)
  local chooseItems = {}
  for taskid, task in ipairs(tasks) do
    table.insert(chooseItems, {
      task.name .. '任务',
      function (player)
        task:show(player.objid)
        MyOptionHelper.showOptions(player, 'back')
      end
    })
  end
  table.insert(chooseItems, {
    '返回',
    function (player)
      MyOptionHelper.showOptions(player, 'index')
    end
  })
  MyOptionHelper.setOption(player.objid .. '', chooseItems)
end