--[[--
@author fly 服务器环境列表
]]

local environment = {
	ENVIRONMENT_DEV = 1, --开发  http://192.168.1.213:8085
	ENVIRONMENT_INNER_NET = 2, --内网测试地址  http://192.168.1.213:9085、
	ENVIRONMENT_OUTER_NET = 3, --外网测试地址
	ENVIRONMENT_RELEASE_NET = 4, --发布地址
	-- ENVIRONMENT_TEST = 5, --测试地址
}

environment.ENVIRONMENT  = environment.ENVIRONMENT_RELEASE_NET
local ServerConfig = class("ServerConfig")

ServerConfig.config = {
		[environment.ENVIRONMENT_DEV] = {
			resDomain = "http://192.168.1.121:8086/",
			modelDomain  = "http://192.168.1.121:8085",
			loginDomain = "http://192.168.1.121:8084"
		},
		[environment.ENVIRONMENT_INNER_NET] = {
			resDomain = "http://resource.suit.wang/",
			modelDomain  = "http://192.168.1.185:8085",
   			loginDomain = "http://192.168.1.185:8084"
		},
		[environment.ENVIRONMENT_OUTER_NET] = {
			resDomain = "http://test.resource.suit.wang/",
			modelDomain  = "http://test.api.service.suit.wang",
			loginDomain = "http://test.uc.service.suit.wang"
		},
		[environment.ENVIRONMENT_RELEASE_NET] = {
			resDomain = "http://resource.suit.wang/",
			modelDomain  = "https://api.service.suit.wang",
			loginDomain = "https://uc.service.suit.wang"
		}
		-- ,
		-- [environment.ENVIRONMENT_TEST] = {
		-- 	resDomain = "http://resource.suit.wang/",
		-- 	modelDomain  = "https://test3.service.suit.wang",
		-- 	loginDomain = "https://test1.service.suit.wang"
		-- }
}

	--业务处理服务器
function ServerConfig:findModelDomain()
	for i,v in ipairs(self.config) do
		print("findModelDomain ",i,v,environment.ENVIRONMENT)
	end
	return self.config[environment.ENVIRONMENT].modelDomain --内网调试
end

	--业务处理服务器
function ServerConfig:findLoginDomain()
	return self.config[environment.ENVIRONMENT].loginDomain --内网调试
end

	--资源下载服务器
function ServerConfig:findResDomain()
	-- body
	return self.config[environment.ENVIRONMENT].resDomain
end


cc.exports.config.ServerConfig = ServerConfig.create()
