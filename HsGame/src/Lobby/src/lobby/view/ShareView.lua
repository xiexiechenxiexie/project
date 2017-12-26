-- 分享界面
-- @date 2017..05
-- @author tangwen

local ShareView = class("ShareView", lib.layer.Window)

ShareView.LoginType_Guest            = 0     -- 游客登录
ShareView.LoginType_Wechat           = 1     -- 微信登录
ShareView.loginType_QQ               = 2     -- QQ登录

function ShareView:ctor(__type, __shareTab)
	ShareView.super.ctor(self,ConstantsData.WindowType.WINDOW_SMALL)
	self._shareType = __type
	self._shareTab = __shareTab
	self:initView()
end

function ShareView:initView()
    local bg = self._root
    self._bg = bg
    local bgSize = bg:getContentSize()

    if self.LoginType_Wechat == self._shareType then --微信
    	for i=3,4 do
    		local record = self:createIconNode(i)
    		record:setPosition(-60 + (i-2)*290,bgSize.height/2)
    		bg:addChild(record)
    	end
	elseif self.loginType_QQ == self._shareType then -- qq
		for i=1,2 do
    		local record = self:createIconNode(i)
    		record:setPosition(-60 + i*290,bgSize.height/2)
    		bg:addChild(record)
    	end
	end 
end

function ShareView:createIconNode(__index)
	local size = cc.size(179, 173)
	local record = ccui.Layout:create()
	record.type = __index

	local bgBtnImg = "Share_icon_bg.png"
	local bgBtn = lib.uidisplay.createUIButton({
		normal = bgBtnImg,
		textureType = ccui.TextureResType.plistType,
		isActionEnabled = true,
		callback = function() 
			self:requestShareByIndex(record.type)
		end
		})

	bgBtn:setPosition(cc.p(0,0))
	record:addChild(bgBtn)

    local iconStr = ""
    local iconText = ""
    if __index == ConstantsData.SharaIconIndex.QQ then
		iconStr = "Share_QQ_icon.png"
		iconText = "好友/群"
	elseif __index == ConstantsData.SharaIconIndex.QQ_ZONE then
		iconStr = "Share_QQZONE_icon.png"
		iconText = "QQ空间"
	elseif __index == ConstantsData.SharaIconIndex.WECHAT then
		iconStr = "Share_WeChat_icon.png"
		iconText = "好友/群"
	elseif __index == ConstantsData.SharaIconIndex.WECHAT_FRIEND then
		iconStr = "Share_WeChat_Friend_icon.png"
		iconText = "朋友圈"		
    end

    local icon = ccui.ImageView:create(iconStr, ccui.TextureResType.plistType)
    icon:setPosition(size.width/2,size.height/2)
	bgBtn:addChild(icon)

	local IconText = cc.Label:createWithTTF(iconText,GameUtils.getFontName(),28)
    IconText:setAnchorPoint(cc.p(0.5, 0.5))
    IconText:setPosition(size.width/2, - 30)
    bgBtn:addChild(IconText)

    return record
end

function ShareView:requestShareByIndex(__index)
	if __index == ConstantsData.SharaIconIndex.QQ then -- QQ好友/群
		if ShareManager.ShareContentType_URL == self._shareTab.shareContentType then
			ShareManager:shareUrlToQQ(self._shareTab.title, self._shareTab.des, self._shareTab.url, self._shareTab.callback, self._shareTab.urlImg)
		elseif ShareManager.ShareContentType_IMAGE == self._shareTab.shareContentType then
			ShareManager:shareImageToQQ(self._shareTab.callback, self._shareTab.imgPath)
		else
			self._shareTab.callback(string.format("{\"result\": %d, \"plat\": %d, \"resultCode\": %d }", ShareManager.ShareResult_Fail, ShareManager.ShareType_QQ, 6))
		end
	elseif __index == ConstantsData.SharaIconIndex.QQ_ZONE then -- QQ空间
		if ShareManager.ShareContentType_URL == self._shareTab.shareContentType then
			ShareManager:shareUrlToQQZone(self._shareTab.title, self._shareTab.des, self._shareTab.url, self._shareTab.callback, self._shareTab.urlImg)
		elseif ShareManager.ShareContentType_IMAGE == self._shareTab.shareContentType then
			ShareManager:shareImageToQQZone(self._shareTab.callback, self._shareTab.imgPath)
		else
			self._shareTab.callback(string.format("{\"result\": %d, \"plat\": %d, \"resultCode\": %d }", ShareManager.ShareResult_Fail, ShareManager.ShareType_QQ_ZONE, 6))
		end
	elseif __index == ConstantsData.SharaIconIndex.WECHAT then -- 微信好友/群
		if ShareManager.ShareContentType_URL == self._shareTab.shareContentType then
			ShareManager:shareUrlToWechat(self._shareTab.title, self._shareTab.des, self._shareTab.url, self._shareTab.callback, self._shareTab.urlImg)
		elseif ShareManager.ShareContentType_IMAGE == self._shareTab.shareContentType then
			ShareManager:shareImageToWechat(self._shareTab.callback, self._shareTab.imgPath)
		else
			self._shareTab.callback(string.format("{\"result\": %d, \"plat\": %d, \"resultCode\": %d }", ShareManager.ShareResult_Fail, ShareManager.ShareType_WECHAT, 6))
		end
	elseif __index == ConstantsData.SharaIconIndex.WECHAT_FRIEND then -- 微信朋友圈
		if ShareManager.ShareContentType_URL == self._shareTab.shareContentType then
			ShareManager:shareUrlToWechatCircle(self._shareTab.title, self._shareTab.des, self._shareTab.url, self._shareTab.callback, self._shareTab.urlImg)
		elseif ShareManager.ShareContentType_IMAGE == self._shareTab.shareContentType then
			ShareManager:shareImageToWechatCircle(self._shareTab.callback, self._shareTab.imgPath)
		else
			self._shareTab.callback(string.format("{\"result\": %d, \"plat\": %d, \"resultCode\": %d }", ShareManager.ShareResult_Fail, ShareManager.ShareType_WECHAT, 6))
		end
	else
		self._shareTab.callback(string.format("{\"result\": %d, \"plat\": %d, \"resultCode\": %d }", ShareManager.ShareResult_Fail, ShareManager.ShareType_WECHAT, 9))
    end
    self:removeFromParent()
end

function ShareView:onEnter( ... )
	ShareView.super.onEnter(self)
end

function ShareView:onExit( ... )

end

return ShareView