--[[--
@author :fly
]]




local CREATE_ROOM_DIR = ""
local ChessesDetail = require "ChessesDetail"
local HelpView = require "HelpView"
local MyRoomInfoLayer = class("MyRoomInfoLayer",lib.layer.BaseLayer)
local TAG_PROGRESS = 1
local TAG_ENDED = 2
local TAG_JOIN_CHESS = 3
MyRoomInfoLayer._roomInfoLayer = nil
MyRoomInfoLayer._roomListView = nil

MyRoomInfoLayer._chessInfoLayer = nil
MyRoomInfoLayer._chessListView = nil
MyRoomInfoLayer._slideButtonImgs = {[TAG_PROGRESS] = "btnProgress.png",[TAG_ENDED] = "btnEnded.png"}

MyRoomInfoLayer._inputInfo = {} 

function MyRoomInfoLayer:ctor( ... )
	print("MyRoomInfoLayer:ctor")
	MyRoomInfoLayer.super.ctor(self)

	self:_init()
end

function MyRoomInfoLayer:onListersInitCallback( ... )
	local listeners = {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_ROOM_PROGRESS_TO_VIEW,handler(self,self._refreshProgressLayer)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_ROOM_ENDED_TO_VIEW,handler(self,self._refreshEndedLayer))
	}
	return listeners
end

function MyRoomInfoLayer:onEnter( ... )
	self:addEventListerns()
	self:_slideToProgress()
end

function MyRoomInfoLayer:onExit( ... )
	self:removeEventListeners()
end


function MyRoomInfoLayer:_init(  )
	local dir = CREATE_ROOM_DIR
	local imgProgressEnded = dir .. "imgProgressEnded.png"
	imgProgressEnded = ccui.ImageView:create(imgProgressEnded,ccui.TextureResType.plistType)
	self:addChild(imgProgressEnded)
	imgProgressEnded:setPosition(396,530)

	local imgProgressFlag = "imgProgressFlag.png"
	imgProgressFlag = ccui.ImageView:create(imgProgressFlag,ccui.TextureResType.plistType)
	imgProgressEnded:addChild(imgProgressFlag)
	imgProgressFlag:setVisible(true)

	local imgEndedFlag = "imgEndedFlag.png"
	imgEndedFlag = ccui.ImageView:create(imgEndedFlag,ccui.TextureResType.plistType)
	imgProgressEnded:addChild(imgEndedFlag)
	imgEndedFlag:setVisible(false)

	local slideImg = CREATE_ROOM_DIR .. self._slideButtonImgs[TAG_PROGRESS]

	local button = ccui.Button:create(slideImg,slideImg,slideImg,ccui.TextureResType.plistType)
	imgProgressEnded:addChild(button)
	button:addClickEventListener(function ( __sender)
			self:_slideToProgress(__sender)
			imgProgressFlag:setVisible(true)
			imgEndedFlag:setVisible(false)
	end)
	local size = button:getContentSize()
	local x = size.width / 2 + 5 + 67
	local y = imgProgressEnded:getContentSize().height * 0.5 - 5
	button:setPosition(x,y)
	imgProgressFlag:setPosition(x,y)

	slideImg = CREATE_ROOM_DIR .. self._slideButtonImgs[TAG_ENDED]

	button = ccui.Button:create(slideImg,slideImg,slideImg,ccui.TextureResType.plistType)
	imgProgressEnded:addChild(button)
	button:addClickEventListener(function ( __sender)
			self:_sildeToEnded(__sender)
			imgProgressFlag:setVisible(false)
			imgEndedFlag:setVisible(true)
		end)
	local size = button:getContentSize()
	x = imgProgressEnded:getContentSize().width -  size.width / 2 - 5 - 67
	y = imgProgressEnded:getContentSize().height * 0.5 - 5
	button:setPosition(x,y)
	imgEndedFlag:setPosition(x,y)

end

function MyRoomInfoLayer:_sildeToEnded( __targetNode )
	print("MyRoomInfoLayer:_sildeToEnded")
	if self._roomInfoLayer then self._roomInfoLayer:setVisible(false) end
	if self._chessInfoLayer then self._chessInfoLayer:setVisible(true) end
	-- self:_refreshEndedLayer()
	lobby.CreateRoomManager:getInstance():requestGameEnded()
	lobby.CreateRoomManager:getInstance():setSelection(TAG_ENDED)
end

function MyRoomInfoLayer:_slideToProgress( __targetNode )
	print("MyRoomInfoLayer:_slideToProgress")
	if self._roomInfoLayer then self._roomInfoLayer:setVisible(true) end
	if self._chessInfoLayer then self._chessInfoLayer:setVisible(false) end
	-- self:_refreshProgressLayer()
	lobby.CreateRoomManager:getInstance():requestGameProgress()
	lobby.CreateRoomManager:getInstance():setSelection(TAG_PROGRESS)

end

function MyRoomInfoLayer:_initItemBgtn( __data,__imgFile,__pos,__type ,__anchorPoint,__isItemBgBtn)
	local button = nil
	local callback = nil
	if __type ==  TAG_PROGRESS then
		if __isItemBgBtn then 
			callback = handler(self,self._onGuanZhanBtnClick)
		else
			if __data.peopleNumOfRoom < __data.capityPeopleNumOfRoom then
				callback = handler(self,self._onInviteBtnClick) 
			else
				callback = handler(self,self._onGuanZhanBtnClick)	
			end
		end
	elseif __type == TAG_ENDED then
		callback = handler(self,self._onLookForDetail)
	elseif __type == TAG_JOIN_CHESS then
		callback = handler(self,self._onLookForDetail)
	end
	button = cc.exports.lib.uidisplay.createUIButton({
			textureType = ccui.TextureResType.plistType,
			normal = __imgFile,
			callback = callback	,
			isActionEnabled = false,
			pos = __pos
	})
	button:setAnchorPoint(__anchorPoint)
	return button
