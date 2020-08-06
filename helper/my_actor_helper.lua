-- 我的角色工具类
MyActorHelper = {}

-- 初始化actors
function MyActorHelper:init ()
  -- wenyu = Wenyu:new()
  -- jiangfeng = Jiangfeng:new()
  -- jiangyu = Jiangyu:new()
  -- wangdali = Wangdali:new()
  -- miaolan = Miaolan:new()
  -- yangwanli = Yangwanli:new()
  -- huaxiaolou = Huaxiaolou:new()
  -- yexiaolong = Yexiaolong:new()

  -- daniu = Daniu:new()
  -- erniu = Erniu:new()
  -- qianbingwei = Qianbingwei:new()
  -- ludaofeng = Ludaofeng:new()
  -- sunkongwu = Sunkongwu:new()
  -- limiaoshou = Limiaoshou:new()
  -- qianduo = Qianduo:new()
  -- juyidao = Juyidao:new()
  -- local myActors = { jiangfeng, jiangyu, wangdali, miaolan, wenyu, yangwanli, huaxiaolou, yexiaolong, daniu, 
  --     erniu, qianbingwei, ludaofeng, sunkongwu, limiaoshou, qianduo, juyidao }
  -- for i, v in ipairs(myActors) do
  --   TimeHelper:initActor(v)
  --   -- LogHelper:debug('创建', v:getName(), '完成')
  -- end
  -- guard = Guard:new()
  -- guard:init()
  -- LogHelper:debug('创建人物完成')
end

-- 事件

-- actor进入区域
function MyActorHelper:actorEnterArea (objid, areaid)
  ActorHelper:actorEnterArea(objid, areaid)
  MyStoryHelper:actorEnterArea(objid, areaid)
end

-- actor离开区域
function MyActorHelper:actorLeaveArea (objid, areaid)
  ActorHelper:actorLeaveArea(objid, areaid)
  MyStoryHelper:actorLeaveArea(objid, areaid)
end

-- 生物碰撞
function MyActorHelper:actorCollide (objid, toobjid)
  ActorHelper:actorCollide(objid, toobjid)
  MyStoryHelper:actorCollide(objid, toobjid)
end

-- 生物攻击命中
function MyActorHelper:actorAttackHit (objid, toobjid)
  ActorHelper:actorAttackHit(objid, toobjid)
  MyStoryHelper:actorAttackHit(objid, toobjid)
end

-- 生物行为改变
function MyActorHelper:actorChangeMotion (objid, actormotion)
  ActorHelper:actorChangeMotion(objid, actormotion)
  MyStoryHelper:actorChangeMotion(objid, actormotion)
end

-- 生物死亡
function MyActorHelper:actorDie (objid, toobjid)
  ActorHelper:actorDie(objid, toobjid)
  MyStoryHelper:actorDie(objid, toobjid)
end