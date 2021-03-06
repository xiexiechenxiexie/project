-- 新手礼包 php
-- @date 2017.08.21
-- @author tangwen

local NovicesRewardManager = class("NovicesRewardManager")

function NovicesRewardManager:ctor()
    
end

-- 请求新手信息
function NovicesRewardManager:requestNovicesRewardInfo(__callback)
    self._requestNovicesRewardCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_NOVICES_REWARD_INFO
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onSignNovicesRewardCallback))
end


function NovicesRewardManager:_onSignNovicesRewardCallback( __error,__response )
    if __error then
        print("NovicesReward info net error")
    else
        if 200 == __response.status then
            local data = __response.data.newbiePack
            self._requestNovicesRewardCallBack(data)
        else
            GameUtils.showMsg("请求新手信息数据出错,code = "..__response.status)
        end
    end
end

-- 请求 新手信息领取
function NovicesRewardManager:requestNovicesRewardReceive(__callback)
    self._requestNovicesRewardReceiveCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_NOVICES_REWARD_RECEIVE .. UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onSignNovicesRewardReceiveCallback),true)
end


function NovicesRewardManager:_onSignNovicesRewardReceiveCallback( __error,__response )
    if __error then
        print("get NovicesReward  net error")
    else
        if 200 == __response.status then
            local data = __response.data
            UserData.coins = __response.data.user.Score
            UserData.roomCards = __response.data.user.RoomCardNum
            UserData.diamond = __response.data.user.diamond
            self._requestNovicesRewardReceiveCallBack(data)
        else
            GameUtils.showMsg("领取新手奖励数据出错,code = "..__response.status)
        end
    end
end

lib.singleInstance:bind(NovicesRewardManager)
cc.exports.logic.NovicesRewardManager = NovicesRewardManager
return NovicesRewardManager