end

function MyRoomInfoLayer:_createBaseItem( __data,__type,__index)
	local contentNode = ccui.Widget:create()
	contentNode:setContentSize(cc.size(773,127))

	local imgBg = CREATE_ROOM_DIR .. "imgMyRoomItemBg.png"
	local button = self:_initItemBgtn(__data,imgBg,cc.p(752 /2 + 20,10),__type,cc.p(0.5,0),true)
	contentNode:addChild(button)
	button:setTag(__index)

	local imgCreateRoomItemLine = CREATE_ROOM_DIR .. "imgCreateRoomItemLine.png"
	imgCreateRoomItemLine = ccui.ImageView:create(imgCreateRoomItemLine,ccui.TextureResType.plistType)
	imgCreateRoomItemLine:setPosition(20,64)
	contentNode:addChild(imgCreateRoomItemLine)
	return contentNode
end


function MyRoomInfoLayer:_createProgressItem(__data,__index )
	local ManagerClazz = cc.exports.lobby.CreateRoomManager
	local layout = self:_createBaseItem(__data,TAG_PROGRESS,__index)
	local params = {{
		fontName = GameUtils.getFontName(),
		fontSize = 24,
		text = __data.timeOfCreateRoom,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(209,205,247, 255),
		pos = cc.p(34,107),
		anchorPoint = cc.p(0,0.5)
		}
		,{
		fontName = GameUtils.getFontName(),
		fontSize = 30,
		text = __data.roomId,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(209,205,247, 255),
		pos = cc.p(115,44),
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 30,
		text = __data.leftGameRound,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(209,205,247, 255),
		pos = cc.p(260,44),
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 30,
		text = ManagerClazz:getInstance():findCostSeatLanguage(__data),
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(0,240,255, 255),
		pos = cc.p(378,44),
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 28,
		text = ManagerClazz:getInstance():findNumOfRoomString(__data),
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,248,187, 255),
		pos = cc.p(513,60),
		}
	}

	for i=1,#params do
		local param = params[i]
		local label = cc.exports.lib.uidisplay.createLabel(param)
		layout:addChild(label)
	end

	local imgBarBg = ccui.ImageView:create("imgBarBg.png",ccui.TextureResType.plistType)
	imgBarBg:setPosition(513,32)
	layout:addChild(imgBarBg)

	local loadingBar = ccui.LoadingBar:create("imgBar.png",ccui.TextureResType.plistType,__data.peopleNumOfRoom / __data.capityPeopleNumOfRoom * 100)
	imgBarBg:addChild(loadingBar)
	loadingBar:setPosition(imgBarBg:getContentSize().width * 0.5,imgBarBg:getContentSize().height * 0.5)
	loadingBar:setPercent(__data.peopleNumOfRoom / __data.capityPeopleNumOfRoom * 100)

	local button = nil
	if __data.peopleNumOfRoom < __data.capityPeopleNumOfRoom then  
		button = cc.exports.lib.uidisplay.createLabelButton({
            textureType = ccui.TextureResType.plistType,
            normal = "common_small_green_btn.png",
            callback = handler(self,self._onInviteBtnClick),
            isActionEnabled = true,
            pos = cc.p(670,44),
            text = "邀请好友",
            outlineColor = cc.c4b(24,73,30,255),
            outlineSize = 2,
            labPos = cc.p(0,2),
            scale = 0.5,
    	})
	else
		button = cc.exports.lib.uidisplay.createLabelButton({
            textureType = ccui.TextureResType.plistType,
            normal = "common_small_yellow_btn.png",
            callback = handler(self,self._onGuanZhanBtnClick),
            isActionEnabled = true,
            pos = cc.p(670,44),
            text = "观 战",
            outlineColor = cc.c4b(112,45,2,255),
            outlineSize = 2,
            labPos = cc.p(0,2),
            scale = 0.5,
    	})
	end
	button:setTag(__index)
	layout:addChild(button)
	return layout
end

function MyRoomInfoLayer:_refreshProgressLayer( ... )
	print("MyRoomInfoLayer:_refreshProgressLayer")
	if self._roomInfoLayer == nil then
		self._roomInfoLayer = cc.Layer:create()
		self:addChild(self._roomInfoLayer)
		local imgMyRoomTitle = CREATE_ROOM_DIR .. "imgMyRoomTitle.png"
		imgMyRoomTitle = ccui.ImageView:create(imgMyRoomTitle,ccui.TextureResType.plistType)
		imgMyRoomTitle:setAnchorPoint(cc.p(0,0))
		imgMyRoomTitle:setPosition(12,445)
		self._roomInfoLayer:addChild(imgMyRoomTitle)

		self._roomListView = ccui.ListView:create()
		self._roomListView:setContentSize(cc.size(784,402))
		self._roomListView:setAnchorPoint(cc.p(0,0))
		self._roomListView:setDirection(ccui.ListViewDirection.vertical)
		self._roomInfoLayer:addChild(self._roomListView)
		self._roomListView:setPosition(17,42)

		local str = "房间ID        剩余局数   收费入座     房间人数"
		local labelTip = cc.Label:createWithTTF(str,GameUtils.getFontName(), 24)
		labelTip:setPosition(100,12)
		labelTip:setAnchorPoint(cc.p(0,0))
		labelTip:setColor(cc.c4b(180,168,240,255))
		imgMyRoomTitle:addChild(labelTip)
	end

	local ManagerClazz = cc.exports.lobby.CreateRoomManager
	local progressItems = ManagerClazz:getInstance():findProgressRooms()
	self._roomListView:removeAllChildren()
	for i=1,#progressItems do
		local data = progressItems[i]
		local itemNode = self:_createProgressItem(data,i)
		self._roomListView:pushBackCustomItem(itemNode)
	end
