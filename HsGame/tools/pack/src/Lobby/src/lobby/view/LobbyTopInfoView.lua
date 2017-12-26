--[[
    名称  :   LobbyTopInfoView  大厅顶部信息栏
    作者  :   Xiaxb   
    描述  :   LobbyTopInfoView 	大厅顶部信息栏
    时间  :   2017-8-15
--]]

-- 大厅顶部信息栏
local LobbyTopInfoView = class("LobbyTopInfoView", cc.Layer)

local PersonalInfo = require "PersonalInfoView"

LobbyTopInfoView.Lobby = 1				--大厅主场景
LobbyTopInfoView.LobbyMenu = 2			--大厅菜单场景
LobbyTopInfoView.LobbyGamePlay = 3
LobbyTopInfoView._index = 0

-- 功能按钮标识
LobbyTopInfoView.BTN_BACK 					= 1				-- 返回
LobbyTopInfoView.BTN_HEAD					= 2				-- 头像
LobbyTopInfoView.IMAGE_INFO_BG				= 3				-- 信息背景
LobbyTopInfoView.BTN_ASSET_BG_GOLD 			= 4				-- 金币背景
LobbyTopInfoView.BTN_ASSET_ADD_GOLD			= 5				-- 金币添加
LobbyTopInfoView.BTN_ASSET_BG_DIAMOND		= 6				-- 钻石背景
LobbyTopInfoView.BTN_ASSET_ADD_DIAMOND		= 7 			-- 钻石添加
LobbyTopInfoView.BTN_ASSET_BG_ROOMCARD		= 8				-- 房卡背景
LobbyTopInfoView.BTN_ASSET_ADD_ROOMCARD		= 9 			-- 房卡添加
LobbyTopInfoView.BTN_NOTICE					= 10			-- 滚报


function LobbyTopInfoView:ctor(index)
	print("LobbyTopInfoView:ctor")
	self:_initView(index)
	self:enableNodeEvents() 
end

