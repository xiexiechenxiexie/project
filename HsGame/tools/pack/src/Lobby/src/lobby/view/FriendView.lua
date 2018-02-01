-- 好友
-- @date 2017.08.29
-- @author tangwen

local FriendView = class("FriendView", lib.layer.Window)

local PlayerInfo = require "PlayerInfoView"

local FriendViewType = {
	MY_FRIEND_VIEW = 1,
	ADD_FRIEND_VIEW = 2,
	APPLY_FRIEND_VIEW = 3,
} 

local FRIEND_SCROLLVIEW_SIZE = cc.size(780, 563)  -- 滑动界面大小
local FRIEND_VIEW_POSITION = cc.p(287.5, 20)		-- 滑动界面初始化位置
local RECORD_SIZE = cc.size(780,117)   			--滑动界面节点大小 记录节点大小 
local FRIEND_INTERVAL_V = 117   --每条记录之间的间距 竖 
local FRIEND_MAX_COL = 1		 -- 列数

function FriendView:ctor()
	FriendView.super.ctor(self,ConstantsData.WindowType.WINDOW_BIG)
	self:initView()
end

function FriendView:initView()
	self._FriendBgList = {}
	self._FriendBtnList = {}
	self._FriendTitleList = {}

    local bg = self._root
    self._bg = bg

    local bgSize = bg:getContentSize()

	self._MyFriendBg = display.newNode()
    self._MyFriendBg:setPosition(0,0)
    bg:addChild(self._MyFriendBg )

	self._AddFriendBg = display.newNode()
    self._AddFriendBg:setPosition(0,0)
    bg:addChild(self._AddFriendBg)
    self._AddFriendBg:hide()

	self._ApplyFriendBg = display.newNode()
    self._ApplyFriendBg:setPosition(0,0)
    bg:addChild(self._ApplyFriendBg)
    self._ApplyFriendBg:hide()

    table.insert(self._FriendBgList,self._MyFriendBg)
    table.insert(self._FriendBgList,self._AddFriendBg)
    table.insert(self._FriendBgList,self._ApplyFriendBg)

    local title = ccui.ImageView:create("Lobby_Friend_title.png", ccui.TextureResType.plistType)
	title:setPosition(bgSize.width/2, bgSize.height - 60)
	bg:addChild(title)

	-- local btnBgImg = ccui.ImageView:create("Lobby_Friend_btnBg.png", ccui.TextureResType.plistType)
	-- btnBgImg:setPosition(bgSize.width/2, bgSize.height - 70)
	-- bg:addChild(btnBgImg,3)
	local btnBgSize = bg:getContentSize()

	for i=1,3 do
		local friendbg = ccui.ImageView:create("Lobby_notice_title.png", ccui.TextureResType.plistType)
		friendbg:setPosition(cc.p(154,523-(i-1)*121))
		bg:addChild(friendbg)
	end

	local selectBtnImg = "Lobby_notice_title_bg.png"
    self._btnMyFriend = ccui.Button:create(selectBtnImg, selectBtnImg, selectBtnImg, ccui.TextureResType.plistType)
	self._btnMyFriend:addClickEventListener(function()
		self:requestMyFriendView()
	end)
	self._btnMyFriend:setPosition(154,523)
	bg:addChild(self._btnMyFriend)

	self._btnAddFriend = ccui.Button:create(selectBtnImg, selectBtnImg, selectBtnImg, ccui.TextureResType.plistType)
	self._btnAddFriend:addClickEventListener(function()
		self:requestAddFriendView()
	end)
	self._btnAddFriend:setPosition(154,523-121)
	bg:addChild(self._btnAddFriend)

	self._btnApplyFriend = ccui.Button:create(selectBtnImg, selectBtnImg, selectBtnImg, ccui.TextureResType.plistType)
	self._btnApplyFriend:addClickEventListener(function()
		self:requestApplyFriendView()
	end)
	self._btnApplyFriend:setPosition(154,523-121*2)
	bg:addChild(self._btnApplyFriend)

	table.insert(self._FriendBtnList,self._btnMyFriend)
	table.insert(self._FriendBtnList,self._btnAddFriend)
	table.insert(self._FriendBtnList,self._btnApplyFriend)

	self._MyFriendTitle = cc.Label:createWithTTF("游戏好友",GameUtils.getFontName(),30)
    self._MyFriendTitle:setColor(cc.c3b(255,255,255))
    self._MyFriendTitle:setPosition(154,523)
    bg:addChild(self._MyFriendTitle)
    self._MyFriendTitle:show()

    self._AddFriendTitle = cc.Label:createWithTTF("添加好友",GameUtils.getFontName(),30)
    self._AddFriendTitle:setColor(cc.c3b(255,255,255))
    self._AddFriendTitle:setPosition(154,523-121)
    bg:addChild(self._AddFriendTitle)
    self._AddFriendTitle:show()

    self._ApplyFriendTitle = cc.Label:createWithTTF("好友邀请",GameUtils.getFontName(),30)
    self._ApplyFriendTitle:setColor(cc.c3b(255,255,255))
    self._ApplyFriendTitle:setPosition(154,523-121*2)
    bg:addChild(self._ApplyFriendTitle)
    self._ApplyFriendTitle:show()

    table.insert(self._FriendTitleList,self._MyFriendTitle)
	table.insert(self._FriendTitleList,self._AddFriendTitle)
	table.insert(self._FriendTitleList,self._ApplyFriendTitle)

	local addFriendLabel = cc.Label:createWithTTF("添加好友:",GameUtils.getFontName(),26)
    addFriendLabel:setColor(cc.c3b(255,255,255))
    addFriendLabel:setPosition(375,bgSize.height/2 + 150+45)
    self._AddFriendBg:addChild(addFriendLabel,10)

	--输入框
	local editBoxSize = cc.size(427,58)
	self._EditBox = cc.EditBox:create(editBoxSize,"Lobby_Friend_check_bg.png", ccui.TextureResType.plistType)
	self._EditBox:setPosition(bgSize.width/2 + 5+100,bgSize.height/2 + 150+45)
	self._EditBox:setFontName(GameUtils.getFontName())
	self._EditBox:setFontSize(28)
    self._EditBox:setFontColor(cc.c3b(255,255,255))
    self._EditBox:setPlaceHolder("请输入好友ID:")
    self._EditBox:setPlaceholderFontColor(cc.c3b(255,255,255))
    -- editbox:setMaxLength(8)
    self._EditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self._EditBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self._EditBox:registerScriptEditBoxHandler(function(strEventName,pSender)self:editBoxTextEventHandle(strEventName,pSender)end)
	self._AddFriendBg:addChild(self._EditBox)

	local checkBtnImg = "Lobby_Friend_btn_check.png"
	local btnCheckFriend = lib.uidisplay.createUIButton({
		normal = checkBtnImg,
		textureType = ccui.TextureResType.plistType,
		isActionEnabled = true,
		callback = function() 
			local checkStr = self._EditBox:getText()
			if #checkStr == 0 then
				return
			end
			self:requestCheckFriend(checkStr)
		end
		})

	btnCheckFriend:setPosition(bgSize.width - 205+90,bgSize.height/2 + 147+45)
	self._AddFriendBg:addChild(btnCheckFriend)

