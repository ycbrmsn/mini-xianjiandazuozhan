-- 我的对话工具类
MyTalkHelper = {
  needRemoveTasks = { 11, 12, 13, 14, 21, 22, 23, 24, 2100, 2101 }
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
