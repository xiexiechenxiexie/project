-- 游戏消息和逻辑基类 用于处理一些通用的逻辑和消息
-- @date 2017.07.13
-- @author tangwen
-- @ 游戏消息分发。

local ManagerModel = require "logic/ManagerBase"
local GameManager = class("GameManager", ManagerModel)
local header = require "header/headFile"
local SocketClient = require "Lobby/src/net/SocketClient"
local PlayerInfoManager = require "logic/PlayerInfoManager"
local GameRequest = require "request/GameRequest"


GameManager.EVENT_LEAVE_TABLE = "EVENT_LEAVE_TABLE" 				-- 离开房间
GameManager.EVENT_TABLE_INFO = "EVENT_TABLE_INFO" 					-- 桌子上所有的数据
GameManager.EVENT_REMOVE_TABLE = "EVENT_REMOVE_TABLE" 				-- 销毁桌子
GameManager.EVENT_DISSOLUTION = "EVENT_DISSOLUTION" 				-- 申请解散
GameManager.EVENT_DISSOLUTION_ACTION = "EVENT_DISSOLUTION_ACTION"	-- 解散的行为（同意，拒绝）
GameManager.EVENT_DISSOLUTION_RESULT = "EVENT_DISSOLUTION_RESULT"	-- 解散的结果
GameManager.EVENT_NETWORK_ERR = "EVENT_NETWORK_ERR" 				-- 网络错误
GameManager.EVENT_IS_ONLINE = "EVENT_IS_ONLINE" 					-- 在线，离线
GameManager.EVENT_HEAT_JUMP = "EVENT_HEAT_JUMP" 					-- 心跳
GameManager.EVENT_CHAT_TEXT = "EVENT_CHAT_TEXT" 					-- 聊天文本
GameManager.EVENT_CHAT_BROW = "EVENT_CHAT_BROW" 					-- 聊天表情
GameManager.EVENT_CHAT_TALK = "EVENT_CHAT_TALK" 					-- 聊天语音
GameManager.EVENT_THROW_PROPERTY = "EVENT_THROW_PROPERTY" 			-- 道具
GameManager.EVENT_BANKRUPT = "EVENT_BANKRUPT" 						-- 破产补助
GameManager.EVENT_PLAYER_BANKRUPT_SUCCEED = "EVENT_PLAYER_BANKRUPT_SUCCEED"--领取成功
GameManager.EVENT_USER_AUTHORIZE_SIT_APPLY = "EVENT_USER_AUTHORIZE_SIT_APPLY" -- 房主收到授权入座申请
GameManager.EVENT_USER_AUTHORIZE_ACTION = "EVENT_USER_AUTHORIZE_ACTION" 	-- 房主处理授权入座的行为码
GameManager.EVENT_USER_AUTHORIZE_RESULT = "EVENT_USER_AUTHORIZE_RESULT" 	-- 授权入座的结果（同意，拒绝）
GameManager.EVENT_PAY_RESULT= "EVENT_PAY_RESULT" 					--扣房卡结果 
GameManager.EVENT_CHANGE_TABLE= "EVENT_CHANGE_TABLE" 					--扣房卡结果 

GameManager.EVENT_USER_LOGIN = "EVENT_USER_LOGIN" 				-- 登陆   游戏界面里面直接重连
GameManager.EVENT_USER_JOIN_TABLE = "EVENT_USER_JOIN_TABLE" 	-- 加入房间
GameManager.EVENT_REFRESH_USERDATA = "EVENT_REFRESH_USERDATA" 	-- 更新玩家数据
GameManager._isGameFinished = false 	

function GameManager:ctor()
    GameManager.super.ctor(self)
    self:reset()
    self._view = nil
    print("GameManager:initDealMsgState ctor")
    self:initDealMsgState()
    self._gameRequest = GameRequest:new()
end

function GameManager:initDealMsgState()
	self.IsDealMsg = false  -- 是否开始处理信息，在接受到tabelInfo之后设置 true 开始处理消息
	self.CloseScoketNoMal = true --是否是正常关闭close
