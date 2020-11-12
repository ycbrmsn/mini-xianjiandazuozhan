-- 我的对话工具类
MyTalkHelper = {
  needRemoveTasks = { 11, 12, 13, 14, 21, 2100, 2101, 22, 2200, 2201, 23, 2300, 2301,
    24, 2400, 2401, 25, 2500, 2501, 26, 2600, 2601, 27, 2700, 2701, 28, 2800, 2801,
    29, 2900, 2901, 30, 3000, 3001, 31, 3100, 3101, 32, 3200, 3201, 5100, 5101 }
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
