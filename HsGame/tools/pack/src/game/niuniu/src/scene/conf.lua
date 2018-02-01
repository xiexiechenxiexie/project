local conf = {}

--玩家位置
conf.PlayerPosArray = 
{
    cc.p(62,31),	--1
    cc.p(42,290),	--2
    cc.p(219,608),	--3
    cc.p(832,608),	--4
    cc.p(1174,290),	--5
}

--头像位置
conf.headPosArray = 
{
	cc.p(62,31),	--1
    cc.p(42,290),	--2
    cc.p(219,608),	--3
    cc.p(832,608),	--4
    cc.p(1174,290),	--5
}
--道具位置
conf.popPosArray = 
{
	cc.p(121,90),	--1
    cc.p(103,423),	--2
    cc.p(278,667),	--3
    cc.p(891,667),	--4
    cc.p(1235,423),	--5
}

--倍数位置
conf.multiplePosArray = 
{
	cc.p(244,178),	--1
	cc.p(240,460),	--2
	cc.p(550,687),	--3
	cc.p(787,687),	--4
	cc.p(1121,460),	--5
}
--聊天位置
conf.chatPosArray = 
{
	cc.p(150,178),	--1
	cc.p(170,450),	--2W
	cc.p(280,570),	--3
	cc.p(890,570),	--4
	cc.p(1160,450),	--5
}

--发牌位置
conf.cardPosArray = 
{
	cc.p(-580,-420),	--1
	cc.p(-455,-11),		--2
	cc.p(-420,144),		--3
	cc.p(195,144),		--4
	cc.p(275,-11),		--5
}

--摊牌位置
conf.showCardPosArray = 
{
	cc.p(570,200),		--1
	cc.p(210,385),		--2
	cc.p(245,540),		--3
	cc.p(855,540),		--4
	cc.p(940,385),		--5
}

local function creatEnumTable(tbl, index) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i 
    end 
    return enumtbl 
end

--游戏按钮标签
local Tag={
	"bank0",						--不抢
	"bank1",						--抢一
	"bank2",						--抢二
	"bank3",						--抢三
	"brtting1",						--下注1倍
	"brtting2",						--下注2倍
	"brtting3",						--下注3倍
	"hasniu",						--有牛
	"noniu",						--无牛
	"exploit",						--战绩
	"shop",							--商店
	"invite",						--邀请
	"ready", 						--准备
	"play1",						--玩家1
	"play2",						--玩家2
	"play3",						--玩家3
	"play4",						--玩家4
	"play5",						--玩家5
	"sit1",							--座位1
	"sit2",							--座位2
	"sit3",							--座位3
	"sit4",							--座位4
	"sit5",							--座位5
	"chatList",						--聊天界面
}
conf.Tag=creatEnumTable(Tag,100)
--金币牛牛抢庄按钮游戏按钮标签
local goldTag={
	"bank0",						--不抢
	"bank1",						--抢一
	"bank2",						--抢二
	"bank3",						--抢三
	"bank4",						--抢四
	"brtting5",						--下注5倍
	"brtting10",					--下注10倍
	"brtting15",					--下注15倍
	"brtting20",					--下注20倍
	"brtting25",					--下注25倍
}
conf.goldTag=creatEnumTable(goldTag,200)
--游戏时间索引
local time = {
	"wait",
	"gradBank",
	"brtting",
	"putCard",
}

conf.time = creatEnumTable(time,500)
--帮助索引
local help = {
	"close",
	"cardType",
	"rule",
	"wanfa",
}
conf.help = creatEnumTable(help,600)
--解散房间索引
local dism = {
	"tishi_close",
	"tishi_quxiao",
	"tishi_queding",
	"dis_close",
	"dis_quxiao",
	"dis_queding",
}
conf.dism = creatEnumTable(dism,650)

--房卡桌子状态
local tableState = {
	"endRound",		--准备
	"grapBanker",	--抢庄
	"beting",		--下注
	"roundAction",	--摊牌
	"setTlement",	--结算
	"gameEnd",		--总结算
}
conf.tableState = creatEnumTable(tableState,0)
--金币桌子状态
local goldState = {
	"freetime",		--空闲
	"grapBanker",	--抢庄
	"beting",		--下注
	"roundAction",	--算牛
	"setTlement",	--结算
}
conf.goldState = creatEnumTable(goldState,0)