end

-- 离开房间
function GameManager:onUserLeaveTable(event,data)
	local byteArray = GameUtils.createByteArray(data)
	local State = byteArray:readUInt() 
	local ErrCode = byteArray:readUInt()
	print("onUserLeaveTable:",State)
	if State == 1 then -- 离开房间 关闭socket 离开房间
		if ErrCode == ConstantsData.LeaveTableCode.ERR_CHANGE_TABLE_NORMAL then--换桌
			require("lobby/scene/LobbyScene"):create():runWithScene()
		else
			self:enterLobby()
		end
	else
		GameUtils.showMsg("离开房间失败")
	end
end

--换桌成功
function GameManager:onChangeTable(event,data)
	local byteArray = GameUtils.createByteArray(data)
	local ChangeState = byteArray:readUInt() -- 坐下状态 1 为成功 0为失败 返回错误码
    local code = byteArray:readUInt()
    print("ChangeState,code:",ChangeState,code)
    if ChangeState == 1 and code == 0 then
        print("换桌成功")
        self._view:ShowChangeTable()
    else
        if code == 1 then
            GameUtils.showMsg("正在游戏中，换桌失败")
        elseif code == 2 then
            GameUtils.showMsg("换桌失败")
        end
    end
end

-- 桌子的所有数据
function GameManager:onTableInfo(event,data)

end

-- 销毁桌子
function GameManager:onRemoveTable(event,data)
	self._view:onRemoveTable(data)
end

-- 申请解散桌子
function GameManager:onDissolutionTable(event,data)
	local byteArray = GameUtils.createByteArray(data)
	local succode = byteArray:readUInt()
	local errcode = byteArray:readUInt()
	if succode == 1 then
		-- print("申请解散房间成功")
	else

	end
end

--  解散的行为（同意，拒绝）
function GameManager:onDissolutionAction(event,data)
	print("解散的行为（1同意，0拒绝,2请等待）")
	local byteArray = GameUtils.createByteArray(data)
	local DismissArrayInfo = {}
	DismissArrayInfo.ReqUid = byteArray:readUInt()
	DismissArrayInfo.alltime = byteArray:readUInt()
	DismissArrayInfo.time = byteArray:readUInt()
	DismissArrayInfo.DismissArray = {}
	local player_num = byteArray:readUInt()
	for i=1,player_num do
		local DismissArray = {}
		DismissArray.uid = byteArray:readUInt()
		DismissArray.isDissolution = byteArray:readUInt()
		table.insert(DismissArrayInfo.DismissArray,DismissArray)
	end
	self._view:onGameDissolutionAction(DismissArrayInfo)
end

-- 解散的结果
function GameManager:onDissolutionResult(event,data)
	-- self._view:onGameDissolutionResult(data)
	local byteArray = GameUtils.createByteArray(data)
	local apUid	=byteArray:readUInt()
	local State = byteArray:readUInt()
	print("解散的结果",State)
	local uid = nil
	if State == 0 then
		uid = byteArray:readUInt()
	end
	self._view:onDissolutionResult(State,uid)

end

-- 网络错误
function GameManager:onNetWorkErr(event,data)
	--self._view:onNetWorkErr(data)
end

-- 在线，离线
function GameManager:onNetWorkState(event,data)
	--self._view:onNetWorkState(data)
end

-- 心跳  心跳已经在外边处理了。 
function GameManager:onHeartbeat(event,data)
	--self._view:onHeartbeat(data)
end

-- 聊天文本--字符串的首个字符表示字符串种类,"T":表示是固定的字符串,"F":表示玩家输入的自定义短语
function GameManager:onChatText(event,data)
	local byteArray = GameUtils.createByteArray(data)
	local sitId=byteArray:readUInt()
	local uid=byteArray:readUInt()
	local len = byteArray:readUShort()
	local chatStr = byteArray:readString(len)
	if self.onGameChatText then
		local strType = string.sub(chatStr,1,1)
		local str = string.sub(chatStr,2,len)
		local dataArry = {["sitId"] = sitId,["uid"] = uid,["str"] = str,["strType"] = strType,}
		self:onGameChatText(dataArry)
	end
