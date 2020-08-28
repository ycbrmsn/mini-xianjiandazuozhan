-- 音乐工具类
MusicHelper = {
  musicid = 10773, -- 电子音
  low = { 0.5, 0.525, 0.55, 0.6, 0.625, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95 }, -- 12个低音
  middle = { 1, 1.05, 1.1, 1.2, 1.25, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9 }, -- 12个中音
  high = { 2, 2.1, 2.2, 2.4, 2.5, 2.6, 2.8, 3.0, 3.2, 3.4, 3.6, 3.8 }, -- 12个高音
  -- { objid = { t = objid + 'playBGM', musicid = musicid, volumeIndex = idx, musicIndex = idx }}
  playerMusicInfos = {},
  volumes = { 0, 20, 40, 60, 80, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000 } -- 声音大小
  -- musicInfo = { -- 音乐信息例子
    -- 数组长度为1表示4分音符中音，四分音符第二位为1，八分音符为2。第三位“-”表示低音，“+”表示高音
  --   notes = { 1, 1, 5, 5, 6, 6, 5, '1,2,+' }, -- 音符、乘除数、高低中音
  --   delay = 0.4,
  --   method = 'mul' -- mul/div表示间隔时间是算乘法还是除法，默认是乘法，不同的乐曲用乘除法记录难度有所不同
  -- }
}

-- 解析noteInfo
function MusicHelper:parseNoteInfo (objid, noteInfos, index)
  local noteInfo = noteInfos[index]
  while (type(noteInfo) == 'number' and noteInfo > 10) do
    MusicHelper:changeMusicid(objid, noteInfo)
    index = index + 1
    noteInfo = noteInfos[index]
  end
  local arr = StringHelper:split(noteInfo, ',')
  local multiple = tonumber(arr[2]) or 1
  return MusicHelper:getNoteTimbre(arr[1], arr[3]), multiple, index
end

-- 获取音符的音色值 1、3、5、6、8、10、12
function MusicHelper:getNoteTimbre (note, category)
  local index, timbre = math.abs(tonumber(note))
  if (index < 4) then -- 123
    timbre = index * 2 - 1
  else --4567
    timbre = index * 2 - 2
  end
  if (#note == 2) then -- 低音
    timbre = timbre - 1
  end

  if (not(category)) then -- 中音
    return self.middle[timbre]
  elseif (category == '-') then -- 低音
    return self.low[timbre]
  else -- 高音
    return self.high[timbre]
  end
end

-- 播放一个音符
function MusicHelper:play (objid, pitch)
  if (pitch) then
    local info = self.playerMusicInfos[objid]
    PlayerHelper:playMusic(objid, info.musicid, self.volumes[info.volumeIndex], pitch)
    -- ActorHelper:playSoundEffectById(objid, self.musicid, 100, pitch)
  else
    -- PlayerHelper:stopMusic(objid) -- 因为会影响到其他声音，就先注释掉
  end
  return multiple
end

-- 播放自定义背景音乐
function MusicHelper:playBGM (objid, musicInfo, isLoop, index, delay)
  index = index or 1
  delay = delay or 1
  TimeHelper:callFnFastRuns(function ()
    local pos = ActorHelper:getMyPosition(objid)
    if (pos) then
      if (index > #musicInfo.notes and isLoop) then -- 循环播放
        index = 1
      end
      if (index <= #musicInfo.notes) then
        local pitch, multiple, index = MusicHelper:parseNoteInfo(objid, musicInfo.notes, index)
        local nextDelay
        if (not(musicInfo.method) or musicInfo.method == 'mul') then
          nextDelay = musicInfo.delay * multiple
        else
          nextDelay = musicInfo.delay / multiple
        end
        MusicHelper:playBGM(objid, musicInfo, isLoop, index + 1, nextDelay)
        MusicHelper:play(objid, pitch)
      end
    end
  end, delay, objid .. 'playBGM')
end

-- 开始播放背景音乐
function MusicHelper:startBGM (objid, musicIndex, isLoop, isOverride)
  MusicHelper:initInfoIfNotExist(objid, isOverride)
  self.playerMusicInfos[objid].musicIndex = musicIndex
  self.playerMusicInfos[objid].t = objid .. 'playBGM'
  local musicInfo = BGM[musicIndex]
  MusicHelper:playBGM(objid, musicInfo, isLoop)
end

-- 停止播放背景音乐
function MusicHelper:stopBGM (objid)
  TimeHelper:delFnFastRuns(objid .. 'playBGM')
end

-- 更换背景音乐
function MusicHelper:changeBGM (objid, musicIndex, isLoop, isOverride)
  MusicHelper:stopBGM(objid)
  MusicHelper:startBGM(objid, musicIndex, isLoop, isOverride)
end

-- 不存在信息则初始化一个，第二个参数为是否覆盖
function MusicHelper:initInfoIfNotExist (objid, isOverride)
  if (not(self.playerMusicInfos[objid]) or isOverride) then
    -- 默认电子音，音量100
    self.playerMusicInfos[objid] = { t = objid .. 'playBGM', musicid = 10773,
      volumeIndex = 6, musicIndex = 1 }
  end
end

-- 调节音乐音量
function MusicHelper:modulateVolume (objid, change)
  MusicHelper:initInfoIfNotExist(objid)
  self.playerMusicInfos[objid].volumeIndex = self.playerMusicInfos[objid].volumeIndex + change
  if (self.playerMusicInfos[objid].volumeIndex <= 1) then
    self.playerMusicInfos[objid].volumeIndex = 1
    ChatHelper:sendMsg(objid, '音乐音量已调到最小')
  elseif (self.playerMusicInfos[objid].volumeIndex >= #self.volumes) then
    self.playerMusicInfos[objid].volumeIndex = #self.volumes
    ChatHelper:sendMsg(objid, '音乐音量已调到最大')
  else
    if (change > 0) then
      ChatHelper:sendMsg(objid, '音乐音量变大')
    else
      ChatHelper:sendMsg(objid, '音乐音量变小')
    end
  end
end

-- 改变音色
function MusicHelper:changeMusicid (objid, musicid)
  MusicHelper:initInfoIfNotExist(objid)
  self.playerMusicInfos[objid].musicid = musicid
end