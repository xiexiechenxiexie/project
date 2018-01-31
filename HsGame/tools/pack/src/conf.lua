cc.FileUtils:getInstance():setPopupNotify(false)
local serchPaths = cc.FileUtils:getInstance():getSearchPaths()
 serchPaths[#serchPaths+1] = "src/"
 serchPaths[#serchPaths+1] = "src/game/"
 serchPaths[#serchPaths+1] = "src/Lobby/"
 serchPaths[#serchPaths+1] = "src/Lobby/src/"
 serchPaths[#serchPaths+1] = "src/Lobby/res/"
cc.FileUtils:getInstance():setSearchPaths(serchPaths)

--[[--
向服务器上报消息
]]
function reportMsgToServer( __msg )
	if UserData and UserData.userId then 
		if HttpClient then 
			HttpClient:getInstance():post(config.ServerConfig:findModelDomain() .. config.ApiConfig.REPORT_MSG .. UserData.userId,__msg,function ( ... )
				print("report finish")
			end)
		end
	end
end

--[[--
方便查看日志的接口 print("tag",xxxx)
printMonitor("tag")  这样就会只打印你需要的日志
]]
printMonitor = function ( __flag )
	if __flag and __flag ~= "" then
		local PRINT = print
		print = function ( ... )
			local arg = {...}
			if arg[1] == __flag then
				PRINT(...)
			end
		end
	end
end

--[[--
热更新检测设置 默认全部可以更新 disableUpdatePlatformList 里面是不可以更新的平台
]]
ENABLE_HOT_UPDATE = true
function initHotUpdateEnv( ... )
	local disableUpdatePlatformList = {
		--"windows",
		-- "android",
		-- "ios",
	}
    for _,platform in ipairs(disableUpdatePlatformList) do
    	if device.platform == platform  then 
    		ENABLE_HOT_UPDATE = false
    		break
    	end
    end
    print("initHotUpdateEnv",ENABLE_HOT_UPDATE)
end

AUTO_LOGIN = false

VIRTUAL_MACHINECODE = "111"

print("conf load finish")
