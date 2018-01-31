--[[--
@author fly
]]
require "GamePlayManager"
local ResPath = "src/Lobby/res/common/"

local textConf = {
	less_coin_tip = "您的金币不足是否前往商店去购买!?",
	more_coin_tip = "您的金币超出该房间上限，请前往高倍场一展身手吧!"
}

local  LobbyPlayConfig = class("LobbyPlayConfig",lib.layer.Window)

function LobbyPlayConfig:ctor( ... )
	LobbyPlayConfig.super.ctor(self,lib.layer.Window.SMALL)

	local size = self._root:getContentSize()

	local tipLabel = cc.Label:createWithTTF(self:findTipText(),GameUtils.getFontName(),25,cc.size(size.width * 0.8,0),kCCTextAlignmentCenter)
    tipLabel:setPosition(size.width * 0.5,size.height * 0.5+20)
    self._root:addChild(tipLabel)

    local btn =  ccui.Button:create(ResPath .. "common_cancel.png" ,ResPath .. "common_cancel.png",ResPath .. "common_cancel.png",ccui.TextureResType.localType)
	self._root:addChild(btn)
	btn:setPosition(size.width * 0.25 ,size.height * 0.25)
	btn:setPressedActionEnabled(true)
	btn:addClickEventListener(handler(self,self._onCancel))


	local btn = ccui.Button:create(ResPath .. "common_go_soon.png" ,ResPath .. "common_go_soon.png",ResPath .. "common_go_soon.png",ccui.TextureResType.localType)
	self._root:addChild(btn)
	btn:setPosition(size.width * 0.75 ,size.height * 0.25)
	btn:setPressedActionEnabled(true)
	btn:addClickEventListener(handler(self,self._onOk))
end

function LobbyPlayConfig:findTipText( ... )
	-- body
end

function LobbyPlayConfig:_onOk( ... )
	-- body
end

function LobbyPlayConfig:_onCancel( ... )
	self:onCloseCallback()
end


local LobbyPlayUpperConfig = class("LobbyPlayUpperConfig",LobbyPlayConfig)
function LobbyPlayUpperConfig:ctor( ... )
	LobbyPlayUpperConfig.super.ctor(self)

end

function LobbyPlayUpperConfig:findTipText( ... )
	return textConf.more_coin_tip
end

function LobbyPlayUpperConfig:_onOk( ... )
	-- logic.LobbyTableManager:getInstance():RequestGoldQuickJoinTable()
	local manager = cc.exports.lobby.GamePlayManager:getInstance()
	if  manager:autoEnterPlays() then
		local manager = cc.exports.lobby.GamePlayManager:getInstance()
		print("进入金币场",manager:findSelectItemData().playType)
		manager:enterPalys(manager:findSelectItemData().playType)
	else
		GameUtils.showMsg(manager:findNoPlaysSelectString())
	end	
end



local LobbyPlayLessConfig = class("LobbyPlayLessConfig",LobbyPlayConfig)
function LobbyPlayLessConfig:ctor( ... )
	LobbyPlayLessConfig.super.ctor(self)
end

function LobbyPlayLessConfig:findTipText( ... )
	return textConf.less_coin_tip
end

function LobbyPlayLessConfig:_onOk( ... )
	self:onCloseCallback()
	cc.Director:getInstance():getRunningScene():addChild(require("src/lobby/layer/MallDialog"):create())
end






local LobbyGamePreEnter = require "LobbyGamePreEnter"
local LobbyPlayView = class("LobbyPlayView",LobbyGamePreEnter)


LobbyPlayView._listData = nil

function LobbyPlayView:ctor( ... )
	LobbyPlayView.super.ctor(self)

end

function LobbyPlayView:_addTopView( ... )
	local LobbyTopInfoView =  require("lobby/view/LobbyTopInfoView")
	local topInfoView = LobbyTopInfoView:create(LobbyTopInfoView.LobbyGamePlay)
	topInfoView:setBtnBackCallback(handler(self,self._onBackBtnClick))
	self:addChild(topInfoView,5)
end

function LobbyPlayView:refresh( __event )
	print("LobbyPlayView:refresh")
	if __event  and __event.userdata then self._listData =  __event.userdata end
	self:initPlayList()
end

function LobbyPlayView:initPlayList( ... )
	if not self._listView then
		self._listView = ccui.ListView:create()
		self._listView:setContentSize(cc.size(display.width,440))
		self._listView:setAnchorPoint(cc.p(0,0))
		self._listView:setDirection(ccui.ListViewDirection.horizontal)
		self:addChild(self._listView)
		self._listView:setPosition(0,188)
		self._listView:setGravity(ccui.ListViewGravity.centerHorizontal)
		self:_onListViewEffect()
	end
	self._listView:removeAllChildren()
	self:_createItems()
