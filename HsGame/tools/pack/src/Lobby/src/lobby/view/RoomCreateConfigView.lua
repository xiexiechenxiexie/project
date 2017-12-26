
local  RoomCreateConfigView = class("RoomCreateConfigView",lib.layer.BaseDialog)
local SocketClient = require "Lobby/src/net/SocketClient"

local TagContinue = 1
local TagEnterGame = 2
function RoomCreateConfigView:ctor( ... )
	RoomCreateConfigView.super.ctor(self)
	local bg = ccui.ImageView:create(self:findImgBg(),ccui.TextureResType.plistType)
	self:addChild(bg)
	self:_onRootPanelInit(bg)
	bg:setPosition(display.width / 2,display.height / 2)
	self._bg = bg
	local size = self._bg:getContentSize()

	local button = cc.exports.lib.uidisplay.createLabelButton({
			textureType = ccui.TextureResType.plistType,
			normal = "common_big_yellow_btn.png",
			callback = handler(self,self.onClick),
			isActionEnabled = true,
			pos = cc.p(193,92),
			text = "继续创建",
			outlineColor = cc.c4b(112,45,2,255),
			outlineSize = 2,
			labPos = cc.p(0,2),
	})
	button:setTag(TagContinue)
	bg:addChild(button)

	button = cc.exports.lib.uidisplay.createLabelButton({
			textureType = ccui.TextureResType.plistType,
			normal = "common_big_blue_btn.png",
			callback = handler(self,self.onClick),
			isActionEnabled = true,
			pos = cc.p(515,92),
			text = "进入房间",
			outlineColor = cc.c4b(24,31,92,255),
			outlineSize = 2,
			labPos = cc.p(0,2),
	})
	button:setTag(TagEnterGame)
	bg:addChild(button)

	button = cc.exports.lib.uidisplay.createUIButton({
			textureType = ccui.TextureResType.localType,
			normal = "Lobby/res/common/common_btn_close.png",
			callback = handler(self,self.back),
			isActionEnabled = true,
			pos = cc.p(size.width - 30,size.height - 30)
	})
	bg:addChild(button)
end

function RoomCreateConfigView:initLabel( __tableId )
	
    local richText = GameUtils.createRichText({{Color3B = cc.c3b(224,221,245), opacity = 255, richText = lobby.CreateRoomManager:getInstance():findRoomCreateSuccessString(), fontSize = 30},
                        {Color3B = cc.c3b(254,243,123), opacity = 255, richText = "【"..__tableId.."】", fontSize = 30}})
    richText:setPosition(self._bg:getContentSize().width * 0.5,self._bg:getContentSize().height * 2 / 3)
    richText:setAnchorPoint(cc.p(0.5,0.5))
    self._bg:addChild(richText)
end

function RoomCreateConfigView:onClick( __sender )
	local tag = __sender:getTag()
	if tag == TagContinue then
		print("继续创建游戏")
		self:onCloseCallback()
		
	elseif tag == TagEnterGame then
	    local event = cc.EventCustom:new(config.EventConfig.EVENT_ENTER_GAME)
		lib.EventUtils.dispatch(event)
	end
end


function RoomCreateConfigView:onCloseCallback( ... )
	RoomCreateConfigView.super.onCloseCallback(self,...)
	--logic.LobbyManager:getInstance():LoginLobbyServer()
end

function RoomCreateConfigView:findImgBg( ... )
	return "common_little_bg.png"
end

return RoomCreateConfigView