-- 初始化视图
function LobbyTopInfoView:_initView(index)

	-- 设置背景
	self.infoViewBg = ccui.ImageView:create("lobby_top_bg.png", ccui.TextureResType.plistType)
	self.infoViewBg:setAnchorPoint(cc.p(1, 0.5))
	self.infoViewBg:setPosition(cc.p(self:getContentSize().width, self:getContentSize().height - self.infoViewBg:getContentSize().height/2))
	self:add(self.infoViewBg)

	-- 为所有可响应点击的控件设置点击事件
	local function btnCallBack(sender)
		self:onButtonClickedEvent(sender:getTag(), sender)
    end

    -- 返回按钮
    local btnBack = ccui.Button:create("lobby_btn_back.png", "", "", ccui.TextureResType.plistType)
    -- btnBack:loadTextureNormal("lobby_top_bg.png", ccui.TextureResType.plistType)
	btnBack:setTag(LobbyTopInfoView.BTN_BACK)
	btnBack:setPosition(cc.p(btnBack:getContentSize().width/2 + 20, self.infoViewBg:getContentSize().height/2))
	btnBack:setScale(0.8)
	self.infoViewBg:addChild(btnBack)
	self._btnBack = btnBack
	btnBack:addClickEventListener(btnCallBack)

	-- 添加头像框
	local btnBack_X, btnBack_Y = btnBack:getPosition()
    local headBtnImg = "common/Lobby_head_bg.png"
    self._headBtn = ccui.Button:create(headBtnImg, headBtnImg, headBtnImg)
    self._headBtn:setTag(LobbyTopInfoView.BTN_HEAD)
	self._headBtn:setPosition(cc.p(btnBack_X + btnBack:getContentSize().width/2 + 20 + self._headBtn:getContentSize().width/2, btnBack_Y))
	self.infoViewBg:addChild(self._headBtn)
	self._headBtn:addClickEventListener(btnCallBack)

    local Gender = UserData.gender or 0
    local GenderStr = GameUtils.getDefalutHeadFileByGender(Gender)

    -- 玩家头像
	local AvatarUrl = UserData.avatarUrl
	local awatar = lib.node.Avatar:create({
	 avatarUrl = AvatarUrl,
	 stencilFile = "res/Avatar/head_rect_round_stencil_94_94.png",
	 defalutFile = GenderStr,
	 frameFile = nil,
		})
    awatar:setAnchorPoint(0.5,0.5)
    awatar:setScale(0.8)
	awatar:setPosition(cc.p(self._headBtn:getContentSize().width/2 - 3, self._headBtn:getContentSize().height/2))
	self._headBtn:addChild(awatar, - 1)

	-- 玩家信息背景
	local headBtn_X, headBtn_Y = self._headBtn:getPosition()
	local userInfoBg = ccui.ImageView:create("lobby_name_bg.png", ccui.TextureResType.plistType)
	userInfoBg:setTag(LobbyTopInfoView.IMAGE_INFO_BG)
	userInfoBg:setPosition(cc.p(headBtn_X + self._headBtn:getContentSize().width/2 + userInfoBg:getContentSize().width/2, headBtn_Y))
	userInfoBg:setTouchEnabled(true)
	self.infoViewBg:addChild(userInfoBg)
	userInfoBg:addClickEventListener(btnCallBack)

	-- 玩家昵称
	local nickeNameStr = GameUtils.FormotGameNickName(UserData.nickName,6)
	self._txtName = ccui.Text:create()
	self._txtName:setString(nickeNameStr)
	self._txtName:setTextColor(cc.c3b(255, 255, 255))
	self._txtName:setFontSize(26)
	self._txtName:setFontName(GameUtils.getFontName())
	-- txtName:setTextAreaSize(cc.size(140, 24))
	-- txtName:ignoreContentAdaptWithSize(false)
	self._txtName:setAnchorPoint(cc.p(0, 1))
	self._txtName:setPosition(cc.p(10, userInfoBg:getContentSize().height - 17))
	userInfoBg:addChild(self._txtName)

	-- 左侧信息背景
	local userInfoBg_X, userInfoBg_Y = userInfoBg:getPosition()
	self.assetBgLeft = ccui.ImageView:create("lobby_asset_bg.png", ccui.TextureResType.plistType)
	self.assetBgLeft:setTag(LobbyTopInfoView.BTN_ASSET_BG_GOLD)
	self.assetBgLeft:setPosition(cc.p(userInfoBg_X + userInfoBg:getContentSize().width/2 + self.assetBgLeft:getContentSize().width/2 + 20, userInfoBg_Y))
	self.assetBgLeft:setTouchEnabled(true)
	self.infoViewBg:addChild(self.assetBgLeft)
	self.assetBgLeft:addClickEventListener(btnCallBack)

	-- 左侧信息icon
	self.imageIconLeft = ccui.ImageView:create("lobby_gold_icon.png", ccui.TextureResType.plistType)
	self.imageIconLeft:setPosition(cc.p(self.imageIconLeft:getContentSize().width/2 + 5,  self.assetBgLeft:getContentSize().height/2))
	self.assetBgLeft:addChild(self.imageIconLeft)

    --金币扫光
    self:addGoldLightEffect("lobby_gold_icon.png",self.imageIconLeft)

	self.textLeft = GameUtils.createSwitchNumNode(UserData.coins and UserData.coins or 0)
	self.textLeft:setPosition(cc.p(self.assetBgLeft:getContentSize().width/2 - 10, self.assetBgLeft:getContentSize().height/2))
	self.assetBgLeft:addChild(self.textLeft)

	-- 左侧添加按钮
	self.btnAddLeft = ccui.Button:create("lobby_btn_add.png", "", "", ccui.TextureResType.plistType)
	self.btnAddLeft:setTag(LobbyTopInfoView.BTN_ASSET_ADD_GOLD)
	self.btnAddLeft:setPosition(cc.p(self.assetBgLeft:getContentSize().width - self.btnAddLeft:getContentSize().width/2 - 2, self.assetBgLeft:getContentSize().height/2))
	self.assetBgLeft:addChild(self.btnAddLeft)
	self.btnAddLeft:addClickEventListener(btnCallBack)

	-- 右侧信息背景
	local assetBgLeft_X, assetBgLeft_Y = self.assetBgLeft:getPosition()
	self.assetBgRight = ccui.ImageView:create("lobby_asset_bg.png", ccui.TextureResType.plistType)
	self.assetBgRight:setTag(LobbyTopInfoView.BTN_ASSET_BG_DIAMOND)
	self.assetBgRight:setPosition(cc.p(assetBgLeft_X + self.assetBgRight:getContentSize().width/2 + self.assetBgRight:getContentSize().width/2 + 20, assetBgLeft_Y))
	self.assetBgRight:setTouchEnabled(true)
	self.infoViewBg:addChild(self.assetBgRight)
	self.assetBgRight:addClickEventListener(btnCallBack)

    -- 右侧信息icon
	self.imageIconRight = ccui.ImageView:create("lobby_diamond_icon.png", ccui.TextureResType.plistType)
	self.imageIconRight:setPosition(cc.p(self.imageIconRight:getContentSize().width/2 + 5,  self.assetBgRight:getContentSize().height/2))
	self.assetBgRight:addChild(self.imageIconRight)

    --砖石扫光
    self:addDiamondLightEffect("lobby_diamond_icon.png",self.imageIconRight)

	self.textRight = GameUtils.createSwitchNumNode(UserData.diamond and UserData.diamond or 0)
	self.textRight:setPosition(cc.p(self.assetBgRight:getContentSize().width/2, self.assetBgRight:getContentSize().height/2))
	self.assetBgRight:addChild(self.textRight)

	-- 右侧添加按钮
	self.btnAddRight = ccui.Button:create("lobby_btn_add.png", "", "", ccui.TextureResType.plistType)
	self.btnAddRight:setTag(LobbyTopInfoView.BTN_ASSET_ADD_DIAMOND)
	self.btnAddRight:setPosition(cc.p(self.assetBgRight:getContentSize().width - self.btnAddRight:getContentSize().width/2 - 2, self.assetBgRight:getContentSize().height/2))
	self.assetBgRight:addChild(self.btnAddRight)
	self.btnAddRight:addClickEventListener(btnCallBack)

	self._index = index
	self:changeTopViewType(index)

	-- 滚报背景
	-- self.noticeBg = self.topBg:getChildByName("Image_noticeBg")
	-- self.noticeBg:setTag(LobbyTopInfoView.IMAGE_NOTICE_BG)
	-- self.noticeBg:addClickEventListener(btnCallBack)
    --广播
	local broadCastView = require("lobby/view/BroadCastView").new(index)
	self:addChild(broadCastView)