end

function LobbyPlayView:_onRequest( ... )
	lobby.GamePlayManager:getInstance():requestGamePlayList()
end

function LobbyPlayView:createLocalImgUIView( __layout,__itemData )
	local itemData = __itemData
	local layout = __layout
	local size = cc.size(310,self._listView:getContentSize().height )
	local imgFile = itemData.res.imgItemBg
	local button = cc.exports.lib.uidisplay.createUIButton({
		normal = imgFile,
		textureType = ccui.TextureResType.plistType,
		isActionEnabled = true,
		callback = handler(self,self._onGamePlayButtonClick)
		})
	layout:addChild(button)
	button:setTag(__itemData.playType)
	button.itemData = __itemData
	button:setPosition(size.width * 0.5,size.height * 0.5)
	self:_addStarEffect(button,itemData,ccui.TextureResType.plistType)
	local gameConfig = cc.exports.config.GamePlayConfig
	if itemData.playType ~= gameConfig.SRF then
		self:_initPlayButton(button,itemData,ccui.TextureResType.plistType)
	end
end

function LobbyPlayView:createRemoteImgUIView( __layout,__itemData  )
	local itemData = __itemData
	local layout = __layout
	local size = cc.size(310,self._listView:getContentSize().height )
	local imgFile = itemData.res.imgItemBg

	-- local default = self:findDefaultItemImg()
	-- local button = cc.exports.lib.node.RemoteButton:create(default.fileName,default.fileName,default.fileName,default.textureResType)
	-- button:setDownloadParams({
	-- 	dir = "lobbyplay",
	-- 	url = __itemData.res.imgItemBg 
	-- 	})
	local default = "LobbyPlayXS.png"
	if __itemData.level == 1 then
		default = "LobbyPlayXS.png"
	elseif __itemData.level == 2 then
		default = "LobbyPlayJY.png"
	elseif __itemData.level == 3 then
		default = "LobbyPlayDS.png"
	end
	local button = cc.exports.lib.uidisplay.createUIButton({
		normal = default,
		textureType = ccui.TextureResType.plistType,
		isActionEnabled = true,
		callback = handler(self,self._onGamePlayButtonClick)
		})


	print("__itemData.res.imgItemBg ",__itemData.res.imgItemBg )
	button:setPosition(cc.p(size.width * 0.5,size.height * 0.5))
	button:setTag(__itemData.playType)
	-- button:addClickEventListener(handler(self,self._onGamePlayButtonClick))
	-- button:setPressedActionEnabled(true)
	button.itemData = __itemData
	layout:addChild(button)
	button:setTag(__itemData.playType)
	if __itemData.way == ConstantsData.CalCattleType.TYPE_MANUAL then 
		local imgFile = "src/Lobby/res/GameLayout/Lobby/imgSelfNiu.png"
		local imgTip = ccui.ImageView:create(imgFile)
		button:addChild(imgTip)
		imgTip:setAnchorPoint(0,0.5)
		imgTip:setPosition(-2,300)
	end

	self:_addStarEffect(button,itemData)
	local gameConfig = cc.exports.config.GamePlayConfig
	if itemData.playType ~= gameConfig.SRF then
		self:_initPlayButton(button,itemData)
	end
end

function LobbyPlayView:_createItems( ... )
	local manager = cc.exports.lobby.GamePlayManager:getInstance()
	local items = self._listData
	local gameConfig = cc.exports.config.GamePlayConfig
	local layout = ccui.Widget:create()
	layout:setContentSize(cc.size(45,354))
	self._listView:pushBackCustomItem(layout)

	for i=1,#items do
		local size = cc.size(310,self._listView:getContentSize().height )
		local layout = ccui.Widget:create()
		layout:setContentSize(size)
		self._listView:pushBackCustomItem(layout)
		local itemData = items[i]
		local config = cc.exports.config.GamePlayConfig
		if itemData.playType == config.SRF   then
			self:createLocalImgUIView(layout,itemData)
		else
			self:createRemoteImgUIView(layout,itemData)
		end
	end
	local layout = ccui.Widget:create()
	layout:setContentSize(cc.size(45,354))
	self._listView:pushBackCustomItem(layout)

	--快速开始
	local button = cc.exports.lib.uidisplay.createUIButton({
		normal = self:findImgKSKSBtn(),
		textureType = ccui.TextureResType.plistType,
		isActionEnabled = true,
		callback = handler(self,self._onKSKSClick)
		})
	self:addChild(button)
	button:setPosition(display.width * 0.5,display.height * 0.15)

	-- local dir = "GameLayout/Animation/ksks_Animation/"
	-- local node = ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."ksks_Animation0.png",dir.."ksks_Animation0.plist",dir.."ksks_Animation.ExportJson")  
 --    local adAnim = ccs.Armature:create("ksks_Animation") 
 --    adAnim:setPosition(button:getContentSize().width/2,button:getContentSize().height/2) 
 --    button:addChild(adAnim);
 --    adAnim:getAnimation():playWithIndex(0)
 --    adAnim:getAnimation():setSpeedScale(0.5)

    --按钮扫光
    local stencilSprite = cc.Sprite:createWithSpriteFrameName(self:findImgKSKSBtn())
    local btnLightEffectParams = {
        stencilSprite = stencilSprite,
        lightPath = ResPath .. "LobbyPlayPaoGuang.png",
        delayTime = 0.1,
        lightSpeed = 130,  
    }
    local btnLightEffect = require("lobby/view/LightEffectNode").new(btnLightEffectParams)
    btnLightEffect:lightAnimation()
    btnLightEffect:setPosition(cc.p(stencilSprite:getContentSize().width/2,stencilSprite:getContentSize().height/2))
    button:addChild(btnLightEffect)

	local size = button:getContentSize()
	GameUtils.comeOutEffectElastic(button,cc.exports.manager.ViewManager:getInstance():findLobbyComeOutEffectTime(),size,GameUtils.COMEOUT_BOTTON)
