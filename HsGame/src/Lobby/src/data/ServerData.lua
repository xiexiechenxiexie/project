-- 服务器数据常量
-- @author Tangwen
-- @date 2017.9.25


local ServerData = ServerData or {}

function ServerData.reset()
   ServerData.ServerIP = "nilStr"		-- 连接的网关
   ServerData.ServerPort = "nilStr"	-- 连接的端口
end

cc.exports.ServerData = ServerData