end

function MyRoomInfoLayer:_createEndedItem( __data,__index)
	local ManagerClazz = cc.exports.lobby.CreateRoomManager
	local layout = self:_createBaseItem(__data,TAG_ENDED,__index)
	local params = {{
		fontName = GameUtils.getFontName(),
		fontSize = 14,
		text = __data.timeOfCreateRoom,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(209,205,247, 255),
		pos = cc.p(34,107),
		anchorPoint = cc.p(0,0.5)
		}
		,{
		fontName = GameUtils.getFontName(),
		fontSize = 19,
		text = ManagerClazz:getInstance():findRoomIdString(" ") .. __data.roomId,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(209,205,247, 255),
		pos = cc.p(65,44),
		anchorPoint = cc.p(0,0.5)
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 20,
		text = ManagerClazz:getInstance():findChessNumString("    ") .. __data.gameRound,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(209,205,247, 255),
		pos = cc.p(290,44),
		anchorPoint = cc.p(0,0.5)
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 23,
		text = ManagerClazz:getInstance():findJoinNumString() .. __data.peopleNumOfRoom,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(209,205,247, 255),
		pos = cc.p(458,44),
		anchorPoint = cc.p(0,0.5)
		}
	}

	for i=1,#params do
		local param = params[i]
		local label = cc.exports.lib.uidisplay.createLabel(param)
		layout:addChild(label)
	end 

	local button = cc.exports.lib.uidisplay.createLabelButton({
			textureType = ccui.TextureResType.plistType,
			normal = "common_small_blue_btn.png",
			callback = handler(self,self._onLookForDetail),
			isActionEnabled = true,
			pos = cc.p(670,44),
			text = "查看详情",
			outlineColor = cc.c4b(24,31,92,255),
			outlineSize = 2,
			labPos = cc.p(0,2),
			scale = 0.5,
	})
	button:setTag(__index)
	layout:addChild(button)
	return layout
end

function MyRoomInfoLayer:_refreshEndedLayer( __data )
	print("MyRoomInfoLayer:_refreshEndedLayer")
	local ManagerClazz = cc.exports.lobby.CreateRoomManager
	if self._chessInfoLayer == nil then
			self._chessInfoLayer = cc.Layer:create()
			self:addChild(self._chessInfoLayer)
		local labelConfig =	{
			fontName = GameUtils.getFontName(),
			fontSize = 23,
			text = ManagerClazz:getInstance():findLastChessString(),
			alignment = cc.TEXT_ALIGNMENT_CENTER,
			color = cc.c4b(115,99,192, 255),
			pos = cc.p(60,465),
		}
		local label = cc.exports.lib.uidisplay.createLabel(labelConfig)
		self._chessInfoLayer:addChild(label)

		self._chessListView = ccui.ListView:create()
		self._chessListView:setContentSize(cc.size(784,402))
		self._chessListView:setAnchorPoint(cc.p(0,0))
		self._chessListView:setDirection(ccui.ListViewDirection.vertical)
		self._chessInfoLayer:addChild(self._chessListView)
		self._chessListView:setPosition(17,42)
	end

	self._chessListView:removeAllChildren()
	local items = ManagerClazz:getInstance():findEndedRooms()
	for i=1,#items do
		local data = items[i]
		local itemNode = self:_createEndedItem(data,i)
		self._chessListView:pushBackCustomItem(itemNode)
	end
end


function MyRoomInfoLayer:refresh( ... )

end

function MyRoomInfoLayer:onEnterGame( __sender )
	lobby.CreateRoomManager:getInstance():onJoinGame(__sender:getTag())
end

function MyRoomInfoLayer:_onGuanZhanBtnClick( __sender )
	lobby.CreateRoomManager:getInstance():onVisiteCallback(__sender:getTag())
end

function MyRoomInfoLayer:_onInviteBtnClick( __sender )
	lobby.CreateRoomManager:getInstance():onInviteCallback(__sender:getTag())
end

function MyRoomInfoLayer:_onLookForDetail( __sender )
	print("查看详情",__sender:getTag())
	lobby.CreateRoomManager:getInstance():setClickIndex(__sender:getTag())
	local data = lobby.CreateRoomManager:getInstance():findSelectedData()
	lobby.CreateRoomManager:getInstance():requestChessDetail(data.historyRoomId,handler(self,self._onDetailDetailRsp))
end

function MyRoomInfoLayer:_onDetailDetailRsp( ... )
	local view = ChessesDetail:create()
	cc.Director:getInstance():getRunningScene():addChild(view)
end




local MyChessInfoLayer = class("MyChessInfoLayer",MyRoomInfoLayer)


function MyChessInfoLayer:ctor( ... )
	MyChessInfoLayer.super.ctor(self,...)
	self:refresh()
end

function MyChessInfoLayer:onEnter( ... )
	self:addEventListerns()
	local ManagerClazz = cc.exports.lobby.CreateRoomManager
	ManagerClazz:getInstance():requestGameMyChess()
