-- 游戏消息请求基类
-- @date 2017.07.20
-- @author tangwen

local RequestModel = require "request/RequestBase"
local header = require "header/headFile"
local GameRequest = class("GameRequest", RequestModel)
local ByteList = require "request/ByteList"

function GameRequest:ctor()
    GameRequest.super.ctor(self)
    self:reset()
end

function GameRequest:RequestLoginServer(host,port)
    print("GameRequest:RequestLoginServer:",host,port)
    local msgid = header.C2S_EnumKeyAction.C2S_APPLY_LOGIN
    local byteList =  ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID)
    byteList:writeString(UserData.token)  
    net.SocketClient:getInstance():CreateSocket(host, port)
    net.SocketClient:getInstance():connectServer(function()
        self:packMsg(msgid,byteList:getByteList())
    end)
end

-- 请求 离开房间
-- Request data : id , tableid
function GameRequest:RequestLeaveTable()
    local msgid = header.C2S_EnumKeyAction.C2S_APPLY_LEAVE_TABLE
    local byteList =  ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID) 
    self:packMsg(msgid,byteList:getByteList())
end

-- 请求 桌子的所有信息
-- Request data : id , tableid
function GameRequest:RequestTabelInfo()
	local msgid = header.C2S_EnumKeyAction.C2S_TABLE_INFO
	local byteList =  ByteList:new()
	byteList:writeUInt(UserData.userId)
	byteList:writeUInt(GameData.TableID) 
	self:packMsg(msgid,byteList:getByteList())
end

-- 请求 销毁桌子
-- Request data : id , tableid
function GameRequest:RequestRemoveTabel()
    local msgid = header.C2S_EnumKeyAction.C2S_REMOVE_TABLE
    local byteList =  ByteList:new()    
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID) 
    self:packMsg(msgid,byteList:getByteList())
end

-- 请求 申请解散桌子
-- Request data : id , tableid
function GameRequest:RequestDissolutionTabel()
    local msgid = header.C2S_EnumKeyAction.C2S_APPLY_DISSOLUTION
    local byteList =  ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID) 
    self:packMsg(msgid,byteList:getByteList())
end

-- 请求 申请解散桌子的行为 同意或者拒绝
-- Request data : id, tableid, action
function GameRequest:RequestDissolutionAction(data)
    local msgid = header.C2S_EnumKeyAction.C2S_DISSOLUTION_ACTION
    local byteList =  ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID)
    byteList:writeUInt(data) 
    self:packMsg(msgid,byteList:getByteList())
end

-- 请求 桌子解散的结果
-- Request data : id , tableid
function GameRequest:RequestDissolutionResult()
    local msgid = header.C2S_EnumKeyAction.C2S_DISSOLUTION_RESULT
    local byteList =  ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID) 
    self:packMsg(msgid,byteList:getByteList())
end

-- 请求 玩家是否在线或者离线
-- Request data : id , tableid
function GameRequest:RequestOnlineState()
    local msgid = header.C2S_EnumKeyAction.C2S_IS_ONLINE
    local byteList =  ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID) 
    self:packMsg(msgid,byteList:getByteList())
end

-- 发送 玩家聊天文本
-- Request data : str , tableid
function GameRequest:RequestChatText(data)
    local msgid = header.C2S_EnumKeyAction.C2S_CHAT_TEXT
    local byteList =  ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID)
    byteList:writeString(data)
    self:packMsg(msgid,byteList:getByteList())
end

-- 发送 玩家聊天表情
-- Request data : id , tableid
function GameRequest:RequestChatBrow(data)
    local msgid = header.C2S_EnumKeyAction.C2S_CHAT_BROW
    local byteList =  ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID)
    byteList:writeUInt(data) 
    self:packMsg(msgid,byteList:getByteList())
end

-- 发送 玩家聊天语音
-- Request data :  , tableid
function GameRequest:RequestChatTalk(data)
    local msgid = header.C2S_EnumKeyAction.C2S_CHAT_TALK
    local byteList =  ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID)
    byteList:writeUInt(data) 
    self:packMsg(msgid,byteList:getByteList())
end

-- 道具
-- Request destUid : 说拿道具砸谁？ , propIndex:道具索引
function GameRequest:RequestProp(destUid,propIndex)
    local msgid = header.C2S_EnumKeyAction.C2S_THROW_PROPERTY
    local byteList =  ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID)
    byteList:writeUInt(destUid)
    byteList:writeUInt(propIndex) 
    self:packMsg(msgid,byteList:getByteList())
end

--换桌
function GameRequest:RequestChangeTable()
    print("GameRequest:RequestChangeTable")
    local msgid = header.C2S_EnumKeyAction.C2S_PLAYER_CHANGE_TABLE
    local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID)
    self:packMsg(msgid,byteList:getByteList())
end

--发送购买成功
function GameRequest:RequestShopSucceed()
    print("GameRequest:RequestShopSucceed")
    local msgid = header.C2S_EnumKeyAction.C2S_PLAYER_GOLD_LIST
    local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID)
    self:packMsg(msgid,byteList:getByteList())
end

--破产补助
function GameRequest:RequestBankRupt()
    print("GameRequest:RequestBankRupt")
    local msgid = header.C2S_EnumKeyAction.C2S_BANKRUPT
    local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    print("破产补助",GameData.TableID)
    byteList:writeUInt(GameData.TableID)
    self:packMsg(msgid,byteList:getByteList())
end

--申请授权入座
function GameRequest:RequestAuthorizeSitApply()
    print("GameRequest:RequestAuthorizeSitApply")
    local msgid = header.C2S_EnumKeyAction.C2S_AUTHORIZE_SIT_APPLY
    local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(GameData.TableID)
    byteList:writeString(UserData.nickName)
    self:packMsg(msgid,byteList:getByteList())
end

--请求处理授权入座结果
function GameRequest:RequestAuthorizeAction(__actionId,__applyUserId,__tableId)
    print("GameRequest:RequestAuthorizeAction>>")
    local msgid = header.C2S_EnumKeyAction.C2S_AUTHORIZE_ACTION
    local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(__tableId)
    print("__tableId",__tableId)
    byteList:writeUInt(__applyUserId)
    print("__applyUserId",__applyUserId)
    byteList:writeUInt(__actionId)
    print("__actionId",__actionId)
    self:packMsg(msgid,byteList:getByteList())
end

return GameRequest