end


-- 聊天表情 
function GameManager:onChatBrow(event,data)
	local byteArray = GameUtils.createByteArray(data)
	local sitId=byteArray:readUInt()
	local uid=byteArray:readUInt()
	local browId = byteArray:readUInt()
	if self.onGameChatBrow then
		local dataArry={["sitId"]=sitId,["uid"]=uid,["browId"]=browId}
		self:onGameChatBrow(dataArry)
	end
end

-- 聊天语音 
function GameManager:onChatTalk(event,data)
	if self.onGameChatTalk then
		self:onGameChatTalk(data)
	end
end

-- 道具 
function GameManager:onProp(event,data)
	local dataArry = {}
	local byteArray = GameUtils.createByteArray(data)
	dataArry.SrcUid=byteArray:readUInt()
	dataArry.DestUid = byteArray:readUInt()
	dataArry.PropIndex = byteArray:readUInt()
	local len = byteArray:readUShort()
	dataArry.curScore = tonumber(byteArray:readString(len))
	if self.onGameProp then
		self:onGameProp(dataArry)
	end
end

-- 请求玩家信息
function GameManager:requestGamePlayerInfoData(__userID)
    logic.PlayerInfoManager:getInstance():requestPlayerInfoData(__userID,function( result )
        if result then
            self._view:showGamePlayerInfo(result)     
        end
    end)
end

-- 破产补助
function GameManager:onBankRupt(event,data)
	local dataArry = {}
	local byteArray = GameUtils.createByteArray(data)
	dataArry.curTimes = byteArray:readUInt()
	dataArry.sumTimes = byteArray:readUInt()
    dataArry.bankGoldNum = byteArray:readUInt()
    dataArry.getSign = byteArray:readUInt()
    if self.onGameBankRupt then
    	self:onGameBankRupt(dataArry)
    end
end

-- 破产补助领取成功  谁领了，领了多少钱，当前uid玩家有多少钱
function GameManager:onBankSucc(event,data)
	local dataArray = {}
	local byteArray = GameUtils.createByteArray(data)
	dataArray.uid = byteArray:readUInt()
	local len = byteArray:readUShort()
	dataArray.curScore = tonumber(byteArray:readString(len))
	if self.onGameBankSucc then
    	self:onGameBankSucc(dataArray)
    end
end

-- 房主收到授权入座申请回调
function GameManager:onUserAuthorizeSitApply(event,data)
	print("LobbyManager:onUserAuthorizeSitApply")
	local byteArray = GameUtils.createByteArray(data)
    local applyUserID = byteArray:readUInt()
    local tableID = byteArray:readUInt()
    local gameID = byteArray:readUInt()
    local nickNameStrLen = byteArray:readShort()
    local nickName = byteArray:readStringBytes(nickNameStrLen)
    print("applyUserID,tableID,gameID,nickName:",applyUserID,tableID,gameID,nickName)
    
    local __params = {applyUserID = applyUserID, tableID = tableID, gameID = gameID, nickName = nickName}
    if self._view then
    	self._view:showAuthorizeSitView(__params)
    end
end

-- 授权入座行为码回调
function GameManager:onUserAuthorizeAction(event,data)
	print("LobbyManager:onUserAuthorizeAction")
	local byteArray = GameUtils.createByteArray(data)
	local ActionState = byteArray:readUInt() -- 处理状态 1是处理成功 0是处理失败
	if ActionState == 1 then
		local actionID = byteArray:readUInt()
		local applyUserID = byteArray:readUInt()
		local tableID = byteArray:readUInt()
		local gameID = byteArray:readUInt()
		local __params = {applyUserID = applyUserID, tableID = tableID, gameID = gameID, actionID = actionID}
		dump(__params)
		self._view:updateInformView(__params)
	else
		print("处理授权入座失败")
	end
    
