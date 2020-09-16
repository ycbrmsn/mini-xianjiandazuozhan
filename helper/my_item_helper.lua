-- 我的道具工具类
MyItemHelper = {}

-- 获取击败玩家描述
function MyItemHelper:getDefeatPlayerDesc (objid)
  local itemid = PlayerHelper:getCurToolID(objid)
  if (itemid == MyWeaponAttr.controlSword.levelIds[1]) then
    return '', '#n手执御仙剑，两下就让', '#n消失不见'
  elseif (itemid == MyWeaponAttr.tenThousandsSword.levelIds[1]) then
    return '', '#n一挥万仙剑，将', '#n化成了碎片'
  elseif (itemid == MyWeaponAttr.huixianSword.levelIds[1]) then
    return '', '#n舞动回仙剑，让', '#n生无可恋'
  elseif (itemid == MyWeaponAttr.vitalqiSword.levelIds[1]) then
    return '', '#n轻扬气仙剑，虐了', '#n又一遍'
  elseif (itemid == MyMap.ITEM.ENERGY_FRAGMENT_ID) then
    return '', '#n拿着能量碎片，对', '#n说了声再见'
  elseif (itemid == MyMap.ITEM.APPLE_ID) then
    return '', '#n晃了晃手中的苹果，对', '#n说了句叫你惹我'
  elseif (itemid == MyMap.ITEM.ANIMAL_BONE_ID) then
    return '', '#n甩了甩手中的兽骨，让', '#n不再痛苦'
  elseif (itemid == MyMap.ITEM.MUSIC_PLAYER_ID) then
    return '', '#n擦了擦手中的播放器，给', '#n留下了一个痛苦的回忆'
  elseif (itemid == 230) then
    return '', '#n扛着方南瓜，将', '#n给砸回了家'
  elseif (itemid == 251) then
    return '', '#n握着竹子，让', '#n明白谁才是个孩子'
  end
  return nil
end

-- 事件

-- 投掷物命中
function MyItemHelper:projectileHit (projectileid, toobjid, blockid, x, y, z)
  ItemHelper:projectileHit(projectileid, toobjid, blockid, x, y, z)
end

-- 投掷物被创建
function MyItemHelper:missileCreate (objid, toobjid, itemid, x, y, z)
  ItemHelper:missileCreate(objid, toobjid, itemid, x, y, z)
end