end

function FriendView:editBoxTextEventHandle(strEventName,pSender)
    if strEventName == "began" then  
        self._EditBox:setText("")		             --光标进入，清空内容/选择全部  
        self._EditBox:setPlaceHolder("")
    elseif strEventName == "ended" then  
        											  --当编辑框失去焦点并且键盘消失的时候被调用  
    elseif strEventName == "return" then  
  	    self._EditBox:setPlaceHolder("请输入姓名:")    --当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用  
    elseif strEventName == "changed" then  
                                                    --输入内容改变时调用   
    end  
end

function FriendView:requestMyFriendView()
	self:showFriendViewByIndex(FriendViewType.MY_FRIEND_VIEW)

	logic.FriendManager:getInstance():requestFriendListData(function( result )
		if result then
			UserData.FriendList = result
			self:showMyFriendView(result)
		end
	end)
end

function FriendView:requestAddFriendView()
	self:showFriendViewByIndex(FriendViewType.ADD_FRIEND_VIEW)
	if not tolua.isnull(self._AddFriendRecord) then
        GameUtils.removeNode(self._AddFriendRecord)
        self._AddFriendRecord = nil
    end
end

-- 请求查找好友
function FriendView:requestCheckFriend(__input)
	logic.FriendManager:getInstance():requestCheckFriendData(__input, function( result )
		if result then
			self:showAddFriendView(result)
		else
			GameUtils.showMsg("玩家不存在!")
		end
	end)
end