end

-- 授权入座结果
function GameManager:onUserAuthorizeResult(event,data)
	print("LobbyManager:onUserAuthorizeResult")
	local byteArray = GameUtils.createByteArray(data)
	local ResultState = byteArray:readUInt() -- 处理状态 1是处理成功 0是处理失败 2表示房卡不够 通知客户端可以按钮
	print("ResultState:",ResultState)
	self._view:AuthorizeResult(ResultState)
end

-- 扣房卡结果
function GameManager:onPayResult(event,data)
	print("GameManager:onPayResult")
	local byteArray = GameUtils.createByteArray(data)
	local ResultState = byteArray:readUInt() --  1是扣成功 0是扣失败 
	print("扣房卡结果",ResultState)
end

function GameManager:onUserLogin(event,data)
	print("GameManager:onUserLogin")
	GameUtils.stopLoading()
	local byteArray = GameUtils.createByteArray(data)
	local loginState = byteArray:readUInt() -- 登陆状态 1 为登陆成功 0为登陆失败 返回错误码
	local code = byteArray:readUInt()
	print("loginState:",loginState)
	if loginState  == 1 then
		self.CloseScoketNoMal = true
		local event = cc.EventCustom:new(config.EventConfig.initReConnectState)
		lib.EventUtils.dispatch(event)
		print("游戏登陆成功 :GameManager,code:",loginState,code)
	else
		print("游戏登陆失败 :loginState,code:",loginState,code)
		--GameUtils.showMsg("连接服务器失败，请重新连接,状态码:"..loginState)
		--重新连接服务器
		-- self:enterLobby()
		if code == ConstantsData.ApplyLoginCode.ERR_APPLY_LOGIN_INLIN then
			print("错误原因:已经在线")
			net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function() end)
			local function callback(event)
				if "ok" == event then
					LoginManager:enterLogin()
				end
			end
			local parm = {type = ConstantsData.ShowMgsBoxType.NORMAL_TYPE, msg = "账号异常，请重新登录", btn = {"ok"}, callback = callback}
			GameUtils.showMsgBox(parm)
			self.CloseScoketNoMal = false
		else
			GameUtils.showMsg("连接服务器失败，请重新连接")
			LoginManager:enterLogin()
		end
	end
end

-- 加入房间
function GameManager:onUserJoinTable(event,data)
	print("GameManager:onUserJoinTable")
	local byteArray = GameUtils.createByteArray(data)
	local joinState = byteArray:readUInt() -- 加入房间状态 1 为成功 0为失败 返回错误码
	local code = byteArray:readUInt()
	if joinState  == 1 then 
		print("加入房间成功 :joinState,code:",joinState,code)
		self:initDealMsgState() -- 初始化
		print("我要开始请求tableInfo")
		self._gameRequest:RequestTabelInfo()
		print("我请求tableInfo")
		--self._view:onEnterGame()	
	else
		if code == ConstantsData.JoinTableCode.ERR_JOIN_TABLE_NO_ALLOW then 
			GameUtils.showMsg("加入房间失败,没有权限")
		elseif code == ConstantsData.JoinTableCode.ERR_JOIN_TABLE_NO_INLIN then 
			GameUtils.showMsg("玩家离线")
		elseif code == ConstantsData.JoinTableCode.ERR_JOIN_TABLE_FULL_PLAYER then 
			GameUtils.showMsg("房间人数已满")
		elseif code == ConstantsData.JoinTableCode.ERR_JOIN_TABLE_IN_START then 
			GameUtils.showMsg("游戏已经开始")
		elseif code == ConstantsData.JoinTableCode.ERR_JOIN_TABLE_NOT_FIND then 
			GameUtils.showMsg("未找到房间")
		else 
			GameUtils.showMsg("加入房间失败 joinState" .. joinState .. "code".. code)
		end	
	end
