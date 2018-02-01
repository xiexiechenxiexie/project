--[[
    名称  :   Bridge_ios  ios跨平台实现类
    作者  :   Xiaxb   
    描述  :   根据当前使用平台调用相关的平台信息
    时间  :   2017-7-14
--]]
local Bridge_ios = {}

local luaoc = require "cocos.cocos2d.luaoc"
-- ios处理类
local BRIDGE_CLASS = "AppController"

function Bridge_ios.getDeviceName()
    local paramtab = 
    { 
        -- index = thirdparty 
    }
    local ok, ret  = luaoc.callStaticMethod(BRIDGE_CLASS, "getDeviceName", paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        -- print(msg)  
        return false, msg   
    else  
        return ret
    end
end

-- 获取第三方平台是否安装
function Bridge_ios.isPlatformInstalled(thirdparty)
    local paramtab = 
    { 
        index = thirdparty 
    }
    local ok, ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"isPlatformInstalled",paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        -- print(msg)  
        return false, msg   
    else  
        return ret
    end
end

-- 初始化并配置第三方平台
function Bridge_ios.thirdPartyConfig(configTab)
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS, "thirdPartyConfig", configTab)
    if not ok then
        -- print("luaoc error:" .. ret)        
    end
end

-- 第三方登陆
function Bridge_ios.thirdPartyLogin(thirdparty, callback)
    local paramTab = 
    {
        index = thirdparty, 
        callback = callback
    }
    local ok, ret  = luaoc.callStaticMethod(BRIDGE_CLASS, "thirdLogin", paramTab)
    if not ok then
        local msg = "luaoc error:" .. ret
        -- print(msg)  
        return false, msg   
    else  
        return true     
    end
end

-- 初始化和配置分享
-- function Bridge_ios.shareConfig(socialTab)
--     local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"shareConfig",socialTab)
--     if not ok then
--         print("luaoc error:" .. ret)        
--     end
-- end

-- 分享到指定平台
function Bridge_ios.shareToTarget(target, title, des, targetUrl, img, shareImg, callback)
    local paramTab = 
    {
        target = target,
        title = title,
        des = des,
        targetUrl = targetUrl,
        img = img,
        shareImg = shareImg,
        callback = callback
    }
    -- print("xiaxb-------Bridge_ios.shareToTarget")
    local ok, ret  = luaoc.callStaticMethod(BRIDGE_CLASS, "shareToTarget", paramTab)
    if not ok then
        local msg = "luaoc error:" .. ret
        -- print(msg)  
        return false, msg   
    else  
        return true     
    end
end

--第三方支付
function Bridge_ios.thirdPartyPay(_paymentPlatform, _payParam, _callback)
    local paramTab = 
    {
        paymentPlatform = _paymentPlatform,
        payParam = _payParam,
        callback = _callback
    }
    -- paramTab.paymentPlatform = _paymentPlatform
    -- paramTab.callback = _callback
    -- paramTab.payParam = _payParam
    -- dump(payParamTab, "xiaxb--------payParamTab:")
    local ok, ret = luaoc.callStaticMethod(BRIDGE_CLASS, "thirdPay", paramTab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return true     
    end
end

-- 复制到剪贴板
function Bridge_ios.copyToClipboard(msg)
    local paramtab = 
    {
        msg = msg, 
        callback = GameUtils.showMsg
    }
    local ok, ret = luaoc.callStaticMethod(BRIDGE_CLASS,"copyToClipboard", paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        -- print(msg)  
        return 0, msg   
    else 
        print(ret)
        return ret
    end
end

-- 手机震动
function Bridge_ios.vibrate()
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS, "vibrate")
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return 0, msg   
    else 
        print(ret)
        return ret
    end
end

-- 启动浏览器
function Bridge_ios.openBrowser(url)
    local paramtab = 
    {
        url = url
    }
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS, "openBrowser", paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

-- 启动WebView
function Bridge_ios.openWebView(url)
    local paramtab = 
    {
        targetUrl = url
    }
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS, "openWebView", paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_ios.startRcecord()
    local paramtab = 
    {
        -- targetUrl = url
    }
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS, "startRcecord", paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

function Bridge_ios.stopRcecord()
    local paramtab = 
    {
        -- targetUrl = url
    }
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS, "stopRcecord", paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end


--获取竣付通支付列表
-- function Bridge_ios.getPayList(token, callback)
--     local paramtab = {token = token, scriptHandler = callback}
--     local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"getPayList",paramtab)
--     if not ok then
--         local msg = "luaoc error:" .. ret
--         print(msg)  
--         return false, msg   
--     else  
--         return true     
--     end
-- end

-- 选择图片
function Bridge_ios.triggerPickImg( callback, needClip )
	needClip = needClip or false
    local args = { scriptHandler = callback, needClip = needClip }
    if nil == callback or type(callback) ~= "function" then
        print("user default callback fun")

        local function callbackLua(param)
            if type(param) == "string" then
                print(param)
            end        
        end
        args = { scriptHandler = callback, needClip = needClip }
    end    
    
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"pickImg",args)
    if not ok then
        print("luaoc error:" .. ret)       
    end
end

-- 图片存储至系统相册
function Bridge_ios.saveImgToSystemGallery(filepath, filename)
    local args = { _filepath = filepath, _filename = filename }
    local ok,ret  = luaoc.callStaticMethod(BRIDGE_CLASS,"saveImgToSystemGallery",args)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

-- -- 获取设备id
-- function Bridge_ios.getMachineId()
--     local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"getUUID")
--     if not ok then
--         print("luaj error:" .. ret)
--         return "A501164B366ECFC9E249163873094D50"
--     else
--         print("The ret is:" .. ret)
--         return md5(ret)
--     end
-- end

--获取设备ip
function Bridge_ios.getClientIpAdress()
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"getHostAdress")
    if not ok then
        print("luaj error:" .. ret)
        return "192.168.1.1"
    else
        print("The ret is:" .. ret)
        return ret
    end
end

-- 录音权限判断
function Bridge_ios.checkRecordPermission()
    local args = { }
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"isHaveRecordPermission",args)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

-- 请求单次定位
function Bridge_ios.requestLocation( callback )
    local paramtab = {scriptHandler = callback}
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"requestLocation",paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

-- 计算距离
function Bridge_ios.metersBetweenLocation( loParam )
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"metersBetweenLocation",loParam)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end

-- 请求通讯录
function Bridge_ios.requestContact( callback )
    local paramtab = {scriptHandler = callback}
    local ok,ret = luaoc.callStaticMethod(BRIDGE_CLASS,"requestContact", paramtab)
    if not ok then
        local msg = "luaoc error:" .. ret
        print(msg)  
        return false, msg   
    else  
        return ret
    end
end





return Bridge_ios