-------------------------------------------------
--子游戏消息协议
-------------------------------------------------

local headerFile = {}

--服务器
headerFile.S2C_EnumKeyAction = 
{
	S2C_ACTION_ERR 	= 300000,      	--错误提示
	S2C_FREE_TIME 	= 300001,	   	--空闲时间
	S2C_BET_STRAT 	= 300002, 	  	--开始下注
	S2C_BETING 		= 300003,		--下注中
	S2C_BET_END 	= 300004,		--下注结束
	S2C_SEND_CARD 	= 300005,		--发牌
	S2C_SETTLEMENT 	= 300006,		--结算
	S2C_CALL_BANKER = 300007,		--上庄
	S2C_SEAT 		= 300008,		--坐下
	S2C_PLAYER_LIST = 300009,		--玩家列表
	S2C_SCORE_LIST 	= 300010,		--玩家购买金币成功
}
--客户端
headerFile.C2S_EnumKeyAction = 
{
	C2S_GAME_XIAZHU = 400001,       -- 下注
	C2S_GAME_ZHUANG = 400002, 		-- 上庄
	C2S_GAME_SIT 	= 400003, 		-- 坐下
}

return headerFile

-- S2C_FREE_TIME, // 空闲时间
-- S2C_BET_STRAT, // 开始下注
-- S2C_BET_END,   // 下注结束



-- pkt << (uint32)S2C_BETING; // 下注中
-- pkt << (uint32)betIndex;   // 筹码索引
-- pkt << (uint32)_area;      // 区域

-- S2C_SEND_CARD,
-- 25张牌 uint32
-- 5牌型 uint32
-- 5倍数 uint32

-- 下注
-- 我要上庄
-- 我要坐下




-- S2C_SETTLEMENT

-- 四个区域下注 32
-- 四个区域输赢  32