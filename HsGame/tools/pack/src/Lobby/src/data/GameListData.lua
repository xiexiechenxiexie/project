-- 游戏常量
-- @author Tangwen
-- @date 2017.7.20


local GameListData = GameListData or {}

function GameListData.reset( ... )

end

function GameListData.setProvider( __provider )
	GameListData._provider = __provider
end

function GameListData.findQuickGameData( ... )
	return GameListData._provider:findKSKSGameData()
end

function GameListData.findSelectGameId( ... )
	return GameListData._provider:findSelectedGameId()
end

function GameListData.getNormalGameData(GameID)
	return GameListData._provider:findCoinGameData(GameID)
end

function GameListData.getPrivateGameData(GameID)
	return GameListData._provider:findSRFGameData(GameID)
end

cc.exports.GameListData = GameListData