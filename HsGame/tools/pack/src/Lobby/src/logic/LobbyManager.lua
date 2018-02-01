-- 大厅消息和逻辑基类 TCP相关
-- @date 2017.07.18
-- @author tangwen

local ManagerModel = require "logic/ManagerBase"
local header = require "header/headFile"
local LobbyManager = class("LobbyManager", ManagerModel)
local SocketClient = require "Lobby/src/net/SocketClient"


LobbyManager.EVENT_USER_LOGIN = "EVENT_USER_LOGIN" 				-- 登陆
LobbyManager.EVENT_USER_CREATE_TABLE = "EVENT_USER_CREATE_TABLE" -- 创建房间
LobbyManager.EVENT_USER_JOIN_TABLE = "EVENT_USER_JOIN_TABLE" 	-- 加入房间
LobbyManager.EVENT_USER_QUICK_JOIN_TABLE = "EVENT_USER_QUICK_JOIN_TABLE" 	-- 加入房间
LobbyManager.EVENT_USER_AUTHORIZE_SIT_APPLY = "EVENT_USER_AUTHORIZE_SIT_APPLY" 	-- 房主收到授权入座申请
LobbyManager.EVENT_USER_AUTHORIZE_ACTION = "EVENT_USER_AUTHORIZE_ACTION" 	-- 玩家收到授权入座的结果（同意，拒绝）
LobbyManager.EVENT_USER_AUTHORIZE_SIT_LIST = "EVENT_USER_AUTHORIZE_SIT_LIST" 	-- 玩家申请入座列表
LobbyManager.EVENT_USER_AUTHORIZE_RESULT = "EVENT_USER_AUTHORIZE_RESULT" 	-- 授权入座的结果（同意，拒绝）
LobbyManager.EVENT_REFRESH_USERDATA = "EVENT_REFRESH_USERDATA" 	-- 更新玩家信息

-- 初始化界面
function LobbyManager:ctor()
    LobbyManager.super.ctor(self)
    self:reset()
    self._view = nil 
    print("LobbyManager  :initDealMsgState ctor")
    self:initDealMsgState()
end

function LobbyManager:initDealMsgState()
	self.IsDealMsg = true  -- 是否开始处理信息，发送加入房间消息的时候，设置false，在接受到加入房间之后 true 开始处理消息
	self.CloseScoketNoMal = true --是否是正常关闭close
end

