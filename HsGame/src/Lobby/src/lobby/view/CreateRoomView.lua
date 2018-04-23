--[[--
@author :fly
]]

local NiuNiuRule=cc.exports.lib.rule.NiuNiuRule:getInstance()
local ZhaJinHuaRule=cc.exports.lib.rule.ZhaJinHuaRule:getInstance()
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
MyRoomInfoLayer._slideButtonImgs = {[TAG_PROGRESS] = "btnSelected.png",[TAG_ENDED] = "btnSelected.png"}

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
	-- local imgProgressEnded = dir .. "imgProgressEnded.png"
	-- imgProgressEnded = ccui.ImageView:create(imgProgressEnded,ccui.TextureResType.plistType)
	-- self:addChild(imgProgressEnded)
	-- imgProgressEnded:setPosition(396,530)

	local imgProgressFlag = "btnNormal.png"
	imgProgressFlag = ccui.ImageView:create(imgProgressFlag,ccui.TextureResType.plistType)
	self:addChild(imgProgressFlag,10)
	imgProgressFlag:setVisible(true)

	local imgEndedFlag = "btnNormal.png"
	imgEndedFlag = ccui.ImageView:create(imgEndedFlag,ccui.TextureResType.plistType)
	self:addChild(imgEndedFlag,10)
	imgEndedFlag:setVisible(false)

	local progressText = cc.Label:createWithTTF("进行中",GameUtils.getFontName(),30)
    progressText:setAnchorPoint(cc.p(0.5, 0.5))
    progressText:setColor(cc.c3b(255,255,255))
    progressText:setPosition(133,495)
    self:addChild(progressText,10)

    local endedText = cc.Label:createWithTTF("已结束",GameUtils.getFontName(),30)
    endedText:setAnchorPoint(cc.p(0.5, 0.5))
    endedText:setColor(cc.c3b(191, 169, 125))
    endedText:setPosition(133,495-100)
    self:addChild(endedText,10)

	local slideImg = CREATE_ROOM_DIR .. self._slideButtonImgs[TAG_PROGRESS]
	local button = ccui.Button:create(slideImg,slideImg,slideImg,ccui.TextureResType.plistType)
	self:addChild(button)
	button:addClickEventListener(function ( __sender)
			self:_slideToProgress(__sender)
			imgProgressFlag:setVisible(true)
			imgEndedFlag:setVisible(false)
			progressText:setColor(cc.c3b(255,255,255))
			endedText:setColor(cc.c3b(191, 169, 125))
	end)
	-- local size = button:getContentSize()
	-- local x = size.width / 2 + 5
	-- local y = imgProgressEnded:getContentSize().height * 0.5 - 5
	button:setPosition(133,495)
	imgProgressFlag:setPosition(133,495)

	slideImg = CREATE_ROOM_DIR .. self._slideButtonImgs[TAG_ENDED]
	button = ccui.Button:create(slideImg,slideImg,slideImg,ccui.TextureResType.plistType)
	self:addChild(button)
	button:addClickEventListener(function ( __sender)
			self:_sildeToEnded(__sender)
			imgProgressFlag:setVisible(false)
			imgEndedFlag:setVisible(true)
			progressText:setColor(cc.c3b(191, 169, 125))
			endedText:setColor(cc.c3b(255,255,255))
		end)
	-- local size = button:getContentSize()
	-- x = imgProgressEnded:getContentSize().width -  size.width / 2 - 5
	-- y = imgProgressEnded:getContentSize().height * 0.5 - 5
	button:setPosition(133,495-100)
	imgEndedFlag:setPosition(133,495-100)

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
	contentNode:setContentSize(cc.size(1016,100))

	local imgBg = CREATE_ROOM_DIR .. "imgMyRoomItemBg.png"
	local button = self:_initItemBgtn(__data,imgBg,cc.p(1016 /2,40),__type,cc.p(0.5,0),true)
	contentNode:addChild(button)
	button:setTag(__index)

	-- local imgCreateRoomItemLine = CREATE_ROOM_DIR .. "imgCreateRoomItemLine.png"
	-- imgCreateRoomItemLine = ccui.ImageView:create(imgCreateRoomItemLine,ccui.TextureResType.plistType)
	-- imgCreateRoomItemLine:setPosition(20,64)
	-- contentNode:addChild(imgCreateRoomItemLine)
	return contentNode
end


