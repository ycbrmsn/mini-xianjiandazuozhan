-- 缓存工具类
CacheHelper = {
  positions = {
    frame = 0, -- 对应TimeHelper中的frame
    objids = {}, -- objiid -> MyPosition
  }
}

-- 获取位置
function CacheHelper.getMyPosition (objid)
  local positions = CacheHelper.positions
  local frame = TimeHelper.getFrame()
  if (positions.frame ~= frame) then -- 不是同一帧的数据了
    positions.frame = frame
    positions.objids = {}
  end
  local pos = positions.objids[objid]
  if (type(pos) == 'nil') then -- 未缓存
    pos = ActorHelper.getMyPosition(objid)
    -- LogHelper.debug('缓存：', pos)
    if (pos) then -- 找到位置
      positions.objids[objid] = pos
    else -- 未找到时缓存-1
      positions.objids[objid] = -1
    end
  elseif (type(pos) == 'number') then -- 缓存不存在位置
    return nil
  end
  return pos
end

-- 获取位置
function CacheHelper.getPosition (objid)
  local pos = CacheHelper.getMyPosition(objid)
  if (pos) then
    return pos.x, pos.y, pos.z
  end
end

-- 移除角色，清除缓存
function CacheHelper.despawnActor (objid)
  WorldHelper.despawnActor(objid)
  -- 清除缓存
  local positions = CacheHelper.positions
  local frame = TimeHelper.getFrame()
  if (positions.frame == frame) then -- 是同一帧的数据了
    if (positions.objids) then
      positions.objids[objid] = nil
    end
  end
end