-- 请求添加好友
function FriendView:requestAddFriend(__node,__userID)
	logic.FriendManager:getInstance():requestAddFriendData(__userID, function( result )
		if result then
			GameUtils.showMsg("请等待对方同意！")
			__node.addBtn:hide()
		end
	end)
	
end

-- 请求添加好友
function FriendView:requestReplyApplyFriend(__Node, __userID, __actionID)
	logic.FriendManager:getInstance():requestReplyApplyFriendData(__userID, __actionID, function( result )
		if result then
			__Node._okBtn:hide()
			__Node._refuseBtn:hide()
			if __actionID == 0 then --拒绝
				__Node._hasRefuseLabel:show()
			else
				__Node._hasOkLabel:show()
			end
			print("requestReplyApplyFriend scuess")
		end
	end)
	
end

function FriendView:requestApplyFriendView()

	self:showFriendViewByIndex(FriendViewType.APPLY_FRIEND_VIEW)

	logic.FriendManager:getInstance():requestApplyFriendListData(function( result )
		if result then
			self:showApplyFriendView(result)
		end
	end)
end

function FriendView:showFriendViewByIndex(__index)
	self._EditBox:setText("")
	for k,v in pairs(self._FriendBgList) do
		if k == __index then
			self._FriendBgList[k]:show()
			self._FriendBtnList[k]:setOpacity(255)
			self._FriendBtnList[k]:setEnabled(false)
			self._FriendTitleList[k]:setColor(cc.c3b(255,255,255))
		else
			self._FriendBgList[k]:hide()
			self._FriendBtnList[k]:setOpacity(0)
			self._FriendBtnList[k]:setEnabled(true)
			self._FriendTitleList[k]:setColor(cc.c3b(191, 169, 125))
		end
	end
end

function FriendView:showMyFriendView(__data)
	if not tolua.isnull(self._MyFriendScrollView) then
        GameUtils.removeNode(self._MyFriendScrollView)
        self._MyFriendScrollView = nil
    end

    local row = #__data

	self._MyFriendScrollView = self:createScrollView(row)
	self._MyFriendBg:addChild(self._MyFriendScrollView,1)

	local contentSize = cc.size(FRIEND_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (row - 1) * FRIEND_INTERVAL_V + 36)
	if contentSize.height < FRIEND_SCROLLVIEW_SIZE.height then
		contentSize = FRIEND_SCROLLVIEW_SIZE
	end

    local offset = cc.p(0, contentSize.height)
    local PosY = 0

    self._list = {}

	for k, v in ipairs(__data) do
        local record= self:createMyFriendRecord(v)
        local row = k
        local x = offset.x +RECORD_SIZE.width/2 
        local y =60 + offset.y - row * FRIEND_INTERVAL_V
        record:setPosition(x,y)
        self._MyFriendScrollView:addChild(record)
    end

 --    local __RichTextList = {{Color3B = cc.c3b(224,221,245), opacity = 255, richText = "好友数量:", fontSize = 24},
 --                    		{Color3B = cc.c3b(44,224,0), opacity = 255, richText = row.. "/", fontSize = 24},
 --                    		{Color3B = cc.c3b(224,221,245), opacity = 255, richText = "50", fontSize = 24}}
 --    if self._richText then
 --    	GameUtils.removeNode(self._richText)
 --    	self._richText = nil
 --    end               		
	-- self._richText = GameUtils.createRichText(__RichTextList)
	-- self._richText:setPosition(125,30)
	-- self._MyFriendBg:addChild(self._richText)

end

function FriendView:showAddFriendView(__data)
	if not tolua.isnull(self._AddFriendRecord) then
        GameUtils.removeNode(self._AddFriendRecord)
        self._AddFriendRecord= nil
    end

    local bgSize = self._bg:getContentSize()
    self._AddFriendRecord = self:createAddFriendRecord(__data)
    self._AddFriendRecord:setPosition(bgSize.width/2+132,bgSize.height/2 + 50)
    self._AddFriendBg:addChild(self._AddFriendRecord,1)


end