function MyRoomInfoLayer:_createProgressItem(__data,__index )
	print("MyRoomInfoLayer:_createProgressItem附件的历史开放记录的世界观")
	dump(__data)
	local ManagerClazz = cc.exports.lobby.CreateRoomManager
	local layout = self:_createBaseItem(__data,TAG_PROGRESS,__index)
	local size = layout:getContentSize()
	local params = {{
		fontName = GameUtils.getFontName(),
		fontSize = 24,
		text = __data.timeOfCreateRoom,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(1016,20),
		anchorPoint = cc.p(1,0.5)
		}
		,{
		fontName = GameUtils.getFontName(),
		fontSize = 30,
		text = GameUtils.adjustRoomNum(__data.roomId),
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(70,size.height/2+18),
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 30,
		text = __data.leftGameRound,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(260+120,size.height/2+18),
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 30,
		text = ManagerClazz:getInstance():findCostSeatLanguage(__data),
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(191, 169, 125, 255),
		pos = cc.p(378+170,size.height/2+18),
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 28,
		text = ManagerClazz:getInstance():findNumOfRoomString(__data),
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(513+220,size.height/2+18),
		}
	}

	for i=1,#params do
		local param = params[i]
		local label = cc.exports.lib.uidisplay.createLabel(param)
		layout:addChild(label)
	end

	-- local imgBarBg = ccui.ImageView:create("imgBarBg.png",ccui.TextureResType.plistType)
	-- imgBarBg:setPosition(513,32)
	-- layout:addChild(imgBarBg)

	-- local loadingBar = ccui.LoadingBar:create("imgBar.png",ccui.TextureResType.plistType,__data.peopleNumOfRoom / __data.capityPeopleNumOfRoom * 100)
	-- imgBarBg:addChild(loadingBar)
	-- loadingBar:setPosition(imgBarBg:getContentSize().width * 0.5,imgBarBg:getContentSize().height * 0.5)
	-- loadingBar:setPercent(__data.peopleNumOfRoom / __data.capityPeopleNumOfRoom * 100)

	local button = nil
	local normal = "btnGuanZhan.png"
	if __data.peopleNumOfRoom < __data.capityPeopleNumOfRoom then  
		normal = "btnInvite.png"
	end
	button = self:_initItemBgtn(__data,normal,cc.p(670+290,size.height/2+16),TAG_PROGRESS,cc.p(0.5,0.5))
	layout:addChild(button)
	button:setTag(__index)
	button:setPressedActionEnabled(true)
	return layout
end

function MyRoomInfoLayer:_refreshProgressLayer( ... )
	print("MyRoomInfoLayer:_refreshProgressLayer",self._roomInfoLayer)

	if self._roomInfoLayer == nil then
		self._roomInfoLayer = cc.Layer:create()
		self:addChild(self._roomInfoLayer)
		local imgMyRoomTitle = CREATE_ROOM_DIR .. "imgMyRoomTitle.png"
		imgMyRoomTitle = ccui.ImageView:create(imgMyRoomTitle,ccui.TextureResType.plistType)
		imgMyRoomTitle:setAnchorPoint(cc.p(0,0))
		imgMyRoomTitle:setPosition(285,500)
		self._roomInfoLayer:addChild(imgMyRoomTitle)

		self._roomListView = ccui.ListView:create()
		self._roomListView:setContentSize(cc.size(1016,440))
		self._roomListView:setAnchorPoint(cc.p(0,0))
		self._roomListView:setScrollBarEnabled(false)
		self._roomListView:setDirection(ccui.ListViewDirection.vertical)
		self._roomInfoLayer:addChild(self._roomListView)
		self._roomListView:setPosition(260,42)
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
	local size = layout:getContentSize()
	local params = {{
		fontName = GameUtils.getFontName(),
		fontSize = 24,
		text = __data.timeOfCreateRoom,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(1016,20),
		anchorPoint = cc.p(1,0.5)
		}
		,{
		fontName = GameUtils.getFontName(),
		fontSize = 24,
		text = ManagerClazz:getInstance():findRoomIdString(" ") .. GameUtils.adjustRoomNum(__data.roomId),
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(40,size.height/2+18),
		anchorPoint = cc.p(0,0.5)
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 24,
		text = ManagerClazz:getInstance():findChessNumString("    ") .. __data.gameRound,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(290+75,size.height/2+18),
		anchorPoint = cc.p(0,0.5)
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 24,
		text = ManagerClazz:getInstance():findJoinNumString() .. __data.peopleNumOfRoom,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(458+150,size.height/2+18),
		anchorPoint = cc.p(0,0.5)
		}
	}

	for i=1,#params do
		local param = params[i]
		local label = cc.exports.lib.uidisplay.createLabel(param)
		layout:addChild(label)
	end 
	local button = self:_initItemBgtn(__data,"btnLookDedtail.png",cc.p(670+290,size.height/2+18),TAG_ENDED,cc.p(0.5,0.5))
	layout:addChild(button)
	button:setTag(__index)
	button:setPressedActionEnabled(true)
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
			color = cc.c4b(255,255,255, 255),
			pos = cc.p(300,510),
		}
		local label = cc.exports.lib.uidisplay.createLabel(labelConfig)
		self._chessInfoLayer:addChild(label)

		self._chessListView = ccui.ListView:create()
		self._chessListView:setContentSize(cc.size(1016,440))
		self._chessListView:setAnchorPoint(cc.p(0,0))
		self._chessListView:setDirection(ccui.ListViewDirection.vertical)
		self._chessInfoLayer:addChild(self._chessListView)
		self._chessListView:setPosition(260,42)
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
	dump(data)
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
	local size = layout:getContentSize()
	local params = {{
		fontName = GameUtils.getFontName(),
		fontSize = 24,
		text = __data.timeOfCreateRoom,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(1016,20),
		anchorPoint = cc.p(1,0.5)
		}
		,{
		fontName = GameUtils.getFontName(),
		fontSize = 24,
		text = ManagerClazz:getInstance():findRoomIdString(" ") .. GameUtils.adjustRoomNum(__data.roomId),
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(40,size.height/2+18),
		anchorPoint = cc.p(0,0.5)
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 24,
		text = ManagerClazz:getInstance():findCreatorString(__data) ,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(290+50,size.height/2+18),
		anchorPoint = cc.p(0,0.5)
		},
		{
		fontName = GameUtils.getFontName(),
		fontSize = 24,
		text = ManagerClazz:getInstance():findScoreString(__data) ,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(458+175,size.height/2+18),
		anchorPoint = cc.p(0,0.5)
		}
	}

	for i=1,#params do
		local param = params[i]
		local label = cc.exports.lib.uidisplay.createLabel(param)
		layout:addChild(label)
	end 
	local button = self:_initItemBgtn(__data,"btnLookDedtail.png",cc.p(670+290,size.height/2+18),TAG_JOIN_CHESS,cc.p(0.5,0.5))
	button:setPressedActionEnabled(true)
	button:setTag(__index)
	layout:addChild(button)
	return layout
