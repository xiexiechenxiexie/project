--[[
    名称  :   ShareManager   分享请求处理
    作者  :   Xiaxb   
    描述  :   处理分享相关事宜
    时间  :   2017-7-28
--]]

local ShareManager = {}

-- local LoginManager = require "LoginManager"

ShareManager.ShareContentType_URL                   = 1     -- 分享链接
ShareManager.ShareContentType_IMAGE                 = 2     -- 分享图片

ShareManager.ShareType_QQ                       = 1     -- QQ分享
ShareManager.ShareType_QQ_ZONE                  = 2     -- 空间分享
ShareManager.ShareType_WECHAT                   = 3     -- 微信分享
ShareManager.ShareType_WECHAT_CIRCLE            = 4     -- 朋友圈分享

ShareManager.ShareResult_Success                = 1     -- 分享成功
ShareManager.ShareResult_Fail                   = 2     -- 分享失败
ShareManager.ShareResult_Cancel                 = 3     -- 分享取消

ShareManager.ShareResultCode = {}
ShareManager.ShareResultCode[0] = "游客登录不支持分享!"               -- 分享成功
ShareManager.ShareResultCode[1] = "分享成功!"                       -- 分享成功
ShareManager.ShareResultCode[2] = "分享失败!"                       -- 分享失败
ShareManager.ShareResultCode[3] = "分享取消!"                       -- 分享取消
ShareManager.ShareResultCode[4] = "分享中!"                         -- 分享成功
ShareManager.ShareResultCode[5] = "分享超时!"                       -- 分享成功
ShareManager.ShareResultCode[6] = "客户端不支持分享!"                -- 分享成功
ShareManager.ShareResultCode[7] = "未安装客户端!"                    -- 分享成功
ShareManager.ShareResultCode[8] = "未知错误!"                       -- 分享成功
ShareManager.ShareResultCode[9] = "参数错误!"                       -- 分享成功

ShareManager.ShareResultErr = "分享异常!"                           -- 分享返回数据异常

-- ShareManager.ShareScene_PromoteLayer = 1                            -- 推广分享

-- ShareManager.Share_Scene = 0                                        -- 当前分享场景

-- local shareTab = {}
-- shareTab.loginType = ""
-- shareTab.title = ""
-- shareTab.des = ""
-- shareTab.url = ""
-- shareTab.callback = ""
-- shareTab.img = ""

-- 分享链接数据
-- local shareUrlTab = {}
-- shateUrlTab.shareContentType = 0                --  分享类型(链接或者图片)
-- shareUrlTab.title = ""                          --  分享标题                          
-- shareUrlTab.des = ""                            --  分享描述
-- shareUrlTab.url = ""                            --  分享地址
-- shareUrlTab.urlImg = ""                         --  分享图片地址
-- shareUrlTab.callback = nil                      --  分享结果回调

-- 分享图片数据
-- local shareImageTab = {}
-- -- shateUrlTab.shareContentType = 0             --  分享类型(链接或者图片)          
-- shareImageTab.imgPath = ""                      --  分享图片地址
-- shareImageTab.callback = nil                    --  分享结果回调

-- local shareImageTab = {}     
-- shareImageTab.callback = function function_name( result )
--     -- body
--     print(result)
-- end                    --  分享结果回调
--  ShareManager:shareImage(UserData.loginType, shareTab)

function ShareManager:checkLoginType(loginType, shareTab)
    if 0 == loginType then
        GameUtils.showMsg("游客登录不支持分享")
        if shareTab and shareTab.callback then
            shareTab.callback(string.format("{\"result\": %d, \"plat\": %d, \"resultCode\": %d }", ShareManager.ShareResult_Fail, 0, 0))
        end
        return false
    end
    return true
end

