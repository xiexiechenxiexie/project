-- 游戏配置及一些设置


local conf = {}

conf.MaxBeiShu=3 		--最大倍数
conf.AllCardNum=25 		--总共的牌数
conf.CardNodeNum=5 		--牌组的数量,首组为庄家扑克
conf.Card_Num=5 		--每组牌数
conf.Card_Size=1 		--牌的大小
conf.Card_X=30 			--牌的间隔
conf.GoldActionTime=6 	--播放发牌金币飞行的秒数
conf.ResultTime=12 	    --播放发牌金币等动画的秒数
--下注随机区域
conf.Rand_X=90
conf.Rand_Y=60
conf.GOLD_NUM=10000 	--金币总数量
conf.QUYU_NUM=4 		--下注区域数量
conf.SIT_NUM=6 			--椅子座位数量
conf.LUDAN_NUM=10 		--路单最大数量

--枚举方法
local function creatEnumTable(tbl, index) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i 
    end 
    return enumtbl 
end

--系统庄家名字
conf.HostZhuangName = "SaNa"

--错误码枚举，服务器从1开始
local ErrorCode={
	"ERR_BET_STATEEER",				--非下注状态不能下注
	"ERR_BET_FAIL",					--下注失败
	"ERR_BET_MORE_THAN_PLAYER",		--金币不足，无法下注！
	"ERR_BET_MORE_THAN_DEALER",		--超过庄家的筹码范围
	"ERR_NO_ROB_FAIL",				--下庄失败
	"ERR_NO_ROB_STATEEER",			--下注状态不能下庄
	"ERR_ROB_FAIL",					--上庄失败
	"ERR_ROB_NO_MONNEY",			--筹码不够上庄
	"ERR_SEAT_NO_MONEY",			--上座分数不够
	"ERR_SEAT_FAIL",				--上座失败
	"ERR_SEAT_STATEEER",			--下注状态不能上座
	"ERR_SEAT_DELER",				--庄家不能上座
	"ERR_SEAT_HAVE_PLAYER",			--座位上有人
	"ERR_NO_MONNEY",           		--金币不足，无法下注！
	"ERR_LEAVE_NO_FREE_TIME",		--不是空闲时间不能退出游戏
}
conf.ErrorCode=creatEnumTable(ErrorCode,0)

conf.ErrorCodeStr={
 	"非下注时间不能下注哦！",
 	"下注失败！",
 	"金币不足，无法下注！",
 	"已达到庄家可赔付最大额！",
 	"下庄失败！",
 	"本局结束才能下庄！",
 	"上庄失败！",
 	"上庄金币不足！",
 	"金币不足！",
 	"坐下失败！",
	"下注状态不能坐下！",
 	"庄家不能坐下哦！",
	"座位上有人哦！",
 	"金币不足，无法下注！",
 	"本局结束才能退出游戏哦！",
}

conf.ChatText={
	"快点吧，我等的花儿都谢了！",
	"投降输一半，速度投降吧！",
	"你的牌打的太好了！",
	"吐了个槽的整个一个悲剧啊！",
	"天灵灵，地灵灵，给手好牌行不行！",
	"大清早的鸡还没叫呢，慌什么嘛！",
	"不要走，决战到天亮！",
	"大家好，很高兴见到各位！",
	"出来混迟早要还的！",
	"再见啦，我会想念大家的！",
}


--游戏按钮标签
local Tag={
	"menu",						--菜单
	"back",						--退出
	"help",						--帮助
	"Close",					--关闭
	"chat",						--聊天
	"ludan",					--路单
	"shop",						--商店
	"people",					--人群
	"sit1",						--座位1
	"sit2",						--座位2
	"sit3",						--座位3
	"sit4",						--座位4
	"sit5",						--座位5
	"sit6",						--座位6
	"Myplayer",					--自己头像
	"Zhuangplayer",				--庄家头像
	"player1",					--玩家头像1
	"player2",					--玩家头像2
	"player3",					--玩家头像3
	"player4",					--玩家头像4
	"player5",					--玩家头像5
	"player6",					--玩家头像6
	"xiazhu1",					--下注区域1
	"xiazhu2",					--下注区域2
	"xiazhu3",					--下注区域3
	"xiazhu4",					--下注区域4
	"shangzhuang",				--上庄
	"xiazhuang",				--下庄
	"quxiao",					--取消申请
	"scoreBtn1",				--100下注
	"scoreBtn2",				--1000下注
	"scoreBtn3",				--一万下注
	"scoreBtn4",				--十万下注
	"scoreBtn5",				--百万下注
	"playerList",				--玩家列表
	"SZList",				    --上庄列表
	"recordList",				--胜负列表
	"chatList",				    --聊天界面
	"menuLayer",				--菜单界面
	"sub",						--破产补助
	"shopLayer",				--商城界面
}

conf.Tag=creatEnumTable(Tag,100)

