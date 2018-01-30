--[[--
@author fly
]]

local Test = false

local RoomProgressData = class("RoomProgressData")
RoomProgressData.roomId = 1 --房间id
RoomProgressData.leftGameRound = 5 --剩余局数
RoomProgressData.totalGameRound = 5 --总局数
RoomProgressData.isCostSeat = true --是否收费入座
RoomProgressData.gameBet = 0
RoomProgressData.peopleNumOfRoom = 5 --房间人数
RoomProgressData.capityPeopleNumOfRoom = 5 --房间容纳人数
RoomProgressData.gameId = 1
RoomProgressData.serverIp = ""
RoomProgressData.serverPort = 0

RoomProgressData.timeOfCreateRoom = "2017-07-10 00:00"
function RoomProgressData:ctor( __param )
	if Test then
		return
	end
	self.roomId = __param.TableID --房间id
	self.totalGameRound = __param.GameRound
	self.leftGameRound = __param.GameRound - __param.CurrentRound --剩余局数
	self.gameId = __param.KindID
	if __param.KindID == config.GameIDConfig.KPQZ then
		local data = NiuNiuData.parseRule(__param.CurrentRule)
		self.isCostSeat = NiuNiuData.isOpen(data.ChargeSit)  --是否收费入座
		self.gameBet = data.GameBet
	end
	
	self.peopleNumOfRoom = __param.CurrentPeople--房间人数
	self.capityPeopleNumOfRoom = __param.PeopleNum
	self.timeOfCreateRoom = __param.CreateDate
	self.serverIp = __param.ServerIp or ""
	self.serverPort = __param.ServerPort or 0
end



local RoomEndedData = class("RoomEndedData")
RoomEndedData.roomId = 1
RoomEndedData.gameRound = 1 --局数
RoomEndedData.peopleNumOfRoom = 1 --参与人数
RoomEndedData.timeOfCreateRoom = "2017-07-10"
RoomEndedData.historyRoomId = 1
RoomEndedData.createrName = "老王"
RoomEndedData.gameBet = 1
RoomEndedData.isAutoNiu = true
function RoomEndedData:ctor( __param )
	if Test then
		return
	end
	dump(__param)
	self.historyRoomId = __param.TableHistoryId
	self.roomId = __param.TableID
	self.gameRound = __param.GameRound --局数
	self.peopleNumOfRoom = __param.PeopleNum --参与人数
	self.timeOfCreateRoom = __param.CreateDate
	self.timeOfCreateRoom = string.sub(self.timeOfCreateRoom,6)
	self.createrName = string.getMaxLen(__param.NickName,12)
	if __param.KindID == config.GameIDConfig.KPQZ then
		local data = NiuNiuData.parseRule(__param.CurrentRule)
		self.isAutoNiu = data.AccountType == 0
		self.gameBet = data.GameBet
	end
end

----我参与的牌局
local JoinChessData = class("JoinChessData")
JoinChessData.roomId = 1 --房间Id
JoinChessData.historyRoomId = 1 --历史房间Id
JoinChessData.createrName = "" --创建者
JoinChessData.score = 3  --战绩
JoinChessData.isAutoNiu = true --是否自动结算牛
JoinChessData.gameBet = 1 --底分
JoinChessData.gameRound = 1
JoinChessData.peopleNum = 1  --房间总人数
JoinChessData.timeOfCreateRoom = "2017-10-09 16:59"
JoinChessData.createDate = "老王"
JoinChessData.uid = "" --房主编号
JoinChessData.gameId = 1 --房主编号
function JoinChessData:ctor( __param )
	if Test then
		return
	end
	self.historyRoomId = __param.TableHistoryId
	self.roomId = __param.TableID --房间Id
	self.createrName = string.getMaxLen(__param.NickName,12)  --创建者
	self.score = __param.Score  --战绩
	if __param.KindID == config.GameIDConfig.KPQZ then
		local data = NiuNiuData.parseRule(__param.CurrentRule)
		self.isAutoNiu = data.AccountType == 0
		self.gameBet = data.GameBet
	end
	self.gameRound = __param.GameRound
	self.peopleNum = __param.peopleNum
	--self.createDate = __param.CreateDate
	self.uid = __param.Uid
	self.gameId = __param.KindID
	self.timeOfCreateRoom = __param.CreateDate
	self.timeOfCreateRoom = string.sub(self.timeOfCreateRoom,6)
 end 

----牌局详情
local ChessDetailData = class("ChessDetailData")
ChessDetailData.listGamers = {}

