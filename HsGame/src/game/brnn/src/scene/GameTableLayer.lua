-- 游戏主界面
local MusicManager=cc.exports.manager.MusicManager
local GameResPath  = "game/brnn/res/GameLayout/"
local BRNN_CSB = "game/brnn/res/BRNNScene.csb"
local PLAYER_CSB = "game/brnn/res/PlayerNode.csb"
local GameRequest = require "game/brnn/src/request/GameRequest"
local ChatLayer=require "gamecommon/chat/src/ChatLayer"
local SZListLayer=require "game/brnn/src/scene/SZListLayer"
local GameUserData=require "game/brnn/src/scene/GameUserData"
local WinRecordLayer=require "game/brnn/src/scene/WinRecordLayer"
local PlayerListLayer=require "game/brnn/src/scene/PlayerListLayer"
local GoldLayer=require "game/brnn/src/scene/GoldLayer"
local SmallLuDanNode=require "game/brnn/src/scene/SmallLuDanNode"
local SmallLuDanEffect=require "game/brnn/src/scene/SmallLuDanEffect"
local MenuNode=require "game/brnn/src/scene/MenuLayer"
local HelpNode=require "game/brnn/src/scene/HelpLayer"
local CardTypeNode=require "game/brnn/src/scene/CardTypeNode"
local DanMuNode=require "game/brnn/src/scene/DanMuNode"
local SmallDanMuNode=require "game/brnn/src/scene/SmallDanMuNode"
local GamePlayerInfoView = require "GamePlayerInfoView"
local Subsidy = require "gamecommon/subsidy/src/SubsidyLayer"
local conf = require"game/brnn/src/scene/Conf"
local ScoreNode=require"game/brnn/src/scene/ScoreNode"
local Avatar=cc.exports.lib.node.Avatar
local FrameAniFactory=cc.exports.lib.factory.FrameAniFactory
local Tag=conf.Tag
local LayZ=conf.LayZ

local GameTableLayer = class("GameTableLayer", cc.Layer)

function GameTableLayer:ctor()
	self:enableNodeEvents() 
    --self:preloadUI()
    self:CreateView()
    self:init()
    self._gameRequest = GameRequest:new()
end

function GameTableLayer:preloadUI()
	display.loadSpriteFrames(GameResPath.."btn_score.plist",
							GameResPath.."btn_score.png")
	display.loadSpriteFrames(GameResPath.."niuniu_card.plist",
							GameResPath.."niuniu_card.png")
	display.loadSpriteFrames(GameResPath.."start_xiazhu.plist",
							GameResPath.."start_xiazhu.png")
	display.loadSpriteFrames(GameResPath.."win_gold_ani_effect.plist",
							GameResPath.."win_gold_ani_effect.png")
	display.loadSpriteFrames(GameResPath.."ludanAction.plist",
							GameResPath.."ludanAction.png")
	display.loadSpriteFrames("gamecommon/shopAction.plist",
							"gamecommon/shopAction.png")
	display.loadSpriteFrames("game/brnn/res/SZListLayout/zhuangjia_btn.plist",
							"game/brnn/res/SZListLayout/zhuangjia_btn.png")
	display.loadSpriteFrames("game/brnn/res/WinRecordLayout/WinRecordLayout.plist",
							"game/brnn/res/WinRecordLayout/WinRecordLayout.png")
	display.loadSpriteFrames("gamecommon/chat/res/chat.plist",
							"gamecommon/chat/res/chat.png")
	display.loadSpriteFrames("gamecommon/subsidy/res/subsidy.plist",
							"gamecommon/subsidy/res/subsidy.png")
	FrameAniFactory:getInstance():addAllSpriteFrames()
end

-- 创建界面
function GameTableLayer:CreateView()
	local bg = display.newSprite(GameResPath.."BG.png")
	bg:setPosition(667,375)
	self:addChild(bg,-1)
    local container = cc.CSLoader:createNode(BRNN_CSB)
	self:addChild(container,0)
	self.m_RootNode=container
end

