-- 游戏资源路径和管理器路径
-- @date 2017.09.06
-- @author tangwen

local GamePathResConfig = class("GamePathResConfig")

GamePathResConfig.GamePathRes = 
{
	{gameID = 1001, name = "niuniu", PrivateSceneRes = "game/niuniu/src/scene/GameScene", 
	ManagerRes = "game/niuniu/src/logic/GameManager",GoldSceneRes = "game/niuniu/src/scene/goldNiuScene",
	resPath = "src/game/niuniu/res"},
 	{gameID = 1002, name = "brnn", GoldSceneRes = "game/brnn/src/scene/GameScene", ManagerRes = "game/brnn/src/logic/GameManager",resPath = "src/game/brnn/res"}
} 

GamePathResConfig.GameCommonResPath = "src/gamecommon"

function GamePathResConfig:getGameManagerPathRes()
	for k,v in pairs(self.GamePathRes) do
		if v.gameID == GameData.GameID then
			return v.ManagerRes
		end
	end
end

-- 获取游戏资源路径
function GamePathResConfig:getGameResourcePath( __gameID )
	for k,v in pairs(self.GamePathRes) do
		if v.gameID == __gameID then
			return v.resPath
		end
	end
end

-- 获取游戏公共资源路径
function GamePathResConfig:getGameCommonResourcePath()
	return GamePathResConfig.GameCommonResPath
end

function GamePathResConfig:getGoldGameSceneResPathRes()
	for k,v in pairs(self.GamePathRes) do
		if v.gameID == GameData.GameID then
			return v.GoldSceneRes
		end
	end
end

function GamePathResConfig:getPrivateGameSceneResPathRes()
	for k,v in pairs(self.GamePathRes) do
		if v.gameID == GameData.GameID then
			return v.PrivateSceneRes
		end
	end
end

cc.exports.config.GamePathResConfig = GamePathResConfig.create()
