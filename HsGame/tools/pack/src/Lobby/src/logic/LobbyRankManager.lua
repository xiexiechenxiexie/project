-- 大厅排行榜消息 PHP相关
-- @date 2017.08.09
-- @author tangwen

local LobbyRankManager = class("LobbyRankManager")

function LobbyRankManager:ctor()
end

function LobbyRankManager:requestRickRankList( __callback)
    self._requestRickRankListCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_RICH_RANK
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onRickRankListCallback))
end

function LobbyRankManager:requestFriendRankList( __callback)
    self._requestFriendRankListCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_FRIEND_RANK .. UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onFriendRankListCallback))
end

function LobbyRankManager:_onRickRankListCallback( __error,__response )
    if __error then
        print("Rick Rank net error")
    else
        if 200 == __response.status then
            local data = __response.data.rank
            self._requestRickRankListCallBack(data)
        else
            GameUtils.showMsg("请求排行榜数据出错,code = "..__response.status)
        end
    end
end

function LobbyRankManager:_onFriendRankListCallback( __error,__response )
    if __error then
        print("Friend Rank net error")
    else
        if 200 == __response.status then
            local data = __response.data.rank
            self._requestFriendRankListCallBack(data)
        else
            GameUtils.showMsg("请求排行榜数据出错,code = "..__response.status)
        end
    end
end

lib.singleInstance:bind(LobbyRankManager)
cc.exports.logic.LobbyRankManager = LobbyRankManager
return  LobbyRankManager