-- 初始化界面
function GameTableLayer:init()
	--测试代码
    -- self.clearBtn = ccui.Button:create(GameResPath.."txt_niunum10.png")
    -- self.clearBtn:setPosition(cc.p(700,700))
    -- self.clearBtn:setLocalZOrder(1000)
    -- self:addChild(self.clearBtn)
    -- self.clearBtn:addClickEventListener(function()
    --   self:resetTable()
    -- end)

    -- self.reBtn = ccui.Button:create(GameResPath.."txt_niunum10.png")
    -- self.reBtn:setPosition(cc.p(900,700))
    -- self.reBtn:setLocalZOrder(1000)
    -- self:addChild(self.reBtn)
    -- self.reBtn:addClickEventListener(function()
    --     self:resetTable()
    --     GameRequest:RequestTabelInfo()
    -- end)

	self.m_FaPaiNodeScheduler=nil--发牌定时器
	self.m_OpenCardScheduler=nil --开牌定时器
	self.TishiScheduler=nil      --文字提示定时器

	--玩家列表数据
	self.PlayerListData=nil
	--聊天记录数据
	self.ChatListData={}

	--上庄列表数据
	self.SZListData={}

	--分数变化动画节点
	self.ScoreNode=cc.Node:create()
	self:addChild(self.ScoreNode,LayZ.tishi)

	--入座条件
	self.sit_score_lab = self.m_RootNode:getChildByName("sit_score_lab")
	self.sit_score_lab:setFontName(GameUtils.getFontName())

	--菜单按钮
	local menu_btn=self.m_RootNode:getChildByName("menu_btn")
	menu_btn:setTag(Tag.menu)
	menu_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	--下庄按钮
	local btn_xiazhuang=self.m_RootNode:getChildByName("btn_xiazhuang")
	btn_xiazhuang:setTag(Tag.xiazhuang)
	btn_xiazhuang:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	btn_xiazhuang:setVisible(false)
	self.btn_xiazhuang=btn_xiazhuang

	--上庄按钮
	local btn_shangzhuang=self.m_RootNode:getChildByName("btn_shangzhuang")
	btn_shangzhuang:setTag(Tag.shangzhuang)
	btn_shangzhuang:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	self.btn_shangzhuang=btn_shangzhuang

	--聊天按钮
	local chat_btn=self.m_RootNode:getChildByName("chat_btn")
	chat_btn:setTag(Tag.chat)
	chat_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	--路单按钮
	local ludan_btn=self.m_RootNode:getChildByName("ludan_btn")
	ludan_btn:setTag(Tag.ludan)
	ludan_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	--路单按钮动画
	local ludan_btn_action_node = cc.CSLoader:createNode(GameResPath.."ludanBtnAction.csb")
	ludan_btn:addChild(ludan_btn_action_node)
	ludan_btn_action_node:setPosition(ludan_btn:getContentSize().width/2,ludan_btn:getContentSize().height/2+10)

	local ludan_btn_action = cc.CSLoader:createTimeline(GameResPath.."ludanBtnAction.csb")
	ludan_btn_action_node:runAction(ludan_btn_action)

    self.ludan_btn_action = ludan_btn_action

    if not manager.UserManager:getInstance():findAppCloseRoomCardFlag() then 
		local shop_btn = ccui.Button:create("shop_car.png","shop_car.png","shop_car.png",ccui.TextureResType.plistType)
		shop_btn:setPosition(1278,690)
		shop_btn:setTag(Tag.shop)
		shop_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
		self.m_RootNode:addChild(shop_btn)

		local shop_btn_node = cc.CSLoader:createNode("gamecommon/shop_ani.csb")
		shop_btn_node:setPosition(1278,690)
		self.m_RootNode:addChild(shop_btn_node)
	    local shopAct = cc.CSLoader:createTimeline("gamecommon/shop_ani.csb")
	    shopAct:setTimeSpeed(1)
	    shop_btn_node:runAction(shopAct)
	    shopAct:gotoFrameAndPlay(0,true)
	end

	--人群按钮
	local people_btn=self.m_RootNode:getChildByName("people_btn")
	people_btn:setTag(Tag.people)
	people_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	--提示文本
	local tishiNode=cc.Node:create()
	tishiNode:setPosition(667,155)
	tishiNode:setVisible(false)
	self:addChild(tishiNode,LayZ.tishi)
	local bg=cc.Sprite:create(GameResPath.."time_bg.png")
	tishiNode:addChild(bg)
	local labelConfig =	{
			fontName = GameUtils.getFontName(),
			fontSize = 24,
			text ="",
			alignment = cc.TEXT_ALIGNMENT_CENTER,
			color = cc.c4b(255,255,255, 255),
			pos = cc.p(0,0),
			anchorPoint = cc.p(0.5,0.5)
		}
	local tishi_text = cc.exports.lib.uidisplay.createLabel(labelConfig)
	tishiNode:addChild(tishi_text)
	tishi_text:setName("tishi_text")
	self.m_tishiNode=tishiNode
	
	--特效层
	--开始下注动画
    --骨骼动画
	local node = cc.CSLoader:createNode(GameResPath.."start_xiazhu.csb")
	node:setPosition(display.cx,display.cy)
	self:addChild(node,LayZ.effect)
    local act = cc.CSLoader:createTimeline(GameResPath.."start_xiazhu.csb")
    act:setTimeSpeed(1) --设置执行动画速度
    -- actction.sFrame = 0  --执行动作的开始帧和结尾帧index
    -- actction.eFrame = 0
    node:runAction(act)
    node:setVisible(false)
    self.xiazhu_node=node
    self.xiazhu_action=act

    --粒子
	local particle = cc.ParticleSystemQuad:create(GameResPath.."particle_start_xiazhu.plist")
    particle:setPositionType(cc.POSITION_TYPE_GROUPED )
    particle:setPosition(display.cx,display.cy)
    self:addChild(particle,LayZ.effect)
    particle:stop()
    self.particle_start_xiazhu=particle

	--扑克层
	local card_layout=cc.Node:create()
	self:addChild(card_layout,LayZ.card)
	self.m_card_layout=card_layout

	--金币层
	local gold_layout=cc.Node:create()
	self:addChild(gold_layout,LayZ.gold1)
	self.m_gold_layout=gold_layout

	--牛牛类型及分数层
	local card_type_layout=cc.Node:create()
	self:addChild(card_type_layout,LayZ.cardType)
	card_type_layout:setVisible(false)
	self.m_CardTypeNodeArray={}
	for i=1,conf.CardNodeNum do
		local cardtypenode=CardTypeNode.new()
		cardtypenode:setPosition(conf.CardTypeNodePos[i])
		cardtypenode:setVisible(false)
		card_type_layout:addChild(cardtypenode)
		table.insert(self.m_CardTypeNodeArray,cardtypenode)
	end
	self.m_card_type_layout=card_type_layout

	--广播
	local broadCastView = require("Lobby/src/lobby/view/BroadCastView").new(1)
	self:addChild(broadCastView,LayZ.broadCast)

	--路单特效层
	local LuDanEffecNode = cc.Node:create()
	self:addChild(LuDanEffecNode,LayZ.effect)

	--小路单界面
	local SmallLuDan_Layer=self.m_RootNode:getChildByName("ludan_layout")
	self.m_SmallLDNodeArray={}
	self.m_SmallLDEffecArray={}
	for i=1,conf.QUYU_NUM do
		local node=SmallLuDanNode.new()
		node:setPosition(cc.p(422+222*(i-1),325))
		SmallLuDan_Layer:addChild(node)
		
		local effect_node = SmallLuDanEffect.new()
		LuDanEffecNode:addChild(effect_node)
		effect_node:setActionPos(conf.QuYuCenterPos[i],cc.p(422+222*(i-1),325))

		effect_node:setCallBack(function()
			node:update()
		end)

		table.insert(self.m_SmallLDNodeArray,node)

		table.insert(self.m_SmallLDEffecArray,effect_node)
	end

	--弹幕
	self.m_DanMuNode=DanMuNode.new()
	self:addChild(self.m_DanMuNode,LayZ.danmu)
	self.m_DanMuNode:setPosition(10,200)
	-- self.m_DanMuNode:setVisible(false)

	self.m_quyuBtnTab={}
	self.m_xuanquSpTab={}
	self.m_xuanquTextTab={}
	self.m_xuanquDaraTab={}
	self.m_MyScoreTextTab={}
	self.m_MyScoreDaraTab={}
	for i=1,4 do
		--下注区域框
		local str="xuanqu_sp"..tostring(i)
		local xuanqu_sp=self.m_RootNode:getChildByName(str)
		local act1=cc.FadeOut:create(1)
		local act2=act1:reverse()
		xuanqu_sp:runAction(cc.RepeatForever:create(cc.Sequence:create(act1,act2)))
		xuanqu_sp:setVisible(false)
		table.insert(self.m_xuanquSpTab,xuanqu_sp)

		--下注区域按钮
		str="quyu_btn"..tostring(i)
		local quyu_btn=self.m_RootNode:getChildByName(str)
		quyu_btn:setTag(Tag.xiazhu1-1+i)
		quyu_btn.isNoSound=true
		quyu_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
		table.insert(self.m_quyuBtnTab,quyu_btn)

		--区域总分文本
		str="quyu_score"..tostring(i)
		local quyu_score=self.m_RootNode:getChildByName(str)
		quyu_score:setString("")
		quyu_score:setFontName(GameUtils.getFontName())
		table.insert(self.m_xuanquTextTab,quyu_score)
		table.insert(self.m_xuanquDaraTab,0)

		--自己下注区域总分
		str="myscore"..tostring(i)
		local myscore=self.m_RootNode:getChildByName(str)
		myscore:setString("")
		myscore:setFontName(GameUtils.getFontName())
		table.insert(self.m_MyScoreTextTab,myscore)
		table.insert(self.m_MyScoreDaraTab,0)
	end

	self.SmallDanMuArray = {}
	self.m_sitBtnTab={}
	self.m_playerNode={}
	self.sitScore={}
	--坐下的玩家的uid
	self.sitUidArray={}
	self.sitUidOldArray={0,0,0,0,0,0}
	for i=1,6 do
		--玩家座位
		local PlayerNode=cc.CSLoader:createNode(PLAYER_CSB)
		self.m_RootNode:addChild(PlayerNode,LayZ.player)
		PlayerNode:setPosition(conf.PlayerNodePos[i])
		local Head=PlayerNode:getChildByName("head_bg_1")
		Head:setScale(0.9)
		PlayerNode:setVisible(false)
		table.insert(self.m_playerNode,PlayerNode)

		table.insert(self.sitScore,0)

		--聊天短语框
		local smallDanMuNode=SmallDanMuNode.new(i)
		if i<4 then
			smallDanMuNode:setPosition(conf.PlayerNodePos[i])
		else
			smallDanMuNode:setPosition(conf.PlayerNodePos[i])
		end
		
		self:addChild(smallDanMuNode,LayZ.smalldanmu)
		table.insert(self.SmallDanMuArray,smallDanMuNode)

		--坐下玩家头像
		local headBtn=PlayerNode:getChildByName("head_bg_1")
		headBtn:setTag(Tag.player1-1+i)
		headBtn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
		--坐下玩家名字
		local name=PlayerNode:getChildByName("name")
		name:setString("呜呜呜呜")
		name:setFontName(GameUtils.getFontName())
		--坐下玩家分数
		local score=PlayerNode:getChildByName("score")
		score:setString("$1000000")
		score:setFontName(GameUtils.getFontName())

		--坐下按钮
		local str="sit_btn"..tostring(i)
		local sit_btn=self.m_RootNode:getChildByName(str)
		sit_btn:setTag(Tag.sit1-1+i)
		sit_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
		table.insert(self.m_sitBtnTab,sit_btn)
	end

	--自己短语框
	local smallDanMuNode=SmallDanMuNode.new(7)
	smallDanMuNode:setPosition(conf.MyHeadPos)
	self:addChild(smallDanMuNode,LayZ.smalldanmu)
	table.insert(self.SmallDanMuArray,smallDanMuNode)
	--庄家短语框
	local smallDanMuNode=SmallDanMuNode.new(8)
	smallDanMuNode:setPosition(conf.ZhuangHeadPos)
	self:addChild(smallDanMuNode,LayZ.smalldanmu)
	table.insert(self.SmallDanMuArray,smallDanMuNode)

	self.m_btn_score={}
	for i=1,5 do
		--下注筹码按钮
		local str="btn_score"..tostring(i)
		local btn_score=self.m_RootNode:getChildByName(str)
		btn_score:setTag(Tag.scoreBtn1-1+i)
		btn_score:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
		table.insert(self.m_btn_score,btn_score)
	end

	--按钮选中特效
	self.m_btn_select_node = self.m_RootNode:getChildByName("btn_select_node")

	local btn_select_sp = cc.Sprite:create(GameResPath.."btn_chip_effect.png")
	btn_select_sp:setPosition(0,0)
	btn_select_sp:setBlendFunc(cc.blendFunc(gl.ONE,gl.ONE))
	self.m_btn_select_node:addChild(btn_select_sp)

	local btn_select_particle = cc.ParticleSystemQuad:create(GameResPath.."btn_effect.plist")
    btn_select_particle:setPositionType(cc.POSITION_TYPE_GROUPED )
    btn_select_particle:setPosition(0,0)
    self.m_btn_select_node:addChild(btn_select_particle)
    btn_select_particle:setScaleX(0.6)
    btn_select_particle:setScaleY(0.37)
    btn_select_particle:setBlendFunc(cc.blendFunc(gl.ONE,gl.ONE))
    btn_select_particle:start()

	--庄家的头像
	local zhuangHead=self.m_RootNode:getChildByName("zhuangHead")
	zhuangHead:setTag(Tag.Zhuangplayer)
	zhuangHead:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	zhuangHead:setScale(0.95)
	local paramTab={}
	paramTab.avatarUrl=""
	paramTab.stencilFile=GameResPath.."head_bg.png"
	paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(2)
	local headnode=Avatar:create(paramTab)
	headnode:setScale(1.03)
	headnode:setPosition(cc.p(0,-2))
	zhuangHead:addChild(headnode)
	self.zhuangHead=zhuangHead

	--庄家的钱
	self.zhuang_score=self.m_RootNode:getChildByName("zhuang_score")
	self.zhuang_score:setString("系统当庄")
	self.zhuang_score:setFontName(GameUtils.getFontName())
	--庄家的名字
	self.zhuang_name=self.m_RootNode:getChildByName("zhuang_name")
	self.zhuang_name:setString(conf.HostZhuangName)
	self.zhuang_name:setFontName(GameUtils.getFontName())

	self.ZhuangUid=0

	self.zhuangMoney=0

	--自己的头像
	local myHead=self.m_RootNode:getChildByName("myHead")
	myHead:setTag(Tag.Myplayer)
	myHead:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	myHead:setScale(0.95)
	local paramTab = {}
	paramTab.avatarUrl = UserData.avatarUrl
	paramTab.stencilFile = GameResPath.."head_bg.png"
	paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(UserData.gender)
	local headnode=Avatar:create(paramTab)
	headnode:setScale(1.03)
	headnode:setPosition(cc.p(-1,0))
	myHead:addChild(headnode)
	self.myHead=myHead

	--自己的钱
	self.MyMoney=UserData.coins
	self.myscore=self.m_RootNode:getChildByName("myscore")
	self.myscore:setFontName(GameUtils.getFontName())

	self.myscore:setString(conf.switchNum(self.MyMoney))

	--自己的名字
	self.myname=self.m_RootNode:getChildByName("myname")
	self.myname:setFontName(GameUtils.getFontName())
	self.myname:setString(string.getMaxLen(UserData.nickName))

	--当前选中筹码按钮索引]
	self.curScoreBtnIndex=0
	--当前最大下注筹码索引
	self.maxBtnIndex=0
	--当前自己下注钱
	self.curXiaZhuGold=0

	--系统庄家资料
	self.SystemZhuangInfo = {}
	self.SystemZhuangInfo.AvatarUrl = conf.HostZhuangHeadUrl
	self.SystemZhuangInfo.NickName = conf.HostZhuangName

	--下注状态
	self.IsXiaZhuState = false

	--上庄最小分数
	self.zhuangMinScore=0

	-- 税率
	self.shuilv = 0 

	--最大倍数
	self.MaxBeiShu = 0

	--开牌数据暂存
	self.CardData=CardData
	--结算数据暂存
	self.ResultData={}
	--玩家信息数据
	self.UserData={}

	--路单数据暂存
	self.LuDanDataArray={}

	--小路单数据缓存
	self.SmallLuDanDataArray = {}

	--自己是否是庄家
	self.IsZhuang=false

	self:initCard()
	self:initGold()

	self:reSetXiaZhuBtn()
