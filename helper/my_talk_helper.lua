-- 我的对话工具类
MyTalkHelper = {
  needRemoveTasks = { 11, 12, 13, 14, 21, 22, 23, 24, 2100, 2101, 2200, 2201, 2300, 2301,
    2400, 2401, 2500, 2501, 2600, 2601, 2700, 2701, 2800, 2801, 2900, 2901, 3000, 3001,
    3100, 3101, 3200, 3201, 5100, 5101 }
}

-- 显示对话结束分隔
function MyTalkHelper:showEndSeparate (objid)
  TaskHelper:removeTasks(objid, self.needRemoveTasks)
  ChatHelper:showEndSeparate(objid)
end

-- 显示对话中止分隔
function MyTalkHelper:showBreakSeparate (objid)
  TaskHelper:removeTasks(objid, self.needRemoveTasks)
  ChatHelper:showBreakSeparate(objid)
end
