-- 通用常量定义
-- @author Tangwen
-- @date 2017.8.4


local ConstantsData = ConstantsData or {}

-- 进入房间的类型
ConstantsData.IntoGameType = {
    PRIVATE_CREATE_TABLE_TYPE         = 0,    -- 私人房创建房间类型
    PRIVATE_JOIN_TABLE_TYPE		      = 1,    -- 私人房加入房间类型 包括断线重连
    LOBBY_QUICK_JOIN_TYPE			  = 2,    -- 大厅快速加入房间
    GOLD_LIST_JOIN_TYPE               = 3,    -- 金币场列表加入
    GOLD_QUICK_JOIN_TYPE              = 4,    -- 金币场快速加入
}

ConstantsData.ServerType = {
    LOBBY_SERVER_TYPE = 1,      -- 大厅服务器
    GAME_SERVER_TYPE = 2,       -- 游戏服务器
}

ConstantsData.SceneType = {
    LOBBY_SCENE_TYPE = 1,      -- 大厅界面
    GAME_SCENE_TYPE = 2,       -- 游戏界面
    LOGIN_SCENE_TYPE = 3,      -- 登陆界面
}


ConstantsData.ShowMgsBoxType = {
    NORMAL_TYPE          	  = 1,    -- 普通模式 显示一行居中的
    BIG_TYPE	      	  	  = 2,    -- 超长模式，显示2 3行
}

ConstantsData.JoinTableCode = {
	ERR_JOIN_TABLE_NORMAL = 0,       -- 正常
 	ERR_JOIN_TABLE_NO_ALLOW = 1,     -- 没有权限(不允许)
 	ERR_JOIN_TABLE_NO_INLIN = 2,     -- 不在线
 	ERR_JOIN_TABLE_FULL_PLAYER = 3,  -- 人数已满
 	ERR_JOIN_TABLE_IN_START = 4,     -- 游戏已经开始
 	ERR_JOIN_TABLE_NOT_FIND = 5,     -- 未找到房间
 	ERR_JOIN_TABLE_NO_UNKNOWN = 6 ,  -- 未知
}

-- 登陆code
ConstantsData.ApplyLoginCode = {
    ERR_APPLY_LOGIN_NORMAL = 0,       -- 正常
    ERR_APPLY_LOGIN_INLIN = 1,     -- 已在线
    ERR_APPLY_LOGIN_NO_PASSWORD = 2,     -- 密码错误
    ERR_APPLY_LOGIN_NO_LOCKING = 3,  -- 锁定
    ERR_APPLY_LOGIN_NO_UNKNOWN = 4,     -- 未知 一般为token错误
}



--离开桌子
ConstantsData.LeaveTableCode =
{
    ERR_LEAVE_TABLE_NORMAL = 0,  -- 正常
    ERR_LEAVE_TABLE_NO_ALLOW = 1,  -- 没有权限(不允许)
    ERR_LEAVE_TABLE_NOT_FIND = 2,  -- 未找到房间
    ERR_LEAVE_TABLE_NO_UNKNOWN = 3,  -- 未知
    ERR_CHANGE_TABLE_NORMAL = 4,    -- 换桌成功
    ERR_LEAVE_TABLE_END
}

ConstantsData.LocalZOrder = {
    DIY_DIALOAG_LAYER = 998, -- 场景添加的弹窗,弹出式layer
    SYSTEM_DIALOAG_LAYER = 999, -- 系统弹窗
}

ConstantsData.SexType = {
    SEX_UNKNOW = 0, --未知
    SEX_MAN = 1, -- 男
    SEX_WOMEN = 2, -- 女
}

ConstantsData.FaceType = {
    FACE_ROSE = 1, --玫瑰花
    FACE_BOMB = 2, --炸弹
    FACE_BUCKET = 3, --水桶
    FACE_TOMATO = 4, -- 西红柿
    FACE_DIANZAN = 5, --点赞
    FACE_TOUJI = 6, -- 偷鸡
    FACE_ZHUAJI = 7, --爪机
    FACE_DRINK = 8, -- 喝酒
    FACE_FISH = 9, -- 钓鱼
    FACE_KISS = 10, --亲吻
}

ConstantsData.NoticeType = {
    NOTICE_SYSTEMEVENT = 1, --系统公告
    NOTICE_HOTEVENT = 2, -- 活动公告
}

ConstantsData.NoticeShowType = {
    NOTICE_NORMAL = 0,  -- 普通的
    NOTICE_NEW = 1,     -- 新的
    NOTICE_HOT = 2,     -- 火热的
}

ConstantsData.PointType = {
    POINT_DIAMOND = 1 ,    --钻石
    POINT_COINS = 2 ,  --金币
    POINT_ROOMCARD = 3,   --房卡
}

ConstantsData.WindowType = {
    WINDOW_BIG = 1,
    WINDOW_MIDDLE = 2,
    WINDOW_SMALL = 3,
}

ConstantsData.SharaIconIndex = {
    QQ = 1, -- QQ 群 好友
    QQ_ZONE = 2, --QQ空间
    WECHAT = 3, --微信群好友
    WECHAT_FRIEND = 4, -- 微信朋友圈
}

ConstantsData.ActionIndexType = {
    ACTION_INDEX_REFUSE = 0,
    ACTION_INDEX_AGREE = 1,
}

ConstantsData.LobbyRedPointType = {
    REDPOINT_MAIL = 1,
    REDPOINT_TASK = 2,
    REDPOINT_FRIEND = 3,
}

ConstantsData.RankType = {
    RANK_RICK = 1, -- 财富榜
    RANK_FRIEND = 2,  -- 好友榜
}

ConstantsData.CalCattleType = {
    TYPE_AUTO = 0,      --自动算牛
    TYPE_MANUAL = 1,    --手动算牛
}

ConstantsData.CloseScoketType = {
    NOMAL_CLOSE = 0, -- 正常关闭socket
    EXCEPTION_COLSE = 1,  -- 异常关闭socket 服务端主动关闭
    ABNORMAL_ACCOUNT_CLOSE = 2,--账号异常
}



cc.exports.ConstantsData = ConstantsData