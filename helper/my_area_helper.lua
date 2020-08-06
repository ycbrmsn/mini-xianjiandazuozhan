-- 我的区域工具类
MyAreaHelper = {
  luoyecunPos = MyPosition:new(0, 8, 19), -- 落叶村位置
  pingfengzhaiPos = MyPosition:new(-363, 8, 556), -- 平风寨位置
  doorPositionData = {
    { 31, 8, 2 }, -- 主角家的门
    { 9, 8, -21 }, -- 江枫家的门
    { -13, 8, -21 }, -- 村长家的门
    { -12, 8, -21 }, -- 村长家的门
    { -30, 8, -22 }, -- 苗兰家一楼的门
    { -30, 13, -21 }, -- 苗兰家二楼的门
    { -29, 9, -37 }, -- 王大力家的门
    { -30, 9, -37 }, -- 王大力家的门
    { 15, 9, -39 }, -- 花小楼客栈的门
    { 16, 9, -39 }, -- 花小楼客栈的门
    { 26, 9, -39 }, -- 客栈客房外门
    { 29, 9, -42 }, -- 客栈客房中门
    { 26, 9, -44 }, -- 客栈客房内门
    { 24, 9, -41 }, -- 客栈客房走廊门
    { 24, 8, -19 }, -- 文羽家的门
    { 252, 14, 0 }, -- 强盗营地的门
    { 252, 14, 1 }, -- 强盗营地的门
    { -55, 8, 498 }, -- 二牛门
    { -54, 7, 532 }, -- 千兵卫门1
    { -54, 7, 533 }, -- 千兵卫门2
    { -46, 8, 501 }, -- 风颖马厩门1
    { -46, 8, 500 }, -- 风颖马厩门2
    { -59, 8, 492 }, -- 风颖马厩门3
    { -58, 8, 492 }, -- 风颖马厩门4
    { -37, 8, 546 }, -- 风颖议事厅门1
    { -36, 8, 546 }, -- 风颖议事厅门2
    { -40, 16, 547 }, -- 城主书房门
    { -33, 16, 547 }, -- 城主卧房门
    { 6, 8, 559 }, -- 孔武坊门1
    { 7, 8, 559 }, -- 孔武坊门2
    { 5, 8, 566 }, -- 孔武坊门3
    { 5, 8, 567 }, -- 孔武坊门4
    { 11, 12, 564 }, -- 孔武坊门5
    { 11, 12, 563 }, -- 孔武坊门6
    { 18, 8, 559 }, -- 李妙手门1
    { 19, 8, 559 }, -- 李妙手门2
    { 20, 8, 561 }, -- 李妙手门3
    { 20, 8, 567 }, -- 李妙手门4
    { 20, 8, 566 }, -- 李妙手门5
    { 14, 12, 563 }, -- 李妙手门6
    { 14, 12, 564 }, -- 李妙手门7
    { 7, 8, 580 }, -- 真宝阁门1
    { 6, 8, 580 }, -- 真宝阁门2
    { 11, 8, 573 }, -- 真宝阁门3
    { 17, 8, 573 } -- 真宝阁门4
  },
  doorPositions = {}
}

-- 初始化
function MyAreaHelper:init ()
  self:initShowToastAreas()
  -- body
end

-- 初始化显示飘窗区域
function MyAreaHelper:initShowToastAreas ()
  -- local arr = { wolf, qiangdaoLouluo, ox }
  -- for i, v in ipairs(arr) do
  --   if (v.generate) then -- 如果需要生成怪物
  --     self.showToastAreas[v.areaids[2]] = { v.areaids[1], v.areaName, v.generate }
  --   else
  --     self.showToastAreas[v.areaids[2]] = { v.areaids[1], v.areaName }
  --   end
  -- end
  -- for i, v in ipairs(guard.initAreas) do
  --   if (i >= 5) then
  --     break
  --   end
  --   self.showToastAreas[guard.initAreas2[i]] = { v.areaid, '风颖城' }
  -- end
end

-- 获取所有的门位置
function MyAreaHelper:getDoorPositions ()
  if (#self.doorPositions == 0) then
    for i, v in ipairs(self.doorPositionData) do
      table.insert(self.doorPositions, MyPosition:new(v[1], v[2], v[3]))
    end
  end
  return self.doorPositions
end