end

function MyChessInfoLayer:_init(  )
	
end

function MyChessInfoLayer:onListersInitCallback( ... )
	local listeners = {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_ROOM_JOIN_CHESS_TO_VIEW,handler(self,self.refresh))
	}
	return listeners
end

function MyChessInfoLayer:_createJoinChessItems( __data,__index )
	local ManagerClazz = cc.exports.lobby.CreateRoomManager
	local layout = self:_createBaseItem(__data,TAG_JOIN_CHESS,__index)
	local params = {{
		fontName = GameUtils.getFontName(),
		fontSize = 14,
		text = __data.timeOfCreateRoom,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(209,205,247, 255),
		pos = cc.p(34,107),
		anchorPoint = cc.p(0,0.5)
		}
		,{
		fontName = GameUtils.getFontName(),
		fontSize = 19,
		text = ManagerClazz:getInstance():findRoomIdString(" ") .. __data.roomId,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(209,205,247, 255),
		pos = cc.p(65,44),
		anchorPoint = cc.p(0,0.5)
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 20,
		text = ManagerClazz:getInstance():findCreatorString(__data) ,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(209,205,247, 255),
		pos = cc.p(250,44),
		anchorPoint = cc.p(0,0.5)
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 23,
		text = ManagerClazz:getInstance():findScoreString(__data) ,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(209,205,247, 255),
		pos = cc.p(458,44),
		anchorPoint = cc.p(0,0.5)
		}
	}

	for i=1,#params do
		local param = params[i]
		local label = cc.exports.lib.uidisplay.createLabel(param)
		layout:addChild(label)
	end 

	local button = cc.exports.lib.uidisplay.createLabelButton({
			textureType = ccui.TextureResType.plistType,
			normal = "common_small_blue_btn.png",
			callback = handler(self,self._onLookForDetail),
			isActionEnabled = true,
			pos = cc.p(670,44),
			text = "查看详情",
			outlineColor = cc.c4b(24,31,92,255),
			outlineSize = 2,
			labPos = cc.p(0,2),
			scale = 0.5,
	})

	button:setTag(__index)
	layout:addChild(button)
	return layout
end

function MyChessInfoLayer:refresh( ... )
	local ManagerClazz = cc.exports.lobby.CreateRoomManager
	if self._chessListView == nil  then
		local labelConfig =	{
			fontName = GameUtils.getFontName(),
			fontSize = 23,
			text = ManagerClazz:getInstance():findLastChessString(),
			alignment = cc.TEXT_ALIGNMENT_CENTER,
			color = cc.c4b(115,99,192, 255),
			pos = cc.p(60,465),
		}
		local label = cc.exports.lib.uidisplay.createLabel(labelConfig)
		self:addChild(label)

		self._chessListView = ccui.ListView:create()
		self._chessListView:setContentSize(cc.size(784,402))
		self._chessListView:setAnchorPoint(cc.p(0,0))
		self._chessListView:setDirection(ccui.ListViewDirection.vertical)
		self:addChild(self._chessListView)
		self._chessListView:setPosition(17,42)
	end
	
	self._chessListView:removeAllChildren()
	local items = ManagerClazz:getInstance():findJoinChess()
	for i=1,#items do
		local data = items[i]
		local itemNode = self:_createJoinChessItems(data,i)
		self._chessListView:pushBackCustomItem(itemNode)
	end
end

function MyChessInfoLayer:_onLookForDetail( __sender )
	print("我的牌局",__sender:getTag())
	lobby.CreateRoomManager:getInstance():setSelection(TAG_JOIN_CHESS)
	lobby.CreateRoomManager:getInstance():setClickIndex(__sender:getTag())
	local data = lobby.CreateRoomManager:getInstance():findSelectedData()
	lobby.CreateRoomManager:getInstance():requestChessDetail(data.historyRoomId,handler(self,self._onDetailDetailRsp))
end

function MyChessInfoLayer:_onDetailDetailRsp( ... )
	local view = ChessesDetail:create()
	cc.Director:getInstance():getRunningScene():addChild(view)
end



--创建房间信息
local CreateInput = class("CreateInput")
CreateInput.score = 1 --底分
CreateInput.chess = 10 --局数
CreateInput.isAutoNiu = true --是否自动算牛
CreateInput.isOpenRightToSeat = false --是否开启授权入座
CreateInput.isCostToSeat = true --是否开启收费入座
CreateInput.cost = 3 --房卡消耗
CreateInput.roomNum = 5

function CreateInput:ctor()
	self.score = 1 --底分
	self.chess = 10 --局数
	self.isAutoNiu = true --是否自动算牛
	self.isOpenRightToSeat = false --是否开启授权入座
	self.isCostToSeat = true --是否开启收费入座
	self.cost = 1 --房卡消耗
	self.roomNum = 5--房间人数
end

local LobbyGamePreEnter = require "LobbyGamePreEnter"
local CreateRoomView = class("CreateRoomView",LobbyGamePreEnter)

CreateRoomView._roomInfoLayer = nil
CreateRoomView._chessInfoLayer = nil
CreateRoomView._lbCostInLabel = nil
CreateRoomView._lbRoomCardInButton = nil
CreateRoomView._createInput = nil--创建房间信息
CreateRoomView._MAX_FLOOR_SCORE = 10
CreateRoomView._MAX_CHESS_NUM = 100
function CreateRoomView:ctor( ... )
	CreateRoomView.super.ctor(self)
	self._createInput = CreateInput.create()
	self._roomInfoLayer = nil
	self._chessInfoLayer = nil
	self:_addMyRoomAndChessPanel()
	
	local manager = cc.exports.lobby.CreateRoomManager:getInstance()
	manager:RequestPrivateTableConfig(function ( ... )
		self._createInput.chess = 10
		self._createInput.cost = manager:findRoomCardCost(self._createInput.chess)
		self:_addCreateRoomPanel()
	end)