end

function MyChessInfoLayer:refresh( ... )
	local ManagerClazz = cc.exports.lobby.CreateRoomManager
	if self._chessListView == nil  then
		local labelBg = "btnNormal.png"
		labelBg = ccui.ImageView:create(labelBg,ccui.TextureResType.plistType)
		labelBg:setPosition(133,495)
		self:addChild(labelBg)

		local labelConfig =	{
			fontName = GameUtils.getFontName(),
			fontSize = 30,
			text = ManagerClazz:getInstance():findLastChessString(),
			alignment = cc.TEXT_ALIGNMENT_CENTER,
			color = cc.c4b(255,255,255, 255),
			pos = cc.p(133,495),
		}
		local label = cc.exports.lib.uidisplay.createLabel(labelConfig)
		self:addChild(label)

		self._chessListView = ccui.ListView:create()
		self._chessListView:setContentSize(cc.size(1016,440))
		self._chessListView:setAnchorPoint(cc.p(0,0))
		self._chessListView:setDirection(ccui.ListViewDirection.vertical)
		self:addChild(self._chessListView)
		self._chessListView:setPosition(260,42)
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
CreateRoomView._MAX_FLOOR_SCORE = 10
CreateRoomView._MAX_CHESS_NUM = 100
function CreateRoomView:ctor( ... )
	CreateRoomView.super.ctor(self)
	self._roomInfoLayer = nil
	self._chessInfoLayer = nil
	
	
	local manager = cc.exports.lobby.CreateRoomManager:getInstance()
	manager:RequestPrivateTableConfig(function ( ... )
		-- self:_addCreateRoomPanel()

		self:_addMyRoomAndChessPanel()
	end)
end




