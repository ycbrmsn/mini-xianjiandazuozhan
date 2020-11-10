-- 我的道具工具类
MyItemHelper = {}

-- 获取击败玩家描述
function MyItemHelper:getDefeatPlayerDesc (objid, item)
  if (item) then
    return '', StringHelper:concat('#n使出一套华丽的', item.skillname, ',将'), '#n送别'
  else
    local itemid = PlayerHelper:getCurToolID(objid)
    if (itemid == MyWeaponAttr.controlSword.levelIds[1]) then
      return '', '#n手执御仙剑，两下就让', '#n消失不见'
    elseif (itemid == MyWeaponAttr.tenThousandsSword.levelIds[1]) then
      return '', '#n一挥万仙剑，将', '#n化成了碎片'
    elseif (itemid == MyWeaponAttr.huixianSword.levelIds[1]) then
      return '', '#n舞动回仙剑，让', '#n生无可恋'
    elseif (itemid == MyWeaponAttr.vitalqiSword.levelIds[1]) then
      return '', '#n轻扬气仙剑，虐了', '#n又一遍'
    elseif (itemid == MyWeaponAttr.luanSword.levelIds[1]) then
      return '', '#n狂舞着乱仙剑，又让', '#n四脚朝天'
    elseif (itemid == MyWeaponAttr.shunSword.levelIds[1]) then
      return '', '#n狂舞着乱仙剑，又让', '#n消失不见'
    elseif (itemid == MyMap.ITEM.ENERGY_FRAGMENT_ID) then
      return '', '#n拿着能量碎片，对', '#n说了声再见'
    elseif (itemid == MyMap.ITEM.APPLE_ID) then
      return '', '#n晃了晃手中的苹果，对', '#n说了句叫你惹我'
    elseif (itemid == MyMap.ITEM.ANIMAL_BONE_ID) then
      return '', '#n甩了甩手中的兽骨，让', '#n不再痛苦'
    elseif (itemid == MyMap.ITEM.MUSIC_PLAYER_ID) then
      return '', '#n擦了擦手中的播放器，给', '#n留下了一个痛苦的回忆'
    elseif (itemid == MyMap.ITEM.TIME_TURNTABLE_ID) then
      return '', '#n抡起时间轮盘，艰难地让', '#n玩儿完'
    elseif (itemid == 230) then
      return '', '#n扛着方南瓜，将', '#n给砸回了家'
    elseif (itemid == 251) then
      return '', '#n握着竹子，让', '#n明白谁才是个孩子'
    elseif (itemid == 0) then
      return '', '#n仅凭一对拳头，就打得', '#n无力还手'
    else
      return '', '#n乱舞着手里的东西，让', '#n没了脾气'
    end
  end
end

-- 获取道具描述与类型
function MyItemHelper:getItemDescAndCategory (itemid)
  if (not(itemid)) then
    return nil
  end
  if (itemid == MyWeaponAttr.controlSword.levelIds[1] or itemid == MyWeaponAttr.tenThousandsSword.levelIds[1]
    or itemid == MyWeaponAttr.huixianSword.levelIds[1] or itemid == MyWeaponAttr.vitalqiSword.levelIds[1]
    or itemid == MyWeaponAttr.luanSword.levelIds[1] or itemid == MyWeaponAttr.shunSword.levelIds[1]) then
    return '拿把破剑', 1
  elseif (itemid == MyMap.ITEM.ENERGY_FRAGMENT_ID) then
    return '拿枚能量碎片', 2
  elseif (itemid == MyMap.ITEM.APPLE_ID) then
    return '拿颗苹果', 2
  elseif (itemid == MyMap.ITEM.ANIMAL_BONE_ID) then
    return '拿根碎骨头', 2
  elseif (itemid == MyMap.ITEM.MUSIC_PLAYER_ID) then
    return '拿块砖头', 2
  elseif (itemid == MyMap.ITEM.TIME_TURNTABLE_ID) then
    return '拿个转盘', 2
  elseif (itemid == 230) then
    return '拿个方南瓜', 2
  elseif (itemid == 251) then
    return '拿节竹子', 2
  elseif (itemid == 0) then
    return '空手', 3
  else
    return StringHelper:concat('拿个', ItemHelper:getItemName(itemid)), 2
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