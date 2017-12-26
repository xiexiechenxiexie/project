--[[
    名称  :   SDKConfig  跨平台信息配置
    作者  :   Xiaxb   
    描述  :   SDK相关参数配置
    时间  :   2017-7-14
--]]

--第三方平台定义(同java/ios端定义值一致)
local SDKConfig = SDKConfig or {}

-- 平台定义
SDKConfig.Platform = {
	ANDROID    				= 1,	-- ANDROID
	IOS 					= 2,	-- IOS
	OTHENR 					= 3, 	-- OTHENR
}

-- Token登陆地址	
SDKConfig.TokenLoginURL = config.ServerConfig:findLoginDomain() .. config.LoginApiConfig.REQUEST_LOGIN_TOKEN

-- 获取游客登陆地址
function SDKConfig.getTokenLoginURL()
	local loginURL = ""

	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		-- loginURL = SDKConfig.TokenLoginURL .. "ios/"
		loginURL = SDKConfig.TokenLoginURL
	elseif  (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		-- loginURL = SDKConfig.TokenLoginURL .. "android/"
		loginURL = SDKConfig.TokenLoginURL
	else
		-- print("xiaxb--------------unknow targetPlatform")
		loginURL = SDKConfig.TokenLoginURL
	end
	return loginURL
end

-- 游客登陆地址
SDKConfig.GuestLoginURL = config.ServerConfig:findLoginDomain() .. config.LoginApiConfig.REQUEST_LOGIN_GUEST

-- 获取游客登陆地址
function SDKConfig.getGuestLoginURL()
	local loginURL = ""
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		loginURL = SDKConfig.GuestLoginURL .. "ios/"
	elseif  (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		loginURL = SDKConfig.GuestLoginURL .. "android/"
	else
		-- print("xiaxb--------------unknow targetPlatform")
		loginURL = SDKConfig.GuestLoginURL .. "android"
	end
	return loginURL
end

--微信SDK配置定义
SDKConfig.WeChat = 
{
	AppID								= "wx78ffd4f397e1aa94", --@wechat_appid_wx  wx78ffd4f397e1aa94
	AppSecret 							= "", --@wechat_secret_wx
	PartnerID 							= "", -- 商户id     --@wechat_partnerid_wx			        
	PayKey								= "", -- 支付密钥	 --@wechat_paykey_wx
	URL 								= "http://suit.wang",
}

-- 微信登陆地址
SDKConfig.WeChatLoginURL = config.ServerConfig:findLoginDomain() .. config.LoginApiConfig.REQUEST_LOGIN_WECHAT

-- 获取微信登陆地址
function SDKConfig.getWeChatLoginURL()
	local loginURL = ""

	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		loginURL = SDKConfig.WeChatLoginURL .. "ios/"
	elseif  (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		loginURL = SDKConfig.WeChatLoginURL .. "android/"
	else
		-- print("xiaxb--------------unknow targetPlatform")
	end
	return loginURL
end

--QQSDK配置定义
SDKConfig.QQ = 
{
    AppID                               = "101402535", --@wechat_appid_wx  wx78ffd4f397e1aa94
    AppKey                              = "", --@wechat_secret_wx
    PartnerID                           = "", -- 商户id     --@wechat_partnerid_wx                   
    PayKey                              = "", -- 支付密钥   --@wechat_paykey_wx
    URL                                 = "http://suit.wang",   ---l.HTTP_URL,
}

-- 微信登陆地址
SDKConfig.QQLoginURL = config.ServerConfig:findLoginDomain() .. config.LoginApiConfig.REQUEST_LOGIN_QQ

-- 获取微信登陆地址
function SDKConfig.getQQLoginURL()
	local loginURL = ""

	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		loginURL = SDKConfig.QQLoginURL .. "ios/"
	elseif  (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		loginURL = SDKConfig.QQLoginURL .. "android/"
	else
		-- print("xiaxb--------------unknow targetPlatform")
	end
	return loginURL
end

cc.exports.config.SDKConfig = SDKConfig