function CreateRoomView:_addTabBtn( __targetNode )
	-- local dir = self:_findCreateRoomDir()
	-- local btnMyRoom0 = dir .. "btnMyRoom0.png"
	-- local btnMyRoom1 = dir .. "btnMyRoom1.png"

	-- local btnMyChess0 = dir .. "btnMyChess0.png"
	-- local btnMyChess1 = dir .. "btnMyChess1.png"

	local tabTagMyRoom = 1
	local tabTagMyChess = 2
	local tabTagRoomSet = 3
	local topOrder = 99
	local bottomOrder = 98
	local size = __targetNode:getContentSize()

	 local btnImg = "btnTopSelected.png"
    self._roomSet = ccui.Button:create(btnImg, btnImg, btnImg, ccui.TextureResType.plistType)
	self._roomSet:setPosition(405, size.height-58.5)
	__targetNode:addChild(self._roomSet)
	self._roomSet:setOpacity(0)

	self._myRoom = ccui.Button:create(btnImg, btnImg, btnImg, ccui.TextureResType.plistType)
	self._myRoom:setPosition(405+352, size.height-58.5)
	__targetNode:addChild(self._myRoom)
	self._myRoom:setOpacity(0)

	self._myJoinRoom = ccui.Button:create(btnImg, btnImg, btnImg, ccui.TextureResType.plistType)
	self._myJoinRoom:setPosition(405+352*2, size.height-58.5)
	__targetNode:addChild(self._myJoinRoom)
	self._myJoinRoom:setOpacity(0)

	self.__roomSetImg = ccui.ImageView:create("btnTopSelected.png", ccui.TextureResType.plistType)
	self.__roomSetImg:setPosition(405, size.height-58.5)
	__targetNode:addChild(self.__roomSetImg)
	self.__roomSetImg:show()

	self._myRoomImg = ccui.ImageView:create("btnTopSelected.png", ccui.TextureResType.plistType)
	self._myRoomImg:setPosition(405+352, size.height-58.5)
	__targetNode:addChild(self._myRoomImg)
	self._myRoomImg:hide()

	self._myJoinRoomImg = ccui.ImageView:create("btnTopSelected.png", ccui.TextureResType.plistType)
	self._myJoinRoomImg:setPosition(405+352*2, size.height-58.5)
	__targetNode:addChild(self._myJoinRoomImg)
	self._myJoinRoomImg:hide()

	self._roomSetText = cc.Label:createWithTTF("房间设定",GameUtils.getFontName(),30)
    self._roomSetText:setAnchorPoint(cc.p(0.5, 0.5))
    self._roomSetText:setColor(cc.c3b(255,255,255))
    self._roomSetText:setPosition(405, size.height-60)
    __targetNode:addChild(self._roomSetText)

    self._myRoomText = cc.Label:createWithTTF("我的房间",GameUtils.getFontName(),30)
    self._myRoomText:setAnchorPoint(cc.p(0.5, 0.5))
    self._myRoomText:setColor(cc.c3b(191, 169, 125))
    self._myRoomText:setPosition(405+352, size.height-60)
    __targetNode:addChild(self._myRoomText)

    self._myJoinRoomText = cc.Label:createWithTTF("我参与的牌局",GameUtils.getFontName(),30)
    self._myJoinRoomText:setAnchorPoint(cc.p(0.5, 0.5))
    self._myJoinRoomText:setColor(cc.c3b(191, 169, 125))
    self._myJoinRoomText:setPosition(405+352*2, size.height-60)
    __targetNode:addChild(self._myJoinRoomText)

	-- local btnMyRoom =  ccui.Button:create(btnMyRoom0,btnMyRoom1,btnMyRoom1,ccui.TextureResType.plistType)
	-- __targetNode:addChild(btnMyRoom)
	-- local buttonSize = btnMyRoom:getContentSize()
	-- btnMyRoom:setPressedActionEnabled(false)
	-- btnMyRoom:setZoomScale(0)
	-- btnMyRoom:setPosition(buttonSize.width / 2 ,size.height + buttonSize.height / 2 - 20)


	-- local btnMyChess =  ccui.Button:create(btnMyChess0,btnMyChess1,btnMyChess1,ccui.TextureResType.plistType)
	-- __targetNode:addChild(btnMyChess)
	-- local buttonSize = btnMyRoom:getContentSize()
	-- btnMyChess:setPosition(387,size.height + buttonSize.height / 2 - 20)
	-- btnMyChess:setPressedActionEnabled(false)
	-- btnMyChess:setZoomScale(0)

	local initCallback = function ( __sender)
	local tag = __sender ~= nil and __sender:getTag() or tabTagRoomSet
		if  tag == tabTagMyRoom then
			self:_onShowMyRoom()
			self.__roomSetImg:hide()
			self._myRoomImg:show()
			self._myJoinRoomImg:hide()
			self._roomSetText:setColor(cc.c3b(191, 169, 125))
			self._myRoomText:setColor(cc.c3b(255,255,255))
			self._myJoinRoomText:setColor(cc.c3b(191, 169, 125))
		elseif tag == tabTagMyChess then
			self:_onShowMyChess()
			self.__roomSetImg:hide()
			self._myRoomImg:hide()
			self._myJoinRoomImg:show()
			self._roomSetText:setColor(cc.c3b(191, 169, 125))
			self._myRoomText:setColor(cc.c3b(191, 169, 125))
			self._myJoinRoomText:setColor(cc.c3b(255,255,255))
		elseif tag == tabTagRoomSet then
			self:_onShowRoomSet()
			self.__roomSetImg:show()
			self._myRoomImg:hide()
			self._myJoinRoomImg:hide()
			self._roomSetText:setColor(cc.c3b(255,255,255))
			self._myRoomText:setColor(cc.c3b(191, 169, 125))
			self._myJoinRoomText:setColor(cc.c3b(191, 169, 125))
		end
	end

	self._roomSet:addClickEventListener(function ( __sender ) initCallback(__sender) end)
	self._roomSet:setTag(tabTagRoomSet)
	self._myRoom:addClickEventListener(function ( __sender ) initCallback(__sender) end)
	self._myRoom:setTag(tabTagMyRoom)
	self._myJoinRoom:addClickEventListener(function ( __sender ) initCallback(__sender) end)
	self._myJoinRoom:setTag(tabTagMyChess)

	-- btnMyRoom:addClickEventListener(function ( __sender ) initCallback(__sender) end)
	-- btnMyRoom:setTag(tabTagMyRoom)

	-- btnMyChess:addClickEventListener(function ( __sender ) initCallback(__sender) end)
	-- btnMyChess:setTag(tabTagMyChess)
	initCallback(nil)
end

function CreateRoomView:_addMyRoomAndChessPanel( ... )
	local dir = self:_findCreateRoomDir()
	local imgMyInfo = dir .. "imgCreateRoomBg.png"
	local imgBg = ccui.ImageView:create(imgMyInfo,ccui.TextureResType.plistType)
	-- imgBg:setContentSize(cc.size(774,562))
	self.imgBg = imgBg
	self:addChild(imgBg)
	imgBg:setAnchorPoint(0,0)
	imgBg:setPosition(10,15)
	self:_addTabBtn(imgBg)
end

