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
	local cardTypeTitle = cc.Label:createWithTTF("牌型说明",GameUtils.getFontName(),30)
    cardTypeTitle:setColor(cc.c3b(255,255,255))
    cardTypeTitle:setPosition(cardType:getContentSize().width/2,cardType:getContentSize().height/2)
    cardType:addChild(cardTypeTitle)
    self.cardTypeTitle = cardTypeTitle

	local rule = bg:getChildByName("rule")
	rule:setTag(help.rule)
	rule:addClickEventListener(function(sender) self:onClickBack(sender) end)
	self.rule = rule
	local ruleTitle = cc.Label:createWithTTF("基本规则",GameUtils.getFontName(),30)
    ruleTitle:setColor(cc.c3b(191, 169, 125))
    ruleTitle:setPosition(rule:getContentSize().width/2,rule:getContentSize().height/2)
    rule:addChild(ruleTitle)
    self.ruleTitle = ruleTitle

	local wanfa = bg:getChildByName("wanfa")
	wanfa:setTag(help.wanfa)
	wanfa:addClickEventListener(function(sender) self:onClickBack(sender) end)
	self.wanfa = wanfa
	local wanfaTitle = cc.Label:createWithTTF("玩法介绍",GameUtils.getFontName(),30)
    wanfaTitle:setColor(cc.c3b(191, 169, 125))
    wanfaTitle:setPosition(wanfa:getContentSize().width/2,wanfa:getContentSize().height/2)
    wanfa:addChild(wanfaTitle)
    self.wanfaTitle = wanfaTitle

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
		-- self.point:runAction(cc.MoveTo:create(0.2,cc.p(207,377)))
		self.state:show()
		self.ruleview:hide()
		self.wanfaView:hide()
		self.cardTypeTitle:setColor(cc.c3b(255,255,255))
		self.ruleTitle:setColor(cc.c3b(191, 169, 125))
		self.wanfaTitle:setColor(cc.c3b(191, 169, 125))
	elseif tag == help.rule then
		self.cardType:setBrightStyle(0)
		self.rule:setBrightStyle(1)
		self.wanfa:setBrightStyle(0)
		-- self.point:runAction(cc.MoveTo:create(0.2,cc.p(207,279.5)))
		self.state:hide()
		self.ruleview:show()
		self.wanfaView:hide()
		self.cardTypeTitle:setColor(cc.c3b(191, 169, 125))
		self.ruleTitle:setColor(cc.c3b(255,255,255))
		self.wanfaTitle:setColor(cc.c3b(191, 169, 125))
	elseif tag == help.wanfa then
		self.cardType:setBrightStyle(0)
		self.rule:setBrightStyle(0)
		self.wanfa:setBrightStyle(1)
		-- self.point:runAction(cc.MoveTo:create(0.2,cc.p(207,187.5)))
		self.state:hide()
		self.ruleview:hide()
		self.wanfaView:show()
		self.cardTypeTitle:setColor(cc.c3b(191, 169, 125))
		self.ruleTitle:setColor(cc.c3b(255,255,255))
		self.wanfaTitle:setColor(cc.c3b(191, 169, 125))
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