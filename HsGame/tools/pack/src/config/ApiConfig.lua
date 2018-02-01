--[[--
@author fly
]]

local LoginApiConfig = {
	
	REQUEST_LOGIN_GUEST = "/api/v1/thirdauth/guest",				--游客登录
	REQUEST_LOGIN_WECHAT = "/api/v1/thirdauth/wx/",					--微信登录
	REQUEST_LOGIN_QQ = "/api/v1/thirdauth/qq/",						--QQ登录
	REQUEST_LOGIN_TOKEN = "/api/v1/fetch/",							--token登录
}



local ApiConfig = {
	REQUEST_GAME_LIST = "/api/v1/gameServer/list", --游戏列表请求ok
	REQUEST_TABLE_CONFIG = "/api/v1/room/setting/",--私人场房间配置ok
	REQUEST_CREATE_TABLE = "/api/v1/room/create",--创建房间ok
	REQUEST_GET_ROOM_FINISH = "/api/v1/room/finish/",--已经结束
	REQUEST_GET_ROOM_PLAYING = "/api/v1/room/playing/",  --正在玩ok
	REQUEST_ROOM_HISTORY_DETAIL = "/api/v1/room/historydetail/", --历史详情
	REQUEST_MY_JOIN_ROOM = "/api/v1/room/participate/", --我参与的牌局ok
	REQUEST_RICH_RANK = "/api/v1/app/rank",  -- 财富排行榜ok
	REQUEST_FRIEND_RANK = "/api/v1/friend/rank",  -- 好友排行ok
	REQUEST_GAME_PLAY_LIST = "/api/v1/deskset/",  -- /api/v1/app/deskset/ .. gameId没图片
	REQUEST_SELF_INFO = "/api/v1/profile/self/",	-- 个人信息ok
	REQUEST_PLAYER_INFO = "/api/v1/profile/user/",   	-- 用户信息ok
	REQUEST_PRIVATEROOM_PLAYER_INFO = "/api/v1/profile/inRoom/", -- 正在一个房间玩游戏玩家 ok
	REQUEST_GAME_PLAYER_INFO = "/api/v1/profile/inRoom/", -- 正在一个游戏玩游戏玩家 ok
	REQUEST_REVISE_SELF_INFO = "/api/v1/profile/update",   	-- 修改用户信息ok
	REQUEST_NOTICE = "/api/v1/announcement/list", -- 公告活动ok
	REQUEST_NOTICE_SET = "/api/v1/app/announcement/switch", -- 公告开关
	REQUEST_SIGN_CHECK_IN = "/api/v1/app/checkin/", --签到
	REQUEST_SIGN_SET = "/api/v1/checkIn/isShow", -- 签到开关
	REQUEST_SIGN_INFO = "/api/v1/app/checkinsetting/", -- 签到具体信息
	REQUEST_NOVICES_REWARD_INFO = "/api/v1/app/newbie/setting", -- 新手礼包信息
	REQUEST_NOVICES_REWARD_RECEIVE = "/api/v1/app/newbie/receive/", -- 新手礼包领取
	REQUEST_TASK_INFO = "/api/v1/task/progress", -- 任务信息
	REQUEST_TASK_GET_AWARD = "/api/v1/task/receive/", -- 领取任务奖励

	REQUEST_MANIFESTS_INFO = "/api/v1/app/update",
	
	REQUEST_PROMOTE_INFO = "/api/v1/app/share/setting/", --有奖推送信息
	REQUEST_PROMOTE_MOBILE_CODE = "/api/v1/verifycode/send/", -- 有奖推送手机验证码
	REQUEST_PROMOTE_BINGDING_MOBILE = "/api/v1/verifycode/verify/", --  有奖推送绑定手机
	REQUEST_PROMOTE_BINGDING_INVITE_CODE = "/api/v1/app/distribution/bind/", --  有奖推送绑定推广码
	REQUEST_PROMOTE_SHARE_AWARD = "/api/v1/app/share/award/",
	REQUEST_FRIEND_LIST = "/api/v1/friend/list", --好友列表
	REQUEST_CHECK_FRIEND = "/api/v1/friend/find", --查找好友
	REQUEST_ADD_FRIEND = "/api/v1/friend/apply/", -- 添加好友
	REQUEST_APPLY_FRIEND_LIST = "/api/v1/friend/applyList", --好友申请列表
	REQUEST_REPLY_APPLY_FRIEND = "/api/v1/friend/reply", -- 回复好友申请列表 (同意或者拒绝)
	REQUEST_DELETE_FRIEND = "/api/v1/friend/breakup/", --删除好友

	REPORT_MSG = "/api/v1/app/report/",

	REQUEST_LOBBY_SERVER_INFO = "/api/v1/room/lobby", --大厅游戏服信息
	REQUEST_INVITE_INFO = "/api/v1/app/share/invite/",
	REQUEST_JOIN_ROOM_INFO_WITH_ROOMID = "/api/v1/room/join/",
	REQUEST_REFRESH_USERDATA = "/api/v1/refresh/", -- 更新用户数据
	REQUEST_SHARE_URL = "/api/v1/app/share/config/",-- 没用到
	REQUEST_STORESWITCH = "/api/v1/app/system/storeswitch",--审核开关
	REQUEST_SYSTEM_ZHUANG_HEAD_URL = "/api/v1/app/system/dealer",
	REQUEST_CHECK_STATUS = "/api/v1/app/checkStatus",
}


-- 商城请求API
local MallApiConfig = {
	
	REQUEST_MALL_LIST_DATA = "/api/v1/store/goods/",			--商城列表请求
	REQUEST_MALL_GOODS_ORDER = "/api/v1/store/buy",				--商品订单请求
	REQUEST_MALL_IAP_VERIFY = "/api/v1/store/iapverify",		--苹果支付校验请求
	REQUEST_MALL_PAY_RESULT_VERIFY = "/api/v1/store/checkorder/",		--支付校验请求
	REQUEST_MALL_SERVER_INFO = "/api/v1/app/customerservice/setting" 	--商城客服联系方式
				
}


cc.exports.config.LoginApiConfig = LoginApiConfig
cc.exports.config.ApiConfig = ApiConfig
cc.exports.config.MallApiConfig = MallApiConfig
