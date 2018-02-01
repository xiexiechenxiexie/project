-----------------------------------
--帮助
-----------------------------------

local help = class("help",lib.layer.BaseWindow)
local GameResPath = "game/niuniu/res/GameLayout/NiuNiu/"

help.close = 1                 --关闭
help.cardType = 2			   --牌型
help.rule = 3   			   --规则 
help.wanfa = 4                 --玩法

function help:ctor()
	help.super.ctor(self)
	self:preloadUI()
	-- self:enableNodeEvents() 
	self:init()
end
function help:preloadUI()
	display.loadSpriteFrames(GameResPath.."help.plist",
							GameResPath.."help.png")
end

--加载界面
function help:init()
	local container = cc.CSLoader:createNode(GameResPath .. "help.csb")
	self:addChild(container)
	local bg = container:getChildByName("bg")
	self:_onRootPanelInit(bg)

	local close = bg:getChildByName("close")
	close:setTag(help.close)
	close:addClickEventListener(function(sender) self:onCloseCallback(sender) end)

	local point = bg:getChildByName("point")
	self.point = point

	local cardType = bg:getChildByName("cardType")
	cardType:setTag(help.cardType)
	cardType:setBrightStyle(1)
	cardType:addClickEventListener(function(sender) self:onClickBack(sender) end)
	self.cardType = cardType

	local rule = bg:getChildByName("rule")
	rule:setTag(help.rule)
	rule:addClickEventListener(function(sender) self:onClickBack(sender) end)
	self.rule = rule

	local wanfa = bg:getChildByName("wanfa")
	wanfa:setTag(help.wanfa)
	wanfa:addClickEventListener(function(sender) self:onClickBack(sender) end)
	self.wanfa = wanfa

	local state = bg:getChildByName("shuoming")
	self.state = state

	local ruleview = bg:getChildByName("ScrollView_3")
	self.ruleview = ruleview
	ruleview:hide()

	local wanfaView = bg:getChildByName("wanfaView")
	self.wanfaView = wanfaView
	wanfaView:hide()
end

function help:onClickBack(sender)
	local tag = sender:getTag()
	if tag == help.cardType then
		self.cardType:setBrightStyle(1)
		self.rule:setBrightStyle(0)
		self.wanfa:setBrightStyle(0)
		self.point:runAction(cc.MoveTo:create(0.2,cc.p(207,377)))
		self.state:show()
		self.ruleview:hide()
		self.wanfaView:hide()
	elseif tag == help.rule then
		self.cardType:setBrightStyle(0)
		self.rule:setBrightStyle(1)
		self.wanfa:setBrightStyle(0)
		self.point:runAction(cc.MoveTo:create(0.2,cc.p(207,279.5)))
		self.state:hide()
		self.ruleview:show()
		self.wanfaView:hide()
	elseif tag == help.wanfa then
		self.cardType:setBrightStyle(0)
		self.rule:setBrightStyle(0)
		self.wanfa:setBrightStyle(1)
		self.point:runAction(cc.MoveTo:create(0.2,cc.p(207,187.5)))
		self.state:hide()
		self.ruleview:hide()
		self.wanfaView:show()
	end
end

function help:onEnter()
	help.super.onEnter(self)
end
function help:onExit()
	help.super.onExit(self)
	display.removeSpriteFrames(GameResPath.."help.plist",
							GameResPath.."help.png")
end


return help