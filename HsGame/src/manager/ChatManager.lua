--[[--
聊天模块
]]


local MESSAGE_SCENE_TYPE = {
	WORLD_MESSAGE  = 1, -- 世界聊天
	GAME_MESSAGE   = 2, -- 房间内消息
	FRIEND_MESSAGE = 3, -- 好友聊天消息
	SERVER_MESSAGE = 4, --后台配置消息
	SYSTEM_HORN_MESSAGE = 5  --系统广播
}

local MESSAGE_CONTENT_TYPE = {
	AUDIO = 1,--语音消息
	TEXT = 2,--文本消息
	EMOTION = 3--表情消息
}

local headFile = require "Lobby/src/header/headFile.lua"
local SocketClient = require "Lobby/src/net/SocketClient"

local ChatRequest = class("ChatRequest",net.RequestBase)
ChatRequest.msgType = 0
ChatRequest.fromUserId = 0
ChatRequest.toUserId = 0
ChatRequest.tableId = 0
function ChatRequest:ctor( __params )
	ChatRequest.super.ctor(self,__params)
	if __params.msgType then self.msgType = __params.msgType  end
	if __params.fromUserId  then self.fromUserId = __params.fromUserId  end
	if __params.toUserId then self.toUserId = __params.toUserId end
	if __params.tableId then self.tableId = __params.tableId end
	if __params.contentType then self.contentType = __params.contentType end
	if __params.text then self.text = __params.text end
end

function ChatRequest:writeContent( ... )
	ChatRequest.super.writeContent(self)
	self._byteArray:writeUInt(self.fromUserId)
	self._byteArray:writeUInt(self.tableId) --桌子id
	self._byteArray:writeUInt(self.msgType)
	self._byteArray:writeUInt(self.toUserId)
	self._byteArray:writeUInt(self.contentType)

	self._byteArray:writeUShort(#tostring(123454))
	self._byteArray:writeString(tostring(123454)) --

	self._byteArray:writeUShort(string.len(self.text))
	self._byteArray:writeString(self.text)
end

function ChatRequest:findMsgId( ... )
	return headFile.C2S_EnumKeyAction.C2S_SEND_CHAT
end










local ChatResponse = class("ChatResponse",net.ResponseBase)
ChatResponse.fromUserId = 0
ChatResponse.toUserId = 0
ChatResponse.tableId = 0
ChatResponse.msgType = 0
ChatResponse.contentType = 0
ChatResponse.text = ""
ChatResponse.timestamp = ""
function ChatResponse:ctor( __params)
	ChatResponse.super.ctor(self,__params)
	self.fromUserId = 0
	self.toUserId = 0
	self.tableId = 0
	self.msgType = 0
	self.contentType = 0
	self.text = ""
	self.timestamp = 0
end


function ChatResponse:readContent(  )
	ChatResponse.super.readContent(self)
	self.fromUserId = self._byteArray:readUInt()
	self.tableId = self._byteArray:readUInt()
	self.msgType = self._byteArray:readUInt()--消息类型
	self.toUserId = self._byteArray:readUInt()
	self.contentType = self._byteArray:readUInt()

	local len = self._byteArray:readUShort()
	self.timestamp = self._byteArray:readString(len) --时间戳

	len = self._byteArray:readUShort()
	-- print(len,self.timestamp,self.contentType,self.toUserId,self.msgType,self.tableId,self.fromUserId)
	self.text = self._byteArray:readString(len)
end




local ChatManager = class("ChatManager")
function ChatManager:ctor( ... )
	self:addEventListeners()
	self._funcCache = {
		[MESSAGE_CONTENT_TYPE.TEXT] = handler(self,self.handleChatText),
		[MESSAGE_CONTENT_TYPE.AUDIO] = handler(self,self.handleChatAudio),
		[MESSAGE_CONTENT_TYPE.EMOTION] = handler(self,self.handleChatEmotion)
	}
end

function ChatManager:addEventListeners( ... )
	local listeners = self:_findListeners()
	if  listeners then lib.EventUtils.registeAllListeners(self,listeners) end
end

function ChatManager:_findListeners( ... )
	local params = {
		{eventKey = config.EventConfig.EVENT_SEND_CHAT,callback = handler(self,self.onChatRsp)
		,rspCmdId = headFile.S2C_EnumKeyAction.S2C_SEND_CHAT,clazz = ChatResponse}
	}
	local listeners = {}
	for i,info in ipairs(params) do
		local listener = lib.EventUtils.createEventCustomListener(info.eventKey,info.callback)
		listeners[#listeners + 1] = listener
		SocketClient:getInstance():registeRspClazz(info.rspCmdId,info.clazz,info.eventKey)
	end
	return listeners
end

function ChatManager:sendChat(__params)
	print("sendChat",__params.msg,__params.msgType,__params.toUserId,__params.tableId)
	if __params  then
		local chat = ChatRequest.new( { msgType = __params.msgType,
										text = __params.msg,
										fromUserId = __params.userId,
										toUserId = __params.toUserId,
										tableId =__params.tableId, --485453
										contentType = __params.contentType
										})
		chat:write()
		local pack = chat:getPackageBytes()
		SocketClient:getInstance():sendData(pack)
	end
end
	-- WORLD_MESSAGE  = 1, -- 世界聊天
	-- GAME_MESSAGE   = 2, -- 房间内消息
	-- FRIEND_MESSAGE = 3, -- 好友聊天消息
function ChatManager:onChatRsp( __event )
	print("ChatManager:onChatRsp")
	if not __event then return end
	local chatRsp = __event.packet
	if chatRsp then 
		dump(chatRsp)
		local func = self._funcCache[chatRsp.contentType]
		if func then func(chatRsp)  end
	end
end

function ChatManager:dispatch( __obj )
	if not __obj or __obj.msgType  then 
	end
	local event = nil
	if __obj.msgType == MESSAGE_SCENE_TYPE.GAME_MESSAGE then
		event = cc.EventCustom:new(config.EventConfig.EVENT_SEND_CHAT_GAME_VIEW)
	elseif __obj.msgType == MESSAGE_SCENE_TYPE.WORLD_MESSAGE then 
		event = cc.EventCustom:new(config.EventConfig.EVENT_SEND_CHAT_WORLD_VIEW)
	elseif __obj.msgType == MESSAGE_SCENE_TYPE.FRIEND_MESSAGE then
		event = cc.EventCustom:new(config.EventConfig.EVENT_SEND_CHAT_FRIEND_VIEW)
	end

	if event then 
		event.packet = __obj
		print("转发",event:getEventName(),event.packet.text)
	    lib.EventUtils.dispatch(event)
	end

end

function ChatManager:handleChatText( __chat )
	self:dispatch(__chat)
end

function ChatManager:handleChatAudio(__chat)
	__chat.audioId = tonumber(__chat.text)
	self:dispatch(__chat)
end

function ChatManager:handleChatEmotion(__chat)
	__chat.emotionId = tonumber(__chat.text)
	self:dispatch(__chat)
end

function ChatManager:onDestroy( ... )
	lib.EventUtils.removeAllListeners(self)
end


cc.exports.lib.singleInstance:bind(ChatManager)
cc.exports.manager.ChatManager = ChatManager
cc.exports.CHAT_MESSAGE_SCENE_TYPE = MESSAGE_SCENE_TYPE
cc.exports.CHAT_MESSAGE_CONTENT_TYPE = MESSAGE_CONTENT_TYPE
ChatManager:getInstance()