--[[
    名称  :   MallDialg  商城弹窗
    作者  :   Xiaxb   
    描述  :   MallDialg 	商城弹窗
    时间  :   2017-8-07
--]]
local MallDialg = class("MallDialg", lib.layer.Window)

require "Lobby/src/lobby/model/MallManager"

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
-- btnMenuRes[BTN_MENU_GOLD]["NORMAL"] = "TP/Mall/mall_btn_menu_gold_normal.png"
-- btnMenuRes[BTN_MENU_GOLD]["SELECTED"] = "TP/Mall/mall_btn_menu_gold_selected.png"
btnMenuRes[BTN_MENU_GOLD]["NORMAL"] = "TP/Mall/Store/mall_dialog_title_btn_normal.png"
btnMenuRes[BTN_MENU_GOLD]["SELECTED"] = "TP/Mall/Store/mall_dialog_title_btn_selected.png"
btnMenuRes[BTN_MENU_GOLD]["TEXT"] = "金币"
btnMenuRes[BTN_MENU_GOLD]["POS"] = cc.p(83, 37)

-- 钻石按钮图片样式
btnMenuRes[BTN_MENU_DIAMOND] = {}
-- btnMenuRes[BTN_MENU_DIAMOND]["NORMAL"] = "TP/Mall/mall_btn_menu_diamond_normal.png"
-- btnMenuRes[BTN_MENU_DIAMOND]["SELECTED"] = "TP/Mall/mall_btn_menu_diamond_selected.png"
btnMenuRes[BTN_MENU_DIAMOND]["NORMAL"] = "TP/Mall/Store/mall_dialog_title_btn_normal.png"
btnMenuRes[BTN_MENU_DIAMOND]["SELECTED"] = "TP/Mall/Store/mall_dialog_title_btn_selected.png"
btnMenuRes[BTN_MENU_DIAMOND]["TEXT"] = "钻石"
btnMenuRes[BTN_MENU_DIAMOND]["POS"] = cc.p(244, 37)

-- 房卡按钮图片样式
btnMenuRes[BTN_MENU_ROOMCARD] = {}
-- btnMenuRes[BTN_MENU_ROOMCARD]["NORMAL"] = "TP/Mall/mall_btn_menu_room_card_normal.png"
-- btnMenuRes[BTN_MENU_ROOMCARD]["SELECTED"] = "TP/Mall/mall_btn_menu_rooom_card_selected.png"
btnMenuRes[BTN_MENU_ROOMCARD]["NORMAL"] = "TP/Mall/Store/mall_dialog_title_btn_normal.png"
btnMenuRes[BTN_MENU_ROOMCARD]["SELECTED"] = "TP/Mall/Store/mall_dialog_title_btn_selected.png"
btnMenuRes[BTN_MENU_ROOMCARD]["TEXT"] = "房卡"
btnMenuRes[BTN_MENU_ROOMCARD]["POS"] = cc.p(405, 37)

-- -- 玩家财富信息
-- local TEXT_INFO_DIAMOND = 1010
-- local TEXT_INFO_GOLD = 1011
-- local TEXT_INFO_ROOM_CARD = 1012

-- local textInfoRes = {}

-- textInfoRes[TEXT_INFO_DIAMOND] = {}
-- textInfoRes[TEXT_INFO_DIAMOND]["INFO_BG"] = "TP/Mall/mall_top_info_item_bg.png"
-- textInfoRes[TEXT_INFO_DIAMOND]["INFO_ICON"] = "TP/Mall/mall_info_diamond.png"
-- textInfoRes[TEXT_INFO_DIAMOND]["POS"] = cc.p(490, 705)
-- textInfoRes[TEXT_INFO_DIAMOND]["ICON_OFFSET_X"] = 3
-- textInfoRes[TEXT_INFO_DIAMOND]["ICON_OFFSET_Y"] = 0

-- textInfoRes[TEXT_INFO_GOLD] = {}
-- textInfoRes[TEXT_INFO_GOLD]["INFO_BG"] = "TP/Mall/mall_top_info_item_bg.png"
-- textInfoRes[TEXT_INFO_GOLD]["INFO_ICON"] = "TP/Mall/mall_info_gold.png"
-- textInfoRes[TEXT_INFO_GOLD]["POS"] = cc.p(750, 705)
-- textInfoRes[TEXT_INFO_GOLD]["ICON_OFFSET_X"] = 0
-- textInfoRes[TEXT_INFO_GOLD]["ICON_OFFSET_Y"] = -1

-- textInfoRes[TEXT_INFO_ROOM_CARD] = {}
-- textInfoRes[TEXT_INFO_ROOM_CARD]["INFO_BG"] = "TP/Mall/mall_top_info_item_bg.png"
-- textInfoRes[TEXT_INFO_ROOM_CARD]["INFO_ICON"] = "TP/Mall/mall_info_room_card.png"
-- textInfoRes[TEXT_INFO_ROOM_CARD]["POS"] = cc.p(1010, 705)
-- textInfoRes[TEXT_INFO_ROOM_CARD]["ICON_OFFSET_X"] = 10
-- textInfoRes[TEXT_INFO_ROOM_CARD]["ICON_OFFSET_Y"] = 1


