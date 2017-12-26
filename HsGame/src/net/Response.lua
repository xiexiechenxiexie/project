--[[--
@响应解析
]]

local ResponseBase = class("ResponseBase")
ResponseBase._msgId = 0
ResponseBase._packLen = 0
function ResponseBase:readHead(  )
	self._msgId = self._byteArray:readUInt()
end

function ResponseBase:readContent(  )

end

function ResponseBase:read(__byteArray  )
	self._byteArray = __byteArray
	self:readHead()
	self:readContent()
end

cc.exports.net = cc.exports.net or {}
cc.exports.net.ResponseBase = ResponseBase