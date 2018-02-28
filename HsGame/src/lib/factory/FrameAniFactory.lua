-----------------------------------------
--特效
-----------------------------------------
local spriteFrameCache = cc.SpriteFrameCache:getInstance()

local FrameAniFactory = class("FrameAniFactory")

--名字
--资源list，资源png
--帧数
--0帧动画，1骨骼动画
--移动中是否旋转,1旋转
--终点位置调整
--动画播放节点调整
FrameAniFactory.res = 
{
	{"meigui","EffectAnimate/meigui.plist","EffectAnimate/meigui.png",25,0,0,cc.p(0,0),cc.p(0,0)},
	{"zhadan","EffectAnimate/zhadan.plist","EffectAnimate/zhadan.png",19,0,1,cc.p(0,0),cc.p(0,0)},
	{"water","EffectAnimate/water.plist","EffectAnimate/water.png",39,1,0,cc.p(-80,80),cc.p(-40,0)},
	{"xihongshi","EffectAnimate/xihongshi.plist","EffectAnimate/xihongshi.png",25,1,0,cc.p(0,0),cc.p(0,0)},
	{"dianzan","EffectAnimate/dianzan.plist","EffectAnimate/dianzan.png",26,0,0,cc.p(0,0),cc.p(0,0)},
	{"xiaotou","EffectAnimate/xiaotou.plist","EffectAnimate/xiaotou.png",22,0,1,cc.p(-70,0),cc.p(-60,0)},
	{"cock","EffectAnimate/cock.plist","EffectAnimate/cock.png",17,0,0,cc.p(100,0),cc.p(50,0)},
	{"jiubei","EffectAnimate/jiubei.plist","EffectAnimate/jiubei.png",45,1,0,cc.p(0,0),cc.p(0,0)},
	{"fish","EffectAnimate/fish.plist","EffectAnimate/fish.png",79,1,0,cc.p(-50,0),cc.p(-40,0)},
	{"qinwen","EffectAnimate/qinwen.plist","EffectAnimate/qinwen.png",21,0,0,cc.p(0,50),cc.p(0,50)},
	{"Brow","EffectAnimate/brow.plist","EffectAnimate/brow.png"},
	{"Gold","EffectAnimate/win_gold.plist","EffectAnimate/win_gold.png"},
}
FrameAniFactory.animates = {}

function FrameAniFactory:addSpriteFrames(_name)
	for i,v in ipairs(FrameAniFactory.res) do
		if tostring(_name)==v[1] then
			display.loadSpriteFrames(v[2],v[3])
		end
	end
end

function FrameAniFactory:addAllSpriteFrames()
	for i,v in ipairs(FrameAniFactory.res) do
		display.loadSpriteFrames(v[2],v[3])
	end
end

function FrameAniFactory:getAnimation(_name,_len,_speed)
	if display.getAnimationCache(_name) == nil then
		local  _speed = _speed or 0.5/2
		local frames = display.newFrames(_name.."%d.png",0,_len)
		local animation = display.newAnimation(frames,_speed)    
		table.insert(FrameAniFactory.animates,_name)
		display.setAnimationCache(_name,animation)
		return animation
	else
		return display.getAnimationCache(_name)
	end
end


function FrameAniFactory:clearAnimation(_name)
	if _name then
		if display.getAnimationCache(_name) then
			for i,v in ipairs(FrameAniFactory.res) do
				if tostring(_name)==v[1] then
					display.removeSpriteFrames(v[2],v[3])
				end
			end
		end
	end
end

function FrameAniFactory:clearAllSpriteFrames()
	for i,v in ipairs(FrameAniFactory.res) do
		display.removeSpriteFrames(v[2],v[3])
	end
end