function CreateRoomView:_initCreateRoomPanel( __parent )
	local manager = cc.exports.lobby.LobbyGameEnterManager:getInstance()
	-- local size = __parent:getContentSize()
	-- local dir  = self:_findCreateRoomDir()
	-- local imgCreateRoom = dir .. "imgCreateRoom.png"
	-- local imgCreateRoom = cc.Label:createWithTTF("创建房间",GameUtils.getFontName(), 30)
	-- __parent:addChild(imgCreateRoom)
	-- imgCreateRoom:setPosition(667,375)

	-- local gameBgNiu = "btnNormal.png"
	-- gameBgNiu = ccui.ImageView:create(gameBgNiu,ccui.TextureResType.plistType)
	-- __parent:addChild(gameBgNiu,2)
	-- gameBgNiu:setVisible(true)

	-- local gameBgZjh = "btnNormal.png"
	-- gameBgZjh = ccui.ImageView:create(gameBgZjh,ccui.TextureResType.plistType)
	-- __parent:addChild(gameBgZjh,2)
	-- gameBgZjh:setVisible(false)

	-- local gameTextNiu = cc.Label:createWithTTF("牛  牛",GameUtils.getFontName(),30)
 --    gameTextNiu:setAnchorPoint(cc.p(0.5, 0.5))
 --    gameTextNiu:setColor(cc.c3b(255,255,255))
 --    gameTextNiu:setPosition(133-10,495-15)
 --    __parent:addChild(gameTextNiu,2)

 --    local gameTextZjh = cc.Label:createWithTTF("炸金花",GameUtils.getFontName(),30)
 --    gameTextZjh:setAnchorPoint(cc.p(0.5, 0.5))
 --    gameTextZjh:setColor(cc.c3b(191, 169, 125))
 --    gameTextZjh:setPosition(133-10,495-100-15)
 --    __parent:addChild(gameTextZjh,2)

 	local tagNiu = 1
 	local tagZy  = 2
 	local tagMp  = 0
 	local tagZjh = 4

	local slideImg = "btnSelected.png"
	local buttonNn = ccui.Button:create(slideImg,slideImg,slideImg,ccui.TextureResType.plistType)
	buttonNn:setPosition(123,480)
	__parent:addChild(buttonNn)

	slideImg = "btnSelected.png"
	local buttonZy = ccui.Button:create(slideImg,slideImg,slideImg,ccui.TextureResType.plistType)
	buttonZy:setPosition(123,380)
	__parent:addChild(buttonZy)

	slideImg = "btnSelected.png"
	local buttonMp = ccui.Button:create(slideImg,slideImg,slideImg,ccui.TextureResType.plistType)
	buttonMp:setPosition(123,280)
	__parent:addChild(buttonMp)
	
	slideImg = "btnSelected.png"
	local buttonZjh = ccui.Button:create(slideImg,slideImg,slideImg,ccui.TextureResType.plistType)
	buttonZjh:setPosition(123,180)
	__parent:addChild(buttonZjh)

	local gameBgNiu = "btnNormal.png"
	gameBgNiu = ccui.ImageView:create(gameBgNiu,ccui.TextureResType.plistType)
	gameBgNiu:setPosition(123,480)
	__parent:addChild(gameBgNiu)
	gameBgNiu:setVisible(true)

	local gameBgZy = "btnNormal.png"
	gameBgZy = ccui.ImageView:create(gameBgZy,ccui.TextureResType.plistType)
	gameBgZy:setPosition(123,380)
	__parent:addChild(gameBgZy)
	gameBgZy:setVisible(false)

	local gameBgMp = "btnNormal.png"
	gameBgMp = ccui.ImageView:create(gameBgMp,ccui.TextureResType.plistType)
	gameBgMp:setPosition(123,280)
	__parent:addChild(gameBgMp)
	gameBgMp:setVisible(false)

	local gameBgZjh = "btnNormal.png"
	gameBgZjh = ccui.ImageView:create(gameBgZjh,ccui.TextureResType.plistType)
	gameBgZjh:setPosition(123,180)
	__parent:addChild(gameBgZjh)
	gameBgZjh:setVisible(false)

	local gameTextNiu = cc.Label:createWithTTF("牛牛上庄",GameUtils.getFontName(),30)
    gameTextNiu:setAnchorPoint(cc.p(0.5, 0.5))
    gameTextNiu:setColor(cc.c3b(255,255,255))
    gameTextNiu:setPosition(123,480)
    __parent:addChild(gameTextNiu)

    local gameTextZy = cc.Label:createWithTTF("自由抢庄牛牛",GameUtils.getFontName(),30)
    gameTextZy:setAnchorPoint(cc.p(0.5, 0.5))
    gameTextZy:setColor(cc.c3b(191, 169, 125))
    gameTextZy:setPosition(123,380)
    __parent:addChild(gameTextZy)

    local gameTextMp = cc.Label:createWithTTF("明牌抢庄牛牛",GameUtils.getFontName(),30)
    gameTextMp:setAnchorPoint(cc.p(0.5, 0.5))
    gameTextMp:setColor(cc.c3b(191, 169, 125))
    gameTextMp:setPosition(123,280)
    __parent:addChild(gameTextMp)

    local gameTextZjh = cc.Label:createWithTTF("炸金花",GameUtils.getFontName(),30)
    gameTextZjh:setAnchorPoint(cc.p(0.5, 0.5))
    gameTextZjh:setColor(cc.c3b(191, 169, 125))
    gameTextZjh:setPosition(123,180)
    __parent:addChild(gameTextZjh)

    local initCallback = function (__sender)
    	local tag = __sender ~= nil and __sender:getTag() or ConstantsData.GameType.TYPE_NIUNIU
    	if tag == ConstantsData.GameType.TYPE_NIUNIU then
    		self:createNiuRule(__parent,tag)
    		gameBgNiu:setVisible(true)
			gameBgZy:setVisible(false)
			gameBgMp:setVisible(false)			
			gameBgZjh:setVisible(false)
			gameTextNiu:setColor(cc.c3b(255,255,255))
			gameTextZy:setColor(cc.c3b(191, 169, 125))
			gameTextMp:setColor(cc.c3b(191, 169, 125))
			gameTextZjh:setColor(cc.c3b(191, 169, 125))
    	elseif tag == ConstantsData.GameType.TYPE_ZIYOU then
    		self:createZyRule(__parent,tag)
    		gameBgNiu:setVisible(false)
			gameBgZy:setVisible(true)
			gameBgMp:setVisible(false)			
			gameBgZjh:setVisible(false)
			gameTextNiu:setColor(cc.c3b(191, 169, 125))
			gameTextZy:setColor(cc.c3b(255,255,255))
			gameTextMp:setColor(cc.c3b(191, 169, 125))
			gameTextZjh:setColor(cc.c3b(191, 169, 125))    		
    	elseif tag == ConstantsData.GameType.TYPE_MINGPAI then
    		self:createMpRule(__parent,tag)
    		gameBgNiu:setVisible(false)
			gameBgZy:setVisible(false)
			gameBgMp:setVisible(true)			
			gameBgZjh:setVisible(false)
			gameTextNiu:setColor(cc.c3b(191, 169, 125))
			gameTextZy:setColor(cc.c3b(191, 169, 125))
			gameTextMp:setColor(cc.c3b(255,255,255))
			gameTextZjh:setColor(cc.c3b(191, 169, 125))
    	elseif tag == ConstantsData.GameType.TYPE_ZJH then
    		GameUtils.showMsg("游戏正在开发中")
    		-- self:createZjhRule(__parent,tag)
			-- gameBgNiu:setVisible(false)
			-- gameBgZy:setVisible(false)
			-- gameBgMp:setVisible(false)			
			-- gameBgZjh:setVisible(true)
			-- gameTextNiu:setColor(cc.c3b(191, 169, 125))
			-- gameTextZy:setColor(cc.c3b(191, 169, 125))
			-- gameTextMp:setColor(cc.c3b(191, 169, 125))
			-- gameTextZjh:setColor(cc.c3b(255,255,255))
    	end
    end

    buttonNn:addClickEventListener(function ( __sender ) initCallback(__sender) end)
	buttonNn:setTag(ConstantsData.GameType.TYPE_NIUNIU)
	buttonZy:addClickEventListener(function ( __sender ) initCallback(__sender) end)
	buttonZy:setTag(ConstantsData.GameType.TYPE_ZIYOU)
	buttonMp:addClickEventListener(function ( __sender ) initCallback(__sender) end)
	buttonMp:setTag(ConstantsData.GameType.TYPE_MINGPAI)
	buttonZjh:addClickEventListener(function ( __sender ) initCallback(__sender) end)
	buttonZjh:setTag(ConstantsData.GameType.TYPE_ZJH)

	initCallback(nil)
 --    buttonNn:addClickEventListener(function ( __sender)
	-- 		manager:setSelectGameId(manager.KPQZ)
	-- 		self:createNNRuleLayer(__parent)		
	-- end)
	-- buttonZy:addClickEventListener(function ( __sender)
	-- 		manager:setSelectGameId(manager.KPQZ)
	-- 		self:createNNRuleLayer(__parent)	
	-- end)
	-- buttonMp:addClickEventListener(function ( __sender)
	-- 		manager:setSelectGameId(manager.KPQZ)
	-- 		self:createNNRuleLayer(__parent)
	-- end)
	-- buttonZjh:addClickEventListener(function ( __sender)
	-- 		-- manager:setSelectGameId(manager.PSZ)
	-- 		-- self:createPSZRuleLayer(__parent)
	-- 	end)

	-- if manager:findSelectedGameId() == manager.KPQZ then
	-- 	self:createNNRuleLayer(__parent)
	-- 	gameBgNiu:setVisible(true)
	-- 	gameBgZjh:setVisible(false)
	-- 	gameTextNiu:setColor(cc.c3b(255,255,255))
	-- 	gameTextZjh:setColor(cc.c3b(191, 169, 125))
	-- elseif manager:findSelectedGameId() == manager.PSZ then
	-- 	self:createPSZRuleLayer(__parent)
	-- 	gameBgNiu:setVisible(false)
	-- 	gameBgZjh:setVisible(true)
	-- 	gameTextNiu:setColor(cc.c3b(191, 169, 125))
	-- 	gameTextZjh:setColor(cc.c3b(255,255,255))
	-- 	self:createPSZRuleLayer(__parent)
	-- end	

	local button = cc.exports.lib.uidisplay.createUIButton({
            textureType = ccui.TextureResType.plistType,
            normal = "btnCreateRoomCmd.png",
            callback = handler(self,self._onCreateRoomClick),
            isActionEnabled = true,
            pos = cc.p(405+352+370,80)
    })
    __parent:addChild(button)


	local endedText = cc.Label:createWithTTF("如果游戏在十分钟内没有正式开始，系统会自动解散房间并退还房卡",GameUtils.getFontName(),18)
    endedText:setAnchorPoint(cc.p(0.5, 0.5))
    endedText:setColor(cc.c3b(191, 169, 125))
    endedText:setPosition(405+352-50,60)
    __parent:addChild(endedText,10)