end




function CreateRoomView:_addTabBtn( __targetNode )
	local dir = self:_findCreateRoomDir()
	local btnMyRoom0 = dir .. "btnMyRoom1.png"
	local btnMyRoom1 = dir .. "btnMyRoom0.png"

	local btnMyChess0 = dir .. "btnMyChess1.png"
	local btnMyChess1 = dir .. "btnMyChess0.png"

	local roomInfo = dir.."btnRoomInfo_bg.png"

	local myRoom = dir.."btnCreateRoom_bg.png"
	local myChess = dir.."btnCreateRoom_bg.png"

	local tabTagMyRoom = 1
	local tabTagMyChess = 2
	local topOrder = 99
	local bottomOrder = 98
	local size = __targetNode:getContentSize()

	local roomInfoBg = cc.Sprite:createWithSpriteFrameName(roomInfo)
	__targetNode:addChild(roomInfoBg)
	roomInfoBg:setPosition(375,588)

	local myRoomBg = cc.Sprite:createWithSpriteFrameName(myRoom)
	__targetNode:addChild(myRoomBg)
	myRoomBg:setPosition(31,586.5)
	myRoomBg:setVisible(true)
	myRoomBg:setAnchorPoint(0,0.5)
	local myChessBg = cc.Sprite:createWithSpriteFrameName(myChess)
	__targetNode:addChild(myChessBg)
	myChessBg:setPosition(717,586.5)
	myChessBg:setVisible(false)
	myChessBg:setAnchorPoint(1,0.5)

	local btnMyRoom =  ccui.Button:create(btnMyRoom0,btnMyRoom1,btnMyRoom0,ccui.TextureResType.plistType)
	__targetNode:addChild(btnMyRoom)
	local buttonSize = btnMyRoom:getContentSize()
	btnMyRoom:setPressedActionEnabled(false)
	btnMyRoom:setZoomScale(0)
	btnMyRoom:setPosition(buttonSize.width / 2 + 175 ,size.height + buttonSize.height / 2 + 10)


	local btnMyChess =  ccui.Button:create(btnMyChess0,btnMyChess1,btnMyChess0,ccui.TextureResType.plistType)
	__targetNode:addChild(btnMyChess)
	local buttonSize = btnMyRoom:getContentSize()
	btnMyChess:setPosition(387 + 125,size.height + buttonSize.height / 2 + 10)
	btnMyChess:setPressedActionEnabled(false)
	btnMyChess:setZoomScale(0)
	local initCallback = function ( __sender)
		local tag = __sender ~= nil and __sender:getTag() or tabTagMyRoom
		if  tag == tabTagMyRoom then
			self:_onShowMyRoom()
			btnMyRoom:setTouchEnabled(false)
			btnMyChess:setTouchEnabled(true)
			myRoomBg:setVisible(true)
			myChessBg:setVisible(false)
			-- btnMyChess:setLocalZOrder(bottomOrder)
			-- btnMyRoom:setLocalZOrder(topOrder)
			-- btnMyRoom:loadTextures(btnMyRoom1,btnMyRoom0,btnMyRoom0,ccui.TextureResType.plistType)
			-- btnMyChess:loadTextures(btnMyChess0,btnMyChess1,btnMyChess1,ccui.TextureResType.plistType)
		elseif tag == tabTagMyChess then
			self:_onShowMyChess()
			btnMyRoom:setTouchEnabled(true)
			btnMyChess:setTouchEnabled(false)
			myRoomBg:setVisible(false)
			myChessBg:setVisible(true)
			-- btnMyChess:setLocalZOrder(topOrder)
			-- btnMyRoom:setLocalZOrder(bottomOrder)
			-- btnMyRoom:loadTextures(btnMyRoom0,btnMyRoom1,btnMyRoom1,ccui.TextureResType.plistType)
			-- btnMyChess:loadTextures(btnMyChess1,btnMyChess0,btnMyChess0,ccui.TextureResType.plistType)
		end
	end

	btnMyRoom:addClickEventListener(function ( __sender ) initCallback(__sender) end)
	btnMyRoom:setTag(tabTagMyRoom)

	btnMyChess:addClickEventListener(function ( __sender ) initCallback(__sender) end)
	btnMyChess:setTag(tabTagMyChess)
	initCallback(nil)
end

function CreateRoomView:_addMyRoomAndChessPanel( ... )
	local dir = self:_findCreateRoomDir()
	local imgMyInfo = dir .. "imgMyInfo.png"
	local imgBg = ccui.Scale9Sprite:createWithSpriteFrameName(imgMyInfo,cc.rect(100,88,8,8))
	imgBg:setContentSize(cc.size(774,562))
	self:addChild(imgBg)
	imgBg:setAnchorPoint(0,0)
	imgBg:setPosition(10,15)
	self:_addTabBtn(imgBg)

	local str = "如果游戏在十分钟内没有正式开始，系统会自动解散房间并退还房卡"
	local labelTip = cc.Label:createWithTTF(str,GameUtils.getFontName(), 20)
	labelTip:setPosition(imgBg:getContentSize().width/2,15)
	labelTip:setColor(cc.c4b(133,125,190, 255))
	imgBg:addChild(labelTip)
