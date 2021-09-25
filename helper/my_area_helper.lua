-- 我的区域工具类
MyAreaHelper = {
  luoyecunPos = MyPosition:new(0, 8, 19), -- 落叶村位置
  pingfengzhaiPos = MyPosition:new(-363, 8, 556), -- 平风寨位置
  doorPositionData = {
    -- { 16, 8, -2 }, -- 林千树门1
    -- { 15, 8, -2 }, -- 林千树门2
    -- { -3, 8, -2 }, -- 叶小龙门1
    -- { -4, 8, -2 }, -- 叶小龙门2
    -- { -8, 8, 87 }, -- 林万树门1
    -- { -7, 8, 87 }, -- 林万树门2
    -- { 11, 8, 87 }, -- 叶大龙门1
    -- { 12, 8, 87 } -- 叶大龙门2
  },
  doorPositions = {}
}

-- 初始化
function MyAreaHelper.init ()
  MyAreaHelper.initDoorAreas()
  MyAreaHelper.initShowToastAreas()
  -- body
end

-- 初始化显示飘窗区域
function MyAreaHelper.initShowToastAreas ()
  local arr = {}
  for i, v in ipairs(arr) do
    if (v.generate) then -- 如果需要生成怪物
      AreaHelper.addToastArea(v.areaids[2], { v.areaids[1], v.areaName, v.generate })
    else
      AreaHelper.addToastArea(v.areaids[2], { v.areaids[1], v.areaName })
    end
  end
end

-- 初始化所有actor可打开的门的位置
function MyAreaHelper.initDoorAreas ()
  for i, v in ipairs(MyAreaHelper.doorPositionData) do
    local pos = MyPosition:new(v[1], v[2], v[3])
    local areaid = AreaHelper.getAreaByPos(pos)
    AreaHelper.allDoorAreas[areaid] = pos
    -- table.insert(AreaHelper.allDoorAreas, areaid, pos)
  end
end

-- 获取所有的门位置
function MyAreaHelper.getDoorPositions ()
  return MyAreaHelper.doorPositions
end