end

function CreateRoomView:_onCreateRoomClick()
	local manager = cc.exports.lobby.CreateRoomManager:getInstance()
	local NiuNiuRule=cc.exports.lib.rule.NiuNiuRule:getInstance()
	local data = NiuNiuRule:getCurrRule()
	if not Mall.MallManager.checkNeedGotoMallBuyRoomCard(manager:findNotEnoughRoomCardString(), data.cost) then 
		manager:requestCreateRoom( data,manager:findActGameId(),data.roomNum)	
	end
	print("哈哈哈哈")
	dump(data)
end

function CreateRoomView:createNiuRule(target,tag)
	if self._niuRuleLayer == nil then 
		self._niuRuleLayer = NiuNiuRule:createRuleLayer(tag)
		target:addChild(self._niuRuleLayer)
	end 
	self._niuRuleLayer:setVisible(true)

	if self._zyRuleLayer then self._zyRuleLayer:setVisible(false) end
	if self._mpRuleLayer then self._mpRuleLayer:setVisible(false) end
	if self._zjhRuleLayer then self._zjhRuleLayer:setVisible(false) end
end

function CreateRoomView:createZyRule(target,tag)
	if self._zyRuleLayer == nil then 
		self._zyRuleLayer = NiuNiuRule:createRuleLayer(tag)
		target:addChild(self._zyRuleLayer)
	end 
	self._zyRuleLayer:setVisible(true) 

	if self._niuRuleLayer then self._niuRuleLayer:setVisible(false) end
	if self._mpRuleLayer then self._mpRuleLayer:setVisible(false) end
	if self._zjhRuleLayer then self._zjhRuleLayer:setVisible(false) end
