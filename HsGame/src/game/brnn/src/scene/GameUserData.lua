
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
		local UserId=v.userId
		local Score=v.score
		if userInfo[UserId] then
			userInfo[UserId].score=Score
		else
			self:InitPlayerInfo(UserId)
			userInfo[UserId].score=Score
		end
	end
end

--初始化玩家信息
function GameUserData:InitPlayerInfo(uid)
	userInfo[uid]={}
	userInfo[uid].avatar=""
	userInfo[uid].gender=0-- 0未知1男2女
	userInfo[uid].nickName="游客"..tostring(uid)
	userInfo[uid].score=0
	userInfo[uid].userId=uid
	userInfo[uid].winroundsum=0
	userInfo[uid].losesum=0
	userInfo[uid].winning=0
end

--设置玩家分数
function GameUserData:setScore(uid,score)
	if userInfo[uid] then
		userInfo[uid].score=score
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
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_PLAYER_INFO .. __userID.."?token="..UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onInfoCallback))
end

function GameUserData:_onInfoCallback( __error,__response )
    if __error then
        print("Player Info net error")
    else
        if 200 == __response.status then
        	local data = __response.data
        	if next(data)~=nil then
        		local index=data.userId
        		if userInfo[index] == nil then
        			self:InitPlayerInfo(index)
        		end
        		userInfo[index].avatar=data.avatar
				userInfo[index].gender=data.gender
				userInfo[index].nickName=data.nickName
				userInfo[index].userId=index
				userInfo[index].score=data.score
				userInfo[index].winroundsum=data.winroundsum or 0
				userInfo[index].losesum=data.losesum or 0
				userInfo[index].winning=data.winning or 0
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
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_PRIVATEROOM_PLAYER_INFO ..GameData.TableID.."?token="..UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onInfoArrayCallback))
end

function GameUserData:_onInfoArrayCallback( __error,__response )
	print("获取批量玩家信息")
	dump(__response)
    if __error then
        print("Personal Info net error")
    else
        if 200 == __response.status then
            local data = __response.data
            for i,v in ipairs(data) do
            	local index = v.userId
            	if userInfo[index] == nil then
        			self:InitPlayerInfo(index)
        		end
        		userInfo[index].avatar=v.avatar
				userInfo[index].gender=v.gender
				userInfo[index].nickName=v.nickName
				userInfo[index].userId=index
				userInfo[index].score=userInfo[index].score or v.score
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