end

function LobbyPlayView:_initPlayButton( __targetNode,__itemData,__textureResType )
	local manager = cc.exports.lobby.GamePlayManager:getInstance()
	local size = __targetNode:getContentSize()
	local imgFloorScore = __itemData.res.imgFloorScore
	if __textureResType == ccui.TextureResType.plistType then
		imgFloorScore = ccui.ImageView:create(imgFloorScore,__textureResType)
	else
		local default = self:findImgDefailtFloorScore()
		imgFloorScore = cc.exports.lib.node.RemoteImageView:create(default.fileName,default.textureResType)
		imgFloorScore:setDownloadParams({
			dir = "lobbyplay",
			url = __itemData.res.imgFloorScore
			})
	end
	__targetNode:addChild(imgFloorScore)

	imgFloorScore:setPosition(137,144)

	local atlasFile = self:findNumAtlas()
	local atlasNode = ccui.TextAtlas:create(tostring(__itemData.floorScore),atlasFile,27,36,"0")
	local size = __targetNode:getContentSize()
	-- atlasNode:setPosition(120,33)
	atlasNode:setAnchorPoint(cc.p(0.5,0.5))
	imgFloorScore:addChild(atlasNode)


	local label = cc.exports.lib.uidisplay.createLabel({
		fontSize = 22,
		text = manager:findEnterConditionString(__itemData.minEnterCoinNum,__itemData.maxEnterCoinNum),
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(140,75)
	})
	__targetNode:addChild(label)

	-- local lobbyPlayOnline = ccui.ImageView:create("LobbyPlayOnline.png",ccui.TextureResType.plistType)
	-- __targetNode:addChild(lobbyPlayOnline)
	-- lobbyPlayOnline:setPosition(107,40)
	-- local label = cc.exports.lib.uidisplay.createLabel({
	-- 	fontSize = 23,
	-- 	text = tostring(__itemData.onlineNum),
	-- 	alignment = cc.TEXT_ALIGNMENT_CENTER,
	-- 	color = cc.c4b(255,255,255, 255),
	-- 	pos = cc.p(128,40),
	-- 	anchorPoint = cc.p(0,0.5)
	-- })
	-- __targetNode:addChild(label)
end

