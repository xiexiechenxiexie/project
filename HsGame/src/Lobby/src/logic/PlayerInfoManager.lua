-- 玩家信息 消息管理 PHP相关
-- @date 2017.08.15
-- @author tangwen

local PlayerInfoManager = class("PlayerInfoManager")

function PlayerInfoManager:ctor()

end

-- 请求个人信息
function PlayerInfoManager:requestPersonalInfoData( __callback)
    self._requestPersonalInfoCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_SELF_INFO .. "?token="..UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onPersonalInfoCallback))
end

function PlayerInfoManager:_onPersonalInfoCallback( __error,__response )
    if __error then
        print("Personal Info net error")
    else
        if 200 == __response.status then
            local data = __response.data
            self._requestPersonalInfoCallBack(data)
        else
            GameUtils.showMsg("请求个人信息数据出错,code:".. __response.status)
        end
    end
end

-- 请求用户信息
function PlayerInfoManager:requestPlayerInfoData( __userID, __callback)
    self._requestPlayerInfoCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_PLAYER_INFO .. __userID.."?token="..UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onPlayerInfoCallback))
end

function PlayerInfoManager:_onPlayerInfoCallback( __error,__response )
    if __error then
        print("Player Info net error")
    else
        if 200 == __response.status then
            local data = __response.data
            self._requestPlayerInfoCallBack(data)
        else
            GameUtils.showMsg("请求玩家信息数据出错,code = "..__response.status)
        end
    end
end

-- 请求修改个人信息 REQUEST_REVISE_SELF_INFO
function PlayerInfoManager:requestReviseSelfInfo(__params,__callback)
    self._requestReviseSelfInfoCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_REVISE_SELF_INFO 
    print("请求修改个人信息url",url)
    cc.exports.HttpClient:getInstance():post(url,__params,handler(self,self.onReviseSelfInfoCallback))
end

function PlayerInfoManager:onReviseSelfInfoCallback( __error,__response )
    print("但是就打开拉斯加了")
    dump(__response)
    if __error then
        print("requestReviseSelfInfo info net error")
    else
        if 200 == __response.status then
            local data = __response
            self._requestReviseSelfInfoCallBack(data)
        elseif 503 == __response.status then
            GameUtils.showMsg("昵称不能为空")   
        else
            GameUtils.showMsg("请求个人信息数据出错,code = "..__response.status)
        end
    end
end

lib.singleInstance:bind(PlayerInfoManager)
cc.exports.logic.PlayerInfoManager = PlayerInfoManager
return PlayerInfoManager
