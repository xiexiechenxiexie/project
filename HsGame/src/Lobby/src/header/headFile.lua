--[[
    消息头定义
    @Author: tangwen
    @Date: 2017.7.18
]]

local headFile = {}

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
 	C2S_PLAYER_GOLD_LIST = 100018,		-- 购买成功

 	C2S_PLAYER_CHANGE_TABLE = 110001, 	-- 换桌
 	C2S_BANKRUPT = 110002,				-- 破产补助
 	C2S_PLAYER_BANKRUPT_SUCCEED = 110003,-- 领取成功

 	C2S_SEND_CHAT = 120001,			--发送聊天

 	C2S_AUTHORIZE_SIT_APPLY  = 130001, 	    -- 玩家申请入座
 	C2S_AUTHORIZE_ACTION = 130002, 	-- 房主授权入座的行为（同意，拒绝）
 	C2S_AUTHORIZE_SIT_LIST  = 130003, 	    -- 玩家申请入座列表
 	C2S_AUTHORIZE_RESULT  = 130004, 	    -- 授权入座结果

    C2S_SEND_BORADCAST = 140001,    --请求广播 (占位 未使用)

    C2S_REFRESH_USERDATA= 150001,    --请求用户数据 (占位 未使用)

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

 	S2C_PLAYER_CHANGE_TABLE = 210001, 	-- 换桌
 	S2C_BANKRUPT = 210002,				-- 破产补助
 	S2C_PLAYER_BANKRUPT_SUCCEED = 210003,-- 领取成功

 	S2C_SEND_CHAT = 220001,				--好友聊天消息

 	S2C_AUTHORIZE_SIT_APPLY = 230001, 	-- 房主收到授权入座申请
	S2C_AUTHORIZE_ACTION = 230002,  	-- 房主授权入座的行为码结果
	S2C_AUTHORIZE_SIT_LIST  = 230003, 	-- 玩家申请入座列表
	S2C_AUTHORIZE_RESULT  = 230004, 	-- 授权入座结果
	S2C_PAY_RESULT = 230005,            --扣房卡结果

    S2C_SEND_BORADCAST = 240001,        --服务器推送广播

    S2C_REFRESH_USERDATA = 250001,    --请求用户数据 (占位 未使用)
}

return headFile