end

--按钮事件
function LobbyTopInfoView:onButtonClickedEvent(tag, sender)
	if LobbyTopInfoView.BTN_BACK == tag then
		print("xiaxb----------------BTN_BACK")
		-- self:onKeyBack()
	elseif LobbyTopInfoView.BTN_HEAD == tag or LobbyTopInfoView.IMAGE_INFO_BG == tag then
		print("xiaxb----------------BTN_HEAD:showPlayerInfoDialog")
		local personalInfoView = PersonalInfo.new()
		self:addChild(personalInfoView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
	elseif LobbyTopInfoView.BTN_ASSET_BG_GOLD == tag or LobbyTopInfoView.BTN_ASSET_ADD_GOLD == tag then
		print("xiaxb----------------BTN_DIAMOND_BG&BTN_DIAMOND_ADD")
		self:addChild(require("src/lobby/layer/MallLayer"):create(config.MallLayerConfig.Type_Gold))	
	elseif LobbyTopInfoView.BTN_ASSET_BG_DIAMOND == tag or LobbyTopInfoView.BTN_ASSET_ADD_DIAMOND == tag then
		print("xiaxb----------------BTN_GLOD_BG&BTN_GLOD_ADD")
		self:addChild(require("src/lobby/layer/MallLayer"):create(config.MallLayerConfig.Type_Diamond))
	elseif LobbyTopInfoView.BTN_ASSET_BG_ROOMCARD == tag or LobbyTopInfoView.BTN_ASSET_ADD_ROOMCARD == tag then
		print("xiaxb----------------BTN_GLOD_BG&BTN_GLOD_ADD")
		self:addChild(require("src/lobby/layer/MallLayer"):create(config.MallLayerConfig.Type_RoomCard))
	elseif LobbyTopInfoView.BTN_NOTICE == tag then
		print("xiaxb----------------IMAGE_NOTICE_BG")
		GameUtils.showMsg("聊天系统开发中。。。。。。")
	else

	end
end

-- 根据id变换样式
function LobbyTopInfoView:changeTopViewType(index)

	if LobbyTopInfoView.Lobby == index or LobbyTopInfoView.LobbyGamePlay == index then
		print("obbyTopInfoView.Lobby")
		-- 更新顶部坐标
		if LobbyTopInfoView.Lobby == index then 
			self.infoViewBg:setPosition(cc.p(self:getContentSize().width, self:getContentSize().height - self.infoViewBg:getContentSize().height/2))
		else
			self.infoViewBg:setPosition(cc.p(self:getContentSize().width + 100, self:getContentSize().height - self.infoViewBg:getContentSize().height/2))
		end
		
		-- 更新左侧信息样式
		self.assetBgLeft:setTag(LobbyTopInfoView.BTN_ASSET_BG_GOLD)
		self.imageIconLeft:loadTexture("lobby_gold_icon.png", ccui.TextureResType.plistType)
		GameUtils.updateSwitchNumNode(self.textLeft,UserData.coins and UserData.coins or 0)
		self.btnAddLeft:setTag(LobbyTopInfoView.BTN_ASSET_ADD_GOLD)

        --添加金币扫光
        self:addGoldLightEffect("lobby_gold_icon.png",self.imageIconLeft)

        -- 更新左侧信息样式
		self.assetBgRight:setTag(LobbyTopInfoView.BTN_ASSET_BG_DIAMOND)
		self.imageIconRight:loadTexture("lobby_diamond_icon.png", ccui.TextureResType.plistType)
		GameUtils.updateSwitchNumNode(self.textRight,UserData.diamond and UserData.diamond or 0)
		self.btnAddRight:setTag(LobbyTopInfoView.BTN_ASSET_ADD_DIAMOND)
		if self.infoViewBg then
	        local size = self.infoViewBg:getContentSize()
	        GameUtils.comeOutEffectSlower(self.infoViewBg,manager.ViewManager:getInstance():findLobbyComeOutEffectTime(),size,GameUtils.COMEOUT_TOP)
	    end

        --添加砖石扫光
        self:addDiamondLightEffect("lobby_diamond_icon.png",self.imageIconRight)

	elseif LobbyTopInfoView.LobbyMenu == index  then
		print("obbyTopInfoView.LobbyMenu")
		-- 更新顶部坐标
		self.infoViewBg:setPosition(cc.p(self:getContentSize().width + 100, self:getContentSize().height - self.infoViewBg:getContentSize().height/2))

		-- 更新左侧信息样式
		self.assetBgLeft:setTag(LobbyTopInfoView.BTN_ASSET_BG_DIAMOND)
		self.imageIconLeft:loadTexture("lobby_diamond_icon.png", ccui.TextureResType.plistType)
		GameUtils.updateSwitchNumNode(self.textLeft,UserData.diamond and UserData.diamond or 0)
		self.btnAddLeft:setTag(LobbyTopInfoView.BTN_ASSET_ADD_DIAMOND)

        --添加砖石扫光
        self:addDiamondLightEffect("lobby_diamond_icon.png",self.imageIconLeft)

        -- 更新左侧信息样式
		self.assetBgRight:setTag(LobbyTopInfoView.BTN_ASSET_BG_ROOMCARD)
		self.imageIconRight:loadTexture("lobby_roomcard_icon.png", ccui.TextureResType.plistType)
		GameUtils.updateSwitchNumNode(self.textRight,UserData.roomCards and UserData.roomCards or 0)
		self.btnAddRight:setTag(LobbyTopInfoView.BTN_ASSET_ADD_ROOMCARD)
		if self.infoViewBg then
	        local size = self.infoViewBg:getContentSize()
	        GameUtils.comeOutEffectElastic(self.infoViewBg,manager.ViewManager:getInstance():findLobbyComeOutEffectTime(),size,GameUtils.COMEOUT_TOP)
	    end

        --添加砖石扫光
        self:addGoldLightEffect("lobby_roomcard_icon.png",self.imageIconRight)

	end
	self._index = index
end

function LobbyTopInfoView:addEventListerns()
	local listeners = self:onListersInitCallback()
	if listeners then
		lib.EventUtils.registeAllListeners(self,listeners)
	end
end

function LobbyTopInfoView:removeEventListeners( ... )
	lib.EventUtils.removeAllListeners(self)
end

function LobbyTopInfoView:onListersInitCallback( ... )
	return {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_REFRESH_USER_INFO,handler(self, self.refreshUserInfo)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_REFRESH_USER_NICKNAME,handler(self, self.updateNickName)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_REFRESH_USER_AVATAR,handler(self, self.updateAvatar))
	}
