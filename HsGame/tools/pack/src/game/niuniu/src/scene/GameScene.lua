-- 游戏主界面 牛牛
-- @date 2017.07.13
-- @author tangwen
local Test = false
local GameModel = require "gamemodel/scene/GameModelScene"
local GameResPath  = "game/niuniu/res/GameLayout/NiuNiu/"
local NIUNIU_CSB = GameResPath .. "Layer.csb"
local GameScene = class("GameScene", GameModel)

local GameManager = require"game/niuniu/src/logic/GameManager"
local conf = require"game/niuniu/src/scene/conf"
local head = require "game/niuniu/src/header/headerFile"
local GameRequest = require "game/niuniu/src/request/GameRequest"
local tableAction = require "game/niuniu/src/scene/tableAction"
local GameResult = require "game/niuniu/src/scene/GameResult"
local Avatar = require "lib/component/node/Avatar"
local help = require "game/niuniu/src/scene/help"
local dismiss = require "game/niuniu/src/scene/dismiss"
local exploits = require "game/niuniu/src/scene/exploits"
local GamePlayerInfo = require "GamePlayerInfoView"
local chatNode = require "gamecommon/chat/src/ChatLayer"
local MenuNode = require "game/niuniu/src/scene/MenuNode"
local Time = require "game/niuniu/src/scene/Time"
local Score = require "game/niuniu/src/scene/ScoreNode"

local FrameAniFactory = cc.exports.lib.factory.FrameAniFactory
local MusicManager = cc.exports.manager.MusicManager
local scheduler = cc.Director:getInstance():getScheduler()

local LIST_SIZE = cc.size(1300,450)
-- 功能按钮标识
GameScene.BTN_MORE_SHOW	    	= 1				-- 更多显示
GameScene.BTN_MORE_HIDE         = 2             -- 隐藏
GameScene.BTN_CHAT              = 3             -- 聊天

--最大人数
local PLAYER_MAX_NUM = 5

-- 初始化界面
function GameScene:ctor()
    GameScene.super.ctor(self)
    self:enableNodeEvents()  -- 注册 onEnter onExit 时间 by  tangwen
    --self:preloadUI()
    self:initGemeData()
    self:CreateView()
    self._gameRequest = GameRequest:new()
end

function GameScene:preloadUI()
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
	display.loadSpriteFrames(GameResPath.."dismiss.plist",
							GameResPath.."dismiss.png")
	display.loadSpriteFrames(GameResPath.."exploits.plist",
							GameResPath.."exploits.png")
	display.loadSpriteFrames("gamecommon/chat/res/chat.plist",
       						"gamecommon/chat/res/chat.png")
	display.loadSpriteFrames(GameResPath.."action/goldniuniu_start.plist",
							GameResPath.."action/goldniuniu_start.png")
	display.loadSpriteFrames(GameResPath.."win/goldniu_win.plist",
							GameResPath.."win/goldniu_win.png")
    display.loadSpriteFrames(GameResPath.."winHead/goldniuniu_player_effect.plist",
                            GameResPath.."winHead/goldniuniu_player_effect.png")
	FrameAniFactory:getInstance():addAllSpriteFrames()
end

function GameScene:initGemeData()
    --桌子信息
    self.TableInfoArray = {}

    --分数列表
    self.ScoreArray = {0,0,0,0,0}

    --战绩
    self.exploitArray = {}

    --扑克数据
    self.CardData = {}

    --自己的手牌数组
    self.handCardArray = {}

    --玩家信息
    self.playerInfoData = {}

    --金币
    self.goldActionArray = {}            

    self.MaxCard = 5
    self.niuNum = 0
    self.handCard = {}
    self.downCrad = {}
    self.handBackCard = {}
    self.allSortCard = {}
    self.cardTyoeArray = {}
    
    self.gradArray = {}
    self.brttingMArray = {}
    self.txtArray = {}
    
    self.bankidArr = {}                 --转化后的庄家椅子id组
    self.bankSeatid = nil               --庄家的椅子id
    self.playerDataArray = {}           --结算时玩家数据
    self.bankerid = nil                 --庄家id
    self.clickCard = {}                 --点击的牌
    self.clickCardValue = {}            --点击的牌值
    self.clickCardNode = {}             --点击的牌值的节点
    self.FiveCardData = {}              --五张牌数据
    self.chatDataArray = {}             --聊天数据
    self.ChatListData = {}              --聊天记录数据

    self.clickNum = 0                   --点击次数

    self.myCattType = 0                 --保存自己的牌型值
end

