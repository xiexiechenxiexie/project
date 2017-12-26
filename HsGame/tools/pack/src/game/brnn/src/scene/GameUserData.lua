
local GameUserData = class("GameUserData")

local userInfo={}

function GameUserData:ctor()

end

--初始化
function GameUserData:initData(uidArray)
	for i,v in ipairs(uidArray) do
		if userInfo[v]==nil then
			self:InitPlayerInfo(v)
		end
	end
end

--更新
function GameUserData:UpdataData(uidArray)
	for i,v in ipairs(uidArray) do
		if userInfo[v]==nil then
			self:InitPlayerInfo(v)
			self:RequestUserInfo(v)
		end
	end
end

--更新玩家分数
function GameUserData:updataScore(dataArray)
	for i,v in ipairs(dataArray) do
		local UserId=v.UserId
		local Score=v.Score
		if userInfo[UserId] then
			userInfo[UserId].Score=Score
		else
			self:InitPlayerInfo(UserId)
			userInfo[UserId].Score=Score
		end
	end
end

--初始化玩家信息
function GameUserData:InitPlayerInfo(uid)
	userInfo[uid]={}
	userInfo[uid].AvatarUrl=""
	userInfo[uid].Gender=0-- 0未知1男2女
	userInfo[uid].NickName="游客"..tostring(uid)
	userInfo[uid].Score=0
	userInfo[uid].UserId=uid
	userInfo[uid].winroundsum=0
	userInfo[uid].losesum=0
	userInfo[uid].winning=0
end

--设置玩家分数
function GameUserData:setScore(uid,score)
	if userInfo[uid] then
		userInfo[uid].Score=score
	end
end

--获得玩家信息
function GameUserData:getUserInfo(UserId)
	if userInfo[UserId] then
		return userInfo[UserId]
	end
end

-- 请求用户信息
function GameUserData:RequestUserInfo( __userID)
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_PLAYER_INFO .. __userID
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onInfoCallback))
end

function GameUserData:_onInfoCallback( __error,__response )
    if __error then
        print("Player Info net error")
    else
        if 200 == __response.status then
        	local data = __response.data.profile
        	if next(data)~=nil then
        		local index=data.UserId
        		if userInfo[index] == nil then
        			self:InitPlayerInfo(index)
        		end
        		userInfo[index].AvatarUrl=data.AvatarUrl
				userInfo[index].Gender=data.Gender
				userInfo[index].NickName=data.NickName
				userInfo[index].UserId=index
				userInfo[index].Score=data.Score
				userInfo[index].winroundsum=data.winroundsum
				userInfo[index].losesum=data.losesum
				userInfo[index].winning=data.winning
        	end 
        end
    end
end

--获取批量玩家信息
function GameUserData:setRequestUserInfoCallBack(callback)
	self.callback=callback
end

--获取批量玩家信息
function GameUserData:RequestUserInfoArray()
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.GAME_PLAYER_INFO .. UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onInfoArrayCallback))
end

function GameUserData:_onInfoArrayCallback( __error,__response )
    if __error then
        print("Personal Info net error")
    else
        if 200 == __response.status then
            local data = __response.data.profile
            for i,v in ipairs(data) do
            	local index=v.UserId
            	if userInfo[index] == nil then
        			self:InitPlayerInfo(index)
        		end
        		userInfo[index].AvatarUrl=v.AvatarUrl
				userInfo[index].Gender=v.Gender
				userInfo[index].NickName=v.NickName
				userInfo[index].UserId=index
				userInfo[index].Score=userInfo[index].Score or v.Score
				userInfo[index].winroundsum=v.winroundsum
				userInfo[index].losesum=v.losesum
				userInfo[index].winning=v.winning
            end
            if self.callback then
            	self.callback()
            end
        end
    end
end

function GameUserData:onDestory()
	userInfo={}
end

cc.exports.lib.singleInstance:bind(GameUserData)

return GameUserData