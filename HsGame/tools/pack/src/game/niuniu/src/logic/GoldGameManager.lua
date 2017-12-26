-- 游戏消息和逻辑基类 用于处理一些通用的逻辑和消息
-- @date 2017.07.13
-- @author tangwen

local ManagerModel = require "logic/GameManager"
local header = require "game/niuniu/src/header/headerFile"
local GameManager = class("GameManager", ManagerModel)
local GameResult = require "game/niuniu/src/scene/GameResult"
local conf = require"game/niuniu/src/scene/conf"
local tableAction = require "game/niuniu/src/scene/tableAction"
local subsidy = require "gamecommon/subsidy/src/SubsidyLayer"

GameManager.EVENT_ACTION_ERR = "EVENT_ACTION_ERR"                   --错误提示
GameManager.EVENT_START_SET = "EVENT_START_SET"                     --开始
GameManager.EVENT_FOUR_CARD = "EVENT_FOUR_CARD"                     --四张牌
GameManager.EVENT_GRAP_BANKER = "EVENT_GRAP_BANKER"                 --抢庄时间
GameManager.EVENT_GRAP_IN = "EVENT_GRAP_IN"                         --抢庄中
GameManager.EVENT_SET_BANKER = "EVENT_SET_BANKER"                   --设置庄家
GameManager.EVENT_BET_STRAT = "EVENT_BET_STRAT"                     --下注开始 
GameManager.EVENT_BETING = "EVENT_BETING"                           --下注中 
GameManager.EVENT_SEND_FIVE_CARD = "EVENT_SEND_FIVE_CARD"           --发第五张牌
GameManager.EVENT_SHOW_START = "EVENT_SHOW_START"                   --摊牌开始
GameManager.EVENT_SHOW_CARD_ING = "EVENT_SHOW_CARD_ING"             --亮牌中
GameManager.EVENT_SHOW_CARD = "EVENT_SHOW_CARD"                     --全都摊牌
GameManager.EVENT_SETTLEMENT = "EVENT_SETTLEMENT"                   --结算分数
GameManager.EVENT_USER_LIST = "EVENT_USER_LIST"                     --用户列表

GameManager.EVENT_PLAYER_SIT = "EVENT_PLAYER_SIT"                   --坐下
GameManager.EVENT_STAND_UP = "EVENT_STAND_UP"                       --站起
-- S2C_PLAYER_SCORE
GameManager.EVENT_PLAYER_SCORE = "EVENT_PLAYER_SCORE"               --数据同步

-- 初始化界面
function GameManager:ctor() 
    GameManager.super.ctor(self)
    self:reset()
    self.playerListUID = {}
end

local TableInfoArray = {}   --玩家數組
local PlayerSelfInfo = {}   --玩家自己信息

local exploitArray = {}
local playerUidData = {}

--初始化玩家游戏状态
local userPlayStateArray = {false,false,false,false,false} 

