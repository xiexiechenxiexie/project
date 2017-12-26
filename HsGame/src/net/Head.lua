local headerFile = {}



-----------------------牛牛 begin---------------------------------

-- 服务端返回客户端ID
headerFile.S2C_EnumKeyAction = 
{
	S2C_GAME_START = 300020,      -- 游戏开始
	S2C_GAME_MULTIPLE = 300021,   -- 玩家抢庄倍数
	S2C_GAME_BANKER = 300022,     -- 发送庄家用户ID 
	S2C_GAME_BRTTING = 300023,    -- 玩家下注倍数
	
	S2C_GAME_BRTTINGEND = 300024, -- 下注结束，发送最后一张扑克
	S2C_GAME_SHOWCARD = 300025,   -- 玩家摊牌
	S2C_GAME_END = 300026,	      -- 游戏结束，单局结算
	S2C_USER_READY = 300027,	  -- 总局结算
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
	C2S_PLAYER_SIT = 300004,			-- 坐下
}
-- 服务端返回客户端ID(金币牛牛)
headerFile.S2C_EnumKeyActionGold = 
{
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
}
-----------------------牛牛 end---------------------------------















-------------------------百人牛牛 beigin-------------------------------
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
	S2C_TABLE_INFO 	= 300010,		--桌子信息
}
--客户端
headerFile.C2S_EnumKeyAction = 
{
	C2S_GAME_XIAZHU = 400001,       -- 下注
	C2S_GAME_ZHUANG = 400002, 		-- 上庄
	C2S_GAME_SIT 	= 400003, 		-- 坐下
}
-------------------------百人牛牛 end-------------------------------














-- 客户端连接服务端
headFile.C2S_EnumKeyAction = {
	C2S_APPLY_LOGIN = 100001,   --  登陆
	C2S_APPLY_CREATE_TABLE = 100002,    --  创建房间
	C2S_APPLY_JOIN_TABLE = 100003,       --  加入房间
	C2S_APPLY_LEAVE_TABLE = 100004,      --  离开房间
	C2S_TABLE_INFO = 100005,             --  桌子的所有数据
	C2S_REMOVE_TABLE = 100006,           --  销毁桌子
	C2S_APPLY_DISSOLUTION = 100007,    	--  申请解散
	C2S_DISSOLUTION_ACTION = 100008, 	--  解散的行为（同意，拒绝）
	C2S_DISSOLUTION_RESULT = 100009,  	--  解散的结果
	C2S_NETWORK_ERR	= 100010,            --  网络错误
	C2S_IS_ONLINE = 100011,              --  在线，离线
	C2S_HEAT_JUMP = 100012,              --  心跳
	C2S_QUICK_JOIN = 100013,             --  快速加入
	C2S_CHAT_TEXT = 100014,				--  聊天文本
 	C2S_CHAT_BROW = 100015,				--  聊天表情
 	C2S_CHAT_TALK= 100016,				--  聊天语音
 	C2S_THROW_PROPERTY = 100017, 	    -- 道具

 	C2S_PLAYER_CHANGE_TABLE = 110001, 	-- 换座位
 	C2S_BANKRUPT = 110002,				-- 破产补助
 	C2S_PLAYER_BANKRUPT_SUCCEED = 110003,-- 领取成功

 	C2S_SEND_CHAT = 120001,			--发送聊天
}

-- 服务端返回客户端ID
headFile.S2C_EnumKeyAction = {
	S2C_APPLY_LOGIN = 200001,   --  登陆
	S2C_APPLY_CREATE_TABLE = 200002,    --  创建房间
	S2C_APPLY_JOIN_TABLE = 200003,       --  加入房间
	S2C_APPLY_LEAVE_TABLE = 200004,      --  离开房间
	S2C_TABLE_INFO = 200005,             --  桌子的所有数据
	S2C_REMOVE_TABLE = 200006,           --  销毁桌子
	S2C_APPLY_DISSOLUTION = 200007,    	--  申请解散
	S2C_DISSOLUTION_ACTION = 200008, 	--  解散的行为（同意，拒绝）
	S2C_DISSOLUTION_RESULT = 200009,  	--  解散的结果
	S2C_NETWORK_ERR	= 200010,            --  网络错误
	S2C_IS_ONLINE = 200011,              --  在线，离线
	S2C_HEAT_JUMP = 200012,              --  心跳
	S2C_QUICK_JOIN = 200013,             --  快速加入
	S2C_CHAT_TEXT = 200014,				--  聊天文本
 	S2C_CHAT_BROW = 200015,				--  聊天表情
 	S2C_CHAT_TALK= 200016,				--  聊天语音
 	S2C_THROW_PROPERTY = 200017, 	    -- 道具

 	S2C_PLAYER_CHANGE_TABLE = 210001, 	-- 换座位
 	S2C_BANKRUPT = 210002,				-- 破产补助
 	S2C_PLAYER_BANKRUPT_SUCCEED = 210003,-- 领取成功

 	S2C_SEND_CHAT = 220001,				--好友聊天消息
}

