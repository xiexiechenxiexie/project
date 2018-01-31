 --[[--
author:fly
 ]]
local LobbyGamePreEnter = require "LobbyGamePreEnter"

local JoinRoomView = class("JoinRoomView",LobbyGamePreEnter)
local CreateRoomView = require "CreateRoomView"
local LobbyManager = require "logic/LobbyManager"

JoinRoomView._imgInputOut = nil
JoinRoomView._indexCount = 0
JoinRoomView._inputLabelArray = {}

function JoinRoomView:ctor( ... )
	print("JoinRoomView:ctor")
	JoinRoomView.super.ctor(self)
	self._inputLabelArray = {}
	self:_addInputPanel()
	self:_addCreateRoomPanel()
	self._inputNum = {}
end

function JoinRoomView:_addInputPanel( ... )
	local dir = self:findCreateRoomDir()
	local imgInputPanel = dir .. "imgInputPanel.png"
	local imgBg = ccui.Scale9Sprite:createWithSpriteFrameName(imgInputPanel,cc.rect(166,120,20,20))
	imgBg:setContentSize(cc.size(600,600))
	self:addChild(imgBg)
	imgBg:setAnchorPoint(0,0)
	imgBg:setPosition(111,20)

	local size = imgBg:getContentSize()

	local imgTitle = dir .. "imgTitle.png"
	imgTitle = ccui.ImageView:create(imgTitle,ccui.TextureResType.plistType)
	imgBg:addChild(imgTitle)
	imgTitle:setPosition(size.width * 0.5,size.height -22)

	local imgInputOut = dir .. "imgInputOut.png"
	imgInputOut = ccui.ImageView:create(imgInputOut,ccui.TextureResType.plistType)
	imgBg:addChild(imgInputOut)
	imgInputOut:setPosition(size.width * 0.5,size.height - 98)

	self:_addBtns(imgBg)
	self:_addOutputAtlasNode(imgInputOut)
end

function JoinRoomView:_addInputAtlasNode( __targetNode ,__num)
	local atlasFile = self:findImgInputNum()
	local atlasNode = ccui.TextAtlas:create(tostring(__num),atlasFile,32,46,"0")
	local size = __targetNode:getContentSize()
	atlasNode :setPosition(size.width / 2,size.height / 2)
	__targetNode:addChild(atlasNode)
end

