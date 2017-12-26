--[[
    名称  :   MultiPlatform  跨平台管理
    作者  :   Xiaxb   
    描述  :   根据当前使用平台调用相关的平台信息
    时间  :   2017-7-14
--]]

local MultiPlatform = class("MultiPlatform")

-- local ExternalFun = require(appdf.EXTERNAL_SRC .. "ExternalFun")
-- local self:reqModule = ExternalFun.req_var

-- 实现单例
MultiPlatform._instance = nil
-- 当前平台
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

-- 跨平台实现类
local PLATFORM = {}
PLATFORM[cc.PLATFORM_OS_ANDROID] = "src/Lobby/src/external/platform/Bridge_android"
PLATFORM[cc.PLATFORM_OS_IPHONE] = "src/Lobby/src/external/platform/Bridge_ios"
PLATFORM[cc.PLATFORM_OS_IPAD] = "src/Lobby/src/external/platform/Bridge_ios"
PLATFORM[cc.PLATFORM_OS_MAC] = "src/Lobby/src/external/platform/Bridge_ios"

-- 获取单例对象
function MultiPlatform:getInstance()
	if nil == MultiPlatform._instance then
		-- print("xiaxb-----------------MultiPlatform")
		MultiPlatform._instance = MultiPlatform:create()
	end
	return MultiPlatform._instance
end

-- 初始化
function MultiPlatform:ctor()
	-- self.sDefaultTitle = ""
	-- self.sDefaultContent = ""
	-- self.sDefaultUrl = ""
end

function MultiPlatform:getDeviceName()
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).getDeviceName then
		return self:reqModule(PLATFORM[plat]).getDeviceName()
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return "unkonw"		
	end
end

-- 获取支持平台
function MultiPlatform:getSupportPlatform()
	local plat = targetPlatform
	--ios特殊处理
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
		plat = cc.PLATFORM_OS_IPHONE
	end
	return plat
end

-- 获取第三方平台是否安装
function MultiPlatform:isPlatformInstalled(thirdparty)
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).isPlatformInstalled then
		return self:reqModule(PLATFORM[plat]).isPlatformInstalled(thirdparty)
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg		
	end
end

-- 初始化并配置第三方平台
function MultiPlatform:thirdPartyConfig(thirdparty, configTab)
	configTab = configTab or {}
	configTab.index = thirdparty
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).thirdPartyConfig then
		self:reqModule(PLATFORM[plat]).thirdPartyConfig(configTab)
	else
		print("unknow platform ==> " .. plat)
	end	
end

-- 第三方平台登陆
function MultiPlatform:thirdPartyLogin(thirdparty, callback)
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).thirdPartyLogin then
		return self:reqModule(PLATFORM[plat]).thirdPartyLogin(thirdparty, callback)
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg		
	end	
end

-- 初始化和配置分享
-- function MultiPlatform:shareConfig(socialTab)
-- 	socialTab = socialTab or {}
-- 	socialTab.title = socialTab.title or ""
-- 	socialTab.content = socialTab.content or ""
-- 	socialTab.url = socialTab.url or ""

-- 	local plat = self:getSupportPlatform()
-- 	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).shareConfig then
-- 		self:reqModule(PLATFORM[plat]).configSocial( socialTab )
-- 	else
-- 		print("unknow platform ==> " .. plat)
-- 	end	
-- end

-- 分享到指定平台
function MultiPlatform:shareToTarget(target, callback, title, content, url, img, shareImg)
	if nil == callback or type(callback) ~= "function" then
		-- print("xiab------MultiPlatform:shareToTarget: need callback function") 
		callback = function(result) end
		-- return false, "need callback function"
	end
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).shareToTarget then
		return self:reqModule(PLATFORM[plat]).shareToTarget( target, title, content, url, img, shareImg, callback )
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg		
	end
end

-- 第三方支付
function MultiPlatform:thirdPartyPay(thirdparty, payparamTab, callback)
	if nil == callback or type(callback) ~= "function" then
		return false, "need callback function"
	end
	payparamTab = payparamTab or {}

	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).thirdPartyPay then
		return self:reqModule(PLATFORM[plat]).thirdPartyPay(thirdparty, payparamTab, callback)
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg		
	end	
end

-- 复制到剪贴板
function MultiPlatform:copyToClipboard(msg)
	if type(msg) ~= "string" then
		print("复制内容非法")
		return 0, "复制内容非法"
	end
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).copyToClipboard then
		return self:reqModule(PLATFORM[plat]).copyToClipboard(msg)
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return 0, msg
	end
end

-- 手机震动
function MultiPlatform:vibrate()
	-- if type(msg) ~= "string" then
	-- 	print("复制内容非法")
	-- 	return 0, "复制内容非法"
	-- end
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).vibrate then
		return self:reqModule(PLATFORM[plat]).vibrate()
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return 0, msg
	end
end

