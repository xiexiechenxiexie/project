-----------------------------------
--帮助
-----------------------------------

local HelpView = class("HelpView",lib.layer.Window)
local GameResPath = "src/Lobby/res/GameLayout/Help/"

HelpView.close = 1                 --关闭
HelpView.cardType = 2			   --牌型
HelpView.rule = 3   			   --规则 
HelpView.wanfa = 4                 --玩法

function HelpView:ctor()
	-- self:preloadUI()
	-- self:enableNodeEvents() 
	print("有没有这个东西啊")
	HelpView.super.ctor(self,ConstantsData.WindowType.WINDOW_BIG)    ----新背景的txtBg：size（844,550）
	self:init()
	print("HelpView:ctor")
end
function HelpView:preloadUI()
	display.loadSpriteFrames(GameResPath.."Lobby_help.plist",
							GameResPath.."Lobby_help.png")
end

--加载界面
function HelpView:init()
	print("貌似是没有")
	local bg = self._root
    self._bg = bg

    -- local bg = ccui.ImageView:create("res/common/common_big_bg0.png")
    -- bg:setPosition(667,375)
    -- self:addChild(bg)

	local container = cc.CSLoader:createNode(GameResPath .. "help.csb")
	container:setPosition(-140,-60)
	bg:addChild(container)

	local bgSize = bg:getContentSize()
    local titleBg = ccui.ImageView:create("res/common/common_title_bg.png")
    titleBg:setPosition(bgSize.width/2, bgSize.height - 21)
    bg:addChild(titleBg)

    local title = cc.Label:createWithTTF("帮助",GameUtils.getFontName(), 36)
    title:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2+3)
    title:setTextColor(cc.c3b(141,62,30))
    title:enableOutline(cc.c3b(255, 250, 152),2)
    titleBg:addChild(title)

	-- local bg = container:getChildByName("bg")
	-- self:_onRootPanelInit(bg)

	-- local close = bg:getChildByName("close")
	-- close:setTag(HelpView.close)
	-- close:addClickEventListener(function(sender) self:onCloseCallback(sender) end)

	local cardType = container:getChildByName("cardType")
	cardType:setTag(HelpView.cardType)
	cardType:setBrightStyle(1)
	cardType:addClickEventListener(function(sender) self:onClickBack(sender) end)
	self.cardType = cardType

	local rule = container:getChildByName("rule")
	rule:setTag(HelpView.rule)
	rule:addClickEventListener(function(sender) self:onClickBack(sender) end)
	self.rule = rule

	local wanfa = container:getChildByName("wanfa")
	wanfa:setTag(HelpView.wanfa)
	wanfa:addClickEventListener(function(sender) self:onClickBack(sender) end)
	self.wanfa = wanfa

	local state = container:getChildByName("shuoming")
	self.state = state

	local ruleview = container:getChildByName("ScrollView_3")
	self.ruleview = ruleview
	ruleview:hide()

	local wanfaView = container:getChildByName("wanfaView")
	self.wanfaView = wanfaView
	wanfaView:hide()

	for i=1,3 do
		local str = "Text_"..tostring(i)
		local font = container:getChildByName(str)
		font:setFontName(GameUtils.getFontName())
		font:enableOutline(cc.c3b(24, 31, 92),2)
	end
	for i=1,2 do
		local str = "Text"..tostring(i)
		local wanfa = wanfaView:getChildByName(str)
		wanfa:setFontName(GameUtils.getFontName())
	end
	for i=1,4 do
		local str = "Text"..tostring(i+2)
		local rule = ruleview:getChildByName(str)
		rule:setFontName(GameUtils.getFontName())
	end
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
	-- HelpView.super.onExit(self)
	-- display.removeSpriteFrames(GameResPath.."Lobby_help.plist",
	-- 						GameResPath.."Lobby_help.png")
end


return HelpView