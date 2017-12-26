-- 发送消息基类
-- @date 2017.07.20
-- @author tangwen

local RequestBase = class("RequestBase")

function RequestBase:ctor()
    self.name = "RequestBase"
end

function RequestBase:reset()
	
end

-- 网络客户端打包处理
-- data 格式
-- data = {{type = "Uint",content = 1},{type = "String",content = "test"}}
function RequestBase:packMsg(msgid,data)
    print("RequestBase:packMsg ")
	local Len = self:getByteArrayLen(data)
	print("发包:msgid,len:",msgid,Len)
    local byteArray =  cc.hsGameUtils.ByteArray:new("ENDIAN_BIG")
    byteArray:writeUInt(Len)  -- 消息的总长度   4个字节
    byteArray:writeUInt(msgid) -- 消息的msgid  4个字节

    for k,v in pairs(data) do   
        if v.type == "UInt" then
            byteArray:writeUInt(v.content)
            print("writeUInt:",v.content)
        elseif v.type == "String" then 
            print("writeString:",v.content)
            byteArray:writeShort(#v.content)     -- 包体data的长度 2个字节
            byteArray:writeString(v.content)
        end
    end
    local msg = byteArray:getPack()
    net.SocketClient:getInstance():sendData(msg)
end

-- 根据传入包体 一个table表 判断有多大
function RequestBase:getByteArrayLen(data)
    local len = 0
    for k,v in pairs(data) do
        if v.type == "UInt" then
            len = len + 4
        elseif v.type == "String" then
            len = len + #v.content + 2  -- 这个2是字符串的长度
        end
    end
    return len + 8   -- 8 表示 包头，msgid 4，4）
end

return RequestBase