end

--初始化牌
function GameTableLayer:initCard()
	self.m_card_layout:setVisible(false)
	self.m_CardBackArray={}
	for i=1,(conf.Card_Num)*(conf.CardNodeNum) do
		local CardSp=cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
		CardSp:setScale(conf.Card_Size)
		CardSp:setTag(i)
		self.m_card_layout:addChild(CardSp,(conf.Card_Num)*(conf.CardNodeNum)+i)
		table.insert(self.m_CardBackArray,CardSp)
	end

	self.m_CardArray={}
	for i=1,(conf.Card_Num)*(conf.CardNodeNum) do
		local CardSp=cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")

		local a=math.modf((i-1)/conf.CardNodeNum)+1
		local b=(i-1)%conf.Card_Num+1
		local Tpos={x=0,y=0}
		Tpos.x=conf.CardNodePos[a].x+(b-3)*conf.Card_X
		Tpos.y=conf.CardNodePos[a].y
		CardSp:setPosition(Tpos)
		CardSp:setScale(conf.Card_Size)
		CardSp:setVisible(false)
		self.m_card_layout:addChild(CardSp,(conf.Card_Num)*(conf.CardNodeNum)+i)
		table.insert(self.m_CardArray,CardSp)
	end
end

--重置牌
function GameTableLayer:resetCard()
	for i,v in ipairs(self.m_CardBackArray) do
		v:initWithSpriteFrameName("niuniu_card_0x00.png")
		v:setPosition(conf.CardStartMovePos)
		v:stopAllActions()
		v:setVisible(true)
		v:setLocalZOrder((conf.Card_Num)*(conf.CardNodeNum)-i+50)
	end

	for i,v in ipairs(self.m_CardArray) do
		v:setVisible(false)
		v:initWithSpriteFrameName("niuniu_card_0x00.png")
		v:stopAllActions()
	end
end

--初始化金币
function GameTableLayer:initGold()
	local GoldLayer=GoldLayer.new()
	self.m_gold_layout:addChild(GoldLayer)
	self.m_gold_layout:setVisible(false)

	local people_btn=self.m_RootNode:getChildByName("people_btn")
	local ppos={}
	ppos.x,ppos.y=people_btn:getPosition()

	GoldLayer:setGoldMovePos("Player0",ppos)

	for i=1,4 do
		--下注区域框
		local str="xuanqu_sp"..tostring(i)
		local xuanqu_sp=self.m_RootNode:getChildByName(str)
		local s_pos={}
		s_pos.x,s_pos.y=xuanqu_sp:getPosition()
		str="xiazhu"..tostring(i)
		GoldLayer:setGoldMovePos(str,s_pos)
	end
	
	self.m_GoldLayer=GoldLayer
end

--重置金币
function GameTableLayer:resetGold()
	self.m_gold_layout:setVisible(false)
	self.m_GoldLayer:reset()
end

function GameTableLayer:onEnter()
	-- MusicManager:getInstance():playSound()

	--获取系统庄家头像及名字
	self:RequestSystemZhuangInfo()
end

function GameTableLayer:onExit()
	-- display.removeSpriteFrames(GameResPath.."btn_score.plist",
	-- 						GameResPath.."btn_score.png")
	-- display.removeSpriteFrames(GameResPath.."niuniu_card.plist",
	-- 						GameResPath.."niuniu_card.png")
	-- display.removeSpriteFrames(GameResPath.."start_xiazhu.plist",
	-- 						GameResPath.."start_xiazhu.png")
	-- display.removeSpriteFrames(GameResPath.."win_gold_ani_effect.plist",
	-- 						GameResPath.."win_gold_ani_effect.png")
	-- display.removeSpriteFrames(GameResPath.."ludanAction.plist",
	-- 						GameResPath.."ludanAction.png")
	-- display.removeSpriteFrames("gamecommon/shopAction.plist",
	-- 						"gamecommon/shopAction.png")
	-- display.removeSpriteFrames("game/brnn/res/SZListLayout/zhuangjia_btn.plist",
	-- 						"game/brnn/res/SZListLayout/zhuangjia_btn.png")
	-- display.removeSpriteFrames("game/brnn/res/WinRecordLayout/WinRecordLayout.plist",
	-- 						"game/brnn/res/WinRecordLayout/WinRecordLayout.png")
	-- display.removeSpriteFrames("gamecommon/chat/res/chat.plist",
	-- 						"gamecommon/chat/res/chat.png")
	-- display.removeSpriteFrames("gamecommon/subsidy/res/subsidy.plist",
	-- 						"gamecommon/subsidy/res/subsidy.png")
	-- FrameAniFactory:getInstance():clearAllSpriteFrames()

	self:stopAllScheduler()

	self._gameRequest = nil
end

function GameTableLayer:stopAllScheduler()
	if self.m_FaPaiNodeScheduler then
		local scheduler = cc.Director:getInstance():getScheduler()
    	scheduler:unscheduleScriptEntry(self.m_FaPaiNodeScheduler)
    	self.m_FaPaiNodeScheduler=nil
	end
	if self.m_OpenCardScheduler then
		local scheduler = cc.Director:getInstance():getScheduler()
    	scheduler:unscheduleScriptEntry(self.m_OpenCardScheduler)
    	self.m_OpenCardScheduler=nil
	end
	self:resetTiShiScheduler()
end


--按钮事件
function GameTableLayer:onButtonClickedEvent(sender)
	local tag=sender:getTag()
	if tag==Tag.menu then
		if sender:isSelected() then
			self:closeMenuLayer()
		else
			self:popMenuLayer()
		end
	elseif tag==Tag.Close then
		self:closeHelpLayer()
	elseif tag==Tag.chat then
		self:onChatBtnEvent()
	elseif tag==Tag.ludan then
		self:onLudanBtnEvent()
	elseif tag==Tag.shop then
		self:onShopBtnEvent()
	elseif tag==Tag.people then
		self:onPeopleBtnEvent()
	elseif tag==Tag.shangzhuang then
		self:onSZBtnEvent()
	elseif tag==Tag.xiazhuang then
		self:onXZBtnEvent()
	elseif (tag>=Tag.scoreBtn1) and (tag<=Tag.scoreBtn5)  then
		local index=tag-Tag.scoreBtn1
		self:onScoreBtnEvent(index)
	elseif (tag>=Tag.sit1) and (tag<=Tag.sit6) then
		local index=tag-Tag.sit1
		self:onSitBtnEvent(index)
	elseif (tag>=Tag.player1) and (tag<=Tag.player6) then
		local index=tag-Tag.player1
		self:onPlayerBtnEvent(index)
	elseif tag==Tag.Myplayer then
		self:onMyHeadBtnEvent()
	elseif tag==Tag.Zhuangplayer then
		self:onZhuangHeadBtnEvent()
	elseif (tag>=Tag.xiazhu1) and (tag<=Tag.xiazhu4) then
		local index=tag-Tag.xiazhu1
		self:onXiaZhuBtnEvent(index)
	end
end

--返回大厅
function GameTableLayer:onBackBtnEvent()
	self:setMenuBtn(false)
	self:closeMenuLayer()

	--发送离开房间
  	self._gameRequest:RequestLeaveTable()
end

--帮助
function GameTableLayer:onHelpBtnEvent()
	local helpNode=HelpNode.new()
	self:addChild(helpNode,LayZ.help)
end

--聊天
function GameTableLayer:onChatBtnEvent()
	local chatLayer=ChatLayer.new()
	chatLayer:setTag(Tag.chatList)
	self:addChild(chatLayer,LayZ.chat)
	chatLayer:setData(self.ChatListData)
end

--路单
function GameTableLayer:onLudanBtnEvent()
	--胜负记录
	local winRecordLayer=WinRecordLayer.new()
	self:addChild(winRecordLayer,LayZ.ludan)
	winRecordLayer:setTag(Tag.recordList)
	if self.LuDanDataArray then
		winRecordLayer:updateList(self.LuDanDataArray)
	end
end

--商店
function GameTableLayer:onShopBtnEvent()
	if self:getChildByTag(Tag.shopLayer) == nil then
		local shopLayer = require("src/lobby/layer/MallDialog"):create(config.MallLayerConfig.Type_Gold)
		shopLayer:setTag(Tag.shopLayer)
		self:addChild(shopLayer,conf.LayZ.shop)
	end
end

--玩家列表
function GameTableLayer:onPeopleBtnEvent()
	local playerListLayer=PlayerListLayer.new()
	playerListLayer:setTag(Tag.playerList)
	self:addChild(playerListLayer,LayZ.playerList)
	playerListLayer:setData(self.PlayerListData,self.zhuangMinScore)
end

--上庄列表
function GameTableLayer:onSZBtnEvent()
	local szListLayer=SZListLayer.new()
	szListLayer:setTag(Tag.SZList)
	self:addChild(szListLayer,LayZ.zhuangList)
	szListLayer:setData(self.SZListData,self.zhuangMinScore)
