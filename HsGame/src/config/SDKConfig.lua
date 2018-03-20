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
	return SDKConfig.TokenLoginURL
end

-- 游客登陆地址
SDKConfig.GuestLoginURL = config.ServerConfig:findLoginDomain() .. config.LoginApiConfig.REQUEST_LOGIN_GUEST

-- 获取游客登陆地址
function SDKConfig.getGuestLoginURL()
	return SDKConfig.GuestLoginURL
end

--微信SDK配置定义
SDKConfig.WeChat = 
{
	AppID								= "wxf7049b6098b9fd03", --@wechat_appid_wx  wx78ffd4f397e1aa94
	AppSecret 							= "47ecd01ba135853a4fa3c626f4b3727a", --@wechat_secret_wx
	PartnerID 							= "", -- 商户id     --@wechat_partnerid_wx			        
	PayKey								= "", -- 支付密钥	 --@wechat_paykey_wx
	URL 								= "",
}

-- 微信登陆地址
SDKConfig.WeChatLoginURL = config.ServerConfig:findLoginDomain() .. config.LoginApiConfig.REQUEST_LOGIN_WECHAT

-- 获取微信登陆地址
function SDKConfig.getWeChatLoginURL()
	return SDKConfig.WeChatLoginURL
end

--QQSDK配置定义
SDKConfig.QQ = 
{
    AppID                               = "101402535", --@wechat_appid_wx  wx78ffd4f397e1aa94
    AppKey                              = "", --@wechat_secret_wx
    PartnerID                           = "", -- 商户id     --@wechat_partnerid_wx                   
    PayKey                              = "", -- 支付密钥   --@wechat_paykey_wx
    URL                                 = "",   ---l.HTTP_URL,
}

-- 微信登陆地址
SDKConfig.QQLoginURL = config.ServerConfig:findLoginDomain() .. config.LoginApiConfig.REQUEST_LOGIN_QQ

-- 获取微信登陆地址
function SDKConfig.getQQLoginURL()
	return SDKConfig.QQLoginURL
end

cc.exports.config.SDKConfig = SDKConfig
