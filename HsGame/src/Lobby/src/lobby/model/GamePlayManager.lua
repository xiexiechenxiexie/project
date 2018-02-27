--[[--
@author fly 
]]

local GamePlayModel = class("GamePlayModel")
GamePlayModel.playType  = 1--场次类型
GamePlayModel.name = "--"
GamePlayModel.floorScore  = 50--场次类型
GamePlayModel.minEnterCoinNum  = 10000--场次最低准入金币数量
GamePlayModel.maxEnterCoinNum = 99999--场次最高准入金币数量
GamePlayModel.onlineNum = 200--在线人数
GamePlayModel.fee = 0
GamePlayModel.serverIp = nil
GamePlayModel.serverPort = nil
GamePlayModel.res = {
	imgItemBg = "",imgFloorScore="",imgStar = ""
}


function GamePlayModel:ctor(__params)
	print(__params)
	if __params.rule then
		local ruleData = lib.JsonUtil:decode(__params.rule)
		self.floorScore = ruleData.base or 0
		self.way = ruleData.way or 0 --1 手动算牛 0自动
	end
	self.level = __params.level or 0 --等级
	self.playType = __params.deskset_id or 1 --场次类型
	self.name = __params.name or "私人房"
	self.minEnterCoinNum = __params.minBet or 0--场次最低准入金币数量
	self.maxEnterCoinNum = __params.maxBet or 0--场次最高准入金币数量
	self.onlineNum = __params.onlineNumber or 0--在线人数 
	self.serverIp = __params.serverIp
	self.serverPort = __params.serverPort
	self.fee = __params.fee
	self.res = {imgItemBg = config.ServerConfig:findResDomain() .. (__params.logo_url or "")
	,imgFloorScore=config.ServerConfig:findResDomain() ..(__params.score_url or "")
	,imgStar = config.ServerConfig:findResDomain() ..(__params.gif_url or "")} 
	print(self.res.imgItemBg,self.res.imgFloorScore,self.res.imgStar)
end


local GamePlayManager = class("GamePlayManager")
GamePlayManager.TEST = false

GamePlayManager._listCache = {}

function GamePlayManager:ctor( ... )
	self._listCache = {}
	if self.TEST then
		self:_initTest()
	else
		local resArr = {
			{imgItemBg = "LobbyPlaySRF.png",imgStar = "LobbyPlaySRFAct.png"},
			{imgItemBg = "LobbyPlayXS.png",imgFloorScore="LobbyPlayXSScore.png",imgStar = "LobbyPlayXSAct.png"},
			{imgItemBg = "LobbyPlayJY.png",imgFloorScore="LobbyPlayJYScore.png",imgStar = "LobbyPlayJYAct.png"},
			{imgItemBg = "LobbyPlayDS.png",imgFloorScore="LobbyPlayDSScore.png",imgStar = "LobbyPlayDSAct.png"},
		}	
	end
end

function GamePlayManager:findGamePlayList( ... )
	return self._listCache
end

