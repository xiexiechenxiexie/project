-----------------------------------
--帮助
-----------------------------------

local HelpView = class("HelpView",lib.layer.BaseWindow)
local GameResPath = "src/Lobby/res/GameLayout/Help/"

HelpView.close = 1                 --关闭
HelpView.cardType = 2			   --牌型
HelpView.rule = 3   			   --规则 
HelpView.wanfa = 4                 --玩法

function HelpView:ctor()
	HelpView.super.ctor(self)
	self:preloadUI()
	-- self:enableNodeEvents() 
	self:init()
	print("HelpView:ctor")
end
function HelpView:preloadUI()
	display.loadSpriteFrames(GameResPath.."help.plist",
							GameResPath.."help.png")
end

--加载界面
function HelpView:init()
	local container = cc.CSLoader:createNode(GameResPath .. "help.csb")
	self:addChild(container)
	local bg = container:getChildByName("bg")
	self:_onRootPanelInit(bg)

	local close = bg:getChildByName("close")
	close:setTag(HelpView.close)
	close:addClickEventListener(function(sender) self:onCloseCallback(sender) end)

	local cardType = bg:getChildByName("cardType")
	cardType:setTag(HelpView.cardType)
	cardType:setBrightStyle(1)
	cardType:addClickEventListener(function(sender) self:onClickBack(sender) end)
	self.cardType = cardType

	local rule = bg:getChildByName("rule")
	rule:setTag(HelpView.rule)
	rule:addClickEventListener(function(sender) self:onClickBack(sender) end)
	self.rule = rule

	local wanfa = bg:getChildByName("wanfa")
	wanfa:setTag(HelpView.wanfa)
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

function HelpView:onClickBack(sender)
	local tag = sender:getTag()
	if tag == HelpView.close then
		print("关闭")
		-- self:onCloseCallback()
	elseif tag == HelpView.cardType then
		print("牌型")
		self.cardType:setBrightStyle(1)
		self.rule:setBrightStyle(0)
		self.wanfa:setBrightStyle(0)
		self.state:show()
		self.ruleview:hide()
		self.wanfaView:hide()
	elseif tag == HelpView.rule then
		print("规则")
		self.cardType:setBrightStyle(0)
		self.rule:setBrightStyle(1)
		self.wanfa:setBrightStyle(0)
		self.state:hide()
		self.ruleview:show()
		self.wanfaView:hide()
	elseif tag == HelpView.wanfa then
		print("玩法")
		self.cardType:setBrightStyle(0)
		self.rule:setBrightStyle(0)
		self.wanfa:setBrightStyle(1)
		self.state:hide()
		self.ruleview:hide()
		self.wanfaView:show()
	end
end

function HelpView:onEnter()
	print("HelpView:onEnter")
	HelpView.super.onEnter(self)
end
function HelpView:onExit()
	HelpView.super.onExit(self)
	display.removeSpriteFrames(GameResPath.."help.plist",
							GameResPath.."help.png")
end


return HelpView