end


function LobbyTopInfoView:updateNickName( ... )
	local nickeNameStr = GameUtils.FormotGameNickName(UserData.nickName,6)
	self._txtName:setString(nickeNameStr)
end

function LobbyTopInfoView:updateAvatar( ... )
	if  UserData.avatarUrl ~= nil and UserData.avatarUrl ~= "" then
		return
	end
	
	self._headBtn:removeAllChildren()

    local Gender = UserData.gender or 0
    local GenderStr = GameUtils.getDefalutHeadFileByGender(Gender)

    -- 玩家头像
	local AvatarUrl = UserData.avatarUrl or ""
	local awatar = lib.node.Avatar:create({
	 avatarUrl = AvatarUrl,
	 stencilFile = "res/Avatar/head_rect_round_stencil_94_94.png",
	 defalutFile = GenderStr,
	 frameFile = nil,
		})
    awatar:setAnchorPoint(0.5,0.5)
    awatar:setScale(0.8)
	awatar:setPosition(cc.p(self._headBtn:getContentSize().width/2 - 3, self._headBtn:getContentSize().height/2))
	self._headBtn:addChild(awatar, - 1)
end

function LobbyTopInfoView:setBtnBackCallback( __callback )
	print("LobbyTopInfoView:setBtnBackCallback")
	self._btnBack:addClickEventListener(__callback)
