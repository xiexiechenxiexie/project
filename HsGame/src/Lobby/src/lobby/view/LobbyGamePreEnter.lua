--[[--
@author:设计为 场次界面  加入房间 开房间界面 共享背景界面
]]

local LobbyGamePreEnter = class("LobbyGamePreEnter",cc.exports.lib.layer.BaseLayer)

function LobbyGamePreEnter:ctor( ... )
	print("LobbyGamePreEnter:ctor")
	LobbyGamePreEnter.super.ctor(self)
	self:_addBg()
	self:_addTopLayer()
	-- self:_addBackBtn()
	-- 添加顶部信息栏
	self:_addTopView()
end

function LobbyGamePreEnter:_addTopView( ... )
	local LobbyTopInfoView =  require("lobby/view/LobbyTopInfoView")
	local topInfoView = LobbyTopInfoView:create(LobbyTopInfoView.LobbyMenu)
	topInfoView:setBtnBackCallback(handler(self,self._onBackBtnClick))
	self:addChild(topInfoView,5)
end

function LobbyGamePreEnter:_addBg( ... )
	local imgBg = ccui.ImageView:create(self:findLobbyGameEnterBg())
	self:addChild(imgBg)
	imgBg:setPosition(display.width / 2,display.height / 2)
end

function LobbyGamePreEnter:_addTopLayer( ... )
	--todo://添加顶部房卡钻石Layer
	
end

function LobbyGamePreEnter:_addBackBtn( ... )
	local imgFile = self:_findBackBtnFile()
	local button = ccui.Button:create(imgFile,imgFile,imgFile)
	button:setPressedActionEnabled(true)
	button:addClickEventListener(handler(self,self._onBackBtnClick))
	self:addChild(button)
	button:setPosition(48,display.height-48)
end

function LobbyGamePreEnter:findLobbyGameEnterBg( ... )
	return "res/GameLayout/Lobby/LobbyEnter/imgLobbyEnterGameBg.png"
end

function LobbyGamePreEnter:_findBackBtnFile( ... )
	return "res/common/btnBack.png"
end

function LobbyGamePreEnter:_onBackBtnClick( __sender,__type)
	self:removeFromParent()
end


return LobbyGamePreEnter