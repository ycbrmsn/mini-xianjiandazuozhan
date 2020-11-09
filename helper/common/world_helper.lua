-- 世界工具类
WorldHelper = {
  PARTICLE_ID = {
    BOOM1 = 1007,
    BOOM16 = 1186 -- 爆炸16特效
  },
  SOUND_ID = {
    ACTION4 = 10007, -- 放置/破坏方块的声音
    ACTION5 = 10010, -- 放置/破坏方块的声音
    BE_ATTACK = 10102, -- 被攻击
    CLOSE_DOOR = 10652, -- 关门的声音id
    OPEN_DOOR = 10653 -- 开门的声音id
  },
  volume = 100,
  pitch = 1
}

-- 在指定位置上播放开门的声音
function WorldHelper:playOpenDoorSoundOnPos (pos, volume, pitch)
  return self:playSoundOnPos(pos, self.SOUND_ID.OPEN_DOOR, volume, pitch)
end

-- 在指定位置上播放关门的声音
function WorldHelper:playCloseDoorSoundOnPos (pos, volume, pitch)
  return self:playSoundOnPos(pos, self.SOUND_ID.CLOSE_DOOR, volume, pitch)
end

function WorldHelper:playBeAttackedSoundOnPos (pos, volume, pitch)
  return self:playSoundOnPos(pos, self.SOUND_ID.BE_ATTACK, volume, pitch)
end

-- 放置方块的声音
function WorldHelper:playPlaceBlockSoundOnPos (pos, volume, pitch)
  return self:playSoundOnPos(pos, self.SOUND_ID.ACTION5, volume, pitch)
end

-- 位置上播放声音
function WorldHelper:playSoundOnPos (pos, soundId, volume, pitch, isLoop)
  volume = volume or self.volume
  pitch = pitch or self.pitch
  self:playSoundEffectOnPos(pos, soundId, volume, pitch, isLoop)
end

-- 攻击特效
function WorldHelper:playAttackEffect (pos)
  return self:playBodyEffect(pos, self.PARTICLE_ID.BOOM1)
end

function WorldHelper:stopAttackEffect (pos)
  return self:stopBodyEffect(pos, self.PARTICLE_ID.BOOM1)
end

-- 击退特效
function WorldHelper:playRepelEffect (pos)
  return self:playBodyEffect(pos, self.PARTICLE_ID.BOOM16)
end

function WorldHelper:stopRepelEffect (pos)
  return self:stopBodyEffect(pos, self.PARTICLE_ID.BOOM16)
end

function WorldHelper:playBodyEffect (pos, particleId, scale)
  scale = scale or 1
  return self:playParticalEffect(pos.x, pos.y, pos.z, particleId, scale)
end

function WorldHelper:stopBodyEffect (pos, particleId)
  return self:stopEffectOnPosition(pos.x, pos.y, pos.z, particleId)
end

-- 指定地点播放特效然后关闭
function WorldHelper:playAndStopBodyEffectById (pos, particleId, scale, time)
  scale = scale or 1
  time = time or 3
  local posString = pos:toString()
  self:playParticalEffect(pos.x, pos.y, pos.z, particleId, scale)
  local t = posString .. 'stopPosEffect' .. particleId
  TimeHelper:callFnLastRun(posString, t, function ()
    self:stopEffectOnPosition(pos.x, pos.y, pos.z, particleId)
  end, time)
end

-- 通过起点与目的点生成投掷物
function WorldHelper:spawnProjectileByPos (shooter, itemid, pos, dst, speed)
  return WorldHelper:spawnProjectile(shooter, itemid, pos.x, pos.y, pos.z,
    dst.x, dst.y, dst.z, speed)
end

-- 通过起点与方向生成投掷物
function WorldHelper:spawnProjectileByDirPos (shooter, itemid, pos, dirVector3, speed)
  return self:spawnProjectileByDir(shooter, itemid, pos.x, pos.y, pos.z,
    dirVector3.x, dirVector3.y, dirVector3.z, speed)
end

-- 获取玩家附近的所有生物
function WorldHelper:getCreaturesAroundPos (pos, w, h)
  w, h = w or 60, h or 20
  local num, objids = WorldHelper:getActorsByBox(OBJ_TYPE.OBJTYPE_CREATURE, pos.x - w, pos.y - h, pos.z - w,
    pos.x + w, pos.y + h, pos.z + w)
  return objids
end

-- 封装原始接口

-- 生成生物
function WorldHelper:spawnCreature (x, y, z, actorid, actorCnt)
  return CommonHelper:callOneResultMethod(function (p)
    return World:spawnCreature(x, y, z, actorid, actorCnt)
  end, '生成生物', 'x=', x, ', y=', y, ', z=', z, ', actorid=', actorid,
    ', actorCnt=', actorCnt)
