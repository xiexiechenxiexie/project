-- 更多界面
-- @date 2017.08.12
-- @author tangwen

local MoreView = class("MoreView", lib.layer.BaseLayer)

function MoreView:ctor()
	MoreView.super.ctor(self)
	self:enableNodeEvents() 
	self:initView()
end

function MoreView:initView()
	local size = cc.size(519, 112)

	local bg = ccui.ImageView:create("lobby_more_btn_bg.png", ccui.TextureResType.plistType)
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setPosition(0, 0)
    self:addChild(bg)
    
    local noticeBtnImg = "lobby_btn_activity.png"
    local noticeBtnImg1 = "lobby_btn_activity1.png"
    local noticeBtn = ccui.Button:create(noticeBtnImg,noticeBtnImg1,"",ccui.TextureResType.plistType)
	noticeBtn:setPosition(size.width / 5 - 15, size.height/2 + 15)
	bg:addChild(noticeBtn)
	noticeBtn:addClickEventListener(function()
		self:getParent():requestNoticeInfo()
	end)

	local signBtnImg = "lobby_more_btn_sign.png"
	local signBtnImg1 = "lobby_more_btn_sign1.png"
    local signBtn = ccui.Button:create(signBtnImg,signBtnImg1,"",ccui.TextureResType.plistType)
	signBtn:setPosition(size.width / 5 * 2 - 5, size.height/2 + 15)
	bg:addChild(signBtn)
	signBtn:addClickEventListener(function()
		self:getParent():requestSignInfo()
	end)

	local settingBtnImg = "lobby_more_btn_set.png"
	local settingBtnImg1 = "lobby_more_btn_set1.png"
    local settingBtn = ccui.Button:create(settingBtnImg,settingBtnImg1,"",ccui.TextureResType.plistType)
	settingBtn:setPosition(size.width / 5 * 3 + 5, size.height/2 + 15)
	bg:addChild(settingBtn)
	settingBtn:addClickEventListener(function()
		local setView = require("lobby/view/SetView").new(0)
		self:getParent():addChild(setView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
	end)

	local serverBtnImg = "lobby_btn_service.png"
	local serverBtnImg1 = "lobby_btn_service1.png"
    local serverBtnImg = ccui.Button:create(serverBtnImg,serverBtnImg1,"",ccui.TextureResType.plistType)
	serverBtnImg:setPosition(size.width / 5 * 4 + 15, size.height/2 + 15)
	bg:addChild(serverBtnImg)
	serverBtnImg:addClickEventListener(function()
	    logic.LobbyManager:getInstance():requestServiceData(function( result )
	        if result then
	        	local serviceView = require("lobby/view/ServiceView").new(result)
				self:getParent():addChild(serviceView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
	        end
	    end)
	end)
end

function MoreView:onEnter()
	self:_addTouchEvent()
	self:addEventListerns()
end

function MoreView:onExit()
	self:_removeTouchEvent()
	self:removeEventListeners()
end

function MoreView:onTouchEnded( )
	self:getParent():setMoreBtnTexture()
	GameUtils.removeNode(self)
end

return MoreView