end

--下庄
function GameTableLayer:onXZBtnEvent()
	local szListLayer=SZListLayer.new()
	szListLayer:setTag(Tag.SZList)
	self:addChild(szListLayer,LayZ.zhuangList)
	szListLayer:setData(self.SZListData,self.zhuangMinScore)
end

--筹码
function GameTableLayer:onScoreBtnEvent(index)
	local xx,yy=self.m_btn_score[index+1]:getPosition()
	self.m_btn_select_node:setPosition(cc.p(xx,yy+3))
	self.curScoreBtnIndex=index+1
end

--座位
function GameTableLayer:onSitBtnEvent(index)
	-- -- if self.IsZhuang==false then
		self._gameRequest:RequestGameSit(index)
	-- -- end
end

--坐下玩家头像按钮
function GameTableLayer:onPlayerBtnEvent(index)
	local info=GameUserData:getInstance():getUserInfo(self.sitUidArray[index+1])
	local playerInfoView=GamePlayerInfoView.new(self.sitUidArray[index+1])
	playerInfoView:setInfoData(info)
 	self:addChild(playerInfoView,LayZ.playerInfo)
end

--自己头像按钮
function GameTableLayer:onMyHeadBtnEvent()
	local info=GameUserData:getInstance():getUserInfo(UserData.userId)
	local playerInfoView=GamePlayerInfoView.new(UserData.userId)
	playerInfoView:setInfoData(info)
 	self:addChild(playerInfoView,LayZ.playerInfo)
end

--庄家头像按钮
function GameTableLayer:onZhuangHeadBtnEvent()
	if self.ZhuangUid>0 then
		local info=GameUserData:getInstance():getUserInfo(self.ZhuangUid)
		local playerInfoView=GamePlayerInfoView.new(self.ZhuangUid)
		playerInfoView:setInfoData(info)
 		self:addChild(playerInfoView,LayZ.playerInfo)
	else
		local info = {}
		info.AvatarUrl = self.SystemZhuangInfo.AvatarUrl or conf.HostZhuangHeadUrl
		info.Gender = 2
		info.NickName = self.SystemZhuangInfo.NickName or conf.HostZhuangName
		info.Score = 0
		info.UserId = 0
		local gamePlayerInfoView=GamePlayerInfoView.new(0)
		gamePlayerInfoView:setInfoData(info)
 		self:addChild(gamePlayerInfoView,LayZ.playerInfo)
	end

end

--下注区域
function GameTableLayer:onXiaZhuBtnEvent(index)
	-- if self.curScoreBtnIndex>0 and self.IsZhuang==false then
	if self.curScoreBtnIndex == 0 then
		self._gameRequest:RequestGameXiaZhu(self.curScoreBtnIndex,index)
	else
		self._gameRequest:RequestGameXiaZhu(self.curScoreBtnIndex-1,index)
	end
	
end

--开始发牌
function GameTableLayer:StartFaPai()
	self:setGoldAndCardLZ(false)
	self:resetTiShiScheduler()
	self:resetCard()
	self:setCardArrayData()
	self.m_card_layout:setVisible(true)

	if self.m_FaPaiNodeScheduler then
		local scheduler = cc.Director:getInstance():getScheduler()
    	scheduler:unscheduleScriptEntry(self.m_FaPaiNodeScheduler)
    	self.m_FaPaiNodeScheduler=nil
	end

	self:StartFaPaischeduler()
end

--设置上庄数据
function GameTableLayer:setSZlist(dataArray)
	self.SZListData=dataArray
end

--跟新上庄列表
function GameTableLayer:updataSZlist()
	if next(self.SZListData)==nil then
		return
	end
	local dataArray = self.SZListData
	if tostring(dataArray[1])==tostring(UserData.userId) then
		self:reSetXiaZhuBtn()
		self.IsZhuang=true
		self.btn_xiazhuang:setVisible(true)
		self.btn_shangzhuang:setVisible(false)
	else
		self.IsZhuang=false
		self.btn_xiazhuang:setVisible(false)
		self.btn_shangzhuang:setVisible(true)
	end
	--跟新上庄列表
	if self:getChildByTag(Tag.SZList) then
		self:getChildByTag(Tag.SZList):setData(dataArray)
	end

	--跟新庄家信息
	if dataArray[1]~=self.ZhuangUid then
		local Info={}
		self.zhuangHead:removeAllChildren()
		if dataArray[1]>0 then
			Info=GameUserData:getInstance():getUserInfo(dataArray[1])
			self.ZhuangUid=dataArray[1]
			if Info==nil then
				return
			end
		else
			Info.NickName = self.SystemZhuangInfo.NickName or conf.HostZhuangName
			Info.Score = 88888888888888
			Info.AvatarUrl = self.SystemZhuangInfo.AvatarUrl or conf.HostZhuangHeadUrl
			Info.Gender = 2
			self.ZhuangUid = 0
		end
		self.zhuangMoney=Info.Score
		if self.ZhuangUid > 0 then
			self.zhuang_score:setString(conf.switchNum(Info.Score))
		else
			self.zhuang_score:setString("系统当庄")
		end
		self.zhuang_name:setString(string.getMaxLen(tostring(Info.NickName)))

		local paramTab={}
		paramTab.avatarUrl=Info.AvatarUrl
		paramTab.stencilFile=GameResPath.."head_bg.png"
		paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(Info.Gender)
		local headnode=Avatar:create(paramTab)
		headnode:setScale(1.03)
		headnode:setPosition(cc.p(0,-2))
		self.zhuangHead:addChild(headnode)
	end
end

--请求系统庄家头像
function GameTableLayer:RequestSystemZhuangInfo()
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_SYSTEM_ZHUANG_HEAD_URL
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onSystemZhuangInfoCallback))
end

--设置系统庄家头像
function GameTableLayer:_onSystemZhuangInfoCallback( __error,__response )
    if __error then
        print("Player Info net error")
    else
    	dump(__response)
        if 200 == __response.status then
        	local data = __response.data
        	if next(data)~=nil then
        		self.SystemZhuangInfo.AvatarUrl=data.AvatarUrl
				self.SystemZhuangInfo.NickName=data.NickName
				if self.SystemZhuangInfo.NickName and self.SystemZhuangInfo.AvatarUrl and self.ZhuangUid > 0 then
					self.zhuangHead:removeAllChildren()
					local paramTab={}
					paramTab.avatarUrl=self.SystemZhuangInfo.AvatarUrl
					paramTab.stencilFile=GameResPath.."head_bg.png"
					paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(2)
					local headnode=Avatar:create(paramTab)
					headnode:setScale(1.03)
					headnode:setPosition(cc.p(0,-2))
					self.zhuangHead:addChild(headnode)
					self.zhuang_name:setString(string.getMaxLen(tostring(self.SystemZhuangInfo.NickName)))
				end
        	end 
        end
    end
end

--更新玩家列表
function GameTableLayer:updataPlayerList(dataArray)
	if dataArray then
		self.PlayerListData={}
		self.PlayerListData=dataArray
	end
	if self:getChildByTag(Tag.playerList) then
		self:getChildByTag(Tag.playerList):setData(self.PlayerListData)
	end
end

--设置路单数据
function GameTableLayer:setLudanListData(dataArray)
	if dataArray then
		self.LuDanDataArray={}
		self.LuDanDataArray=dataArray
		self:updateSmallLDNodedata()
	end
end

--更新路单
function GameTableLayer:updateList()
	self:startLuDanBtnAction()

	if self:getChildByTag(Tag.recordList) and self.LuDanDataArray then
		self:getChildByTag(Tag.recordList):updateList(self.LuDanDataArray)
	end
end

