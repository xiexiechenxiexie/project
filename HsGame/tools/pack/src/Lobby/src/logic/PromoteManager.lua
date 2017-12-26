-- 有奖推送 PHP相关
-- @date 2017.08.31
-- @author tangwen

local PromoteManager = class("PromoteManager")

function PromoteManager:ctor()

end

-- 请求有奖推送信息
function PromoteManager:requestPromoteInfoData(__callback)
	self._requestPromoteInfoCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_PROMOTE_INFO .. UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onPromoteInfoCallback))
end

function PromoteManager:_onPromoteInfoCallback( __error,__response )
    if __error then
        print("Promote Info net error")
    else
        if 200 == __response.status then
            local data = __response.data
            self._requestPromoteInfoCallBack(data)
        elseif 500 == __response.status then
            GameUtils.showMsg("请求有奖推广失败")
        else
            GameUtils.showMsg("请求有奖信息数据出错,code = "..__response.status)
        end
    end
end

-- 请求绑定手机号码验证码
function PromoteManager:requestMobileCodeData(__mobile, __callback)
    self._requestMobileCodeCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findLoginDomain() .. config.ApiConfig.REQUEST_PROMOTE_MOBILE_CODE ..__mobile.. "/".. UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onPromoteMobileCodeCallback))
end

function PromoteManager:_onPromoteMobileCodeCallback( __error,__response )
    if __error then
        print("Promote MobileCode net error")
    else
        if 200 == __response.status then
            local data = __response
            self._requestMobileCodeCallBack(data)
        elseif 500 ==  __response.status then
            GameUtils.showMsg("发送失败")
        elseif 504 ==  __response.status then
            GameUtils.showMsg("手机格式错误")           
        else
            GameUtils.showMsg("请求验证码失败："..__response.status)
        end
    end
end

-- 请求绑定手机
function PromoteManager:requestBindingMobileData(__code, __callback)
    self._requestBindingMobileCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findLoginDomain() .. config.ApiConfig.REQUEST_PROMOTE_BINGDING_MOBILE ..UserData.token.. "/".. __code
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onPromoteBindingMobileCallback))
end

function PromoteManager:_onPromoteBindingMobileCallback( __error,__response )
    if __error then
        print("Promote MobileCode net error")
    else
        if 200 == __response.status then
            local data = __response
            GameUtils.showMsg("绑定手机号码成功")
            self._requestBindingMobileCallBack(data)
        elseif 500 == __response.status then
            GameUtils.showMsg("验证码错误")
        else
            GameUtils.showMsg("绑定手机号码失败："..__response.status)
        end
    end
end

-- 请求绑定推广码
function PromoteManager:requestBindingInviteCodeData(__code, __callback)
    self._requestBindingInviteCodeCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_PROMOTE_BINGDING_INVITE_CODE ..UserData.token.. "/".. __code
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onPromoteBindingInviteCodeCallback))
end

function PromoteManager:_onPromoteBindingInviteCodeCallback( __error,__response )
    if __error then
        print("Promote BindingInviteCode net error")
    else
        if 200 == __response.status then
            local data = __response
            UserData.coins = __response.data.user.Score
            UserData.roomCards = __response.data.user.RoomCardNum
            UserData.diamond = __response.data.user.diamond
            GameUtils.showMsg("绑定邀请码成功")
            self._requestBindingInviteCodeCallBack(data)
        elseif 501 == __response.status then
            GameUtils.showMsg("绑定推广码无效")
        elseif 502 == __response.status then
            GameUtils.showMsg("该推广码是您的下级会员推广码")
        elseif 504 == __response.status then
            GameUtils.showMsg("已绑定过邀请码")
        elseif 505 == __response.status then
            GameUtils.showMsg("无效的绑定")
        elseif 506 == __response.status then
            GameUtils.showMsg("已经绑定下级")
        else
            GameUtils.showMsg("绑定邀请码失败："..__response.status)
        end
    end
end

-- 请求每日分享奖励
function PromoteManager:requestDailyShareAwardData(__callback)
    self._requestDailyShareAwardCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_PROMOTE_SHARE_AWARD .. UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onPromoteDailyShareAwardCallback))
end

function PromoteManager:_onPromoteDailyShareAwardCallback( __error,__response )
    if __error then
        print("Promote requestDailyShareAwardData net error")
    else
        if 200 == __response.status then
            local data = __response
            UserData.coins = __response.data.user.Score
            UserData.roomCards = __response.data.user.RoomCardNum
            UserData.diamond = __response.data.user.diamond
            self._requestDailyShareAwardCallBack(data)
        elseif 500 == __response.status then
            GameUtils.showMsg("已经领取当日分享奖励")
        else
            GameUtils.showMsg("请求每日分享奖励失败："..__response.status)
        end
    end
end

lib.singleInstance:bind(PromoteManager)
cc.exports.logic.PromoteManager = PromoteManager
return  PromoteManager