end

-- 刷新玩家数据
function GameManager:onRefreshUserData(event,data)
	print("GameManager:onRefreshUserData")
	manager.UserManager:getInstance():refreshUserInfo()
end


-- 游戏切后台
function GameManager:GameToBackGround( __event )
	net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
		print("游戏切后台")
	end)
end


-- 后台切回游戏 直接走重连逻辑
function GameManager:backGroundToGame( __event )
	print("GameManager:后台切回游戏")
	if self.CloseScoketNoMal then
		self:ReconnectGameServer()
	end
end

function GameManager:ReconnectGameServer( ... )
	print("ReconnectGameServer")
	if not self._isGameFinished then 
		GameUtils.stopLoading()
		net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
			GameUtils.startLoading("正在进行重连，请稍等...")
			self._gameRequest:RequestLoginServer(ServerData.ServerIP,ServerData.ServerPort)
	    end)	
	end
end

function GameManager:requestLoginServer( ... )
	if not self._isGameFinished then 
		self._gameRequest:RequestLoginServer(ServerData.ServerIP,ServerData.ServerPort)
	end
end

function GameManager:enterLobby()
	print("进入大厅")
	net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
		require("lobby/scene/LobbyScene"):create():runWithScene()
    end)	
end

-- 在GameManager里面 收到tableInfo信息才开始处理后续的消息
function GameManager:onDispatchEvent( __event )
	if __event.msgid == header.S2C_EnumKeyAction.S2C_TABLE_INFO then
		self.IsDealMsg = true
	end

	if self.IsDealMsg == true then
		self:dispatchMsg(__event.msgid,__event.data)
	else
		print("没收到tableInfo,不处理的消息msgid:",__event.msgid)
	end
	
end


function GameManager:startEventListener(view)
	print("游戏管理器基类初始化监听")
	self._view = view
	self._isGameFinished = false
	self:addEventListener(header.S2C_EnumKeyAction.S2C_APPLY_LEAVE_TABLE,self.EVENT_LEAVE_TABLE, self, self.onUserLeaveTable)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_TABLE_INFO,self.EVENT_TABLE_INFO, self, self.onTableInfo)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_REMOVE_TABLE,self.EVENT_REMOVE_TABLE, self, self.onRemoveTable)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_APPLY_DISSOLUTION,self.EVENT_DISSOLUTION, self, self.onDissolutionTable)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_DISSOLUTION_ACTION,self.EVENT_DISSOLUTION_ACTION, self, self.onDissolutionAction)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_DISSOLUTION_RESULT,self.EVENT_DISSOLUTION_RESULT, self, self.onDissolutionResult)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_NETWORK_ERR,self.EVENT_NETWORK_ERR, self, self.onNetWorkErr)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_IS_ONLINE,self.EVENT_IS_ONLINE, self, self.onNetWorkState)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_HEAT_JUMP,self.EVENT_HEAT_JUMP, self, self.onHeartbeat)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_CHAT_TEXT,self.EVENT_CHAT_TEXT, self, self.onChatText)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_CHAT_BROW,self.EVENT_CHAT_BROW, self, self.onChatBrow)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_CHAT_TALK,self.EVENT_CHAT_TALK, self, self.onChatTalk)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_THROW_PROPERTY,self.EVENT_THROW_PROPERTY, self, self.onProp)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_BANKRUPT,self.EVENT_BANKRUPT, self, self.onBankRupt)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_PLAYER_BANKRUPT_SUCCEED,self.EVENT_PLAYER_BANKRUPT_SUCCEED, self, self.onBankSucc)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_AUTHORIZE_SIT_APPLY,self.EVENT_USER_AUTHORIZE_SIT_APPLY, self, self.onUserAuthorizeSitApply)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_AUTHORIZE_ACTION,self.EVENT_USER_AUTHORIZE_ACTION, self, self.onUserAuthorizeAction)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_AUTHORIZE_RESULT,self.EVENT_USER_AUTHORIZE_RESULT, self, self.onUserAuthorizeResult)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_PAY_RESULT,self.EVENT_PAY_RESULT, self, self.onPayResult)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_PLAYER_CHANGE_TABLE,self.EVENT_CHANGE_TABLE, self, self.onChangeTable)

	self:addEventListener(header.S2C_EnumKeyAction.S2C_APPLY_LOGIN,self.EVENT_USER_LOGIN, self, self.onUserLogin)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_APPLY_JOIN_TABLE,self.EVENT_USER_JOIN_TABLE, self, self.onUserJoinTable)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_REFRESH_USERDATA,self.EVENT_REFRESH_USERDATA, self, self.onRefreshUserData)

	local listeners = {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_SOCKET_DISPATCH_MSG,handler(self,self.onDispatchEvent)),
		lib.EventUtils.createEventCustomListener("APP_ENTER_FOREGROUND_EVENT",handler(self,self.backGroundToGame)),
		lib.EventUtils.createEventCustomListener("APP_SOCKET_RECONNECT_EVENT",handler(self,self.requestLoginServer)),
		lib.EventUtils.createEventCustomListener("APP_ENTER_BACKGROUND_EVENT",handler(self,self.GameToBackGround)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_RECONNECT_SOCKET,handler(self,self.ReconnectGameServer)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_GAME_RESULT_FINISH,handler(self,self.onGameEnd)),
	}
	lib.EventUtils.registeAllListeners(self,listeners)
