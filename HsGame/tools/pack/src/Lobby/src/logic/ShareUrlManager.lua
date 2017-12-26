-- 分享链接管理器 PHP相关
-- Author: tangwen
-- Date: 2017-10-18 20:26:27

local ShareUrlManager = class("ShareUrlManager")

function ShareUrlManager:ctor()
end

-- 查询分享URL
function ShareUrlManager:requestShareUrlData(__callback)
    self._requestShareUrlCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_SHARE_URL ..UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onShareUrlCallback))
end

function ShareUrlManager:_onShareUrlCallback( __error,__response )
    if __error then
        printError("requestShareUrlData net error")
    else
        if 200 == __response.status then
            local data = __response.data.share
            UserData.shareUrl = {share_description = __response.data.share.share_description,
        						 share_link = __response.data.share.share_link,
        						 share_logo = config.ServerConfig:findResDomain() .. __response.data.share.share_logo,
        						 share_title = __response.data.share.share_title}
            self._requestShareUrlCallBack(data)
        else
            GameUtils.showMsg("查询分享链接失败："..__response.status)
        end
    end
end

lib.singleInstance:bind(ShareUrlManager)
cc.exports.logic.ShareUrlManager = ShareUrlManager

return  ShareUrlManager