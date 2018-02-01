local UserManager = class("UserManager")

function UserManager:ctor( ... )

end

--请求用户信息
function UserManager:refreshUserInfo( ... )
    if UserData.userId then 
        local config = cc.exports.config
        local url = config.ServerConfig:findLoginDomain() .. config.ApiConfig.REQUEST_SELF_INFO .. UserData.token
        cc.exports.HttpClient:getInstance():get(url,handler(self,self._onInfoCallback))
    end
end
--[[--
cc.exports.manager.UserManager:getInstance():refreshPlayInfo()
]]
function UserManager:_onInfoCallback( __error,__response )
    if __error then
        print("Player Info net error")
    else
        if 200 == __response.status then
        	print(tostring(__response))
        	local data = __response.data
			if data.NickName then UserData.nickName = data.nickName end
			if data.Score then UserData.coins = data.score end
			if data.RoomCardNum  then  UserData.roomCards = data.roomCard end
			if data.diamond then UserData.diamond = data.diamond end
			if data.AvatarUrl then UserData.avatarUrl = data.avatar end
			if data.Gender then UserData.gender = data.gender end
			local event = cc.EventCustom:new(config.EventConfig.EVENT_REFRESH_USER_INFO)
			lib.EventUtils.dispatch(event)	
        end
    end
end

function UserManager:setCloseRoomCardFlag( __flag )
    self._flag = __flag
    print("setCloseRoomCardFlag",self._flag)
end

function UserManager:findAppCloseRoomCardFlag( ... )
    print("findAppCloseRoomCardFlag",self._flag)
    return self._flag
end

function UserManager:onDestory( ... )

end

cc.exports.manager = cc.exports.manager or {}
lib.singleInstance:bind(UserManager)
cc.exports.manager.UserManager = UserManager
return UserManager