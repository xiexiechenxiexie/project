----------------------------------------
--金币牛牛子类
----------------------------------------

-- 游戏主界面 牛牛
-- @date 2017.07.13
-- @author tangwen

local  GamePlayInfo = class("GamePlayInfo")
 GamePlayInfo.AvatarUrl   = ""
 GamePlayInfo.Gender      = 2
 GamePlayInfo.NickName    = "游客?"
 GamePlayInfo.RoomCardNum = 0
 GamePlayInfo.Score       = 0
 GamePlayInfo.UserId      = 0
 GamePlayInfo.diamond     = 0
function GamePlayInfo:ctor( __params )
	assert(__params.userId,"invalide userId")
	self.AvatarUrl   = ""
	self.Gender      = __params.Gender or ConstantsData.SexType.SEX_WOMEN
	self.NickName    = __params.NickName or tostring(__params.userId)
	self.RoomCardNum = __params.RoomCardNum or 0
	self.Score       = __params.Score or 0 --金币
	self.UserId      = __params.UserId or 0
	self.diamond     = __params.diamond or 0
end

local GameModel = require "gamemodel/scene/GameModelScene"
local GameResPath  = "game/niuniu/res/GameLayout/NiuNiu/"
local NIUNIU_CSB = GameResPath .. "Layer.csb"
local goldNiuScene = class("goldNiuScene", GameModel)

local GameManager = require"game/niuniu/src/logic/GoldGameManager"
local conf = require"game/niuniu/src/scene/conf"
local head = require "game/niuniu/src/header/headerFile"
local GameRequest = require "game/niuniu/src/request/GameRequest"
local tableAction = require "game/niuniu/src/scene/tableAction"
local Avatar = require "lib/component/node/Avatar"
local help = require "game/niuniu/src/scene/help"
local GamePlayerInfo = require "GamePlayerInfoView"
local subsidy = require "gamecommon/subsidy/src/SubsidyLayer"
local chatNode = require "gamecommon/chat/src/ChatLayer"
local MenuNode = require "game/niuniu/src/scene/MenuNode"
local CardTypeNode = require "game/niuniu/src/scene/CardTypeNode"
local Score = require "game/niuniu/src/scene/ScoreNode"
local FrameAniFactory=cc.exports.lib.factory.FrameAniFactory
local MusicManager=cc.exports.manager.MusicManager
local scheduler = cc.Director:getInstance():getScheduler()

-- 功能按钮标识
goldNiuScene.BTN_MORE_SHOW	    	= 1				-- 更多显示
goldNiuScene.BTN_MORE_HIDE	    	= 2				-- 更多隐藏
goldNiuScene.BTN_CHAT               = 3             -- 聊天

local SESS_COLOR = cc.c3b(228,168,85)

local userInfo = {}