-- 创建界面
function GameScene:CreateView()
    --测试代码
    -- self.clearBtn = ccui.Button:create(GameResPath.."txt_ready.png")
    -- self.clearBtn:setPosition(cc.p(700,700))
    -- self.clearBtn:setLocalZOrder(1000)
    -- self:addChild(self.clearBtn)
    -- self.clearBtn:addClickEventListener(function()
    --   self:resetTable()
    -- end)

    -- self.reBtn = ccui.Button:create(GameResPath.."txt_ready.png")
    -- self.reBtn:setPosition(cc.p(900,700))
    -- self.reBtn:setLocalZOrder(1000)
    -- self:addChild(self.reBtn)
    -- self.reBtn:addClickEventListener(function()
    --     self:resetTable()
    --     self._gameRequest:RequestTabelInfo()
    -- end)

	local bg = display.newSprite(GameResPath.."bg.png")
	bg:setPosition(667,375)
	self.bg = bg
	self:addChild(bg)
    local container = cc.CSLoader:createNode(NIUNIU_CSB)
	bg:addChild(container)
	self.container = container

    local roomid = cc.Label:createWithSystemFont("房间ID:",SYSFONT, 24)
    roomid:setPosition(190,730)
    self.bg:addChild(roomid)
    self.roomid=roomid
    --底分
    local difen = cc.Sprite:create(GameResPath.."rule/rule_difen.png")
    difen:setPosition(570,580)
    self.bg:addChild(difen)
    local atlasFile = GameResPath.."rule/rule_num.png"
    local atlasNode = ccui.TextAtlas:create("0",atlasFile,14,21,"0")
    atlasNode:setPosition(600,580)
    self.bg:addChild(atlasNode)
    self.atlasNode = atlasNode

    --自动算牛
    local zidong = cc.Sprite:create(GameResPath.."rule/rule_zidong.png")
    zidong:setPosition(680,580)
    self.bg:addChild(zidong)
    self.zidong=zidong
    --手动算牛
    local shoudong = cc.Sprite:create(GameResPath.."rule/rule_shoudong.png")
    shoudong:setPosition(680,580)
    self.bg:addChild(shoudong)
    self.shoudong=shoudong

    --更多
    local MoreBtn_hide = container:getChildByName("Button_more_hide")
    MoreBtn_hide:setTag(GameScene.BTN_MORE_HIDE)
    MoreBtn_hide:hide()
    MoreBtn_hide:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    self.MoreBtn_hide = MoreBtn_hide
    local MoreBtn_show = container:getChildByName("Button_more_show")
    MoreBtn_show:setTag(GameScene.BTN_MORE_SHOW)
    MoreBtn_show:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    self.MoreBtn_show = MoreBtn_show 

    -- 战绩
    local exploit = ccui.Button:create("exploit0.png","exploit1.png","exploit0.png",ccui.TextureResType.plistType)
    exploit:setPosition(1200,700)
    exploit:setTag(conf.Tag.exploit)
    exploit:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    bg:addChild(exploit)
    self.exploit = exploit
    local gameNum = cc.Label:createWithSystemFont("第0/0局",SYSFONT,24)
    gameNum:setPosition(80,40)
    gameNum:setColor(cc.c3b(255,236,109))
    exploit:addChild(gameNum)
    self.gameNum = gameNum

    --准备节点
    local readyNode = cc.Node:create()
    readyNode:setVisible(false)
    bg:addChild(readyNode)
    -- 邀请好友
    local invite = ccui.Button:create(GameResPath.."invite_0.png",GameResPath.."invite_1.png")
    invite:setPosition(490,375)
    invite:setTag(conf.Tag.invite)
    invite:addClickEventListener(function(sender) self:handleInviteFriend(sender) end)
    readyNode:addChild(invite)

    -- 准备图片
    self.readyArray = {}

    -- 准备按钮
    local ready = ccui.Button:create(GameResPath.."ready_0.png",GameResPath.."ready_1.png")
    ready:setPosition(844,375)
    ready:setTag(conf.Tag.ready)
    ready:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    readyNode:addChild(ready)
    self.readyNode = readyNode

    --抢庄倍数图片
    local gradNode = cc.Node:create()
    bg:addChild(gradNode)

    --下注倍数图片
    self.brttingMArray = {}

    for i=1,5 do
        local ready = cc.Sprite:create(GameResPath.."txt_ready.png")
        ready:setAnchorPoint(0,0)
        ready:setPosition(conf.showCardPosArray[i])
        gradNode:addChild(ready)
        ready:setVisible(false)
        table.insert(self.readyArray,ready)

        local grad = cc.Sprite:createWithSpriteFrameName("txt_qiang0.png")
        grad:setPosition(conf.multiplePosArray[i])
        grad:setVisible(false)
        gradNode:addChild(grad)
        table.insert(self.gradArray,grad)

        local mul=cc.Label:createWithCharMap(GameResPath.."xiazhu_num.png",24,33,string.byte('/'))
        mul:setPosition(conf.multiplePosArray[i])
        gradNode:addChild(mul)
        mul:setVisible(false)
        table.insert(self.brttingMArray,mul)
    end

    self.gradNode = gradNode

    --解散按钮状态
    self.dissolutionBtnState = false

 	local panel = container:getChildByName("Panel_Rate")
 	local panel1 = container:getChildByName("Panel_Rate0")
 	local panel_pri = container:getChildByName("Panel_Rate_Pre1")
 	local panel_pri1 = container:getChildByName("Panel_Rate_Pre2")
 	panel:hide()
 	panel1:hide()
 	panel_pri:hide()
 	panel_pri1:hide()
 	self.panel_pri = panel_pri
 	self.panel_pri1 = panel_pri1

 	--聊天
 	local chatBtn = container:getChildByName("Button_chat")
 	chatBtn:setTag(GameScene.BTN_CHAT)
 	chatBtn:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    chatBtn:setVisible(false)
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
    --抢庄
    for i=1,4 do
        local str = "Button_pre_"..tostring(i-1)
        local bank = panel_pri:getChildByName(str)
        bank:setTag(conf.Tag.bank0+i-1)
        bank:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    end

    --下注
    for i=1,3 do
        local str = "Button_pre_"..tostring(i)
        local brtting = panel_pri1:getChildByName(str)
        brtting:setTag(conf.Tag.brtting1+i-1)
        brtting:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
    end

    self.playerBtnArray = {} 
    self.sitBtnArray = {} 
    for i=1,5 do
        local str = "playerNode"..i
        local playerNode = container:getChildByName(str)
        str =  "player"..i
        local player = playerNode:getChildByName(str)
        player:setTag(conf.Tag.play1+i-1)
        player:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
        player:setVisible(false)
        table.insert(self.playerBtnArray,player)

        -- str = "zhuang"..i
        -- local zhuang = playerNode:getChildByName(str)
        -- zhuang:setVisible(false)

        str = "sit"..i
        local sit = playerNode:getChildByName(str)
        sit:setTag(conf.Tag.sit1+i-1)
        sit:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
        sit:setVisible(false)
        table.insert(self.sitBtnArray,sit)
    end

    --玩家节点
    self.playerCoinArr = {}             --玩家金币数据数组
    self.headDataArray = {}             --加载到界面的头像数据
    self.NameDataArray = {}             --加载到界面的名字数据

    for i=1,5 do
        local headnode = cc.Node:create()
        self.bg:addChild(headnode,30)
        local paramTab = {}
        paramTab.avatarUrl = ""
        paramTab.stencilFile = GameResPath.."player/head_bg.png"
        paramTab.defalutFile = "Lobby/res/Avatar/default_unkonw.png"
        paramTab.frameFile = GameResPath.."player/head_clip_bg.png"
        local Avatarnode = lib.node.Avatar:create(paramTab)
        if i == 2 or i == 5 then
            headnode:setPosition(conf.PlayerPosArray[i].x+21,conf.PlayerPosArray[i].y+83)
        else
            headnode:setPosition(conf.PlayerPosArray[i].x+15,conf.PlayerPosArray[i].y+15)
        end
        headnode:addChild(Avatarnode)
        headnode:setVisible(false)
        table.insert(self.headDataArray,headnode)

        local nickName = cc.Label:createWithSystemFont("",SYSFONT,26)
        if i == 2 or i == 5 then
            nickName:setPosition(conf.PlayerPosArray[i].x+68,conf.PlayerPosArray[i].y+70)
        else
            nickName:setPosition(conf.PlayerPosArray[i].x+180,conf.PlayerPosArray[i].y+80)
        end
        self.bg:addChild(nickName,30)
        nickName:setVisible(false)
        table.insert(self.NameDataArray,nickName)

        local gameCoin = cc.Label:createWithSystemFont("",SYSFONT,26)
        if i == 2 or i == 5 then
            gameCoin:setPosition(conf.PlayerPosArray[i].x+68,conf.PlayerPosArray[i].y+35)
        else
            gameCoin:setPosition(conf.PlayerPosArray[i].x+195,conf.PlayerPosArray[i].y+28)
        end
        self.bg:addChild(gameCoin,30)
        gameCoin:setString(0)
        gameCoin:setVisible(false)
        table.insert(self.playerCoinArr,gameCoin)
    end

    local dir = GameResPath.."Animation/game_start_Animation/"
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."game_start_Animation0.png",dir.."game_start_Animation0.plist",dir.."game_start_Animation.ExportJson")  
    self._startAni = ccs.Armature:create("game_start_Animation") 
    self._startAni:setPosition(self:getContentSize().width/2,self:getContentSize().height/2) 
    self:addChild(self._startAni)

    dir = GameResPath.."Animation/niuni_win2_Animation/"
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."niuni_win2_Animation0.png",dir.."niuni_win2_Animation0.plist",dir.."niuni_win2_Animation.ExportJson")  
    self._winAni = ccs.Armature:create("niuni_win2_Animation") 
    self._winAni:setPosition(self:getContentSize().width/2,self:getContentSize().height/2) 
    self._winAni:hide()
    self:addChild(self._winAni)

    dir = GameResPath.."Animation/lose2_Animation/"
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."lose2_Animation0.png",dir.."lose2_Animation0.plist",dir.."lose2_Animation.ExportJson")  
    self._loseAni = ccs.Armature:create("lose2_Animation") 
    self._loseAni:setPosition(self:getContentSize().width/2,self:getContentSize().height/2) 
    self:addChild(self._loseAni)

    --算牛框
    local suanniukuang = cc.Sprite:create(GameResPath.."suanniukuang.png")
    suanniukuang:setPosition(667,240)
    suanniukuang:hide()
    self.bg:addChild(suanniukuang)
    self.suanniukuang = suanniukuang
    
    --广播
	local broadCastView = require("Lobby/src/lobby/view/BroadCastView").new(1)
	self:addChild(broadCastView)
    --抢庄蒙灰
    local layerColor = cc.LayerColor:create(cc.c4b(10,10,10,120), display.width, display.height)
    layerColor:setVisible(false)
    self:addChild(layerColor)
    self.layerColor = layerColor
end

--桌子同步
function GameScene:updateTableInfo(TableInfoArray)
    dump(TableInfoArray)
    self:resetTable()
    self.TableInfoArray = TableInfoArray
    local tableState = self.TableInfoArray.tableState
    local tableTime = self.TableInfoArray.tableTime
    local player = self.TableInfoArray.player
    local curPlayerNum = self.TableInfoArray.curPlayer
    local tableID = self.TableInfoArray.tableID
    local curNum = self.TableInfoArray.curGameNum
    local allNum = self.TableInfoArray.GameNum
    local ruledata = NiuNiuData.parseRule(self.TableInfoArray.rule)
    local playerdata = self.TableInfoArray.playerUidData
    local playerArray = self.TableInfoArray.playerArray
    --自己的椅子id初始值为0
    self.TableInfoArray.mySitId = 0
    --自己是否入局
    self.TableInfoArray.isJoin = false
    --自己是否坐下
    self.TableInfoArray.IsSit = false

    --玩家列表
    for i,v in ipairs(player) do
        if tostring(v.uid) == tostring(UserData.userId) then
            self.TableInfoArray.mySitId = v.seatid
            self.TableInfoArray.IsSit = true
            if v.isJoin > 0 then
                self.TableInfoArray.isJoin = true
            end
        end

        --初始化分数
        self.ScoreArray[i] = v.allSocre

        local switchid = conf.swichPos(v.seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)

        self.playerCoinArr[switchid]:setString(conf.switchNum(v.allSocre))
    end

	self.roomid:setString("房间ID:"..tableID)
    self.gameNum:setString("第"..self.TableInfoArray.curGameNum.."/"..self.TableInfoArray.GameNum.."局")


    --牛牛规则
    if ruledata.AccountType == 1 then -- 手动算牛
       self.zidong:setVisible(false)
    elseif ruledata.AccountType == 0 then -- 自动算牛
        self.shoudong:setVisible(false)
    else
        self.zidong:setVisible(false)
        self.shoudong:setVisible(false)
    end
    self.atlasNode:setString(ruledata.GameBet)
    -- if ruledata.AuthorizeSit == 1 then
    --     if playerdata[UserData.userId] == nil then
    --         self:SetSpectatorsState()
    --     end
    -- end
    if ruledata.ChargeSit == 1 then--开启收费
    end
    self.ruledata = ruledata

    --聊天按钮
    self:setReadyBtnHide()

    --更新玩家信息
    self:onGamePlayerList(playerArray)

    --状态处理
    if tableState == conf.tableState.waitStart then
        self:onGameSceneWaitStart()
    elseif tableState == conf.tableState.endRound then
        self:onGameSceneStart()
    elseif tableState == conf.tableState.grapBanker then
        self:onGameSceneGradBanker()
    elseif tableState == conf.tableState.beting then
        self:onGameSceneGradBrtting()
    elseif tableState == conf.tableState.roundAction then
        self:onGameSceneShowCard()
    elseif tableState == conf.tableState.setTlement then
        self:onGameSceneGameEnd()
    end
end

--断线等待开始
function GameScene:onGameSceneWaitStart()
    print("断线等待开始")

end

--断线开始
function GameScene:onGameSceneStart()
    print("断线开始")
    local tableTime = self.TableInfoArray.tableTime
    local player = self.TableInfoArray.player

    if self.TableInfoArray.curGameNum > 1  then
        self:startTime(tableTime)
    end
end