function JoinRoomView:_addOutputAtlasNode( __targetNode )
	local atlasFile = self:findImgOutputNum()
	local dWidth = 88
	local offset = {x = -52,y = 37}
	-- local atlasNode = ccui.TextAtlas:create("0",atlasFile,24,35,"0")
	-- atlasNode:setPosition(offset.x,offset.y)
	-- __targetNode:addChild(atlasNode)
	-- __targetNode:setTag(1)
	-- self._inputLabelArray[#self._inputLabelArray + 1] = atlasNode
	for i=1,6 do
		local atlasNode = ccui.TextAtlas:create("0",atlasFile,32,46,"0")
		local size = __targetNode:getContentSize()
		atlasNode:setPosition(offset.x + i * dWidth ,offset.y)
		__targetNode:addChild(atlasNode)
		atlasNode:setTag(i+1)
		atlasNode:setVisible(false)
		self._inputLabelArray[#self._inputLabelArray + 1] = atlasNode
	end

end

function JoinRoomView:_addBtns( __imgBg )
	local imgBg = __imgBg
	local dir = self:findCreateRoomDir()
    local btnNumNormal =  dir .. "btnNum0.png"
	local btnNumPD =  dir .. "btnNum1.png"

	local btnResetNormal =  dir .. "btnReset0.png"
	local btnResetPD =  dir .. "btnReset1.png"

	local btnDelNormal =  dir .. "btnInputDelete0.png"
	local btnDelPD =  dir .. "btnInputDelete1.png"

	local paddingWidth = 25  local paddingV = 20
	local rowNum = 4 		 local col = 3
	local leftTop = {x = 120,y = 385}
	for r=1,rowNum do
		for c=1,col do
			local id = (r -1 ) * col + c

			local normalFile = 	btnNumNormal
			local dpFile = btnNumPD
			print("id  " .. id)	
			if id == 10 then
				normalFile = btnResetNormal
				dpFile = btnResetPD
			elseif id == 12 then
				normalFile = btnDelNormal
				dpFile = btnDelPD

			end

			local btn = ccui.Button:create(normalFile,dpFile,dpFile,ccui.TextureResType.plistType)
			local x = leftTop.x + (c - 1) * (btn:getContentSize().width  + paddingWidth)
			local y = leftTop.y - (r - 1) * (btn:getContentSize().height  + paddingV) 
			imgBg:addChild(btn)
			btn:setPressedActionEnabled(true)
			btn:addClickEventListener(handler(self,self._onInputBtnCallback))
			btn:setPosition(x,y)
			if id >=1 and id <= 9 or id == 11 then
				if id == 11 then id = 0 end
				self:_addInputAtlasNode(btn,id)
			end
			btn:setTag(id) 
		end
	end
end

function JoinRoomView:_addCreateRoomPanel( ... )
	local dir = self:findCreateRoomDir()
	local btnCreateRoom = dir .. "btnJoinRoomCR.png"
	local button = ccui.Button:create(btnCreateRoom,btnCreateRoom,btnCreateRoom,ccui.TextureResType.plistType)
	button:setPressedActionEnabled(true)
	button:addClickEventListener(handler(self,self._onCreatePanelClick))
	button:setPosition(display.width - 320, 260)
	self:addChild(button)

	local arrFile = {
	[1] = {name = dir .. "imgCreateRoomPork.png",x = 120,y = 260},
	[2] = {name = dir .. "imgCreateRoomMM.png",x = 208,y = 295},
	[3] = {name = dir .. "imgCreateRoomText.png",x = 180,y = 80}
	}

	for i=1,#arrFile do
		local info = arrFile[i]
		local node = ccui.ImageView:create(info.name,ccui.TextureResType.plistType)
		button:addChild(node)
		node:setPosition(info.x,info.y)
	end

	local imgTips = dir .. "imgTips.png"
	local node = ccui.ImageView:create(imgTips,ccui.TextureResType.plistType)
	self:addChild(node)
	node:setPosition(1016,545)

end

function JoinRoomView:_onHandleNum( __num )
	print("JoinRoomView:_onHandleNum " ,__num)
	if self._indexCount < 6 then
		self._indexCount = self._indexCount + 1
		self._inputNum[self._indexCount] = __num
		self:_onInputLabelsRefresh()
		if self._indexCount == 6 then
			local numString = ""
			for i,v in ipairs(self._inputNum) do
				numString = numString .. v
			end
			local tableId = tonumber(numString)
			local gameId = cc.exports.config.GameIDConfig.KPQZ --
			
			lobby.CreateRoomManager:getInstance():requestRoomInfo(tableId,function ( __info )
				if __info.data.serverIp and __info.data.serverPort then 
					local gameIp = __info.data.serverIp
					local gamePort = __info.data.serverPort
					
					logic.LobbyTableManager:getInstance():RequestPrivateJoinTable(gameId,gameIp,gamePort,tableId)
				else
				    GameUtils.showMsg(lobby.CreateRoomManager:getInstance():findingRoomNotExist())	
				end
			end)	

		end
	end
	
end

function JoinRoomView:_onHandleReset(  )
	print("JoinRoomView:_onHandleReset " )
	self._inputNum = {}
	self._indexCount = 0
	self:_onInputLabelsRefresh()
end

function JoinRoomView:_onHandleDel(  )
	print("JoinRoomView:_onHandleDel ")
	if self._indexCount > 0 then
		self._inputNum[self._indexCount] = nil
		self:_onInputLabelsRefresh()
		self._indexCount = self._indexCount - 1
	end
end

function JoinRoomView:_onInputBtnCallback( __sender )
    local id = __sender:getTag()
	print("_onInputBtnCallback num " .. id)
	if (id >= 0 and id <= 9 )  then
			self:_onHandleNum(id)
			return
	end

	if id == 10 then
		self:_onHandleReset()
		return
	end

	self:_onHandleDel()

end

function JoinRoomView:_onInputLabelsRefresh( ... )
	for i=1,6 do
		if self._inputNum[i] then
			self._inputLabelArray[i]:show()
			self._inputLabelArray[i]:setString(tostring(self._inputNum[i]))
		else
			self._inputLabelArray[i]:hide()
			self._inputLabelArray[i]:setString("0")
		end

	end
end

function JoinRoomView:_onCreatePanelClick( ... )
	local view = CreateRoomView.create()
	self:addChild(view)
end

function JoinRoomView:_onBackBtnClick( ... )
	self:removeFromParent()
end

function JoinRoomView:findCreateRoomDir( ... )
	return ""
end

function JoinRoomView:findImgInputNum( ... )
	return "res/GameLayout/Lobby/LobbyEnter/imgInputNum.png"
end

function JoinRoomView:findImgOutputNum( ... )
	return "res/GameLayout/Lobby/LobbyEnter/imgInputNum.png"
end


return JoinRoomView