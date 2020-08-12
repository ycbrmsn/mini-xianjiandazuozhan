-- 音乐工具类
MusicHelper = {
  musicid = 10773, -- 电子音
  low = { 0.5, 0.525, 0.55, 0.6, 0.625, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95 }, -- 12个低音
  middle = { 1, 1.05, 1.1, 1.2, 1.25, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9 }, -- 12个中音
  high = { 2, 2.1, 2.2, 2.4, 2.5, 2.6, 2.8, 3.0, 3.2, 3.4, 3.6, 3.8 }, -- 12个高音
  lowNotes = {}, -- 一共7个低音符
  middleNotes = {}, -- 一共7个中音符
  highNotes = {} -- 一共7个高音符
  -- musicInfo = { -- 音乐信息例子
    -- 数组长度为1表示4分音符中音，四分音符第二位为1，八分音符为2。第三位“-”表示低音，“+”表示高音
  --   notes = { { 1, 1, '-' }, { 1 }, { 5 }, { 5, 3 }, { 6, 3 }, { 6, 3 }, { 5, 3 } }, -- 音符/除数/高低中音
  --   delay = 0.4
  -- }
}

-- 解析noteInfo
function MusicHelper:parseNoteInfo (noteInfo)
  local arr = StringHelper:split(noteInfo, ',')
  local multiply = tonumber(arr[2]) or 1
  return MusicHelper:getNoteTimbre(arr[1], arr[3]), multiply
end

-- 获取音符的音色值
function MusicHelper:getNoteTimbre (note, category)
  if (#self.lowNotes == 0) then -- 如果未初始化则初始化
    for i = 1, 12 do
      if (i == 1 or i == 3 or i == 5 or i == 6 or i == 8 or i == 10 or i == 12) then
        table.insert(self.lowNotes, self.low[i])
        table.insert(self.middleNotes, self.middle[i])
        table.insert(self.highNotes, self.high[i])
      end
    end
  end
  local index = tonumber(note)
  if (not(category)) then -- 中音
    return self.middleNotes[index]
  elseif (category == '-') then -- 低音
    return self.lowNotes[index]
  else -- 高音
    return self.highNotes[index]
  end
end

-- 播放一个音符
function MusicHelper:play (objid, noteInfo)
  local pitch, multiply = MusicHelper:parseNoteInfo(noteInfo)
  if (pitch) then
    PlayerHelper:playMusic(objid, self.musicid, 100, pitch)
  else
    PlayerHelper:stopMusic(objid)
  end
  return multiply
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
        local multiply = MusicHelper:play(objid, musicInfo.notes[index])
        MusicHelper:playBGM(objid, musicInfo, isLoop, index + 1, musicInfo.delay * multiply)
      end
    end
  end, delay, objid .. 'playBGM')
end

-- 停止播放背景音乐
function MusicHelper:stopBGM (objid)
  TimeHelper:delFnFastRuns(objid .. 'playBGM')
end