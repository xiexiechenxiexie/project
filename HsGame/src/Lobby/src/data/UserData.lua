local UserData = UserData or {}

function UserData.reset()
	UserData.userId = -1
	UserData.account = "nilStr"
	UserData.token = "nilStr"
	UserData.nickName = "nilStr"
	UserData.level = 0
	UserData.coins = 0
	UserData.roomCards = 0
	UserData.diamond = 0
	UserData.winRate = 0
	UserData.gender = 0
	UserData.avatarUrl = ""
	UserData.loginType = 0
	UserData.mobilePlatform = 0
	UserData.LastTableID = 0 -- 登陆获取到的桌子 ID ，通常为0 ，断线重连时有数据
	UserData.LastGameID = 0
	UserData.LastGameIP = "nilStr"
	UserData.LastGamePort = "nilStr"
	UserData.LastGameRoomType = 0
	UserData.HasNewbiePack = 0
	UserData.MobilePhone = ""
	UserData.FriendList = {}
	UserData.LoginServerType = 0 --  登陆的服务器类型 (大厅服务器or游戏服务器)
	UserData.RunSceneType = 0    --  运行中界面类型 (大厅界面or游戏界面or登陆界面) 主要为大厅服与游戏服通用协议服务
	UserData.shareUrl = nil
end

function UserData.findFriendByIndex(__userID)
	if __userID == UserData.userId then
		return 1
	end

	if #UserData.FriendList == 0 then
		return nil
	end
	
	for k,v in pairs(UserData.FriendList) do
		if __userID == v.UserId then
			return v
		end
	end

	return nil
end

cc.exports.UserData = UserData
