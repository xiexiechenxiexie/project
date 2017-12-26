-- 客户端网络
-- @date 2017.07.11
-- @author tangwen

cc.exports.net = cc.exports.net or {}

local SocketClient = class("SocketClient")
SocketClient._clazzDict = {}
SocketClient._eventDict = {}
local header = require "header/headFile"

local msgHead = {}

-- ͨ通过解析头，获取整个包体的长度
local function getDataLen(data)	
	local byteArray = GameUtils.createByteArray(data)
	local len = byteArray:readUInt()
	return len
end


-- 解析服务器信息
local function unpackMsg(data)
	local byteArray = GameUtils.createByteArray(data)
	local msgHead = {}
	if data then
		msgHead.msgid = byteArray:readUInt()
		msgHead.data = byteArray:getBytes(5,msgHead.datalen)
		return msgHead
	else
		return nil
	end
end

 local _instance = nil 
 function SocketClient:getInstance()
     if not _instance then
         _instance = self
         _instance:init()
     end
     return _instance
 end


function SocketClient:init()
	self._clazzDict = {}
	self._eventDict = {}
	self._closeFlag = ConstantsData.CloseScoketType.EXCEPTION_COLSE
end


function SocketClient:addHeadJumpEvents( ... )
	logic.HeadJumpManager:getInstance():addEvents()
end

function SocketClient:removeHeadJumpEvents( ... )
	logic.HeadJumpManager:getInstance():onDestory()
end

-- 创建socket
function SocketClient:CreateSocket(IP,PORT)
	print("CreateSocket:",IP,PORT)
	if self._socket and self._socket.host == IP and self._socket.port == PORT  and self._socket.isConnected then 
		print("socket连接存在并且连接正常")
	else
		self:closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function ( ... )end)
		self._socket = cc.net.SocketTCP.new(IP, PORT, true)
		--self._socket:setTickTime(1 / 30)
		self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected))
		self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self, self.onClose))
		self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self, self.onClosed))
		self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFailure))
		self._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self, self.onData))

		self._closeFlag = ConstantsData.CloseScoketType.EXCEPTION_COLSE

		self:removeHeadJumpEvents()
		self:addHeadJumpEvents()	
	end

end

-- 分发消息
function SocketClient:dispatchMsg(msg)
	local msgid = msg.msgid
	local data = msg.data
	print("收到消息:msgid:",msgid)

	local event = cc.EventCustom:new(config.EventConfig.EVENT_SOCKET_DISPATCH_MSG)
	event.msgid = msgid
	event.data = data
	lib.EventUtils.dispatch(event)
	
end

function SocketClient:onConnected(event)
	print("SocketClient:onConnected(event)")

	self:stopHeartbeat()
	self:startHeartbeat()

	if self._connectCallback then
		self._connectCallback()
	end
	if self.isReconnect then 
		local event = cc.EventCustom:new("APP_SOCKET_RECONNECT_EVENT")
		lib.EventUtils.dispatch(event)	
		self.isReconnect = false
		GameUtils.stopLoading()
	end

end

function SocketClient:onClose(event)
	print("SocketClient:onClose(event)")

end

function SocketClient:onClosed(event)
	print("SocketClient:onClosed(event)")
	if self._closeFlag == ConstantsData.CloseScoketType.EXCEPTION_COLSE then
    	print("服务器或者系统断开连接")
		self.isReconnect = true
		GameUtils.startLoading("网络异常尝试重新登陆...")
	else
		print("主动断开链接")
    end

	self:stopHeartbeat()
	self:removeHeadJumpEvents()
	if self._CloseCallback then
        self._CloseCallback()
        self._CloseCallback = nil
    end

end

function SocketClient:onConnectFailure(event)
	print("SocketClient:onConnectFailure(event)")

    local function callback(event)
		if "ok" == event then
			net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
				LoginManager:enterLogin()
			end)
		end
	end
	local parm = {type = ConstantsData.ShowMgsBoxType.NORMAL_TYPE, msg = "无法连接服务器，请重新登陆。", btn = {"ok"}, callback = callback}
	GameUtils.showMsgBox(parm)

	self:stopHeartbeat()
	self:removeHeadJumpEvents()
end

-- 处理粘包问题 2017.07.15 tangwen
local head_data = ""		-- 读取数据头的内容
local content_data = ""		-- 读取实际的数据内容
local PACKAGE_HEAD_SIZE = 4 -- 包头是4个字节的uint类型

