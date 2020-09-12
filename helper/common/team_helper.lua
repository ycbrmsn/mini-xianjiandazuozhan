-- 队伍工具类
TeamHelper = {}

-- 封装原始接口

function TeamHelper:getTeamScore (teamid)
  return CommonHelper:callOneResultMethod(function (p)
    return Team:getTeamScore(teamid)
  end, '获取组队分数', 'teamid=', teamid)
end

function TeamHelper:addTeamScore (teamid, score)
  return CommonHelper:callIsSuccessMethod(function (p)
    return Team:addTeamScore(teamid, score)
  end, '增加队伍分数', 'teamid=', teamid, ',score=', score)
end