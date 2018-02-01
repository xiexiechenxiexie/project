---------------------------------------------------
--动画
---------------------------------------------------

local GameModel = require "gamemodel/scene/GameModelScene"
local tableAction = class("tableAction", cc.Layer)
local GameResPath  = "game/niuniu/res/GameLayout/NiuNiu/action/"
local GameResRusPath  = "game/niuniu/res/GameLayout/NiuNiu/"
local conf = require"game/niuniu/src/scene/conf"
local Time = require"game/niuniu/src/scene/Time"
local FrameAniFactory=cc.exports.lib.factory.FrameAniFactory

local LABEL_COLOL = cc.c3b(250,235,204)
local scheduler = cc.Director:getInstance():getScheduler()
local tag = 500

local GOLD_NUM = 15
local MAXPLATER = 5

function tableAction:ctor()
	self:enableNodeEvents()
	self.witetime = nil
	self.banktime = nil
	self.brttingtime = nil

	self.timenum = nil
	self.timeupdate = nil
	self.banktimeUp = nil
	self.brttingUp = nil

	self.zhuangGArr = {}
	self.zhuangArr = {}
	self.roZhuangArr = {}
	self.iconArr = {}
end

--开始倒计时
function tableAction:timeStart(index,time)
	self:stopAllUpdate()
	if index == tag+1 then
		local toBegin = cc.Label:createWithSystemFont("游戏即将开始:"..tostring(time),SYSFONT,26)
		toBegin:setColor(LABEL_COLOL)
		toBegin:setPosition(667,375)
		self:addChild(toBegin)
		self.toBegin = toBegin
		self.witetime = time
	    self.timeupdate=scheduler:scheduleScriptFunc(handler(self, self.updatetime), 1, false)
	elseif index == tag+2 then
		local gradBanker = cc.Label:createWithSystemFont("请抢庄:"..tostring(time),SYSFONT,26)
		gradBanker:setColor(LABEL_COLOL)
		gradBanker:setPosition(667,375)
		self:addChild(gradBanker)
		self.gradBanker = gradBanker
		self.banktime = time
		self.banktimeUp=scheduler:scheduleScriptFunc(handler(self, self.updatebank), 1, false)
	elseif index == tag+3 then
		local brtting = cc.Label:createWithSystemFont("请选择下注倍数:"..tostring(time),SYSFONT,26)
		brtting:setColor(LABEL_COLOL)
		brtting:setPosition(667,375)
		self:addChild(brtting)
		self.brtting = brtting
		self.brttingtime = time
		self.brttingUp=scheduler:scheduleScriptFunc(handler(self, self.updatebrtting), 1, false)
	elseif index == tag+4 then
		self:putCardClock(time)
	end	