-- 玩家登陆
function LobbyManager:onUserLogin(event,data)
	print("LobbyManager:onUserLogin")
	if GameData.IntoGameType == ConstantsData.IntoGameType.PRIVATE_CREATE_TABLE_TYPE then
		GameUtils.stopLoading() 
	end

	local byteArray = GameUtils.createByteArray(data)
	local loginState = byteArray:readUInt() -- 登陆状态 1 为登陆成功 0为登陆失败 返回错误码
	local code = byteArray:readUInt()
	print("loginState:",loginState,code)
	if loginState  == 1 then
		self.CloseScoketNoMal = true 
		local event = cc.EventCustom:new(config.EventConfig.initReConnectState)
		lib.EventUtils.dispatch(event)
		print("登陆成功 :loginState,code,LastTableID,IntoGameType:",loginState,code,UserData.LastTableID,GameData.IntoGameType)
		if UserData.LastTableID == 0 then -- 登陆获取到的桌子 ID ，通常为0 ，断线重连时有数据
			print("UserData.LoginServerType:",UserData.LoginServerType)
			if UserData.LoginServerType == ConstantsData.ServerType.GAME_SERVER_TYPE then --进入游戏服
				print("连接游戏服务器成功")
				local intoType = GameData.IntoGameType
				if intoType == ConstantsData.IntoGameType.PRIVATE_CREATE_TABLE_TYPE then  --0 创建房间 
					GameData.GameType = config.GameType.SRF
					request.LobbyRequest:RequestApplyCreateTable()
				elseif intoType == ConstantsData.IntoGameType.PRIVATE_JOIN_TABLE_TYPE then  --1 私人房加入房间
					GameData.GameType = config.GameType.SRF
					request.LobbyRequest:RequestApplyJoinPrivateTable(GameData.TableID)
					self.IsDealMsg = false
				elseif intoType == ConstantsData.IntoGameType.LOBBY_QUICK_JOIN_TYPE then -- 2 大厅快速加入房间
					GameData.GameType = config.GameType.COIN
					request.LobbyRequest:RequestQuickJoinTable()
					self.IsDealMsg = false
				elseif intoType == ConstantsData.IntoGameType.GOLD_LIST_JOIN_TYPE then -- 3 金币场列表加入
					GameData.GameType = config.GameType.COIN
					request.LobbyRequest:RequestApplyJoinGoldTable()
					self.IsDealMsg = false
				elseif intoType == ConstantsData.IntoGameType.GOLD_QUICK_JOIN_TYPE then -- 4 金币场快速加入
					GameData.GameType = config.GameType.COIN
					request.LobbyRequest:RequestQuickJoinTable()
					self.IsDealMsg = false
				else
					print("进入房间类型错误")	
				end
			elseif UserData.LoginServerType == ConstantsData.ServerType.LOBBY_SERVER_TYPE then  --进入大厅服
				print("连接大厅服务器成功")
				GameUtils.stopLoading()
			else
				print("连接服务器类型错误")	
			end
			print("登陆完成")

		else
			print("断线重连:",UserData.LastGameIP,UserData.LastGamePort) -- 这里走断线重连操作 等待服务器推送消息即可 
			UserData.LastTableID = 0
			UserData.LastGameID = 0
			UserData.LastGameIP = ""
			UserData.LastGamePort = ""
			UserData.LastGameRoomType = -1
		end
		
	else
		print("登陆失败 :loginState,code:",loginState,code)
		local msgStr = ""
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
		elseif code == ConstantsData.ApplyLoginCode.ERR_APPLY_LOGIN_NO_PASSWORD then
			print("错误原因:密码错误")
		elseif code == ConstantsData.ApplyLoginCode.ERR_APPLY_LOGIN_NO_LOCKING then
			print("错误原因:锁定")
		elseif code == ConstantsData.ApplyLoginCode.ERR_APPLY_LOGIN_NO_UNKNOWN then
			print("错误原因:未知 一般为token错误")
		end

		if code ~= ConstantsData.ApplyLoginCode.ERR_APPLY_LOGIN_INLIN then
			LoginManager:enterLogin()
			GameUtils.showMsg("连接服务器失败，请重新连接")
		end

		-- if UserData.LoginServerType == ConstantsData.ServerType.LOBBY_SERVER_TYPE then
		-- 	local function callback(event)
		-- 		if "ok" == event then
		-- 			net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
		-- 				LoginManager:enterLogin()
		-- 			end)
		-- 		end
		-- 	end
		-- 	if code ~= ConstantsData.ApplyLoginCode.ERR_APPLY_LOGIN_INLIN then 
		-- 		local parm = {type = ConstantsData.ShowMgsBoxType.NORMAL_TYPE, msg = "账号连接异常，请重新登录游戏！", btn = {"ok"}, callback = callback}
		-- 		GameUtils.showMsgBox(parm)
		-- 	end
		-- elseif UserData.LoginServerType == ConstantsData.ServerType.GAME_SERVER_TYPE then
		-- 	if code ~= ConstantsData.ApplyLoginCode.ERR_APPLY_LOGIN_INLIN then
		-- 		net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.ABNORMAL_ACCOUNT_CLOSE,function()
		-- 			self:LoginLobbyServer()
		-- 		end)
		-- 	end
		-- end
	end

end

-- 创建房间
function LobbyManager:onUserCreateTable(event,data)
	GameUtils.stopLoading()
	print("LobbyManager:onUserCreateTable")
	local byteArray = GameUtils.createByteArray(data)
	local tableState = byteArray:readUInt() -- 状态 1 为创建成功 0为创建失败 返回错误码
	local code = byteArray:readUInt()
	net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
	  	if tableState  == 1 then 
			print("创建房间成功 :tableState,code:",tableState,code)
			manager.UserManager:getInstance():refreshUserInfo()
			local event = cc.EventCustom:new(config.EventConfig.EVENT_CREATE_ROOM_SHOW)
	   		event._usedata = {tableId = GameData.TableID}
			lib.EventUtils.dispatch(event)
		else
			print("创建房间失败 :tableState,code:",tableState,code)
			GameUtils.showMsg("创建房间失败")
		end
		self:LoginLobbyServer() -- 创建房间成 则重新连接大厅服务器

	end)

