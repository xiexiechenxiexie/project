local Excuter = class("Excuter")
Excuter._executeCall = nil
Excuter._params = nil
function Excuter:ctor( __execute,__params )
	self._executeCall = __execute
	self._params = __params
end

function Excuter:execute( ... )
	self:checkPrams()
	if self._executeCall then 
		self._executeCall(self._params)
	end
end

function Excuter:checkPrams( ... )
	
end

local LaunchExecuter = class("LaunchExecuter",Excuter)
function LaunchExecuter:checkPrams( ... )

end 


local EnterPreGameRoomExecuter = class("LaunchExecuter",Excuter)
function EnterPreGameRoomExecuter:checkPrams( ... )

end 


cc.exports.lobby = cc.exports.lobby or {}
require "GamePlayManager"
local LobbyGameEnterManager = class("LobbyGameEnterManager")
local GameIdConfig = cc.exports.config.GameIDConfig
LobbyGameEnterManager.BRNN = GameIdConfig.BRNN--百人牛牛
LobbyGameEnterManager.KPQZ = GameIdConfig.KPQZ --看牌强庄 --牛牛
LobbyGameEnterManager.PSZ = GameIdConfig.PSZ --拼三张  扎金花
LobbyGameEnterManager.HHDZ = GameIdConfig.HHDZ --红黑大战 

LobbyGameEnterManager.TEST = false

LobbyGameEnterManager._downloadFinishCallback = nil
LobbyGameEnterManager._gameListCache = {}
LobbyGameEnterManager._rspCacheData = nil

LobbyGameEnterManager._requestGameListCallBack = nil 
LobbyGameEnterManager._ksksGameList = nil  --快速开始列表

LobbyGameEnterManager._showGameList = nil --游戏展示列表 金幣長列表
LobbyGameEnterManager._srfGameIdList = nil  --私人房列表

LobbyGameEnterManager._gameInfoCache = nil
LobbyGameEnterManager._selectGameId = nil--玩家选择的游戏
LobbyGameEnterManager._executer = nil

function LobbyGameEnterManager:ctor( ... )
    self:addEvents()
end

function LobbyGameEnterManager:requestGameList( __callback)
	if self.TEST then
		self:_onGameListCallback()
		__callback()
		return
	end
	self._requestGameListCallBack = __callback
	local config = cc.exports.config
	local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_GAME_LIST
	cc.exports.HttpClient:getInstance():get(url,handler(self,self._onGameListCallback))
end