--播放路单按钮动画
function GameTableLayer:startLuDanBtnAction()
	self.ludan_btn_action:gotoFrameAndPlay(0,false)
	local a = {}
	a[#a+1] = cc.DelayTime:create(1.5)
	a[#a+1] = cc.CallFunc:create(function()
		self.ludan_btn_action:gotoFrameAndPlay(0,false)
	end)

	self:runAction(cc.Sequence:create(a))
end


--更新桌面小路单数据
function GameTableLayer:updateSmallLDNodedata()
	if next(self.LuDanDataArray)==nil then
		return
	end
	self.SmallLuDanDataArray = {}
	for i=1,#self.LuDanDataArray[1] do
		local Tab={}
		for j=1,#self.LuDanDataArray do
			local value=self.LuDanDataArray[j][i]
			table.insert(Tab,value)
		end
		table.insert(self.SmallLuDanDataArray,Tab)
	end

	for i,v in ipairs(self.m_SmallLDNodeArray) do
    	v:setData(self.SmallLuDanDataArray[i])
    end
end

--调整小路单位置
function GameTableLayer:updateSmallLDNodePos()
	if next(self.SmallLuDanDataArray) == nil then
		return
	end
	for i,v in ipairs(self.m_SmallLDNodeArray) do
    	v:adjustPos()
    end
end

--更新桌面小路单数据
function GameTableLayer:updateSmallLDNode()
	for i,v in ipairs(self.m_SmallLDNodeArray) do
		v:update()
	end
end

--更新桌面小路单数据
function GameTableLayer:updateSmallLDNodeByIndex(index)
	if index < 1 or index > 4 then return end
	self.m_SmallLDEffecArray[index]:StartAction()
end

--设置坐下玩家数据
function GameTableLayer:setPlayerSit(dataArray)
	self.sitUidArray=dataArray
end

--更新坐下玩家分数
function GameTableLayer:updataSitPlayerScore()
	if self.sitUidArray==nil then
		return
	end
	for i,v in ipairs(self.sitUidArray) do
		if v>0 then
			local info=GameUserData:getInstance():getUserInfo(v)
			if info then
				local score=info.Score
				if score>=0 then
					local scoreLab=self.m_playerNode[i]:getChildByName("score")
					scoreLab:setString(conf.switchNum(score))
					self.sitScore[i]=score
				end
			end
		end
	end
end

--更新玩家坐下
function GameTableLayer:updataPlayerSit()
	if self.sitUidArray==nil then
		return
	end
	local dataArray=self.sitUidArray
	for i,v in ipairs(dataArray) do
		if v>0 then
			self.m_sitBtnTab[i]:setVisible(false)
			self.m_playerNode[i]:setVisible(true)
			if self.sitUidOldArray[i]~=v then
				local Info=nil
				Info=GameUserData:getInstance():getUserInfo(v)
				if Info==nil then
					GameUserData:getInstance():InitPlayerInfo(v)
					Info=GameUserData:getInstance():getUserInfo(v)
				end
				local score=self.m_playerNode[i]:getChildByName("score")
				local name=self.m_playerNode[i]:getChildByName("name")
				name:setString(string.getMaxLen(Info.NickName))
				score:setString(conf.switchNum(Info.Score))
				self.sitScore[i]=Info.Score
				local Head=self.m_playerNode[i]:getChildByName("head_bg_1")
				Head:removeAllChildren()
				local paramTab={}
				paramTab.avatarUrl=Info.AvatarUrl
				paramTab.stencilFile=GameResPath.."head_bg.png"
				paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(Info.Gender)
				local headnode=Avatar:create(paramTab)
				headnode:setScale(1.05)
				headnode:setPosition(cc.p(-2,-2))
				Head:addChild(headnode)
				self.sitUidOldArray[i]=v
			end
		else
			self.sitUidOldArray[i]=0
			self.m_sitBtnTab[i]:setVisible(true)
			self.m_playerNode[i]:setVisible(false)
		end
	end
end

--开始发牌定时器
function GameTableLayer:StartFaPaischeduler()
	self.m_FaCardNodeIndex=0
	local scheduler = cc.Director:getInstance():getScheduler()  
	self.m_FaPaiNodeScheduler = scheduler:scheduleScriptFunc(function()  
   		self:updateFapai()
	end,0.1,false)
end

--每组发牌动画
function GameTableLayer:updateFapai(dt)
	self.m_FaCardNodeIndex=self.m_FaCardNodeIndex+1
	local index=self.m_FaCardNodeIndex
	MusicManager:getInstance():playAudioEffect(conf.Music["Fapai_one"],false)
	if index>conf.CardNodeNum*conf.Card_Num then
		local scheduler = cc.Director:getInstance():getScheduler()
    	scheduler:unscheduleScriptEntry(self.m_FaPaiNodeScheduler)
    	self.m_FaPaiNodeScheduler=nil
    	self:StartOpenCard()
    	return
	end

	local i=math.modf((index-1)/conf.CardNodeNum)+1
	local j=(index-1)%conf.Card_Num+1
	local Tpos={x=0,y=0}
	Tpos.x=conf.CardNodePos[i].x+(j-3)*conf.Card_X
	Tpos.y=conf.CardNodePos[i].y

	local jp=cc.EaseSineIn:create(cc.JumpTo:create(0.3,Tpos,100, 1))
    local callfunc=cc.CallFunc:create(function(sender)
    		sender:setLocalZOrder(sender:getTag())
    	end)
 	self.m_CardBackArray[index]:runAction(cc.Sequence:create(jp,callfunc))
end

--设置牌的数据
function GameTableLayer:setCardArrayData()
	local dataArry=self.CardData.CardDataArray
	for i,v in ipairs(self.m_CardArray) do
		local res = string.format("%02X",dataArry[i])
		local str="niuniu_card_0x"..res..".png"
		v:initWithSpriteFrameName(str)
	end
end

--设置倍数
function GameTableLayer:setBeiShuData()
	local dataArry=self.CardData.BeiShuArray
	for i,v in ipairs(dataArry) do
		if i~=1 then
			self.m_CardTypeNodeArray[i]:setBeiShu(v)
		end
	end
end

--设置结算数据
function GameTableLayer:setResultData(dataArry)
	self.ResultData=dataArry
	if dataArry==nil then
		return
	end
	local myWinArray=dataArry.myWinArray
	for i,v in ipairs(myWinArray) do
		self.m_CardTypeNodeArray[i+1]:setScore(v)
	end
end

function GameTableLayer:setCardData(dataArry)
	self.CardData=dataArry
	self:setBeiShuData()
end

--开始金币动画
function GameTableLayer:StartResultGold()
	local dataArry=self.ResultData
	if dataArry==nil then
		return
	end
	if self.CardData.CardTyprArray then
		if self.CardData.CardTyprArray[1]>=7 then
			self:PlayerLoseGoldAction(dataArry)
		end
	end

	self:runAction(cc.Sequence:create(cc.DelayTime:create(1.2),cc.CallFunc:create(function()
		if dataArry.zhuangWinArray then
			for i,v in ipairs(dataArry.zhuangWinArray) do
				if v>0 then
					self.m_GoldLayer:ZhuangGetGold(i-1)
				end
			end
    		self:ZhuangGetMoneyAct()
		end
		end)))

	self:runAction(cc.Sequence:create(cc.DelayTime:create(2.4),cc.CallFunc:create(function()
		if dataArry.zhuangWinArray then
			for i,v in ipairs(dataArry.zhuangWinArray) do
				if v<0 then
					self.m_GoldLayer:ZhuangLossGold(i-1,math.abs(v))
				end
			end
			self:ZhuangMoneyAct()
		end
		end)))

	self:runAction(cc.Sequence:create(cc.DelayTime:create(3.6),cc.CallFunc:create(function()
		if dataArry then
			self.m_GoldLayer:PlayerGetGold(dataArry)
			self:PlayerGetGoldAction(dataArry)
		end
		end)))
end

--跟新庄家钱
function GameTableLayer:UpdataZhuangScore()
	if self.ZhuangUid >0 then
		local info=GameUserData:getInstance():getUserInfo(self.ZhuangUid)
		local score=info.Score
		self.zhuangMoney=score
		self.zhuang_score:setString(conf.switchNum(score))
	end
end

--金币动画播完同步钱等数据
function GameTableLayer:ResultUpdata()
	local info=GameUserData:getInstance():getUserInfo(UserData.userId)
	if info then
		local score = info.Score
		self.MyMoney=score
		self.myscore:setString(conf.switchNum(score))
	end
	self:updataSitPlayerScore()
	self:UpdataZhuangScore()
end

--开始翻牌
function GameTableLayer:StartOpenCard()
	for i,v in ipairs(self.m_CardTypeNodeArray) do
		v:setVisible(false)
	end
	self.m_card_type_layout:setVisible(true)
	if self.m_OpenCardScheduler then
		local scheduler = cc.Director:getInstance():getScheduler()
    	scheduler:unscheduleScriptEntry(self.m_OpenCardScheduler)
    	self.m_OpenCardScheduler=nil
	end
	self:StartOpenCardcheduler()

	self:updateSmallLDNodePos()
end

--开始翻牌定时器
function GameTableLayer:StartOpenCardcheduler()
	self.m_OpenCardIndex=0
	local scheduler = cc.Director:getInstance():getScheduler()  
	self.m_OpenCardScheduler = scheduler:scheduleScriptFunc(function()  
   		self:updateOpenCard()
	end,1,false)
end

--每组翻牌动画
function GameTableLayer:updateOpenCard(dt)
	self.m_OpenCardIndex=self.m_OpenCardIndex+1
	if self.m_OpenCardIndex>conf.CardNodeNum then
		local scheduler = cc.Director:getInstance():getScheduler()
    	scheduler:unscheduleScriptEntry(self.m_OpenCardScheduler)
    	self.m_OpenCardScheduler=nil

    	self:setGoldAndCardLZ(true)
    	self:setTishiText("结算中，请稍后...")
    	self:StartResultGold()
    	self:updateList()
    	return
	end
	self:OpenCardAction(self.m_OpenCardIndex)
end

--翻牌动画
function GameTableLayer:OpenCardAction(index)
    for i=(index-1)*conf.Card_Num+1,index*conf.Card_Num do
    	local seq1=cc.Sequence:create(cc.DelayTime:create(0.2),cc.Hide:create())
    	local seq2=cc.Sequence:create(cc.DelayTime:create(0.2),cc.Show:create())
    	local rota1=cc.OrbitCamera:create(0.8,1,0,0,360,0,0)
    	local rota2=cc.OrbitCamera:create(0.4,1,0,180,180,0,0)

    	self.m_CardArray[i]:stopAllActions()
    	self.m_CardBackArray[i]:stopAllActions()
    	self.m_CardArray[i]:runAction(cc.Spawn:create(rota2,seq2))
    	self.m_CardBackArray[i]:runAction(cc.Spawn:create(rota1,seq1))	
    end
	self:CardTypeAction(index)
end

-- --牛牛大小动画
function GameTableLayer:CardTypeAction(index)
	if self.IsZhuang then
		self.m_CardTypeNodeArray[index]:HideMyResult()
	end
	if self.ResultData.zhuangWinArray==nil then
		return
	end
	local zhuangWinArray=self.ResultData.zhuangWinArray
	local value=nil
	if self.CardData.CardTyprArray then
		value=self.CardData.CardTyprArray[index]
	else
		value=0
	end
	local niuniuActionType=nil
	if index==1 then
		niuniuActionType=0
	else
		if zhuangWinArray[index-1]<0 then
			niuniuActionType=1
		else
			niuniuActionType=0
		end
	end
	
	local de=cc.DelayTime:create(0.7)
    local cal=cc.CallFunc:create(function(sender)
		sender:setNiuType(value,niuniuActionType)
    	sender:setVisible(true)
		self:ShowWinQuYu(index)
		local musicStr=conf.Music["nn_type"]..tostring(value)..".mp3"
		MusicManager:getInstance():playAudioEffect(musicStr,false)

		self:updateSmallLDNodeByIndex(index-1)
    	end)
	self.m_CardTypeNodeArray[index]:runAction(cc.Sequence:create(de,cal))
end

--显示赢的区域框
function GameTableLayer:ShowWinQuYu(index)
	if index>1 then
		local myWinArray=self.ResultData.myWinArray
		if myWinArray==nil then
			return
		end
		if myWinArray[index-1]>0 then
			self.m_xuanquSpTab[index-1]:setVisible(true)
		end
	end
end

--重置桌子
function GameTableLayer:resetTable()
	self:stopAllScheduler()
	self.ScoreNode:removeAllChildren()
	self:UpdataUserData()
	self:ResultUpdata()
	self:stopAllActions()
	self.CardData={}
	self.ResultData={}
	self.curXiaZhuGold=0
	self.m_card_layout:setVisible(false)
	self.m_card_type_layout:setVisible(false)
	self:resetGold()

	self:clear()

	for i,v in ipairs(self.m_xuanquSpTab) do
		v:setVisible(false)
	end
	for i,v in ipairs(self.m_MyScoreTextTab) do
		self.m_MyScoreDaraTab[i]=0
		v:setString("")
	end
	for i,v in ipairs(self.m_xuanquTextTab) do
		self.m_xuanquDaraTab[i]=0
		v:setString("")
	end
	for i,v in ipairs(self.m_CardTypeNodeArray) do
		v:stopAllActions()
		v:setVisible(false)
	end
end

--清理桌子
function GameTableLayer:clear()
	if self.SmallDanMuArray then
		for i,v in ipairs(self.SmallDanMuArray) do
			v:reset()
		end
	end

	for i,v in ipairs(self.m_SmallLDEffecArray) do
		v:reset()
	end
end

--开始下注
function GameTableLayer:StartXiaZhu()
	self.IsXiaZhuState=true
	self:setXiaZhuBtnState()
	self.m_gold_layout:setVisible(true)
	MusicManager:getInstance():playAudioEffect(conf.Music["game_start"],false)
end

--停止下注
function GameTableLayer:StopXiaZhu()
	self.IsXiaZhuState=false
	self:reSetXiaZhuBtn()
	MusicManager:getInstance():playAudioEffect(conf.Music["game_stop"],false)
end

--重置下注区域分数显示
function GameTableLayer:resetXiaZhuScore()
	for i,v in ipairs(self.m_MyScoreTextTab) do
		self.m_MyScoreDaraTab[i]=0
		if self.IsZhuang then
			v:setString("庄家不能下注")
		else
			v:setString("点击框内下注") 
		end
	end
	for i,v in ipairs(self.m_xuanquTextTab) do
		self.m_xuanquDaraTab[i]=0
		v:setString("0")
	end
end

--设置最大默认下注按钮状态
function GameTableLayer:setXiaZhuBtnState()
	print("设置最大默认下注按钮状态",(self.MyMoney+self.curXiaZhuGold)<(self.curXiaZhuGold+100)*self.MaxBeiShu,self.IsZhuang,self.IsXiaZhuState)
	if (self.MyMoney+self.curXiaZhuGold)<(self.curXiaZhuGold+100)*self.MaxBeiShu or self.IsZhuang or self.IsXiaZhuState ==false then
		self:reSetXiaZhuBtn()
		return
	end
	self.maxBtnIndex = conf.getMaxBtnIndex(self.MyMoney,self.curXiaZhuGold,self.MaxBeiShu)
	if self.maxBtnIndex  < 1 then
		self:reSetXiaZhuBtn()
	else
		if self.curScoreBtnIndex > self.maxBtnIndex or self.curScoreBtnIndex < 1 then
			local xx,yy=self.m_btn_score[self.maxBtnIndex]:getPosition()
			self.m_btn_select_node:setPosition(cc.p(xx,yy+3))
			self.m_btn_select_node:setVisible(true)
			for i,v in ipairs(self.m_btn_score) do
				if self.maxBtnIndex >= i then
					self.m_btn_score[i]:setEnabled(true)
				else
					self.m_btn_score[i]:setEnabled(false)
				end
			end
			self.curScoreBtnIndex = self.maxBtnIndex
			-- self:setQuYuBtn(true)
		end
	end
end

--设置下注按钮状态变灰
function GameTableLayer:reSetXiaZhuBtn()
	for i,v in ipairs(self.m_btn_score) do
		v:setEnabled(false)
	end
	self.m_btn_select_node:setVisible(false)
	self.curScoreBtnIndex = 0
	-- self:setQuYuBtn(false)
end

--设置下注区域状态
function GameTableLayer:setQuYuBtn(b)
	for i,v in ipairs(self.m_quyuBtnTab) do
		v:setEnabled(b)
	end
end

--设置提示文本
function GameTableLayer:setTishiText(str)
	local tishi_text=self.m_tishiNode:getChildByName("tishi_text")
	tishi_text:setString(str)
	self.m_tishiNode:setVisible(true)
end

--设置提示定时器
function GameTableLayer:setTishiScheduler(str1,timeNum,str2)
	if self.TishiScheduler then
		local scheduler = cc.Director:getInstance():getScheduler()
    	scheduler:unscheduleScriptEntry(self.TishiScheduler)
    	self.TishiScheduler=nil
	end

	self.m_TishiIndex=timeNum or 5
	self.m_TishiStr1=str1 or ""
	self.m_TishiStr2=str2 or ""
	local tishiStr=self.m_TishiStr1..tostring(self.m_TishiIndex)..self.m_TishiStr2
	self:setTishiText(tishiStr)
	local scheduler = cc.Director:getInstance():getScheduler()  
	self.TishiScheduler = scheduler:scheduleScriptFunc(function()  
   		self:updateTiShi()
	end,1,false)
end

function GameTableLayer:updateTiShi()
	self.m_TishiIndex=self.m_TishiIndex-1
	local tishiStr=self.m_TishiStr1..tostring(self.m_TishiIndex)..self.m_TishiStr2
	self:setTishiText(tishiStr)

	if self.m_TishiIndex<1 then
		self:resetTiShiScheduler()
    	return
	end

	if self.m_TishiStr1 == "正在下注" then
		if self.m_TishiIndex<4 and self.m_TishiIndex>1 then
			MusicManager:getInstance():playAudioEffect(conf.Music["game_timeout1"],false)
		elseif self.m_TishiIndex == 1 then
			MusicManager:getInstance():playAudioEffect(conf.Music["game_timeout2"],false)
		end
	end
end

function GameTableLayer:resetTiShiScheduler()
	if self.TishiScheduler then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.TishiScheduler)
	end
	self.TishiScheduler=nil
	self.m_TishiIndex=nil
	self.m_TishiStr1=nil
	self.m_TishiStr2=nil
	self.m_tishiNode:setVisible(false)
