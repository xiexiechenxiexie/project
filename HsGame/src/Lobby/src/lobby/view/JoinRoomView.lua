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
	local imgBg = ccui.ImageView:create(imgInputPanel,ccui.TextureResType.plistType)
	self:addChild(imgBg)
	imgBg:setPosition(667,350)--数字盘

	local size = imgBg:getContentSize()

	local imgTitle = dir .. "imgInputPanelText.png"
	imgTitle = ccui.ImageView:create(imgTitle,ccui.TextureResType.plistType)
	imgBg:addChild(imgTitle)
	imgTitle:setPosition(size.width * 0.5,size.height -58)

	for i=1,6 do
		local imgInputOut = dir .. "imgInputOut.png"
		imgInputOut = ccui.ImageView:create(imgInputOut,ccui.TextureResType.plistType)
		imgInputOut:setAnchorPoint(0,0)
		imgBg:addChild(imgInputOut)
		imgInputOut:setPosition(62+(i-1)*73,420)

		self:_addOutputAtlasNode(imgInputOut,i)
	end
	

	self:_addBtns(imgBg)
	-- self:_addOutputAtlasNode(imgInputOut)
end

function JoinRoomView:_addInputAtlasNode( __targetNode ,__num)
	local atlasFile = self:findImgInputNum()
	local atlasNode = ccui.TextAtlas:create(tostring(__num),atlasFile,32,46,"0")
	local size = __targetNode:getContentSize()
	atlasNode :setPosition(size.width / 2,size.height / 2)
	__targetNode:addChild(atlasNode)
end

function JoinRoomView:_addOutputAtlasNode( __targetNode, index)
	local atlasFile = self:findImgOutputNum()
	local dWidth = 88
	local offset = {x = 28,y = 28}
	-- local atlasNode = ccui.TextAtlas:create("0",atlasFile,24,35,"0")
	-- atlasNode:setPosition(offset.x,offset.y)
	-- __targetNode:addChild(atlasNode)
	-- __targetNode:setTag(1)
	-- self._inputLabelArray[#self._inputLabelArray + 1] = atlasNode
	-- for i=1,6 do
		local atlasNode = ccui.TextAtlas:create("0",atlasFile,32,46,"0")
		local size = __targetNode:getContentSize()
		atlasNode:setPosition(offset.x + (index-1)*0.1  ,offset.y)
		__targetNode:addChild(atlasNode)
		atlasNode:setTag(index+1)
		atlasNode:setVisible(false)
		self._inputLabelArray[#self._inputLabelArray + 1] = atlasNode
	-- end

end

function JoinRoomView:_addBtns( __imgBg )
	local imgBg = __imgBg
	local dir = self:findCreateRoomDir()
    local btnNumNormal =  dir .. "btnNum.png"
	local btnNumPD =  dir .. "btnNum.png"

	local btnResetNormal =  dir .. "btnReset.png"
	local btnResetPD =  dir .. "btnReset.png"

	local btnDelNormal =  dir .. "btnInputDelete.png"
	local btnDelPD =  dir .. "btnInputDelete.png"

	local paddingWidth = 25  local paddingV = 20
	local rowNum = 4 		 local col = 3
	local leftTop = {x = 120,y = 385-15}
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
	button:setPosition(display.width/2 +270, 200)--创建房间按钮
	self:addChild(button)

	local txt1 = ccui.Text:create()
	txt1:setText("欢迎来到私人房：")
	txt1:setFontSize(26)
	txt1:setTextColor(cc.c4b(255, 255, 255, 255))
	txt1:setAnchorPoint(cc.p(0, 0))
	txt1:setPosition(cc.p(self:getContentSize().width/2+130, self:getContentSize().height*0.7-50))
	self:addChild(txt1)
	local txt2 = ccui.Text:create()
	txt2:setText("1.点击创建私人房，邀请\n好友来对战。")
	txt2:setFontSize(26)
	txt2:setTextColor(cc.c4b(255, 255, 255, 255))
	txt2:setAnchorPoint(cc.p(0, 0))
	txt2:setPosition(cc.p(self:getContentSize().width/2+130, self:getContentSize().height*0.7-120))
	self:addChild(txt2)
	local txt3 = ccui.Text:create()
	txt3:setText("2.输入房间号码，进入好\n友创建的房间。")
	txt3:setFontSize(26)
	txt3:setTextColor(cc.c4b(255, 255, 255, 255))
	txt3:setAnchorPoint(cc.p(0, 0))
	txt3:setPosition(cc.p(self:getContentSize().width/2+130, self:getContentSize().height*0.7-220))
	self:addChild(txt3)

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
				if __info.data.server_ip and __info.data.server_port then 
					local gameIp = __info.data.server_ip
					local gamePort = __info.data.server_port
					
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