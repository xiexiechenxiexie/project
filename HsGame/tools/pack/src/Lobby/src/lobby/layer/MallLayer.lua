--[[
    名称  :   MallLayer  商城主页面
    作者  :   Xiaxb   
    描述  :   MallLayer 	商城主页面
    时间  :   2017-8-07
--]]
local MallLayer = class("MallLayer", lib.layer.BaseWindow)

-- 当前选中菜单下标
local _curMenuType = 0

-- 左侧菜单按钮tag
local BTN_MENU_GOLD = 1001
local BTN_MENU_DIAMOND = 1002
local BTN_MENU_ROOMCARD = 1003

-- 按钮样式定义
local btnMenuRes = {}

-- 金币按钮图片样式
btnMenuRes[BTN_MENU_GOLD] = {}
btnMenuRes[BTN_MENU_GOLD]["NORMAL"] = "mall_btn_menu_gold_normal.png"
btnMenuRes[BTN_MENU_GOLD]["SELECTED"] = "mall_btn_menu_gold_selected.png"
btnMenuRes[BTN_MENU_GOLD]["POS"] = cc.p(132, 580)

-- 钻石按钮图片样式
btnMenuRes[BTN_MENU_DIAMOND] = {}
btnMenuRes[BTN_MENU_DIAMOND]["NORMAL"] = "mall_btn_menu_diamond_normal.png"
btnMenuRes[BTN_MENU_DIAMOND]["SELECTED"] = "mall_btn_menu_diamond_selected.png"
btnMenuRes[BTN_MENU_DIAMOND]["POS"] = cc.p(132, 580-121)

-- 房卡按钮图片样式
btnMenuRes[BTN_MENU_ROOMCARD] = {}
btnMenuRes[BTN_MENU_ROOMCARD]["NORMAL"] = "mall_btn_menu_room_card_normal.png"
btnMenuRes[BTN_MENU_ROOMCARD]["SELECTED"] = "mall_btn_menu_rooom_card_selected.png"
btnMenuRes[BTN_MENU_ROOMCARD]["POS"] = cc.p(132, 580-121*2)

-- 玩家财富信息
local TEXT_INFO_DIAMOND = 1010
local TEXT_INFO_GOLD = 1011
local TEXT_INFO_ROOM_CARD = 1012

local textInfoRes = {}

textInfoRes[TEXT_INFO_DIAMOND] = {}
textInfoRes[TEXT_INFO_DIAMOND]["INFO_BG"] = "mall_top_info_item_bg.png"
textInfoRes[TEXT_INFO_DIAMOND]["INFO_ICON"] = "mall_info_diamond.png"
textInfoRes[TEXT_INFO_DIAMOND]["POS"] = cc.p(450, 710)
textInfoRes[TEXT_INFO_DIAMOND]["ICON_OFFSET_X"] = 10
textInfoRes[TEXT_INFO_DIAMOND]["ICON_OFFSET_Y"] = 0

textInfoRes[TEXT_INFO_GOLD] = {}
textInfoRes[TEXT_INFO_GOLD]["INFO_BG"] = "mall_top_info_item_bg.png"
textInfoRes[TEXT_INFO_GOLD]["INFO_ICON"] = "mall_info_gold.png"
textInfoRes[TEXT_INFO_GOLD]["POS"] = cc.p(730, 710)
textInfoRes[TEXT_INFO_GOLD]["ICON_OFFSET_X"] = 10
textInfoRes[TEXT_INFO_GOLD]["ICON_OFFSET_Y"] = -1

textInfoRes[TEXT_INFO_ROOM_CARD] = {}
textInfoRes[TEXT_INFO_ROOM_CARD]["INFO_BG"] = "mall_top_info_item_bg.png"
textInfoRes[TEXT_INFO_ROOM_CARD]["INFO_ICON"] = "mall_info_room_card.png"
textInfoRes[TEXT_INFO_ROOM_CARD]["POS"] = cc.p(1010, 710)
textInfoRes[TEXT_INFO_ROOM_CARD]["ICON_OFFSET_X"] = 10
textInfoRes[TEXT_INFO_ROOM_CARD]["ICON_OFFSET_Y"] = 1

local flashPos = {}
flashPos[1] = cc.p(22, 73)
flashPos[2] = cc.p(55, 77)
flashPos[3] = cc.p(90, 79)
flashPos[4] = cc.p(120, 80)
flashPos[5] = cc.p(155, 82)
flashPos[6] = cc.p(190, 83)
flashPos[7] = cc.p(225, 85)
flashPos[8] = cc.p(260, 86)
flashPos[9] = cc.p(300, 88)
flashPos[10] = cc.p(295, 56)
flashPos[11] = cc.p(285, 22)
flashPos[12] = cc.p(250, 21)
flashPos[13] = cc.p(215, 21)
flashPos[14] = cc.p(178, 21)
flashPos[15] = cc.p(135, 21)
flashPos[16] = cc.p(96, 22)
flashPos[17] = cc.p(60, 22)
flashPos[18] = cc.p(26, 42)

