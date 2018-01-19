--向服务器发送消息
local RequestModel = require "request/GameRequest"
local header = require "game/zjh/src/header/headerFile"
local GameRequest = class("GameRequest", RequestModel)
local ByteList = require "request/ByteList"

function GameRequest:ctor()
    GameRequest.super.ctor(self)
    self:reset()
end

--测试包
function GameRequest:RequestTest()
    local msgid = 100000
    local byteList =  ByteList:new()
    byteList:writeUInt(123465)
    byteList:writeUInt(123456)
    net.SocketClient:getInstance():CreateSocket("192.168.0.104", "8888")
    net.SocketClient:getInstance():connectServer(function()
        self:packMsg(msgid,byteList:getByteList())
    end)
end

return GameRequest