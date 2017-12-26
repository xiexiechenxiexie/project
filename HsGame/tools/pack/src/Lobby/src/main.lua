require "src/conf.lua"
require "src/Lobby/src/Boot.lua"

local function main()

	cc.exports.config.channle = {}
cc.exports.config.channle.CHANNLE_ID = "nn_appstore_01"

	print("config.channle.CHANNLE_ID",config.channle.CHANNLE_ID)
	-- 友盟注册
	MobClickForLua.startMobclick(MobClickForLua.Umeng_AppKey, config.channle.CHANNLE_ID)

	local director = cc.Director:getInstance()
	-- director:setDisplayStats(false)
	director:setNotificationNode(cc.Node:new()) --跨scene节点 常驻内存并且被渲染的节点，所有可能跨scene提示的UI均需要挂在这个节点上面
	initHotUpdateEnv()

	require("src/preload/src/LogoScene"):create():runWithScene()
    --printMonitor("fly")
end

local status, msg = xpcall(main, __G__TRACKBACK__)

if not status then
	-- record the message
	local message = msg

	-- auto genretated
	local msg = debug.traceback(msg, 3)
	print("xiaxb", "msg------" .. msg)

	-- report lua exception
  	buglyReportLuaException(tostring(message), debug.traceback())
	print("xiaxb", " |  message "  .. message .. "message")


	return msg
end