end

-- 移除生物
function WorldHelper:despawnCreature (objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return World:despawnCreature(objid)
  end, '移除生物', 'objid=', objid)
end

-- 在指定位置上播放音效
function WorldHelper:playSoundEffectOnPos (pos, soundId, volume, pitch, isLoop)
  return CommonHelper:callIsSuccessMethod(function (p)
    return World:playSoundEffectOnPos(pos, soundId, volume, pitch, isLoop)
  end, '在指定位置上播放音效', 'pos=', pos, ',soundId=', soundId, ',volume=',
    volume, ',pitch=', pitch, ',isLoop=', isLoop)
end

-- 停止指定位置上播放的音效
function WorldHelper:stopSoundEffectOnPos (pos, soundId)
  return CommonHelper:callIsSuccessMethod(function (p)
    return World:stopSoundEffectOnPos(pos, soundId)
  end, '停止指定位置上播放的音效', 'pos=', pos, ', soundId=', soundId)
end

-- 获取当前几点
function WorldHelper:getHours ()
  return CommonHelper:callOneResultMethod(function (p)
    return World:getHours()
  end, '获取当前几点')
end

-- 设置当前几点
function WorldHelper:setHours (hour)
  return CommonHelper:callIsSuccessMethod(function (p)
    return World:setHours(hour)
  end, '设置当前几点', 'hour=', hour)
end

-- 计算位置之间的距离
function WorldHelper:calcDistance (pos1, pos2)
  return World:calcDistance(pos1, pos2)
end

-- 在指定位置生成道具
function WorldHelper:spawnItem (x, y, z, itemId, itemCnt)
  return CommonHelper:callOneResultMethod(function (p)
    return World:spawnItem(x, y, z, itemId, itemCnt)
  end, '在指定位置生成道具', 'x=', x, ',y=', y, ',z=', z, ',itemId=', itemId,
    ',itemCnt=', itemCnt)
end

-- 在指定位置播放特效
function WorldHelper:playParticalEffect (x, y, z, particleId, scale)
  return CommonHelper:callIsSuccessMethod(function (p)
    return World:playParticalEffect(x, y, z, particleId, scale)
  end, '在指定位置播放特效', 'x=', x, ',y=', y, ',z=', z, ',particleId=',
    particleId, ',scale=', scale)
end

-- 停止指定位置的特效
function WorldHelper:stopEffectOnPosition (x, y, z, particleId)
  return CommonHelper:callIsSuccessMethod(function (p)
    return World:stopEffectOnPosition(x, y, z, particleId)
  end, '停止指定位置的特效', 'x=', x, ',y=', y, ',z=', z, ',particleId=', particleId)
end

-- 生成投掷物
function WorldHelper:spawnProjectile (shooter, itemid, x, y, z, dstx, dsty, dstz, speed)
  return CommonHelper:callOneResultMethod(function (p)
    return World:spawnProjectile(shooter, itemid, x, y, z, dstx, dsty, dstz, speed)
  end, '生成投掷物', 'shooter=', shooter, ',itemid=', itemid, ',x=', x, ',y=',
    y, ',z=', z, ',dstx=', dstx, ',dsty=', dsty, ',dstz=', dstz, ',speed=', speed)
end

-- 生成投掷物(通过方向)
function WorldHelper:spawnProjectileByDir (shooter, itemid, x, y, z, dirx, diry, dirz, speed)
  return CommonHelper:callOneResultMethod(function (p)
    return World:spawnProjectileByDir(shooter, itemid, x, y, z, dirx, diry, dirz, speed)
  end, '生成投掷物', 'shooter=', shooter, ',itemid=', itemid, ',x=', x, ',y=',
    y, ',z=', z, ',dirx=', dirx, ',diry=', diry, ',dirz=', dirz, ',speed=', speed)
end

-- 移除actor
function WorldHelper:despawnActor (objid)
  return CommonHelper:callIsSuccessMethod(function (p)
    return World:despawnActor(objid)
  end, '移除actor', 'objid=', objid)
end

-- 获取范围内actor，返回数量和objid数组
function WorldHelper:getActorsByBox (objtype, x1, y1, z1, x2, y2, z2)
  return CommonHelper:callTwoResultMethod(function (p)
    return World:getActorsByBox(objtype, x1, y1, z1, x2, y2, z2)
  end, '获取范围内actor', 'objtype=', objtype, ',x1=', x1, ',y1=', y1, ',z1=',
    z1, ',x2=', x2, ',y2=', y2, ',z2=', z2)
end