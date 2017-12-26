-- 逻辑层单例管理器初始化
-- @date 2017.09.07
-- @author tangwen

cc.exports.logic = cc.exports.logic or {}
local list = {
	"logic/FriendManager.lua",
	"logic/GameManager.lua",
	"logic/LobbyManager.lua",
	"logic/LobbyRankManager.lua",
	"logic/LobbyTableManager.lua",
	"logic/NovicesRewardManager.lua",
	"logic/PlayerInfoManager.lua",
	"logic/PromoteManager.lua",
	"logic/HeadJumpManager.lua",
	"logic/ShareUrlManager.lua",
}


cc.exports.logic.reset = function ( ... )
	for _,v in ipairs(list) do
		package.loaded[v] = nil
	end

	for _,v in ipairs(list) do
		local model = require (v)
	end
end

logic.reset()