end

-- 加入房间
function LobbyManager:onUserJoinTable(event,data)
	
	print("LobbyManager:onUserJoinTable")
	local byteArray = GameUtils.createByteArray(data)
	local joinState = byteArray:readUInt() -- 加入房间状态 1 为成功 0为失败 返回错误码
	local code = byteArray:readUInt()
	if joinState  == 1 then 
		print("加入房间成功 :joinState,code:",joinState,code)
		if self._view then
			self._view:onEnterGame()
		end	
	else
		GameUtils.stopLoading()
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

function LobbyManager:onUserQuickJoinTable(event,data)
	---GameUtils.stopLoading()
	print("LobbyManager:onUserQuickJoinTable")
	local byteArray = GameUtils.createByteArray(data)
	local joinState = byteArray:readUInt() -- 加入房间状态 1 为成功 0为失败 返回错误码
	local code = byteArray:readUInt()
	if joinState  == 1 then 
		print("快速加入房间成功 :joinState,code:",joinState,code)
		local tableID = byteArray:readUInt()
		GameData.TableID = tableID
		if self._view then
			self._view:onEnterGame()
		end
	else
		GameUtils.stopLoading()
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
			GameUtils.showMsg("加入房间失败")
		end									
	end
end

-- 房主收到授权入座申请回调 显示小红点
function LobbyManager:onUserAuthorizeSitApply(event,data)
	GameUtils.stopLoading()
	print("LobbyManager:onUserAuthorizeSitApply")
	if self._view then
		self._view:showRedPointByIndex(ConstantsData.LobbyRedPointType.REDPOINT_MAIL)
	end
end

-- 玩家申请入座列表回调 处理邮件专用
function LobbyManager:onUserAuthorizeSitList(event,data)
	GameUtils.stopLoading()
	print("LobbyManager:onUserAuthorizeSitList")
	local byteArray = GameUtils.createByteArray(data)
	local listNum = byteArray:readUInt()
	print("收到授权入座消息条数:",listNum)
	local listDataList = {}
	if listNum ~= 0 then
		for i=1,listNum do
			local applyUserID = byteArray:readUInt()
		    local tableID = byteArray:readUInt()
		    local gameID = byteArray:readUInt()
		    local nickNameStrLen = byteArray:readShort()
		    local nickName = byteArray:readStringBytes(nickNameStrLen)
		    local __params = {applyUserID = applyUserID, tableID = tableID, gameID = gameID, nickName = nickName}
		    table.insert(listDataList,__params)
		end
	end
	if self._view then
		self._view:showMailViewByData(listDataList)
	end
	
end

-- 房主收到授权入座的行为码回调 移除当前邮件
function LobbyManager:onUserAuthorizeAction(event,data)
	GameUtils.stopLoading()
	print("LobbyManager:onUserAuthorizeAction")
	local byteArray = GameUtils.createByteArray(data)
	local ActionState = byteArray:readUInt() -- 处理状态 1是处理成功 0是处理失败
	if ActionState == 1 then
		local actionID = byteArray:readUInt()
		local applyUserID = byteArray:readUInt()
		local tableID = byteArray:readUInt()
		local gameID = byteArray:readUInt()
		local __params = {applyUserID = applyUserID, tableID = tableID, gameID = gameID, actionID = actionID}
		if self._view then
			self._view:updataMailNode(__params)
		end
	else
		print("处理授权入座失败")
	end
    
end

-- 授权入座结果
function LobbyManager:onUserAuthorizeResult(event,data)
	GameUtils.stopLoading()
	print("LobbyManager:onUserAuthorizeResult")
	local byteArray = GameUtils.createByteArray(data)
	local ResultState = byteArray:readUInt() -- 处理状态 1是处理成功 0是处理失败 通知客户端可以按钮
	print("ResultState:",ResultState)
end

