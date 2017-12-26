-- 有奖推广
-- @date 2017.08.18
-- @author tangwen

local PromoteLayer = class("PromoteLayer", lib.layer.BaseLayer)

local PROMOTELAYER_CSB = "GameLayout/Promote/PromoteLayer.csb"

local DownCodeImgIndex ="DOWN_CODE_IMG"

PromoteLayer.LoginType_Guest            = 0     -- 游客登录
PromoteLayer.LoginType_Wechat           = 1     -- 微信登录
PromoteLayer.loginType_QQ               = 2     -- QQ登录

function PromoteLayer:ctor(__data)
	PromoteLayer.super.ctor(self)
	self._promoteData = __data
	self:enableNodeEvents() 
	self:initView()
end

function PromoteLayer:initView()
    self._panel = cc.CSLoader:createNode(PROMOTELAYER_CSB)
	self:addChild(self._panel)

	local btnClose = self._panel:getChildByName("btn_back")
	btnClose:addClickEventListener(function()
		GameUtils.removeNode(self)
	end)

	self._codeBg = self._panel:getChildByName("img_code_bg")
	self._codeImg = self._codeBg:getChildByName("Image_17")

	local btnCopy = self._codeBg:getChildByName("btn_copy")
	btnCopy:addClickEventListener(function()
		MultiPlatform:getInstance():copyToClipboard(self._promoCode)
	end)

	self._btnDown = self._codeBg:getChildByName("btn_down")
	self._btnDown:setLocalZOrder(3)
	self._btnDown:addClickEventListener(function()
		local imgUrl = config.ServerConfig:findResDomain() .. self._CodeUrl
		local codeImg = lib.node.RemoteImageView:create("Lobby_Promote_code.png",ccui.TextureResType.plistType)
		codeImg:setDownloadParams({
			dir = "promote",
			url = imgUrl,
			size = cc.size(121,118)
		})
  		codeImg:setDownloadFinishCallback(function(fullFileName)
   			MultiPlatform:getInstance():saveImgToSystemGallery(fullFileName, "promote_code.png")
  		end)
		codeImg:setPosition(self._codeImg:getPosition())
		codeImg:setLocalZOrder(1)
		self._codeBg:addChild(codeImg)
		self._codeImg:hide()
		--self._btnDown:hide()
		cc.UserDefault:getInstance():setFloatForKey(DownCodeImgIndex,1)
	end)

	self._TextPromoCode = self._codeBg:getChildByName("Text_PromoCode")
	self._TextShareGet = self._panel:getChildByName("text_share_get")

	local btnGetGift = self._panel:getChildByName("btn_getGift")
	btnGetGift:addClickEventListener(function()
		local bindingInviteCodeView = require("lobby/view/BindingInviteCodeView").new(self._promoteData)
		self:addChild(bindingInviteCodeView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
	end)


	local btnCheckGift = self._panel:getChildByName("btn_check")
	btnCheckGift:addClickEventListener(function()
		print("MobilePhone:",UserData.MobilePhone)
		if UserData.MobilePhone == "" then
			local bindingMobileView = require("lobby/view/BindingMobileView").new()
			self:addChild(bindingMobileView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
		else
			local targetPlatform = cc.Application:getInstance():getTargetPlatform()
			if device.platform ~= "windows"  then
				if self._promoteData.distribution == nil then
					return
				end
				MultiPlatform:getInstance():openWebView(self._promoteData.distribution.distribution_website)
			end

		end
	end)

	local friendGetBg = self._panel:getChildByName("img_friend_get_bg")

	self._TextFriendGetDiamond = friendGetBg:getChildByName("Text_friend_get_diamond")
	self._TextFriendGetCoins = friendGetBg:getChildByName("Text_friend_get_coins")
	self._TextFriendGetRoomCard = friendGetBg:getChildByName("Text_friend_get_roomcard")

	self._btnShare = self._panel:getChildByName("btn_share")
	self._btnShare:addClickEventListener(function()
		if not (self._promoteData and  self._promoteData.distribution) then
			return
		end

		-- 设置推广分享(用于区别统计链接)
		ShareManager.Share_Scene = ShareManager.ShareScene_PromoteLayer

		local shareUrlTab = {}
		shareUrlTab.title = self._promoteData.distribution.share_title                          --  分享标题                          
		shareUrlTab.des = self._promoteData.distribution.share_description                      --  分享描述
		shareUrlTab.url = self._promoteData.distribution.share_link                             --  分享地址
		shareUrlTab.urlImg = config.ServerConfig:findResDomain() .. self._promoteData.distribution.share_logo--  分享图片地址
		shareUrlTab.callback = function(result) 												--  分享结果回调
									if result then
										self:requestDailyShareAward(result)
									end
								end          

		print("xiaxb", "shareUrl------start")
		ShareManager:shareUrl(UserData.loginType, shareUrlTab)
		print("xiaxb", "shareUrl------end")
	end)

	local clip = cc.ClippingNode:create()  --创建裁剪节点
	local stencileNode = ccui.ImageView:create("Lobby_Promote_btn_share.png", ccui.TextureResType.plistType)		--创建模板
	clip:setStencil(stencileNode)					--设置模板
	clip:setAlphaThreshold(0.5)				--设置裁剪阈值
	clip:setContentSize(cc.size(stencileNode:getContentSize()))			--设置裁剪大小
	clip:setPosition(151,43)
	clip:addChild(stencileNode)

	local spark1 = ccui.ImageView:create("Lobby_Promote_paoguang.png", ccui.TextureResType.plistType)
	spark1:setPosition(cc.p(-spark1:getContentSize().width- 50, 0))
	clip:addChild(spark1)
	self._btnShare:addChild(clip)

	local moveAction1 = cc.MoveBy:create(1, cc.p(stencileNode:getContentSize().width + spark1:getContentSize().width + 50, 0))
	local seq1 = cc.Sequence:create(moveAction1, cc.DelayTime:create(math.random(2, 2)), cc.CallFunc:create( function (sender)
    	sender:setPosition(cc.p(-sender:getContentSize().width - 50, 0))
    	end
	) )
	local repeatAction1 = cc.RepeatForever:create(seq1)
	spark1:runAction(repeatAction1)

	self:bubbleUpAnimation(self._btnShare)

	local myGetBg = self._panel:getChildByName("img_self_get_bg")
	local myGetItem1 = myGetBg:getChildByName("gift1")
	local ItemText1 = myGetItem1:getChildByName("GetText")
	ItemText1:setString(self._promoteData.share.s1 .. "%的红包券")

	local myGetItem2 = myGetBg:getChildByName("gift2")
	local ItemText2 = myGetItem2:getChildByName("GetText")
	ItemText2:setString(self._promoteData.share.s2 .. "%的红包券")

	local myGetItem3 = myGetBg:getChildByName("gift3")
	local ItemText3 = myGetItem3:getChildByName("GetText")
	ItemText3:setString(self._promoteData.share.s3 .. "%的红包券")

	self._TextShareGet:setString(self._promoteData.share.everyday)

	for k,v in pairs(self._promoteData.reward) do
		if v.type == ConstantsData.PointType.POINT_DIAMOND then
			self._TextFriendGetDiamond:setString(v.number)
		elseif v.type == ConstantsData.PointType.POINT_COINS then
			self._TextFriendGetCoins:setString(v.number)
		elseif v.type == ConstantsData.PointType.POINT_ROOMCARD then
			self._TextFriendGetRoomCard:setString(v.number)
		else
			print("推广游戏奖励出错")
		end
	end

	self._promoCode = self._promoteData.distribution.promo_code
	self._TextPromoCode:setString(self._promoteData.distribution.promo_code)
	self._CodeUrl = self._promoteData.distribution.qrcode_url
	self._CheckUrl = self._promoteData.distribution.distribution_website

	local downCodeFlag = cc.UserDefault:getInstance():getFloatForKey(DownCodeImgIndex)
	print("downCodeFlag:",downCodeFlag)
	if downCodeFlag == 1 then 
		local imgUrl = config.ServerConfig:findResDomain() .. self._CodeUrl
		print("imgUrl:",imgUrl)
		local codeImg = lib.node.RemoteImageView:create("Lobby_Promote_code.png",ccui.TextureResType.plistType)
		codeImg:setDownloadParams({
			dir = "promote",
			url = imgUrl
		})
		codeImg:setContentSize(self._codeImg:getContentSize())
		codeImg:setScale(0.5)
		codeImg:setPosition(self._codeImg:getPosition())
		codeImg:setLocalZOrder(1)
		self._codeBg:addChild(codeImg)
		self._codeImg:hide()
		--self._btnDown:hide()
	end
end

function PromoteLayer:requestDailyShareAward(__data)
	local data = lib.JsonUtil:decode(__data)
	if data.result == 1 then
		logic.PromoteManager:getInstance():requestDailyShareAwardData(function( result )
	        if result then
	        	print("发送领取奖励事件")
	        	local event = cc.EventCustom:new(config.EventConfig.EVENT_REFRESH_USER_INFO)
				lib.EventUtils.dispatch(event)
				if self._promoteData.share.everyday ~= nil then
					local __params = {{type = ConstantsData.PointType.POINT_COINS, score = self._promoteData.share.everyday}}
					GameUtils.showGiftAccount(__params)
				end

	        end
	    end)

		-- 统计推广分享
		-- print("xiaxb", "plat:" .. data.plat)
		if ShareManager.ShareType_QQ == data.plat then
			-- print("xiaxb", "plat1:" .. data.plat)
			MobClickForLua.event(MobClickForLua.shareQQUrl)
		elseif ShareManager.ShareType_QQ_ZONE == data.plat then
			-- print("xiaxb", "plat2:" .. data.plat)
			MobClickForLua.event(MobClickForLua.shareQQZoneUrl)
		elseif ShareManager.ShareType_WECHAT == data.plat then
			-- print("xiaxb", "plat3:" .. data.plat)
			MobClickForLua.event(MobClickForLua.shareWechatUrl)
		elseif ShareManager.ShareType_WECHAT_CIRCLE == data.plat then
			-- print("xiaxb", "plat4:" .. data.plat)
			MobClickForLua.event(MobClickForLua.shareWechatCircleUrl)
		else
		end   
	end
end

function PromoteLayer:bubbleUpAnimation(__targetNode)
	for i=1,20 do
		local star = ccui.ImageView:create("Lobby_Promote_up.png", ccui.TextureResType.plistType)
		__targetNode:addChild(star)

		star:setOpacity(0)
		local random = math.random(60,100) * 0.01
		star:setScale(random)

		if i <=  2 then
			star:setPosition(math.random(20,25),18)
		elseif i <= 18 then
		    star:setPosition(math.random(55,210),18)
		else 	
			star:setPosition(math.random(211,260),18)
		end
		
		local speedY = 50
		star.orgPos = {x = star:getPositionX(),y = star:getPositionY()}
		local height = 60
		local duration = height / speedY
		local delayTime = math.random(1,20) * 0.1
		local delayAct = cc.DelayTime:create(delayTime)
		local fadeInAct = cc.FadeIn:create(delayTime)
		local spawnAct = cc.Spawn:create(delayAct,fadeInAct)
		local moveByAct = cc.MoveBy:create(duration, cc.p( math.random(-20,14) , math.random(50,height) ) )
		local fadeOutAct = cc.FadeOut:create(duration)
		local spawnMoveAct = cc.Spawn:create(moveByAct,fadeOutAct)
		local callbackAct = cc.CallFunc:create(function (__target )
			__target:setPosition(__target.orgPos.x,__target.orgPos.y)
			__target:setOpacity(0)
		end)
		local repeatAct = cc.RepeatForever:create( cc.Sequence:create(spawnAct,spawnMoveAct,callbackAct) )
		star:runAction(repeatAct)
	end
end

function PromoteLayer:onListersInitCallback( ... )
	local listeners = {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_ROOM_JOIN_CHESS_TO_VIEW,handler(self,self.refresh))
	}
	return listeners
end

function PromoteLayer:onEnter( ... )
	self:_addTouchEvent()
	self:addEventListerns()
	self:_onRequest()
	manager.ViewManager:getInstance():addViewCount()
end


return PromoteLayer