function FriendView:showApplyFriendView(__data)
	if not tolua.isnull(self._ApplyFriendScrollView) then
        GameUtils.removeNode(self._ApplyFriendScrollView)
        self._ApplyFriendScrollView = nil
    end

    local row = #__data

	self._ApplyFriendScrollView = self:createScrollView(row)
	self._ApplyFriendBg:addChild(self._ApplyFriendScrollView,1)

	local contentSize = cc.size(FRIEND_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (row - 1) * FRIEND_INTERVAL_V + 36)
	if contentSize.height < FRIEND_SCROLLVIEW_SIZE.height then
		contentSize = FRIEND_SCROLLVIEW_SIZE
	end

    local offset = cc.p(0, contentSize.height)
    local PosY = 0

	for k, v in ipairs(__data) do
        local record= self:createApplyFriendRecord(v)
        local row = k
        local x = offset.x +RECORD_SIZE.width/2 
        local y =50 + offset.y - row * FRIEND_INTERVAL_V
        record:setPosition(x,y)
        self._ApplyFriendScrollView:addChild(record)
    end

end



function FriendView:createScrollView(rowNum)
	local contentSize = cc.size(FRIEND_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (rowNum - 1) * FRIEND_INTERVAL_V + 36)

	local _FriendScrollView = ccui.ScrollView:create()
    _FriendScrollView:setTouchEnabled(true)--触摸的属性
    _FriendScrollView:setBounceEnabled(true)--弹回的属性
    _FriendScrollView:setInertiaScrollEnabled(true)--滑动的惯性
    _FriendScrollView:setScrollBarEnabled(false)
    _FriendScrollView:setDirection(ccui.ScrollViewDir.vertical)
    _FriendScrollView:setContentSize(FRIEND_SCROLLVIEW_SIZE)
    _FriendScrollView:setInnerContainerSize(contentSize)
    _FriendScrollView:setPosition(FRIEND_VIEW_POSITION)

    return _FriendScrollView
end