end

function GameManager:onGameEnd( ... )
	self._isGameFinished = true
end

function GameManager:stopEventListener()
	print("游戏管理器基类移除监听")
	self._view = nil
	self:removeEventListener(self.EVENT_LEAVE_TABLE, self)
	self:removeEventListener(self.EVENT_TABLE_INFO, self)
	self:removeEventListener(self.EVENT_REMOVE_TABLE, self)
	self:removeEventListener(self.EVENT_DISSOLUTION, self)
	self:removeEventListener(self.EVENT_DISSOLUTION_ACTION, self)
	self:removeEventListener(self.EVENT_DISSOLUTION_RESULT, self)
	self:removeEventListener(self.EVENT_NETWORK_ERR, self)
	self:removeEventListener(self.EVENT_IS_ONLINE, self)
	self:removeEventListener(self.EVENT_HEAT_JUMP, self)
	self:removeEventListener(self.EVENT_CHAT_TEXT, self)
	self:removeEventListener(self.EVENT_CHAT_BROW, self)
	self:removeEventListener(self.EVENT_CHAT_TALK, self)
	self:removeEventListener(self.EVENT_THROW_PROPERTY, self)
	self:removeEventListener(self.EVENT_BANKRUPT, self)
	self:removeEventListener(self.EVENT_PLAYER_BANKRUPT_SUCCEED, self)
	self:removeEventListener(self.EVENT_USER_AUTHORIZE_SIT_APPLY, self)
	self:removeEventListener(self.EVENT_USER_AUTHORIZE_ACTION, self)
	self:removeEventListener(self.EVENT_USER_AUTHORIZE_RESULT, self)
	self:removeEventListener(self.EVENT_PAY_RESULT, self)
	self:removeEventListener(self.EVENT_CHANGE_TABLE, self)

	self:removeEventListener(self.EVENT_USER_LOGIN, self)
	self:removeEventListener(self.EVENT_USER_JOIN_TABLE, self)
	self:removeEventListener(self.EVENT_REFRESH_USERDATA, self)

	lib.EventUtils.removeAllListeners(self)
	print("GameManager:initDealMsgState stop Listener")
	self:initDealMsgState()
end

function GameManager:onDestory()
	print("GameManager:onDestory")
	lib.EventUtils.removeAllListeners(self)
	self._gameRequest = nil
end

cc.exports.logic.GameManager = GameManager
--cc.exports.lib.singleInstance:bind(GameManager)

return GameManager
