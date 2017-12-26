--[[--
请求消息基类
]]
local RequestBase = class("RequestBase")
RequestBase._byteArray = nil
function RequestBase:ctor( ... )

end

function RequestBase:write( ... )
    local byteArray =  cc.hsGameUtils.ByteArray:new("ENDIAN_BIG")
    self._byteArray = byteArray
    byteArray:writeUInt(0)  -- 消息的总长度   4个字节
    byteArray:writeUInt(self:findMsgId()) -- 消息的msgid  4个字节
    self:writeContent()
    byteArray:setPos(1)
    byteArray:writeUInt(byteArray:getLen())
end

function RequestBase:writeContent( ... )

end

function RequestBase:findMsgId( ... )
	return 0
end

function RequestBase:getPackageBytes( ... )
	return self._byteArray:getPack()
end
cc.exports.net = cc.exports.net or {}
cc.exports.net.RequestBase = RequestBase