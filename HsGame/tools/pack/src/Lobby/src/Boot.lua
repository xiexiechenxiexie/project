--[[--
@author fly 重新加载lua文件模块 


通过路径来判断是否是cocos之外的(也就是自己编写的项目代码)
游戏之外系统功能全部包含在大厅里面，所以判断大厅热更部分文件 只需要判断引入lua文件key包含路径符号，然后不包含 game/  路径符号即可

判断是游戏部分必须包含路径符号，并且包含游戏模块名字]]

local persiste = {
"HotUpdateManager",
"Boot",
"main",
"src/conf.lua",
"EventUtils.lua",
"LogoScene",
} --不需要重新加載的文件,若修改了和平台修改一样重要  需要整包人更新

_removeLuaFile = function ( __path )
	if __path and package.loaded then 
		local luaClazzObj = package.loaded[__path]
		if type(luaClazzObj) == "boolean" then 
		elseif type(luaClazzObj) == "table" then
			print("fly","luaClazzObj",luaClazzObj)
			if luaClazzObj and luaClazzObj.destory then --所有缓存采取单利方式  但是必须在对应文件 做return 操作
				luaClazzObj.destory()
				luaClazzObj = nil
			end
		end
		print("fly",__path,"removed")
		package.loaded[__path] = nil
	end
end

_reloadLuaFile = function ( __path )
	
	if __path then
		local isPersiste = false
		for _,name in ipairs(persiste) do
			local index = string.find(__path,name,1,true)
			isPersiste =  index and index > 0
			if isPersiste then break end
		end
		if not isPersiste then
			print("fly","_reloadLuaFile",__path)
			local luaCalzzObj = require(__path)
		end
	end
end


--首屏加載
local listBootLuaFiles = {
"src/config/GameConfig.lua",
"src/config/ServerConfig.lua",
"src/config/ApiConfig.lua",
"src/config/ChannelConfig.lua",
"src/config/LobbyConfig.lua",
"src/Lobby/src/external/MultiPlatform.lua",
"src/Lobby/src/net/HttpClient.lua",--必须热更
"src/lib/utils/JsonUtil.lua",
"src/lib/utils/GameUtils.lua",
"src/lib/download/HotUpdateManager.lua",
"src/Lobby/src/external/MobClickForLua.lua",
--这里文件改动牵扯整包更新
}

require "config"
require "socket"
require("lsqlite3")
require("lfs")
require "cocos.init" 

for _,v in ipairs(listBootLuaFiles) do
	require (v)
end

local Boot = {}

function Boot:restart( ... )
	package.loaded = {}
	lib.download.HotUpdateManager:setSearchPath()
	-- cc.Director:getInstance():endToLua()
	require("src/Lobby/src/main.lua")
	
end

function Boot:boot( isNotSetSearchPath )
	if not isNotSetSearchPath then lib.download.HotUpdateManager:setSearchPath() end
	self:reloadCommon()
	print("fly","----------reloadCommon finished")
	self:reloadLobbyOnly()
	print("fly","----------reloadLobbyOnly finished")
	self:reloadGameAll()
	print("fly","----------reloadGameAll finished",cc.exports.config.channle.CHANNLE_ID)
	local initData = require "data/initData"
	initData:init()
end

function Boot:clear( __callback )
	local list = package.loaded 
	for path,luaClazzObj in pairs(list) do
		local luaClazzObj = package.loaded[path]
		if type(luaClazzObj) == "boolean" then 
		elseif type(luaClazzObj) == "table" then
			print("fly","luaClazzObj",luaClazzObj)
			if luaClazzObj and luaClazzObj.destory then --所有缓存采取单利方式  但是必须在对应文件 做return 操作
				luaClazzObj.destory()
				luaClazzObj.instance = nil
				luaClazzObj:getInstance()
			end
		end
	end
	local initData = require "data/initData"
	initData:init()

	if __callback then __callback() end
end



function Boot:reloadCommon( ... )

	local list = {
		"src/Lobby/src/PathManager.lua",
		"src/config/init.lua",
		"src/lib/init.lua",
		"src/manager/init.lua",
		"src/net/init.lua",
		"src/Lobby/src/logic/init.lua",
		"src/Lobby/src/request/init.lua",
		"src/Lobby/src/net/SocketClient.lua",
		"src/Lobby/src/net/HttpClient.lua",
		"src/Lobby/src/external/MultiPlatform.lua",
		"src/config/GameConfig.lua",
		"src/config/ServerConfig.lua",
		"src/config/ApiConfig.lua",
		"src/config/ChannelConfig.lua",
	}

	for _,v in ipairs(listBootLuaFiles) do
	 	_removeLuaFile(v)
	end 
	print("fly","----------listBootLuaFiles removed finish")

	for _,v in ipairs(list) do
	 	_removeLuaFile(v)
	end 

	print("fly","----------list removed finished")

	for _,v in ipairs(list) do
	 	_reloadLuaFile(v)
	end
	print("fly","----------list load finished")

end



function Boot:reloadLobbyOnly( ... )
	local luaModelNames = {}
	for k,v in pairs( package.loaded ) do
		if type(k) == "string"  then
			local indexNotCocos = string.find(k,"/",1,true)
			local index = string.find(k,"game/",1,true)
			local isPersiste = false
			for _,name in ipairs(persiste) do
				local index = string.find(k,name,1,true)
				isPersiste =  index and index > 0
				if isPersiste then break end
			end
			if not isPersiste then
				if indexNotCocos and indexNotCocos > 0   then
					_removeLuaFile(k)
					luaModelNames[#luaModelNames + 1] = k
				end
			end
		end
	end

	for _,key in ipairs(luaModelNames) do
		_reloadLuaFile(key)
	end
end

--[[--
重新加载游戏lua文件
]]
function Boot:reloadGame( __gameModelStr )
	print("Boot:reloadGame")
	local pattern = __gameModelStr .. "/"
	local list = {}
	for k,tb in pairs( package.loaded ) do
		local index = string.find(k,pattern,1,true)
		if index and type(index) == "number" and index > 0  then
			list[#list + 1] = k
			_removeLuaFile(k)
		end
	end
	
	for _,v in ipairs(list) do
		_reloadLuaFile(v)
	end
end


function Boot:reloadGameAll()
	local pattern = "game/"
	local list = {}
	for k,tb in pairs( package.loaded ) do
		local index = string.find(k,pattern,1,true)
		if index and type(index) == "number" and index > 0  then
			list[#list + 1] = k
			_removeLuaFile(k)
		end
	end
	
	for _,v in ipairs(list) do
		_reloadLuaFile(v)
	end
end



cc.exports.Boot = Boot