-- 桌子的所有数据
function GameManager:onTableInfo(event,data)
    --清场
    self._view:clearCache()
    userPlayStateArray = {false,false,false,false,false}

    GameUtils.stopLoading()
    local byteArray = GameUtils.createByteArray(data)
    TableInfoArray.gameType = byteArray:readUInt()--游戏类型
    TableInfoArray.gameRoomType = byteArray:readUInt()--场次类型
    TableInfoArray.tableState = byteArray:readUInt()--桌子状态 1准备2抢庄3下注4摊牌5结算
    TableInfoArray.tableTime = byteArray:readUInt()--桌子状态 剩余时间
    TableInfoArray.curActionID = byteArray:readUInt()--当前玩家id
    TableInfoArray.tableID = byteArray:readUInt()--桌子id
    GameData.TableID = TableInfoArray.tableID 
    TableInfoArray.GameNum = byteArray:readUInt()--最大游戏局数
    TableInfoArray.curGameNum = byteArray:readUInt()--当前游戏局数
    TableInfoArray.landlord = byteArray:readUInt()--房主
    TableInfoArray.bankerUser = byteArray:readUInt()--庄家
    TableInfoArray.curPlayer = byteArray:readUInt()--当前玩家数
    TableInfoArray.player={}
    PlayerSelfInfo = {}
    self.playerListUID = {}
    for i=1,TableInfoArray.curPlayer do
        local player = {}
        player.uid = byteArray:readUInt()--uid
        player.seatid = byteArray:readUInt()--椅子id
        player.isInGame = byteArray:readUInt()--是否在游戏中
        player.goldLen = byteArray:readUShort()--玩家金币数长度
        player.goldNum = tonumber(byteArray:readString(player.goldLen))--玩家金币数
        player.maxGrapMul = byteArray:readUInt()--玩家最大抢庄倍数
        player.maxBrtMul = byteArray:readUInt()--玩家最大下注倍数
        player.oneScoreLen = byteArray:readUShort()--单局得分长度
        player.oneScore = tonumber(byteArray:readString(player.oneScoreLen))--单局得分
        player.allSocre = byteArray:readUInt()--总得分
        player.isReady = byteArray:readUInt()--是否准备
        player.isOnline = byteArray:readUInt()--是否在线
        player.isDissolution = byteArray:readUInt()--是否解散 0拒绝1同意2等待选择
        player.isGrapBanker = byteArray:readUInt()--是否抢庄
        player.multiple = byteArray:readUInt()--抢庄倍数
        player.isBrtting = byteArray:readUInt()--是否下注
        player.Brtting = byteArray:readUInt()--下注倍数
        player.isShowCard = byteArray:readUInt()--是否亮牌
        player.cardTypeMultiple = byteArray:readUInt()--牌的倍数
        player.bankerNum = byteArray:readUInt()--当庄次数
        player.cardType = byteArray:readUInt()--牌型
        player.vicCount = byteArray:readUInt()--胜利次数
        player.cardNum = byteArray:readUInt()--牌数
        player.cardDataArray = {}
        for i=1,player.cardNum do
            local cardValue = byteArray:readUInt()
            table.insert(player.cardDataArray,cardValue)
        end
        if playerUidData[player.uid] == nil then
            playerUidData[player.uid] = player
        end
        TableInfoArray.player[player.seatid+1] = player
        -- table.insert(TableInfoArray.player,player)

        --判断是否是自己
        if player.uid == UserData.userId then
            PlayerSelfInfo = player
        end

        local playerItem = {}
        playerItem.uid = player.uid
        playerItem.sit = player.seatid
        self.playerListUID[player.seatid+1] = playerItem

        --根据牌的数量去设置玩家状态
        if player.isInGame > 0 then
            userPlayStateArray[player.seatid + 1] = true
        end
    end  

    self._view:setPlayerStatus(userPlayStateArray)

    self._view:setPlayerState(TableInfoArray.tableState,PlayerSelfInfo.cardNum)

    self._view:upDataRule()
    self._view:setPlayer(self.playerListUID)
    self._view:goldConnect(TableInfoArray.tableState)
    self._view:setTableInfoArrayData(TableInfoArray)
    self._view._gameStatus = TableInfoArray.tableState
end
--玩家列表
function GameManager:onPlayerList(event,data)
    local playerListUID = {}                --玩家uid加椅子id
    local byteArray = GameUtils.createByteArray(data)
    local playerNum = byteArray:readUInt()
    for i=1,playerNum do                                    
        local player = {}
        player.uid = byteArray:readUInt()
        player.sit = byteArray:readUInt()
        playerListUID[player.sit+1] = player
    end
    self.playerListUID = playerListUID
    --自己的椅子id初始值为0
    TableInfoArray.mySitId = 0
    --自己是否坐下
    TableInfoArray.IsSit = false
    for k,v in pairs(playerListUID) do
        if tostring(v.uid) == tostring(UserData.userId) then
            TableInfoArray.mySitId = v.sit
            TableInfoArray.IsSit = true
            self._view.myid = v.sit
        end
    end

    self._view:setPlayer(playerListUID)
    self._view:refreshUserData()

    --判断此时是否满足开始游戏条件
    if self._view._gameStatus == conf.goldState.freetime and playerNum < 2 then
        self._view:removeClockNode()
    end