end

function CreateRoomView:_initCreateRoomPanel( __parent )
	local manager = cc.exports.lobby.CreateRoomManager:getInstance()
	local size = __parent:getContentSize()
	local dir  = self:_findCreateRoomDir()
	local imgCreateRoom = dir .. "imgCreateRoom.png"
	imgCreateRoom = ccui.ImageView:create(imgCreateRoom,ccui.TextureResType.plistType)
	__parent:addChild(imgCreateRoom)
	imgCreateRoom:setPosition(265,size.height - 35)

	local textColor = cc.c4b(185,165,255, 255)
	local valueCOloe = cc.c4b(255,255,255,255)
	local data = manager:findSelectedData()

	local y = 368
	local params = {
		{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findMinScoreString("  "),alignment = cc.TEXT_ALIGNMENT_CENTER,color = textColor,pos = cc.p(100,514),anchorPoint = cc.p(0,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findChessNumString("  "),alignment = cc.TEXT_ALIGNMENT_CENTER,color = textColor,pos = cc.p(100,430),anchorPoint = cc.p(0,0.5)},
		
		--算牛
		{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findComNiuLabelString("      "),alignment = cc.TEXT_ALIGNMENT_CENTER,color = textColor,pos = cc.p(15,y),anchorPoint = cc.p(0,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findAutoNiuLabelString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = valueCOloe,pos = cc.p(187,y),anchorPoint = cc.p(0,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findSelfNiuLabelString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = valueCOloe,pos = cc.p(395,y),anchorPoint = cc.p(0,0.5)},
		
		--授权入座
		{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findSeatDownRightString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = textColor,pos = cc.p(15,y - 80),anchorPoint = cc.p(0,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findCloseString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = valueCOloe,pos = cc.p(187,y - 80),anchorPoint = cc.p(0,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findOpenString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = valueCOloe,pos = cc.p(395,y - 80),anchorPoint = cc.p(0,0.5)},
		
		--收费入座
		{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findCostSeatDownString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = textColor,pos = cc.p(15,y - 160),anchorPoint = cc.p(0,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findYesString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = valueCOloe,pos = cc.p(187,y - 160),anchorPoint = cc.p(0,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findNoString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = valueCOloe,pos = cc.p(395,y - 160),anchorPoint = cc.p(0,0.5)},
		
		--开房花费显示
		--{fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findCostSeatDownString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = textColor,pos = cc.p(15,y - 186),anchorPoint = cc.p(0,0.5)},
		-- {fontName = GameUtils.getFontName(),fontSize = 30,text = manager:findCostLabelString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = textColor,pos = cc.p(15,y - 186),anchorPoint = cc.p(0,0.5)},
		-- {fontName = GameUtils.getFontName(),fontSize = 30,text = "X" .. manager:findRoomCardCost(self._createInput.chess),alignment = cc.TEXT_ALIGNMENT_CENTER,color = cc.c4b(255,231,148,255),pos = cc.p(197,y - 186),anchorPoint = cc.p(0,0.5)},
	}

	local isGrantAuthorizationShow = manager:isGrantAuthorizationShow()
	local isCostSitSelectionShow = manager:isCostSitSelectionShow()
	for i=1,#params do
		local param = params[i]

		if (not isGrantAuthorizationShow and (i >= 6 and i <= 8)) or 
		   (not isCostSitSelectionShow and (i >= 9 and i <= 13)) then
		else 
		    local label = cc.exports.lib.uidisplay.createLabel(param)
			__parent:addChild(label)
			-- if i == #params or i == #params -1 then
			-- 	if i == #params then
			-- 		self._lbCostInLabel = label
			-- 	end
			-- 	self._costWidgetContainer = self._costWidgetContainer or {}
			-- 	self._costWidgetContainer[i] = label 
			-- end 
		end
	end

	-- local iconRoomCard = ccui.ImageView:create("res/common/iconRoomCard.png",ccui.TextureResType.localType)
	-- __parent:addChild(iconRoomCard)
	-- iconRoomCard:setPosition(cc.p(177,y - 186))
	-- iconRoomCard:setVisible(isCostSitSelectionShow)

	self._costWidgetContainer = self._costWidgetContainer or {}
	-- self._costWidgetContainer["iconRoomCard"] = iconRoomCard 

	local imgCreateRoomLine = ccui.ImageView:create("imgCreateRoomLine.png",ccui.TextureResType.plistType)
	__parent:addChild(imgCreateRoomLine)
	imgCreateRoomLine:setPosition(cc.p(size.width * 0.5,400))



	local btnRadioBg = "btnRadioBg.png"
	local btnRadioSelected =  "btnRadioSelected.png"
	
	cc.exports.lib.uidisplay.createRadioGroup({
		groupPos = cc.p(167,y),
		parent = __parent,
		fileSelect = btnRadioSelected,
		fileUnselect = btnRadioBg,
		num = 2,
		textureType = ccui.TextureResType.plistType,
		poses = {cc.p(167,y),cc.p(375,y)},
		callback = handler(self,self._onCalculateRadioGroupClick)
	})
	self._createInput.isAutoNiu = true

	if  isGrantAuthorizationShow  then
		local height = y - 80
		cc.exports.lib.uidisplay.createRadioGroup({
			groupPos = cc.p(167,height),
			parent = __parent,
			fileSelect = btnRadioSelected,
			fileUnselect = btnRadioBg,
			num = 2,
			textureType = ccui.TextureResType.plistType,
			poses = {cc.p(167,height),cc.p(375,height)},
			callback = handler(self,self._onOpenClosedRadioGroupClick)
		})
		self._createInput.isOpenRightToSeat = true
	end

	if  isCostSitSelectionShow  then 
		local height = y - 160	
		cc.exports.lib.uidisplay.createRadioGroup({
			groupPos = cc.p(167,height),
			parent = __parent,
			fileSelect = btnRadioSelected,
			fileUnselect = btnRadioBg,
			num = 2,
			textureType = ccui.TextureResType.plistType,
			poses = {cc.p(167,height),cc.p(375,height)},
			callback = handler(self,self._onYesNoRadioGroupClick)
		})
		self._createInput.isCostToSeat = true
	end

	local button = cc.exports.lib.uidisplay.createLabelButton({
			textureType = ccui.TextureResType.plistType,
			normal = "common_big_blue_btn.png",
			callback = handler(self,self._onCreateRoomClick),
			isActionEnabled = true,
			pos = cc.p(271,98),
			text = "开房",
			outlineColor = cc.c4b(24,31,92,255),
			outlineSize = 2,
			labPos = cc.p(-70,2),
	})
	__parent:addChild(button)

	local sp = cc.Sprite:createWithSpriteFrameName("btnCreateRoomBg.png")
	sp:setPosition(button:getContentSize().width/2+50,button:getContentSize().height/2+4)
	button:addChild(sp)


	local iconRoomCard = ccui.ImageView:create("res/common/iconRoomCard.png",ccui.TextureResType.localType)
	button:addChild(iconRoomCard)
	iconRoomCard:setPosition(cc.p(165,button:getContentSize().height * 0.5 + 2))
	local param = {fontName = GameUtils.getFontName(),fontSize = 30,text = "X".. self._createInput.cost,alignment = cc.TEXT_ALIGNMENT_CENTER,color = cc.c4b(255,231,148,255),pos = cc.p(184,button:getContentSize().height * 0.5),anchorPoint = cc.p(0,0.5)}
	local label = cc.exports.lib.uidisplay.createLabel(param)
	button:addChild(label)
	self._lbRoomCardInButton = label


	local button = cc.exports.lib.uidisplay.createUIButton({
			textureType = ccui.TextureResType.localType,
			normal = "res/common/btnHelp.png",
			callback = handler(self,self._onBtnHelpClick),
			isActionEnabled = true,
			pos = cc.p(size.width -43,42)
	})
	__parent:addChild(button)

	local node = cc.exports.lib.uidisplay.createAddMinusNode({
		imgBg = "imgAddMinus.png",
		callback = handler(self,self._onAddMinsScoreClick),
		imgMinus = "btnMinus0.png",
		imgMinusPrssed = "btnMinus1.png",
		imgMinusDisabled = "btnMinus1.png",
		imgMinusSize = cc.size(50,39),
		imgAdd = "btnAdd0.png",
		imgAddPrssed = "btnAdd1.png",
		imgAddDisabled = "btnAdd1.png",
		imgAddSize = cc.size(50,39),
		textureType = ccui.TextureResType.plistType,
		textSize = 30,
		textColor = cc.c4b(255,255,255,255),
		textFont = GameUtils.getFontName(),
		num = self._createInput.score,
		maxNum = self._MAX_FLOOR_SCORE,
		minNum = 1,
		dNum = 1
		})
	__parent:addChild(node)
	node:setPosition(307,size.height - 104)

	local node = cc.exports.lib.uidisplay.createAddMinusNode({
		imgBg = "imgAddMinus.png",
		callback = handler(self,self._onAddMinsChessClick),
		imgMinus = "btnMinus0.png",
		imgMinusPrssed = "btnMinus1.png",
		imgMinusDisabled = "btnMinus1.png",
		imgMinusSize = cc.size(50,39),
		imgAdd = "btnAdd0.png",
		imgAddPrssed = "btnAdd1.png",
		imgAddDisabled = "btnAdd1.png",
		imgAddSize = cc.size(50,39),
		textureType = ccui.TextureResType.plistType,
		textSize = 30,
		textColor = cc.c4b(255,255,255,255),
		textFont = GameUtils.getFontName(),
		num = self._createInput.chess,
		maxNum = self._MAX_CHESS_NUM,
		minNum = self._createInput.chess,
		dNum = 10
		})
	__parent:addChild(node)
	node:setPosition(307,size.height - 188)
	self:_onDataOnCreatePanelRefresh(self._createInput.chess)
end

--[[--
刷新消耗的房卡
]]
function CreateRoomView:_onDataOnCreatePanelRefresh( __num)
	local manager = cc.exports.lobby.CreateRoomManager:getInstance()
	local cardCost = manager:findRoomCardCost(__num)
	if self._createInput.isCostToSeat then 
		cardCost = cardCost / 3
	end
	self._createInput.cost = cardCost
	if self._lbCostInLabel then self._lbCostInLabel:setString("X" .. cardCost) end
	if self._lbRoomCardInButton then self._lbRoomCardInButton:setString("X" .. cardCost) end
end

function CreateRoomView:_onAddMinsScoreClick( __num,__label)
	print("_onAddMinsScoreClick",__num,CreateRoomView._MAX_FLOOR_SCORE)
	if __num > CreateRoomView._MAX_FLOOR_SCORE then 
		__num = CreateRoomView._MAX_FLOOR_SCORE
	end
	self._createInput.score = __num
	__label:setString(""..__num)
end

function CreateRoomView:_onAddMinsChessClick( __num,__label )
	
	if __num > self._MAX_CHESS_NUM then __num = self._MAX_CHESS_NUM end
	__label:setString(""..__num)
	--多少局对应多少房卡
	self:_onDataOnCreatePanelRefresh(__num)
	self._createInput.chess = __num
	print("_onAddMinsChessClick",self._createInput.chess,CreateRoomView._MAX_CHESS_NUM)
	-- local manager = cc.exports.lobby.CreateRoomManager:getInstance()
	-- local cardCost = manager:findRoomCardCost(__num)
	-- self._createInput.cost = cardCost
end


function CreateRoomView:_onCalculateRadioGroupClick( __selectRadioButton,__index,_eventType )
	print("_onCalculateRadioGroupClick",__selectRadioButton,__index,_eventType)
	if __index == 0 then
		print("选择了自动计算")
		self._createInput.isAutoNiu = true
	else
		print("选择了手动计算")	
		self._createInput.isAutoNiu = false
	end
end

--是否开启授权入座
function CreateRoomView:_onOpenClosedRadioGroupClick( __selectRadioButton,__index,_eventType )
	print("_onOpenClosedRadioGroupClick",__selectRadioButton,__index,_eventType)
	if __index == 0 then
		print("open")
		self._createInput.isOpenRightToSeat = true
	else
		print("cloase")	
		self._createInput.isOpenRightToSeat = false
	end
end

--是否收费入座
function CreateRoomView:_onYesNoRadioGroupClick( __selectRadioButton,__index,_eventType )
	print("_onYesNoRadioGroupClick",__selectRadioButton,__index,_eventType)
	if __index == 0 then
		print("yes")
		for k,v in pairs(self._costWidgetContainer) do
			v:show()
		end
		self._createInput.isCostToSeat = true
	else
		for k,v in pairs(self._costWidgetContainer) do
			v:hide()
		end
		self._createInput.isCostToSeat = false
	end
	self:_onDataOnCreatePanelRefresh(self._createInput.chess)
end

function CreateRoomView:_onCreateRoomClick( ... )
	--创建房间信息接口调用
	print("_onCreateRoomClick")
	self:_requestCreateRoom()

end

function CreateRoomView:_requestCreateRoom( ... )
	local manager = cc.exports.lobby.CreateRoomManager:getInstance()
	if not Mall.MallManager.checkNeedGotoMallBuyRoomCard(manager:findNotEnoughRoomCardString(), self._createInput.cost) then 
		
		print(manager:findActGameId())
		manager:requestCreateRoom( self._createInput,manager:findActGameId(),self._createInput.roomNum)	
	end
end

function CreateRoomView:_onBtnHelpClick( ... )
	local helpView = HelpView.new()
	cc.Director:getInstance():getRunningScene():addChild(helpView)
end

local RoomCreateConfigView = require "RoomCreateConfigView"
function CreateRoomView:_onCreateRoomShowCallback( __event)
	local createRoom = RoomCreateConfigView:create()
	createRoom:initLabel(__event._usedata.tableId)
	manager.UserManager:getInstance():refreshUserInfo()
	cc.Director:getInstance():getRunningScene():addChild(createRoom)
	cc.exports.lobby.CreateRoomManager:getInstance():requestGameProgress()
end

function CreateRoomView:_addCreateRoomPanel( ... )
	local dir = self:_findCreateRoomDir()
	local imgCreateRoomPanel = dir .. "imgCreateRoomPanel.png"
	local imgBg = ccui.Scale9Sprite:createWithSpriteFrameName(imgCreateRoomPanel,cc.rect(100,140,4,4))
	imgBg:setContentSize(cc.size(518,618))
	self:addChild(imgBg)
	imgBg:setAnchorPoint(1,0)
	imgBg:setPosition(display.width - 15,15)
	self:_initCreateRoomPanel(imgBg)
end

function CreateRoomView:_onShowMyRoom( ... )
	print("CreateRoomView:_onShowMyRoom")
	if self._roomInfoLayer == nil then 
		self._roomInfoLayer = MyRoomInfoLayer.create()
		self:addChild(self._roomInfoLayer)
	end 
	self._roomInfoLayer:setVisible(true) 
	self._roomInfoLayer:refresh()
	if self._chessInfoLayer then  self._chessInfoLayer:setVisible(false) end 
end

function CreateRoomView:_onShowMyChess( ... )
	print("CreateRoomView:_onShowMyChess")
	if self._chessInfoLayer == nil then 
		self._chessInfoLayer = MyChessInfoLayer.create()
		self:addChild(self._chessInfoLayer)
		print("create chess layer")
	end 
	if self._roomInfoLayer then  self._roomInfoLayer:setVisible(false) end 
	self._chessInfoLayer:setVisible(true)
	self._chessInfoLayer:refresh()
end

function CreateRoomView:onListersInitCallback( ... )
	local listeners = {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_CREATE_ROOM_SHOW,handler(self,self._onCreateRoomShowCallback)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_CREATE_REQUEST,handler(self,self._requestCreateRoom)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_ENTER_GAME,handler(self,self._enterGame)),
	}
	return listeners
end

function CreateRoomView:_enterGame( ... )

   	GameData.IntoGameType = ConstantsData.IntoGameType.PRIVATE_JOIN_TABLE_TYPE
	logic.LobbyManager:getInstance():LoginGameServer()


end

function CreateRoomView:_findCreateRoomDir( ... )
	return CREATE_ROOM_DIR
end

function CreateRoomView:_onBackBtnClick( ... )
	self:removeFromParent()
end


return CreateRoomView