function LobbyGameEnterManager:_onGameListCallback( __error,__respObj )
	--todo:响应不完整  私人房列表展示type = 2  快速开始 type = 1 游戏 type = 0
	-- 有私人房的一定有金币场面？？？
	-- print("_onGameListCallback",__respObj[1].Name)

	dump(__respObj)
	if self._gameInfoCache == nil then
		self._gameInfoCache = {}
	end


	self._showGameList = {}
	self._ksksGameList  = {}
	self._srfGameIdList = {}

	-- add by tangwen
	-- GameListData.setData(__respObj)
	local GameType = config.GameType
	local GameColllectType = config.GameColllectType
	if __respObj.status == 200  then
		for i,v in ipairs(__respObj.data) do
			-- --游戏集合列表  2 私人房  1 快速开始  0 NONE
			-- local GameColllectType = {
			--    Type_SRF = 2,
			--    Type_KSKS = 1,
			--    Type_Game = 0
			-- }
			local typeValue = tonumber(v.gameType)
			if typeValue ~= GameColllectType.Type_KSKS and typeValue ~= GameColllectType.Type_SRF then 
				self._showGameList[#self._showGameList+ 1] = v
				-- local hotUpdateManager = lib.download.HotUpdateManager
				if not self._gameListCache then 
					self._gameListCache = {}
				end

				local updateInfo = {}
				local gameId = v.gameId
				-- updateInfo.isUpdate = hotUpdateManager:isGameModelNeedToUpadte(gameId)
				-- updateInfo.isNeedDownload  = hotUpdateManager:isGameNeedWholePkgDownload(gameId)
				-- updateInfo.isEnablePlay = (v.Status  == 1)--1 完成 0未完成
				updateInfo.isUpdate = false
				updateInfo.isNeedDownload  = false
				updateInfo.isEnablePlay = true--1 完成 0未完成
				
				self._gameListCache[gameId] = updateInfo
				print("dump(updateInfo)")
				dump(updateInfo)

			end

			if typeValue == GameColllectType.Type_KSKS then self._ksksGameList[#self._ksksGameList + 1] = v end
			if typeValue == GameColllectType.Type_SRF then self._srfGameIdList[#self._srfGameIdList + 1] = v end

			-- if typeValue == GameColllectType.Type_SRF then self._srfGameIdList = v.GameList end
			
		end

		local gameArr = {self._showGameList,self._ksksGameList,self._srfGameIdList}
		for i,list in ipairs(gameArr) do
			for i,info in ipairs(list) do
					local key =  info.gameId .. "_" .. info.gameType
					self._gameInfoCache[key] = info
			end
		end

		if self._requestGameListCallBack then self._requestGameListCallBack() end

     	local event = cc.EventCustom:new(config.EventConfig.EVENT_GAME_LIST_REFRESH)
		lib.EventUtils.dispatch(event)	
		GameListData.setProvider(self) --该模块属于多余 后续去掉
	else
		print("游戏列表请求错误",dump(__error))
	end
end



function LobbyGameEnterManager:findKSKSGameId( __index )
	--todo:快速开始游戏id
	__index = __index or 1
	return self._ksksGameList[__index].gameId
end

function LobbyGameEnterManager:findKSKSGameData( __index )
	__index = __index or 1
	return self._ksksGameList[__index]
end

--[[--
查找房间信息
]]
function LobbyGameEnterManager:findGameServerInfo( __gameId,__gameType )
	local key = __gameId .. "_" .. __gameType
	return self._gameInfoCache[key]
end

--获取金币场游戏列表
function LobbyGameEnterManager:findShowGameList( ... )
	return self._showGameList 
end

--金币场游戏查找
function LobbyGameEnterManager:findCoinGameData( __gameId,__playType)
	return self:findGameServerInfo(__gameId,config.GameType.COIN)
end

--查找私人房列表
function LobbyGameEnterManager:findSRFGameList( ... )
	return self._srfGameIdList
end

--私人房游戏查找
function LobbyGameEnterManager:findSRFGameData( __gameId )
	return self:findGameServerInfo(__gameId,config.GameType.SRF)
end


function LobbyGameEnterManager:findSRFGameId(__index )
	__index = __index or 1
	print("findSRFGameId",__index)
	if self._srfGameIdList[__index] then return self._srfGameIdList[__index].gameId end
	return 0
end


function LobbyGameEnterManager:setSelectGameId( __selectGameId )
	self._selectGameId = __selectGameId
end

function LobbyGameEnterManager:findSelectedGameId( ... )
	return self._selectGameId
end


function LobbyGameEnterManager:isGameEnablePlay( __gameId )
	return  (self._gameListCache[__gameId] and self._gameListCache[__gameId].isEnablePlay) or false
end

function LobbyGameEnterManager:isNeedToSelectPlayScene( __gameId )
	
	return (__gameId == config.GameIDConfig.KPQZ) or (__gameId == config.GameIDConfig.PSZ)
end



--[[--
版本检测
]]
function LobbyGameEnterManager:isGameNeedUpdate( __gameId )
	return (self._gameListCache[__gameId] and self._gameListCache[__gameId].isUpdate) or false
end

function LobbyGameEnterManager:isGameNeedDownload( __gameId )
	return (self._gameListCache[__gameId] and self._gameListCache[__gameId].isNeedDownload) or false
end

function LobbyGameEnterManager:download( __gameId ,__callback)
	self._downloadFinishCallback = __callback
	--todo:先走流程
	self:dowloadFinish(__gameId)

end
function LobbyGameEnterManager:addEvents( ... )
	local listeners = {
		lib.EventUtils.createEventCustomListener(lib.download.HotUpdateManager.EVENT_UPDATE_SUCCESS,handler(self,self.onUpdateSuccessCallback)),
		lib.EventUtils.createEventCustomListener(lib.download.HotUpdateManager.EVENT_UPDATE_ERROR,handler(self,self.onUpdateErrorCallback)),
		lib.EventUtils.createEventCustomListener(lib.download.HotUpdateManager.EVENT_UPDATE_PROGRESS,handler(self,self.onUpdateProfressCallback)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_TASK_GOTO_GAME_SCENE,handler(self,self.onEnterGameEventCallback)),
	}
	lib.EventUtils.registeAllListeners(self,listeners)
end
function LobbyGameEnterManager:onDestory( ... )
	lib.EventUtils.removeAllListeners(self)
end

function LobbyGameEnterManager:update( __gameId,__callback)
	if not self._hotNodeCache then 
		self._hotNodeCache = {}
	end
	if not self._hotNodeCache[__gameId] then 
		self._downloadFinishCallback = __callback

		local hot = lib.download.HotUpdateManager.new(__gameId,nil)
		local scene = cc.Director:getInstance():getRunningScene()
		scene:addChild(hot)

		self._hotNodeCache[__gameId] =  hot
		hot:checkUpdate()
	else
		print("已经在下载中")
		GameUtils.showMsg("正在下载中,请稍后")
	end
end

function LobbyGameEnterManager:tryReUpdate( __gameId,__callback)
	if self._hotNodeCache and self._hotNodeCache[__gameId] then self._hotNodeCache[__gameId]:tryReDownload() end
end


function LobbyGameEnterManager:onUpdateProfressCallback( __event )
	local data = {
		gameId = __event.userdata.gameId,
		percent = __event.userdata.percent,
		errMsg = nil,
	}
	self._downloadFinishCallback(data)
end

function LobbyGameEnterManager:onUpdateSuccessCallback( __event )
	local data = {
		gameId = __event.userdata.gameId,
		percent = 100,
		errMsg = nil
	}
	self._downloadFinishCallback(data)
end



function LobbyGameEnterManager:onUpdateErrorCallback( __event )
	local data = {
		gameId = __event.userdata.gameId,
		percent = 0,
		errMsg = "update error"
	}
	local hot = self._hotNodeCache[__gameId]
	self._downloadFinishCallback(data)
end

function LobbyGameEnterManager:enterPlays( __gameId )
	local LobbyPlayView = require "LobbyPlayView"
	assert(LobbyPlayView,"invalid LobbyPlayView please make sure it exsit")
	local view  = LobbyPlayView.create()
	cc.Director:getInstance():getRunningScene():addChild(view)
end

function LobbyGameEnterManager:onEnterGameEventCallback(__event )
	local userdata = __event.userdata
	if userdata then 
		local gameId = userdata.gameId
		local gameType = userdata.gameType
		if gameType and gameId and (gameType == config.GameType.COIN or gameType == config.GameType.SRF) and config.GameIDConfig.BRNN ~= gameId   then 
			self:setSelectGameId(gameId)
			self:enterPlays(gameId)
		elseif gameId and config.GameIDConfig.BRNN == gameId then 
			logic.LobbyTableManager:getInstance():RequestQuickJoinTable()
		else
			print("invalid gameId or gameType gameId:",gameId,"gameType",gameType)
		end

	end
end

function LobbyGameEnterManager:isDoingEnterGameRoom( ... )
	return self._executer
end

--[[--

]]

function LobbyGameEnterManager:finishDownload( __gameId )
	if self._gameListCache[__gameId]  then
		self._gameListCache[__gameId].isUpdate = false
		self._gameListCache[__gameId].isNeedDownload = false
	end
	if self._executer then 
		self._executer:execute() 
		self._executer = nil	
	end
end

--[[--
通向游戏的管道,邀请好友 断线重连 入口请求
]]
function LobbyGameEnterManager:pipelToEnterGame( __gameId,__roomId )
	print("通向游戏的管道,邀请好友 断线重连 入口请求",__gameId,__roomId)
	self:requestGameList(function ( ... )
		print("self._gameListCache")
		dump(self._gameListCache)
	    if self._gameListCache[__gameId].isUpdate or self._gameListCache[__gameId].isNeedDownload then 
	     	local event = cc.EventCustom:new(config.EventConfig.PIPLE_TO_ENTER_GAME)
	     	event.userdata = {
	     		gameId = __gameId,
	     		roomId = __roomId
	     	}
			lib.EventUtils.dispatch(event)	
			print("发出进入游戏命令")
		else
			if self._executer then 
				self._executer:execute()
				self._executer = nil
			end
			print("直接进入游戏命令")
		end
	end)
	
end

function LobbyGameEnterManager:launchAppToEnterPreGameRoom()
	print("LobbyGameEnterManager:launchAppToEnterPreGameRoom",GameData.GameID,config.GameType.COIN,UserData.LastGameRoomType,UserData.LastGameID)
	self:setSelectGameId(GameData.GameID)
	if config.GameType.COIN == UserData.LastGameRoomType and UserData.LastGameID > 0 then
	print("1111111",GameData.GameIP,GameData.GamePort) 
        lobby.GamePlayManager:getInstance():requestGamePlayList(UserData.LastGameID,function ( ... )
        	lobby.GamePlayManager:getInstance():setSelectItemByServerPortAndServerIP(GameData.GameIP ,GameData.GamePort)
        	logic.LobbyManager:getInstance():LoginGameServer()
        end)
    else
		logic.LobbyManager:getInstance():LoginGameServer()
    end
end

--[[--
私人房 启动进入房间
]]
function LobbyGameEnterManager:launchAppToEnterInviteGameRoom( __params )
	local gameId = __params.gameId
	local roomId = __params.roomId
	self:setSelectGameId(gameId )
	lobby.CreateRoomManager:getInstance():requestRoomInfo(roomId,function ( __info )
		dump(__info)
		dump(__info.data)
		GameData.GameID = gameId
		GameData.GameIP = __info.data.server_ip
		GameData.GamePort = __info.data.server_port
		GameData.TableID = roomId
		GameData.writeTableID= roomId
		GameData.GameType = config.GameType.SRF
		GameData.IntoGameType = ConstantsData.IntoGameType.PRIVATE_JOIN_TABLE_TYPE
    	logic.LobbyManager:getInstance():LoginGameServer()
	end)
end


--[[--
断线重连
]]
function LobbyGameEnterManager:needEnterPreGameRoom()
	GameData.TableID = UserData.LastTableID
	GameData.GameID = UserData.LastGameID
    GameData.GameIP = UserData.LastGameIP
	GameData.GamePort = UserData.LastGamePort
	GameData.GameType = UserData.LastGameRoomType
	if UserData.LastTableID ~= 0 then --断线重连
		GameUtils.startLoadingForever("拼命进入上次掉线房间...")
		self._executer = EnterPreGameRoomExecuter.new(handler(self,self.launchAppToEnterPreGameRoom))
		print("走断线重连",UserData.LastGameID,UserData.LastTableID)
		self:pipelToEnterGame(UserData.LastGameID,UserData.LastTableID)
		GameUtils.startLoadingForever("拼命进入上次掉线房间...")
		return true
	end
	return false
end

function LobbyGameEnterManager:needToEnterInviteGameRoom(  )
	print("LobbyGameEnterManager:needToEnterInviteGameRoom")
	local task = manager.launchTaskManager:launch()
	dump(task)
	if  task then 
		GameUtils.startLoadingForever("拼命进入邀请的房间...")
		UserData.LastTableID = 0
		UserData.LastGameID = 0
		UserData.LastGameIP = ""
		UserData.LastGamePort = ""
		UserData.LastGameRoomType = -1
		self._executer = LaunchExecuter.new(handler(self,self.launchAppToEnterInviteGameRoom),{gameId = task.gameId,roomId = task.roomId})
		print("task.roomId",task.roomId,"task.gameId",task.gameId)
		self:pipelToEnterGame(task.gameId,task.roomId)
		
		return true
	end
	return false
end

cc.exports.lib.singleInstance:bind(LobbyGameEnterManager)
cc.exports.lobby.LobbyGameEnterManager = LobbyGameEnterManager
return LobbyGameEnterManager