function MallDialg:ctor(menuType)
	print("MallDialg:ctor")
	MallDialg.super.ctor(self, lib.layer.Window.MIDDLE)
	_curMenuType = menuType and menuType or config.MallLayerConfig.Type_Gold
	self:_initView()
end

-- 初始化试图视图
function MallDialg:_initView()

	-- 商城背景
	-- self.mallDialogBg = ccui.ImageView:create("TP/Mall/Store/mall_dialog_bg.png", ccui.TextureResType.plistType)
	self.mallDialogBg = self._root
	-- self.mallDialogBg:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
	-- self.mallDialogBg:setTag(1)
	-- self:addChild(self.mallDialogBg)
	-- self:_onRootPanelInit(self.mallDialogBg)

	-- 抬头背景
	self.dialogTitle = ccui.ImageView:create("TP/Mall/Store/mall_dialog_title_bg.png", ccui.TextureResType.plistType)
	self.dialogTitle:setPosition(cc.p(self.mallDialogBg:getContentSize().width/2, 480))
	self.mallDialogBg:addChild(self.dialogTitle)

	--注册点击事件  
	local function callback_tag(sender)
		self:_btnMenuTouchListener(sender:getTag())
	end 

	-- 初始化菜单按钮初始化菜单按钮
	for index = BTN_MENU_GOLD, BTN_MENU_ROOMCARD do

		local btnMenu = ccui.Button:create(btnMenuRes[index]["NORMAL"], btnMenuRes[index]["SELECTED"], "", ccui.TextureResType.plistType)
		btnMenu:setTitleText(btnMenuRes[index]["TEXT"])
		btnMenu:setTitleFontSize(30)
		btnMenu:setTitleFontName(GameUtils.getFontName())
		btnMenu:setTitleColor(cc.c3b(104, 96, 169))
		btnMenu:setTouchEnabled(true)
		btnMenu:setContentSize(cc.size(155, 65))
		btnMenu:setPosition(btnMenuRes[index]["POS"])
		-- btnMenu:setPosition(cc.p(btnMenu:getContentSize().width*(index - 1001 + 0.5)+10, self.dialogTitle:getContentSize().height/2))
		btnMenu:setTag(index)
		self.dialogTitle:addChild(btnMenu)

		btnMenu:addClickEventListener(callback_tag)

		if index == (_curMenuType + 1000) then
			btnMenu:loadTextures(btnMenuRes[index]["SELECTED"], btnMenuRes[index]["SELECTED"], "", ccui.TextureResType.plistType)
			btnMenu:setTitleColor(cc.c3b(255, 255, 255))
		end
	end
	-- 关闭按钮
	-- cc.SpriteFrameCache:getInstance():addSpriteFrames("res/GameLayout/Lobby/Lobby.plist")
	-- self.btnMore:loadTextureNormal("lobby_btn_more_show.png", UI_TEX_TYPE_PLIST)
	-- local btnClose = ccui.Button:create("res/GameLayout/Dialog/dialog_close.png")
	-- btnClose:loadTextureNormal("lobby_btn_back.png", UI_TEX_TYPE_PLIST)
	-- btnClose:setPosition(cc.p(self.mallDialogBg:getContentSize().width - btnClose:getContentSize().width/2 - 20, self.mallDialogBg:getContentSize().height - btnClose:getContentSize().height/2 - 15))
	-- self.mallDialogBg:addChild(btnClose)

	-- local function callback_Close(sender)
	-- 	self:onCloseCallback()
		
	-- end
	-- btnClose:addClickEventListener(callback_Close)

	Mall.MallManager:getInstance():getStoreList(self.mallDialogBg, _curMenuType)
end

function MallDialg:onExit( ... )
	MallDialg.super.onExit(self)
	Mall.MallManager:getInstance():resetData()
end

function MallDialg:gotoBuyDiamond( ... )
	self:_btnMenuTouchListener(BTN_MENU_DIAMOND)
end

-- 菜单按钮点击事件回掉
function MallDialg:_btnMenuTouchListener(tag)
	print("Xiaxb", "tag", tag)

	if (1000 + _curMenuType) == tag then
		print("xiaxb", "当前已选中！")
		return
	end

	for index = BTN_MENU_GOLD, BTN_MENU_ROOMCARD do
		print("xiaxb", "index", index)
		if index == tag then
			self.dialogTitle:getChildByTag(index):loadTextures(btnMenuRes[index]["SELECTED"], btnMenuRes[index]["SELECTED"], "", ccui.TextureResType.plistType)
			self.dialogTitle:getChildByTag(index):setTitleColor(cc.c3b(255, 255, 255))
		else
			self.dialogTitle:getChildByTag(index):loadTextures(btnMenuRes[index]["NORMAL"], btnMenuRes[index]["SELECTED"], "", ccui.TextureResType.plistType)
			self.dialogTitle:getChildByTag(index):setTitleColor(cc.c3b(104, 96, 169))
		end
	end 
	_curMenuType = tag - 1000
	Mall.MallManager:getInstance():getStoreList(self.mallDialogBg, _curMenuType)
end
return MallDialg
