-------------------------------------------------
--子游戏消息逻辑
-------------------------------------------------

local headerFile = {}
-- 客户端连接服务端
headerFile.C2S_EnumKeyAction = 
{
	C2S_PLAYER_ACTION = 100020,
	C2S_PLAYER_READY = 100021,			-- 玩家准备
	C2S_PLAYER_GAMESTART = 100022,		-- 游戏开始	
	C2S_PLAYER_GRADBANKER =  100023,	-- 抢庄
	C2S_PLAYER_BRTTING = 100024,		-- 下注
	C2S_PLAYER_SWIGN = 100025,			-- 摊牌
}
-- 服务端返回客户端ID
headerFile.S2C_EnumKeyAction = 
{	
	S2C_WAIT_START = 300019,      -- 等待开始
	S2C_GAME_START = 300020,      -- 游戏开始
	S2C_GAME_MULTIPLE = 300021,   -- 玩家抢庄倍数
	S2C_GAME_BANKER = 300022,     -- 发送庄家用户ID 
	S2C_GAME_BRTTING = 300023,    -- 玩家下注倍数
	
	S2C_GAME_BRTTINGEND = 300024, -- 下注结束，发送最后一张扑克
	S2C_GAME_SHOWCARD = 300025,   -- 玩家摊牌
	S2C_GAME_END = 300026,	      -- 游戏结束，单局结算
	S2C_USER_READY = 300027,	  -- 总局结算
	S2C_GAME_ERROR = 300028,      -- 错误信息
	S2C_PLAYER_LIST = 300030,     -- 玩家列表
	S2C_PLAYER_READY = 200021,	  -- 玩家准备
	S2C_JIESAN_RESULT = 300032,	  -- 解散结算
}
-- 客户端连接服务端(金币牛牛)
headerFile.C2S_EnumKeyActionGold = 
{
	C2S_PLAYER_ACTION = 100020,
	C2S_PLAYER_GRADBANKER = 300001,		-- 抢庄
	C2S_PLAYER_BRTTING = 300002,		-- 下注
	C2S_PLAYER_SWIGN = 300003,			-- 摊牌
	C2S_PLAYER_SIT = 300015,			-- 坐下
	C2S_STAND_UP = 300016,				-- 站起
}
-- 服务端返回客户端ID(金币牛牛)
headerFile.S2C_EnumKeyActionGold = 
{
	S2C_ACTION_ERR = 400000,    -- 错误提示
	S2C_START_SET = 400001,     -- 开始
	S2C_FOUR_CARD = 400002,     -- 四张牌
	S2C_GRAP_BANKER = 400003,   -- 抢庄时间
	S2C_GRAP_ING = 400004,      -- 抢庄中
	S2C_SET_BANKER = 400005,    -- 设置庄家
	S2C_BET_STRAT = 400006,     -- 下注开始 
	S2C_BETING = 400007,        -- 下注中
	S2C_SEND_FIVE_CARD = 400008,-- 发第五张牌
	S2C_SHOW_START = 400009,    -- 摊牌开始
	S2C_SHOW_CARD_ING = 400010, -- 亮牌中
	S2C_SHOW_CARD = 400011,     -- 全都摊牌
	S2C_SETTLEMENT = 400012,    -- 结算分数
	S2C_BIG_PACK = 400013, 		-- 大包
	S2C_PLAYER_LIST = 400014,   -- 玩家列表
	S2C_PLAYER_SIT = 400015,	-- 坐下
	S2C_STAND_UP = 400016,		-- 站起

	S2C_PLAYER_SCORE = 400017,		-- 数据同步	
}





return headerFile