end

function CreateRoomView:createMpRule(target,tag)
	if self._mpRuleLayer == nil then 
		self._mpRuleLayer = NiuNiuRule:createRuleLayer(tag)
		target:addChild(self._mpRuleLayer)
	end 
	self._mpRuleLayer:setVisible(true) 

	if self._niuRuleLayer then self._niuRuleLayer:setVisible(false) end
	if self._zyRuleLayer then self._zyRuleLayer:setVisible(false) end
	if self._zjhRuleLayer then self._zjhRuleLayer:setVisible(false) end
end

function CreateRoomView:createZjhRule(target,tag)
	if self._zjhRuleLayer == nil then 
		self._zjhRuleLayer = ZhaJinHuaRule:createRuleLayer(tag)
		target:addChild(self._zjhRuleLayer)
	end 
	self._zjhRuleLayer:setVisible(true) 

	if self._niuRuleLayer then self._niuRuleLayer:setVisible(false) end
	if self._zyRuleLayer then self._zyRuleLayer:setVisible(false) end
	if self._mpRuleLayer then self._mpRuleLayer:setVisible(false) end
end


-- function CreateRoomView:createNNRuleLayer(target)
-- 	if target:getChildByTag(lobby.LobbyGameEnterManager.PSZ) then
-- 		local node = target:getChildByTag(lobby.LobbyGameEnterManager.PSZ)
-- 		node:setVisible(false)
-- 	end
-- 	if target:getChildByTag(lobby.LobbyGameEnterManager.KPQZ) then
-- 		local node = target:getChildByTag(lobby.LobbyGameEnterManager.KPQZ)
-- 		node:setVisible(true)
-- 		return
-- 	end

-- 	local layer = NiuNiuRule:createRuleLayer()
-- 	target:addChild(layer)
-- 	layer:setTag(lobby.LobbyGameEnterManager.KPQZ)
-- end

-- function CreateRoomView:createPSZRuleLayer(target)
-- 	if target:getChildByTag(lobby.LobbyGameEnterManager.KPQZ) then
-- 		local node = target:getChildByTag(lobby.LobbyGameEnterManager.KPQZ)
-- 		node:setVisible(false)
-- 	end
-- 	if target:getChildByTag(lobby.LobbyGameEnterManager.PSZ) then
-- 		local node = target:getChildByTag(lobby.LobbyGameEnterManager.PSZ)
-- 		node:setVisible(true)
-- 		return
-- 	end

-- 	local layer = ZhaJinHuaRule:createRuleLayer()
-- 	target:addChild(layer)
-- 	layer:setTag(lobby.LobbyGameEnterManager.PSZ)
-- end