function ChessDetailData:ctor ( __roomList )
	if Test then
		for i=1,10 do
			self.listGamers[#self.listGamers+1] = {gameId = 1,gamerName = "老王",avatar = "",score = 1000,flag = 0}
		end
		return
	end
	self.listGamers = {}
	__roomList = __roomList or {}
	for _,param in ipairs(__roomList) do
		local data = {}
		data.gamerName = param.NickName
		data.avatarUrl = param.AvatarUrl
		data.score = param.Score
		data.flag = param.Flag
		data.userId = param.UserId
		data.gender = param.Gender
		self.listGamers[#self.listGamers + 1] = data
	end
end




local CreateRoomManager = class("CreateRoomManager")

CreateRoomManager.Test = Test
CreateRoomManager._listProgress = nil
CreateRoomManager._listEnded = nil
CreateRoomManager._listJoinChess = nil
CreateRoomManager._chessDetail = nil
CreateRoomManager._selection = 1

CreateRoomManager._configCreate = nil


function CreateRoomManager:ctor( ... )
	self._listProgress = {}
	self._listEnded = {}
	self._listJoinChess = {}
	self._configCreate = nil
	if self.Test then
		self:_initTestData()
	else
		self._init()
	end
end

function CreateRoomManager:_initTestData( ... )
	local itemNum = 10 
	for i=1,itemNum do
		self._listProgress[#self._listProgress + 1] = RoomProgressData.create()
	end

	local itemNum = 5 
	for i=1,itemNum do
		self._listEnded[#self._listEnded + 1] = RoomEndedData.create()
	end
	itemNum = 9
	for i=1,itemNum do
		self._listJoinChess[#self._listJoinChess + 1] = JoinChessData.create()
	end

	self._chessDetail = ChessDetailData.create()
end

function CreateRoomManager:_init( ... )

end

-- 请求私人房房间配置响应
CreateRoomManager._callback = nil
function CreateRoomManager:RequestPrivateTableConfig(__callback)
	self._callback = __callback
	local gameId  = self:findActGameId()
    local config = cc.exports.config
	local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_TABLE_CONFIG..gameId.."/"..UserData.token
    print("url:",url)
	cc.exports.HttpClient:getInstance():get(url,handler(self,self.onTableConfigCallback))
end

--[[--
私人房配置
]]
function CreateRoomManager:onTableConfigCallback( __error,__response )
	print("私人房配置")
	dump(__response)
	if __error then
    	print("Table config net error")
    	GameUtils.showMsg(self:findrequestRoomConfigAndInfoErrorString() .. __error)
    else
    	local GameIdConfig = cc.exports.config.GameIDConfig
		if 200 == __response.status then
    		local gameId = self:findActGameId()
            print(gameId)
    		if gameId == GameIdConfig.KPQZ then -- 牛牛  看牌抢庄
    			self._configCreate = {}
                self._configCreate._costOfOneRoomCard =  __response.data.round or 10 --局数
                self._configCreate._cardCostUnit = __response.data.spend or 3  --每round 消耗spend房卡        
                self._configCreate._isAuthorizeSitSelectionShow = __response.data.options.permission or 1 == 1   -- 授权入座选项，0不显示，1显示
                self._configCreate._isCostSitSelectionShow = __response.data.options.toll or 1  == 1 -- 收费入座选项，0不现实，1显示
            	if self._callback then self._callback() end
            elseif gameId == GameIdConfig.BRNN then
                print("gameId == 1002")
            else
                print("game id error")
            end
    	end
    end
end

--[[--
是否展示授权入座选项
]]
function CreateRoomManager:isGrantAuthorizationShow( ... )
	print("是否展示授权入座选项",self._configCreate._isAuthorizeSitSelectionShow)
	return self._configCreate._isAuthorizeSitSelectionShow
end

--[[--
是否展示消耗花费选项
]]
function CreateRoomManager:isCostSitSelectionShow( ... )
	print("是否展示消耗花费选项",self._configCreate._isCostSitSelectionShow)
	return self._configCreate._isCostSitSelectionShow
end

--[[--
房卡消耗单元 每n张房卡对应多少局
]]
function CreateRoomManager:findCardCostUnit( ... )
	return self._configCreate._cardCostUnit
end

function CreateRoomManager:findDetailListGamers( ... )
	return self._chessDetail.listGamers
end

--[[--
开房间开多少局数消耗 单元房卡  n局对应 单元房卡数量
]]
function CreateRoomManager:findChessUnit( ... )
	return self._configCreate._costOfOneRoomCard
end

function CreateRoomManager:findProgressRooms( ... )
	return self._listProgress;
end

function CreateRoomManager:findEndedRooms( ... )
	return self._listEnded
end

function CreateRoomManager:findJoinChess( ... )
	return self._listJoinChess
end

--[[--
房间列表数据选项卡  1 进行中  2 已经结束  3  我的牌局
]]
function CreateRoomManager:setSelection(__selection)
	self._selection = __selection
end

function CreateRoomManager:setClickIndex( __index )
	self._index = __index
end

function CreateRoomManager:findSelectedData( ... )
	local list = nil
	if self._selection == 1 then
		list = self._listProgress
	elseif self._selection == 2 then
		list = self._listEnded
	elseif  self._selection == 3 then
		list = self._listJoinChess
	end
	dump(list)
	if list then
		return list[self._index]
	end
	return nil
end




--正在进行的牌局
function CreateRoomManager:requestGameProgress(__callback )
	local url = self:findRequestUrl(config.ApiConfig.REQUEST_GET_ROOM_PLAYING)
	url = url .. UserData.token .. "/" .. lobby.LobbyGameEnterManager:getInstance():findSelectedGameId()
	
	if Test then
		local event = cc.EventCustom:new(config.EventConfig.EVENT_ROOM_PROGRESS_TO_VIEW)
		lib.EventUtils.dispatch(event)	
		return
	end

	HttpClient:getInstance():get(url,function (__errorMsg,__rsp)
		if  __errorMsg then
			print("网络错误",__errorMsg)
			return
		end
		if __rsp.status == 200 then
			self._listProgress = {}
			print("__rsp.data.roomlist",__rsp.data.roomlist)
			for i,info in ipairs(__rsp.data.roomlist) do
				local progress = RoomProgressData.new(info)
				self._listProgress[i] = progress

			end
			local event = cc.EventCustom:new(config.EventConfig.EVENT_ROOM_PROGRESS_TO_VIEW)
			lib.EventUtils.dispatch(event)
		else
			print("正在进行房间数据异常",__rsp.msg)
			
			local event = cc.EventCustom:new(config.EventConfig.EVENT_ROOM_PROGRESS_TO_VIEW)
			lib.EventUtils.dispatch(event)
		end 
	end)
end

--参与的牌局
function CreateRoomManager:requestGameMyChess( __callback )
	if Test then
		local event = cc.EventCustom:new(config.EventConfig.EVENT_ROOM_JOIN_CHESS_TO_VIEW)
		lib.EventUtils.dispatch(event)	
		return
	end

	local url = self:findRequestUrl(config.ApiConfig.REQUEST_MY_JOIN_ROOM)
	url = url .. UserData.token .. "/" .. lobby.LobbyGameEnterManager:getInstance():findSelectedGameId()
	HttpClient:getInstance():get(url,function (__errorMsg,__rsp)
		if __errorMsg then
			print("网络错误",__errorMsg)
			return
		end
		if __rsp.status == 200 then
			self._listJoinChess = {}
			for i,info in ipairs(__rsp.data.roomlist) do
				local joinProcess = JoinChessData:create(info)
				self._listJoinChess[i] = joinProcess
				if __callback then 
					__callback(nil,self._listJoinChess)
				end
			end
			local event = cc.EventCustom:new(config.EventConfig.EVENT_ROOM_JOIN_CHESS_TO_VIEW)
			lib.EventUtils.dispatch(event)	
		else
			print("已经结束房间 数据异常",__rsp.msg)
			if __callback then 
				__callback(__rsp.msg,nil)
			end
		end 
	end)
end

--已经结束的牌局
function CreateRoomManager:requestGameEnded( __callback )
	if Test then
		local event = cc.EventCustom:new(config.EventConfig.EVENT_ROOM_ENDED_TO_VIEW)
		lib.EventUtils.dispatch(event)	
		return
	end

	local url = self:findRequestUrl(config.ApiConfig.REQUEST_GET_ROOM_FINISH)
	url = url .. UserData.token .. "/" .. lobby.LobbyGameEnterManager:getInstance():findSelectedGameId()
	HttpClient:getInstance():get(url,function (__errorMsg,__rsp)
		if __errorMsg then
			print("网络错误",__errorMsg)
			return
		end
		if __rsp.status == 200 then
			self._listEnded = {}
			for i,info in ipairs(__rsp.data.roomlist) do
				dump(info)
				print(info.TableID)
				local ended = RoomEndedData:create(info)
				self._listEnded[i] = ended

			end
			if __callback then 
				__callback(nil,self._listEnded)
			end
			local event = cc.EventCustom:new(config.EventConfig.EVENT_ROOM_ENDED_TO_VIEW)
			lib.EventUtils.dispatch(event)	
		else
			print("已经结束房间 数据异常",__rsp.msg)
			if __callback then 
				__callback(__rsp.msg,nil)
			end
		end 
	end)
end

--牌局详情
function CreateRoomManager:requestChessDetail(__historyRoomId, __callback )
	local url = self:findRequestUrl(config.ApiConfig.REQUEST_ROOM_HISTORY_DETAIL)
	url = url  .. __historyRoomId
	HttpClient:getInstance():get(url,function (__errorMsg,__rsp)
		if __errorMsg then
			print("网络错误",__errorMsg)
			return
		end
		if __rsp.status == 200 then
			self._chessDetail = {}
			self._chessDetail = ChessDetailData:create(__rsp.data.roomlist) 
			if __callback then 
				__callback(nil,self._chessDetail)
			end
		else
			print("已经结束房间 数据异常",__rsp.msg)
			if __callback then 
				__callback(__rsp.msg,nil)
			end
		end 
	end)
end



function CreateRoomManager:requestCreateRoom( __createInput,__gameId,__capacity)
	print("CreateRoomManager:requestCreateRoom",__gameId,__capacity)
	local params = {
		gameID = __gameId,
		round = __createInput.chess,
		capacity = __capacity,
		accountType = __createInput.isAutoNiu and 0 or 1,
		gameBet = __createInput.score - 1,
		authorizeSit = __createInput.isOpenRightToSeat and 1 or 0,
		chargeSit = __createInput.isCostToSeat and 1 or 0
	}
	print("CreateRoomManager:requestCreateRoom")
	dump(params)
	self:RequestCreatePrivateTable(params)
	GameUtils.startLoadingForever()

end

function CreateRoomManager:RequestCreatePrivateTable(__params)
    print("RequestCreatePrivateTable")
    
    GameData.GameID = __params.gameID 
    GameData.GameRoundNum = __params.round
    GameData.GamePlayerNum = __params.capacity
    GameData.IntoGameType = ConstantsData.IntoGameType.PRIVATE_CREATE_TABLE_TYPE
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_CREATE_TABLE
    print("url:",url)
    local param = {}
    if __params.gameID == config.GameIDConfig.KPQZ  then -- 牛牛 看牌抢庄
        NiuNiuData.AccountType = __params.accountType
        NiuNiuData.GameBet  = __params.gameBet
        
        NiuNiuData.AuthorizeSit  = __params.authorizeSit
        NiuNiuData.ChargeSit  = __params.chargeSit
        param = { token= UserData.token, round = GameData.GameRoundNum, gameId = GameData.GameID, capacity = GameData.GamePlayerNum, rule = NiuNiuData.createRule(),charges = __params.chargeSit + 1 }
    end
    logic.LobbyTableManager:getInstance():setGameId(__params.gameID )
    dump(param)
    HttpClient:getInstance():post(url,param,handler(self,self.onCreatePrivateTableCallback))
end

function CreateRoomManager:onCreatePrivateTableCallback( __errorMsg,__response )
	print("CreateRoomManager:onCreatePrivateTableCallback")
	GameUtils.startLoadingForever()
	--todo:展示确认框
    if __errorMsg then
    	GameUtils.showMsg(self:findCreateRoomRequestFailedString(),3)
    else

        if 200 == __response.status then
            GameData.GameIP =  __response.data.serverIp
            GameData.GamePort = __response.data.port 
            GameData.TableID = __response.data.tableId
            print("GameData.GameIP:",GameData.GameIP)
            print("GameData.Port:",GameData.GamePort)
            print("GameData.TableID:",GameData.TableID)
            logic.LobbyManager:getInstance():LoginGameServer()
        end
    end
end

--[[--
请求房间配置信息,房间信息 已确认房卡消耗
]]
function CreateRoomManager:requestRoomConfigAndInfo( __tableId,__callback )
	GameUtils.startLoadingForever(self:findRoomInfoString())
	if not self._configCreate then 
		self:RequestPrivateTableConfig(function ( ... )
			self:requestRoomInfo(__tableId,__callback)
		end)
	else
	    self:requestRoomInfo(__tableId,__callback)	
	end
end

function CreateRoomManager:requestRoomInfo( __tableId,__callback )
	local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_JOIN_ROOM_INFO_WITH_ROOMID .. UserData.token .. "/" ..  __tableId
	HttpClient:getInstance():get(url,function ( __errorMsg,__response )
		GameUtils.stopLoading()
		if not __errorMsg then 
			if __callback  then 
				if __response.data and __response.data.server_ip and __response.data.server_port then 
					__callback(__response)
				else
					GameUtils.showMsg(self:findingRoomNotExist())
				end
				
			end
		else
			GameUtils.showMsg(self:findrequestRoomConfigAndInfoErrorString() .. __errorMsg)
		end
	end)
end






function CreateRoomManager:findRoomCardCost( __chessNum )
	print("CreateRoomManager:findRoomCardCost",__chessNum,self:findChessUnit() , self:findCardCostUnit())
	return __chessNum / (self:findChessUnit() / self:findCardCostUnit()) --todo房卡配置信息读取
end

function CreateRoomManager:findActGameId( ... )
	return cc.exports.lobby.LobbyGameEnterManager:getInstance():findSelectedGameId()
end

function CreateRoomManager:findRequestUrl(__apiStr)
	return config.ServerConfig:findModelDomain() .. __apiStr
end

--[[--
邀请好友
]]
function CreateRoomManager:onInviteCallback( __index )
	print("邀请好友 索引编号：",__index)
	local progressDatas = self:findProgressRooms()
    if progressDatas[__index] and progressDatas[__index].roomId then 
    	self:requestShareInfo(progressDatas[__index],function ( shareInfo )
            print("ShareManager:shareUrlToFriend")
			dump(shareInfo)
         	ShareManager:shareUrlToFriend(UserData.loginType,shareInfo)
    	end)
    end
end

--[[--
观战  
]]
function CreateRoomManager:onVisiteCallback( __index )
	print("观战 房间编号：",__index)
	local selectData = self._listProgress[__index]
	if selectData then 
		local gameId = self:findActGameId()
		GameData.TableID = selectData.roomId
		GameData.GameID = selectData.gameId
		self:requestRoomInfo(GameData.TableID,function ( __info )
			GameData.GameIP = __info.data.server_ip
			GameData.GamePort = __info.data.server_port
			GameData.IntoGameType = ConstantsData.IntoGameType.PRIVATE_JOIN_TABLE_TYPE
	    	logic.LobbyManager:getInstance():LoginGameServer()
		end)
	end
end

--[[--
房间信息请求
]]
function CreateRoomManager:requestShareInfo( __processData,__callback )
	assert(__processData,"invalid __roomId")
    local shareInfo = {
        title = "???",
        des = "非常经典的棋牌游戏",
        url = "www.baidu.com"
    }
    print("__processData.roomId",__processData.roomId)

    local url = config.ServerConfig:findModelDomain() 
    ..  config.ApiConfig.REQUEST_INVITE_INFO 
    .. __processData.roomId 
    .. "/" .. __processData.gameBet 
    .. "/" .. __processData.totalGameRound
    .. "/" .. __processData.gameId

    local func = function ( __errorMsg,__response )
    	print(tostring(__errorMsg),tostring(__response))
    	if not __errorMsg then
    		shareInfo.des = __response.data.description
    		shareInfo.title = __response.data.title
    		shareInfo.url = __response.data.url
	        if __callback then 
	            __callback(shareInfo)
	        end
	    else
	    	GameUtils.showMsg(tostring(__errorMsg),2)
    	end
    end
    HttpClient:getInstance():get(url,func)
end

--[[--
授权入座申请，检测房卡消耗，并且提示房卡
]]
function CreateRoomManager:checkSitDown( __roomId,__callback)
	local enterTipFunc = function ( __info )
		local roomInfo = {}
		local data = NiuNiuData.parseRule(__info.data.CurrentRule)
		dump(data)
		roomInfo.AuthorizeSit = data.AuthorizeSit 
		roomInfo.ChargeSit = data.ChargeSit 
		roomInfo.cost = self:findRoomCardCost(__info.data.GameRound) 
		if data.ChargeSit then 
			roomInfo.cost = roomInfo.cost / 3
		end
		roomInfo.serverIp = __info.data.server_ip
		roomInfo.serverPort = __info.data.server_port
		roomInfo.gameId = __info.data.CurrentRule
		roomInfo.currentPeople = __info.data.CurrentPeople
		roomInfo.peopleNum = __info.data.PeopleNum
		if roomInfo.cost > UserData.roomCards and data.ChargeSit > 1 then -- 
			local content = string.format("需要消耗%d张房卡,你只有%d房卡不足",roomInfo.cost,UserData.roomCards)
			local param = {type = ConstantsData.ShowMgsBoxType.NORMAL_TYPE, msg = content, btn = {"ok"}, callback = callback}		
			local function callback(event)
				GameUtils.hideMsgBox()
			end
			GameUtils.showMsgBox(param)
			return 
		end
		if data.AuthorizeSit > 0 then
				local content = "该房间需要授权入座"
				if data.ChargeSit > 0  then 
					local cost = roomInfo.cost
					content = string.format("需要消耗%d张房卡",roomInfo.cost)
				end
				local params = {
						content = content,
						okFunc = function ( ... )
							if __callback then  __callback(roomInfo) end
						end,
						showType = lib.layer.MessageBox.TYPE_SELECT,
				}
				lib.layer.MessageBox.showMsgBox(params)
		else
				if __callback then  __callback(roomInfo) end
		end
	end
	self:requestRoomConfigAndInfo(__roomId,function ( __info )
		enterTipFunc(__info)
	end)
end

function CreateRoomManager:findCreateRoomRequestFailedString( ... )
	return "创建房间失败，请重试或者联系客服"
end

function CreateRoomManager:findCostSeatLanguage( __data )
	print("CreateRoomManager:findCostSeatLanguage")
	dump(__data)
	if __data.isCostSeat then
		return "是"
	else
		return "否"
	end
end

function CreateRoomManager:findLastChessString( ... )
	return "最近50场"
end

function CreateRoomManager:findRoomIdString( __str )
	__str = __str or ""
	return string.format("房间ID:%s",__str)
end

function CreateRoomManager:findChessAllString( ... )
	return "局数: "
end

function CreateRoomManager:findJoinNumString( ... )
	return "参与人数: "
end

function CreateRoomManager:findCreateLabelName( ... )
	return "创建者:"
end

function CreateRoomManager:findTimeLabelString( ... )
	return "时间:"
end

function CreateRoomManager:findCreatorString( __data )
	return "创建者:" .. __data.createrName
end

function CreateRoomManager:findScoreString( __data )
	if __data.score >  0 then
		return "战绩: + " ..  __data.score 
	end
	return "战绩: "  ..  __data.score
	
end

function CreateRoomManager:findMinScoreString(__str )
	__str = __str or ""
	return string.format("底%s分:",__str)
end

function CreateRoomManager:findChessNumString( __str )
	__str = __str or ""
	return string.format("局%s数:",__str)
end

function CreateRoomManager:findComNiuLabelString( __str )
	__str = __str or ""
	return string.format("算%s牛:",__str)
end
function CreateRoomManager:findAutoNiuLabelString( ... )
	return "自动算牛"
end

function CreateRoomManager:findSelfNiuLabelString( ... )
	return "手动算牛"
end

function CreateRoomManager:findOpenString( ... )
	return "开启"
end

function CreateRoomManager:findCloseString( ... )
	return "关闭"
end

function CreateRoomManager:findYesString( ... )
	return "AA支付"
end

function CreateRoomManager:findNoString( ... )
	return "房主支付"
end

function CreateRoomManager:findSeatDownRightString( ... )
	return "授权入座"
end

function CreateRoomManager:findCostLabelString( ... )
	return "费      用:"
end

function CreateRoomManager:findCostSeatDownString( ... )
	return "支付方式"
end


function CreateRoomManager:findNumOfRoomString( __data )
	return __data.peopleNumOfRoom .. "/" .. __data.capityPeopleNumOfRoom
end

function CreateRoomManager:findNotEnoughRoomCardString( ... )
	return "你的房卡不足，请前往商城购买"
end

function CreateRoomManager:findRoomInfoString( ... )
	return "正在请求房间信息,请稍后^v^!"
end

function CreateRoomManager:findrequestRoomConfigAndInfoErrorString( ... )
	return "请求房间信息出错:"
end

function CreateRoomManager:findingRoomNotExist( ... )
	return "此房间不存在！"
end
function CreateRoomManager:findRoomCreateSuccessString( ... )
	return "已成功创建房间,房间号:"
end
cc.exports.lib.singleInstance:bind(CreateRoomManager)
cc.exports.lobby.CreateRoomManager = CreateRoomManager
return CreateRoomManager
