-- 大厅数据常量
-- @author Tangwen
-- @date 2017.9.11


local LobbyData = LobbyData or {}

function LobbyData.reset()
   LobbyData.LobbyServerIP = "nilStr"		-- 大厅的网关
   LobbyData.LobbyServerPort = "nilStr"	-- 大厅端口
end

cc.exports.LobbyData = LobbyData