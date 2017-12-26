-- 大厅消息请求
-- @date 2017.07.20
-- @author tangwen

local RequestModel = require "request/RequestBase"
local header = require "header/headFile"
local LobbyRequest = class("LobbyRequest", RequestModel)
local SocketClient = require "Lobby/src/net/SocketClient"
local ByteList = require "request/ByteList"


function LobbyRequest:ctor()
    LobbyRequest.super.ctor(self)
    self:reset()
end

-- 请求登陆服务器  这里暂时发送的 创建房间协议。
function LobbyRequest:RequestLoginServer(host,port)
	print("RequestLoginServer:",host,port)
	GameUtils.startLoadingForever("请求登录中...")
	local msgid = header.C2S_EnumKeyAction.C2S_APPLY_LOGIN
	local byteList =  ByteList:new()
	byteList:writeUInt(UserData.userId)
	if UserData.LastTableID == 0 then 
		byteList:writeUInt(0)
	else
		byteList:writeUInt(GameData.TableID)
	end
	byteList:writeString(UserData.token)  
	print("token:",UserData.token)
    net.SocketClient:getInstance():CreateSocket(host, port)
    net.SocketClient:getInstance():connectServer(function()
        self:packMsg(msgid,byteList:getByteList())
    end)
end

-- 申请创建房间
function LobbyRequest:RequestApplyCreateTable()
	GameUtils.startLoadingForever("申请创建房间...")
	local msgid = header.C2S_EnumKeyAction.C2S_APPLY_CREATE_TABLE
	local byteList =  ByteList:new()
	byteList:writeUInt(UserData.userId)
	byteList:writeUInt(GameData.TableID) 
	self:packMsg(msgid,byteList:getByteList())
end

-- 申请加入私人房间
function LobbyRequest:RequestApplyJoinPrivateTable(TableID)
	print("TableID",TableID)
	GameUtils.startLoadingForever("请求加入私人房...")
	local msgid = header.C2S_EnumKeyAction.C2S_APPLY_JOIN_TABLE
	local byteList =  ByteList:new()
	byteList:writeUInt(UserData.userId)
	byteList:writeUInt(TableID) 
	self:packMsg(msgid,byteList:getByteList())
end

-- 申请加入金币场  统一走快速加入协议
function LobbyRequest:RequestApplyJoinGoldTable()
	GameUtils.startLoadingForever("请求加入房间...")
	local msgid = header.C2S_EnumKeyAction.C2S_QUICK_JOIN
	local byteList =  ByteList:new()
	byteList:writeUInt(UserData.userId)
	self:packMsg(msgid,byteList:getByteList())
end


-- 申请快速加入房间 不需要table
function LobbyRequest:RequestQuickJoinTable()
	GameUtils.startLoadingForever("请求加入房间...")
	local msgid = header.C2S_EnumKeyAction.C2S_QUICK_JOIN
	local byteList =  ByteList:new()
	byteList:writeUInt(UserData.userId)
	self:packMsg(msgid,byteList:getByteList())
end

--申请授权入座列表
function LobbyRequest:RequestAuthorizeSitList()
    print("LobbyRequest:RequestAuthorizeSitList")
    GameUtils.startLoadingForever("正在请求授权入座...")
    local msgid = header.C2S_EnumKeyAction.C2S_AUTHORIZE_SIT_LIST
    local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    self:packMsg(msgid,byteList:getByteList())
end

--请求处理授权入座结果
function LobbyRequest:RequestAuthorizeAction(__actionId,__applyUserId,__tableID)
    print("LobbyRequest:RequestAuthorizeAction")
    GameUtils.startLoadingForever("...")
    local msgid = header.C2S_EnumKeyAction.C2S_AUTHORIZE_ACTION
    local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(__tableID)
    byteList:writeUInt(__applyUserId)
    byteList:writeUInt(__actionId)
    self:packMsg(msgid,byteList:getByteList())
end

cc.exports.request.LobbyRequest = LobbyRequest
return LobbyRequest