-- 启动浏览器
function MultiPlatform:openBrowser(url)
	url = url or "http://partner.suit.wang"
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).openBrowser then
		return self:reqModule(PLATFORM[plat]).openBrowser(url)
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg
	end
end

function MultiPlatform:openWebView(url)
	url = url or "http://partner.suit.wang"
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).openWebView then
		return self:reqModule(PLATFORM[plat]).openWebView(url)
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg
	end
end

-- 游戏截图
function MultiPlatform:captureScreen()
	-- print("xiaxb-------MultiPlatform:captureScreen")
	local fileName = "CaptureScreenTest.png"
	--截屏回调方法  
	local function afterCaptured(result, outputFile)  
		if result then 
			-- print("xiaxb--------outputFile:" .. outputFile)
		else
			-- print("xiaxb--------outputFile:fail")
		end  
	end
	-- print("xiaxb-------captureScreen: center")
	-- 截屏  
    cc.utils:captureScreen(afterCaptured, fileName)
	-- print("xiaxb-------captureScreen: end")
end

-- 录音权限判断
function MultiPlatform:checkRecordPermission()
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).checkRecordPermission then
		return self:reqModule(PLATFORM[plat]).checkRecordPermission( )
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg
	end
end

-- 开始录音
function MultiPlatform:startRcecord()
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).startRcecord then
		return self:reqModule(PLATFORM[plat]).startRcecord()
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg
	end
end

-- 结束录音
function MultiPlatform:stopRcecord()
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).stopRcecord then
		return self:reqModule(PLATFORM[plat]).stopRcecord()
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg
	end
end

-- android安装更新包
function MultiPlatform:installNewApk(apkPath)
	-- body
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).installNewApk then
		return self:reqModule(PLATFORM[plat]).installNewApk(apkPath)
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg
	end
end

--获取外部存储可写文档目录
function MultiPlatform:getExtralDocPath()
	local plat = self:getSupportPlatform()
	local path = device.writablePath
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).getExtralDocPath then
		path = self:reqModule(PLATFORM[plat]).getExtralDocPath( )
	else
		print("undefined funtion or unknow platform ==> " .. plat)
	end	

	if false == cc.FileUtils:getInstance():isDirectoryExist(path) then
		cc.FileUtils:getInstance():createDirectory(path)
	end
	return path
end


-- 图片存储至系统相册
function MultiPlatform:saveImgToSystemGallery(filepath, filename)
	if false == cc.FileUtils:getInstance():isFileExist(filepath) then
		local msg = filepath .. " not exist"
		print(msg)
		return false, msg
	end
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).saveImgToSystemGallery then
		local result = self:reqModule(PLATFORM[plat]).saveImgToSystemGallery( filepath, filename )
		if result then
			GameUtils.showMsg("保存成功！")
		end
		return result
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg		
	end
end



-- 选择图片
-- callback 回调函数
-- needClip 是否需要裁减图片
function MultiPlatform:triggerPickImg(callback, needClip)
	local plat = self:getSupportPlatform()

	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).triggerPickImg then
		self:reqModule(PLATFORM[plat]).triggerPickImg( callback, needClip )
	else
		print("unknow platform ==> " .. plat)
	end	
end


-- 获取设备id
function MultiPlatform:getMachineId()
	local plat = self:getSupportPlatform()

	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).getMachineId then
		return self:reqModule(PLATFORM[plat]).getMachineId( )
	else
		print("unknow platform ==> " .. plat)
		return "A501164B366ECFC9E249163873094D50"
	end	
end

-- 获取设备ip
function MultiPlatform:getClientIpAdress()
	local plat = self:getSupportPlatform()

	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).getMachineId then
		return self:reqModule(PLATFORM[plat]).getClientIpAdress( )
	else
		print("unknow platform ==> " .. plat)
		return "192.168.1.1"
	end	
end

-- 请求单次定位
function MultiPlatform:requestLocation(callback)
	callback = callback or -1

	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).requestLocation then
		return self:reqModule(PLATFORM[plat]).requestLocation(callback)
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		if type(callback) == "function" then
			callback("")
		end
		return false, msg
	end
end

-- 计算距离
function MultiPlatform:metersBetweenLocation( loParam )
	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).metersBetweenLocation then
		return self:reqModule(PLATFORM[plat]).metersBetweenLocation(loParam)
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg
	end
end

-- 请求通讯录
function MultiPlatform:requestContact(callback)
	callback = callback or -1

	local plat = self:getSupportPlatform()
	if nil ~= self:reqModule(PLATFORM[plat]) and nil ~= self:reqModule(PLATFORM[plat]).requestContact then
		return self:reqModule(PLATFORM[plat]).requestContact(callback)
	else
		local msg = "unknow platform ==> " .. plat
		print(msg)
		return false, msg
	end
end

function MultiPlatform:reqModule(module_name)
	if (nil ~= module_name) and ("string" == type(module_name)) then
		return require(module_name);
	end
end

cc.exports.MultiPlatform = MultiPlatform