-- 发送请求初始化
-- @date 2017.10.17
-- @author tangwen

cc.exports.request = cc.exports.request or {}
local list = {
	"request/LobbyRequest.lua",
	"request/GameRequest.lua",
}


cc.exports.request.reset = function ( ... )
	print("request.reset")
	for _,v in ipairs(list) do
		package.loaded[v] = nil
	end

	for _,v in ipairs(list) do
		local model = require (v)
	end
end

request.reset()