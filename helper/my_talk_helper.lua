-- 我的对话工具类
MyTalkHelper = {
  needRemoveTasks = { 11, 12 }
}

-- 显示对话结束分隔
function MyTalkHelper:showEndSeparate (objid)
  TalkHelper:removeTasks(objid, self.needRemoveTasks)
  ChatHelper:showEndSeparate(objid)
end

-- 显示对话中止分隔
function MyTalkHelper:showBreakSeparate (objid)
  TalkHelper:removeTasks(objid, self.needRemoveTasks)
  ChatHelper:showBreakSeparate(objid)
end