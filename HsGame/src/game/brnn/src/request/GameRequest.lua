--向服务器发送消息
local RequestModel = require "request/GameRequest"
local header = require "game/brnn/src/header/headerFile"
local GameRequest = class("GameRequest", RequestModel)
local ByteList = require "request/ByteList"

--动作id
local C2S_PLAYER_ACTION=100020

function GameRequest:ctor()
    GameRequest.super.ctor(self)
    self:reset()
end

--下注
function GameRequest:RequestGameXiaZhu(ChoumaIndex,QuyuIndex)
    printInfo("发送下注")
	local msgid = header.C2S_EnumKeyAction.C2S_GAME_XIAZHU
	local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(msgid)
	byteList:writeUInt(ChoumaIndex)
	byteList:writeUInt(QuyuIndex)
    self:packMsg(C2S_PLAYER_ACTION,byteList:getByteList())
end

--上庄,取消申请,下庄
function GameRequest:RequestGameShangZhuang(_data)--_data  0,表示下庄,1,表示上庄
    printInfo("发送上,下庄")
    local msgid = header.C2S_EnumKeyAction.C2S_GAME_ZHUANG
    local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(msgid)
    byteList:writeUInt(_data)
    self:packMsg(C2S_PLAYER_ACTION,byteList:getByteList())
end

--坐下
function GameRequest:RequestGameSit(sitIndex)
    printInfo("发送坐下")
    local msgid = header.C2S_EnumKeyAction.C2S_GAME_SIT
    local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(msgid)
    byteList:writeUInt(sitIndex)
    self:packMsg(C2S_PLAYER_ACTION,byteList:getByteList())
end

return GameRequest