end

--开始下注动画
function GameTableLayer:StartXiaZhuAction()
	self.xiazhu_node:setVisible(true)
	self.xiazhu_action:gotoFrameAndPlay(0,false)

	local a={}
	a[#a+1]=cc.DelayTime:create(0.2)
	a[#a+1]=cc.CallFunc:create(function()
		self.particle_start_xiazhu:start()
	end)
	self:runAction(cc.Sequence:create(a))
end

--下注
function GameTableLayer:PlayerXiaZhu(SrcIndex,DestIndex,goldIndex,uid,curScore)
	MusicManager:getInstance():playAudioEffect(conf.Music["coin_jn"],false)
	self.m_GoldLayer:PlayerXiaZhu(SrcIndex,DestIndex,goldIndex,uid)

	--增加区域总分数
	self.m_xuanquDaraTab[DestIndex+1]=self.m_xuanquDaraTab[DestIndex+1]+conf.BetToScore[goldIndex+1]
	local score=self.m_xuanquDaraTab[DestIndex+1]
	self.m_xuanquTextTab[DestIndex+1]:setString(conf.switchNum(score))

	if tostring(uid)==tostring(UserData.userId) then
		--增加区域自己分数
		self.m_MyScoreDaraTab[DestIndex+1]=self.m_MyScoreDaraTab[DestIndex+1]+conf.BetToScore[goldIndex+1]
		local score=self.m_MyScoreDaraTab[DestIndex+1]
		self.m_MyScoreTextTab[DestIndex+1]:setString(conf.switchNum(score))

		--自己下注的钱
  		self.curXiaZhuGold=self.curXiaZhuGold+conf.BetToScore[goldIndex+1]
	end
	self:UpdataUserGold(uid,curScore)
end

--判断是否要更新下注按钮 --当前分数CurScore--已经下注的钱XiaZhuScore--当前最大按钮索引CurMaxIndex
function GameTableLayer:IsUpdataScoreBtn(CurScore,XiaZhuScore,CurMaxIndex)
	if CurMaxIndex < 1 or CurScore < 0 then
		return false
	end
	if self.MaxBeiShu*(conf.BetToScore[CurMaxIndex]+XiaZhuScore) > CurScore then
		return true
	else
		return false
	end
end

-------------------------------------------------断线重连的一些接口-------------------------------------------------
--下注中
function GameTableLayer:OnGameXiaZhuScene(myXiaZhuScoreArray,AllXiaZhuScoreArray)
	if next(AllXiaZhuScoreArray)==nil then
		return
	end
	if next(myXiaZhuScoreArray) then
		for i=1,conf.QUYU_NUM do
			--自己已经下注得钱
			self.curXiaZhuGold=self.curXiaZhuGold+myXiaZhuScoreArray[i]
			--增加区域自己分数
			if self.IsZhuang then
				self.m_MyScoreTextTab[i]:setString("庄家不能下注")
			else
				self.m_MyScoreDaraTab[i]=myXiaZhuScoreArray[i]
				if myXiaZhuScoreArray[i]>0 then
					local score=self.m_MyScoreDaraTab[i]
					self.m_MyScoreTextTab[i]:setString(conf.switchNum(score))
				else
					self.m_MyScoreTextTab[i]:setString("点击框内下注")
				end
			end
		end
	end
	--增加区域总分数
	for i=1,conf.QUYU_NUM do
		self.m_xuanquDaraTab[i]=AllXiaZhuScoreArray[i]
		local score=self.m_xuanquDaraTab[i]
		self.m_xuanquTextTab[i]:setString(conf.switchNum(score))
	end

	self.m_GoldLayer:setXiaZhuGold(AllXiaZhuScoreArray)
	self.m_gold_layout:setVisible(true)
end

--已经发完牌
function GameTableLayer:OnGameOverFaPaiScene()
	self.m_card_layout:setVisible(true)
	self:setCardArrayData()
	self:setGoldAndCardLZ(true)
	for i,v in ipairs(self.m_CardArray) do
		v:setVisible(true)
	end
	for i,v in ipairs(self.m_CardBackArray) do
		v:setVisible(false)
	end
	for i,v in ipairs(self.m_CardTypeNodeArray) do
		v:setNiuTypeScene(self.CardData.CardTyprArray[i])
		v:setVisible(true)
		if i ~= 1 then
			if self.IsZhuang or i == 1 then
				v:HideMyResult()
			end
		end
	end
	--设置倍数
	self:setBeiShuData()
	self.m_card_type_layout:setVisible(true)
end

-------------------------------------------------断线重连的一些接口-------------------------------------------------
--菜单界面
function GameTableLayer:popMenuLayer()
	if self:getChildByTag(Tag.menuLayer) == nil then
		local menuNode=MenuNode.new()
		menuNode:setTag(Tag.menuLayer)
		self:addChild(menuNode,LayZ.menu)
	end
end

--收起菜单界面
function GameTableLayer:closeMenuLayer()
 	if self:getChildByTag(Tag.menuLayer) then
 		self:getChildByTag(Tag.menuLayer):closeLayer()
 	end
end

--设置菜单按钮
function GameTableLayer:setMenuBtn(b)
	local menu_btn=self.m_RootNode:getChildByName("menu_btn")
	menu_btn:setSelected(b)
end

--转换金币层和扑克层上下关系
function GameTableLayer:setGoldAndCardLZ(b)
	if b then
		self.m_gold_layout:setLocalZOrder(LayZ.gold2)
	else
		self.m_gold_layout:setLocalZOrder(LayZ.gold1)
	end
end

--设置自己得钱
function GameTableLayer:setMyMoney(score)
	self.MyMoney=score
	self.myscore:setString(conf.switchNum(self.MyMoney))
end

--自己钱改变动画
function GameTableLayer:MyMoneyAct()
	local score=self:GetUserData(UserData.userId)
	if score==nil then
		return
	end
	self.MyMoney=score
	self.myscore:setString(conf.switchNum(self.MyMoney))
	GameUserData:getInstance():setScore(UserData.userId,self.MyMoney)

	if self.sitUidArray then
		for i,v in ipairs(self.sitUidArray) do
			if tostring(v)==tostring(UserData.userId) then
				self:setSitPlayerInfo(i)
			end
		end
	end
end

--庄家收钱特效
function GameTableLayer:ZhuangGetMoneyAct()
	if self.ResultData==nil then
		return
	end
	local dataArry=self.ResultData.zhuangWinArray
	local b=false
	local Score=0
	for i,v in ipairs(dataArry) do
		if v>0 then
			b=true
			Score=Score+v
		end
	end
	if b then
		local a={}
    	a[#a+1]=cc.DelayTime:create(0.4)
   	 	a[#a+1]=cc.CallFunc:create(function()
    		local ppos=conf.ZhuangHeadPos
   			self:PlayGoldAction(ppos)
    	end)
    	self:runAction(cc.Sequence:create(a))
    	MusicManager:getInstance():playAudioEffect(conf.Music["coin_out"],false)
	end
end

--庄家的钱改变
function GameTableLayer:ZhuangMoneyAct()
	if self.ResultData.zhuangWinArray==nil then
		return
	end
	local dataArry=self.ResultData.zhuangWinArray
	local Score=0
	for i,v in ipairs(dataArry) do
		if v<0 then
			Score=Score+v
		end
	end

	if Score<0 then
		MusicManager:getInstance():playAudioEffect(conf.Music["coin_out"],false)
	end

	if self.ZhuangUid<=0 then
		return
	end
	local score=self:GetUserData(self.ZhuangUid)
	if score then
		self.zhuangMoney=score
		self.zhuang_score:setString(conf.switchNum(score))
		GameUserData:getInstance():setScore(self.ZhuangUid,score)
		if tostring(self.ZhuangUid)==tostring(UserData.userId) then
			self.MyMoney=score
			self.myscore:setString(conf.switchNum(self.MyMoney))
			GameUserData:getInstance():setScore(UserData.userId,self.MyMoney)
		end
	end
end

--玩家得金币动画 
function GameTableLayer:PlayerGetGoldAction(DataArray)
	local myWinArray=DataArray.myWinArray
	local sitWinArray=DataArray.sitWinArray
	if sitWinArray==nil or myWinArray==nil then
		return
	end
	local dataTab = {}
	local dataTab2 = {}
	local isHaveMy=false
	local score=0
	local isGet=false
	local IsPlayerMusic=false
	for i,v in ipairs(myWinArray) do
		if v~=0 then
			isHaveMy=true
		end
		if v>0 then
			isGet=true
			IsPlayerMusic=true
		end
		score=score+v
	end
	if isHaveMy then
		local mytab={}
		mytab.index=7
		mytab.score=score
		table.insert(dataTab,mytab)
		table.insert(dataTab2,mytab)
	end

	local isHaveGold={false,false,false,false,false,false}
	local isHaveScore={false,false,false,false,false,false}
	local tab={}
	for i,v in ipairs(sitWinArray) do
		local score=0
		if tostring(v.uid)~=tostring(UserData.userId) then
			for a,b in ipairs(v.score) do
				if b > 0 then
					isHaveGold[i]=true
					IsPlayerMusic=true
				end
				if b ~= 0 then
					isHaveScore[i] = true
				end
				score=score+b
			end
		end
		table.insert(tab,score)
	end
	for i,v in ipairs(isHaveGold) do
		if v then
			local sittab={}
			sittab.index=i
			sittab.score=tab[i]
			table.insert(dataTab,sittab)
		end
	end
	for i,v in ipairs(isHaveScore) do
		if v then
			local sittab={}
			sittab.index=i
			sittab.score=tab[i]
			table.insert(dataTab2,sittab)
		end
	end
	if IsPlayerMusic then
		MusicManager:getInstance():playAudioEffect(conf.Music["coin_out"],false)
	end
    local a={}
    a[#a+1]=cc.DelayTime:create(0.4)
    a[#a+1]=cc.CallFunc:create(function()
    	if next(dataTab) then
			for i,v in ipairs(dataTab) do
    			if v.index==7 and self.IsZhuang==false then
    				if isGet then
    					local ppos=conf.MyHeadPos
    					self:PlayGoldAction(ppos)
    				end
    				self:MyMoneyAct()
    			end
    			if v.index>0 and v.index<7 then
    				local ppos=cc.p(conf.PlayerNodePos[v.index].x,conf.PlayerNodePos[v.index].y+60)
    				self:PlayGoldAction(ppos)
    			end
    		end
		end
		if next(dataTab2) then
			self:StartPlayScoreAction(dataTab2)
		end
    	end)
    self:runAction(cc.Sequence:create(a))
end

--统一播放分数改变动画
function GameTableLayer:StartPlayScoreAction(dataTab)
	if dataTab then
		for i,v in ipairs(dataTab) do
    		if v.index==7 and self.IsZhuang==false then
    			local ppos=conf.MyHeadPos
    			local score = v.score
				if score > 0 then
					--扣税
					score =  score-score*self.shuilv
				end
    			self:ScoreAction(ppos,conf.switchNum(score))
    		end
    		if v.index>0 and v.index<7 then
    			local ppos=cc.p(conf.PlayerNodePos[v.index].x,conf.PlayerNodePos[v.index].y+60)
    			local score = v.score
				if score > 0 then
					--扣税
					score =  score-score*self.shuilv
				end
    			self:ScoreAction(ppos,conf.switchNum(score))
    		end
    	end
	end
	if self.ResultData.zhuangWinArray then
		local dataArry=self.ResultData.zhuangWinArray
		local Score=0
		for i,v in ipairs(dataArry) do
			Score=Score+v
		end
		local ppos=cc.p(conf.ZhuangHeadPos.x,conf.ZhuangHeadPos.y-30)
		if Score > 0 then
			--扣税
			Score =  Score-Score*self.shuilv
		end
		self:ScoreAction(ppos,conf.switchNum(Score))
	end
end

--玩家陪金币动画 
function GameTableLayer:PlayerLoseGoldAction(DataArray)
	self.m_GoldLayer:PlayerPeiGold(DataArray)
	local myWinArray=DataArray.myWinArray
	local sitWinArray=DataArray.sitWinArray
	local zhuangWinArray=DataArray.zhuangWinArray
	if myWinArray==nil or sitWinArray==nil or zhuangWinArray==nil then
		return
	end
	local dataTab={}
	local isHaveMy=false
	local score=0
	for i,v in ipairs(myWinArray) do
		if v<0 then
			isHaveMy=true
			score=score+v
		end
	end
	if isHaveMy then
		local mytab={}
		mytab.index=7
		mytab.score=score
		table.insert(dataTab,mytab)
	end
	local isHaveSit={false,false,false,false,false,false}
	local tab={}
	for i,v in ipairs(sitWinArray) do
		local score=0
		if tostring(v.uid)~=tostring(UserData.userId) then
			for a,b in ipairs(v.score) do
				if b<0 then
					isHaveSit[i]=true
					score=score+b
				end
			end
		end
		table.insert(tab,score)
	end
	for i,v in ipairs(isHaveSit) do
		if v then
			local sittab={}
			sittab.index=i
			sittab.score=tab[i]
			table.insert(dataTab,sittab)
		end
	end
	if dataTab then
		for i,v in ipairs(dataTab) do
    		if v.index==7 and self.IsZhuang==false then
    			self:MyMoneyAct()
    		end
    		if v.index>0 and v.index<7 then
    			self:setSitPlayerInfo(v.index)
    		end
   	 	end
   	 	MusicManager:getInstance():playAudioEffect(conf.Music["coin_out"],false)
	end
end

--改变坐下玩家信息
function GameTableLayer:setSitPlayerInfo(sitIndex)
	if self.sitUidArray==nil then
		return
	end
	local score=self:GetUserData(self.sitUidArray[sitIndex]) or 0
	if score >= 0 then
		local scoreLab=self.m_playerNode[sitIndex]:getChildByName("score")
		scoreLab:setString(conf.switchNum(score))
		GameUserData:getInstance():setScore(self.sitUidArray[sitIndex],score)
	end
end

--分数变化动画
function GameTableLayer:ScoreAction(ppos,Str)
	local node=ScoreNode.new(Str)
	node:setPosition(ppos)
	self.ScoreNode:addChild(node)

	MusicManager:getInstance():playAudioEffect(conf.Music["score"],false)
end

--获得金币特效
function GameTableLayer:PlayGoldAction(ppos)
	local node = cc.CSLoader:createNode(GameResPath.."gold_effect.csb")
    local act = cc.CSLoader:createTimeline(GameResPath.."gold_effect.csb")
    act:setTimeSpeed(1)
    node:runAction(act)
    act:gotoFrameAndPlay(0,false)
    act:setLastFrameCallFunc(function()
		node:removeFromParent()
	end)
	local particle1 = cc.ParticleSystemQuad:create(GameResPath.."win_effect.plist")
    particle1:setPositionType(cc.POSITION_TYPE_GROUPED )
    particle1:setPosition(0,0)
    node:addChild(particle1)
    particle1:setScale(0.4)
    particle1:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA,gl.DST_ALPHA))
    particle1:start()
    
    self:addChild(node,LayZ.tishi)
    node:setPosition(ppos)
end

--刷新玩家金币 
function GameTableLayer:UpdataUserGold(uid,score)

	GameUserData:getInstance():setScore(uid,score)

	for i,v in ipairs(self.UserData) do
		if uid==v.UserId then
			v.Score=score
		end
	end
	
	if uid == nil or score ==nil then return end
	if tostring(uid) == tostring(UserData.userId) then
		self.MyMoney=score
		if self.MyMoney >= 0 then
			self.myscore:setString(conf.switchNum(score))
		end
		if self.curScoreBtnIndex < 1 then
			self:setXiaZhuBtnState()
		else
			if self:IsUpdataScoreBtn(self.MyMoney-conf.BetToScore[self.curScoreBtnIndex],self.curXiaZhuGold,self.maxBtnIndex) then
				self:setXiaZhuBtnState()
			end
		end
		
	end
	if tostring(uid) == tostring(self.ZhuangUid) then
		self.zhuangMoney = score
		if self.zhuangMoney >= 0 then
			self.zhuang_score:setString(conf.switchNum(score))
		end
	end
	local index=0
	for i,v in ipairs(self.sitUidArray) do
		if tostring(uid) == tostring(v) then
			index = i
		end
	end
	if index > 0 then
		self.sitScore[index]=score
		local sitScoreLab=self.m_playerNode[index]:getChildByName("score")
		if self.sitScore[index]>=0 then
			sitScoreLab:setString(conf.switchNum(self.sitScore[index]))
		end
	end
end

--保存玩家金币数据
function GameTableLayer:PreservationUserData(dataArray)
	self.UserData=dataArray
end

--获取玩家金币数据
function GameTableLayer:GetUserData(uid)
	if self.UserData==nil then
		return
	end
	for i,v in ipairs(self.UserData) do 
		if uid==v.UserId then
			return v.Score
		end
	end
end

--判断玩家是否在桌面上(座位1~6，自己7，庄家8)
function GameTableLayer:getPlayerOnTable(uid)
	local key = 0
	if tostring(uid) == tostring(self.ZhuangUid) then
		key = 8
	end
	for i,v in ipairs(self.sitUidArray) do
		if tostring(uid) == tostring(v) then
			key = i
		end
	end
	if tostring(uid) == tostring(UserData.userId) then
		key = 7
	end
	return key
end

--设置玩家金币数据
function GameTableLayer:SetUserData(uid,Score)
	if self.UserData==nil then
		return
	end
	for i,v in ipairs(self.UserData) do 
		if uid==v.UserId then
			v.Score=v.Score+Score
		end
	end
end

--设置最小上庄
function GameTableLayer:SetSZMinScore(score)
	if score then
		self.zhuangMinScore = score
	end
end

--设置坐下条件
function GameTableLayer:SetSitMinScore(score)
	if score then
		self.sit_score_lab:setString("入座条件:金币≥"..conf.switchNum(score))
	end
end


--设置税率
function GameTableLayer:SetSuiLv(num)
	if num then
		self.shuilv = num
	end
end

--设置税率
function GameTableLayer:SetMaxBeiShu(num)
	if num then
		self.MaxBeiShu = num
	end
end

--保存玩家金币数据
function GameTableLayer:UpdataUserData()
	GameUserData:getInstance():updataScore(self.UserData)
end

-- 聊天文本
function GameTableLayer:onGameChatText(data)
	local tab = {}
	tab.uid = data.uid
	tab.strType = data.strType
	tab.value = data.str
	if tab.strType == "T" then
		tab.value = conf.ChatText[tonumber(data.str)]
	end
	tab.type = 0
	tab.info = GameUserData:getInstance():getUserInfo(data.uid)
	table.insert(self.ChatListData,tab)
	local key = self:getPlayerOnTable(tab.uid)
	if key > 0 then
		self.SmallDanMuArray[key]:setStrData(tab.value)
		if tab.strType == "T" then
			local sex = tab.info.Gender or 1
			local musicStr = nil
			if sex == 1 then
				musicStr = "Man"
			else 
				musicStr = "Woman"
			end
			musicStr = musicStr.."_Chat_"..data.str..".mp3"
			MusicManager:getInstance():playAudioEffect(conf.Music["chat_effect"]..musicStr,false)
		end
	else
		self.m_DanMuNode:addData(tab.uid,0,tab.value)
	end
	if self:getChildByTag(Tag.chatList) then
		self:getChildByTag(Tag.chatList):addData(tab)
	end
end

-- 聊天表情 
function GameTableLayer:onGameChatBrow(data)
	local tab={}
	tab.uid=data.uid
	tab.value=data.browId
	tab.type=1
	tab.info=GameUserData:getInstance():getUserInfo(data.uid)
	table.insert(self.ChatListData,tab)

	local key = self:getPlayerOnTable(tab.uid)
	if key > 0 then
		self.SmallDanMuArray[key]:setBrowData(tab.value)
	else
		self.m_DanMuNode:addData(data.uid,1,data.browId)
	end

	if self:getChildByTag(Tag.chatList) then
		self:getChildByTag(Tag.chatList):addData(tab)
	end
end

-- 道具 
function GameTableLayer:onGameProp(data)
	local SrcUid=data.SrcUid
	local DestUid=data.DestUid
	local PropIndex=data.PropIndex
	local curScore=data.curScore
	self:UpdataUserGold(SrcUid,curScore)

	local SrcPos=nil
	local DestPos=nil

	--发道具的玩家是否坐下
	local SrcIsSit=false
	local SrcIndex=0
	local DestIsSit=false
	local DestIndex=0
	if self.sitUidArray then
		for i,v in ipairs(self.sitUidArray) do
			if tostring(v)==tostring(SrcUid) then
				SrcIsSit=true
				SrcIndex=i
			end
			if tostring(v)==tostring(DestUid) then
				DestIsSit=true
				DestIndex=i
			end
		end
	end
	
	--发道具玩家对应位置
	if tostring(SrcUid)==tostring(UserData.userId) then
		SrcPos=conf.MyHeadPos
	else
		if SrcIsSit then
			SrcPos=cc.p(conf.PlayerNodePos[SrcIndex].x,conf.PlayerNodePos[SrcIndex].y+60)
		else
			local ppos = nil
			if tostring(SrcUid)==tostring(self.ZhuangUid) then
				ppos=conf.ZhuangHeadPos
			else
				local people_btn=self.m_RootNode:getChildByName("people_btn")
				ppos={}
				ppos.x,ppos.y=people_btn:getPosition()
			end
			SrcPos=ppos
		end
	end
	--道具目标玩家对应位置
	if tostring(DestUid)==tostring(self.ZhuangUid) then
		DestPos=conf.ZhuangHeadPos
	elseif DestIsSit then
		DestPos=cc.p(conf.PlayerNodePos[DestIndex].x,conf.PlayerNodePos[DestIndex].y+60)
	end
	local node=FrameAniFactory:getInstance():getDaoJuNode(PropIndex,SrcPos,DestPos)
	self:addChild(node,LayZ.daoju)
end

--破产补助
function GameTableLayer:onGameBankRupt(data)
	dump(data)
	local curTimes = data.curTimes
    local sumTimes = data.sumTimes 
	local bankGoldNum = data.bankGoldNum
    local getSign = data.getSign
    if curTimes>sumTimes then
    	if not manager.UserManager:getInstance():findAppCloseRoomCardFlag() then
    		self:onShopBtnEvent()
    	end
    	
    elseif self:getChildByTag(Tag.sub)==nil then
    	local sub = Subsidy:new()
    	sub:setTag(Tag.sub)
    	sub:initLayer(bankGoldNum,getSign)
    	self:addChild(sub,LayZ.playerInfo)
    end
end

--破产补助领取成功
function GameTableLayer:onGameBankSucc(data)
	if tostring(UserData.userId) == tostring(data.uid) then
		GameUtils.showMsg("领取成功")
	end
	self:UpdataUserGold(data.uid,data.curScore)
end

return GameTableLayer