-- 分享链接(根据传入登录方式显示对应分享平台)
function ShareManager:shareUrl(loginType, shareTab)
    if self:checkLoginType(loginTypem, shareTab) then
        shareTab.shareContentType = ShareManager.ShareContentType_URL		                --  分享类型(链接或者图片)
        local shareView = require("lobby/view/ShareView").new(loginType, shareTab)
        cc.Director:getInstance():getRunningScene():addChild(shareView, ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
    end
end

-- 分享图片(根据传入登录方式显示对应分享平台)
function ShareManager:shareImage(loginType, shareTab)
    -- print("xiaxb", "shareImage")
    if not shareTab.imgPath or "" == shareTab.imgPath then
        local function afterCaptured(succeed, outputFile)  
            -- GameUtils.stopLoading()
            if succeed then
                -- MultiPlatform:getInstance():shareToTarget(ShareManager.ShareType_QQ, callback, nil, nil, nil, outputFile, "true")
                 if self:checkLoginType(loginType, shareTab) then
                    shareTab.shareContentType = ShareManager.ShareContentType_IMAGE
                    shareTab.imgPath = outputFile
                    local shareView = require("lobby/view/ShareView").new(loginType, shareTab)
                    cc.Director:getInstance():getRunningScene():addChild(shareView, ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
                end
            else
                -- GameUtils.showMsg(shareReslut[2])
                if shareTab.callback then
                    local result = String.format("{\"result\": %d, \"plat\": %d, \"resultCode\": %d}", 2, loginType, 2)
                    shareTab.callback(shareReslut[2])
                end
            end    
        end  
        self:captureScreen(afterCaptured)
        -- GameUtils.startLoadingForever("获取屏幕截图......")
    else
        MultiPlatform:shareToTarget(ShareManager.ShareType_QQ, callback, nil, nil, nil, imgPath, "true")
    end
end

-- 分享链接至QQ平台(QQ/QQ空间)
function ShareManager:shareUrlToQQPlatform(title, des, url, callback)
    
end

-- 分享图片至QQ平台(QQ/QQ空间)
function ShareManager:shareImageToQQPlatform(imgPath, callback)

end

-- 分享图片至微信平台(微信/朋友圈)
function ShareManager:shareUrlToWechatPlatform(title, des, url, callback)

end

-- 分享图片至微信平台(微信/朋友圈)
function ShareManager:shareImageToWechatPlatform(imgPath, callback)

end

-- 分享链接至好友(QQ／群, 微信／群)
function ShareManager:shareUrlToFriend(loginType, shareTab)
    -- dump(shareTab, "xiaxb------shareUrlToFriend")
    -- print("xiaxb", "sfdafadfar:" .. shareTab.des)
    -- print("xxiaxb", "fadfadfa"..loginType)
    if self:checkLoginType(loginType, shareTab) then
        if LoginManager.LoginType_Guest == loginType then
            GameUtils.showMsg(ShareManager.ShareResultCode)
        elseif LoginManager.LoginType_Wechat == loginType then
            -- MultiPlatform:shareToTarget(ShareManager.ShareType_WECHAT, shareTab.callback, shareTab.title, shareTab.des, shareTab.url, nil, "false")
            self:shareUrlToWechat(shareTab.title, shareTab.des, shareTab.url, shareTab.callback, shareTab.urlImg)
        elseif LoginManager.LoginType_QQ == loginType then
            -- MultiPlatform:shareToTarget(ShareManager.ShareType_QQ , callback, title, des, url, nil, "false")
            self:shareUrlToQQ(shareTab.title, shareTab.des, shareTab.url, shareTab.callback, shareTab.urlImg)
        end
    end
end

-- 分享图片(QQ／群， 微信／群)
function ShareManager:shareImageToFriend(loginType, shareTab)
    if self:checkLoginType(loginType, shareTab) then
        if LoginManager.LoginType_Guest == loginType then
            GameUtils.showMsg(shareReslut[2])
            shareTab.callback(string.format("{\"result\": %d, \"plat\": %d, \"resultCode\": %d }", ShareManager.ShareResult_Fail, 0, 0))
        elseif LoginManager.LoginType_Wechat == loginType then       
            -- MultiPlatform:shareToTarget(ShareManager.ShareType_WECHAT, shareTab.callback, nil, nil, nil, shareTab.imgPath, "true")
            self:shareImageToWechat(shareTab.callback, shareTab.imgPath)
        elseif LoginManager.LoginType_QQ == loginType then
            -- MultiPlatform:shareUrlToQQ(ShareManager.ShareType_QQ, shareTab.callback, nil, nil, nil, shareTab.imgPath, "true")
            shareImageToQQZone(shareTab.callback, shareTab.imgPath)
        end
    end
end

-- 分享链接(朋友圈, QQ空间)
function ShareManager:shareUrlToZone(loginType, shareTab)
    if self:checkLoginType(loginType, shareTab) then
        if LoginManager.LoginType_Guest == loginType then
            GameUtils.showMsg(shareReslut[2])
        elseif LoginManager.LoginType_Wechat == loginType then
            -- MultiPlatform:shareToTarget(ShareManager.ShareType_WECHAT_CIRCLE, shareTab.callback, shareTab.title, shareTab.des, shareTab.url, nil, "false")
            self:shareUrlToWechatCircle(shareTab.title, shareTab.des, shareTab.url, shareTab.callback, shareTab.urlImg)
        elseif LoginManager.LoginType_QQ == loginType then
            -- MultiPlatform:shareToTarget(ShareManager.ShareType_QQ_ZONE, shareTab.callback, shareTab.title, shareTab.des, shareTab.url, nil, "false")
            self:shareUrlToQQZone(shareTab.title, shareTab.des, shareTab.url, shareTab.callback, shareTab.urlImg)
        end
    end
end

-- 分享图片(朋友圈, QQ空间)
function ShareManager:shareImageZone(imgPath, callback)
    if self:checkLoginType(loginType, shareTab) then
        if LoginManager.LoginType_Guest == loginType then
            GameUtils.showMsg(shareReslut[2])
        elseif LoginManager.LoginType_Wechat == loginType then
            -- MultiPlatform:shareToTarget(ShareManager.ShareType_WECHAT_CIRCLE, shareTab.callback, nil, nil, nil, shareTab.imgPath, "true")
            self:shareImageToWechatCircle(shareTab.callback, shareTab.imgPath)
        elseif LoginManager.LoginType_QQ == loginType then
            -- MultiPlatform:shareToTarget(ShareManager.ShareType_QQ_ZONE, shareTab.callback, nil, nil, nil, shareTab.imgPath, "true")
            self:shareImageToQQZone(shareTab.callback, shareTab.imgPath)
        end
    end
end

-- 分享链接至QQ
function ShareManager:shareUrlToQQ(title, des, url, callback, urlImg)
    MultiPlatform:shareToTarget(ShareManager.ShareType_QQ, callback, title, des, url, urlImg, "false")
end

-- 分享链接至QQ空间
function ShareManager:shareUrlToQQZone(title, des, url, callback, urlImg)
    -- print("xiaxb-------shareUrlToQQZone")
	MultiPlatform:shareToTarget(ShareManager.ShareType_QQ_ZONE, callback, title, des, url, urlImg, "false")
end

-- 分享链接至微信
function ShareManager:shareUrlToWechat(title, des, url, callback, urlImg)
    MultiPlatform:shareToTarget(ShareManager.ShareType_WECHAT, callback, title, des, url, urlImg, "false")
end

-- 分享链接至微信朋友圈
function ShareManager:shareUrlToWechatCircle(title, des, url, callback, urlImg)
    MultiPlatform:shareToTarget(ShareManager.ShareType_WECHAT_CIRCLE, callback, title, des, url, urlImg, "false")
end

-- 分享图片至QQ
function ShareManager:shareImageToQQ(callback, imgPath)
    -- print("xiaxb", "shareImageToQQ")
    -- if not imgPath or "" == imgPath then
    --     local function afterCaptured(succeed, outputFile)  
    --         if succeed then
    --             MultiPlatform:getInstance():shareToTarget(ShareManager.ShareType_QQ, callback, nil, nil, nil, outputFile, "true")
    --         else
    --             GameUtils.showMsg(shareReslut[2])
    --             if callback then
    --                 callback(shareReslut[2])
    --             end
    --         end    
    --     end  
    --     self:captureScreen(afterCaptured)
    -- else
        MultiPlatform:shareToTarget(ShareManager.ShareType_QQ, callback, nil, nil, nil, imgPath, "true")
    -- end
end

-- 分享图片至QQ空间
function ShareManager:shareImageToQQZone(callback, imgPath)
    -- if not imgPath or "" == imgPath then
    --     local function afterCaptured(succeed, outputFile)  
    --         if succeed then
    --             MultiPlatform:getInstance():shareToTarget(ShareManager.ShareType_QQ_ZONE, callback, nil, nil, nil, outputFile, "true")
    --         else
    --             GameUtils.showMsg(shareReslut[2])
    --             if callback then
    --                 callback(shareReslut[2])
    --             end
    --         end    
    --     end
    --     self:captureScreen(afterCaptured) 
    -- else
        MultiPlatform:shareToTarget(ShareManager.ShareType_QQ_ZONE, callback, nil, nil, nil, imgPath, "true")
    -- end
end

-- 分享图片至微信
function ShareManager:shareImageToWechat(callback, imgPath)
    -- print("xiaxb", "ShareManager:shareImageToWechat")
    -- if not imgPath or "" == imgPath then
    --     local function afterCaptured(succeed, outputFile)  
    --         if succeed then
    --             print("xiaxb", "outputFile:" .. outputFile)
    --             MultiPlatform:getInstance():shareToTarget(ShareManager.ShareType_WECHAT, callback, nil, nil, nil, outputFile, "true")
    --         else
    --             GameUtils.showMsg(shareReslut[2])
    --             if callback then
    --                 callback(shareReslut[2])
    --             end
    --         end    
    --     end
    --     self:captureScreen(afterCaptured)
    -- else
        MultiPlatform:shareToTarget(ShareManager.ShareType_WECHAT, callback, nil, nil, nil, imgPath, "true")
    -- end
end

-- 分享图片至微信朋友圈
function ShareManager:shareImageToWechatCircle(callback, imgPath)
    -- if not imgPath or "" == imgPath then
    --     local function afterCaptured(succeed, outputFile)  
    --         if succeed then
    --             MultiPlatform:getInstance():shareToTarget(ShareManager.ShareType_WECHAT_CIRCLE, callback, nil, nil, nil, outputFile, "true")
    --         else
    --             GameUtils.showMsg(shareReslut[2])
    --             if callback then
    --                 callback(shareReslut[2])
    --             end
    --         end    
    --     end  
    --     self:captureScreen(afterCaptured)
    -- else
        MultiPlatform:shareToTarget(ShareManager.ShareType_WECHAT_CIRCLE, callback, nil, nil, nil, imgPath, "true")
    -- end
end


function ShareManager:captureScreen(afterCapturedCallback)
    --截屏回调方法  
    local fileName = "CaptureScreenHSGM.png"  
    cc.utils:captureScreen(afterCapturedCallback, fileName)
end

cc.exports.ShareManager = ShareManager