local inform = {
	"close",		--关闭
	"agree",		--同意
	"refuse",		--拒绝
}
conf.inform = creatEnumTable(inform,160)

local musicResPath = "game/niuniu/res/GameLayout/NiuNiu/music/"
--音效配置
conf.Music = {
	["coinfly"]			=musicResPath.."Coinfly.mp3",     	--金币飞行音效
	["Fapai_one"]		=musicResPath.."Fapai_one.mp3",		--发一张牌
	["Fapai_more"]		=musicResPath.."Fapai_more.mp3",	--发多张牌
	["Ready"]			=musicResPath.."Ready.mp3",			--准备
	["Gamestart"]		=musicResPath.."Gamestart.mp3",		--游戏开始
	["Gamelose"]	    =musicResPath.."Gamelose.mp3",		--游戏输
	["Gamewin"]			=musicResPath.."Gamewin.mp3",		--游戏赢
	["Dingzhuang"]	    =musicResPath.."Dingzhuang.mp3",	--定庄
	["Xuanzhuang"]		=musicResPath.."Xuanzhuang.mp3",	--选庄
	["Out_Card"]		=musicResPath.."Out_Card.mp3",	    --点击牌
	["Man_ox"]			=musicResPath.."Man_ox",		    --牛牛牌型男
	["Woman_ox"]		=musicResPath.."Woman_ox",		    --牛牛牌型女
	["chat_effect"]		="gamecommon/chat/res/music/",	    --快捷短语音效
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

conf.ErrorCodeStr={
 	"抢庄倍数错误",
 	"已经抢过庄",
 	"下注倍数错误",
 	"已经下过注",
 	"玩家有牛",
 	"玩家没牛",
 	"已经摊过牌",
 	"房卡不够",
}

--错误码枚举，服务器从11开始
local ErrorCode={
	"ERROR_GRADBANKER",				--抢庄倍数错误
	"ERROR_GRADBANKERTRUE",			--已经抢过庄
	"ERROR_BRTTING",				--下注倍数错误
	"ERROR_BRTTINGTRUE",			--已经下过注
	"ERROR_SWIGNHOVE",				--玩家有牛
	"ERROR_SWIGNNO",				--玩家没牛
	"ERROR_SWIGNTRUE",				--已经摊过牌
	"ERROR_NOT_ROOMCARD",       	--房卡不够
}
conf.ErrorCode=creatEnumTable(ErrorCode,0)

--重新定义位置
local function swichPos(oldid,myid,max)
    if oldid and myid and max then
        return (oldid+max-myid)%max + 1
    else
        print("DataError 座位号转换失败 数据为空")
        return 65535
    end
    
--[[
	local function extend(tbl, tbl2)
		local tbl_ = {}

		if type(tbl) == "table" then
			for k, v in pairs(tbl) do
		  		table.insert(tbl_,v)
			end
		end

		if type(tbl2) == "table" then
			for k,v in pairs(tbl2) do
		  		table.insert(tbl_,v)
			end
		end

		return tbl_
	end
    local tmp1 = {}
    local tmp2 = {}
    for i=1,max do
        if i<myid+1 then
           table.insert(tmp1,i)
        else
           table.insert(tmp2,i)
        end
    end
    local temp = extend(tmp2,tmp1)
    for i,v in ipairs(temp) do
        if v == oldid+1 then
            return i
        end 
    end
--]]
end
conf.swichPos=swichPos
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

--提示语配置表
conf.tipes = {
   waitNext = "请耐心等待下一局",
   waitGraBanker = "请耐心等待别的玩家抢庄",
   waitBet = "请耐心等待别的玩家下注",
   waitOpenCards = "还有人在冥思苦想中",
   waitJieSuan = "游戏即将开始,请耐心等待",
   enterLook = "您目前处于观战状态",         
}

return conf