-- 刷新玩家数据
function LobbyManager:onRefreshUserData(event,data)
	GameUtils.stopLoading()
	print("LobbyManager:onRefreshUserData")
	manager.UserManager:getInstance():refreshUserInfo()
end


-- 登陆大厅服务器
function LobbyManager:LoginLobbyServer( )
	net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
		print("开始连接大厅服务器中...")
    	UserData.LoginServerType = ConstantsData.ServerType.LOBBY_SERVER_TYPE
		if  LobbyData.LobbyServerIP and LobbyData.LobbyServerPort then
			-- LobbyData.LobbyServerPort = "8886"
			-- LobbyData.LobbyServerIP = "192.168.1.84"
			ServerData.ServerIP = LobbyData.LobbyServerIP
			ServerData.ServerPort = LobbyData.LobbyServerPort
			request.LobbyRequest:RequestLoginServer(ServerData.ServerIP,ServerData.ServerPort)
		else
			-- printError("gameIp gamePort invalid")
		end
    end)

end

-- 登陆游戏服务器
function LobbyManager:LoginGameServer( )
	net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
		print("开始连接游戏服务器中...",GameData.GamePort,GameData.GameIP)
		UserData.LoginServerType = ConstantsData.ServerType.GAME_SERVER_TYPE
		if UserData.LastTableID == 0 then -- 断线重连不走这里，因为这里直接跳转了游戏，场景获取不到
			GameUtils.startLoading("登陆服务器中，请稍等...")
		end
		if  GameData.GamePort and GameData.GameIP then
			-- GameData.GamePort = "8886"
			-- GameData.GameIP = "192.168.1.84"
			ServerData.ServerIP = GameData.GameIP
			ServerData.ServerPort = GameData.GamePort
			request.LobbyRequest:RequestLoginServer(ServerData.ServerIP,ServerData.ServerPort)
		else
			-- printError("gameIp gamePort invalid")
		end
    end)
end


-- 请求公告开关
function LobbyManager:requestNoticeSetData(__callback)
	self._requestNoticeSetCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_NOTICE_SET
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onNoticeSetCallback))
end

function LobbyManager:_onNoticeSetCallback( __error,__response )
    if __error then
        print("requestNoticeSetData net error")
    else
        if 200 == __response.status then
            local data = __response.data
            self._requestNoticeSetCallBack(data)
        end
    end
end

-- 请求公告信息
function LobbyManager:requestNoticeInfoData(__callback)
    self._requestNoticeInfoCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_NOTICE
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onNoticeInfoCallback))
end

function LobbyManager:_onNoticeInfoCallback( __error,__response )
    if __error then
        print("requestNoticeInfoData net error")
    else
        if 200 == __response.status then
            local data = __response.data
            self._requestNoticeInfoCallBack(data)
        else
            GameUtils.showMsg("请求公告信息数据出错,code = "..__response.status)
        end
    end
end

-- 请求今天是否显示签到信息  签到开关
function LobbyManager:requestSignSetData(__callback)
	print("requestSignSetData")
	self._requestSignSetCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_SIGN_SET .."?token".. UserData.token
    print("签到开关url",url)
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onSignSetCallback))
end


function LobbyManager:_onSignSetCallback( __error,__response )
	print("签到开关")
	dump(__response)
    if __error then
        print("requestSignSetData net error")
    else
        if 200 == __response.status then
            local data = __response.data
            self._requestSignSetCallBack(data)
        else
            GameUtils.showMsg("请求签到设置信息数据出错,code = "..__response.status)
        end
    end
end

-- 请求签到具体信息
function LobbyManager:requestSignInfoData(__callback)
	print("requestSignInfoData")
	self._requestSignInfoCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_SIGN_INFO .. UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onSignInfoCallback))
end

function LobbyManager:_onSignInfoCallback( __error,__response )
    if __error then
        print("requestSignInfoData net error")
    else
        if 200 == __response.status then
            local data = __response.data
            self._requestSignInfoCallBack(data)
        else
            GameUtils.showMsg("请求签到信息数据出错,code = "..__response.status)
        end
    end
end

-- 请求签到
function LobbyManager:requestSignCheckIn(__callback)
	print("requestSignCheckIn")
	self._requestSignCheckInCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_SIGN_CHECK_IN .. UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onSignCheckInCallback))
