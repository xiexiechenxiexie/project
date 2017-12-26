-- 子游戏消息请求

local RequestModel = require "request/GameRequest"
local header = require "game/niuniu/src/header/headerFile"
local GameRequest = class("GameRequest", RequestModel)
local ByteList = require "Lobby/src/request/ByteList"

function GameRequest:ctor()
    GameRequest.super.ctor(self)
    self:reset()
end
--请求游戏开始
function GameRequest:RequestGameStart(data1,data2)
	local msgid = header.C2S_EnumKeyAction.C2S_PLAYER_ACTION
	local byteList = ByteList:new()
	byteList:writeUInt(data1)
	byteList:writeUInt(data2)
    self:packMsg(msgid,byteList:getByteList())
end
--请求抢庄
function GameRequest:RequestGameGradbanker(data1,data2,data3)
    local msgid = header.C2S_EnumKeyAction.C2S_PLAYER_ACTION
    local byteList = ByteList:new()
    byteList:writeUInt(data1)
    byteList:writeUInt(data2)
    byteList:writeUInt(data3)
    self:packMsg(msgid,byteList:getByteList())
end
--请求下注
function GameRequest:RequestGameBrtting(data1,data2,data3)
    local msgid = header.C2S_EnumKeyAction.C2S_PLAYER_ACTION
    local byteList = ByteList:new()
    byteList:writeUInt(data1)
    byteList:writeUInt(data2)
    byteList:writeUInt(data3)
    self:packMsg(msgid,byteList:getByteList())
end
--请求摊牌
function GameRequest:RequestGameShowCard(data1,data2,data3)
    local msgid = header.C2S_EnumKeyAction.C2S_PLAYER_ACTION
    local byteList = ByteList:new()
    byteList:writeUInt(data1)
    byteList:writeUInt(data2)
    byteList:writeUInt(data3)
    self:packMsg(msgid,byteList:getByteList())
end

--玩家准备
function GameRequest:RequestPlayerReady(data1,data2)
    local msgid = header.C2S_EnumKeyAction.C2S_PLAYER_READY
    local byteList = ByteList:new()
    byteList:writeUInt(data1)
    self:packMsg(msgid,byteList:getByteList())
end

--玩家坐下
function GameRequest:RequestPlayerSit()
    local msgid = header.C2S_EnumKeyAction.C2S_PLAYER_ACTION
    local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(header.C2S_EnumKeyActionGold.C2S_PLAYER_SIT)
    self:packMsg(msgid,byteList:getByteList())
end

--玩家站起
function GameRequest:RequestPlayerStandUp()
    local msgid = header.C2S_EnumKeyAction.C2S_PLAYER_ACTION
    local byteList = ByteList:new()
    byteList:writeUInt(UserData.userId)
    byteList:writeUInt(header.C2S_EnumKeyActionGold.C2S_STAND_UP)
    self:packMsg(msgid,byteList:getByteList())
end

return GameRequest