MallLayer._maxIndex = TEXT_INFO_ROOM_CARD
MallLayer._maxBtnIndex = BTN_MENU_ROOMCARD
function MallLayer:ctor(menuType)
	MallLayer.super.ctor(self)
	_curMenuType = menuType and menuType or config.MallLayerConfig.Type_Gold
	self._maxIndex = TEXT_INFO_ROOM_CARD
	if manager.UserManager:getInstance():findAppCloseRoomCardFlag() then 
		self._maxIndex = TEXT_INFO_GOLD
	end
	self._maxBtnIndex = BTN_MENU_ROOMCARD
	if manager.UserManager:getInstance():findAppCloseRoomCardFlag() then 
		self._maxBtnIndex = BTN_MENU_DIAMOND
		print("self._maxBtnIndex = BTN_MENU_ROOMCARD",self._maxBtnIndex , BTN_MENU_ROOMCARD)
	end
	self:_initView()
end

-- 初始化试图视图
function MallLayer:_initView()

	-- 商城背景
	local mallBg = ccui.ImageView:create("mall_bg.jpg", ccui.TextureResType.plistType)
	mallBg:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
	self:addChild(mallBg)

	-- 左上角商城logo
	local mallLogo = ccui.ImageView:create("mall_logo.png", ccui.TextureResType.plistType)
	mallLogo:setPosition(cc.p(mallLogo:getContentSize().width-30, mallBg:getContentSize().height - mallLogo:getContentSize().height/2 - 20))
	mallBg:addChild(mallLogo)

	-- local mallLogoLight1 = ccui.ImageView:create("mall_logo_light1.png", ccui.TextureResType.plistType)
	-- mallLogoLight1:setPosition(cc.p(mallLogo:getContentSize().width / 2, mallLogo:getContentSize().height /2))
	-- mallLogo:addChild(mallLogoLight1)

	-- local mallLogoLight2 = ccui.ImageView:create("mall_logo_light2.png", ccui.TextureResType.plistType)
	-- mallLogoLight2:setPosition(cc.p(mallLogo:getContentSize().width / 2, mallLogo:getContentSize().height/2))
	-- mallLogo:addChild(mallLogoLight2)

	-- local lightAc1 = cc.Sequence:create(cc.FadeOut:create(2/60), cc.DelayTime:create(30/60), cc.FadeIn:create(2/60), cc.DelayTime:create(30/60))
	-- local lightAc2 = cc.Sequence:create(cc.FadeIn:create(2/60), cc.DelayTime:create(30/60), cc.FadeOut:create(2/60), cc.DelayTime:create(30/60))

	-- local lightSqu1 = cc.RepeatForever:create(lightAc1)
	-- local lightSqu2 = cc.RepeatForever:create(lightAc2)

	-- mallLogoLight1:runAction(lightSqu1)
	-- mallLogoLight2:runAction(lightSqu2)

	local function callback( sender )
		sender:removeFromParent()
	end

	-- local scheduler = cc.Director:getInstance():getScheduler()
 -- 	self.schedulerId = scheduler:scheduleScriptFunc(
 -- 		function()
	--  		local mallLogoFlash = ccui.ImageView:create("mall_logo_flash.png", ccui.TextureResType.plistType)
	-- 		mallLogoFlash:setPosition(flashPos[math.random(1, #flashPos)])
	-- 		mallLogoFlash:setScale(0.5)
	-- 		mallLogoFlash:setOpacity(0)
	-- 		mallLogo:addChild(mallLogoFlash)

	-- 		local flashAc = cc.Sequence:create(cc.FadeIn:create(5/60), cc.Spawn:create(cc.ScaleTo:create(30/60, 1.5), cc.RotateBy:create(30/60, 180)), cc.Spawn:create(cc.ScaleTo:create(30/60, 0.5), cc.RotateBy:create(30/60, 180)), cc.FadeOut:create(5/60), cc.CallFunc:create(callback))
	-- 		mallLogoFlash:runAction(flashAc)

	-- 	end, 1.5, false)

	--注册点击事件  
	local function callback_tag(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:_btnMenuTouchListener(sender:getTag())
		end
	end 

	-- 初始化菜单按钮

	for index = BTN_MENU_GOLD, self._maxBtnIndex do

		local btnMenu = ccui.Button:create(btnMenuRes[index]["NORMAL"], btnMenuRes[index]["SELECTED"], "", ccui.TextureResType.plistType)
		btnMenu:setTouchEnabled(true)
		btnMenu:setContentSize(cc.size(295, 82))
		btnMenu:setPosition(btnMenuRes[index]["POS"])
		btnMenu:setTag(index)
		self:addChild(btnMenu)

		btnMenu:addTouchEventListener(callback_tag)

		if index == (_curMenuType + 1000) then
			btnMenu:loadTextures(btnMenuRes[index]["SELECTED"], btnMenuRes[index]["SELECTED"], "", ccui.TextureResType.plistType)
		end
	end

	-- -- 联系客服提示语
	-- local txtTip = ccui.Text:create()
	-- txtTip:setText("充值过程中遇到问题请联系客服")
	-- txtTip:setFontSize(18)
	-- txtTip:setTextColor(cc.c4b(255, 255, 255, 255))
	-- txtTip:setAnchorPoint(cc.p(0, 0.5))
	-- txtTip:setPosition(cc.p(30, 85))

	-- self:addChild(txtTip)

	-- -- 微信客服(
	-- local txtWechatTitle = ccui.Text:create()
	-- txtWechatTitle:setText("客服微信：")
	-- txtWechatTitle:setFontSize(20)
	-- txtWechatTitle:setTextColor(cc.c4b(255, 255, 255, 255))
	-- txtWechatTitle:setAnchorPoint(cc.p(0, 0.5))
	-- txtWechatTitle:setPosition(cc.p(30, 55))

	-- self:addChild(txtWechatTitle)

	-- --	客服微信
	-- local txtTWechat = ccui.Text:create()
	-- txtTWechat:setText("400-000-000")
	-- txtTWechat:setFontSize(20)
	-- txtTWechat:setTextColor(cc.c4b(255, 255, 255, 255))
	-- txtTWechat:setAnchorPoint(cc.p(0, 0.5))
	-- txtTWechat:setPosition(cc.p(130, 55))

	-- self:addChild(txtTWechat)

	-- -- QQ客服
	-- local txtQQTitle = ccui.Text:create()
	-- txtQQTitle:setText("客服QQ：")
	-- txtQQTitle:setFontSize(20)
	-- txtQQTitle:setTextColor(cc.c4b(255, 255, 255, 255))
	-- txtQQTitle:setAnchorPoint(cc.p(0, 0.5))
	-- txtQQTitle:setPosition(cc.p(30, 25))

	-- self:addChild(txtQQTitle)

	-- --	QQ客服
	-- local txtQQ = ccui.Text:create()
	-- txtQQ:setText("123456789")
	-- txtQQ:setFontSize(20)
	-- txtQQ:setTextColor(cc.c4b(255, 255, 255, 255))
	-- txtQQ:setAnchorPoint(cc.p(0, 0.5))
	-- txtQQ:setPosition(cc.p(130, 25))

	-- self:addChild(txtQQ)

	-- ***************************************************** --

	-- 顶部按钮

	-- 顶部背景
	-- local topInfoBg = ccui.ImageView:create("mall_top_info_bg.png")
	-- topInfoBg:setPosition(cc.p(topInfoBg:getContentSize().width/2 + leftMenuBg:getContentSize().width, self:getContentSize().height - topInfoBg:getContentSize().height/2))
	-- self:addChild(topInfoBg)

	-- 玩家财富信息
	for index = TEXT_INFO_DIAMOND, self._maxIndex do
		
		-- 财富信息背景
		local infoBg = ccui.ImageView:create(textInfoRes[index]["INFO_BG"], ccui.TextureResType.plistType)
		infoBg:setPosition(textInfoRes[index]["POS"])
		infoBg:setTag(index)
		self:addChild(infoBg)

		-- 财富信息图标
		local infoIcon = ccui.ImageView:create(textInfoRes[index]["INFO_ICON"], ccui.TextureResType.plistType)
		infoIcon:setPosition(cc.p(infoIcon:getContentSize().width/2 + textInfoRes[index]["ICON_OFFSET_X"], infoBg:getContentSize().height/2 + textInfoRes[index]["ICON_OFFSET_Y"])) 
		infoBg:addChild(infoIcon)

        local goldLightEffectParams = {
            stencilSprite = cc.Sprite:createWithSpriteFrameName(textInfoRes[index]["INFO_ICON"]),
            starPosArray = {cc.p(-17,8),cc.p(8,-17),cc.p(10,17)},
            starScaleArray = {0.6,0.6,1},
            delayTime = 0.1,
        }
        self.lightEffect = require("lobby/view/LightEffectNode").new(goldLightEffectParams)
	    self.lightEffect:setPosition(cc.p(infoIcon:getContentSize().width/2,infoIcon:getContentSize().height/2))
        self.lightEffect:starAnimation()
        self.lightEffect:lightAnimation()
        infoIcon:addChild(self.lightEffect)

		local info = self.getUserInfoWithIndex(index)
		print("xiaxb", "type:" .. type(info))
		dump(UserData, "xiaxb-------userData:")
		-- 财富信息参数
		local infoText = GameUtils.createSwitchNumNode(info)
		if info then
			infoText:setPosition(cc.p(infoBg:getContentSize().width/2 + 10, infoBg:getContentSize().height/2))
			-- infoText:setText(tostring(info))
			-- infoText:setFontSize(26)
			infoText:setTag(index)
			-- infoText:setTextColor(cc.c4b(255, 210, 0, 255))
			infoBg:addChild(infoText)
		end
	end

	-- -- 可以根据tag获取财富信息文本赋值
	-- self:getChildByTag(TEXT_INFO_DIAMOND):getChildByTag(TEXT_INFO_DIAMOND):setText("89757")

	-- 关闭按钮
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameLayout/Lobby/Lobby.plist")
	-- self.btnMore:loadTextureNormal("lobby_btn_more_show.png", UI_TEX_TYPE_PLIST)
	local btnClose = ccui.Button:create("lobby_btn_back.png","lobby_btn_back1.png","", ccui.TextureResType.plistType)
	-- btnClose:loadTextureNormal("lobby_btn_back.png","lobby_btn_back1.png","", ccui.TextureResType.plistType)
	btnClose:setPosition(cc.p(self:getContentSize().width - btnClose:getContentSize().width/2, self:getContentSize().height - btnClose:getContentSize().height/2 - 2))
	self:addChild(btnClose)

	local function callback_Close(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			self:removeFromParent()
		end
	end
	btnClose:addTouchEventListener(callback_Close)

	-- local function callbackUpdateServer(data)
	-- 	txtTWechat:setText(data.WechatService)
	-- 	txtQQ:setText(data.QQService)
	-- end

	-- Mall.MallManager:getInstance():getCustomerService(callbackUpdateServer)
	Mall.MallManager:getInstance():getMallList(self, _curMenuType)
end

function MallLayer:refreshUserInfo( ... )
	-- 刷新用户财富信息
	for index = TEXT_INFO_DIAMOND, self._maxIndex do
		local info = self.getUserInfoWithIndex(index)
		GameUtils.updateSwitchNumNode(self:getChildByTag(index):getChildByTag(index),info)
	end
end

-- 根据id获取用户财富信息
function MallLayer.getUserInfoWithIndex( index )
	local info = 0
	if index == TEXT_INFO_DIAMOND then
		info = UserData.diamond
	elseif index == TEXT_INFO_GOLD then
		info = UserData.coins
	elseif index == TEXT_INFO_ROOM_CARD then
		info = UserData.roomCards
	end
	return info or 0
end

function MallLayer:onListersInitCallback( ... )
	return {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_REFRESH_USER_INFO,handler(self, self.refreshUserInfo)),
	}
end

function MallLayer:gotoBuyDiamond( ... )
	self:_btnMenuTouchListener(BTN_MENU_DIAMOND)
end

-- 菜单按钮点击事件回掉
function MallLayer:_btnMenuTouchListener(tag)
	-- print("Xiaxb", "tag", tag)

	if (1000 + _curMenuType) == tag then
		-- print("xiaxb", "当前已选中！")
		return
	end

	for index = BTN_MENU_GOLD, self._maxBtnIndex do
		if index == tag then
			self:getChildByTag(index):loadTextures(btnMenuRes[index]["SELECTED"], btnMenuRes[index]["SELECTED"], "", ccui.TextureResType.plistType)
		else
			self:getChildByTag(index):loadTextures(btnMenuRes[index]["NORMAL"], btnMenuRes[index]["SELECTED"], "", ccui.TextureResType.plistType)
		end
	end 
	_curMenuType = tag - 1000
	Mall.MallManager:getInstance():getMallList(self, _curMenuType)
end

function MallLayer:onEnter()
	MallLayer.super.onEnter(self)
end

function MallLayer:onExit( ... )
	MallLayer.super.onExit(self)
	local scheduler = cc.Director:getInstance():getScheduler()
 	-- scheduler:unscheduleScriptEntry(self.schedulerId)
	Mall.MallManager:getInstance():resetData()
end

return MallLayer
