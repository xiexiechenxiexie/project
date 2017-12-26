-- 好友管理器 PHP相关
-- @date 2017.08.29
-- @author tangwen

local FriendManager = class("FriendManager")

function FriendManager:ctor()
end

-- 查询好友列表
function FriendManager:requestFriendListData(__callback)
    self._requestFriendListCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_FRIEND_LIST ..UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onFriendListCallback))
end

function FriendManager:_onFriendListCallback( __error,__response )
    if __error then
        printError("requestFriendListData net error")
    else
        if 200 == __response.status then
            local data = __response.data.friends
            self._requestFriendListCallBack(data)
        else
            GameUtils.showMsg("查询好友列表失败："..__response.status .. "/" .. UserData.token)
        end
    end
end

-- 查找好友
function FriendManager:requestCheckFriendData(__GameID, __callback)
    self._requestCheckFriendCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_CHECK_FRIEND .. __GameID
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onCheckFriendCallback))
end

function FriendManager:_onCheckFriendCallback( __error,__response )
    if __error then
        printError("requestCheckFriendData net error")
    else
        if 200 == __response.status then
            local data = __response.data.user
            self._requestCheckFriendCallBack(data)
        else
            GameUtils.showMsg("查找好友失败："..__response.status)
        end
    end
end

-- 添加好友
function FriendManager:requestAddFriendData(__userID, __callback)
    self._requestAddFriendCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_ADD_FRIEND .. UserData.token .. "/" .. __userID
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onAddFriendCallback))
end

function FriendManager:_onAddFriendCallback( __error,__response )
    if __error then
        printError("requestAddFriendData net error")
    else
        if 200 == __response.status then
            local data = __response
            self._requestAddFriendCallBack(data)
        elseif 503 == __response.status then
            GameUtils.showMsg("不能添加自己为好友")
        elseif 504 == __response.status then
            GameUtils.showMsg("不能重复添加好友")
        else
            GameUtils.showMsg("添加好友失败："..__response.status)
        end
    end
end

-- 好友申请列表
function FriendManager:requestApplyFriendListData( __callback)
    self._requestApplyFriendListCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_APPLY_FRIEND_LIST .. UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onApplyFriendListCallback))
end

function FriendManager:_onApplyFriendListCallback( __error,__response )
    if __error then
        printError("requestApplyFriendListData net error")
    else
        if 200 == __response.status then
            local data = __response.data.applyList
            self._requestApplyFriendListCallBack(data)
        else
            GameUtils.showMsg("查询好友申请列表失败："..__response.status)
        end
    end
end

-- 回复好友申请列表 (同意或者拒绝)
function FriendManager:requestReplyApplyFriendData( __userID, __actionID, __callback)
    self._requestReplyApplyFriendCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_REPLY_APPLY_FRIEND .. UserData.token .. "/" .. __userID .. "/" .. __actionID 
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onReplyApplyFriendCallback))
end

function FriendManager:_onReplyApplyFriendCallback( __error,__response )
    if __error then
        printError("requestReplyApplyFriendData net error")
    else
        if 200 == __response.status then
            local data = __response
            self._requestReplyApplyFriendCallBack(data)
        else
            GameUtils.showMsg("回复好友申请列表失败："..__response.status)
        end
    end
end

-- 删除好友
function FriendManager:requestDeleteFriendData( __userID, __callback)
    self._requestDeleteFriendCallBack = __callback
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_DELETE_FRIEND .. UserData.token .. "/" .. __userID 
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onDeleteFriendCallback))
end

function FriendManager:_onDeleteFriendCallback( __error,__response )
    if __error then
        printError("requestDeleteFriendData net error")
    else
        if 200 == __response.status then
            local data = __response
            self._requestDeleteFriendCallBack(data)
        else
            GameUtils.showMsg("删除好友失败："..__response.status)
        end
    end
end

lib.singleInstance:bind(FriendManager)
cc.exports.logic.FriendManager = FriendManager

return  FriendManager