function FriendView:createMyFriendRecord(data)
	print("短时间看的哈市加快了")
	dump(data)
	if data == nil then
		return
	end

	local size = cc.size(780, 117)
	local record = ccui.Layout:create()

   	local bg =  ccui.ImageView:create("Lobby_Friend_list_bg.png", ccui.TextureResType.plistType)
    bg:setContentSize(size)
    bg:setPosition(cc.p(0,0))
    record:addChild(bg)

    local NickName = data.nickName or ""
	local nameText = cc.Label:createWithTTF(NickName,GameUtils.getFontName(),24)
	nameText:setColor(cc.c3b(224,221,245))
    nameText:setAnchorPoint(cc.p(0, 0.5))
    nameText:setPosition(-size.width/2 + 100, 20)
    record:addChild(nameText)



    local stateText = cc.Label:createWithTTF("",GameUtils.getFontName(),18)
	stateText:setColor(cc.c3b(44,224,0))
    stateText:setAnchorPoint(cc.p(0, 0.5))
    stateText:setPosition(-size.width/2 + 100, -20)
    record:addChild(stateText)

    local stateStr = ""
	if data.kind_id ~= nil  then 
		local __RichTextList = {}
		if data.game_type == config.GameType.SRF then
		    __RichTextList = {{Color3B = cc.c3b(255,255,255), opacity = 255, richText = "正在", fontSize = 18},
                	{Color3B = cc.c3b(44,224,0), opacity = 255, richText = config.GameModelNameText[data.kind_id] .. "私人房", fontSize = 18},
                	{Color3B = cc.c3b(255,255,255), opacity = 255, richText = "游戏中", fontSize = 18}}
		else
			__RichTextList = {{Color3B = cc.c3b(255,255,255), opacity = 255, richText = "正在", fontSize = 18},
            	   	{Color3B = cc.c3b(44,224,0), opacity = 255, richText = config.GameModelNameText[data.kind_id], fontSize = 18},
                	{Color3B = cc.c3b(255,255,255), opacity = 255, richText = "游戏中", fontSize = 18}}
		end
		local stateText = GameUtils.createRichText(__RichTextList)
		stateText:setColor(cc.c3b(44,224,0))
    	stateText:setAnchorPoint(cc.p(0, 0.5))
    	stateText:setPosition(-size.width/2 + 100, -20)
    	record:addChild(stateText)

	elseif data.isOnline ~= 0 then
		stateStr = "正在大厅中闲逛"
		local stateText = cc.Label:createWithTTF(stateStr,GameUtils.getFontName(),18)
		stateText:setColor(cc.c3b(255,174,0))
		stateText:setAnchorPoint(cc.p(0, 0.5))
		stateText:setPosition(-size.width/2 + 100, -20)
		record:addChild(stateText)
	else
		stateStr = "离线"
		local stateText = cc.Label:createWithTTF(stateStr,GameUtils.getFontName(),18)
		stateText:setColor(cc.c3b(144,143,150))
		stateText:setAnchorPoint(cc.p(0, 0.5))
		stateText:setPosition(-size.width/2 + 100, -20)
		record:addChild(stateText)
	end

	local Gender = data.gender or 0
    local GenderStr = GameUtils.getDefalutHeadFileByGender(Gender)

    local AvatarUrl = data.avatarUrl or ""
    local awatar = lib.node.Avatar:create({
	 avatarUrl = AvatarUrl,
	 stencilFile = "res/Avatar/head_rect_round_stencil_94_94.png",
	 defalutFile = GenderStr,
	 frameFile = nil,
		})
	awatar:setPosition(-size.width/2 + 10, -size.height/2 + 20)
	awatar:setScale(0.8)
	record:addChild(awatar)

	local headBtnImg = "res/Avatar/default_unkonw.png"
	local headBtn = ccui.Button:create(headBtnImg,headBtnImg,headBtnImg,ccui.TextureResType.localType)
	headBtn:setOpacity(0)
	headBtn:setScale(1)
	headBtn:setPosition(-size.width/2 + 50,0)
	record:addChild(headBtn)
	headBtn:addClickEventListener(function()
		local playerInfoView = PlayerInfo.new(data.userId)
		self:addChild(playerInfoView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
	end)

	local moneyIconImg = ccui.ImageView:create("common_icon_coisn.png", ccui.TextureResType.plistType)
	moneyIconImg:setPosition(-23,0)
	record:addChild(moneyIconImg)

 	local moneyText = GameUtils.createSwitchNumNode(data.score or 99990)
 	moneyText:setAnchorPoint(cc.p(0, 0.5))
	moneyText:setPosition(15, 0)
	record:addChild(moneyText)

	-- local chatBtnImg = "Lobby_Friend_btn_chat.png"
 --    local chatBtn = lib.uidisplay.createUIButton({
 --        normal = chatBtnImg,
 --        textureType = ccui.TextureResType.plistType,
 --        isActionEnabled = true,
 --        callback = function() 
 --            print("chat")
 --            require "src/manager/ChatManager.lua"
	-- 		local chatManager = manager.ChatManager:getInstance()
	-- 		if UserData.FriendList and UserData.FriendList[1] then 
	-- 			chatManager:sendChat({
	-- 				msg = "中文测试",msgType = CHAT_MESSAGE_SCENE_TYPE.FRIEND_MESSAGE,userId = UserData.userId,
	-- 				toUserId = UserData.FriendList[1].UserId,tableId = 0,contentType = CHAT_MESSAGE_CONTENT_TYPE.TEXT
	-- 				})
	-- 		end
 --        end
 --        })

	-- chatBtn:setPosition(size.width/2 - 68, 0)
	-- record:addChild(chatBtn)
	-- chatBtn:hide()
	
    return record
end

function FriendView:createAddFriendRecord(data)
	if data == nil then
		return
	end
	local size = cc.size(780, 117)
	local record = ccui.Layout:create()

   	local bg =  ccui.ImageView:create("Lobby_Friend_list_bg.png", ccui.TextureResType.plistType)
    bg:setContentSize(size)
    bg:setPosition(cc.p(0,0))
    record:addChild(bg)

    local NickName = data.nickName or ""
	local nameText = cc.Label:createWithTTF(NickName,GameUtils.getFontName(),24)
	nameText:setColor(cc.c3b(224,221,245))
    nameText:setAnchorPoint(cc.p(0, 0.5))
    nameText:setPosition(-size.width/2 + 100, 20)
    record:addChild(nameText)

    local stateStr = ""
    if data.kind_id ~= nil then 
    	stateStr = "正在"..config.GameModelNameText[data.kind_id].."游戏中"
    end

    local stateText = cc.Label:createWithTTF(stateStr,GameUtils.getFontName(),18)
	stateText:setColor(cc.c3b(44,224,0))
    stateText:setAnchorPoint(cc.p(0, 0.5))
    stateText:setPosition(-size.width/2 + 100, -20)
    record:addChild(stateText)

    local Gender = data.gender or 0
    local GenderStr = GameUtils.getDefalutHeadFileByGender(Gender)

    local AvatarUrl = data.avatarUrl or ""
    local awatar = lib.node.Avatar:create({
	 avatarUrl = AvatarUrl,
	 stencilFile = "res/Avatar/head_rect_round_stencil_94_94.png",
	 defalutFile = GenderStr,
	 frameFile = nil,
		})
	awatar:setPosition(-size.width/2 + 10, -size.height/2 + 20)
	awatar:setScale(0.8)
	record:addChild(awatar)

	local moneyIconImg = ccui.ImageView:create("common_icon_coisn.png", ccui.TextureResType.plistType)
	moneyIconImg:setPosition(-23,0)
	record:addChild(moneyIconImg)

 	local moneyText = GameUtils.createSwitchNumNode(data.score or 0)
 	moneyText:setAnchorPoint(cc.p(0, 0.5))
	moneyText:setPosition(15, 0)
	record:addChild(moneyText)

	local addBtnImg = "Lobby_Friend_btn_add.png"
    record.addBtn = lib.uidisplay.createUIButton({
        normal = addBtnImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            self:requestAddFriend(record,data.userId)
        end
        })
	record.addBtn:setPosition(size.width/2 - 110, 0)
	record:addChild(record.addBtn)

    return record
end

function FriendView:createApplyFriendRecord(data)
	if data == nil then
		return
	end

	local size = cc.size(780, 117)
	local record = ccui.Layout:create()

   	local bg =  ccui.ImageView:create("Lobby_Friend_list_bg.png", ccui.TextureResType.plistType)
    bg:setContentSize(size)
    bg:setPosition(cc.p(0,0))
    record:addChild(bg)

    local NickName = data.nickName or ""
	local nameText = cc.Label:createWithTTF(NickName,GameUtils.getFontName(),24)
	nameText:setColor(cc.c3b(224,221,245))
    nameText:setAnchorPoint(cc.p(0, 0.5))
    nameText:setPosition(-size.width/2 + 100, 20)
    record:addChild(nameText)

    local Gender = data.gender or 0
    local GenderStr = GameUtils.getDefalutHeadFileByGender(Gender)

    local AvatarUrl = data.avatarUrl or ""
    local awatar = lib.node.Avatar:create({
	 avatarUrl = AvatarUrl,
	 stencilFile = "res/Avatar/head_rect_round_stencil_94_94.png",
	 defalutFile = GenderStr,
	 frameFile = nil,
		})
	awatar:setPosition(-size.width/2 + 10, -size.height/2 + 10)
	awatar:setScale(0.8)
	record:addChild(awatar)

	-- local moneyIconImg = ccui.ImageView:create("common_icon_coisn.png", ccui.TextureResType.plistType)
	-- moneyIconImg:setPosition(-23,0)
	-- record:addChild(moneyIconImg)

 -- 	local moneyText = GameUtils.createSwitchNumNode(data.Score or 99990)
 -- 	moneyText:setAnchorPoint(cc.p(0, 0.5))
	-- moneyText:setPosition(15, 0)
	-- record:addChild(moneyText)

	record._hasOkLabel = cc.Label:createWithTTF("添加好友成功!",GameUtils.getFontName(),24)
	record._hasOkLabel:setColor(cc.c3b(44,224,0)) 
    record._hasOkLabel:setPosition(size.width/2 - 116, 0)
    record:addChild(record._hasOkLabel)
    record._hasOkLabel:hide()

    record._hasRefuseLabel =  cc.Label:createWithTTF("拒绝了好友申请!",GameUtils.getFontName(),24)
    record._hasRefuseLabel:setColor(cc.c3b(247,34,34)) 
    record._hasRefuseLabel:setPosition(size.width/2 - 116, 0)
    record:addChild(record._hasRefuseLabel)
    record._hasRefuseLabel:hide()

	local okBtnImg = "common_btn_ok.png"
	local refuseBtnImg = "common_btn_no.png"

    record._okBtn = lib.uidisplay.createUIButton({
        normal = okBtnImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            self:requestReplyApplyFriend(record, data.userId, 1)
        end
        })
	record._okBtn:setPosition(size.width/2 - 60, 0)
	record:addChild(record._okBtn)

	record._refuseBtn = lib.uidisplay.createUIButton({
        normal = refuseBtnImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            self:requestReplyApplyFriend(record, data.userId, 0)
        end
        })
	record._refuseBtn:setPosition(size.width/2 - 172, 0)
	record:addChild(record._refuseBtn)

    return record
end


function FriendView:onEnter( ... )
	FriendView.super.onEnter(self)
	self:requestMyFriendView()
end

function FriendView:onExit( ... )

end

return FriendView