end

function LobbyManager:_onSignCheckInCallback( __error,__response )
    if __error then
        print("requestSignCheckIn net error")
    else
        if 200 == __response.status then
        	UserData.coins = __response.data.user.Score
            UserData.roomCards = __response.data.user.RoomCardNum
            UserData.diamond = __response.data.user.diamond
            self._requestSignCheckInCallBack(__response)
        end
    end
end

-- 请求任务具体信息
function LobbyManager:requestTaskInfoData(__callback)
	print("requestTaskInfoData")
	self._requestTaskInfoCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_TASK_INFO .."?token="..UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onTaskInfoCallback))
end

function LobbyManager:_onTaskInfoCallback( __error,__response )
	print("回答了")
	dump(__response)
    if __error then
        print("requestTaskInfoData net error")
    else
        if 200 == __response.status then
            local data = __response.data
            self._requestTaskInfoCallBack(data)
        else
            GameUtils.showMsg("请求任务信息数据出错,code = "..__response.status)
        end
    end
end

-- 请求领取任务奖励
function LobbyManager:requestTaskGetAwardData(__index,__callback)
	print("requestTaskGetAwardData")
	self._requestTaskGetAwardCallBack = __callback
    local config = cc.exports.config
    local param = {}
    param.token = UserData.token
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_TASK_GET_AWARD .. __index
    cc.exports.HttpClient:getInstance():post(url,param,handler(self,self._onTaskGetAwardCallback))
end

function LobbyManager:_onTaskGetAwardCallback( __error,__response )
    if __error then
        print("requestTaskGetAwardData net error")
    else
        if 200 == __response.status then
            local data = __response.data
            UserData.coins = __response.data.bonusScore
            UserData.roomCards = __response.data.bonusRoomCard
            UserData.diamond = __response.data.bonusDiamond
            self._requestTaskGetAwardCallBack(data)
        elseif 504 == __response.status then 
        	GameUtils.showMsg("已经领取")
        else	
            GameUtils.showMsg("请求任务信息数据出错,code = "..__response.status)
        end
    end
end

-- 请求客服数据
function LobbyManager:requestServiceData( __callback )
	print("requestServiceData")
	self._requestServiceCallBack = __callback
    local url = config.ServerConfig:findModelDomain() .. config.MallApiConfig.REQUEST_MALL_SERVER_INFO
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onServiceCallback))
end

function LobbyManager:_onServiceCallback( __error,__response )
    if __error then
        print("requestServiceData net error")
    else
        if 200 == __response.status then
            local data = __response.data
            self._requestServiceCallBack(data)
        elseif 503 == __response.status then
        	GameUtils.showMsg("没有客服数据信息")
        else
            GameUtils.showMsg("请求客服数据出错,code = "..__response.status)
        end
    end
end

-- 请求大厅IP地址
function LobbyManager:requestLobbyServerInfoData(__callback)
	print("requestLobbyServerInfoData")
	self._requestLobbyServerInfoCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_LOBBY_SERVER_INFO
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onLobbyServerInfoCallback))
end

function LobbyManager:_onLobbyServerInfoCallback( __error,__response )
    if __error then
        print("requestLobbyServerInfoData net error")
    else
        if __response and 200 == __response.status then
            local data = __response.data
            LobbyData.LobbyServerIP = __response.data.serverIp
            LobbyData.LobbyServerPort = __response.data.serverPort
            self._requestLobbyServerInfoCallBack(data)
            
        else
            GameUtils.showMsg("请求大厅服务器配置信息失败,code = "..tostring(__response))
        end
    end
end

function LobbyManager:onShowLoginTip( __event )
	if self._view then
		self._view:onShowLoginTip()
	end
end

-- 游戏切后台
function LobbyManager:GameToBackGround( __event )
	net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
		print("LobbyManager：游戏切后台")
	end)
end

-- 后台切回游戏 直接走重连逻辑
function LobbyManager:backGroundToLobby( __event )
	print("LobbyManager:后台切回游戏")
	if self.CloseScoketNoMal then
		self:ReconnectLobbyServer()
	end