--断线重连抢庄
function GameScene:onGameSceneGradBanker()
    print("断线重连抢庄")
    local tableTime = self.TableInfoArray.tableTime
    local player = self.TableInfoArray.player


    for i,v in ipairs(player) do
        local switchid = conf.swichPos(v.seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
        
        if self.TableInfoArray.IsSit then
            if v.isJoin > 0 then
                self:setFaPai(switchid,4)
            end
        else
            if v.isJoin > 0 then
                self:showTanpai(switchid,4)
            end
        end
        
        if player[i].cardNum > 0 then
            self.FiveCardData = {}
            for i,j in ipairs(v.cardDataArray) do
                local value = string.format("%02X",j)
                table.insert(self.FiveCardData,value)
            end
        end

        for i,v in ipairs(player[i].cardDataArray) do
            local value = string.format("%02X",v) 
            self:OnScenePlayerCard(value,i)
        end

        if tostring(UserData.userId) == tostring(player[i].uid) then
            if player[i].isGrapBanker == 0 then
                self:GradbankerBtn(tableTime)
            else
                local multiple = player[i].multiple
                self:gradMultiple(switchid,multiple)
                self:showGameTips(conf.tipes.waitGraBanker)
            end
        end
    end
    if self.TableInfoArray.bankerSitId < 5 then
        self:setZhuangData(nil,self.TableInfoArray.bankerSitId)
        self:setZhuang()
    end
end

--断线重连下注
function GameScene:onGameSceneGradBrtting()
    print("断线重连下注")
    local tableTime = self.TableInfoArray.tableTime
    local player = self.TableInfoArray.player


    for i,v in ipairs(player) do
        local switchid = conf.swichPos(v.seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
        if self.TableInfoArray.IsSit then
            if v.isJoin > 0 then
                self:setFaPai(switchid,4)
            end
        else
            if v.isJoin > 0 then
                self:showTanpai(switchid,4)
            end
        end

        if v.cardNum > 0 then
            self.FiveCardData = {}
            for i,j in ipairs(v.cardDataArray) do
                local value = string.format("%02X",j)
                table.insert(self.FiveCardData,value)
            end
        end
        for i,v in ipairs(v.cardDataArray) do
            local value = string.format("%02X",v) 
            self:OnScenePlayerCard(value,i)
        end
    end

    if tostring(UserData.userId) ~= tostring(self.TableInfoArray.bankerUser) then
        for i,v in ipairs(player) do
            if tostring(v.uid) == tostring(UserData.userId) then
                if v.isBrtting == 0 then
                    self:BrttingBtnF(self.TableInfoArray.bankerUser,tableTime)
                else
                    self:showGameTips(conf.tipes.waitBet)
                end
            end
        end
    end

    if self.TableInfoArray.bankerSitId < 5 then
        self:setZhuangData(nil,self.TableInfoArray.bankerSitId)
        self:setZhuang()
    end
end

--断线重连摊牌
function GameScene:onGameSceneShowCard()
    print("断线重连摊牌")
    local tableTime = self.TableInfoArray.tableTime
    local player = self.TableInfoArray.player

    local index = 1
    for i,v in ipairs(player) do
        if tostring(UserData.userId) == tostring(v.uid) then
            index = i
            self.myCattType = v.cardType
        end
    end
    if player[index].isShowCard == 0 then
        if self.TableInfoArray.isJoin then
            self:niuBtn()
        end
        if player[index].cardType > 0 then
            self.hasNiuBtn:setTouchEnabled(true)
            self.hasNiuBtn:setBright(true)
        end
        for j,v in ipairs(player[index].cardDataArray) do
            local value = string.format("%02X",v) 
            self:OnScenePlayerCard(value,j)
        end
        for m,v in ipairs(player) do
            local switchid = conf.swichPos(v.seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
            if self.TableInfoArray.IsSit then
                if v.isJoin > 0 then
                    self:setFaPai(switchid,5)
                end
            else
                if v.isJoin > 0 then
                    self:showTanpai(switchid,5)
                end
            end
            if v.cardNum > 0 then
                self.FiveCardData = {}
                for i,j in ipairs(v.cardDataArray) do
                    local value = string.format("%02X",j)
                    table.insert(self.FiveCardData,value)
                end
            end
        end
        self:taipaiTime(tableTime)
    else
        for m,v in ipairs(player) do
            local switchid = conf.swichPos(v.seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
            if v.isJoin > 0 then
                self:showTanpai(switchid,5)
            end
        end
        if self.TableInfoArray.IsSit then
            self:showGameTips(conf.tipes.waitOpenCards)
        end
    end

    --完成两个字
    for i,v in ipairs(player) do
        if v.isShowCard > 0 then
            local switchid = conf.swichPos(v.seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
            self:wancheng(switchid)
        end
    end
    if self.TableInfoArray.bankerSitId < 5 then
        self:setZhuangData(nil,self.TableInfoArray.bankerSitId)
        self:setZhuang()
    end
end

--断线重连结算
function GameScene:onGameSceneGameEnd()
    print("断线重连结算")
    local player = self.TableInfoArray.player
    local seatid = 1
    for i,v in ipairs(player) do
        if v.isJoin > 0 then
            for a,b in ipairs(v.cardDataArray) do
                local value = string.format("%02X",b)
                self:sortCard(a,value,v.seatid)
            end
            self:showNiu(v.seatid,v.cardType)
        end
    end
    if self.TableInfoArray.bankerSitId < 5 then
        self:setZhuangData(nil,self.TableInfoArray.bankerSitId)
        self:setZhuang()
    end

    if self.TableInfoArray.IsSit and self.TableInfoArray.isJoin == false then
        self:showGameTips(conf.tipes.waitJieSuan)
    end
end

function GameScene:setSitHide()
    for k,v in pairs(self.sitBtnArray) do
        v:setVisible(false)
    end
end

function GameScene:setSitShow()
    for k,v in pairs(self.sitBtnArray) do
        v:setVisible(true)
    end
end

function GameScene:setPlayHide()
    for k,v in pairs(self.playerBtnArray) do
        v:setVisible(false)
    end
end

function GameScene:HidePlayerNode()
    for i=1,PLAYER_MAX_NUM do
        self.headDataArray[i]:setVisible(false)
        self.NameDataArray[i]:setVisible(false)
        self.playerCoinArr[i]:setVisible(false)
    end
end

function GameScene:setReadyBtnHide()
    self.readyNode:setVisible(false)
end

function GameScene:setReadyBtnShow()
    self.readyNode:setVisible(true)
end

function GameScene:updatePlayerInfo(seatId,uid)
    self.playerBtnArray[seatId]:setVisible(true)
    self.sitBtnArray[seatId]:setVisible(false)

	--请求玩家信息
    if self.playerInfoData[uid].IsRequestUserInfo < 1 then
        self:RequestUserInfo(uid)
    else
        self:updateInfor()
    end
end


function GameScene:initPlayerInfo(uid)
    if self.playerInfoData[uid] == nil then
        self.playerInfoData[uid] = {}
        local info = {}
        info.avatar = ""
        info.gender = 0-- 0未知1男2女
        info.nickName = "游客"..tostring(uid)
        info.score = 0
        info.userId = uid
        info.winroundsum = 0
        info.losesum = 0
        info.winning = 0
        info.playerCoin = self:getScore(uid)
        info.IsRequestUserInfo = 0
        self.playerInfoData[uid] = info
    end
end

function GameScene:getScore(uid)
    local index = 1
    for i,v in ipairs(self.TableInfoArray.playerArray) do
        if tostring(uid) == tostring(v.uid) then
            index = v.seatid+1
        end
    end
    return self.ScoreArray[index]
end


function GameScene:updateInfor()
	for i,v in ipairs(self.TableInfoArray.playerArray) do
		if self.playerInfoData[v.uid] then
			self:updateAvatarByData(v.seatid,self.playerInfoData[v.uid])
		end
	end
end

function GameScene:updateAvatarByData(sitId,__data)
	local swichId = conf.swichPos(sitId,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
	-- local paramTab = {}
	-- paramTab.avatarUrl = __data.AvatarUrl
	-- paramTab.stencilFile = GameResPath.."player/head_bg.png"
	-- paramTab.defalutFile = "Lobby/res/Avatar/default_unkonw.png"
	-- paramTab.frameFile = GameResPath.."player/head_clip_bg.png"
	-- local headnode = lib.node.Avatar:create(paramTab)

    local paramTab = {}
    paramTab.avatarUrl = __data.avatar
    paramTab.stencilFile = GameResPath.."player/head_bg.png"
    paramTab.frameFile = GameResPath.."player/head_clip_bg.png"   
    local Gender = __data.gender or 0
    paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(Gender)
    local headnode = lib.node.Avatar:create(paramTab)

    self.headDataArray[swichId]:removeAllChildren()
    self.headDataArray[swichId]:addChild(headnode)
    self.NameDataArray[swichId]:setString(string.getMaxLen(__data.nickName,5))
    self.playerCoinArr[swichId]:setString(conf.switchNum(self.ScoreArray[sitId+1]))
    self.headDataArray[swichId]:setVisible(true)
    self.NameDataArray[swichId]:setVisible(true)
    self.playerCoinArr[swichId]:setVisible(true)
end

-- 请求用户信息
function GameScene:RequestUserInfo( __userID)
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_PLAYER_INFO .. __userID.."?token="..UserData.token
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onInfoCallback))
end

function GameScene:_onInfoCallback( __error,__response )
    if __error then
        print("Player Info net error")
    else
        if 200 == __response.status then
        	local data = __response.data
        	if data ~= nil then
                local kValue = data.userId
                if self.playerInfoData[kValue] == nil then
                    self:initPlayerInfo(kValue)
                end
        		self.playerInfoData[kValue].avatar = data.avatar
                self.playerInfoData[kValue].gender = data.gender
                self.playerInfoData[kValue].nickName = data.nickName
                self.playerInfoData[kValue].userId = kValue
                self.playerInfoData[kValue].winroundsum = data.winroundsum or 0
                self.playerInfoData[kValue].losesum = data.losesum or 0
                self.playerInfoData[kValue].winning = data.winning or 0
                self.playerInfoData[kValue].IsRequestUserInfo = 1
        		self:updateInfor()
        	end
        end
    end
end

--更新玩家金币，扔道具等
function GameScene:updatePlayerGold(__userID,gold)
    if self.playerInfoData[__userID] == nil then
        self:initPlayerInfo(__userID)
    end
    self.playerInfoData[__userID].Score = gold
end


function GameScene:onButtonClickedEvent(sender)
	local tag = sender:getTag()
	if tag == GameScene.BTN_MORE_SHOW then 
		self:moreListShow()
    elseif tag == GameScene.BTN_MORE_HIDE then
        if self:getChildByTag(110) == nil then
            self:moreListHide()
        end
	elseif tag == conf.Tag.hasniu then
        self.niuNum = 1                                 --家在这里
		self:clickNiuBtn()
	elseif tag == conf.Tag.noniu then
        self.niuNum = 0                                 --家在这里
		self:clickNiuBtn()
	elseif tag == GameScene.BTN_CHAT then
            self:chatAct()
	elseif tag == conf.Tag.exploit then
		self:exploitAct()
	elseif tag == conf.Tag.ready then
			self._gameRequest:RequestPlayerReady(UserData.userId,head.C2S_EnumKeyAction.C2S_PLAYER_READY)
            MusicManager:getInstance():playAudioEffect(conf.Music["Ready"],false)
    elseif tag >= conf.Tag.bank0 and  tag <= conf.Tag.bank3 then
        self:Gradbanker(tag)
    elseif tag >= conf.Tag.brtting1 and  tag <= conf.Tag.brtting3 then
        self:Brtting(tag)
    elseif tag >= conf.Tag.play1 and  tag <= conf.Tag.play5 then
        self:ClickPlayerHead(tag)
    elseif tag >= conf.Tag.sit1 and  tag <= conf.Tag.sit5 then
        self:RequestAuthorizeSitApply()
    end
end

function GameScene:handleInviteFriend( ... )
    print("邀请好友")
    local data = {
        roomId = self.TableInfoArray.tableID,--房间id
        totalGameRound =  self.TableInfoArray.GameNum,--局数
        gameBet = self.ruledata.GameBet,--底分
        gameId = config.GameIDConfig.KPQZ
    }
    lobby.CreateRoomManager:getInstance():requestShareInfo(data,function ( shareInfo )
         ShareManager:shareUrlToFriend(UserData.loginType,shareInfo)
    end)
end

--设置观战
function GameScene:SetSpectatorsState()

end

--解除观战
function GameScene:removeSpectatorsState()
    print("解除观战",self.TableInfoArray.curGameNum)
    if self.TableInfoArray.curGameNum > 0 then
        GameRequest:RequestTabelInfo()
    end
end

--设置解散按钮状态
function GameScene:setDissolutionBtnState(b)
    self.dissolutionBtnState = b
    if self:getChildByTag(110) then
        self:getChildByTag(110):setDissolutionBtnState(b)
    end
end

--确定点击玩家的uid
function GameScene:ClickPlayerHead(tag)
	local index = tag-113

    local sitId = 1
    for i=1,5 do
        local a = conf.swichPos(i-1,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
        if a == index then
            sitId = i - 1
        end
    end

    local uid = 0
    for i,v in ipairs(self.TableInfoArray.playerArray) do
        if sitId == v.seatid  then
            uid = v.uid
        end
    end

    if self.playerInfoData[uid] then
        local playerInfoView = GamePlayerInfo.new(uid)
        playerInfoView:setInfoData(self.playerInfoData[uid])
        playerInfoView:setPosition(0,0)
        self:addChild(playerInfoView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
    end
end

--更多列表显示
function GameScene:moreListShow()
    self.MoreBtn_show:hide()
    self.MoreBtn_hide:show()
    local menuNode = MenuNode.new()
    menuNode:init()
    menuNode:setDissolutionBtnState(self.dissolutionBtnState)
    menuNode:setTag(110)
    self:addChild(menuNode,110)
end

--更多列表隐藏
function GameScene:moreListHide()
    self.MoreBtn_show:show()
    self.MoreBtn_hide:hide()

    if self:getChildByTag(110) then
        self:getChildByTag(110):closeLayer()
    end
end

--帮助界面动画
function GameScene:ShowCardTypeLayer()
	local help = help:new()
	self:addChild(help,110)
end

--战绩界面动画
function GameScene:exploitAct()
	local expl = exploits:new()
 	expl:initInter(self.TableInfoArray.playerArray,self.exploitArray,self.playerInfoData)
 	self:addChild(expl,110)
end

--聊天界面
function GameScene:chatAct()
    local chat = chatNode.new()
    chat:setTag(conf.Tag.chatList)
    self:addChild(chat,15)
    chat:setData(self.ChatListData)
end

--设置
function GameScene:setAct()
    local setView = require("lobby/view/SetView").new(1)
    self:addChild(setView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
end

--战绩列表
function GameScene:exploitData(exploitArray)
    table.insert(self.exploitArray,exploitArray)
end

--准备显示
function GameScene:showReady(sit,b)
    self.readyArray[sit]:setVisible(b)
end

function GameScene:hideReady()
    for i,v in ipairs(self.readyArray) do
        v:setVisible(false)
    end
end

--游戏开始倒计时
function GameScene:startTime(time)
    if self.TableInfoArray.IsSit then
        self:createClock(conf.time.wait,time)
        self:hideGameTips()
    end
end

--游戏开始动画
function GameScene:startAct()
    self._startAni:getAnimation():playWithIndex(0,-1,0)
    MusicManager:getInstance():playAudioEffect(conf.Music["Gamestart"],false)
end

--赢的特效
function GameScene:victoryAct()
    self._winAni:getAnimation():playWithIndex(0,-1,0)
    MusicManager:getInstance():playAudioEffect(conf.Music["Gamewin"],false)
    local a={}
    a[#a+1]=cc.DelayTime:create(1)
    a[#a+1]=cc.CallFunc:create(function() self._winAni:setVisible(false) end)
    self:runAction(cc.Sequence:create(a))
end

--输的特效
function GameScene:loseAct()
    self._loseAni:getAnimation():playWithIndex(0,-1,0)
    MusicManager:getInstance():playAudioEffect(conf.Music["Gamelose"],false)
end

--开始发牌
function GameScene:StartFaPai(playerArray)
	for i,v in ipairs(playerArray) do
        local switchId = conf.swichPos(v.seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
        if self.TableInfoArray.isJoin then
            self:showFaPai(switchId,4)
        else
            self:showTourFaPai(switchId,4)
        end
	end
end

--断线重连专用牌
function GameScene:setFaPai(seatId,cardNum)
    local b = true
    if self.TableInfoArray.isJoin and seatId == 1 then
        b = false
    end
    for j=1, cardNum do
        if b then
            local cardNode = display.newNode()
            cardNode:setScale(0.6)
            self.bg:addChild(cardNode)
            local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
            backCard:setPosition(1120+j*50,660)
            cardNode:addChild(backCard)
            table.insert(self.handBackCard,backCard)
            
            cardNode:setPosition(conf.cardPosArray[seatId])
        end
    end
    MusicManager:getInstance():playAudioEffect(conf.Music["Fapai_more"],false)
end

--发牌(观战视角)
function GameScene:showTourFaPai(seatId,index)
    for j=1, index do
        local cardNode = display.newNode()
        cardNode:setScale(0.6)
        self.bg:addChild(cardNode)
        local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
        backCard:setPosition(1120+j*50,660)
        cardNode:addChild(backCard)
        self.backCard = backCard
        table.insert(self.handBackCard,backCard)
        if seatId == 1 then
            cardNode:runAction(cc.EaseSineIn:create(cc.MoveTo:create(0.2+j*0.05,cc.p(-94,-195))))
        else
            cardNode:runAction(cc.EaseSineIn:create(cc.MoveTo:create(0.2+j*0.05,conf.cardPosArray[seatId])))
        end
    end
    MusicManager:getInstance():playAudioEffect(conf.Music["Fapai_more"],false)
end

--发牌
function GameScene:showFaPai(seatId,cardNum)
	for j=1, cardNum do
		local cardNode = display.newNode()
		cardNode:setScale(0.6)
		self.bg:addChild(cardNode)
		local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
		backCard:setPosition(1120+j*50,660)
		cardNode:addChild(backCard)
		table.insert(self.handBackCard,backCard)
		if seatId == 1 then
            local array = {}
            array[#array + 1] = cc.EaseSineIn:create(cc.MoveTo:create(0.3+j*0.05,cc.p(conf.cardPosArray[seatId].x+j*80,conf.cardPosArray[seatId].y)))
            array[#array + 1] = cc.ScaleTo:create(0.3,0.8)
            
            local spawn = cc.Spawn:create(array)
            local seq = cc.Sequence:create(spawn,cc.DelayTime:create(0.3),
                cc.CallFunc:create(
                    function ()
                        cardNode:hide()
                    end))
            cardNode:runAction(seq)

            table.insert(self.handCardArray,cardNode)
		else
			cardNode:runAction(cc.EaseSineIn:create(cc.MoveTo:create(0.3+j*0.05,conf.cardPosArray[seatId])))
		end
	end
    MusicManager:getInstance():playAudioEffect(conf.Music["Fapai_more"],false)
end

--初始化玩家牌
function GameScene:setPlayerCard()
	for i,v in ipairs(self.CardData) do
		self:initPlayerCard(v,i)
	end
end

--初始化玩家牌
function GameScene:initPlayerCard(cardValue,i)
    cardValue = cardValue or "00"
	for j,v in ipairs(self.handCardArray) do
        if v then
            v:runAction(cc.Sequence:create(cc.OrbitCamera:create(0.3,1,0,0,-90,0,0),cc.FadeOut:create(0.1)))
        end
	end

	local frontCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x"..cardValue..".png")
	frontCard:setTag(i)
	frontCard:setPosition(300+i*110,100)
	frontCard:setScale(0.8)
	frontCard:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.FadeIn:create(0.1),cc.OrbitCamera:create(0.3,1,0,90,-90,0,0)))
	self.bg:addChild(frontCard)
    self:cardClickedEvent(frontCard)
    table.insert(self.handCard,frontCard)
end

--断线重连初始化玩家牌
function GameScene:OnScenePlayerCard(cardValue,i)
    cardValue = cardValue or "00"

    local frontCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x"..cardValue..".png")
    frontCard:setTag(i)
    frontCard:setPosition(300+i*110,100)
    frontCard:setScale(0.8)
    self.bg:addChild(frontCard)
    self:cardClickedEvent(frontCard)
    table.insert(self.handCard,frontCard)
end

function GameScene:cardClickedEvent(sprite)
	local listener = cc.EventListenerTouchOneByOne:create()
	local function onTouchBegan(touch, event)
		local target = event:getCurrentTarget()
		local size = target:getContentSize()
		local rect = cc.rect(10, 10, size.width-10, size.height-10)
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

function GameScene:upCard(sprite)
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
function GameScene:niuCount(sprite)
    local value = self.FiveCardData[sprite:getTag()]
    local num = tonumber(value, 16)
    local kNum = tonumber(num)%16
    table.insert(self.clickCard,sprite)
    table.insert(self.clickCardValue,kNum)
end

--牌的点数
function GameScene:cardDianShu(num,i)
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
function GameScene:sumCardDianshu(sum)
    if self.numnode then
        self.numnode:removeFromParent()
        self.numnode = nil
    end
    if sum == 0 then
        return
    end
    local xx = self.suanniukuang:getContentSize().width
    local numnode = cc.Node:create()
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
    self.numnode = numnode
end

--设置点击牌值的位置
function GameScene:setValuePos() 
    for i,v in ipairs(self.clickCardNode) do
        v:hide()
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

    if self.ruledata.AccountType == 1 then--手动算牛
        self:shoudongSuanniu()
    end
end

--抢庄按钮显示
function GameScene:GradbankerBtn(time)
    if self.TableInfoArray.isJoin ==false then
        return
    end
    if self.TableInfoArray.IsSit  then
        self.panel_pri:show()
    end

    self:createClock(conf.time.gradBank,time)
end

--抢庄
function GameScene:Gradbanker(tag)
	self.panel_pri:hide()
	self._gameRequest:RequestGameGradbanker(UserData.userId,head.C2S_EnumKeyAction.C2S_PLAYER_GRADBANKER,tag-101)
	self:removeClock()
end

--抢庄隐藏
function GameScene:GradbankerHide()
    if self.panel_pri then
        self.panel_pri:hide()
    end
    self:removeClock()
end

--抢庄的倍数
function GameScene:gradMultiple(index,multiple)
    self.gradArray[index]:initWithSpriteFrameName("txt_qiang"..tostring(multiple)..".png")
    self.gradArray[index]:setVisible(true)
end

--隐藏抢庄的倍数
function GameScene:HideAllMultiple()
    for i,v in ipairs(self.gradArray) do
        self.gradArray[i]:setVisible(false)
    end
end

--设置庄家数据
function GameScene:setZhuangData(bankidArr,bankSeatid)
	self.bankidArr = bankidArr
	self.bankSeatid = bankSeatid
end

--选庄动画
function GameScene:roundZhuangAct()
    if self.bankidArr then
        if #self.bankidArr == 1 then
            return
        end
    end
    self.layerColor:setVisible(true)
	local rezhuang = tableAction:new()
    rezhuang:roundZhuang(self.bankidArr)
    self.bg:addChild(rezhuang)
    self.rezhuang = rezhuang
    MusicManager:getInstance():playAudioEffect(conf.Music["Xuanzhuang"],false)
end

--设置庄家
function GameScene:setZhuang()
    if self.setbank then
        self.setbank:removeFromParent()
        self.setbank = nil
    end
    self.layerColor:setVisible(false)
	local setbank = tableAction:new()
    local switchId = conf.swichPos(self.bankSeatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
    setbank:zhuangEffect(switchId)
    self.bg:addChild(setbank)
    self.setbank = setbank
    MusicManager:getInstance():playAudioEffect(conf.Music["Dingzhuang"],false)
end

--下注的倍数
function GameScene:brttingMultiple(index,multiple)
    self.brttingMArray[index]:setString("/"..multiple)
    self.brttingMArray[index]:setVisible(true)
end

--下注按钮显示
function GameScene:BrttingBtnF(UserId,time)
	if tostring(UserData.userId) ~= tostring(UserId) then
        if self.TableInfoArray.IsSit and self.TableInfoArray.isJoin then
            self.panel_pri1:show()
            self:createClock(conf.time.brtting,time)
        end
	end

	local array = {}
	array[#array+1] = cc.DelayTime:create(1)
	array[#array+1] = cc.CallFunc:create(
		function ()
			self:HideAllMultiple()
		end)
	local seq = cc.Sequence:create(array)
	self:runAction(seq)
end

--下注
function GameScene:Brtting(tag)
	self._gameRequest:RequestGameBrtting(UserData.userId,head.C2S_EnumKeyAction.C2S_PLAYER_BRTTING,tag-104)
	self.panel_pri1:hide()
end

--隐藏下注按钮
function GameScene:hideBrttingBtn()
	self:removeClock()
	self.panel_pri1:hide()
end

--显示有牛没牛按钮
function GameScene:niuBtn()
    self.suanniukuang:show()
	self.hasNiuBtn:show()
	self.noNiuBtn:show()
end

function GameScene:clickNiuBtn()
	self._gameRequest:RequestGameShowCard(UserData.userId,head.C2S_EnumKeyAction.C2S_PLAYER_SWIGN,self.niuNum)
end

--五张牌数据
function GameScene:FiveCard(FiveCardData)
    self.FiveCardData = FiveCardData
end

function GameScene:judgeNiu(num)
    if self.ruledata then
        if self.ruledata.AccountType == 0 then--自动算牛
            self:zidongSuanniu(num)
        elseif self.ruledata.AccountType == 1 then--手动算牛
            self.myCattType = num
             if num > 10 then
                self.hasNiuBtn:setTouchEnabled(true)
                self.hasNiuBtn:setBright(true)
            end
        end
    end
end

--自动算牛
function GameScene:zidongSuanniu(num)
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
function GameScene:shoudongSuanniu()
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

--发送最后一张牌(游客视角)
function GameScene:showTourLastCard(seatId)
    local switchid = conf.swichPos(seatId,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
    local cardNode1 = display.newNode()
    cardNode1:setScale(0.6)
    self.bg:addChild(cardNode1)
    local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
    backCard:setPosition(1120+5*50,660)
    cardNode1:addChild(backCard,35)
    table.insert(self.handBackCard,backCard)
    if switchid == 1 then
        cardNode1:runAction(cc.EaseSineIn:create(cc.MoveTo:create(0.2,cc.p(-94,-195))))
    else
        cardNode1:runAction(cc.EaseSineIn:create(cc.MoveTo:create(0.2,conf.cardPosArray[switchid])))
    end
    MusicManager:getInstance():playAudioEffect(conf.Music["Fapai_one"],false)
end

--发送最后一张牌
function GameScene:showLastCard(seatId)
    local switchid = conf.swichPos(seatId,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
	self.suanniukuang:show()
	local cardNode1 = display.newNode()
	cardNode1:setScale(0.6)
	self.bg:addChild(cardNode1)
	local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
	backCard:setPosition(1120+5*50,660)
	cardNode1:addChild(backCard)
	table.insert(self.handBackCard,backCard)
	if switchid == 1  then
        local array = {}
        array[#array + 1] = cc.EaseSineIn:create(cc.MoveTo:create(0.3,cc.p(conf.cardPosArray[switchid].x+5*80,conf.cardPosArray[switchid].y)))
        array[#array + 1] = cc.ScaleTo:create(0.3,0.8,0.8)
        local spawn = cc.Spawn:create(array)
        cardNode1:runAction(spawn)
        table.insert(self.handCardArray,cardNode1)
	else
		cardNode1:runAction(cc.EaseSineIn:create(cc.MoveTo:create(0.3,conf.cardPosArray[switchid])))
	end
    MusicManager:getInstance():playAudioEffect(conf.Music["Fapai_one"],false)
end

function GameScene:taipaiTime(time)
    self:createClock(conf.time.putCard,time)
end

--摊牌
function GameScene:ShowCard()
    self.suanniukuang:hide()
	self:removeClock()

	for i,v in pairs(self.handCard) do
        if v then
            v:removeFromParent()
        end
	end
    self.handCard = {}
	for i=1,self.MaxCard do
		local showDownCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
		showDownCard:setPosition(575+i*30,200)
		showDownCard:setScale(0.6)
		self.bg:addChild(showDownCard)
		table.insert(self.downCrad,showDownCard)
	end
	local array = {}
	array[#array + 1] = cc.DelayTime:create(1)
	local seq = cc.Sequence:create(array)
	self:runAction(seq)
	self:hideNiuBtn()
end

function GameScene:hideNiuBtn()
	self.hasNiuBtn:hide()
    self.hasNiuBtn:setTouchEnabled(false)
    self.hasNiuBtn:setBright(false)
	self.noNiuBtn:hide()
end

--设置玩家数据
function GameScene:setPlayerData(playerDataArray,bankid)
	self.playerDataArray = playerDataArray
	self.bankerid = bankid
end

--玩家摊牌
function GameScene:playerTanpai()
	if self.playerDataArray == nil then
		return
	end
	for i,v in ipairs(self.playerDataArray) do
		self:runAction(cc.Sequence:create(cc.DelayTime:create(i),
			cc.CallFunc:create(function () self:startTanPai(v,v.playerSeatId) end)))
	end
end

--开始摊牌
function GameScene:startTanPai(oneData,SeatId)
	for m=1,oneData.playerCardNum do
	    local value = string.format("%02X",oneData.CardArray[m])
	    self:sortCard(m,value,SeatId)
	end
	self:showNiu(SeatId,oneData.playerCardType)
end

--最后显示五张牌
function GameScene:sortCard(index,value,seatId)
    local switchid = conf.swichPos(seatId,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
	local card = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x"..value..".png")
	card:setPosition(conf.showCardPosArray[switchid].x+index*32,conf.showCardPosArray[switchid].y)
	card:setScale(0.6)
	card:runAction(cc.OrbitCamera:create(0.3,1,0,90,-90,0,0))
	self.bg:addChild(card,10)
	table.insert(self.allSortCard,card)
end

--显示牛
function GameScene:showNiu(seatId,cardtype)
    local switchid = conf.swichPos(seatId,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
	local txtBg = cc.Sprite:createWithSpriteFrameName("txt_bg.png")
	txtBg:setPosition(conf.showCardPosArray[switchid].x+90,conf.showCardPosArray[switchid].y-30)
	self.bg:addChild(txtBg,11)

	-- local txtTip = cc.Sprite:createWithSpriteFrameName("txt_niu"..cardtype..".png")
	-- txtTip:setPosition(txtBg:getContentSize().width/2,txtBg:getContentSize().height/2)
	-- txtBg:addChild(txtTip)

    -- if cardtype == 0 or cardtype >= 10 then
        local txtTip = cc.Sprite:create(GameResPath.."txtNiu/goldtxt_niu"..cardtype..".png")
        txtTip:setPosition(txtBg:getContentSize().width/2,txtBg:getContentSize().height/2)
        txtBg:addChild(txtTip)
        if cardtype > 6 then
            txtTip:setScale(2)
            txtTip:runAction(cc.ScaleTo:create(0.1,1))
        end
    -- else
    --     local pTexture = display.loadImage(GameResPath.."txtNiu/goldtxt_niu1-9.png")
    --     local txtTip1 = cc.Sprite:createWithTexture(pTexture,cc.rect(0,0,43,40))
    --     local txtTip2 = cc.Sprite:createWithTexture(pTexture,cc.rect(tonumber(cardtype)*43,0,43,40))
    --     txtTip1:setPosition(txtBg:getContentSize().width/2-22,txtBg:getContentSize().height/2)
    --     txtTip2:setPosition(txtBg:getContentSize().width/2+22,txtBg:getContentSize().height/2)
    --     txtBg:addChild(txtTip1)
    --     txtBg:addChild(txtTip2)

    --     if cardtype > 6 then
    --         txtTip1:setScale(2)
    --         txtTip1:runAction(cc.ScaleTo:create(0.1,1))
    --         txtTip2:setScale(2)
    --         txtTip2:runAction(cc.ScaleTo:create(0.1,1))
    --     end
    -- end


	-- if cardtype == 0 then
	-- 	txtBg:setOpacity(0)
	-- end
	table.insert(self.cardTyoeArray,txtBg)

    local uid = nil
    for i,v in ipairs(self.TableInfoArray.playerArray) do
        if v.seatid == seatId then
            uid = v.uid
        end
    end

    if uid then
        local musicStr = nil
        if self.playerInfoData[uid].Gender == ConstantsData.SexType.SEX_MAN then
            musicStr=conf.Music["Man_ox"]..tostring(cardtype)..".mp3"
        else
            musicStr=conf.Music["Woman_ox"]..tostring(cardtype)..".mp3"
        end
        MusicManager:getInstance():playAudioEffect(musicStr,false)
    end
end

--显示输赢特效
function GameScene:setBunkoEffect()
    if self.TableInfoArray.isJoin == false then
        return
    end
    local index = 1
    for i,v in ipairs(self.playerDataArray) do
        if UserData.userId == v.playerUid then
            index = i
        end
    end
	if self.playerDataArray[index].playerGoal > 0 then
        self:victoryAct()
    elseif self.playerDataArray[index].playerGoal < 0 then
        self:loseAct()
    end
end

--金币走向
function GameScene:setGoldToward()
	for i,v in ipairs(self.playerDataArray) do
        if v.playerSeatId+1 ~= self.bankerid then
            local id = conf.swichPos(v.playerSeatId,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
            local swichBankId = conf.swichPos(self.bankerid-1,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
            if self.playerDataArray[i].playerGoal > 0 then
                self:setGoldEffect(swichBankId,id)
            elseif self.playerDataArray[i].playerGoal < 0 then
                self:setGoldEffect(id,swichBankId)
            end
        end
    end
end

--金币动画
function GameScene:setGoldEffect(id1,id2)
	local action = tableAction:new()
    action:goldCoin(id1,id2)
    self:addChild(action)
    table.insert(self.goldActionArray,action)
    MusicManager:getInstance():playAudioEffect(conf.Music["coinfly"],false)
    local a = {}
    a[#a+1] = cc.DelayTime:create(1)
    a[#a+1] = cc.CallFunc:create(function () self:setGoldHeadEff(id2) end)
    self:runAction(cc.Sequence:create(a))
end

function GameScene:setGoldHeadEff(id)
    local winHeadNode = nil
    local winHeadAct = nil
    if id == 2 or id == 5 then
        winHeadNode = cc.CSLoader:createNode(GameResPath.."winHead/win_gold_effect_2.csb")
        winHeadAct = cc.CSLoader:createTimeline(GameResPath.."winHead/win_gold_effect_2.csb")
        winHeadNode:setPosition(conf.headPosArray[id].x+55,conf.headPosArray[id].y+90)
    else
        winHeadNode = cc.CSLoader:createNode(GameResPath.."winHead/win_gold_effect.csb")
        winHeadAct = cc.CSLoader:createTimeline(GameResPath.."winHead/win_gold_effect.csb")
        winHeadNode:setPosition(conf.headPosArray[id].x+113.5,conf.headPosArray[id].y+56.5)
    end
    self.bg:addChild(winHeadNode)
    winHeadAct:setTimeSpeed(1) --设置执行动画速度
    winHeadAct:gotoFrameAndPlay(0,false)
    winHeadNode:runAction(winHeadAct)

    --胜利头像例子
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
function GameScene:wancheng(index)
	local txtBg = cc.Sprite:createWithSpriteFrameName("txt_bg.png")
	txtBg:setPosition(conf.showCardPosArray[index].x+90,conf.showCardPosArray[index].y-30)
	self.bg:addChild(txtBg,8)
	-- local txtTip = cc.Sprite:createWithSpriteFrameName("txt_wancheng.png")
    local txtTip = cc.Sprite:create(GameResPath.."txtNiu/goldtxt_wancheng.png")
	txtTip:setPosition(txtBg:getContentSize().width/2,txtBg:getContentSize().height/2)
	txtBg:addChild(txtTip)
	table.insert(self.txtArray,txtBg)
end

--隐藏完成
function GameScene:hideWancheng()
	if next(self.txtArray)~=nil then
		for i,v in ipairs(self.txtArray) do
            if v then
                v:setVisible(false)
            end
		end
	end
end

--设置玩家得分
function GameScene:setPlayerScore()
	local index = 1
    for i,v in ipairs(self.playerDataArray) do
        local switchid = conf.swichPos(v.playerSeatId,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
        self:playerScore(switchid,v.playerGoal)
    end
end

function GameScene:updatePlayerScore()
    for i,v in ipairs(self.playerDataArray) do
        local swichId = conf.swichPos(v.playerSeatId,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
        self.playerCoinArr[swichId]:setString(self.ScoreArray[v.playerSeatId+1])
    end
end

--玩家单局得分
function GameScene:playerScore(seatId,score)
    local scoreNode = Score.new(seatId,score)
    self.bg:addChild(scoreNode)


	self:updatePlayerScore()
end

--重置桌子
function GameScene:resetTable()
    self:stopAllActions()

    --隐藏闹钟
    self:hideGameTips()

    --隐藏有牛没牛按钮
    self:hideNiuBtn()

    --隐藏游戏开始动画
    -- self.xiazhu_node:setVisible(false)

    --隐藏抢庄按钮
    self:GradbankerHide()

    --隐藏下注按钮
    self:hideBrttingBtn()

    --隐藏抢庄倍数
    self:HideAllMultiple()

    --隐藏闹钟
    self:removeClock()

    --隐藏赢的动画
    -- self.winNode:setVisible(false)
    -- self.loseNode:setVisible(false)

    --隐藏牌
    self:hideWancheng()
    for i,v in ipairs(self.downCrad) do
        if v then
            v:removeFromParent() 
        end
    end
    for i,v in pairs(self.handCard) do
        if v then
            v:removeFromParent()
        end
    end
    for i,v in ipairs(self.handBackCard) do
        if v then
            v:removeFromParent()
        end
    end
    for i,v in ipairs(self.allSortCard) do
        if v then
            v:removeFromParent()
        end
    end
    for i,v in ipairs(self.cardTyoeArray) do
        if v then
            v:removeFromParent()
        end
    end
    for i,v in ipairs(self.brttingMArray) do
        v:setVisible(false)
    end
    for i,v in ipairs(self.handCardArray) do
        if v then
            v:removeFromParent()
        end
        
    end

    for i,v in ipairs(self.txtArray) do
        if v then
            v:removeFromParent()
        end
    end

    self.handCard = {}
    self.handCardArray = {}
    self.downCrad = {}
    self.handBackCard = {}
    self.allSortCard = {}
    self.cardTyoeArray = {}
    self.txtArray = {}

    self.clickCard = {}                 --点击的牌
    self.clickCardValue = {}            --点击的牌值
    self.clickCardNode = {}             --点击的牌值的节点
    self.FiveCardData = {}              --五张牌数据
    self.clickNum = 0                   --点击次数

    if self.numnode then
        self.numnode:removeFromParent()
        self.numnode = nil
    end
    

    --tableaction释放
    if self.tableEffect then
        self.tableEffect:removeFromParent()
        self.tableEffect = nil
    end
    if self.lose then
        self.lose:removeFromParent()
        self.lose = nil
    end
    if self.rezhuang then
        self.rezhuang:removeFromParent()
        self.rezhuang = nil
    end
    --隐藏庄家框
    if self.setbank then
        self.setbank:removeFromParent()
        self.setbank = nil
    end
    for i,v in ipairs(self.goldActionArray) do
        if v then
            v:removeFromParent()
        end
    end
    self.goldActionArray = {}

    if self.goldAction then
        self.goldAction:removeFromParent()
        self.goldAction = nil
    end

    --算牛框
    self.suanniukuang:removeAllChildren()
    self.suanniukuang:setVisible(false)

    if self.winHeadNode then
        self.winHeadNode:removeFromParent()
        self.winHeadNode = nil
    end
    if self.winPart then
        self.winPart:removeFromParent()
        self.winPart = nil
    end
end

----------------------------------------------------------------------消息处理----------------------------------------------------------------------
--玩家列表
function GameScene:onGamePlayerList(playerArray)
    dump(playerArray)
    print("自己是否坐下",self.TableInfoArray.isJoin)
    local myIsSit = false
    for i,v in ipairs(playerArray) do
        if tostring(v.uid) == tostring(UserData.userId) then
            myIsSit = true
        end
    end

    if self.TableInfoArray.isJoin == false and self.TableInfoArray.IsSit == false and myIsSit then
        self:resetTable()
    end
    self.TableInfoArray.playerArray = playerArray

    for i,v in ipairs(self.TableInfoArray.playerArray) do
        if tostring(v.uid) == tostring(UserData.userId) then
            self.TableInfoArray.mySitId = v.seatid
            self.TableInfoArray.IsSit = true
            self:setSitHide()
        end

        --初始化玩家信息
        self:initPlayerInfo(v.uid)

        self.playerInfoData[v.uid].Score = v.Score
    end

    if self.TableInfoArray.IsSit then
        self.chatBtn:setVisible(true)
    end

    if self.TableInfoArray.IsSit == false and self.TableInfoArray.curGameNum > 0 then
        self:showGameTips(conf.tipes.enterLook)
    end

    --准备两个字
    self:hideReady()
    if self.TableInfoArray.curGameNum < 1 then
        for i,v in ipairs(self.TableInfoArray.playerArray) do
            if v.isReady > 0 then
                local swich = conf.swichPos(v.seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
                self:showReady(swich,true)
            else
                if tostring(UserData.userId) == tostring(v.uid) and self.TableInfoArray.IsSit  then
                    self:setReadyBtnShow()
                end
            end
        end
    end

    --解散按钮状态
    if tostring(UserData.userId) == tostring(self.TableInfoArray.landlord) then
        self:setDissolutionBtnState(true)
    else
        if self.TableInfoArray.IsSit then
            if self.TableInfoArray.curGameNum>0 then
                self:setDissolutionBtnState(true)
            else
                self:setDissolutionBtnState(false)
            end
        else
            self:setDissolutionBtnState(false)
        end
    end

    self:setPlayHide()
    self:HidePlayerNode()
    
    if self.TableInfoArray.IsSit then
        self:setSitHide()
    else
        self:setSitShow()
    end

    --更新玩家信息
    for i,v in ipairs(playerArray) do
        local swichId = conf.swichPos(v.seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
        self:updatePlayerInfo(swichId,v.uid)
    end
end

--准备
function GameScene:onGameReady(data)
    dump(data)
    local readyUid = data.readyUid
    local readySit = data.readySit

    local index = 0
    for i,v in ipairs(self.TableInfoArray.playerArray) do
        if UserData.userId == v.uid then
            index = v.seatid
        end
    end
    local swich = conf.swichPos(readySit,index,5)
    self:showReady(swich,true)

    if tostring(readyUid) == tostring(UserData.userId) then
        self:setReadyBtnHide()
    end
end

-- 等待开始
function GameScene:onGameWaitStart(data)
    dump(data)
    local curGameNum = data.curGameNum
    local freeTime = data.freeTime

    self:resetTable()

    self.TableInfoArray.curGameNum = curGameNum
    self.gameNum:setString("第"..self.TableInfoArray.curGameNum.."/"..self.TableInfoArray.GameNum.."局")

    self:hideReady()

    if self.TableInfoArray.curGameNum > 1  then
        self:startTime(freeTime)
    end

    self.gameNum:setString("第"..self.TableInfoArray.curGameNum.."/"..self.TableInfoArray.GameNum.."局")

    if self.TableInfoArray.IsSit == false and self.TableInfoArray.curGameNum > 0 then
        self:showGameTips(conf.tipes.enterLook)
    end
end

--游戏开始
function GameScene:onGameStart(data)
    dump(data)
    if self.TableInfoArray.IsSit then
        self:setDissolutionBtnState(true)
        self.TableInfoArray.isJoin = true
    end

    -- self.xiazhu_node:setVisible(false)
    self:setReadyBtnHide()
    local bankTime = data.bankTime
    local playerNum = data.playerNum
    local playerArray = data.playerArray
    local cardNum = data.cardNum
    local cardDataArray = data.cardDataArray

    self.CardData=cardDataArray

    self.FiveCardData = cardDataArray

    self:hideReady()

    local a = {}
    a[#a+1] = cc.CallFunc:create(function() self:startAct() end)
    a[#a+1] = cc.DelayTime:create(1)
    a[#a+1] = cc.CallFunc:create(function() self:StartFaPai(playerArray) end)
    a[#a+1] = cc.DelayTime:create(0.3)
    a[#a+1] = cc.CallFunc:create(function()
        self:GradbankerBtn(bankTime-1)
        self:setPlayerCard() 
        end)
    local seq = cc.Sequence:create(a)
    self:runAction(seq)
end

--抢庄
function GameScene:onGameGradBanker(data)
    dump(data)
    local uid = data.uid
    local seatId= data.seatId
    local multiple = data.multiple

    local switchId = conf.swichPos(seatId,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
    self:gradMultiple(switchId,multiple)

    if self.TableInfoArray.mySitId == seatId and self.TableInfoArray.isJoin then
        self:showGameTips(conf.tipes.waitGraBanker)
    end
end

--庄家ID
function GameScene:onGameGradBankerID(data)
    dump(data)
    local brtTime = data.brtTime
    local bankUid = data.bankUid
    local bankSeatId = data.bankSeatId
    local bankNum = data.bankNum
    local bankSeatIdArray = data.bankSeatIdArray

    self.TableInfoArray.bankerUser = bankUid

    self:GradbankerHide()

    if self.TableInfoArray.IsSit then
        self:hideGameTips()
    end

    local bankidArr = {}
    for i,v in ipairs(bankSeatIdArray) do
        local id = conf.swichPos(v,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
        table.insert(bankidArr,id)
    end

    self:setZhuangData(bankidArr,bankSeatId)

    local a = {}
    a[#a+1] = cc.CallFunc:create(function() self:roundZhuangAct() end)
    a[#a+1] = cc.DelayTime:create(1)
    a[#a+1] = cc.CallFunc:create(function() self:setZhuang() end)
    a[#a+1] = cc.DelayTime:create(0.5)
    a[#a+1] = cc.CallFunc:create(function()
            self:BrttingBtnF(bankUid,brtTime-2)
        end)
    self:runAction(cc.Sequence:create(a))
end

--下注
function GameScene:onGameGradBrtting(data)
    dump(data)
    local uid = data.uid
    local seatId = data.seatId
    local multiple = data.multiple

    self:GradbankerHide()

    local switchId = conf.swichPos(seatId,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
    self:brttingMultiple(switchId,multiple)

    if self.TableInfoArray.mySitId == seatId and self.TableInfoArray.isJoin then
        self:showGameTips(conf.tipes.waitBet)
    end
end

--下注结束
function GameScene:onGameGradBrttingEnd(data)
    dump(data)
    local baipaiTime = data.baipaiTime
    local playerArray = data.playerArray
    local niuType = data.niuType
    local cardNum = data.cardNum
    local cardData = data.cardData

    self:hideBrttingBtn()

    if self.TableInfoArray.IsSit then
        self:hideGameTips()
    end

    for i,v in pairs(playerArray) do
        if self.TableInfoArray.isJoin  then
            self:showLastCard(v.seatid)
        else
            self:showTourLastCard(v.seatid)
        end
        
    end
    if self.TableInfoArray.isJoin then
        self:initPlayerCard(cardData[cardNum],cardNum)
        self:niuBtn()
        self:FiveCard(cardData)
        self:judgeNiu(niuType)
    end
    
    self:taipaiTime(baipaiTime)
end

--显示提示语 
function GameScene:showGameTips(tipes)
    if self._tipsTextLable == nil then
        self._tipsTextLable = cc.Label:createWithSystemFont("",SYSFONT,25)
        self._tipsTextLable:setAnchorPoint(cc.p(0,0.5))
        self:addChild(self._tipsTextLable)         
    end

    --观战放下面
    if tipes and tipes == conf.tipes.enterLook then
        self._tipsTextLable:setPosition(cc.p(550,50))
    else
        self._tipsTextLable:setPosition(cc.p(550,400))
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
function GameScene:hideGameTips()
    if self._tipsTextLable then
        self._tipsTextLable:stopAllActions()
        self._tipsTextLable:hide()
    end
end

--创建倒计时闹钟
function GameScene:createClock(index,time)
    --判断闹钟节点是否存在 存在移除
    self:removeClock()

    if time and time > 0 then
        --重新创建闹钟       
        self.m_clockNode = tableAction:new()
        self.m_clockNode:timeStart(index,time)
        self.bg:addChild(self.m_clockNode)
    end
end

--移除闹钟
function GameScene:removeClock()
    if self.m_clockNode then
       self.m_clockNode:removeFromParent()
       self.m_clockNode = nil
    end
end

--摊牌
function GameScene:onGameShowCard(data)
    dump(data)
    local uid = data.uid
    local seatid = data.seatid

    local switchId = conf.swichPos(seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
    self:wancheng(switchId)

    if self.TableInfoArray.mySitId == seatid and self.TableInfoArray.isJoin then
        self:showGameTips(conf.tipes.waitOpenCards)
    end

    if tostring(uid) == tostring(UserData.userId) then 
        self:ShowCard()
    end
    
end

--结束
function GameScene:onGameEnd(data)
    dump(data)
    local PlayerNum = data.PlayerNum
    local PlayerArray = data.PlayerArray
    PlayerArray.curGameNum = self.TableInfoArray.curGameNum

    if self.TableInfoArray.IsSit then
        self:hideGameTips()
    end

    if self.TableInfoArray.isJoin then
        self:ShowCard()
    end

    
    local inBankID = 1
    for i,v in ipairs(PlayerArray) do
        if self.TableInfoArray.bankerUser == v.playerUid then
            inBankID = v.playerSeatId+1
        end

        self.ScoreArray[v.playerSeatId+1] = v.AllGoal
    end
    self:exploitData(PlayerArray)

    self:setPlayerData(PlayerArray,inBankID)
    for i,v in ipairs(PlayerArray) do
        if self.playerInfoData[v.playerUid] then
            self.playerInfoData[v.playerUid].playerCoin = v.AllGoal

        end
    end

    dump(self.playerInfoData)
    
    local a = {}
    a[#a+1] = cc.CallFunc:create(function () self:playerTanpai() end)
    a[#a+1] = cc.DelayTime:create(#PlayerArray+1)
    a[#a+1] = cc.CallFunc:create(function () self:setBunkoEffect() end)
    a[#a+1] = cc.DelayTime:create(1)
    a[#a+1] = cc.CallFunc:create(function () self:setGoldToward() end)
    a[#a+1] = cc.DelayTime:create(0.5)
    a[#a+1] = cc.CallFunc:create(function () self:setPlayerScore() end)
    self:runAction(cc.Sequence:create(a))
end

--总结算
function GameScene:onGameAllResult(data)
    local countPlayer = data.countPlayer
    local playerArr = data.playerArr
    local resultType = data.resultType

    if resultType > 0 then
        self:gameAllResult(playerArr,countPlayer) 
    else
        local array = {}
        array[#array + 1] = cc.DelayTime:create(#self.TableInfoArray.playerArray+3)
        array[#array + 1] = cc.CallFunc:create(function() 
                self:gameAllResult(playerArr,countPlayer) 
            end)
        local seq = cc.Sequence:create(array)
        self:runAction(seq)
    end
end


--牌局总结算
function GameScene:gameAllResult(playerArr,countPlayer)
	local result = GameResult:new()
    result:initAllResult(self.TableInfoArray,playerArr,self.TableInfoArray.tableID,countPlayer,self.playerInfoData)
    self:addChild(result,121)
end

--聊天文字
function GameScene:onGameChatText(data)
    print("聊天文字",data.uid,data.strType,data.str)
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

    local index = 1
    for i,v in ipairs(self.TableInfoArray.playerArray) do
        if tostring(v.uid) == tostring(tab.uid) then
            index = v.seatid+1
        end
    end
    local swich = conf.swichPos(index-1,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
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
        if self.playerInfoData[tab.uid].Gender == ConstantsData.SexType.SEX_MAN then
            musicStr = "Man"
        else
            musicStr = "Woman"
        end
        musicStr = musicStr.."_Chat_"..data.str..".mp3"
        if self.playerInfoData[tab.uid] then
            MusicManager:getInstance():playAudioEffect(conf.Music["chat_effect"]..musicStr,false)
        end
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
function GameScene:onGameChatBrow(data)
    print("聊天表情",data.uid,data.browId)
    local tab={}
    tab.uid=data.uid
    tab.value=data.browId
    tab.type=1
    tab.info=self.playerInfoData[data.uid]
    table.insert(self.ChatListData,tab)
    local index = 1
    for i,v in ipairs(self.TableInfoArray.playerArray) do
        if tostring(v.uid) == tostring(data.uid) then
            index = v.seatid+1
        end
    end
    local swich = conf.swichPos(index-1,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
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
function GameScene:onGameProp(data)
	local srcUid=data.SrcUid
	local destUid=data.DestUid
	local propIndex=data.PropIndex
    local curScore=data.curScore

    self:updatePlayerGold(srcUid,curScore)
	local src = nil
	local dest = nil
	local srcPos = nil
	local destPos = nil
	for i,v in ipairs(self.TableInfoArray.playerArray) do
		if tostring(v.uid) == tostring(data.SrcUid) then
			src = conf.swichPos(v.seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
		end
		if tostring(v.uid) == tostring(destUid) then
			dest = conf.swichPos(v.seatid,self.TableInfoArray.mySitId,PLAYER_MAX_NUM)
		end
	end
	srcPos = conf.popPosArray[src]
	destPos = conf.popPosArray[dest]
	local node=FrameAniFactory:getInstance():getDaoJuNode(propIndex,srcPos,destPos)
    if node then
        self.bg:addChild(node,99)
    end
end

--显示摊牌之后的牌
function GameScene:showTanpai(seatId,index)
	for j=1, index do
		local cardNode = display.newNode()
		cardNode:setScale(0.6)
		self.bg:addChild(cardNode)
		local backCard = cc.Sprite:createWithSpriteFrameName("niuniu_card_0x00.png")
		backCard:setPosition(0,0)
		cardNode:addChild(backCard)
		table.insert(self.handBackCard,backCard)
		cardNode:setPosition(cc.p(conf.showCardPosArray[seatId].x+j*30,conf.showCardPosArray[seatId].y))
		table.insert(self.handCardArray,cardNode)
	end
end

--解散的行为（同意，拒绝）
function GameScene:onGameDissolutionAction(DismissArrayInfo)
    local dis=nil
    if self:getChildByTag(555) then
        dis = self:getChildByTag(555)
        dis:initAction(DismissArrayInfo,self.playerInfoData)
    else
        dis = dismiss:new()
        dis:initAction(DismissArrayInfo,self.playerInfoData)
        dis:setTag(555)
        self:addChild(dis,120)
    end
end

--解散的结果
function GameScene:onDissolutionResult(State,uid)
    if self:getChildByTag(555) then
        local dis = self:getChildByTag(555)
        dis:CloseDismissTime()
    end
    if State == 0 and self.playerInfoData[uid] then
        local player_name_str = string.getMaxLen(self.playerInfoData[uid].nickName,7)
        GameUtils.showMsg("由于["..player_name_str.."]拒绝"..",\n解散房间失败，牌局继续进行")
    end
end

function GameScene:onEnter()
	GameScene.super.onEnter(self)
	GameManager:getInstance():startEventListener(self) --  父类的监听
	GameManager:getInstance():startGameEventListener(self) -- 子类的监听
	self._gameRequest:RequestTabelInfo()
    GameUtils.startLoadingForever()
    self:_onMusicPlay(manager.MusicManager.MUSICID_NIUNIU_SRF)
end

function GameScene:onExit()
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
	-- display.removeSpriteFrames(GameResPath.."dismiss.plist",
	-- 						GameResPath.."dismiss.png")
	-- display.removeSpriteFrames(GameResPath.."exploits.plist",
	-- 						GameResPath.."exploits.png")
	-- display.removeSpriteFrames("gamecommon/chat/res/chat.plist",
 --       						"gamecommon/chat/res/chat.png")
	-- display.removeSpriteFrames(GameResPath.."action/goldniuniu_start.plist",
	-- 						GameResPath.."action/goldniuniu_start.png")
	-- display.removeSpriteFrames(GameResPath.."win/goldniu_win.plist",
	-- 						GameResPath.."win/goldniu_win.png")
 --    display.removeSpriteFrames(GameResPath.."winHead/goldniuniu_player_effect.plist",
 --                            GameResPath.."winHead/goldniuniu_player_effect.png")
	-- FrameAniFactory:getInstance():clearAllSpriteFrames()

    print("游戏退出")
    local resPathList = {config.GamePathResConfig:getGameResourcePath(config.GameIDConfig.KPQZ),
                    config.GamePathResConfig:getGameCommonResourcePath()}
    for k,v in pairs(resPathList) do
        FileSystemUtils.removePlistResource(v)
    end
    print("游戏模块资源释放完毕")
    GameData.reset()
    GameManager.destory()
    self._gameRequest = nil
end

return GameScene