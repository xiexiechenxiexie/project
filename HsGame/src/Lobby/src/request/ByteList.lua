-- 拼装数据结构 table 
-- @date 2017.07.20
-- @author tangwen

local ByteList = class("ByteList")

function ByteList:ctor()
	self._ByteList = {}
end

function ByteList:getByteList()
    return self._ByteList
end

function ByteList:writeUInt(data)
    local list = {type = "UInt",content = data}
    table.insert(self._ByteList,list)
    return self._ByteList
end

function ByteList:writeString(data)
    local list = {type = "String",content = data}
    table.insert(self._ByteList,list)
    return self._ByteList
end

return ByteList