end

function LobbyManager:ReconnectLobbyServer( ... )
	GameUtils.stopLoading()
	net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
		GameUtils.startLoading("重连服务器中，请稍等...")
		request.LobbyRequest:RequestLoginServer(ServerData.ServerIP,ServerData.ServerPort)
    end)	
end

function LobbyManager:onDispatchEvent( __event )
	if __event.msgid == header.S2C_EnumKeyAction.S2C_APPLY_JOIN_TABLE or __event.msgid == header.S2C_EnumKeyAction.S2C_QUICK_JOIN then
		self.IsDealMsg = true
	end

	print("LobbyManager:onDispatchEvent 接受消息状态:",self.IsDealMsg)
	if self.IsDealMsg == true then
		self:dispatchMsg(__event.msgid,__event.data)
	else
		print("没收到加入房间信息,不处理的消息msgid:",__event.msgid)
	end
	
end


function LobbyManager:startEventListener(view)
	print("LobbyManager:startEventListener")
	self._view  = view
	self:addEventListener(header.S2C_EnumKeyAction.S2C_APPLY_LOGIN,self.EVENT_USER_LOGIN, self, self.onUserLogin)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_APPLY_CREATE_TABLE,self.EVENT_USER_CREATE_TABLE, self, self.onUserCreateTable)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_APPLY_JOIN_TABLE,self.EVENT_USER_JOIN_TABLE, self, self.onUserJoinTable)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_QUICK_JOIN,self.EVENT_USER_QUICK_JOIN_TABLE, self, self.onUserQuickJoinTable)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_AUTHORIZE_SIT_APPLY,self.EVENT_USER_AUTHORIZE_SIT_APPLY, self, self.onUserAuthorizeSitApply)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_AUTHORIZE_ACTION,self.EVENT_USER_AUTHORIZE_ACTION, self, self.onUserAuthorizeAction)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_AUTHORIZE_SIT_LIST,self.EVENT_USER_AUTHORIZE_SIT_LIST, self, self.onUserAuthorizeSitList)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_AUTHORIZE_RESULT,self.EVENT_USER_AUTHORIZE_RESULT, self, self.onUserAuthorizeResult)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_REFRESH_USERDATA,self.EVENT_REFRESH_USERDATA, self, self.onRefreshUserData)

	local listeners = {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_SOCKET_DISPATCH_MSG,handler(self,self.onDispatchEvent)),
		lib.EventUtils.createEventCustomListener("APP_ENTER_FOREGROUND_EVENT",handler(self,self.backGroundToLobby)),
		lib.EventUtils.createEventCustomListener("APP_ENTER_BACKGROUND_EVENT",handler(self,self.GameToBackGround)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_RECONNECT_SOCKET,handler(self,self.ReconnectLobbyServer)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_LOGIN_TIP_SHOW,handler(self,self.onShowLoginTip)),
	}
	lib.EventUtils.registeAllListeners(self,listeners)
	print(self)
end

function LobbyManager:stopEventListener()
	print("LobbyManager:stopEventListener")
	self._view  = nil
	self:removeEventListener(self.EVENT_USER_LOGIN, self)
	self:removeEventListener(self.EVENT_USER_CREATE_TABLE, self)
	self:removeEventListener(self.EVENT_USER_JOIN_TABLE, self)
	self:removeEventListener(self.EVENT_USER_QUICK_JOIN_TABLE, self)
	self:removeEventListener(self.EVENT_USER_AUTHORIZE_SIT_APPLY, self)
	self:removeEventListener(self.EVENT_USER_AUTHORIZE_ACTION, self)
	self:removeEventListener(self.EVENT_USER_AUTHORIZE_SIT_LIST, self)
	self:removeEventListener(self.EVENT_USER_AUTHORIZE_RESULT, self)
	self:removeEventListener(self.EVENT_REFRESH_USERDATA, self)

	lib.EventUtils.removeAllListeners(self)

end

function LobbyManager:onDestory()
	print("LobbyManager:onDestory")
	self:stopEventListener()
end

lib.singleInstance:bind(LobbyManager)
cc.exports.logic.LobbyManager = LobbyManager
return LobbyManager