--[[--
刷新消耗的房卡
]]
-- function CreateRoomView:_onDataOnCreatePanelRefresh( __num)
-- 	local manager = cc.exports.lobby.CreateRoomManager:getInstance()
-- 	local cardCost = manager:findRoomCardCost(__num)
-- 	if self._createInput.isCostToSeat then 
-- 		cardCost = cardCost / 3
-- 	end
-- 	self._createInput.cost = cardCost
-- 	if self._lbCostInLabel then self._lbCostInLabel:setString("X" .. cardCost) end
-- 	if self._lbRoomCardInButton then self._lbRoomCardInButton:setString("X" .. cardCost) end
-- end

-- function CreateRoomView:_onAddMinsScoreClick( __num,__label)
-- 	print("_onAddMinsScoreClick",__num,CreateRoomView._MAX_FLOOR_SCORE)
-- 	if __num > CreateRoomView._MAX_FLOOR_SCORE then 
-- 		__num = CreateRoomView._MAX_FLOOR_SCORE
-- 	end
-- 	self._createInput.score = __num
-- 	__label:setString(""..__num)
-- end

-- function CreateRoomView:_onAddMinsChessClick( __num,__label )
	
-- 	if __num > self._MAX_CHESS_NUM then __num = self._MAX_CHESS_NUM end
-- 	__label:setString(""..__num)
-- 	--多少局对应多少房卡
-- 	self:_onDataOnCreatePanelRefresh(__num)
-- 	self._createInput.chess = __num
-- 	print("_onAddMinsChessClick",self._createInput.chess,CreateRoomView._MAX_CHESS_NUM)
-- 	-- local manager = cc.exports.lobby.CreateRoomManager:getInstance()
-- 	-- local cardCost = manager:findRoomCardCost(__num)
-- 	-- self._createInput.cost = cardCost
-- end


-- function CreateRoomView:_onCalculateRadioGroupClick( __selectRadioButton,__index,_eventType )
-- 	print("_onCalculateRadioGroupClick",__selectRadioButton,__index,_eventType)
-- 	if __index == 0 then
-- 		print("选择了自动计算")
-- 		self._createInput.isAutoNiu = true
-- 	else
-- 		print("选择了手动计算")	
-- 		self._createInput.isAutoNiu = false
-- 	end
-- end

--是否开启授权入座
-- function CreateRoomView:_onOpenClosedRadioGroupClick( __selectRadioButton,__index,_eventType )
-- 	print("_onOpenClosedRadioGroupClick",__selectRadioButton,__index,_eventType)
-- 	if __index == 0 then
-- 		print("close")
-- 		self._createInput.isOpenRightToSeat = false
-- 	else
-- 		print("open")	
-- 		self._createInput.isOpenRightToSeat = true
-- 	end
-- end

--是否收费入座
-- function CreateRoomView:_onYesNoRadioGroupClick( __selectRadioButton,__index,_eventType )
-- 	print("_onYesNoRadioGroupClick",__selectRadioButton,__index,_eventType)
-- 	if __index == 0 then
-- 		print("yes")
-- 		for k,v in pairs(self._costWidgetContainer) do
-- 			v:show()
-- 		end
-- 		self._createInput.isCostToSeat = true
-- 	else
-- 		for k,v in pairs(self._costWidgetContainer) do
-- 			v:hide()
-- 		end
-- 		self._createInput.isCostToSeat = false
-- 	end
-- 	self:_onDataOnCreatePanelRefresh(self._createInput.chess)
-- end

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
	local imgBg = ccui.ImageView:create(imgCreateRoomPanel,ccui.TextureResType.plistType)
	-- imgBg:setContentSize(cc.size(518,618))
	self:addChild(imgBg)
	imgBg:setAnchorPoint(1,0)
	imgBg:setPosition(display.width - 1,15)
	-- self:_initCreateRoomPanel(imgBg)
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
	if self._roomSetLayer then self._roomSetLayer:setVisible(false) end
end

function CreateRoomView:_onShowMyChess( ... )
	print("CreateRoomView:_onShowMyChess")
	if self._chessInfoLayer == nil then 
		self._chessInfoLayer = MyChessInfoLayer.create()
		self:addChild(self._chessInfoLayer)
		print("create chess layer")
	end 
	if self._roomInfoLayer then  self._roomInfoLayer:setVisible(false) end 
	if self._roomSetLayer then self._roomSetLayer:setVisible(false) end
	self._chessInfoLayer:setVisible(true)
	self._chessInfoLayer:refresh()
end

function CreateRoomView:_onShowRoomSet( ... )
	if self._roomSetLayer == nil then 
		self:roomSetLayer()
	end
	self._roomSetLayer:setVisible(true)
	if self._roomInfoLayer then self._roomInfoLayer:setVisible(false) end 
	if self._chessInfoLayer then self._chessInfoLayer:setVisible(false) end
end

function CreateRoomView:roomSetLayer( ... )
	if self._roomSetLayer == nil then
		self._roomSetLayer = cc.Layer:create()
		self.imgBg:addChild(self._roomSetLayer)
		self:_initCreateRoomPanel(self._roomSetLayer)
	end
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