end

function LobbyTopInfoView:refreshUserInfo( ... )
	print("fly","LobbyTopInfoView:refreshUserInfo》》》",self._index )
	if LobbyTopInfoView.Lobby == self._index or LobbyTopInfoView.LobbyGamePlay == self._index then 
		self.assetBgLeft:setTag(LobbyTopInfoView.BTN_ASSET_BG_GOLD)
		self.imageIconLeft:loadTexture("lobby_gold_icon.png", ccui.TextureResType.plistType)
		GameUtils.updateSwitchNumNode(self.textLeft,UserData.coins and UserData.coins or 0)
		self.btnAddLeft:setTag(LobbyTopInfoView.BTN_ASSET_ADD_GOLD)

        -- 更新左侧信息样式
		self.assetBgRight:setTag(LobbyTopInfoView.BTN_ASSET_BG_DIAMOND)
		self.imageIconRight:loadTexture("lobby_diamond_icon.png", ccui.TextureResType.plistType)
		GameUtils.updateSwitchNumNode(self.textRight,UserData.diamond and UserData.diamond or 0)
		self.btnAddRight:setTag(LobbyTopInfoView.BTN_ASSET_ADD_DIAMOND)
	elseif LobbyTopInfoView.LobbyMenu == self._index  then 
		self.assetBgLeft:setTag(LobbyTopInfoView.BTN_ASSET_BG_DIAMOND)
		self.imageIconLeft:loadTexture("lobby_diamond_icon.png", ccui.TextureResType.plistType)
		GameUtils.updateSwitchNumNode(self.textLeft,UserData.diamond and UserData.diamond or 0)
		self.btnAddLeft:setTag(LobbyTopInfoView.BTN_ASSET_ADD_DIAMOND)

        -- 更新左侧信息样式
		self.assetBgRight:setTag(LobbyTopInfoView.BTN_ASSET_BG_ROOMCARD)
		self.imageIconRight:loadTexture("lobby_roomcard_icon.png", ccui.TextureResType.plistType)
		GameUtils.updateSwitchNumNode(self.textRight,UserData.roomCards and UserData.roomCards or 0)
		self.btnAddRight:setTag(LobbyTopInfoView.BTN_ASSET_ADD_ROOMCARD)
	end		
end

function LobbyTopInfoView:onEnter()
	self:addEventListerns()
end

function LobbyTopInfoView:onExit()
	self:removeEventListeners()
end

--添加金币扫光
function LobbyTopInfoView:addGoldLightEffect(stentilPath,node)
    if self.goldLightEffect then
        self.goldLightEffect:removeFromParent()
        self.goldLightEffect = nil
    end

    local goldLightEffectParams = {
        stencilSprite = cc.Sprite:createWithSpriteFrameName(stentilPath),
        starPosArray = {cc.p(-17,8),cc.p(8,-17),cc.p(10,17)},
        starScaleArray = {0.6,0.6,1},
        delayTime = 0.1,
    }
    self.goldLightEffect = require("lobby/view/LightEffectNode").new(goldLightEffectParams)
	self.goldLightEffect:setPosition(cc.p(node:getContentSize().width/2,node:getContentSize().height/2))
    self.goldLightEffect:starAnimation()
    self.goldLightEffect:lightAnimation()
    node:addChild(self.goldLightEffect)
end

--添加砖石扫光
function LobbyTopInfoView:addDiamondLightEffect(stentilPath,node)
    if self.diamondLightEffect then
        self.diamondLightEffect:removeFromParent()
        self.diamondLightEffect = nil
    end

    local diamondLightEffectParams = {
        stencilSprite = cc.Sprite:createWithSpriteFrameName(stentilPath),
        starPosArray = {cc.p(-20,6),cc.p(0,-16),cc.p(10,15)},
        starScaleArray = {0.6,0.6,1},
        delayTime = 0.1, 
    }
    self.diamondLightEffect = require("lobby/view/LightEffectNode").new(diamondLightEffectParams)
	self.diamondLightEffect:setPosition(cc.p(node:getContentSize().width/2,node:getContentSize().height/2))
    self.diamondLightEffect:starAnimation()
    self.diamondLightEffect:lightAnimation()
    node:addChild(self.diamondLightEffect)
end

return LobbyTopInfoView