-----------------------------------------道具动画----------------------------------------------------------
function FrameAniFactory:getDaoJuNode(index,srcPos,destPos,time)
	if index<0 or index>10 or srcPos==nil or destPos==nil then
		return
	end
	if spriteFrameCache:getSpriteFrame(FrameAniFactory.res[index][1]..".png")==nil then
		self:addSpriteFrames(_name)
	end
	time= time or 2
	local moveTime=0.8
	local act=nil
	local rootNode=cc.Node:create()
	local sp=cc.Sprite:createWithSpriteFrameName(FrameAniFactory.res[index][1]..".png")
	sp:setPosition(srcPos)
	rootNode:addChild(sp)
	local bezier = {
		srcPos,
    	cc.p(destPos.x+FrameAniFactory.res[index][7].x,destPos.y+FrameAniFactory.res[index][7].y),
    	cc.p(destPos.x+FrameAniFactory.res[index][7].x,destPos.y+FrameAniFactory.res[index][7].y),
  	}
  	local bezierForward = cc.BezierTo:create(moveTime, bezier)
  	local move_action=nil
	if FrameAniFactory.res[index][6]>0 then
		local rota=cc.RotateTo:create(moveTime,720)
		move_action=cc.Spawn:create(rota,bezierForward)
	else
		move_action=bezierForward
	end
	if FrameAniFactory.res[index][5]>0 then
		local node =cc.CSLoader:createNode("gamecommon/EffectAnimate/"..FrameAniFactory.res[index][1]..".csb")
		node:setPosition(destPos.x+FrameAniFactory.res[index][8].x,destPos.y+FrameAniFactory.res[index][8].y)
		rootNode:addChild(node)
		local act = cc.CSLoader:createTimeline("gamecommon/EffectAnimate/"..FrameAniFactory.res[index][1]..".csb")
		local frameTime=FrameAniFactory.res[index][4]/60
    	act:setTimeSpeed(frameTime/time*2)
    	node:setVisible(false)
    	node:runAction(act)

		act:setLastFrameCallFunc(function()
			rootNode:removeFromParent()
		end)

		local a={}
  		a[#a+1]= move_action
		a[#a+1]=cc.CallFunc:create(function(sender)
			sp:setVisible(false)
			node:setVisible(true)
    		act:gotoFrameAndPlay(0,false)
    		local musicRes="gamecommon/EffectAnimate/music/daoju_"..FrameAniFactory.res[index][1]..".mp3"
    		local MusicManager=require "manager/MusicManager"
    		MusicManager:getInstance():playAudioEffect(musicRes,false)
    	end)
		local seq=cc.Sequence:create(a)
		sp:runAction(seq)
	else
		local sp1=cc.Sprite:createWithSpriteFrameName(FrameAniFactory.res[index][1]..".png")
		sp1:setPosition(destPos.x+FrameAniFactory.res[index][8].x,destPos.y+FrameAniFactory.res[index][8].y)
		rootNode:addChild(sp1)
		sp1:setVisible(false)

		local function SpAction()
			local musicRes="gamecommon/EffectAnimate/music/daoju_"..FrameAniFactory.res[index][1]..".mp3"
			local MusicManager=require "manager/MusicManager"
			MusicManager:getInstance():playAudioEffect(musicRes,false)
			sp1:setVisible(true)
			sp:setVisible(false)
			local b={}
  			b[#b+1]=self:getDaoJuAnimationById(index,time)
  			b[#b+1]=cc.CallFunc:create(function(sender)
    			rootNode:removeFromParent()
    		end)
    		local seq1=cc.Sequence:create(b)
			sp1:runAction(seq1)
		end

		local a={}
  		a[#a+1]=move_action
  		a[#a+1]=cc.CallFunc:create(SpAction)
		local seq=cc.Sequence:create(a)
		sp:runAction(seq)
	end
	return rootNode
end

--帧动画
function FrameAniFactory:getDaoJuAnimationById(index,time)
	local animation = nil
	local  _speed = time/FrameAniFactory.res[index][4]
	local _name=FrameAniFactory.res[index][1]
	if display.getAnimationCache(_name)==nil then
		local frames = display.newFrames(_name.."_%d.png",1,FrameAniFactory.res[index][4])
		animation = display.newAnimation(frames,_speed)    
		table.insert(FrameAniFactory.animates,_name)
		display.setAnimationCache(_name,animation)
	else
		animation=display.getAnimationCache(_name)
	end

	local action  =cc.Animate:create(animation)
	return action
end

-----------------------------------------金币滚动动画------------------------------------------------------
function FrameAniFactory:getGoldAction()
	local DelayTimeRand = math.random()--0~1
	local WidthRand = 800*(0.5-math.random())
	local HeightRand = 600+200*math.random()
	local indexRand = math.random(1,16)
	local scaleRand = math.random()/2+0.5
	if spriteFrameCache:getSpriteFrame("win_gold_1.png")==nil then
		self:addSpriteFrames("Gold")
	end

	local frames = {}
	for i = 1,40 do
		local count = indexRand+i-1
		if count > 16 then
			count=count%16
		end
		local frameName = string.format("win_gold_%d.png", count)
		local frame = spriteFrameCache:getSpriteFrame(frameName)
		frames[#frames + 1] = frame
	end

	local animation = display.newAnimation(frames,1/40)
	local action = cc.Animate:create(animation)
	local bezier = {
		cc.p(0,0),
    	cc.p(WidthRand/2,HeightRand),
    	cc.p(WidthRand,0),
  	}
  	local bezierForward = cc.BezierTo:create(1, bezier)

  	local szt = cc.ScaleTo:create(1,1)

  	local fade = cc.FadeTo:create(1,200)

	local a = {}
	a[#a+1] = cc.DelayTime:create(DelayTimeRand/4)
	a[#a+1] = cc.Spawn:create(action,bezierForward,fade,szt)
  	a[#a+1] = cc.CallFunc:create(function(sender)
  		sender:removeFromParent()
  	end)

	local sp = cc.Sprite:createWithSpriteFrameName("win_gold_1.png")
	sp:setScale(scaleRand)

	sp:runAction(cc.Sequence:create(a))

	return sp
end

-----------------------------------------聊天表情----------------------------------------------------------
--表情的帧数
FrameAniFactory.brow_animates=
{
	8,2,3,10,7,
	11,8,9,8,10,
	6,2,12,3,5,
	10,10,6,4,4,
	10,8,4,9,7,
	6,4,5,9,5
}

function FrameAniFactory:getBrowAnimationById(_id,time)
	time= time or 2
	local animation = nil
	local  _speed = time/FrameAniFactory.brow_animates[_id]
	local _name="brow"..tostring(_id)
	if spriteFrameCache:getSpriteFrame("brow1_1.png")==nil then
		self:addSpriteFrames("Brow")
	end
	if display.getAnimationCache(_name)==nil then
		local frames = display.newFrames(_name.."_%d.png",1,FrameAniFactory.brow_animates[_id])
		animation = display.newAnimation(frames,_speed)    
		table.insert(FrameAniFactory.animates,_name)
		display.setAnimationCache(_name,animation)
	else
		animation=display.getAnimationCache(_name)
	end

	local action  = cc.Animate:create(animation)
	return action
end

function FrameAniFactory:getBrowSpriteById(_id)
	if spriteFrameCache:getSpriteFrame("brow1_0.png")==nil then
		self:addSpriteFrames("Brow")
	end
	return cc.Sprite:createWithSpriteFrameName("brow"..tostring(_id).."_0.png")
end

function FrameAniFactory:getBrowSpriteFrameById(_id)
	if spriteFrameCache:getSpriteFrame("brow1_0.png")==nil then
		self:addSpriteFrames("Brow")
	end
	return spriteFrameCache:getSpriteFrame("brow"..tostring(_id).."_0.png")
end
-----------------------------------------聊天表情----------------------------------------------------------

cc.exports.lib.singleInstance:bind(FrameAniFactory)
cc.exports.lib.factory.FrameAniFactory = FrameAniFactory

return FrameAniFactory