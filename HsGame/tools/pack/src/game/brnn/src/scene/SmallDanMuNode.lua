-- 游戏帮助

local GameResPath  = "game/brnn/res/GameLayout/"
local FrameAniFactory=cc.exports.lib.factory.FrameAniFactory
local SmallDanMuNode = class("SmallDanMuNode",cc.Node)
local DANMU_HEIGHT = 68
local StrPos={cc.p(30,120),cc.p(30,120),cc.p(30,120),cc.p(-30,120),cc.p(-30,120),cc.p(-30,120),cc.p(20,80),cc.p(-30,0)}

function SmallDanMuNode:ctor(index)
    self:init(index)
end

function SmallDanMuNode:init(index)
	local node=cc.Node:create()
	node:setVisible(false)
	self:addChild(node)

	local spStr=""
	if index >3 and index < 7 or index == 8 then
		spStr = "chat_bg_down_r.png"
	else
		spStr = "chat_bg_down_L.png"
	end
	local bgSp=cc.Scale9Sprite:create(GameResPath..spStr)
	local Ssize=bgSp:getContentSize()
	
	bgSp:setPosition(StrPos[index])
	node:addChild(bgSp)
	bgSp:setPreferredSize(cc.size(100,DANMU_HEIGHT))

	local labelConfig =	{
			fontName = GameUtils.getFontName(),
			fontSize = 22,
			text ="",
			alignment = cc.TEXT_ALIGNMENT_CENTER,
			color = cc.c4b(24,59,87,255),
			pos = cc.p(0,0),
			anchorPoint = cc.p(0.5,0.5)
		}
	local lab = cc.exports.lib.uidisplay.createLabel(labelConfig)
	lab:setName("lab")
	node:addChild(lab)

	if index >3 and index < 7 or index == 8 then
		bgSp:setAnchorPoint(cc.p(1,0.5))
		bgSp:setCapInsets(cc.rect(11,22,2,24))
		lab:setPosition(cc.p(StrPos[index].x-20,StrPos[index].y))
		lab:setAnchorPoint(cc.p(1,0.5))
	else
		bgSp:setAnchorPoint(cc.p(0,0.5))
		bgSp:setCapInsets(cc.rect(39,22,2,24))
		lab:setPosition(cc.p(StrPos[index].x+20,StrPos[index].y))
		lab:setAnchorPoint(cc.p(0,0.5))
	end

	local browSp = cc.Sprite:createWithSpriteFrameName("brow1_1.png")
	if index < 7 then
		browSp:setPosition(0,60)
	end
	node:addChild(browSp)

	self.node = node
	self.bgSp = bgSp
	self.lab = lab
	self.browSp = browSp
end

function SmallDanMuNode:setStrData(strData)
	if strData == nil then return end

	self.lab:setString(strData)
	local len=self.lab:getContentSize().width
	self.bgSp:setPreferredSize(cc.size(30+len,DANMU_HEIGHT))
	self.browSp:setVisible(false)
	self.bgSp:setVisible(true)
	self.lab:setVisible(true)
	self.node:setVisible(true)
	local a = {}
	a[#a+1] = cc.DelayTime:create(2)
	a[#a+1] = cc.CallFunc:create(function()
		self.node:setVisible(false)
		end)
	self.node:stopAllActions()
	self.browSp:stopAllActions()
	self.node:runAction(cc.Sequence:create(a))
end

function SmallDanMuNode:setBrowData(BrowIndex)
	if BrowIndex == nil then return end
	self.browSp:setVisible(true)
	self.bgSp:setVisible(false)
	self.lab:setVisible(false)
	self.node:setVisible(true)

	local act = FrameAniFactory:getInstance():getBrowAnimationById(BrowIndex)
	local a = {}
	a[#a+1] = act
	a[#a+1] = cc.CallFunc:create(function()
		self.node:setVisible(false)
		end)
	self.node:stopAllActions()
	self.browSp:stopAllActions()
	self.browSp:runAction(cc.Sequence:create(a))
end

function SmallDanMuNode:reset()
	self.browSp:setVisible(false)
	self.bgSp:setVisible(false)
	self.lab:setVisible(false)
	self.node:setVisible(false)
end

return SmallDanMuNode