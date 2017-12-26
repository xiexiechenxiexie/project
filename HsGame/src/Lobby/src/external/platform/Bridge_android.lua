--[[
    名称  :   Bridge_andrid  android跨平台实现类
    作者  :   Xiaxb   
    描述  :   根据当前使用平台调用相关的平台信息
    时间  :   2017-7-14
--]]

local Bridge_android = {}

local luaj = require "cocos.cocos2d.luaj"
-- ios处理类
local BRIDGE_CLASS = "com/hsgame/qp/niuniu/AppActivity"

-- 获取设备机型
function Bridge_android.getDeviceName()
    local args = {  }
    local sigs = "()Ljava/lang/String;" 
    local ok,ret  = luaj.callStaticMethod(BRIDGE_CLASS, "getDeviceName", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

-- 获取第三方平台是否安装-> android 默认安装引导用户安装app，ios特殊处理
function Bridge_android.isPlatformInstalled(thirdparty)
    return "yes"
end

-- 初始化并配置第三方平台
function Bridge_android.thirdPartyConfig(configTab)
    -- dump(configTab,"xiajingda")
    local args = {lib.JsonUtil:encode(configTab)}
    -- dump(args, "xiaxb")
    local sigs = "(Ljava/lang/String;)V"
    local ok, ret  = luaj.callStaticMethod(BRIDGE_CLASS, "thirdPartyConfig", args, sigs)
    if not ok then
        print("luaj error:" .. ret)        
    end
end

-- 第三方登陆
function Bridge_android.thirdPartyLogin(thirdparty, callback)
    local args = {thirdparty, callback}
    dump(args, "xiaxb---")
    local sigs = "(II)V"
    local ok, ret  = luaj.callStaticMethod(BRIDGE_CLASS, "thirdLogin", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

-- 分享到指定平台
function Bridge_android.shareToTarget(target, title, des, targetUrl, img, shareImg, callback)
    local t = 
    {
        target = target,
        title = title,
        des = des,
        targetUrl = targetUrl,
        img = img,
        shareImg = shareImg,
    }
    -- dump(t, "xiaxb")
    -- local sigs = "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
    local params = lib.JsonUtil:encode(t)
    -- print("xiaxb", params)
    local sigs = "(Ljava/lang/String;I)V"
    local ok,ret  = luaj.callStaticMethod(BRIDGE_CLASS, "shareToTarget", {params, callback}, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

--第三方支付
function Bridge_android.thirdPartyPay(_thirdParty, _payParam, callback)
    local payParamTab = {}
    payParamTab.paymentPlatform = _thirdParty
    payParamTab.payParam = _payParam
    local args = { lib.JsonUtil:encode(payParamTab), callback }
    dump(payParamTab, "xiaxb-----------payParamTab")
    local sigs = "(Ljava/lang/String;I)V"
    local ok,ret  = luaj.callStaticMethod(BRIDGE_CLASS, "thirdPay", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

-- 复制到剪贴板
function Bridge_android.copyToClipboard(msg)
    local args = { msg }
    local sigs = "(Ljava/lang/String;)Z" 
    local ok,ret  = luaj.callStaticMethod(BRIDGE_CLASS, "copyToClipboard", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret     
    end
end

-- 手机震动
function Bridge_android.vibrate()
    local args = { }
    local sigs = "()Z" 
    local ok,ret  = luaj.callStaticMethod(BRIDGE_CLASS, "vibrate", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret     
    end
end

-- 启动浏览器
function Bridge_android.openBrowser(url)
    local args = { url }
    local sigs = "(Ljava/lang/String;)V" 
    local ok, ret  = luaj.callStaticMethod(BRIDGE_CLASS, "openBrowser", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

-- 启动WebView
function Bridge_android.openWebView(url)
    local args = {url}
    local sigs = "(Ljava/lang/String;)V" 
    local ok, ret  = luaj.callStaticMethod(BRIDGE_CLASS, "openWebView", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

-- 开始录音
function Bridge_android.startRcecord()
    local args = {}
    local sigs = "()V" 
    local ok, ret  = luaj.callStaticMethod(BRIDGE_CLASS, "startRcecord", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

-- 结束录音
function Bridge_android.stopRcecord(apkPath)
    local args = {apkPath}
    local sigs = "()Ljava/lang/String;" 
    local ok, ret = luaj.callStaticMethod(BRIDGE_CLASS, "stopRcecord", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret     
    end
end

-- 安装更新包
function Bridge_android.installNewApk(apkPath)
    local args = {apkPath}
    local sigs = "(Ljava/lang/String;)V" 
    local ok, ret  = luaj.callStaticMethod(BRIDGE_CLASS, "installNewApk", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

--获取竣付通支付列表
-- function Bridge_android.getPayList(token, callback)
--     local args = { token, callback }
--     local sigs = "(Ljava/lang/String;I)V" 
--     local ok,ret  = luaj.callStaticMethod(BRIDGE_CLASS,"getPayList",args,sigs)
--     if not ok then
--         local msg = "luaj error:" .. ret
--         print(msg)  
--         return false, msg   
--     else  
--         return true     
--     end
-- end

--获取外部存储可写文档目录
function Bridge_android.getExtralDocPath()
    local sigs = "()Ljava/lang/String;"
    local ok, ret = luaj.callStaticMethod(BRIDGE_CLASS,"getSDCardDocPath",{},sigs)
    if not ok then
        print("luaj error:" .. ret)
        return device.writablePath
    else
        print("The ret is:" .. ret)
        return ret
    end
end

--选择图片
function Bridge_android.triggerPickImg(callback, needClip)
    needClip = needClip or false
    local args = { callback, needClip }
    if nil == callback or type(callback) ~= "function" then
    	print("user default callback fun")

    	local function callbackLua(param)
	        if type(param) == "string" then
	        	print(param)
	        end        
	    end
    	args = { callbackLua, needClip }
    end    
    
    local sigs = "(IZ)V"
    local ok,ret  = luaj.callStaticMethod(BRIDGE_CLASS,"pickImg",args,sigs)
    if not ok then
        print("luaj error:" .. ret)       
    end
end

-- 图片存储至系统相册
function Bridge_android.saveImgToSystemGallery(filepath, filename)
    local args = { filepath, filename }
    local sigs = "(Ljava/lang/String;Ljava/lang/String;)Z" 
    local ok,ret = luaj.callStaticMethod(BRIDGE_CLASS,"saveImgToSystemGallery",args,sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

--获取设备id
function Bridge_android.getMachineId()
    local sigs = "()Ljava/lang/String;"    
    local ok,ret = luaj.callStaticMethod(BRIDGE_CLASS,"getUUID",{},sigs)
    if not ok then
        print("luaj error:" .. ret)
        return "A501164B366ECFC9E249163873094D50"
    else
        print("The ret is:" .. ret)
        return md5(ret)
    end
end

--获取设备ip
function Bridge_android.getClientIpAdress()
    local sigs = "()Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(BRIDGE_CLASS,"getHostAdress",{},sigs)
    if not ok then
        print("luaj error:" .. ret)
        return "192.168.1.1"
    else
        print("The ret is:" .. ret)
        return ret
    end
end

-- 录音权限判断
function Bridge_android.checkRecordPermission()
    local args = { }
    local sigs = "()Z" 
    local ok,ret = luaj.callStaticMethod(BRIDGE_CLASS,"isHaveRecordPermission",args,sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

-- 请求单次定位
function Bridge_android.requestLocation( callback )
    local args = { callback }
    local sigs = "(I)V" 
    local ok,ret = luaj.callStaticMethod(BRIDGE_CLASS,"requestLocation", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

-- 计算距离
function Bridge_android.metersBetweenLocation( loParam )
    local args = { cjson.encode(loParam) }
    local sigs = "(Ljava/lang/String;)Ljava/lang/String;"
    local ok,ret = luaj.callStaticMethod(BRIDGE_CLASS,"metersBetweenLocation", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

-- 请求通讯录
function Bridge_android.requestContact( callback )
    local args = { callback }
    local sigs = "(I)V" 
    local ok,ret = luaj.callStaticMethod(BRIDGE_CLASS,"requestContact", args, sigs)
    if not ok then
        local msg = "luaj error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

return Bridge_android