--音效配置
conf.Music=
{
	["coin_jn"]			="game/brnn/res/music/coin_jn.mp3",     	--下注金币音效
	["coin_out"]		="game/brnn/res/music/coin_out.mp3",		--金币飞入口袋音效
	["Fapai_one"]		="game/brnn/res/music/Fapai_one.mp3",		--发牌
	["game_start"]		="game/brnn/res/music/game_start.mp3",		--开始下注
	["game_stop"]		="game/brnn/res/music/game_stop.mp3",		--停止下注
	["game_timeout1"]	="game/brnn/res/music/game_timeout1.mp3",	--下注倒计时后三秒的前两秒
	["game_timeout2"]	="game/brnn/res/music/game_timeout2.mp3",	--下注倒计时后三秒的最后一秒
	["score"]			="game/brnn/res/music/score.mp3",			--分数
	["nn_type"]			="game/brnn/res/music/nn_type_",			--牛牛牌型
	["chat_effect"]		="gamecommon/chat/res/music/",				--快捷短语音效
	["ludan_effect"]	="game/brnn/res/music/ludanEffect.mp3", 	--路单音效
}

--主场景图层值
local LayZ={
	"player",					--玩家层
	"gold1",					--金币层1
	"card",						--扑克层
	"cardType",					--牛牛类型及分数层
	"gold2",					--金币层2
	"tishi",					--提示
	"effect",					--特效层
	"smalldanmu",				--坐下玩家弹幕
	"danmu",					--弹幕
	"daoju",					--道具
	"broadCast",				--广播
	"menu",						--菜单
	"help",						--帮助
	"chat",						--聊天
	"ludan",					--路单
	"shop",						--商店
	"playerList",				--玩家列表
	"zhuangList",				--上庄列表
	"playerInfo",				--个人信息
}

conf.LayZ=creatEnumTable(LayZ,1)

--玩家节点位置
conf.PlayerNodePos=
{
	cc.p(126.20,165.23),
	cc.p(83.87,350.97),
	cc.p(182.14,549.02),
	cc.p(1157.89,550.32),
	cc.p(1248.95,352.57),
	cc.p(1195.61,165.23)
}

--自己位置
conf.MyHeadPos=cc.p(153,58)
--庄家位置
conf.ZhuangHeadPos=cc.p(550,700)

--扑克节点位置
conf.CardNodePos=
{
	cc.p(668,595),
	cc.p(340,258),
	cc.p(561,258),
	cc.p(783,258),
	cc.p(1005,258)
}

--牌型节点位置
conf.CardTypeNodePos=
{
	cc.p(668,558),
	cc.p(340,220),
	cc.p(561,220),
	cc.p(783,220),
	cc.p(1005,220)
}

--下注区域中心位置
conf.QuYuCenterPos=
{
	cc.p(340,435),
	cc.p(560,435),
	cc.p(780,435),
	cc.p(1000,435)
}

--发牌初始位置
conf.CardStartMovePos=cc.p(667,475)

--桌面路单节点位置
conf.LuDanNodePos=
{
	cc.p(340,200),
	cc.p(561,200),
	cc.p(783,200),
	cc.p(1005,200)
}

--筹码对应金币
conf.BetToScore={10^2,10^3,10^4,10^5,10^6}

--根据自己的金钱计算最大下注索引
local function getMaxBtnIndex(MyScore,curXiaZhuScore,MaxBeiShu)
	local BtnIndex=0
	if (curXiaZhuScore+10^6)*MaxBeiShu<=(MyScore+curXiaZhuScore) then
		BtnIndex=5
		return BtnIndex
	elseif (curXiaZhuScore+10^5)*MaxBeiShu<=(MyScore+curXiaZhuScore) then
		BtnIndex=4
		return BtnIndex
	elseif (curXiaZhuScore+10^4)*MaxBeiShu<=(MyScore+curXiaZhuScore) then
		BtnIndex=3
		return BtnIndex
	elseif (curXiaZhuScore+10^3)*MaxBeiShu<=(MyScore+curXiaZhuScore) then
		BtnIndex=2
		return BtnIndex
	elseif (curXiaZhuScore+10^2)*MaxBeiShu<=(MyScore+curXiaZhuScore) then
		BtnIndex=1
		return BtnIndex
	end
	return BtnIndex
end

conf.getMaxBtnIndex=getMaxBtnIndex

--将数字改成以万，亿为单位
local function switchNum(num)
	if num == nil or type(num)~="number" then  
        printInfo("将数字改成以万，亿为单位，参数错误")
    else
    	local IsZheng=true
		if num<0 then
			IsZheng=false
			num=0-num
		end  
        if num / 10^8 >=1 then  
            num = math.floor(num / 10^6)
            if IsZheng then
              	return(string.format("%.2f", num/10^2).."亿")
            else
            	return "-"..(string.format("%.2f", num/10^2).."亿")
            end
        elseif num / 10^4 >= 1 then  
            num = math.floor(num / 10^2)
            if IsZheng then
              	return(string.format("%.2f", num/10^2).."万")
            else
            	return "-"..(string.format("%.2f", num/10^2).."万")
            end
        else
        	if IsZheng then
              	return tostring(num)
            else
            	return "-"..tostring(num)
            end  
            return num  
        end  
    end 
end

conf.switchNum=switchNum


return conf