-- 初始化界面`
function goldNiuScene:ctor()
    self.MaxPlayer = 5
    -- self.isGameing = false
    self._gameStatus = conf.goldState.freetime
    
    self.niuNum = 0                     --根据值判断有牛还是没牛：0没牛，1有牛
    self.handCard = {}                  --存放自己的牌
    self.handBackCard = {{},{},{},{},{}}--按照转换后的椅子id来存放的每个人的背面牌
    self.allSortCard = {}               --存放所有玩家摊牌之后的牌
    self.cardTyoeArray = {}             --存放牌型
    self.gradArray = {}                 --存放玩家抢庄的倍数
    self.brttingMArray = {}             --存放玩家下注的倍数
    self.txtArray = {}                  --存放完成

    self.playerInfoData = {}    		--玩家信息
    self.myid = nil						--自己的椅子id
    self.uidArray = {}					--玩家列表
    self.CardData = {}                  --玩家牌数据
    self.locakBankSeatid = nil		    --庄家的椅子id(本地)
	self.playerDataArray = {}			--结算时玩家数据
	self.playerArr = {} 				--结算玩家数据
	self.clickCard = {}                 --点击的牌
    self.clickCardValue = {}            --点击的牌值
    self.clickCardNode = {}             --点击的牌值的节点
    self.chatDataArray = {}             --聊天数据
	self.clickNum = 0                   --点击次数
    self.playerCoinArr = {}             --玩家金币数据数组
    self.headDataArray = {}             --加载到界面的头像数据
    self.NameDataArray = {}             --加载到界面的名字数据
    self.ChatListData = {}              --聊天数据
    self.PlayerDataSync = {}            --数据同步
    self.FifthCardData = nil            --第五张牌得值
    self.luckCardData = {}              --运气牌数组
    self.goldAction = {}                --存放金币动画
    self.isOnTable = false              --是否坐下
    self.isStart = false                --是否开始
    self.myResuId = 0                   --结算时自己的椅子id

    self.myCattType = 0                 --保存自己的牌型

	self:initGemeData()
    self:enableNodeEvents()  -- 注册 onEnter onExit 时间 by  tangwen
    --self:preloadUI()
    self:CreateView()
    self._gameRequest = GameRequest:new()
end

function goldNiuScene:preloadUI()
	display.loadSpriteFrames(GameResPath.."GameBtn.plist",
							GameResPath.."GameBtn.png")
	display.loadSpriteFrames(GameResPath.."UserBtn.plist",
							GameResPath.."UserBtn.png")
	display.loadSpriteFrames(GameResPath.."GameBtn_L.plist",
							GameResPath.."GameBtn_L.png")
	display.loadSpriteFrames(GameResPath.."NiuTip.plist",
							GameResPath.."NiuTip.png")
	display.loadSpriteFrames(GameResPath.."card/niuniu_card.plist",
							GameResPath.."card/niuniu_card.png")
	display.loadSpriteFrames(GameResPath.."private_More.plist",
							GameResPath.."private_More.png")
	display.loadSpriteFrames(GameResPath.."playerPanel.plist",
							GameResPath.."playerPanel.png")
	display.loadSpriteFrames(GameResPath.."help.plist",
							GameResPath.."help.png")
	display.loadSpriteFrames("gamecommon/subsidy/res/subsidy.plist",
							"gamecommon/subsidy/res/subsidy.png")
	display.loadSpriteFrames("gamecommon/chat/res/chat.plist",
       						"gamecommon/chat/res/chat.png")
	FrameAniFactory:getInstance():addAllSpriteFrames()
	display.loadSpriteFrames("gamecommon/shopAction.plist",
       						"gamecommon/shopAction.png")
	display.loadSpriteFrames(GameResPath.."action/goldniuniu_start.plist",
							GameResPath.."action/goldniuniu_start.png")
	display.loadSpriteFrames(GameResPath.."win/goldniu_win.plist",
							GameResPath.."win/goldniu_win.png")
    display.loadSpriteFrames(GameResPath.."winHead/goldniuniu_player_effect.plist",
                            GameResPath.."winHead/goldniuniu_player_effect.png")
    display.loadSpriteFrames(GameResPath.."CardType.plist",
                            GameResPath.."CardType.png")
end
function goldNiuScene:initGemeData()
	self._playerDataList ={}
end

-- 创建界面
function goldNiuScene:CreateView()
	-- local bg = ccui.Button:create(GameResPath.."bg_gold.png")

    --测试代码
    -- self.clearBtn = ccui.Button:create(GameResPath.."txt_ready.png")
    -- self.clearBtn:setPosition(cc.p(700,700))
    -- self.clearBtn:setLocalZOrder(1000)
    -- self:addChild(self.clearBtn)
    -- self.clearBtn:addClickEventListener(function()
    --   self:clearCache()
    -- end)

    -- self.reBtn = ccui.Button:create(GameResPath.."txt_ready.png")
    -- self.reBtn:setPosition(cc.p(900,700))
    -- self.reBtn:setLocalZOrder(1000)
    -- self:addChild(self.reBtn)
    -- self.reBtn:addClickEventListener(function()
    --     self._gameRequest:RequestTabelInfo()
    -- end)

    local bg = display.newSprite(GameResPath.."bg.png")
    bg:setPosition(667,375)
    self.bg = bg
    self:addChild(bg)

    local container = cc.CSLoader:createNode(NIUNIU_CSB)
	bg:addChild(container)
    local bgScene = container:getChildByName("bg")
    bgScene:setTexture(GameResPath.."bg_gold.png")

    --更多
    local MoreBtn_hide = container:getChildByName("Button_more_hide")
    MoreBtn_hide:hide()
    MoreBtn_hide:setTag(goldNiuScene.BTN_MORE_HIDE)
    MoreBtn_hide:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    self.MoreBtn_hide = MoreBtn_hide
    local MoreBtn_show = container:getChildByName("Button_more_show")
    MoreBtn_show:setTag(goldNiuScene.BTN_MORE_SHOW)
    MoreBtn_show:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    self.MoreBtn_show = MoreBtn_show

 	--抢庄下注按钮节点
 	local panel = container:getChildByName("Panel_Rate")--下注
 	local panel1 = container:getChildByName("Panel_Rate0")--抢庄
 	local panel_pri = container:getChildByName("Panel_Rate_Pre1")--私人
 	local panel_pri1 = container:getChildByName("Panel_Rate_Pre2")--私人
 	panel:hide()
 	panel1:hide()
 	panel_pri:hide()
 	panel_pri1:hide()
 	self.panel = panel
 	self.panel1 = panel1

 	--聊天
 	local chatBtn = container:getChildByName("Button_chat")
 	chatBtn:setTag(goldNiuScene.BTN_CHAT)
 	chatBtn:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    self.chatBtn = chatBtn
 	--有牛按钮
 	local hasNiuBtn = container:getChildByName("Button_has_niu")
 	hasNiuBtn:setTag(conf.Tag.hasniu)
 	hasNiuBtn:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	hasNiuBtn:hide()
    hasNiuBtn:setTouchEnabled(false)
    hasNiuBtn:setBright(false)
 	self.hasNiuBtn = hasNiuBtn
 	--无牛按钮
 	local noNiuBtn = container:getChildByName("Button_no_niu")
 	noNiuBtn:setTag(conf.Tag.noniu)
 	noNiuBtn:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	noNiuBtn:hide()
 	self.noNiuBtn = noNiuBtn

 	--抢庄(金币)
 	local goldbank0 = panel1:getChildByName("Button_Rate_0")
 	local goldbank1 = panel1:getChildByName("Button_Rate_1")
 	local goldbank2 = panel1:getChildByName("Button_Rate_2")
 	local goldbank3 = panel1:getChildByName("Button_Rate_3")
 	local goldbank4 = panel1:getChildByName("Button_Rate_4")
 	goldbank0:setTag(conf.goldTag.bank0) self.goldbank0 = goldbank0
 	goldbank1:setTag(conf.goldTag.bank1) self.goldbank1 = goldbank1
 	goldbank2:setTag(conf.goldTag.bank2) self.goldbank2 = goldbank2
 	goldbank3:setTag(conf.goldTag.bank3) self.goldbank3 = goldbank3
 	goldbank4:setTag(conf.goldTag.bank4) self.goldbank4 = goldbank4
 	goldbank0:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	goldbank1:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	goldbank2:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	goldbank3:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	goldbank4:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    --下注(金币)
 	local goldbrtting5  = panel:getChildByName("Button_Rate_5")
 	local goldbrtting10 = panel:getChildByName("Button_Rate_10")
 	local goldbrtting15 = panel:getChildByName("Button_Rate_15")
 	local goldbrtting20 = panel:getChildByName("Button_Rate_20")
 	local goldbrtting25 = panel:getChildByName("Button_Rate_25")
 	goldbrtting5:setTag(conf.goldTag.brtting5) self.goldbrtting5 = goldbrtting5
 	goldbrtting10:setTag(conf.goldTag.brtting10) self.goldbrtting10 = goldbrtting10
 	goldbrtting15:setTag(conf.goldTag.brtting15) self.goldbrtting15 = goldbrtting15
 	goldbrtting20:setTag(conf.goldTag.brtting20) self.goldbrtting20 = goldbrtting20
 	goldbrtting25:setTag(conf.goldTag.brtting25) self.goldbrtting25 = goldbrtting25
 	goldbrtting5:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	goldbrtting10:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	goldbrtting15:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	goldbrtting20:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	goldbrtting25:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    --玩家头像框
 	local playerNode1 = container:getChildByName("playerNode1")
 	local playerNode2 = container:getChildByName("playerNode2")
 	local playerNode3 = container:getChildByName("playerNode3")
 	local playerNode4 = container:getChildByName("playerNode4")
 	local playerNode5 = container:getChildByName("playerNode5")
 	local player1 = playerNode1:getChildByName("player1") self.player1 = player1 player1:hide()
 	local player2 = playerNode2:getChildByName("player2") self.player2 = player2 player2:hide()
 	local player3 = playerNode3:getChildByName("player3") self.player3 = player3 player3:hide()
 	local player4 = playerNode4:getChildByName("player4") self.player4 = player4 player4:hide()
 	local player5 = playerNode5:getChildByName("player5") self.player5 = player5 player5:hide()
 	player1:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	player2:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	player3:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	player4:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	player5:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	player1:setTag(conf.Tag.play1)
 	player2:setTag(conf.Tag.play2)
 	player3:setTag(conf.Tag.play3)
 	player4:setTag(conf.Tag.play4)
 	player5:setTag(conf.Tag.play5)
    self._playBtnList = {} 
    table.insert(self._playBtnList,player1)
    table.insert(self._playBtnList,player2)
    table.insert(self._playBtnList,player3)
    table.insert(self._playBtnList,player4)
    table.insert(self._playBtnList,player5)

 	-- local zhuang1 = playerNode1:getChildByName("zhuang1") zhuang1:hide()
 	-- local zhuang2 = playerNode2:getChildByName("zhuang2") zhuang2:hide()
 	-- local zhuang3 = playerNode3:getChildByName("zhuang3") zhuang3:hide()
 	-- local zhuang4 = playerNode4:getChildByName("zhuang4") zhuang4:hide()
 	-- local zhuang5 = playerNode5:getChildByName("zhuang5") zhuang5:hide()

    --座位按钮
    self._sitBtnList = {} 
    local sit1 = playerNode1:getChildByName("sit1") self.sit1 = sit1 sit1:setTag(conf.Tag.sit1)
    local sit2 = playerNode2:getChildByName("sit2") self.sit2 = sit2 sit2:setTag(conf.Tag.sit2)
    local sit3 = playerNode3:getChildByName("sit3") self.sit3 = sit3 sit3:setTag(conf.Tag.sit3)
    local sit4 = playerNode4:getChildByName("sit4") self.sit4 = sit4 sit4:setTag(conf.Tag.sit4)
    local sit5 = playerNode5:getChildByName("sit5") self.sit5 = sit5 sit5:setTag(conf.Tag.sit5)
    table.insert(self._sitBtnList,self.sit1)
    table.insert(self._sitBtnList,self.sit2)
    table.insert(self._sitBtnList,self.sit3)
    table.insert(self._sitBtnList,self.sit4)
    table.insert(self._sitBtnList,self.sit5)

    sit1:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    sit2:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    sit3:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    sit4:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    sit5:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    --商店
    if not manager.UserManager:getInstance():findAppCloseRoomCardFlag() then 
     	local shop_btn = ccui.Button:create()
    	shop_btn:loadTextureNormal("shop_car.png", UI_TEX_TYPE_PLIST)
    	shop_btn:setPosition(1250,670)
    	shop_btn:setTag(conf.Tag.shop)
    	shop_btn:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    	self.bg:addChild(shop_btn)


    	local shop_btn_node = cc.CSLoader:createNode("gamecommon/shop_ani.csb")
    	shop_btn:setTag(conf.Tag.shop)
    	shop_btn_node:setPosition(1250,670)
    	self.bg:addChild(shop_btn_node)
        local shopAct = cc.CSLoader:createTimeline("gamecommon/shop_ani.csb")
        shopAct:setTimeSpeed(1)
        shop_btn_node:runAction(shopAct)
        shopAct:gotoFrameAndPlay(0,true)
    end

    --开始动画
 	local node = cc.CSLoader:createNode(GameResPath.."action/goldniuniu_ani_start.csb")
	node:setPosition(0,0)
	self:addChild(node)
    local act = cc.CSLoader:createTimeline(GameResPath.."action/goldniuniu_ani_start.csb")
    act:setTimeSpeed(1) --设置执行动画速度
    node:runAction(act)
    node:setVisible(false)
    self.xiazhu_node=node
    self.xiazhu_action=act
    --开始动画粒子
	local particle = cc.ParticleSystemQuad:create(GameResPath.."action/start_effect_new.plist")
	particle:setTexture(cc.Director:getInstance():getTextureCache():addImage(GameResPath.."action/effect_start.png"))
    particle:setPositionType(cc.TMX_TILE_HORIZONTAL_FLAG)
    particle:setPosition(display.cx,display.cy+20)
    self:addChild(particle)
    particle:stop()
    particle:setDuration(0.5)
    self.particleparticle=particle
    --胜利动画
 	local winNode = cc.CSLoader:createNode(GameResPath.."win/goldniuniu_win.csb")
	winNode:setPosition(0,0)
	self:addChild(winNode)
    local winAct = cc.CSLoader:createTimeline(GameResPath.."win/goldniuniu_win.csb")
    winAct:setTimeSpeed(1) --设置执行动画速度
    winNode:runAction(winAct)
    winNode:setVisible(false)
    self.winNode=winNode
    self.winAction=winAct
    --胜利动画粒子
    local winActPart = cc.ParticleSystemQuad:create(GameResPath.."win/particle_texture(4).plist")
    winActPart:setPositionType(cc.TMX_TILE_HORIZONTAL_FLAG)
    winActPart:setPosition(display.cx,display.cy)
    self:addChild(winActPart)
    winActPart:stop()
    winActPart:setDuration(0.5)
    self.winActPart=winActPart


    --失败动画
    local loseNode = cc.CSLoader:createNode(GameResPath.."lose/Scene.csb")
    loseNode:setPosition(0,0)
    self:addChild(loseNode)
    local loseAct = cc.CSLoader:createTimeline(GameResPath.."lose/Scene.csb")
    loseAct:setTimeSpeed(1) --设置执行动画速度
    loseNode:runAction(loseAct)
    loseNode:setVisible(false)
    self.loseNode=loseNode
    self.loseAction=loseAct

    --运气爆棚
    local luckNode = cc.CSLoader:createNode(GameResPath.."CardType.csb")
    luckNode:setPosition(667,375)
    self:addChild(luckNode,100)
    local luckAct = cc.CSLoader:createTimeline(GameResPath.."CardType.csb")
    luckAct:setTimeSpeed(1) --设置执行动画速度
    luckNode:runAction(luckAct)
    luckNode:setVisible(false)
    local saoguang = luckNode:getChildByName("saoguang")
    saoguang:setVisible(false)
    local Bone = luckNode:getChildByName("Bone_5")
    local luckEffect = cc.Sprite:createWithSpriteFrameName("Card type_effect.png")
    luckEffect:setPosition(-350,0)
    luckEffect:setVisible(false)
    Bone:addChild(luckEffect)
    self.luckEffect=luckEffect
    self.luckNode=luckNode
    self.luckAction=luckAct
    self:setLuckActCard()
	
    --算牛框
    local suanniukuang = cc.Sprite:create(GameResPath.."suanniukuang.png")
    suanniukuang:setPosition(667,245)
    suanniukuang:hide()
    self.bg:addChild(suanniukuang)
    self.suanniukuang = suanniukuang

    --金币牛牛场次信息
    local goldNiuConf = cc.Label:createWithSystemFont("",SYSFONT, 24)
    goldNiuConf:setPosition(667,190)
    goldNiuConf:setColor(SESS_COLOR)
    self.bg:addChild(goldNiuConf)
    self.goldNiuConf=goldNiuConf

    --广播
	local broadCastView = require("Lobby/src/lobby/view/BroadCastView").new(1)
	self:addChild(broadCastView)  

    --颜色层
    local layerColor = cc.LayerColor:create(cc.c4b(10,10,10,120), display.width, display.height)
    layerColor:setVisible(false)
    self:addChild(layerColor,25)
    self.layerColor = layerColor
end
--更新游戏规则
function goldNiuScene:upDataRule()
    local data = lobby.GamePlayManager:getInstance():findSelectItemData()
    if data == nil then
        return
    end

    if data.way == ConstantsData.CalCattleType.TYPE_AUTO then
        self.goldNiuConf:setString(data.name.."  底分:"..data.floorScore.."  每局消耗:"..data.fee.."  自动算牛")
    elseif data.way == ConstantsData.CalCattleType.TYPE_MANUAL then
        self.goldNiuConf:setString(data.name.."  底分:"..data.floorScore.."  每局消耗:"..data.fee.."  手动算牛")
    end

    self.data = data     -- 保存游戏配置
end

function goldNiuScene:showGamePlayerInfo(data)
	self._userDataList = {}
	table.insert(self._userDataList,data)
	local playerInfoView = GamePlayerInfo.new(data.UserId)
	playerInfoView:setPosition(0,0)
	self:addChild(playerInfoView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
end
--設置椅子隱藏顯示
function goldNiuScene:setSitHide()
    for k,v in pairs(self._sitBtnList) do
        v:hide()
    end
end
function goldNiuScene:setSitShow()
    for k,v in pairs(self._sitBtnList) do
        v:show()
    end
end
--玩家頭像隱藏
function goldNiuScene:setPlayHide()
    for k,v in pairs(self._playBtnList) do
        v:hide()
    end
end

function goldNiuScene:updatePlayerInfo(seatId,uid,uidArray)
	self:initData(uidArray)
	--请求玩家信息
	self:RequestUserInfo(uid)
end

--显示玩家头像
function goldNiuScene:setPlayerNodeVisbile(seatId,isVisible)
	if seatId == 1 then
		self.player1:show() 
		self.sit1:hide()
	elseif seatId == 2 then
		self.player2:show()
		self.sit2:hide()
	elseif seatId == 3 then
		self.player3:show()
		self.sit3:hide()
	elseif seatId == 4 then
		self.player4:show()
		self.sit4:hide()
	elseif seatId == 5 then
		self.player5:show()
		self.sit5:hide()
	end
end

function goldNiuScene:initData(uidArray)
	self.uidArray = uidArray
    self.myid = 0
	for k,v in pairs(uidArray) do
		if tostring(v.uid) == tostring(UserData.userId) then
			self.myid=k-1
		end 
	end
end
--更新玩家头像信息
function goldNiuScene:updateInfor(dataArry)
	if dataArry == nil and self.uidArray ==nil then
		return
	end
    self:updateAvatarByData(dataArry)
end

function goldNiuScene:updateAvatarByData(__data)
	local curUserData = self:checkUserData(__data.UserId)
	if curUserData == 0 or self.uidArray == nil or self.myid==nil then
		return
	end
	if next(__data)~=nil then
		local swichId = conf.swichPos(__data.seatIndex-1,self.myid,5)
        self:hidePlayerBySeatID(swichId)
		self:setPlayerNodeVisbile(swichId,true)

        local paramTab = {}
		paramTab.avatarUrl = __data.AvatarUrl
		paramTab.stencilFile = GameResPath.."player/head_bg.png"
		paramTab.frameFile = GameResPath.."player/head_clip_bg.png"
        
        local Gender = __data.Gender or 0
        paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(Gender)

		local headnode = lib.node.Avatar:create(paramTab)
		if swichId == 2 or swichId == 5 then
			headnode:setPosition(conf.PlayerPosArray[swichId].x+21,conf.PlayerPosArray[swichId].y+83)
		else
			headnode:setPosition(conf.PlayerPosArray[swichId].x+15,conf.PlayerPosArray[swichId].y+15)
		end
		self.bg:addChild(headnode,30)
        
        self.headDataArray[swichId] = headnode
        --table.insert(self.headDataArray,headnode)
		
        local nickName = cc.Label:createWithSystemFont(string.getMaxLen(__data.NickName,6),SYSFONT,24)
		if swichId == 2 or swichId == 5 then
			nickName:setPosition(conf.PlayerPosArray[swichId].x+68,conf.PlayerPosArray[swichId].y+70)
		else
			nickName:setPosition(conf.PlayerPosArray[swichId].x+180,conf.PlayerPosArray[swichId].y+80)
		end
		self.bg:addChild(nickName,30)

        self.NameDataArray[swichId] = nickName
        --table.insert(self.NameDataArray,nickName)
        if self.PlayerDataSync then
            for i,v in ipairs(self.PlayerDataSync) do
                if v.uid == __data.UserId then
                    __data.Score = v.score
                end
            end
        end
        local gameCoin = cc.Label:createWithSystemFont(conf.switchNum(__data.Score),SYSFONT,24)
		gameCoin:setTag(swichId)
		if swichId == 2 or swichId == 5 then
			gameCoin:setPosition(conf.PlayerPosArray[swichId].x+68,conf.PlayerPosArray[swichId].y+35)
		else
			gameCoin:setPosition(conf.PlayerPosArray[swichId].x+180,conf.PlayerPosArray[swichId].y+40)
		end
		
        self.playerCoinArr[swichId] = gameCoin
        --table.insert(self.playerCoinArr,gameCoin)
		
        self.bg:addChild(gameCoin,30)
		table.insert(self._playerDataList,__data)
	end
end

-- 检查是否已经加载了用户信息
function goldNiuScene:checkUserData(__userID)
	for k,v in pairs(self._playerDataList) do
		if __userID == v.UserId then 
			return 0
		end
	end
end

-- 请求用户信息
function goldNiuScene:RequestUserInfo( __userID)
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_PLAYER_INFO .. __userID
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onInfoCallback))
end

function goldNiuScene:_onInfoCallback( __error,__response )
    if __error then
        print("Player Info net error")
    else
        if 200 == __response.status then
        	local data = __response.data.profile
        	if next(data)~=nil then
        		local kValue=data.UserId
        		if self.playerInfoData[kValue] == nil then
                    if self.playerListUID then
                        for k,v in pairs(self.playerListUID) do
                            if v.uid == kValue then
                                data.seatIndex = v.sit + 1
                            end
                        end
                    end
	        		self.playerInfoData[kValue]=data
                    self:setPlayerInfo(kValue)
	        	end
                if data.seatIndex == nil then
                    return
                end
        		self:updateInfor(self.playerInfoData[kValue])

                userInfo[kValue].AvatarUrl=data.AvatarUrl
                userInfo[kValue].Gender=data.Gender
                userInfo[kValue].NickName=data.NickName
                userInfo[kValue].Score=data.Score
                userInfo[kValue].UserId=kValue
                userInfo[kValue].winroundsum=data.winroundsum
                userInfo[kValue].losesum=data.losesum
                userInfo[kValue].winning=data.winning
                userInfo[kValue].seatIndex=data.seatIndex
        	end 
        end
    end
end

function goldNiuScene:getPlayerInfo(uid)
    if userInfo[uid] then
        return userInfo[uid]
    end
end
--设置玩家信息
function goldNiuScene:setPlayerInfo(uid)
    userInfo[uid] = {}
    userInfo[uid].AvatarUrl=""
    userInfo[uid].Gender=0-- 0未知1男2女
    userInfo[uid].NickName="游客"..tostring(uid)
    userInfo[uid].Score=0
    userInfo[uid].UserId=uid
    userInfo[uid].winroundsum=0
    userInfo[uid].losesum=0
    userInfo[uid].winning=0
    userInfo[uid].seatIndex=0
end

function goldNiuScene:onButtonClickedEvent(sender)
	local tag = sender:getTag()

    if tag == goldNiuScene.BTN_MORE_HIDE then
        if self:getChildByTag(110) == nil then
            self:moreListHide()
        end
	elseif tag == goldNiuScene.BTN_MORE_SHOW then
		self:moreListShow()
	elseif tag == conf.Tag.hasniu then
        self.niuNum = 1
		-- self:ShowCard()
		self:clickNiuBtn()
        self:showGameTips(conf.tipes.waitOpenCards)
	elseif tag == conf.Tag.noniu then
        self.niuNum = 0
		-- self:ShowCard()
		self:clickNiuBtn()
        self:showGameTips(conf.tipes.waitOpenCards)
	elseif tag == goldNiuScene.BTN_CHAT then
        self:chatAct()
	elseif tag == conf.Tag.shop then
		self:ShopAct()
        -- self._gameRequest:RequestShopSucceed()
    --抢庄(金币)
	elseif tag == conf.goldTag.bank0 then self:Gradbanker(tag)
	elseif tag == conf.goldTag.bank1 then self:Gradbanker(tag)
	elseif tag == conf.goldTag.bank2 then self:Gradbanker(tag)
	elseif tag == conf.goldTag.bank3 then self:Gradbanker(tag)
	elseif tag == conf.goldTag.bank4 then self:Gradbanker(tag)
    --下注(金币)
	elseif tag == conf.goldTag.brtting5 then self:Brtting(tag)
	elseif tag == conf.goldTag.brtting10 then self:Brtting(tag)
	elseif tag == conf.goldTag.brtting15 then self:Brtting(tag)
	elseif tag == conf.goldTag.brtting20 then self:Brtting(tag)
	elseif tag == conf.goldTag.brtting25 then self:Brtting(tag)
    --玩家信息
	elseif tag == conf.Tag.play1 then self:ClickPlayerHead(tag)
	elseif tag == conf.Tag.play2 then self:ClickPlayerHead(tag)
	elseif tag == conf.Tag.play3 then self:ClickPlayerHead(tag)
	elseif tag == conf.Tag.play4 then self:ClickPlayerHead(tag)
	elseif tag == conf.Tag.play5 then self:ClickPlayerHead(tag)
    --坐下
    elseif tag == conf.Tag.sit1 then self:RequestPlayerSitDown()
    elseif tag == conf.Tag.sit2 then self:RequestPlayerSitDown()
    elseif tag == conf.Tag.sit3 then self:RequestPlayerSitDown()
    elseif tag == conf.Tag.sit4 then self:RequestPlayerSitDown()
    elseif tag == conf.Tag.sit5 then self:RequestPlayerSitDown()
	end
end
--隐藏椅子按钮
function goldNiuScene:removeSit()
    self:setSitHide()
end
--刷新玩家数据
function goldNiuScene:refreshUserData()
    self:setSitShow()
    self:refreshData()
end
--设置观战
function goldNiuScene:SetSpectatorsState()
    self:hideChatBtn()
    self:setSitShow()
    self.isOnTable = false

    self._gameRequest:RequestTabelInfo()

    self:showGameTips(conf.tipes.enterLook)
end
--解除观战
function goldNiuScene:removeSpectatorsState()
    self:showChatBtn()
    self:setSitHide()
    self.isOnTable = true
end
--显示聊天按钮
function goldNiuScene:showChatBtn()
    self.chatBtn:show()
    self.chatBtn:setTouchEnabled(true)
    self.chatBtn:setBright(true)
end
--隐藏聊天按钮
function goldNiuScene:hideChatBtn()
    self.chatBtn:hide()
    self.chatBtn:setTouchEnabled(false)
    self.chatBtn:setBright(false)
end

--移除玩家头像数据
function goldNiuScene:removeData()
    --self:setPlayHide()
    if self.playerInfoData then
        for k,v in pairs(self.playerInfoData) do
            self.playerInfoData[k] = nil
        end
    end
    if self._playerDataList then
        for k,v in pairs(self._playerDataList) do
            self._playerDataList[k] = nil
        end
    end
end

--刷新数据
function goldNiuScene:refreshData()
    self:removeData()
    local mySitId = 0
    if self.playerListUID then
        for k,v in pairs(self.playerListUID) do
            if tostring(v.uid) == tostring(UserData.userId) then
                mySitId = k-1
            end
        end
        for i = 1,5 do
            if self.playerListUID[i] ~= nil then
                local swichId = conf.swichPos(i-1,mySitId,self.MaxPlayer)
                self:updatePlayerInfo(swichId,self.playerListUID[i].uid,self.playerListUID)
                self._sitBtnList[swichId]:hide()           
            else
                local swichId = conf.swichPos(i-1,mySitId,self.MaxPlayer)
                self:hidePlayerBySeatID(swichId)     
            end
        end
    end
end

--隐藏指定座位玩家节点
function goldNiuScene:hidePlayerBySeatID(localSeatId)
    if localSeatId == nil or localSeatId < 1 or localSeatId > 5 then
        return
    end

    --隐藏玩家节点
    if self._playBtnList[localSeatId] then
        self._playBtnList[localSeatId]:hide()
        self._sitBtnList[localSeatId]:show()    
    end

    if self.headDataArray[localSeatId] then
        self.headDataArray[localSeatId]:removeFromParent()
        self.headDataArray[localSeatId] = nil    
    end

    if self.NameDataArray[localSeatId] then
        self.NameDataArray[localSeatId]:removeFromParent()
        self.NameDataArray[localSeatId] = nil   
    end

    if self.playerCoinArr[localSeatId] then
        self.playerCoinArr[localSeatId]:removeFromParent()
        self.playerCoinArr[localSeatId] = nil    
    end
end

--确定点击玩家的uid
function goldNiuScene:ClickPlayerHead(tag)
	local index = tag-113
	local swichArr = {}
	for k,v in pairs(self.playerInfoData) do
        if v.seatIndex then
            local swichId = conf.swichPos(v.seatIndex-1,self.myid,5)
            table.insert(swichArr,swichId)
        end
	end
	if swichArr then
		for i,v in ipairs(swichArr) do
			if tostring(index) == tostring(v) then
				for k,v in pairs(self.playerInfoData) do
                    if self.playerInfoData[k].seatIndex then
    					if conf.swichPos(self.playerInfoData[k].seatIndex-1,self.myid,5) == index then
    						-- GameManager:getInstance():requestGamePlayerInfoData(self.playerInfoData[k].UserId)
                            local info = self:getPlayerInfo(self.playerInfoData[k].UserId)
                            for i,v in pairs(self.PlayerDataSync) do
                                if v.uid == self.playerInfoData[k].UserId then
                                    info.Score = v.score
                                end
                            end
                            local playerInfoView = GamePlayerInfo.new(self.playerInfoData[k].UserId)
                            playerInfoView:setInfoData(info)
                            self:addChild(playerInfoView,20)
    					end
                    end
				end
			end
		end
	end
end

--更多列表显示
function goldNiuScene:moreListShow()
    self.MoreBtn_show:hide()
    self.MoreBtn_hide:show()
    local menuNode = MenuNode.new()
    menuNode:initGold()
    menuNode:setTag(110)
    self:addChild(menuNode,110)
end
--更多列表隐藏
function goldNiuScene:moreListHide()
    self.MoreBtn_show:show()
    self.MoreBtn_hide:hide()
    if self:getChildByTag(110) then
        self:getChildByTag(110):closeLayer()
    end
end
--金币牛牛牌型动画
function goldNiuScene:ShowCardTypeLayer()
    local cardTypeNode = CardTypeNode.new()
    self:addChild(cardTypeNode,111)
end

--进入商店
function goldNiuScene:ShopAct()
    local shop = nil
    if self:getChildByTag(666) then
        return
    else 
        shop = require("src/lobby/layer/MallDialog"):create(config.MallLayerConfig.Type_Gold)
        shop:setTag(666)
        self:addChild(shop,20)
    end
end
--聊天界面
function goldNiuScene:chatAct()
    local chat = chatNode.new()
    chat:setTag(conf.Tag.chatList)
    self:addChild(chat,15)
    chat:setData(self.ChatListData)
end
--设置
function goldNiuScene:setAct()
    local setView = require("lobby/view/SetView").new(1)
    self:addChild(setView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
end
--玩家列表
function goldNiuScene:setPlayer(playerListUID)
    self.playerInfoData = {}

	self.playerListUID = playerListUID
    if self.playerListUID then
        for k,v in pairs(self.playerListUID) do
            if self.isStart then
                self.isOnTable = false
            end
            if v.uid == UserData.userId then
                self.isOnTable = true
                break
            else
                self.isOnTable = false
            end
        end
    end
end
--数据同步
function goldNiuScene:setPlayerDataSync(PlayerDataSync)
    self.PlayerDataSync = PlayerDataSync
end

--更行玩家分数
function goldNiuScene:updataCurPlayerScore(uid,score)
    if self.playerCoinArr == nil then
        return
    end

    for i,v in pairs(self.playerListUID) do
        if tostring(uid) == tostring(v.uid) then
            local swich = conf.swichPos(i-1,self.myid,5)
            if self.playerCoinArr[swich] then
                self.playerCoinArr[swich]:setString(conf.switchNum(score))
            end
        end
    end
end

--游戏开始倒计时
function goldNiuScene:startTime(time)
    self:hideCard()
    self:setLuckAct()
    if self.isOnTable then
    	self:createClock(conf.time.wait,time)
        self:hideGameTips()
    end
    self._isGameing = true
end
--游戏开始动画
function goldNiuScene:startAct()
    self._gameStatus = conf.goldState.grapBanker
  
    if self.isOnTable  then
    	self.xiazhu_node:setVisible(true)
    	self.xiazhu_action:gotoFrameAndPlay(0,false)
        MusicManager:getInstance():playAudioEffect(conf.Music["Gamestart"],false)

    	local a={}
    	a[#a+1]=cc.DelayTime:create(0.1)
    	a[#a+1]=cc.CallFunc:create(function() self.particleparticle:start() end)
    	a[#a+1]=cc.DelayTime:create(0.7)
    	a[#a+1]=cc.CallFunc:create(function() self.xiazhu_node:setVisible(false) end)
    	self:runAction(cc.Sequence:create(a))
    end
end

--初始化玩家游戏状态
function goldNiuScene:initPlayerStatus(playerDataArray)
    for k,v in pairs(playerDataArray) do
        GameManager.userPlayStateArray[v.sit+1] = true
    end
end
--赢的特效
function goldNiuScene:victoryAct()
	self.winNode:setVisible(true)
	self.winAction:gotoFrameAndPlay(0,false)
    MusicManager:getInstance():playAudioEffect(conf.Music["Gamewin"],false)
	local a={}
	a[#a+1]=cc.CallFunc:create(function() 
        self.winActPart:start()

		local tableEffect  = tableAction:new()
		tableEffect:iconGold()
        self.tableEffect = tableEffect
		self:addChild(tableEffect)
	 end)
	a[#a+1]=cc.DelayTime:create(2)
	a[#a+1]=cc.CallFunc:create(function() self.winNode:setVisible(false) end)
	self:runAction(cc.Sequence:create(a))
end
--输的特效
function goldNiuScene:loseAct()
    self.loseNode:setVisible(true)
    self.loseAction:gotoFrameAndPlay(0,false)
    MusicManager:getInstance():playAudioEffect(conf.Music["Gamelose"],false)
    local a={}
    a[#a+1]=cc.DelayTime:create(0.5)
    a[#a+1]=cc.CallFunc:create(function ()
        local lose = tableAction:new()
        lose:LoseAutumnleaves()
        self:addChild(lose)
        self.lose = lose 
    end)
    a[#a+1]=cc.DelayTime:create(2)
    a[#a+1]=cc.CallFunc:create(function() 
            self.loseNode:setVisible(false)
            self.lose:removeFromParent()
            self.lose = nil
        end)
    self:runAction(cc.Sequence:create(a))
end
--运气爆棚特效
function goldNiuScene:luckAct()
    self.luckNode:setVisible(true)
    self.luckEffect:setVisible(true)
    self.luckAction:gotoFrameAndPlay(0,false)
    local a={}
    a[#a+1]=cc.DelayTime:create(2)
    a[#a+1]=cc.CallFunc:create(function() self.luckNode:setVisible(false) end)
    self:runAction(cc.Sequence:create(a))
    local b={}
    b[#b+1]=cc.MoveTo:create(1,cc.p(350,0))
    b[#b+1]=cc.DelayTime:create(1)
    b[#b+1]=cc.CallFunc:create(function() self.luckEffect:setVisible(false) end)
    self.luckEffect:runAction(cc.Sequence:create(b))
end

--设置发牌数据
function goldNiuScene:setShowCardData(dataArray)
	self.CardData=dataArray
end

--开始发牌
function goldNiuScene:StartFaPai(playerDataArray)
    self.isStart = true

    for k,v in pairs(self.PlayerDataSync) do
        self:updataCurPlayerScore(v.uid,v.score)
    end

	if self.CardData==nil then
		return
	end
    local cardNum=#self.CardData
    self._isGameing = true
    -- if self.isOnTable and self._isGameing then
    --     -- dump(self.playerListUID)
    --     for i,v in pairs(GameManager.userPlayStateArray)  do
    --         dump(GameManager.userPlayStateArray)
    --         if GameManager.userPlayStateArray[i] == true then
    --            self:showFaPai(conf.swichPos(i-1,self.myid,5),cardNum)
    --         end
    --     end
    -- else
    --     for i,v in pairs(GameManager.userPlayStateArray)  do
    --         if GameManager.userPlayStateArray[i] == true then
    --            self:showTourFaPai(conf.swichPos(i-1,self.myid,5),4)
    --         end
    --     end
    -- end
    for i,v in pairs(playerDataArray) do
        if self.isOnTable and self._isGameing and tostring(v.uid) == tostring(UserData.userId) then
            self:showFaPai(conf.swichPos(v.sit,self.myid,5),cardNum)
        else
            self:showTourFaPai(conf.swichPos(v.sit,self.myid,5),4)
        end
    end
end
--发牌
function goldNiuScene:showFaPai(seatId,index)
	local backCardArray = {}
    for j=1, index do
		local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
        backCard:setScale(0.6)
        backCard:setPosition(667,375)
		self.bg:addChild(backCard)
        table.insert(backCardArray,backCard)
        if seatId == 1 then
			local array = {}
			array[#array + 1] = cc.EaseSineIn:create(cc.MoveTo:create(0.3+j*0.05,cc.p(340+j*110,100)))
			array[#array + 1] = cc.ScaleTo:create(0.3,0.8)
            array[#array + 1] = cc.CallFunc:create(function () backCard:hide() end)
			backCard:runAction(cc.Sequence:create(array))
		else
			backCard:runAction(cc.EaseSineIn:create(cc.MoveTo:create(0.2+j*0.05,cc.p(conf.showCardPosArray[seatId].x+j*30,conf.showCardPosArray[seatId].y))))
		end
	end

    self:removeBackCardBySeatId(seatId)
    self.handBackCard[seatId] = backCardArray
    MusicManager:getInstance():playAudioEffect(conf.Music["Fapai_more"],false)
end
--发牌(观战视角)
function goldNiuScene:showTourFaPai(seatId,index)
    local backCardArray = {}
    for j=1, index do
        local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
        backCard:setPosition(667,375)
        backCard:setScale(0.6)
        self.bg:addChild(backCard)
        table.insert(backCardArray,backCard)
        backCard:runAction(cc.EaseSineIn:create(cc.MoveTo:create(0.2+j*0.05,cc.p(conf.showCardPosArray[seatId].x+j*30,conf.showCardPosArray[seatId].y))))
    end

    self:removeBackCardBySeatId(seatId)
    self.handBackCard[seatId] = backCardArray
    MusicManager:getInstance():playAudioEffect(conf.Music["Fapai_more"],false)
end

--设置玩家牌
function goldNiuScene:setPlayerCard()
	if self.CardData==nil then
		return
	end
	for i,v in ipairs(self.CardData) do
        if self.isOnTable and self._isGameing then
        	self:initPlayerCard(v,i)
        end
	end
end

--初始化玩家牌
function goldNiuScene:initPlayerCard(cardValue,i)
	local frontCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x"..cardValue..".png")
	frontCard:setTag(i)
	frontCard:setPosition(340+i*110,100)
	frontCard:setScale(0.8)
	frontCard:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.FadeIn:create(0.1),cc.OrbitCamera:create(0.3,1,0,90,-90,0,0)))
	self.bg:addChild(frontCard)
	self:cardClickedEvent(frontCard)
	table.insert(self.handCard,frontCard)
end

function goldNiuScene:cardClickedEvent(sprite)
	local listener = cc.EventListenerTouchOneByOne:create()
	local function onTouchBegan(touch, event)
		local target = event:getCurrentTarget()
		local size = target:getContentSize()
		local rect = cc.rect(0, 0, size.width, size.height)
		local p = touch:getLocation()
		p = target:convertTouchToNodeSpace(touch)
		if cc.rectContainsPoint(rect, p) then
			return true
		end
		return false
	end
	local function onTouchMoved(touch, event)  
	end
	local function onTouchEnded(touch, event)
		self:upCard(sprite)
        MusicManager:getInstance():playAudioEffect(conf.Music["Out_Card"],false)
	end
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, sprite)
end
--点击牌谈起落下
function goldNiuScene:upCard(sprite)
    if sprite then
        if self.clickNum < 3 then
            if sprite:getPositionY() == 100 then
                self.clickNum = self.clickNum+1
                sprite:setPositionY(120)
                self:niuCount(sprite)
            elseif sprite:getPositionY() == 120 then
                self.clickNum = self.clickNum-1
                sprite:setPositionY(100)
                for i,v in ipairs(self.clickCard) do
                    if sprite:getTag() == v:getTag() then
                        table.remove(self.clickCard,i)
                        table.remove(self.clickCardValue,i)
                    end
                end
            end
        elseif self.clickNum >= 3 then
            if sprite:getPositionY() == 100 then 

            elseif sprite:getPositionY() == 120 then
                self.clickNum = self.clickNum-1
                sprite:setPositionY(100)
                for i,v in ipairs(self.clickCard) do
                    if sprite:getTag() == v:getTag() then
                        table.remove(self.clickCard,i)
                        table.remove(self.clickCardValue,i)
                    end
                end
            end
        end
        self:setValuePos()
    end
end
-- self.clickCard            在上面的牌
-- self.clickCardValue       在上面的牌的值
--
function goldNiuScene:niuCount(sprite)
    local value = self.CardData[sprite:getTag()]
    local num = tonumber(value, 16)
    local kNum = tonumber(num)%16
    table.insert(self.clickCard,sprite)
    table.insert(self.clickCardValue,kNum)
end 
--判断牌值是不是空的
function goldNiuScene:isCardDataNull()
    if next(self.CardData) == nil then
        for k,v in pairs(GameManager.TableInfoArray.player) do
            if UserData.userId == v.uid then 
                for i,val in ipairs(v.cardDataArray) do
                    local value = string.format("%02X",val)
                    table.insert(self.CardData,value)
                end
            end
        end
    end
end

--牌的点数
function goldNiuScene:cardDianShu(num,i)
    local node = cc.Node:create()
    node:setPosition(35+(i-1)*108,20)
    local pTexture = display.loadImage(GameResPath.."xiazhu_num.png")
    if tonumber(num) < 10 then
        local kCard = cc.Sprite:createWithTexture(pTexture,cc.rect((tonumber(num)+1)*24,0,24,33))
        kCard:setPosition(12,16.5)
        node:addChild(kCard)
    else
        local kCard1 = cc.Sprite:createWithTexture(pTexture,cc.rect(2*24,0,24,33))
        kCard1:setPosition(0,16.5)
        node:addChild(kCard1)
        local kCard2 = cc.Sprite:createWithTexture(pTexture,cc.rect(24,0,24,33))
        kCard2:setPosition(24,16.5)
        node:addChild(kCard2)
    end
    self.suanniukuang:addChild(node)
    table.insert(self.clickCardNode,node)
end
--牌点数总和
function goldNiuScene:sumCardDianshu(sum)
    if self.numnode then
        self.numnode:hide()
        self.numnode:removeFromParent()
        self.numnode = nil
    end
    if sum == 0 then
        return
    end
    local xx = self.suanniukuang:getContentSize().width
    local numnode = cc.Node:create()
    self.numnode = numnode
    numnode:setPosition(xx-60,20)
    local pTexture = display.loadImage(GameResPath.."xiazhu_num.png")
    if tonumber(sum) < 10 then
        local kCard = cc.Sprite:createWithTexture(pTexture,cc.rect((tonumber(sum)+1)*24,0,24,33))
        kCard:setPosition(12,16.5)
        numnode:addChild(kCard)
    else
        local dec = (sum-(sum%10))/10
        local unit = sum%10
        local kCard1 = cc.Sprite:createWithTexture(pTexture,cc.rect((dec+1)*24,0,24,33))
        kCard1:setPosition(0,16.5)
        numnode:addChild(kCard1)
        local kCard2 = cc.Sprite:createWithTexture(pTexture,cc.rect((unit+1)*24,0,24,33))
        kCard2:setPosition(24,16.5)
        numnode:addChild(kCard2)
    end
    self.suanniukuang:addChild(numnode)
end
--设置点击牌值的位置
function goldNiuScene:setValuePos() 
    if self.clickCardNode then
        for i,v in ipairs(self.clickCardNode) do
            v:hide()
        end
    end
    local sum = 0
    for i,v in ipairs(self.clickCardValue) do
        self:cardDianShu(v,i)
        if tonumber(v) > 10 then
            v = 10
        end
        sum = sum + tonumber(v)
    end
    self:sumCardDianshu(sum)
    self.sum = sum

    if self.data.way == ConstantsData.CalCattleType.TYPE_MANUAL then
        self:ManualCalCattle()
    end
end
--抢庄按钮显示(金币)
function goldNiuScene:GradbankerBtnGold(time,maxMul)
    self._isGameing = true
    if self.isOnTable and self._isGameing then
    	self.panel1:show()
    	if maxMul == 3 then
    		self.goldbank4:setBright(false)
    		self.goldbank4:setTouchEnabled(false)
    	elseif maxMul == 2 then
    		self.goldbank4:setBright(false)
    		self.goldbank4:setTouchEnabled(false)
    		self.goldbank3:setBright(false)
    		self.goldbank3:setTouchEnabled(false)
    	elseif maxMul == 1 or maxMul == 0 then
    		self.goldbank4:setBright(false)
    		self.goldbank4:setTouchEnabled(false)
    		self.goldbank3:setBright(false)
    		self.goldbank3:setTouchEnabled(false)
    		self.goldbank2:setBright(false)
    		self.goldbank2:setTouchEnabled(false)
    	end
    	
        self:createClock(conf.time.gradBank,time)
    end
end
--抢庄
function goldNiuScene:Gradbanker(tag)
    if self.isOnTable and self._isGameing then
    	self.panel1:hide()
    	self._gameRequest:RequestGameGradbanker(UserData.userId,head.C2S_EnumKeyActionGold.C2S_PLAYER_GRADBANKER,tag-201)
        self:removeClockNode()
    end

    self:removeClockNode()

    self:showGameTips(conf.tipes.waitGraBanker)
end
--抢庄隐藏
function goldNiuScene:GradbankerHide()
    if self.isOnTable and self._isGameing then
    	if self.panel1 then
            self.panel1:hide() 	
    	end     
        if self.action then
            self.action:hide()
            self.action = nil      
        end
    end
end
--抢庄的倍数
function goldNiuScene:gradMultiple(index,multiple)
    local grad = cc.Sprite:createWithSpriteFrameName("txt_qiang"..multiple..".png")
    grad:setPosition(conf.multiplePosArray[index])
    self.bg:addChild(grad)

    if self.gradArray[index] then
       self.gradArray[index]:removeFromParent()
       self.gradArray[index] = nil
    end
    self.gradArray[index] = grad
end
--设置庄家数据
function goldNiuScene:setZhuangData(bankidArr,bankSeatid)
	self.bankidArr = bankidArr
	self.locakBankSeatid = bankSeatid
end
--选庄动画
function goldNiuScene:roundZhuangAct()
    if self.bankidArr then
        if #self.bankidArr == 1 then
            return
        end
    end
    if self.bankidArr == nil then
            return
    end
    self.layerColor:setVisible(true)
	local rezhuang = tableAction:new()
    rezhuang:roundZhuang(self.bankidArr)
    self.bg:addChild(rezhuang)
    self.rezhuang = rezhuang
    MusicManager:getInstance():playAudioEffect(conf.Music["Xuanzhuang"],false)
end
--设置庄家
function goldNiuScene:setZhuang()
    if self.setbank then
        self.setbank:removeFromParent()
        self.setbank = nil
    end
    
    self.layerColor:setVisible(false)
	local setbank = tableAction:new()
    setbank:zhuangEffect(self.locakBankSeatid)
    self.bg:addChild(setbank)
    self.setbank = setbank
    MusicManager:getInstance():playAudioEffect(conf.Music["Dingzhuang"],false)
end
--下注的倍数
function goldNiuScene:brttingMultiple(index,multiple)    
    if self.gradArray~=nil then
        for i = 1,5 do
            if self.gradArray[i] and  self:getZhuangLocalSeatId() ~= i then
                self.gradArray[i]:setVisible(false)            
            end
        end
    end
    local pTexture=GameResPath.."xiazhu_num.png"
    local node = cc.Node:create()
    local brtting = ccui.TextAtlas:create(tostring(multiple),pTexture,24,33,"/")
    brtting:setPosition(0,0)
    brtting:setString("/"..tostring(multiple))
    node:addChild(brtting)
    node:setPosition(conf.multiplePosArray[index])
    self.bg:addChild(node)
    table.insert(self.brttingMArray,node)
end
--下注按钮显示(金币)
function goldNiuScene:BrttingBtn(UserId,time,maxBrt)
    self._gameStatus = conf.goldState.beting

	if self.isOnTable and self._isGameing then
        if maxBrt == 3 then
    		self.goldbrtting25:setBright(false)
    		self.goldbrtting25:setTouchEnabled(false)
    	elseif maxBrt == 2 then
    		self.goldbrtting25:setBright(false)
    		self.goldbrtting25:setTouchEnabled(false)
    		self.goldbrtting20:setBright(false)
    		self.goldbrtting20:setTouchEnabled(false)
    	elseif maxBrt == 1 then
    		self.goldbrtting25:setBright(false)
    		self.goldbrtting25:setTouchEnabled(false)
    		self.goldbrtting20:setBright(false)
    		self.goldbrtting20:setTouchEnabled(false)
    		self.goldbrtting15:setBright(false)
    		self.goldbrtting15:setTouchEnabled(false)
    	elseif maxBrt == 0 then
    		self.goldbrtting25:setBright(false)
    		self.goldbrtting25:setTouchEnabled(false)
    		self.goldbrtting20:setBright(false)
    		self.goldbrtting20:setTouchEnabled(false)
    		self.goldbrtting15:setBright(false)
    		self.goldbrtting15:setTouchEnabled(false)
    		self.goldbrtting10:setBright(false)
    		self.goldbrtting10:setTouchEnabled(false)
    	end
    	if tostring(UserData.userId) ~= tostring(UserId) then
    		self.panel:show()
            self:createClock(conf.time.brtting,time)
    	end

    
    	local array = {}
    	array[#array+1] = cc.DelayTime:create(1)
    	array[#array+1] = cc.CallFunc:create(
    		function ()
                if self.gradArray~=nil then
                    for i = 1,5 do
                        if self.gradArray[i] and self:getZhuangLocalSeatId() ~= i then
                            self.gradArray[i]:setVisible(false)            
                        end
                    end
                end
    		end)
    	local seq = cc.Sequence:create(array)
    	self:runAction(seq)
    end
end

--下注
function goldNiuScene:Brtting(tag)
    if self.isOnTable and self._isGameing then
	   self.panel:hide()
	   self._gameRequest:RequestGameGradbanker(UserData.userId,head.C2S_EnumKeyActionGold.C2S_PLAYER_BRTTING,(tag-206))
    end
    
    self:removeClockNode()
    self:showGameTips(conf.tipes.waitBet)	
end
--隐藏下注按钮
function goldNiuScene:hideBrttingBtn()
    if self.isOnTable and self._isGameing then
    	self:niuBtn()

        self:removeClockNode()

    	self.panel:hide()
    end
end
--显示有牛没牛按钮
function goldNiuScene:niuBtn()
    if self.isOnTable and self._isGameing then
    	self.hasNiuBtn:show()
    	self.noNiuBtn:show()
    end
end
function goldNiuScene:clickNiuBtn()
    if self.isOnTable and self._isGameing then
        self._gameRequest:RequestGameShowCard(UserData.userId,head.C2S_EnumKeyActionGold.C2S_PLAYER_SWIGN,self.niuNum)
    end
end
--第五张牌数据
function goldNiuScene:setFifthCardData(FifthCardData)
    self.FifthCardData = FifthCardData
    table.insert(self.CardData,FifthCardData)
end
--算牛
function goldNiuScene:judgeNiu(num)
    if self.data then
        if self.data.way == ConstantsData.CalCattleType.TYPE_AUTO then
            self:AutoCalCattle(num)
        elseif self.data.way == ConstantsData.CalCattleType.TYPE_MANUAL then
            self.myCattType = num
            if num > 10 then
                self.hasNiuBtn:setTouchEnabled(true)
                self.hasNiuBtn:setBright(true)
            end
        end
    end
end
--自动算牛
function goldNiuScene:AutoCalCattle(num)
    if num == 0 then
        self.niuNum = 0
        self.hasNiuBtn:setTouchEnabled(false)
        self.hasNiuBtn:setBright(false)
    else
        self.niuNum = 1
        self.hasNiuBtn:setTouchEnabled(true)
        self.hasNiuBtn:setBright(true)
    end
end
--手动算牛
function goldNiuScene:ManualCalCattle()
    if self.myCattType > 10 then
        self.hasNiuBtn:setTouchEnabled(true)
        self.hasNiuBtn:setBright(true)
    elseif self.sum%10 == 0 and self.sum > 0 and #self.clickCardValue == 3 then
        self.hasNiuBtn:setTouchEnabled(true)
        self.hasNiuBtn:setBright(true)
    else
        self.hasNiuBtn:setTouchEnabled(false)
        self.hasNiuBtn:setBright(false)
    end
end

--发送最后一张牌
function goldNiuScene:sendLastCard(playerArray)
    self._gameStatus = conf.goldState.roundAction
  
    -- if self.isOnTable then
    --     for i,v in pairs(self.playerListUID) do
    --         if GameManager.userPlayStateArray[i] == true then   
    --             self:showLastCard(conf.swichPos(v.sit,self.myid,5))
    --         end
    --     end
    -- else
    --     for i,v in pairs(self.playerListUID) do
    --         if GameManager.userPlayStateArray[i] == true then                    
    --             self:showTourLastCard(conf.swichPos(v.sit,self.myid,5))
    --         end
    --     end
    -- end

    for i,v in ipairs(playerArray) do
        if self.isOnTable and tostring(v.uid) == tostring(UserData.userId) then
            self:showLastCard(conf.swichPos(v.sitId,self.myid,5))
        else
            self:showTourLastCard(conf.swichPos(v.sitId,self.myid,5))
        end
    end
end
--发送最后一张牌
function goldNiuScene:showLastCard(seatId)
    if GameManager.userPlayStateArray[self.myid+1] == true then
	    self.suanniukuang:show()
    end
	local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
	backCard:setPosition(667,375)
    backCard:setScale(0.6)
	self.bg:addChild(backCard)

    if self.handBackCard[seatId] == nil then
       self.handBackCard[seatId] = {}
    end
	table.insert(self.handBackCard[seatId],backCard)
 
	if seatId == 1 then
		local array = {}
		array[#array + 1] = cc.EaseSineIn:create(cc.MoveTo:create(0.3,cc.p(340+5*110,100)))
		array[#array + 1] = cc.ScaleTo:create(0.3,0.8)
        array[#array + 1] = cc.CallFunc:create(function() backCard:hide() end)
        backCard:runAction(cc.Sequence:create(array))
	else
		backCard:runAction(cc.EaseSineIn:create(cc.MoveTo:create(0.2,cc.p(conf.showCardPosArray[seatId].x+5*30,conf.showCardPosArray[seatId].y))))
	end
    MusicManager:getInstance():playAudioEffect(conf.Music["Fapai_one"],false)
end
--发送最后一张牌(游客视角)
function goldNiuScene:showTourLastCard(seatId)
    local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
    backCard:setPosition(667,375)
    backCard:setScale(0.6)
    self.bg:addChild(backCard)

    if self.handBackCard[seatId] == nil then
        self.handBackCard[seatId] = {}
    end

    table.insert(self.handBackCard[seatId],backCard)
    backCard:runAction(cc.EaseSineIn:create(cc.MoveTo:create(0.2,cc.p(conf.showCardPosArray[seatId].x+5*30,conf.showCardPosArray[seatId].y))))
    MusicManager:getInstance():playAudioEffect(conf.Music["Fapai_one"],false)
end
--显示最后一张牌
function goldNiuScene:initLastPlayerCard()
    if self.isOnTable and self._isGameing then
        self:initPlayerCard(self.FifthCardData,5)
    end
end
--摊牌的时间
function goldNiuScene:taipaiTime(time)
    if self.isOnTable and self._isGameing then
    	self:createClock(conf.time.putCard,time)
    end
end
--摊牌
function goldNiuScene:ShowCard()
    if self.isOnTable and self._isGameing then
    	self.suanniukuang:hide()

        self:removeClockNode()

    	if self.handCard~=nil then
            for i=1,#self.handCard do
                self.handCard[i]:removeFromParent()
            end
            self.handCard = {}
        end

        local backCardArray = {}
    	for i=1,5 do
    		local showDownCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
    		showDownCard:setPosition(570+i*30,200)
    		showDownCard:setScale(0.6)
    		self.bg:addChild(showDownCard)
    		table.insert(backCardArray,showDownCard)
    	end

        self:removeBackCardBySeatId(1)
        self.handBackCard[1] = backCardArray

    	local array = {}
    	array[#array + 1] = cc.DelayTime:create(1)
    	local seq = cc.Sequence:create(array)
    	self:runAction(seq)
    	self:hideNiuBtn()
    end
end
--隐藏有牛没牛按钮
function goldNiuScene:hideNiuBtn()
    if self.isOnTable and self._isGameing then
    	self.hasNiuBtn:hide()
        self.hasNiuBtn:setTouchEnabled(false)
        self.hasNiuBtn:setBright(false)
    	self.noNiuBtn:hide()
    end
end
--设置玩家数据
function goldNiuScene:setPlayerCardData(playerDataArray)
	self.playerDataArray = playerDataArray
end
--设置结算庄家的数据
function goldNiuScene:setzhuangReusltData(playerArr)
	assert(playerArr,"playerArr or bankerid invalid ")
	self.playerArr = playerArr
end
--玩家摊牌
function goldNiuScene:playerTanpai()
    self._gameStatus = conf.goldState.setTlement

	if self.playerDataArray == nil then
		return
	end
    
    self:removeClockNode()

    for i,v in ipairs(self.playerDataArray) do
        self:runAction(cc.Sequence:create(cc.DelayTime:create(i),
            cc.CallFunc:create(function () self:startTanPai(v,v.swich,self.playerDataArray[i].uid) end)))
    end
end
--开始摊牌
function goldNiuScene:startTanPai(oneData,SeatId,uid)
    if oneData == nil or SeatId == nil or uid == nil then
        print("DataError goldNiuScene:startTanPai 检查数据")
        return
    end

	for m=1,5 do
	    local value = string.format("%02X",oneData.cardArr[m])
	    self:sortCard(m,value,SeatId)
	end
	self:showNiu(SeatId,oneData.niuType,uid)
end
--断线重连结算状态摊牌
function goldNiuScene:jiesuanTanPai(oneData,SeatId,uid)
    if oneData == nil or SeatId == nil or uid == nil then
        print("DataError goldNiuScene:jiesuanTanPai 检查数据")
        return
    end
    if oneData.cardDataArray then
        for m=1,#oneData.cardDataArray do
            local value = string.format("%02X",oneData.cardDataArray[m])
            self:sortCard(m,value,SeatId)
        end
    end
    self:showNiu(SeatId,oneData.cardType,uid)
end

--最后显示五张牌
function goldNiuScene:sortCard(index,value,seatId)
    if seatId == 65535 or index == nil or value == nil then
        return
    end

    self:removeBackCardBySeatId(seatId)

	local card = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x"..value..".png")
	card:setPosition(conf.showCardPosArray[seatId].x-2+index*32,conf.showCardPosArray[seatId].y)
	card:setScale(0.6)
	card:runAction(cc.OrbitCamera:create(0.3,1,0,90,-90,0,0))
	self.bg:addChild(card,10)
	table.insert(self.allSortCard,card)
end
--显示牛
function goldNiuScene:showNiu(seatId,cardtype,uid)
    if seatId == 65535 or cardtype == nil or uid == nil then
        print("DataError goldNiuScene:showNiu 检查数据")
        return
    end

	local txtBg = cc.Sprite:createWithSpriteFrameName("txt_bg.png")
	txtBg:setPosition(conf.showCardPosArray[seatId].x+90,conf.showCardPosArray[seatId].y-30)
	self.bg:addChild(txtBg,10)
    
    if cardtype == 0 or cardtype >= 10 then
        local txtTip = cc.Sprite:create(GameResPath.."txtNiu/goldtxt_niu"..cardtype..".png")
        txtTip:setPosition(txtBg:getContentSize().width/2,txtBg:getContentSize().height/2)
        txtBg:addChild(txtTip)
        if cardtype >= 10 then
            txtTip:setScale(2.5)
            txtTip:runAction(cc.ScaleTo:create(0.1,1))
        end
    else
        local pTexture = display.loadImage(GameResPath.."txtNiu/goldtxt_niu1-9.png")
        local txtTip1 = cc.Sprite:createWithTexture(pTexture,cc.rect(0,0,43,40))
        local txtTip2 = cc.Sprite:createWithTexture(pTexture,cc.rect(tonumber(cardtype)*43,0,43,40))
        txtTip1:setPosition(txtBg:getContentSize().width/2-22,txtBg:getContentSize().height/2)
        txtTip2:setPosition(txtBg:getContentSize().width/2+22,txtBg:getContentSize().height/2)
        txtBg:addChild(txtTip1)
        txtBg:addChild(txtTip2)

        if cardtype > 6 then
            txtTip1:setScale(2.5)
            txtTip1:runAction(cc.ScaleTo:create(0.1,1))
            txtTip2:setScale(2.5)
            txtTip2:runAction(cc.ScaleTo:create(0.1,1))
        end
    end
	-- if cardtype == 0 then
	-- 	txtBg:setOpacity(0)
	-- end
	table.insert(self.cardTyoeArray,txtBg)

    local musicStr = nil

    self.playerInfoData[uid] = checktable(self.playerInfoData[uid])
    if self.playerInfoData[uid].Gender == ConstantsData.SexType.SEX_MAN then
        musicStr=conf.Music["Man_ox"]..tostring(cardtype)..".mp3"
    else
        musicStr=conf.Music["Woman_ox"]..tostring(cardtype)..".mp3"
    end
    MusicManager:getInstance():playAudioEffect(musicStr,false)
end
--显示输赢特效
function goldNiuScene:setBunkoEffect()
    local index = nil
    for k,v in pairs(self.playerArr) do
        if UserData.userId == v.uid then
            index = v.seatid
        end
    end
    if self.isOnTable and index and self._isGameing then
    	if self.playerArr[index+1].playerGoal >= 0 then
            self:victoryAct()
        elseif self.playerArr[index+1].playerGoal < 0 then
            self:loseAct()
        end
    end
end
--金币走向
function goldNiuScene:setGoldToward()
    local myid = 0
    for k,v in pairs(self.playerListUID) do
        if UserData.userId == v.uid then
            myid = v.sit
            self.myResuId = myid
        end
    end

    self.myResuId = myid

	for i,v in pairs(self.playerArr) do
       local id = conf.swichPos(i-1,myid,5)

        if id ~= self.locakBankSeatid then
            if self.playerArr[i].playerGoal > 0 then
                local a = {}
                a[#a+1] = cc.DelayTime:create(1)
                a[#a+1] = cc.CallFunc:create(function () self:setGoldEffect(self.locakBankSeatid,id) end)
                self:runAction(cc.Sequence:create(a))
            elseif self.playerArr[i].playerGoal < 0 then
                self:setGoldEffect(id,self.locakBankSeatid)
            end
        end
    end
end
--金币动画
function goldNiuScene:setGoldEffect(id1,id2)
    if id2 == nil or id1 == nil then
        return
    end
	local action = tableAction:new()
    action:goldCoin(id1,id2)
    self.bg:addChild(action,99)
    table.insert(self.goldAction,action)  
    MusicManager:getInstance():playAudioEffect(conf.Music["coinfly"],false)
    self:setGoldHeadToward(id2)
end
--设置金币头像动画
function goldNiuScene:setGoldHeadToward(id)
    if id == nil then
        return
    end
    local a = {}
    a[#a+1] = cc.DelayTime:create(0.7)
    a[#a+1] = cc.CallFunc:create(function () self:setGoldHeadEff(id) end)
    self:runAction(cc.Sequence:create(a))
end
--金币飞到头像上的特效
function goldNiuScene:setGoldHeadEff(id)
    if id == nil then
        return
    end
    local winHeadNode = nil
    local winHeadAct = nil
    if id == 2 or id == 5 then
        winHeadNode = cc.CSLoader:createNode(GameResPath.."winHead/win_gold_effect_2.csb")
        winHeadAct = cc.CSLoader:createTimeline(GameResPath.."winHead/win_gold_effect_2.csb")
        winHeadNode:setPosition(conf.headPosArray[id].x+77,conf.headPosArray[id].y+99.5)
    else
        winHeadNode = cc.CSLoader:createNode(GameResPath.."winHead/win_gold_effect.csb")
        winHeadAct = cc.CSLoader:createTimeline(GameResPath.."winHead/win_gold_effect.csb")
        winHeadNode:setPosition(conf.headPosArray[id].x+141,conf.headPosArray[id].y+65.5)
    end
    self.bg:addChild(winHeadNode)
    winHeadAct:setTimeSpeed(1) --设置执行动画速度
    winHeadAct:gotoFrameAndPlay(0,false)
    winHeadNode:runAction(winHeadAct)
    self.winHeadNode = winHeadNode

    --金币飞到头像上例子
    local winPart = cc.ParticleSystemQuad:create(GameResPath.."winHead/particle_texture(1).plist")
    winPart:setPositionType(cc.TMX_TILE_HORIZONTAL_FLAG)
    if id == 2 or id == 5 then
        winPart:setPosition(conf.headPosArray[id].x+55,conf.headPosArray[id].y+90)
    else
        winPart:setPosition(conf.headPosArray[id].x+113.5,conf.headPosArray[id].y+56.5)
    end
    self:addChild(winPart)
    winPart:start()
    winPart:setScale(0.5)
    winPart:setDuration(0.2)
    self.winPart = winPart
end

--摊牌完成
function goldNiuScene:wancheng(index)
    if index == nil then
        return
    end

	local txtBg = cc.Sprite:createWithSpriteFrameName("txt_bg.png")
	txtBg:setPosition(conf.showCardPosArray[index].x+90,conf.showCardPosArray[index].y-30)
	self.bg:addChild(txtBg,5)
	-- local txtTip = cc.Sprite:createWithSpriteFrameName("txt_wancheng.png")
    local txtTip = cc.Sprite:create(GameResPath.."txtNiu/goldtxt_wancheng.png")
	txtTip:setPosition(txtBg:getContentSize().width/2,txtBg:getContentSize().height/2)
	txtBg:addChild(txtTip)
	table.insert(self.txtArray,txtBg)
end
--隐藏完成
function goldNiuScene:hideWancheng()
	if self.txtArray~=nil then
		for i,v in pairs(self.txtArray) do
			v:setVisible(false)
			v:removeFromParent()
		end
        self.txtArray = {}
	end
end
--设置玩家得分
function goldNiuScene:setPlayerScore()
    local myid = 0
    if self.playerArr then
        for k,v in pairs(self.playerArr) do
            if UserData.userId == v.uid then
                myid = v.seatid
                self.myResuId = myid
            end
        end
    end

    for i,v in pairs(self.playerArr) do
        self:playerScore(conf.swichPos(v.seatid,self.myResuId,5),v.playerGoal)
    end

    GameManager.userPlayStateArray = {false,false,false,false,false}
end
--玩家单局得分
function goldNiuScene:playerScore(seatId,score)
    local scoreNode = Score.new(seatId,score)
    self.bg:addChild(scoreNode,33)
    for k,v in pairs(self.PlayerDataSync) do
        self:updataCurPlayerScore(v.uid,v.score)
    end
    self.scoreNode = scoreNode
    self.isStart = false 
end
--设置幸运牌型动画
function goldNiuScene:setLuckAct()
    if self.playerDataArray == nil or self.playerArr ==nil then
        return
    end
    for k,v in pairs(self.playerArr) do
        if v.uid == UserData.userId then
            for i,var in pairs(self.playerDataArray) do
                if var.uid == UserData.userId then
                    if tonumber(v.playerGoal) > 0 and tonumber(var.niuType) >= 10 then
                        self:luckAct()
                        self:setLuckActEffect(v.playerGoal,var.cardArr,var.niuType)
                    end
                end
            end
        end
    end
end
--初始化幸运牌型的一些数据
function goldNiuScene:setLuckActCard()
    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,220), display.width, display.height)
    layerColor:setVisible(false)
    self:addChild(layerColor,99)
    self.luckLayerColor = layerColor

    local strFile=GameResPath.."score_num_add.png"
    local scoreNode = ccui.TextAtlas:create("0",strFile,24,33,"/")
    scoreNode:setPosition(667,430)
    scoreNode:setVisible(false)
    self:addChild(scoreNode,100)

    for i=1,5 do
        local cardNode = display.newNode()
        self:addChild(cardNode,100)
        local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
        backCard:setPosition(0,0)
        cardNode:addChild(backCard)
        backCard:setVisible(false)
        cardNode:setPosition(520+i*55,260)
        table.insert(self.luckCardData,backCard)
    end

    local txtBg = cc.Sprite:createWithSpriteFrameName("txt_bg.png")
    txtBg:setPosition(667,200)
    txtBg:setVisible(false)
    txtBg:setScale(1.2)
    self:addChild(txtBg,100)
    -- local txtTip = cc.Sprite:createWithSpriteFrameName("txt_niu0.png")
    local txtTip = cc.Sprite:create(GameResPath.."txtNiu/goldtxt_niu0.png")
    txtTip:setPosition(txtBg:getContentSize().width/2,txtBg:getContentSize().height/2+15)
    txtBg:addChild(txtTip)
    txtTip:setScale(1.2)
    self.luckScoreNode = scoreNode
    self.luckTxtBg = txtBg
    self.luckTxtTip = txtTip
end
--幸运牌型动画显示
function goldNiuScene:setLuckActEffect(score,cardArr,niuType)
    self.luckLayerColor:setVisible(true)
    self.luckScoreNode:setVisible(true)
    self.luckScoreNode:setString(tostring(score))
    self.luckTxtBg:setVisible(true)
    self.luckTxtTip:setTexture(GameResPath.."txtNiu/goldtxt_niu"..tostring(niuType)..".png")

    for i,v in ipairs(self.luckCardData) do
        v:setVisible(true)
        local value = string.format("%02X",cardArr[i])
        v:initWithSpriteFrameName("niuniu_card_0x"..tostring(value)..".png")
    end

    local a={}
    a[#a+1]=cc.DelayTime:create(2)
    a[#a+1]=cc.CallFunc:create(function() 
            self.luckLayerColor:setVisible(false)
            self.luckScoreNode:setVisible(false)
            self.luckTxtBg:setVisible(false)
            for i,v in ipairs(self.luckCardData) do
                v:setVisible(false)
            end

            if self.playerDataArray then
                for k,v in pairs(self.playerDataArray) do
                    self.playerDataArray[k] = nil
                end
            end
            self.playerDataArray = {}

            if self.playerArr then
                for k,v in pairs(self.playerArr) do
                    self.playerArr[k] = nil
                end
            end
            self.playerArr = {}
        end)
    self:runAction(cc.Sequence:create(a))
end

--显示摊牌之后的背面牌
function goldNiuScene:showTanpai(seatId,index)
    local backCardArray = {}
    for j=1, index do
        local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
        backCard:setPosition(cc.p(conf.showCardPosArray[seatId].x+j*30,conf.showCardPosArray[seatId].y))
        backCard:setScale(0.6)
        self.bg:addChild(backCard)
        table.insert(backCardArray,backCard)
    end
    self:removeBackCardBySeatId(seatId)
    self.handBackCard[seatId] = backCardArray
end

--设置牌和庄家数据隐藏
function goldNiuScene:setDataHide()
    self:hideWancheng()
	self:hideCard()
    if self.setbank then
    	self.setbank:gamgEnd()
    end
end
--移除一些数据
function goldNiuScene:hideCard()
	--隐藏
    if self.handCard~=nil then
    	for i=1,#self.handCard do
    		self.handCard[i]:removeFromParent()
    	end
        self.handCard = {}
    end

    self:removeAllBackCard()

    if self.allSortCard~=nil then
    	for i,v in pairs (self.allSortCard) do
    		v:removeFromParent()
    	end
        self.allSortCard = {}
    end
    if self.cardTyoeArray~=nil then
    	for i,v in pairs (self.cardTyoeArray) do
    		v:removeFromParent()
    	end
        self.cardTyoeArray = {}
    end
    if self.brttingMArray~=nil then
    	for i,v in pairs (self.brttingMArray) do
    		v:removeFromParent()
    	end
        self.brttingMArray = {}
    end
    if self.clickCardNode~=nil then
    	for i,v in pairs (self.clickCardNode) do
            v:removeFromParent()
        end
        self.clickCardNode = {}
    end
    if self.gradArray~=nil then
        for i = 1,5 do
            if self.gradArray[i]  then
                self.gradArray[i]:removeFromParent()
                self.gradArray[i] = nil            
            end
        end
        self.gradArray = {}
    end

    if self.winHeadNode then
        self.winHeadNode:removeFromParent()
        self.winHeadNode = nil
    end
    if self.winPart then
        self.winPart:removeFromParent()
        self.winPart = nil
    end

    self.luckNode:setVisible(false)
    self.luckEffect:setVisible(false)
    self.luckLayerColor:setVisible(false)
    self.luckScoreNode:setVisible(false)
    self.luckTxtBg:setVisible(false)
    for i,v in ipairs(self.luckCardData) do
        v:setVisible(false)
    end

	self:reSet()
end
--数据重设
function goldNiuScene:reSet()
	self.handCard = {}
	self.handBackCard = {}
	self.allSortCard = {}
	self.cardTyoeArray = {}
	self.brttingMArray = {}

    self:hideWancheng()
	self.txtArray = {}

	self.clickCard = {}                 --点击的牌
    self.clickCardValue = {}            --点击的牌值
    self.clickCardNode = {}             --点击的牌值的节点
    self.clickNum = 0                   --点击次数
    if self.numnode then
        self.numnode:hide()
        self.numnode:removeFromParent()
        self.numnode = nil
    end

    if self.scoreNode then
       self.scoreNode:removeFromParent()
       self.scoreNode = nil
    end

    self:removeClockNode()

    if next(self.goldAction) then
        for i, v in pairs (self.goldAction) do
            v:removeFromParent()
        end    
    end
    self.goldAction = {}


    if self.tableEffect then
       self.tableEffect:removeFromParent()
       self.tableEffect = nil
    end

    if self.lose then
       self.lose:removeFromParent()
       self.lose = nil
    end

    if self.loseNode then
       self.loseNode:hide()
    end

    if self.rezhuang then
       self.rezhuang:removeFromParent()
       self.rezhuang = nil
    end

    if self.setbank then
       self.setbank:removeFromParent()
       self.setbank = nil
    end

    self._isGameing = false
    --self:hideGameTips()

    self._gameStatus = conf.goldState.freetime

    self.panel:hide()
 	self.panel1:hide()
end
--聊天文字
function goldNiuScene:onGameChatText(data)
    local tab = {}
    tab.uid = data.uid
    tab.strType = data.strType
    tab.value = data.str
    if tab.strType == "T" then
        tab.value = conf.ChatText[tonumber(tab.value)]
    end
    tab.type = 0
    tab.info = self.playerInfoData[data.uid]
    table.insert(self.ChatListData,tab)
    local index = nil
    for k,v in pairs(self.playerListUID) do
        if tostring(v.uid) == tostring(tab.uid) then
            index = k
        end
    end
    local swich = conf.swichPos(index-1,self.myid,5)
    local node = cc.Node:create()
    local chatBg = nil
    if swich == 1 or swich == 2 then
        chatBg = cc.Scale9Sprite:create(GameResPath.."chat/chat_bg_down_L.png")
        chatBg:setAnchorPoint(0,0.5)
        chatBg:setCapInsets(cc.rect(39,22,2,24))
    elseif swich == 3 or swich == 4 then
        chatBg = cc.Scale9Sprite:create(GameResPath.."chat/chat_bg_t_L.png")
        chatBg:setAnchorPoint(0,0.5)
        chatBg:setCapInsets(cc.rect(39,22,2,24))
    else
        chatBg = cc.Scale9Sprite:create(GameResPath.."chat/chat_bg_down_r.png")
        chatBg:setAnchorPoint(1,0.5)
        chatBg:setCapInsets(cc.rect(11,22,2,24))
    end
    chatBg:setPosition(0,0)
    node:addChild(chatBg)
    local xx,yy = chatBg:getContentSize().width,chatBg:getContentSize().height

    local musicStr = nil
    if data.strType == "T" then
        if self.playerInfoData[data.uid].Gender == ConstantsData.SexType.SEX_MAN then
            musicStr = "Man"
        else
            musicStr = "Woman"
        end
        musicStr = musicStr.."_Chat_"..data.str..".mp3"
        MusicManager:getInstance():playAudioEffect(conf.Music["chat_effect"]..musicStr,false)
    end

    local chatText = cc.Label:createWithSystemFont(tab.value,SYSFONT,26)
    chatText:setAnchorPoint(0,0.5)
    chatText:setPosition(5,chatBg:getContentSize().height/2)
    chatText:setColor(cc.c3b(111,66,34))
    chatBg:addChild(chatText)
    local len = chatText:getStringLength()
    chatBg:setPreferredSize(cc.size(len*26,yy))
    node:setAnchorPoint(0,0.5)
    node:setPosition(conf.chatPosArray[swich])
    table.insert(self.chatDataArray,node)
    self.bg:addChild(node,60)
    if self:getChildByTag(conf.Tag.chatList) then
        self:getChildByTag(conf.Tag.chatList):addData(tab)
    end

    local a = {}
    a[#a+1] = cc.DelayTime:create(1.5)
    a[#a+1] = cc.CallFunc:create(function () node:removeAllChildren() end)
    node:runAction(cc.Sequence:create(a))
end
--聊天表情
function goldNiuScene:onGameChatBrow(data)
    local tab={}
    tab.uid=data.uid
    tab.value=data.browId
    tab.type=1
    tab.info=self.playerInfoData[data.uid]
    table.insert(self.ChatListData,tab)
    local index = nil
    for k,v in pairs(self.playerListUID) do
        if tostring(v.uid) == tostring(data.uid) then
            index = k
        end
    end
    local swich = conf.swichPos(index-1,self.myid,5)
    local node = cc.Node:create()
    local str = "brow"..tostring(tab.value).."_1.png"
    local browText = cc.Sprite:createWithSpriteFrameName(str)
    browText:setPosition(0,0)
    node:addChild(browText)
    browText:initWithSpriteFrameName(str)
    local act=FrameAniFactory:getInstance():getBrowAnimationById(tab.value)
    browText:stopAllActions()
    browText:runAction(act)

    node:setAnchorPoint(0,0.5)
    node:setPosition(conf.popPosArray[swich])
    table.insert(self.chatDataArray,node)
    self.bg:addChild(node,60)
    if self:getChildByTag(conf.Tag.chatList) then
        self:getChildByTag(conf.Tag.chatList):addData(tab)
    end

    local a = {}
    a[#a+1] = cc.DelayTime:create(2)
    a[#a+1] = cc.CallFunc:create(function () node:removeAllChildren() end)
    node:runAction(cc.Sequence:create(a))
end
--游戏道具
function goldNiuScene:onGameProp(data)
	local srcUid=data.SrcUid
	local destUid=data.DestUid
	local propIndex=data.PropIndex
    local curScore=data.curScore 
	local src = nil
	local dest = nil
	local srcPos = nil
	local destPos = nil
	if self.playerListUID then
		for k,v in pairs(self.playerListUID) do
			if tostring(v.uid) == tostring(data.SrcUid) then
				src = conf.swichPos(k-1,self.myid,5)
			end
			if tostring(v.uid) == tostring(destUid) then
				dest = conf.swichPos(k-1,self.myid,5)
			end
		end
	end
	srcPos = conf.popPosArray[src]
	destPos = conf.popPosArray[dest]

    local node=FrameAniFactory:getInstance():getDaoJuNode(propIndex,srcPos,destPos)

    if node then
       self.bg:addChild(node,99)       
    end
    
    self:updataCurPlayerScore(srcUid,curScore)
    userInfo[srcUid].Score=curScore  

end
--换桌
function goldNiuScene:ShowChangeTable()
    self:clearCache()
    self:showChatBtn()
    self._gameRequest:RequestTabelInfo()
end   
--清楚缓存   
function goldNiuScene:clearCache()
    self:stopAllActions()
    self:removeClockNode()

    if next(self.goldAction) then
        for i, v in pairs (self.goldAction) do
            v:removeFromParent()
        end    
    end
    self.goldAction = {}

    if self.winHeadNode then
        self.winHeadNode:setVisible(false)
        self.winHeadNode:removeFromParent()
        self.winHeadNode = nil
    end
    if self.winPart then
        self.winPart:setVisible(false)
        self.winPart:removeFromParent()
        self.winPart = nil
    end

    if self.suanniukuang then
       self.suanniukuang:hide()
    end
    
    if self.setbank then
       self.setbank:removeFromParent()
       self.setbank = nil
    end

    if self.brttingMArray~=nil then
        for i = 1,#self.brttingMArray do
            self.brttingMArray[i]:removeFromParent()
        end
        self.brttingMArray = {}
    end

    if self.gradArray~=nil then
        for i = 1,5 do
            if self.gradArray[i]  then
                self.gradArray[i]:removeFromParent()
                self.gradArray[i] = nil            
            end
        end
        self.gradArray = {}
    end

    self.hasNiuBtn:hide()
    self.noNiuBtn:hide()
    
    self.panel:hide()
 	self.panel1:hide()

    self:removeData()
    self:setDataHide()

    self.winNode:hide()
    self.xiazhu_node:hide()
    self.loseNode:hide()

    self.luckNode:setVisible(false)
    self.luckEffect:setVisible(false)
    self.luckLayerColor:setVisible(false)
    self.luckScoreNode:setVisible(false)
    self.luckTxtBg:setVisible(false)
    for i,v in ipairs(self.luckCardData) do
        v:setVisible(false)
    end
end     
--请求玩家战旗
function goldNiuScene:RequestPlayerStandUp()
    self._gameRequest:RequestPlayerStandUp()
end
--请求玩家坐下
function goldNiuScene:RequestPlayerSitDown()
    local bool = false
    if self.playerListUID then
        for k,v in pairs(self.playerListUID) do
            if UserData.userId == v.uid then
                bool = true
            end
        end
    end
    if not bool then
        self._gameRequest:RequestPlayerSit()
    end
end

--断线重连
function goldNiuScene:goldConnect(tableState)
    if tableState == nil or GameManager.TableInfoArray == nil or GameManager.TableInfoArray.player == nil then
        print("DataError goldNiuScene:goldConnect 数据为空，请检查数据")
        return
    end
    self:isCardDataNull()

    --隐藏提示
    self:hideGameTips()

    --提示旁观
    if self.isOnTable == false then
       self:showGameTips(conf.tipes.enterLook)
    end

    --在桌子上 但不在游戏中 提示等待下一局开始
    if tableState ~= conf.goldState.freetime and self._isGameing == false and self.isOnTable == true then
        self:showGameTips(conf.tipes.waitNext)
    end

    local player = GameManager.TableInfoArray.player
    if tableState == conf.goldState.freetime then
    	self:onGameStatusFree()

    --抢庄状态
    elseif tableState == conf.goldState.grapBanker then
    	self:onGameStatusGrapBanker(player)
        
    --下注阶段
    elseif tableState == conf.goldState.beting then
    	self:onGameStatusBeting(player)
        
    --算牛阶段
    elseif tableState == conf.goldState.roundAction then
    	self:onGameStatusRoundAction(player)
        
    --结算阶段
    elseif tableState == conf.goldState.setTlement then
    	self:onGameStatusSetTlement(player)
	end
end

--短线重连 游戏是空闲状态
function goldNiuScene:onGameStatusFree()
    self:startTime(GameManager.TableInfoArray.tableTime)
end

--短线重连 游戏是抢庄状态
function goldNiuScene:onGameStatusGrapBanker(player)
    local playerSelf = GameManager:getPlayerSelfInfo()
    local mysitid = GameManager:getSelfSeatId()
    if player == nil or playerSelf == nil or mysitid == nil then
        print("DataError goldNiuScene:onGameStatusGrapBanker 数据为空，请检查数据")
    end

    --旁观玩家视角
    if mysitid == 65535 then
        for i ,v in pairs(player) do
            --自己不在桌子上 创建所有玩家的牌
            if player[i].cardNum > 0 then
                self:showTanpai(conf.swichPos(player[i].seatid,0,5),4)           
            end

            --已经选择抢庄倍数的 还原抢庄倍数
	        if player[i].isGrapBanker == 1 then      
		    	local sitid = player[i].seatid
		    	local index = conf.swichPos(sitid,0,5)
		    	local multiple = player[i].multiple
		    	self:gradMultiple(index,multiple)
	        end
        end
        self:hideChatBtn()
    --自己在桌子上 
    else
        for i ,v in pairs(player) do            
            if player[i].seatid ~= mysitid then
                --创建非自己的玩家的牌
                if player[i].cardNum > 0 then
                    self:showTanpai(conf.swichPos(player[i].seatid,mysitid,5),4)           
                end
	            --显示倍数
                if player[i].isGrapBanker == 1 then      
		        	local sitid = player[i].seatid
		        	local index = conf.swichPos(sitid,mysitid,5)
		        	local multiple = player[i].multiple
		        	self:gradMultiple(index,multiple)
	            end
            end
        end        
    end
  
    --如果玩家不在本局游戏中
    if self._isGameing == false then
        return
    end

    --玩家在本局游戏中
    --创建玩家自己的手牌
    self.CardData = {}
    if player[mysitid+1].cardDataArray then
        for i,v in ipairs(player[mysitid+1].cardDataArray) do
	        local value = string.format("%02X",v)
	        self:initPlayerCard(value,i)
            table.insert(self.CardData,value)
        end           
    end
    --创建玩家自己的抢庄倍数
    if player[mysitid+1].isGrapBanker == 0 then 
        self:GradbankerBtnGold(GameManager.TableInfoArray.tableTime,player[mysitid+1].maxGrapMul)   
    else
	    local multiple = player[mysitid+1].multiple
	    self:gradMultiple(1,multiple)
        self:showGameTips(conf.tipes.waitGraBanker)
    end
end

--短线重连 游戏是下注状态
function goldNiuScene:onGameStatusBeting(player)
    local playerSelf = GameManager:getPlayerSelfInfo()
    local playInfo = GameManager.TableInfoArray
    local mysitid = GameManager:getSelfSeatId()

    if playInfo == nil or mysitid == 65535 or playerSelf == nil then
        print("DataError goldNiuScene:onGameStatusBeting 数据为空，请检查数据")
    end
  
    --设置庄家数据
    local zhuangSeat = 65535
    for i,v in pairs(player) do
	    if tostring(playInfo.bankerUser) == tostring(player[i].uid) then
	    	zhuangSeat = player[i].seatid
	    end
	end
    local index = 0;
    if mysitid == 65535 then
        index = conf.swichPos(zhuangSeat,0,5)
    else
        index = conf.swichPos(zhuangSeat,mysitid,5)      
    end
    self:setZhuangData({},index)
    self:setZhuang()

    --设置庄家倍数
    self:gradMultiple(index,player[zhuangSeat+1].multiple)
	   
    --旁观玩家视角
    if mysitid == 65535 then
        for i ,v in pairs(player) do
            --自己不在桌子上 创建所有玩家的牌
            if player[i].cardNum > 0 then
                self:showTanpai(conf.swichPos(player[i].seatid,0,5),4)
            end

            --已经选择下注倍数的 还原下注倍数
	        if player[i].isBrtting == 1 then      
	    		local index= conf.swichPos(i-1,0,5) or 65535
	    		local Brtting = player[i].Brtting
	    		self:brttingMultiple(index,Brtting)
	        end
        end
        self:hideChatBtn()
    --自己在桌子上 
    else
        for i ,v in pairs(player) do            
            if player[i].seatid ~= mysitid then
                --创建非自己的玩家的牌
                if player[i].cardNum > 0 then
                    self:showTanpai(conf.swichPos(player[i].seatid,mysitid,5),4)
                end

	            --显示倍数
                if player[i].isBrtting == 1 then      
	    		    local index= conf.swichPos(i-1,mysitid,5) or 65535
	    		    local Brtting = player[i].Brtting
	    		    self:brttingMultiple(index,Brtting)
	            end
            end
        end        
    end    
         
    --如果玩家不在本局游戏中
    if self._isGameing == false then
        return
    end
    
    --创建玩家自己的手牌
    self.CardData = {}
    if player[mysitid+1].cardDataArray then
        for i,v in ipairs(player[mysitid+1].cardDataArray) do
	        local value = string.format("%02X",v)
	        self:initPlayerCard(value,i)
            table.insert(self.CardData,value)
        end    
    end        
    --创建下注倍数
    if player[mysitid+1].isBrtting == 0 then 
        self:BrttingBtn(playInfo.bankerUser,playInfo.tableTime,player[mysitid+1].maxBrtMul)   
    else
	    local Brtting = player[mysitid+1].Brtting
	    self:brttingMultiple(1,Brtting)
        self:showGameTips(conf.tipes.waitBet)                
    end
end

--短线重连 游戏是算牛状态
function goldNiuScene:onGameStatusRoundAction(player)
    local playerSelf = GameManager:getPlayerSelfInfo()
    local playInfo = GameManager.TableInfoArray
    local mysitid = GameManager:getSelfSeatId()

    if playInfo == nil or mysitid == 65535 or playerSelf == nil then
        print("DataError goldNiuScene:onGameStatusBeting 数据为空，请检查数据")
    end

    --设置庄家数据
    local zhuangSeat = 65535
    for i,v in pairs(player) do
	    if tostring(playInfo.bankerUser) == tostring(player[i].uid) then
	    	zhuangSeat = player[i].seatid
	    end
	end
    local index = 0
    if mysitid == 65535 then
        index = conf.swichPos(zhuangSeat,0,5)
    else
        index = conf.swichPos(zhuangSeat,mysitid,5)      
    end
    self:setZhuangData({},index)
    self:setZhuang()
    --设置庄家倍数
    self:gradMultiple(index,player[zhuangSeat+1].multiple)

    --旁观玩家视角
    if mysitid == 65535 then
        for i ,v in pairs(player) do
            --自己不在桌子上 创建所有玩家的牌
            if player[i].cardNum > 0 then
                self:showTanpai(conf.swichPos(player[i].seatid,0,5),5)         
            
                --已经算牛完成的 显示完成
	            if player[i].isShowCard == 1 then      
                    self:wancheng(conf.swichPos(player[i].seatid,0,5))
	            end

                --已经选择下注倍数的 还原下注倍数
                if player[i].Brtting > 0 then
 	                local index= conf.swichPos(i-1,0,5) or 65535
	                self:brttingMultiple(index,player[i].Brtting)               
                end

            end           
        end
        self:hideChatBtn()
    --自己在桌子上 
    else
        for i ,v in pairs(player) do            
            if player[i].seatid ~= mysitid and player[i].cardNum > 0 then
                --创建非自己的玩家的牌
                self:showTanpai(conf.swichPos(player[i].seatid,mysitid,5),5)
	            --是否亮牌
                if player[i].isShowCard == 1 then      
                    self:wancheng(conf.swichPos(player[i].seatid,mysitid,5))
                end

                --已经选择下注倍数的 还原下注倍数
                if player[i].Brtting > 0 then
 	                local index= conf.swichPos(i-1,mysitid,5)
	                self:brttingMultiple(index,player[i].Brtting)               
                end
            end
        end        
    end 

    --如果玩家不在本局游戏中
    if self._isGameing == false then
        return
    end
    
    if player[mysitid+1].isShowCard == 0 then
        --创建玩家自己的手牌
        self.CardData = {}
        if self._isGameing and player[mysitid+1].cardDataArray then
            for i,v in ipairs(player[mysitid+1].cardDataArray) do
	            local value = string.format("%02X",v)
	            self:initPlayerCard(value,i)
                table.insert(self.CardData,value)
            end    
        end

        if player[mysitid+1].cardType > 0 then
            self.hasNiuBtn:setTouchEnabled(true)
            self.hasNiuBtn:setBright(true)
        end
        --算牛情况
        self:niuBtn()
        self.suanniukuang:show()
        self:taipaiTime(GameManager.TableInfoArray.tableTime)
    else
        self:showTanpai(1,5)
        self:wancheng(1)
	    self:showGameTips(conf.tipes.waitOpenCards)          
    end

    if player[mysitid+1].Brtting > 0 then
        self:brttingMultiple(1,player[mysitid+1].Brtting)               
    end
end

--短线重连 游戏是结算状态
function goldNiuScene:onGameStatusSetTlement(player)
    --self:hideGameTips()
    local playerSelf = GameManager:getPlayerSelfInfo()
    local playInfo = GameManager.TableInfoArray
    local mysitid = GameManager:getSelfSeatId()

    if playInfo == nil or mysitid == 65535 or playerSelf == nil then
        print("DataError goldNiuScene:onGameStatusBeting 数据为空，请检查数据")
    end

    --设置庄家数据
    local zhuangSeat = 65535
    for i,v in pairs(player) do
	    if tostring(playInfo.bankerUser) == tostring(player[i].uid) then
	    	zhuangSeat = player[i].seatid
	    end
	end
    local index = 0;
    if mysitid == 65535 then
        index = conf.swichPos(zhuangSeat,0,5)
    else
        index = conf.swichPos(zhuangSeat,mysitid,5)      
    end
    self:setZhuangData({},index)
    self:setZhuang()
    --设置庄家倍数
    self:gradMultiple(index,player[zhuangSeat+1].multiple)
    
    --创建牌
    if mysitid == 65535 then
        self:hideChatBtn()
        mysitid = 0
    end

    for i,v in pairs(player) do
        if player[i].cardNum > 0 then
            self:jiesuanTanPai(player[i],conf.swichPos(i-1,mysitid,5),player[i].uid)       
            --已经选择下注倍数的 还原下注倍数
            if player[i].Brtting > 0 then
 	            local index= conf.swichPos(i-1,mysitid,5)
	            self:brttingMultiple(index,player[i].Brtting)               
            end      
        end
	end

    if self.isOnTable == true then
       self:showGameTips(conf.tipes.waitJieSuan)
    end  
end

-- 破产补助
function goldNiuScene:onGameBankRupt(data)
    dump(data)
    local curTimes = data.curTimes
    local sumTimes = data.sumTimes
    local bankGoldNum = data.bankGoldNum
    local getSign = data.getSign

    if curTimes > sumTimes then
        if not manager.UserManager:getInstance():findAppCloseRoomCardFlag() then  
            self:ShopAct()
        end
    else
        local sub = nil 
        if self:getChildByTag(777) then
            return
        else 
            sub = subsidy:new()
            sub:initLayer(bankGoldNum)
            sub:setTag(777)
            self:addChild(sub,20)
        end
    end
end
-- 破产补助uid
function goldNiuScene:onGameBankSucc(data)
    if tostring(data.uid) == tostring(UserData.userId) then
        GameUtils.showMsg("领取成功")
    end
    self:updataCurPlayerScore(data.uid,data.curScore)
    userInfo[data.uid].Score=data.curScore
end

function goldNiuScene:onEnter()
	goldNiuScene.super.onEnter(self)
	GameManager:getInstance():startEventListener(self) --  父类的监听
	GameManager:getInstance():startGameEventListener(self) -- 子类的监听
	self._gameRequest:RequestTabelInfo()
    self:_onMusicPlay(manager.MusicManager.MUSICID_NIUNIU_COIN)
end

function goldNiuScene:onExit()
	-- display.removeSpriteFrames(GameResPath.."GameBtn.plist",
	-- 						GameResPath.."GameBtn.png")
	-- display.removeSpriteFrames(GameResPath.."UserBtn.plist",
	-- 						GameResPath.."UserBtn.png")
	-- display.removeSpriteFrames(GameResPath.."GameBtn_L.plist",
	-- 						GameResPath.."GameBtn_L.png")
	-- display.removeSpriteFrames(GameResPath.."card/niuniu_card.plist",
	-- 						GameResPath.."card/niuniu_card.png")
	-- display.removeSpriteFrames(GameResPath.."NiuTip.plist",
	-- 						GameResPath.."NiuTip.png")
	-- display.removeSpriteFrames(GameResPath.."private_More.plist",
	-- 						GameResPath.."private_More.png")
	-- display.removeSpriteFrames(GameResPath.."playerPanel.plist",
	-- 						GameResPath.."playerPanel.png")
	-- display.removeSpriteFrames(GameResPath.."subsidy.plist",
	-- 						GameResPath.."subsidy.png")
	-- display.removeSpriteFrames(GameResPath.."help.plist",
	-- 						GameResPath.."help.png")
	-- display.removeSpriteFrames("gamecommon/chat/res/chat.plist",
 --       						"gamecommon/chat/res/chat.png")
	-- FrameAniFactory:getInstance():clearAllSpriteFrames()
	-- display.removeSpriteFrames("gamecommon/shopAction.plist",
 --       						"gamecommon/shopAction.png")
	-- display.removeSpriteFrames(GameResPath.."action/goldniuniu_start.plist",
	-- 						GameResPath.."action/goldniuniu_start.png")
	-- display.removeSpriteFrames(GameResPath.."win/goldniu_win.plist",
	-- 						GameResPath.."win/goldniu_win.png")
 --    display.removeSpriteFrames(GameResPath.."winHead/goldniuniu_player_effect.plist",
 --                            GameResPath.."winHead/goldniuniu_player_effect.png")
 --    display.removeSpriteFrames(GameResPath.."CardType.plist",
 --                            GameResPath.."CardType.png")

    local resPathList = {config.GamePathResConfig:getGameResourcePath(config.GameIDConfig.KPQZ),
                    config.GamePathResConfig:getGameCommonResourcePath()}
    for k,v in pairs(resPathList) do
        FileSystemUtils.removePlistResource(v)
    end
    GameData.reset()
    GameManager.destory()
    self._gameRequest = nil
end

--設置玩家状态 是否在本局游戏中
function goldNiuScene:setPlayerState(__gameState, __cardsNum)
    if __gameState and __cardsNum then
        if __gameState ~= conf.goldState.freetime and __cardsNum ~= 0 then
           self._isGameing = true
           return
        end
    end
    self._isGameing = false --是否在游戏中 判断是否是中途加入
end

--显示提示语 
function goldNiuScene:showGameTips(tipes)
    if self._tipsTextLable == nil then
        self._tipsTextLable = cc.Label:createWithSystemFont("",SYSFONT,25)
        self._tipsTextLable:setAnchorPoint(cc.p(0,0.5))
        self.bg:addChild(self._tipsTextLable)         
    end

    --观战放下面
    if tipes and tipes == conf.tipes.enterLook then
        self._tipsTextLable:setPosition(cc.p(550,50))
    else
        self._tipsTextLable:setPosition(cc.p(550,375))
    end


    if tipes == nil then
       print("显示提示语 参数错误 ")
       return 
    end

    self.m_dotTimes = 1
    self.m_tipes = tipes
    local delayTime = cc.DelayTime:create(0.5)
    local callFunc = cc.CallFunc:create(function()
           local dotArray = {".", "..", "..."}
           if self._tipsTextLable then
              local str = self.m_tipes .. dotArray[self.m_dotTimes]
              self._tipsTextLable:setString(str)
           end
           self.m_dotTimes = self.m_dotTimes%3+1 
        end)
    self._tipsTextLable:stopAllActions()
    self._tipsTextLable:setString(tipes)
    self._tipsTextLable:show()
    self._tipsTextLable:runAction(cc.RepeatForever:create(cc.Sequence:create(delayTime,callFunc)))
end

--隐藏提示语UI
function goldNiuScene:hideGameTips()
    if self._tipsTextLable then
        self._tipsTextLable:stopAllActions()
        self._tipsTextLable:hide()
    end
end

--创建倒计时闹钟
function goldNiuScene:createClock(index,time)
    if self.isOnTable and time and time > 0 then
        --判断闹钟节点是否存在 存在移除
        self:removeClockNode()
        
        --重新创建闹钟       
        self.m_clockNode = tableAction:new()
        self.m_clockNode:timeStart(index,time)
        self.bg:addChild(self.m_clockNode)
    end
end

--删除指定位置的牌(背面)
function goldNiuScene:removeBackCardBySeatId(seatId) 
    if seatId == nil or seatId < 1 or seatId > 5 then
       print("删除指定位置的牌(背面) seatid 数据不合法")
       return
    end
    
    if self.handBackCard and self.handBackCard[seatId] then
        for i=1,#self.handBackCard[seatId] do
     	    self.handBackCard[seatId][i]:removeFromParent()
        end
        self.handBackCard[seatId] = {}            
    end
end

--删除所有位置的牌(背面)
function goldNiuScene:removeAllBackCard()
    if self.handBackCard then
        for i = 1, 5 do
            if self.handBackCard[i] then
                for j=1,#self.handBackCard[i] do
    	        	self.handBackCard[i][j]:removeFromParent()
    	        end
                self.handBackCard[i] = {}            
            end
        end
    end
end

--移除闹钟
function goldNiuScene:removeClockNode()
    if self.m_clockNode then
   	    self.m_clockNode:removeFromParent() 
   	    self.m_clockNode = nil
    end	
end

--获取庄家本地ID
function goldNiuScene:getZhuangLocalSeatId()
    return self.locakBankSeatid
end

--设置庄家倍数
function goldNiuScene:setZhuangTimes(times)
    if self.gradArray~=nil then
        for i = 1,5 do
            if self.gradArray[i]  then
                self.gradArray[i]:removeFromParent()
                self.gradArray[i] = nil            
            end
        end
        self.gradArray = {}
    end
    
    self:gradMultiple(self.locakBankSeatid,times)    
end

function goldNiuScene:setPlayerStatus(status)
    GameManager.userPlayStateArray = status    
end

return goldNiuScene