function LobbyPlayView:_addStarEffect( __targetNode,__itemData,__textureResType )
	local dir = "GameLayout/Animation/kpqz_ty_Animation/"
	local node = ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."kpqz_ty_Animation0.png",dir.."kpqz_ty_Animation0.plist",dir.."kpqz_ty_Animation.ExportJson")  
    local adAnim = ccs.Armature:create("kpqz_ty_Animation") 
    adAnim:setPosition(__targetNode:getContentSize().width/2,__targetNode:getContentSize().height/2) 
    __targetNode:addChild(adAnim);
    adAnim:getAnimation():playWithIndex(0)

	-- local img = __itemData.res.imgStar
	-- for i=1,20 do
	-- 	local star = nil
	-- 	if  __textureResType == ccui.TextureResType.plistType then
	-- 		star = ccui.ImageView:create(img,__textureResType)
	-- 	else
	-- 		local default = self:findImgDefaultStar()
	-- 		star = cc.exports.lib.node.RemoteImageView:create(default.fileName,default.textureResType)
	-- 		star:setDownloadParams({
	-- 			dir = "lobbyplay",
	-- 			url = img
	-- 			})
	-- 	end
	-- 	__targetNode:addChild(star)

	-- 	star:setOpacity(0)
	-- 	local random = math.random(60,100) * 0.01
	-- 	star:setScale(random)

	-- 	if i <=  2 then
	-- 		star:setPosition(math.random(20,25),18)
	-- 	elseif i <= 18 then
	-- 	    star:setPosition(math.random(55,210),18)
	-- 	else 	
	-- 		star:setPosition(math.random(211,260),18)
	-- 	end
		
	-- 	local speedY = 50
	-- 	star.orgPos = {x = star:getPositionX(),y = star:getPositionY()}
	-- 	local height = 200
	-- 	local duration = height / speedY
	-- 	local delayTime = math.random(1,20) * 0.1
	-- 	local delayAct = cc.DelayTime:create(delayTime)
	-- 	local fadeInAct = cc.FadeIn:create(delayTime)
	-- 	local spawnAct = cc.Spawn:create(delayAct,fadeInAct)
	-- 	local moveByAct = cc.MoveBy:create(duration, cc.p( math.random(-20,14) , math.random(50,height) ) )
	-- 	local fadeOutAct = cc.FadeOut:create(duration)
	-- 	local spawnMoveAct = cc.Spawn:create(moveByAct,fadeOutAct)
	-- 	local callbackAct = cc.CallFunc:create(function (__target )
	-- 		__target:setPosition(__target.orgPos.x,__target.orgPos.y)
	-- 		__target:setOpacity(0)
	-- 	end)
	-- 	local repeatAct = cc.RepeatForever:create( cc.Sequence:create(spawnAct,spawnMoveAct,callbackAct) )
	-- 	star:runAction(repeatAct)
	-- end
end

function LobbyPlayView:_onGamePlayButtonClick( __sender )
	local playType = __sender:getTag()
	local manager = cc.exports.lobby.GamePlayManager:getInstance()
	if playType == config.GamePlayConfig.SRF then 
		local JoinRoomView = require "JoinRoomView"
	 	local view = JoinRoomView.create()
		cc.Director:getInstance():getRunningScene():addChild(view)
	else 
		if manager:enableEnterGame(__sender.itemData)  then
			manager:setSelectItemData(__sender.itemData)
			self:onEnterGame()
			
		else
			if manager:enableUpperEnterGame(__sender.itemData)  then
				local view = LobbyPlayUpperConfig.new()
				self:addChild(view)
			else
				if not manager:isCoinEnough(__sender.itemData)  then 
					local view = LobbyPlayLessConfig.new()
					self:addChild(view)
				else
					GameUtils.showMsg(manager:notBetween())
				end

			end

		end
	end
end

function LobbyPlayView:onEnterGame( ... )
	local manager = cc.exports.lobby.GamePlayManager:getInstance()
	print("进入金币场",manager:findSelectItemData().playType)
	manager:enterPalys(manager:findSelectItemData().playType)
end

function LobbyPlayView:_onKSKSClick( __sender )
	-- logic.LobbyTableManager:getInstance():RequestGoldQuickJoinTable()
	local manager = cc.exports.lobby.GamePlayManager:getInstance()
	if  manager:autoEnterPlays() then
		local manager = cc.exports.lobby.GamePlayManager:getInstance()
		print("进入金币场",manager:findSelectItemData().playType)
		manager:enterPalys(manager:findSelectItemData().playType)
	else
		GameUtils.showMsg(manager:findNoPlaysSelectString())
	end	
end

function LobbyPlayView:onListersInitCallback( ... )
	return {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_REFRESH_GAME_PLAYS,handler(self,self.refresh)),
	}
end

function LobbyPlayView:findImgKSKSBtn( ... )
	return "LobbyPlayKSKS.png"
end

function LobbyPlayView:findNumAtlas( ... )
	return "res/GameLayout/Lobby/LobbyPlayNum.png"
end

function LobbyPlayView:findDefaultItemImg( ... )
	print("ccui.textureResType.plistType",ccui.TextureResType.plistType)
	return {
		fileName = "res/GameLayout/Lobby/LobbyPlaydefault_100_100.png",
		textureResType = ccui.TextureResType.plistType
	}
end

function LobbyPlayView:findImgDefailtFloorScore( ... )
	return {
		fileName = "LobbyPlayDSScore.png",
		textureResType = ccui.TextureResType.plistType
	}
end

function LobbyPlayView:findImgDefaultStar( ... )
	return {
		fileName = "LobbyPlayDSAct.png",
		textureResType = ccui.TextureResType.plistType
	}
end


function LobbyPlayView:onEnter( ... )
	LobbyPlayView.super.onEnter(self)

end

function LobbyPlayView:_onListViewEffect( ... )
	if self._listView then
		local size = self._listView:getContentSize()
		GameUtils.comeOutEffectElastic(self._listView,cc.exports.manager.ViewManager:getInstance():findLobbyComeOutEffectTime() ,size,GameUtils.COMEOUT_RIGHT)
	end
end



return LobbyPlayView