-- 队伍工具类
TeamHelper = {
  teamColor = { [0] = '#ceeeeee', [1] = '#R', [2] = '#B', [3] = '#G', [4] = '#Y', [5] = '#O', [6] = '#P' }
}

-- 获取玩家的队伍颜色
function TeamHelper:getTeamColor (objid)
  local teamid = PlayerHelper:getTeam(objid)
  if (teamid) then
    return self.teamColor[teamid]
  else
    return nil
  end
end

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