function GamePlayManager:requestGamePlayList( __gameId,__callback )
	print("GamePlayManager:requestGamePlayList",lobby.LobbyGameEnterManager:getInstance():findSelectedGameId())
	local gameId = lobby.LobbyGameEnterManager:getInstance():findSelectedGameId()
	local url = config.ServerConfig:findModelDomain()..config.ApiConfig.REQUEST_GAME_PLAY_LIST..gameId.."?token="..UserData.token
	HttpClient:getInstance():get(url,function ( __errorMsg,__reponse )
		dump(__reponse)
		if not __errorMsg then
			local model = GamePlayModel:create({deskset_id = config.GamePlayConfig.SRF})
			model.res = {imgItemBg = "LobbyPlaySRF.png",imgStar = "LobbyPlaySRFAct.png"}
			if not manager.UserManager:getInstance():findAppCloseRoomCardFlag() then 
				self._listCache = {[1] = model}	
			end
			if __reponse.data and #__reponse.data > 0 then
				
				 for _,set in ipairs(__reponse.data) do
				 	self._listCache[#self._listCache + 1] = GamePlayModel:create(set)
				 end
			end
     		local event = cc.EventCustom:new(config.EventConfig.EVENT_REFRESH_GAME_PLAYS)
     		event.userdata = self._listCache
			lib.EventUtils.dispatch(event)	
			print("dispatch")
			if __callback then __callback(nil) end
		else
			print("__errorMsg",__errorMsg)
			if __callback then __callback(__errorMsg) end
		end
	end)
end


function GamePlayManager:_initTest( ... )
	local config = cc.exports.config.GamePlayConfig
	local wan = 10000
	self._listCache[config.SRF] = GamePlayModel.new({
			playType = config.SRF,
			res = {
				imgItemBg = "LobbyPlaySRF.png",imgStar = "LobbyPlaySRFAct.png"
			}
		})
	self._listCache[config.XS] = GamePlayModel.new({
			playType = config.XS,
			floorScore = 50,
			minEnterCoinNum = 3 * wan,
			maxEnterCoinNum = 5 * wan,
			res = {
				imgItemBg = "LobbyPlayXS.png",imgFloorScore="LobbyPlayXSScore.png",imgStar = "LobbyPlayXSAct.png"
			}
		})
	self._listCache[config.JY] = GamePlayModel.new({
			playType = config.JY,
			floorScore = 100,
			minEnterCoinNum = 5 * wan,
			maxEnterCoinNum = 10 * wan,
			res = {
				imgItemBg = "LobbyPlayJY.png",imgFloorScore="LobbyPlayJYScore.png",imgStar = "LobbyPlayJYAct.png"
			}			
		})
	self._listCache[config.DS] = GamePlayModel.new({
			playType = config.DS,
			floorScore = 99999,
			minEnterCoinNum = 10 * wan,
			maxEnterCoinNum = 50 * wan,
			res = {
				imgItemBg = "LobbyPlayDS.png",imgFloorScore="LobbyPlayDSScore.png",imgStar = "LobbyPlayDSAct.png"
			}
	})

	self._listCache[config.ZJ] = GamePlayModel.new({
			playType = config.ZJ,
			floorScore = 99999,
			minEnterCoinNum = 10 * wan,
			maxEnterCoinNum = 50 * wan,
			res = {
				imgItemBg = "http://192.168.1.213:8086/6.png",imgFloorScore="http://192.168.1.213:8086/12.png",imgStar = "http://192.168.1.213:8086/3.png"
			}
	})
end


function GamePlayManager:enterPalys( __playType )
	local gameId = lobby.LobbyGameEnterManager:getInstance():findSelectedGameId()
	--local gameData = lobby.LobbyGameEnterManager:getInstance():findCoinGameData(gameId,__playType)
	local itemData = self:findItemDataByPlayType(__playType)
    -- gameData.GameId
    -- gameData.ServerIp 
    -- gameData.ServerPort
	--todo:根据场次进入游戏.
	local gameId = gameId
	local gameIp = itemData.serverIp
	local port = itemData.serverPort
	local playType = __playType
	
	logic.LobbyTableManager:getInstance():RequestGoldJoinTable(gameId,gameIp,port,playType)
end

function GamePlayManager:setSelectItemByServerPortAndServerIP( __serverIp,__serverPort )
	for i=2,#self._listCache do
		local item = self._listCache[i]
		if item.serverIp == __serverIp  and item.serverPort ==__serverPort then
			self:setSelectItemData(item)
		end
	end
end

function GamePlayManager:autoEnterPlays( ... )
	-- self._listCache[#self._listCache + 1] = GamePlayModel:create(set)
	if not self._listCache then return false end
	if #self._listCache then 
		local maxMinCoin = 0
		for i=2,#self._listCache do
			
			local item = self._listCache[i]
			if maxMinCoin < item.minEnterCoinNum and UserData.coins >= item.minEnterCoinNum then 
				maxMinCoin = item.minEnterCoinNum
			end
		end
		print("maxMinCoin",maxMinCoin)
		for i=2,#self._listCache do
			local item = self._listCache[i]
			

			if UserData.coins >= item.minEnterCoinNum and (UserData.coins <= item.maxEnterCoinNum or item.maxEnterCoinNum < 0 ) then 
				print(maxMinCoin , item.minEnterCoinNum)
				if item.minEnterCoinNum == maxMinCoin then 
					dump(item)
					self:setSelectItemData(item)
					return true
				end
			end
		end
	end
	return false
end

-- GamePlayModel.minEnterCoinNum  = 10000--场次最低准入金币数量
-- GamePlayModel.maxEnterCoinNum = 99999--场次最高准入金币数量
function GamePlayManager:enableEnterGame( __itemData )
	print(__itemData.minEnterCoinNum,UserData.coins)
	dump(__itemData)
	return (UserData.coins <= __itemData.maxEnterCoinNum or __itemData.maxEnterCoinNum < 0 ) and UserData.coins >= __itemData.minEnterCoinNum 
end

function GamePlayManager:isCoinEnough( __itemData )
	return UserData.coins >= __itemData.minEnterCoinNum 
end

function GamePlayManager:enableUpperEnterGame( __itemData )
	if __itemData.maxEnterCoinNum < 0 then 
		return false
	end
	--符合该场次范围不去更高级的场次
	if __itemData.minEnterCoinNum <= UserData.coins and __itemData.maxEnterCoinNum >= UserData.coins then 
		return false
	end
	--不在该场次范围内  
	for _,info in ipairs(self._listCache) do
		if info.maxEnterCoinNum < 0 then 
			--无上限在下线之上  符合
			if UserData.coins >=  info.minEnterCoinNum  then
				return true
			end
		else
			--有更高场次的  并且玩家符合  
			if info.maxEnterCoinNum > __itemData.maxEnterCoinNum and  UserData.coins >=  info.minEnterCoinNum and UserData.coins < info.maxEnterCoinNum   then
				return true
			end
		end

	end
	return false
end

function GamePlayManager:setSelectItemData( __itemData )
	self._selectItemData = __itemData
end

function GamePlayManager:findSelectItemData( ... )
	return self._selectItemData
end

function GamePlayManager:findItemDataByPlayType( __playType )
 for _,info in ipairs(self._listCache) do
  if info.playType == __playType then 
   return info
  end
 end
end

function GamePlayManager:findEnterConditionString( __minNum,__maxNum )
	print("GamePlayManager:findEnterConditionString",__minNum,__maxNum)
	local stringDesc = "准入:%s~%s"
	if __maxNum < 0 then 
		return string.format("准入:%s以上",self:findNumUnitText(__minNum))
	end
	return string.format(stringDesc,self:findNumUnitText(__minNum),self:findNumUnitText(__maxNum))
end

function GamePlayManager:findNumUnitText( __num )
	__num = __num or 0
	if __num < 0 then
		__num = 0
	elseif __num > 100000000 then
		__num =  math.floor(__num / 100000000)
		return __num .. "亿"	
	elseif __num > 10000 then
		__num = math.floor(__num / 10000)	
		return __num .. "万"
	end
	return tostring(__num)
end

function GamePlayManager:findSRFString( ... )
	return "私人房"
end

function GamePlayManager:findNoPlaysSelectString( ... )
	return "没有房间可以进入!!!"
end

function GamePlayManager:notBetween( ... )
	return "不符合进入条件!"
end

cc.exports.lib.singleInstance:bind(GamePlayManager)
cc.exports.lobby.GamePlayManager = GamePlayManager
return GamePlayManager