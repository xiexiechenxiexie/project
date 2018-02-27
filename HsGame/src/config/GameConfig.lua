--[[--
@author fly
]]
local GameIDConfig = {
	BRNN = 2, --百人牛牛
	KPQZ = 1, --  看牌强庄 牛牛
	PSZ  = 3, -- 拼三张  炸金花
	HHDZ = 1004  --红黑大战  
}

local GameModelName = {
	[GameIDConfig.BRNN] = "brnn", --百人牛牛
	[GameIDConfig.KPQZ] = "niuniu", --  看牌强庄 牛牛
	[GameIDConfig.PSZ]  = "psz", -- 拼三张  炸金花
	[GameIDConfig.HHDZ] = "hhdz"  --红黑大战  
}

local GameModelNameText = {
	[GameIDConfig.BRNN] = "百人牛牛", --百人牛牛
	[GameIDConfig.KPQZ] = "看牌抢庄", --  看牌抢庄 牛牛
	[GameIDConfig.PSZ]  = "拼三张", -- 拼三张  炸金花
	[GameIDConfig.HHDZ] = "红黑大战"  --红黑大战  
}



local GamePlayConfig = {
	SRF = 2,--私人房
}

local GameType = {
	COIN = 2, --金币场
	SRF = 3,--私人房
}

--游戏集合列表  2 私人房  1 快速开始  2 金币
local GameColllectType = {
   Type_COIN = 2,
   Type_SRF = 3,
   Type_KSKS = 4,
   Type_ZJH = 5,
}

local RobotRange = {
	minUserId = 1,
	maxUserId = 9999999
}



cc.exports.config = cc.exports.config or {}
cc.exports.config.GameIDConfig = GameIDConfig
cc.exports.config.GameModelName = GameModelName
cc.exports.config.GameModelNameText = GameModelNameText
cc.exports.config.GamePlayConfig = GamePlayConfig
cc.exports.config.GameType = GameType
cc.exports.config.GameColllectType = GameColllectType
cc.exports.config.RobotRange = RobotRange