-- 从socket 接受到数据
function SocketClient:onData(event)
	local data = event.data
	local data_len = #data
	local read_size = 0		-- 已读的数据大小

	while data_len ~= read_size do
		if #head_data <= 3 then	
			if data_len - read_size >= PACKAGE_HEAD_SIZE then     
				local rz = PACKAGE_HEAD_SIZE - #head_data
				head_data = head_data .. string.sub(data, read_size + 1, read_size + rz)
				read_size = read_size + rz
			else  
				local rz = data_len - read_size
				head_data = head_data .. string.sub(data, read_size + 1, read_size + rz)
				read_size = read_size + rz
			end

			if #head_data == PACKAGE_HEAD_SIZE then
				content_data = ""
			end
		else
			-- 计算需要读取数据的大小
			local size = getDataLen(head_data) - 4   -- 总包长减去自身长度4
			if data_len - read_size >= size - #content_data then
				local rz = size - #content_data
				content_data = content_data .. string.sub(data, read_size + 1, read_size + rz)
				read_size = read_size + rz

				if self:parsePacket(content_data)  then
				else
					local msg = unpackMsg(content_data)
					if msg then 
						self:popMsg(msg)
					else
						print("msg is error")
					end
				end--added by fly

				head_data = ""
				content_data = ""
			else
				print("粘包")
				local rz = data_len - read_size
				content_data = content_data .. string.sub(data, read_size + 1, read_size + rz)
				read_size = read_size + rz	
			end
		end
	end
end

-- 弹出一个消息
function SocketClient:popMsg(msg)
	if msg.msgid == header.S2C_EnumKeyAction.S2C_HEAT_JUMP then
		print("收到心跳")
		local event = cc.EventCustom:new(config.EventConfig.EVENT_RECEIVE_HEAD_JUMP)
		lib.EventUtils.dispatch(event)
	else
		self:dispatchMsg(msg)
	end
end

function SocketClient:sendData(data)
	self._socket:send(data)
end

-- 连接服务器
function SocketClient:connectServer(callback)

	self._connectCallback = callback
	if not self._socket.isConnected then
		self._socket:connect()
	else
		if self._connectCallback then
			self._connectCallback()
		end
	end
end

function SocketClient:closeSocket(__flag,callback)
	print("closeSocket")
	self._closeFlag = __flag
	GameUtils.stopLoading()
	self._CloseCallback = callback
	self:stopHeartbeat()
	if self._socket and self._socket.isConnected then --存在连接则直接需要等待彻底关闭socket才能callback
		self._socket:close()
		self._socket:disconnect() 
	else  -- 不存在连接，则直接callback
		self._CloseCallback()
        self._CloseCallback = nil
	end
end


function SocketClient:startHeartbeat()
	print("开始发送心跳包")
	local time = 3
	local event = cc.EventCustom:new(config.EventConfig.EVENT_RECEIVE_HEAD_JUMP)
	lib.EventUtils.dispatch(event)
	self:stopHeartbeat()
	local scheduler = require "cocos.framework.scheduler"
	while nil == self._heartbeatHandler do
		self._heartbeatHandler = scheduler.scheduleGlobal(function(dt)
			print("发送心跳")
			self:sendData(self:getHeartbeatData())
			local event = cc.EventCustom:new(config.EventConfig.EVENT_SEND_HEAD_JUMP)
			lib.EventUtils.dispatch(event)
		end, time)
	end
end

function SocketClient:stopHeartbeat()
	if self._heartbeatHandler then
		local scheduler = require "cocos.framework.scheduler"
		scheduler.unscheduleGlobal(self._heartbeatHandler)
		self._heartbeatHandler = nil
	end
end



function SocketClient:getHeartbeatData()
	local byteArray =  cc.hsGameUtils.ByteArray:new("ENDIAN_BIG")
	byteArray:writeUInt(8)
    byteArray:writeUInt(header.C2S_EnumKeyAction.C2S_HEAT_JUMP)  -- 消息的总长度   4个字节 -- header.S2C_EnumKeyAction.C2S_HEAT_JUMP
    return byteArray:getPack()
end


---------------------------------added by fly------------------------------------------
function SocketClient:parsePacket( __string )
	local byteArray = GameUtils.createByteArray(__string)
	local msgid = byteArray:readUInt()
	local clazz = self._clazzDict[msgid]
	local eventKey = self._eventDict[msgid]
	--print("clazz",clazz,"eventKey",eventKey)
	if clazz and eventKey then
		local obj = clazz.new()
		byteArray:setPos(1)
		obj:read(byteArray)
        local dispatcher = cc.Director:getInstance():getEventDispatcher()
        local event = cc.EventCustom:new(eventKey)
        event.packet = obj
        --print("转发事件",eventKey)
        dispatcher:dispatchEvent(event) 
        return true;
    else
    	--print("msgId",msgid,"not handled") 
    	return false;
	end
end


function SocketClient:registeRspClazz( __msgId,__rspClazz,__eventKey )
	if self._clazzDict  then self._clazzDict[__msgId] = __rspClazz end
	if self._eventDict  then self._eventDict[__msgId] = __eventKey end
end

---------------------------------added by fly ended------------------------------------------
cc.exports.net.SocketClient = SocketClient

return SocketClient