end
--开始
function tableAction:updatetime(dt)
	self.witetime = self.witetime - 1
	self.timenum = string.format("%d",self.witetime)
	self.toBegin:setString("游戏即将开始:"..self.timenum)
	local timeArr = {}
	timeArr[#timeArr+1] = cc.DelayTime:create(1)
	timeArr[#timeArr+1] = cc.CallFunc:create(
		function ()
			self.toBegin:hide()
		end)
	local seq = cc.Sequence:create(timeArr)
	if self.witetime <= 0 then
		self.toBegin:runAction(seq)
		self:stopUpdate()
	end
end
--更新抢庄时间
function tableAction:updatebank(dt)
	self.banktime = self.banktime - 1
	self.gradBanker:setString("请抢庄:"..string.format("%d",self.banktime))
	local timeArr = {}
	timeArr[#timeArr+1] = cc.DelayTime:create(1)
	timeArr[#timeArr+1] = cc.CallFunc:create(
		function ()
			self.gradBanker:hide()
		end)
	local seq = cc.Sequence:create(timeArr)
	if tonumber(self.banktime) <= 0 then
		self.gradBanker:runAction(seq)
		self:stopUpdateBank()
	end
end
--更新下注时间
function tableAction:updatebrtting(dt)
	self.brttingtime = self.brttingtime - 1
	self.brtting:setString("请选择下注倍数:"..self.brttingtime)
	local timeArr = {}
	timeArr[#timeArr+1] = cc.DelayTime:create(1)
	timeArr[#timeArr+1] = cc.CallFunc:create(
		function ()
			self.brtting:hide()
		end)
	local seq = cc.Sequence:create(timeArr)
	if self.brttingtime <= 0 then
		self.brtting:runAction(seq)
		self:stopUpdateBanki()
	end
end
--停止等待倒计时
function tableAction:stopUpdate()
	if self.timeupdate then
        scheduler:unscheduleScriptEntry(self.timeupdate)
    end
    if self.toBegin then
    	self.toBegin:removeFromParent()
    	self.toBegin = nil
    end
end
--停止抢庄倒计时
function tableAction:stopUpdateBank()
	if self.banktimeUp then
        scheduler:unscheduleScriptEntry(self.banktimeUp)
    end
    if self.gradBanker then
    	self.gradBanker:removeFromParent()
    	self.gradBanker = nil
    end
    
end
--停止下注倒计时
function tableAction:stopUpdateBanki()
	if self.brttingUp then
        scheduler:unscheduleScriptEntry(self.brttingUp)
    end
    if self.brtting then
    	self.brtting:removeFromParent()
    	self.brtting = nil
    end
end
function tableAction:stopAllUpdate()
	self:stopUpdate()
	self:stopUpdateBank()
	self:stopUpdateBanki()
	if self.timeNode then
		self.timeNode:removeFromParent()
		self.timeNode = nil
	end
end
--摆牌时钟
function tableAction:putCardClock(time)
	local timeNode = Time.new(time)
	timeNode:setPosition(667,375)
	self:addChild(timeNode)
	self.timeNode = timeNode
end
--金币动画
function tableAction:goldCoin(id1,id2)
	for i=1,GOLD_NUM do
		local icon = display.newSprite(GameResPath.."gold_icon.png")
		self:addChild(icon,666)
		table.insert(self.iconArr,icon)
	end
	local TempIndex=0.5/GOLD_NUM
	for i=1,GOLD_NUM do
		--随机分散坐标
		-- local Dpos=self:setPosRand(destPos)
		-- local index=i-self.GoldTab.ShowNum
		local randNumX = math.random(1,50)
		local randNumY = math.random(1,50)
		local srcPos = cc.p(conf.headPosArray[id1].x+randNumX+30,conf.headPosArray[id1].y+randNumY+30)
		local destpos = cc.p(conf.headPosArray[id2].x+randNumX+30,conf.headPosArray[id2].y+randNumY+30)
		local call1 = cc.CallFunc:create(function ()
			self:ZhuangLossMoveAction(self.iconArr[i],srcPos,destpos,i,TempIndex)			
		end)
		local time = cc.DelayTime:create(1)
		local call2 = cc.CallFunc:create(function ()
			self.iconArr[i]:removeFromParent()
		end)
		self:runAction(cc.Sequence:create(call1,time,call2))
		-- table.insert(self.QuYuGoldTab[destIndex].SpArray,self.GoldTab.SpArray[i])
	end
end
--庄家吐钱金币动画
function tableAction:ZhuangLossMoveAction(Target,srcPos,destpos,index,tempIndex)
	Target:stopAllActions()
	Target:setPosition(srcPos)
	Target:setVisible(true)
    local bezier = {
		srcPos,
	    destpos,
	    destpos,
	   }
	local bezierForward = cc.BezierTo:create(0.4+(index-1)*tempIndex, bezier)
	Target:runAction(bezierForward)
end

--轮庄切换动画
function tableAction:roundZhuang(bankidArr)
	local spriteFrame  = cc.SpriteFrameCache:getInstance()
   	spriteFrame:addSpriteFrames("game/niuniu/res/GameLayout/NiuNiu/playerPanel.plist")
	for i,v in ipairs(bankidArr) do
		if v == 2 or v == 5 then
			local rozhuang = cc.Sprite:createWithSpriteFrameName("gold_effect_shu.png")
			rozhuang:setPosition(cc.p(conf.PlayerPosArray[v].x-17,conf.PlayerPosArray[v].y-15))
			table.insert(self.roZhuangArr,rozhuang)
		else
			local rozhuang = cc.Sprite:createWithSpriteFrameName("gold_effect_heng.png")
			rozhuang:setPosition(cc.p(conf.PlayerPosArray[v].x-10,conf.PlayerPosArray[v].y-15))
			table.insert(self.roZhuangArr,rozhuang)
		end
	end
	for i,v in ipairs(self.roZhuangArr) do
		v:setAnchorPoint(0,0)
		self:addChild(v)
		local array = {}
		array[#array+1] = cc.Blink:create(1,4)
		array[#array+1] = cc.CallFunc:create(function ()
			v:hide()
			v:removeFromParent()
		end)
		v:runAction(cc.Sequence:create(array))
	end
end
--庄家特效
function tableAction:zhuangEffect(seatid)
	local spriteFrame  = cc.SpriteFrameCache:getInstance()
   	spriteFrame:addSpriteFrames("game/niuniu/res/GameLayout/NiuNiu/playerPanel.plist")
   	local sprite = nil
   	if seatid == 2 or seatid == 5 then
   		sprite = cc.Sprite:createWithSpriteFrameName("gold_effectS1.png")
   		sprite:setPosition(cc.p(conf.PlayerPosArray[seatid].x-15,conf.PlayerPosArray[seatid].y-12))
   	else
   		sprite = cc.Sprite:createWithSpriteFrameName("gold_effect1.png")
   		sprite:setPosition(cc.p(conf.PlayerPosArray[seatid].x-10,conf.PlayerPosArray[seatid].y-12))
   	end
   	sprite:setAnchorPoint(0,0)
   	
   	self:addChild(sprite)

   	local animation =cc.Animation:create()
   	if seatid == 2 or seatid == 5 then
		for i=1,2 do
		    local frameName =string.format("gold_effectS%d.png",i)
		    local spriteFra = spriteFrame:getSpriteFrame(frameName)
		   	animation:addSpriteFrame(spriteFra)
		end
	else
		for i=1,2 do
		    local frameName =string.format("gold_effect%d.png",i)
		    local spriteFra = spriteFrame:getSpriteFrame(frameName)
		   	animation:addSpriteFrame(spriteFra)
		end
	end
	animation:setDelayPerUnit(0.2)            --设置两个帧播放时间
	animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态
	local action =cc.Animate:create(animation)

	local array = {}
	array[#array+1] = cc.Repeat:create(action,3)
	array[#array+1] = cc.CallFunc:create(function ()
		self:ziEffect(seatid)
		sprite:hide()
	end)
	array[#array+1] = cc.CallFunc:create(function ()
		self:chooseGrad(seatid)
	end)
	local seq = cc.Sequence:create(array)
	sprite:runAction(seq)
end
--庄字的特效
function tableAction:ziEffect(seatid)

	local spriteFrame  = cc.SpriteFrameCache:getInstance()  
   	spriteFrame:addSpriteFrames("game/niuniu/res/GameLayout/NiuNiu/playerPanel.plist")

	local zhuang = cc.Sprite:createWithSpriteFrameName("gold_zhuang.png")
	if seatid == 2 or seatid == 5 then
		zhuang:setPosition(conf.PlayerPosArray[seatid].x+144-10,conf.PlayerPosArray[seatid].y+207-15)
	else
		zhuang:setPosition(conf.PlayerPosArray[seatid].x+282-10,conf.PlayerPosArray[seatid].y+131-15)
	end
	self:addChild(zhuang)
	-- local zhuangZi = cc.Sprite:createWithSpriteFrameName("gold_zhuang_effect.png")
	-- zhuangZi:setPosition(zhuang:getContentSize().width/2,zhuang:getContentSize().height/2)
	-- zhuang:addChild(zhuangZi)

	-- local fade = cc.FadeOut:create(0.5)
	-- local scale = cc.ScaleTo:create(0.5,1.2)
	-- local call = cc.CallFunc:create(function ()
	-- 	zhuangZi:hide()
	-- 	zhuang:hide()
	-- end)
	-- local spawn = cc.Spawn:create(fade,scale)
	-- local seque = cc.Sequence:create(spawn,call)
	-- zhuangZi:runAction(seque)
end
--庄家
function tableAction:chooseGrad(seatid)
	self.zhuangGArr={}
	self.zhuangArr={}
	if seatid == 2 or seatid == 5 then
		local zhuang_guang = cc.Sprite:createWithSpriteFrameName("gold_effect_shu.png")
		self.zhuang_guang = zhuang_guang
	else
		local zhuang_guang = cc.Sprite:createWithSpriteFrameName("gold_effect_heng.png")
		self.zhuang_guang = zhuang_guang
	end
	self.zhuang_guang:setAnchorPoint(0,0)
	self.zhuang_guang:setPosition(cc.p(conf.PlayerPosArray[seatid].x-15,conf.PlayerPosArray[seatid].y-10))
	self:addChild(self.zhuang_guang)
	table.insert(self.zhuangGArr,self.zhuang_guang)

	local zhuang = cc.Sprite:createWithSpriteFrameName("gold_zhuang.png")
	if seatid == 2 or seatid == 5 then
		zhuang:setPosition(conf.PlayerPosArray[seatid].x+144-10,conf.PlayerPosArray[seatid].y+207-15)
	else
		zhuang:setPosition(conf.PlayerPosArray[seatid].x+282-10,conf.PlayerPosArray[seatid].y+131-15)
	end
	self:addChild(zhuang)

	zhuang:setScale(5)
	zhuang:runAction(cc.ScaleTo:create(0.1,1))


	table.insert(self.zhuangArr,zhuang)
	self.zhuang = zhuang
end
--游戏结束的数据清空
function tableAction:gamgEnd()
	for i,v in ipairs(self.zhuangGArr) do
		self.zhuangGArr[i]:removeFromParent()
	end
	for i,v in ipairs(self.zhuangArr) do
		self.zhuangArr[i]:removeFromParent()
	end
	self.zhuangArr = {}
	self.zhuangGArr = {}
	self:stopAllUpdate()
	self.witetime = nil
	self.banktime = nil
	self.brttingtime = nil
end
--金币
function tableAction:iconGold()
	for i=1,20 do
		local sp = FrameAniFactory:getInstance():getGoldAction()
		local node = cc.Node:create()
		node:setPosition(display.cx,display.cy)
		self:addChild(node,999)
		node:addChild(sp)
	end
end
--失败的秋风落叶特效
function tableAction:LoseAutumnleaves()
	local spriteFrame  = cc.SpriteFrameCache:getInstance()  
   	spriteFrame:addSpriteFrames("game/niuniu/res/GameLayout/NiuNiu/lose/goldNiu_liewen.plist")
   	local loseLeave = cc.Sprite:createWithSpriteFrameName("goldNiu_liewen0001.png")
   	loseLeave:setPosition(667,427.35)
   	self:addChild(loseLeave)

   	local animation = cc.Animation:create()
   	for i=1,8 do
   		local frameName =string.format("goldNiu_liewen000%d.png",i)
		local spriteFra = spriteFrame:getSpriteFrame(frameName)
		animation:addSpriteFrame(spriteFra)
   	end
	animation:setDelayPerUnit(0.2)            --设置两个帧播放时间
	animation:setRestoreOriginalFrame(false)    --动画执行后还原初始状态
	local action =(cc.Repeat:create(cc.Animate:create(animation),1))
	loseLeave:runAction(action)

	local spriteFrame1  = cc.SpriteFrameCache:getInstance()  
   	spriteFrame1:addSpriteFrames("game/niuniu/res/GameLayout/NiuNiu/lose/goldNiu_luoye.plist")
   	local loseluoye = cc.Sprite:createWithSpriteFrameName("goldNiu_luoye1.png")
   	loseluoye:setPosition(667,427.35)
   	self:addChild(loseluoye)

   	local animation1 = cc.Animation:create()
   	for i=1,25 do
   		local frameName1 =string.format("goldNiu_luoye%d.png",i)
		local spriteFra1 = spriteFrame1:getSpriteFrame(frameName1)
		animation1:addSpriteFrame(spriteFra1)
   	end
	animation1:setDelayPerUnit(0.064)            --设置两个帧播放时间
	animation1:setRestoreOriginalFrame(false)    --动画执行后还原初始状态
	local action1 =(cc.Repeat:create(cc.Animate:create(animation1),1))
	loseluoye:runAction(action1)
end
--数据重新设置
function tableAction:reSetData()
	self:stopAllUpdate()
	self.witetime = nil
	self.banktime = nil
	self.brttingtime = nil

	self.timenum = nil
	self.timeupdate = nil
	self.banktimeUp = nil
	self.brttingUp = nil
	self.zhuangGArr = {}
	self.zhuangArr = {}
	self.roZhuangArr = {}
end

function tableAction:onEnter()
end

function tableAction:onExit()
	self:stopAllUpdate()
	self.witetime = nil
	self.banktime = nil
	self.brttingtime = nil

	self.timenum = nil
	self.timeupdate = nil
	self.banktimeUp = nil
	self.brttingUp = nil
end

return tableAction