end
--数据同步
function GameManager:onPlayerScore(event,data)
    local byteArray = GameUtils.createByteArray(data)
    local num = byteArray:readUInt()
    local playerDataSync = {}
    for i=1,num do
        local data = {}
        data.uid = byteArray:readUInt()
        data.len = byteArray:readUShort()
        data.score = tonumber(byteArray:readString(data.len))
        table.insert(playerDataSync,data)
    end
    self._view:setPlayerDataSync(playerDataSync)
end

-- 聊天文本
function GameManager:onGameChatText(data)
    if self._view then
        self._view:onGameChatText(data)
    end
end
-- 聊天表情 
function GameManager:onGameChatBrow(data)
    if self._view then
        self._view:onGameChatBrow(data)
    end
end
-- 聊天语音 
function GameManager:onGameChatTalk(data)
 -- self._view:onGameChatTalk(data)
end
-- 道具 
function GameManager:onGameProp(data)
    if self._view then
        self._view:onGameProp(data)
    end
end

--错误提示
function GameManager:onActionErr(event,data)
    local byteArray = GameUtils.createByteArray(data) 
    local errCode = byteArray:readUInt()
    GameUtils.showMsg("当前操作超时")
end

--开始
function GameManager:onStartSet(event,data)
    local byteArray = GameUtils.createByteArray(data) 
    local freeTime = byteArray:readUInt()
    local array = {}
    array[#array+1] = cc.CallFunc:create(function() self._view:startTime(freeTime) end)
    local seq = cc.Sequence:create(array)
    self._view:runAction(seq)
end

--四张牌
function GameManager:onfourCard(event,data)
    local cardDataArray={}
    local playerDataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    local playerNum = byteArray:readUInt()
    for i = 1,playerNum do
        local player = {}
        player.uid = byteArray:readUInt()
        player.sit = byteArray:readUInt()
        playerDataArray[player.sit+1] = player
    end
    local cardNum = byteArray:readUInt()
    for i=1,cardNum do
        local cardValue = byteArray:readUInt()
        local value = string.format("%02X",cardValue)
        table.insert(cardDataArray,value)
    end

    self._view:setShowCardData(cardDataArray)
    self._view:initPlayerStatus(playerDataArray)

    local a = {}
    a[#a+1] = cc.CallFunc:create(function() self._view:startAct() end)
    a[#a+1] = cc.DelayTime:create(1)
    a[#a+1] = cc.CallFunc:create(function() self._view:StartFaPai(playerDataArray) end)
    a[#a+1] = cc.DelayTime:create(0.3)
    a[#a+1] = cc.CallFunc:create(function() self._view:setPlayerCard() end)
    local seq = cc.Sequence:create(a)
    self._view:runAction(seq)
end
--抢庄时间
function GameManager:onGrapBaker(event,data)
    local byteArray = GameUtils.createByteArray(data)
    local GrapTime = byteArray:readUInt()
    local MaxGrapTime = byteArray:readUInt()
    local a = {}
    a[#a+1] = cc.DelayTime:create(1)
    a[#a+1] = cc.CallFunc:create(function() self._view:GradbankerBtnGold(GrapTime-1,MaxGrapTime) end)
    self._view:runAction(cc.Sequence:create(a))
end
--抢庄中
function GameManager:onGrapIn(event,data)
    local byteArray = GameUtils.createByteArray(data)
    local uid = byteArray:readUInt()
    local seatid = byteArray:readUInt()
    local bet = byteArray:readUInt()
    local index=1
    for i=1,5 do
        if conf.swichPos(seatid,TableInfoArray.mySitId,5)==i then
            index=i
        end
    end
    self._view:gradMultiple(index,bet)
end
--设置庄家
function GameManager:onSetBanker(event,data)
    self._view:GradbankerHide()
    local byteArray = GameUtils.createByteArray(data) 
    local zhuangUid = byteArray:readUInt()
    local zhuangSeat = byteArray:readUInt()
    local zhuangTimes = byteArray:readUInt()
    local count = byteArray:readInt()
    local sitIdArr = {}
    for i=1, count do
        local uid = byteArray:readUInt()
        local seat = byteArray:readUInt()
        table.insert(sitIdArr,seat)
    end
    self.zhuangUid = zhuangUid

    local index = conf.swichPos(zhuangSeat,TableInfoArray.mySitId,5)

    local bankidArr = {}
    for i,v in ipairs(sitIdArr) do
        local id = conf.swichPos(v,TableInfoArray.mySitId,5)
        table.insert(bankidArr,id)
    end

    self._view:setZhuangData(bankidArr,index)
    local array = {}
    array[#array+1] = cc.CallFunc:create(function () self._view:roundZhuangAct() end)
    array[#array+1] = cc.DelayTime:create(1)
    array[#array+1] = cc.CallFunc:create(
        function () 
            self._view:setZhuang()
            self._view:setZhuangTimes(zhuangTimes) 
        end)
    self._view:runAction(cc.Sequence:create(array))
    
    if self._view._isGameing == true and self._view.isOnTable == true  then
        self._view:hideGameTips()    
    end
end
--下注开始
function GameManager:onBetStart(event,data)
    local byteArray = GameUtils.createByteArray(data) 
    local BetTime = byteArray:readUInt()
    local MaxBetTime = byteArray:readUInt()
    local a = {}
    a[#a+1] = cc.DelayTime:create(1)
    a[#a+1] = cc.CallFunc:create(function ()
        if self.zhuangUid then
            self._view:BrttingBtn(self.zhuangUid,BetTime-1,MaxBetTime)
        else
            self._view:BrttingBtn(TableInfoArray.bankerUser,BetTime-1,MaxBetTime)
        end
    end)
    self._view:runAction(cc.Sequence:create(a))

    if self._view._isGameing == true and self._view.isOnTable == true  then
        self._view:hideGameTips()    
    end
end
--下注中
function GameManager:onBetting(event,data)
    local byteArray = GameUtils.createByteArray(data) 
    local uid = byteArray:readUInt()
    local seatid = byteArray:readUInt()
    local bet = byteArray:readUInt()
    local index=1
    for i=1,5 do
        if conf.swichPos(seatid,TableInfoArray.mySitId,5)==i then
            index=i
        end
    end
    if self.zhuangUid then
        self._view:brttingMultiple(index,(bet+1)*5,self.zhuangUid)
    else
        self._view:brttingMultiple(index,(bet+1)*5,TableInfoArray.bankerUser)
    end
end
--发第五张牌
function GameManager:onSendFiveCard(event,data)
    local byteArray = GameUtils.createByteArray(data) 
    local cardNum = byteArray:readUInt()
    local cardData = 0
    local cardType = 0

    if cardNum ~= 0 then 
        cardData = byteArray:readUInt()
        cardType = byteArray:readUInt() 
    end

    local playerNum = byteArray:readUInt()
    local playerArray = {}
    for i = 1,playerNum do
        local player = {}
        player.uid = byteArray:readUInt()
        player.sitId = byteArray:readUInt()
        table.insert(playerArray,player)
    end

    self._view:setFifthCardData(string.format("%02X",cardData))
    self._view:hideBrttingBtn()
    -- self._view:sendLastCard()
    self._view:sendLastCard(playerArray)
    self._view:initLastPlayerCard()
    self._view:judgeNiu(cardType)
end
--摊牌开始
function GameManager:onShowStart(event,data)
    local byteArray = GameUtils.createByteArray(data)
    local showCardTime = byteArray:readUInt()
    self._view:taipaiTime(showCardTime-3)

    if self._view._isGameing == true and self._view.isOnTable == true  then
        self._view:hideGameTips()    
    end
end
--亮牌中
function GameManager:onShowCardIng(event,data)
    local byteArray = GameUtils.createByteArray(data) 
    local uid = byteArray:readUInt()
    local seatid = byteArray:readUInt()
    local index = conf.swichPos(seatid,TableInfoArray.mySitId,5)
    self._view:wancheng(index)

    if tostring(uid) == tostring(UserData.userId) then
        self._view:ShowCard()
    end
end
--全都摊牌
function GameManager:onShowCard(event,data)
    local byteArray = GameUtils.createByteArray(data)
    local playerNum = byteArray:readUInt()
    local playerData = {}
    for i=1,playerNum do
        local player = {}
        player.uid = byteArray:readUInt()
        player.seatid = byteArray:readUInt()
        player.niuType = byteArray:readUInt()
        player.cardNum = byteArray:readUInt()
        player.swich = conf.swichPos(player.seatid,TableInfoArray.mySitId,5)
        player.cardArr = {}
        for i=1,player.cardNum do
            local cardData = byteArray:readUInt()
            table.insert(player.cardArr,cardData)
        end
        table.insert(playerData,player)
    end
    self._view:setPlayerCardData(playerData)
    self._view:playerTanpai()

    if self._view._isGameing == true and self._view.isOnTable == true  then
        self._view:hideGameTips()    
    end
end
--结算
function GameManager:onSettlement(event,data)
    self._view:ShowCard()
    local byteArray = GameUtils.createByteArray(data)
    local SettlementTime = byteArray:readUInt()
    local playerNum = byteArray:readUInt()
    local playerArr = {}
    for i=1,playerNum do
        local player = {}
        player.uid = byteArray:readUInt()
        player.seatid = byteArray:readUInt()
        player.GoalLen = byteArray:readUShort()
        player.playerGoal = tonumber(byteArray:readString(player.GoalLen))
        playerArr[player.seatid+1] = player
    end
  
    self._view:setzhuangReusltData(playerArr)
    local a = {}
    a[#a+1] = cc.DelayTime:create(playerNum+1)
    a[#a+1] = cc.CallFunc:create(function () self._view:setBunkoEffect() end)
    a[#a+1] = cc.DelayTime:create(2)
    a[#a+1] = cc.CallFunc:create(function () self._view:setGoldToward() end)
    a[#a+1] = cc.DelayTime:create(2)
    a[#a+1] = cc.CallFunc:create(function () self._view:setPlayerScore() end)
    a[#a+1] = cc.DelayTime:create(1.5)
    a[#a+1] = cc.CallFunc:create(function () self._view:setDataHide() end)
    self._view:runAction(cc.Sequence:create(a))
end

-- 坐下
function GameManager:onPlayerSit(event,data)
    local byteArray = GameUtils.createByteArray(data)
    local SitState = byteArray:readUInt() -- 坐下状态 1 为成功 0为失败 返回错误码
    local code = byteArray:readUInt()
    if SitState == 1 and code == 0 then
        self._view:removeSpectatorsState()
    else
        if code == 1 then
            GameUtils.showMsg("座位已满")
        elseif code == 2 then
            GameUtils.showMsg("金币不足")
        elseif code == 3 then
            GameUtils.showMsg("已经在座位上了")
        end
    end
end

--站起
function GameManager:onPlayerStandUp(event,data)
    local byteArray = GameUtils.createByteArray(data)
    local UpState = byteArray:readUInt() -- 站起状态 0为正常  1 为 游戏中不能退出 2 已经站起
    local code = byteArray:readUInt()
    if UpState == 1 and code == 0 then
        self._view:clearCache()
        self._view:SetSpectatorsState()
    else
        if code == 1 then
            GameUtils.showMsg("正在游戏中，站起失败")
        elseif code == 2 then
            GameUtils.showMsg("已经站起")
        end
    end
end

--破产补助
function GameManager:onGameBankRupt(data)
    if self._view then
        self._view:onGameBankRupt(data)
    end
end

-- 破产补助领取成功
function GameManager:onGameBankSucc(data)
    if self._view then
        self._view:onGameBankSucc(data)
    end
end


function GameManager:startGameEventListener(view)
	self._view = view
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_ACTION_ERR,self.EVENT_ACTION_ERR,self,self.onActionErr)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_START_SET,self.EVENT_START_SET,self,self.onStartSet)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_FOUR_CARD,self.EVENT_FOUR_CARD,self,self.onfourCard)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_GRAP_BANKER,self.EVENT_GRAP_BANKER,self,self.onGrapBaker)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_GRAP_ING,self.EVENT_GRAP_IN,self,self.onGrapIn)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_SET_BANKER,self.EVENT_SET_BANKER,self,self.onSetBanker)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_BET_STRAT,self.EVENT_BET_STRAT,self,self.onBetStart)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_BETING,self.EVENT_BETING,self,self.onBetting)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_SEND_FIVE_CARD,self.EVENT_SEND_FIVE_CARD,self,self.onSendFiveCard)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_SHOW_START,self.EVENT_SHOW_START,self,self.onShowStart)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_SHOW_CARD_ING,self.EVENT_SHOW_CARD_ING,self,self.onShowCardIng)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_SHOW_CARD,self.EVENT_SHOW_CARD,self,self.onShowCard)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_SETTLEMENT,self.EVENT_SETTLEMENT,self,self.onSettlement)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_PLAYER_LIST,self.EVENT_USER_LIST,self,self.onPlayerList)

    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_PLAYER_SIT,self.EVENT_PLAYER_SIT,self,self.onPlayerSit)
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_STAND_UP,self.EVENT_STAND_UP,self,self.onPlayerStandUp)
    --数据同步
    self:addEventListener(header.S2C_EnumKeyActionGold.S2C_PLAYER_SCORE,self.EVENT_PLAYER_SCORE,self,self.onPlayerScore)
end

function GameManager:stopGameEventListener()
	self._view = nil

    if playerUidData then
        for k,v in pairs(playerUidData) do
            playerUidData[k] = {}
        end
    end
    self:removeEventListener(self.EVENT_ACTION_ERR,self)
    self:removeEventListener(self.EVENT_START_SET,self)
    self:removeEventListener(self.EVENT_FOUR_CARD,self)
    self:removeEventListener(self.EVENT_GRAP_BANKER,self)
    self:removeEventListener(self.EVENT_GRAP_IN,self)
    self:removeEventListener(self.EVENT_SET_BANKER,self)
    self:removeEventListener(self.EVENT_BET_STRAT,self)
    self:removeEventListener(self.EVENT_BETING,self)
    self:removeEventListener(self.EVENT_SEND_FIVE_CARD,self)
    self:removeEventListener(self.EVENT_SHOW_START,self)
    self:removeEventListener(self.EVENT_SHOW_CARD_ING,self)
    self:removeEventListener(self.EVENT_SHOW_CARD,self)
    self:removeEventListener(self.EVENT_SETTLEMENT,self)
    self:removeEventListener(self.EVENT_USER_LIST,self)

    self:removeEventListener(self.EVENT_PLAYER_SIT,self)
    self:removeEventListener(self.EVENT_STAND_UP,self)
    --数据同步
    self:removeEventListener(self.EVENT_PLAYER_SCORE,self)

end

function GameManager:onDestory( ... )
    lib.EventUtils.removeAllListeners(self)
end

--获取玩家自己的信息
function GameManager:getPlayerSelfInfo()
    return PlayerSelfInfo
end

--获取玩家自己的Uid
function GameManager:getSelfSeatId()
    if PlayerSelfInfo.seatid then
       return PlayerSelfInfo.seatid
    end

    return 65535
end

GameManager.TableInfoArray = TableInfoArray
GameManager.userPlayStateArray = userPlayStateArray

cc.exports.lib.singleInstance:bind(GameManager)

return GameManager
