-- 我的道具工具类
MyItemHelper = {}

-- 事件

-- 投掷物命中
function MyItemHelper:projectileHit (projectileid, toobjid, blockid, x, y, z)
  ItemHelper:projectileHit(projectileid, toobjid, blockid, x, y, z)
end

-- 投掷物被创建
function MyItemHelper:missileCreate (objid, toobjid, itemid, x, y, z)
  ItemHelper:missileCreate(objid, toobjid, itemid, x, y, z)
end