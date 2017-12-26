-- 游戏消息和逻辑基类 用于处理一些通用的逻辑和消息
-- @date 2017.07.13
-- @author tangwen

local ManagerModel = require "logic/GameManager"
local header = require "game/niuniu/src/header/headerFile"
local GameManager = class("GameManager", ManagerModel)
local conf = require"game/niuniu/src/scene/conf"

GameManager.EVENT_SETOUT = "EVENT_SETOUT"                           --准备
GameManager.EVENT_WAIT_GAMESTART = "EVENT_WAIT_GAMESTART"           --等待开始
GameManager.EVENT_PLAYER_GAMESTART = "EVENT_PLAYER_GAMESTART"		--游戏开始
GameManager.EVENT_PLAYER_GRADBANKER = "EVENT_PLAYER_GRADBANKER"		--抢庄
GameManager.EVENT_GRADBANKER_MULTIPLE = "EVENT_GRADBANKER_MULTIPLE" --庄家ID
GameManager.EVENT_PLAYER_BRTTING = "EVENT_PLAYER_BRTTING"			--下注
GameManager.EVENT_PLAYER_BRTTINGEND = "EVENT_PLAYER_BRTTINGEND"     --下注结束
GameManager.EVENT_PLAYER_SWIGN = "EVENT_PLAYER_SWIGN"				--有无牛
GameManager.EVENT_GAME_END = "EVENT_GAME_END"                       --游戏结束
GameManager.EVENT_GAME_RESULT = "EVENT_GAME_RESULT"                 --游戏总结算
GameManager.EVENT_PLAYER_LIST = "EVENT_PLAYER_LIST"                 --玩家列表
GameManager.EVENT_JIESAN_RESULT = "EVENT_JIESAN_RESULT"             --解散结算
GameManager.EVENT_GAME_ERROR = "EVENT_GAME_ERROR"                   --错误信息


-- 初始化界面
function GameManager:ctor() 
    GameManager.super.ctor(self)
    self:reset()
end

-- 桌子的所有数据
function GameManager:onTableInfo(event,data)
    print("桌子的所有数据")
    GameUtils.stopLoading()
    local TableInfoArray = {}
    local byteArray = GameUtils.createByteArray(data)
    local gameType = byteArray:readUInt()--游戏类型
    TableInfoArray.tableState = byteArray:readUInt()--桌子状态
    TableInfoArray.tableTime = byteArray:readUInt()--剩余时间
    TableInfoArray.curActionID = byteArray:readUInt()--当前玩家id
    TableInfoArray.tableID = byteArray:readUInt()--桌子id
    GameData.TableID = TableInfoArray.tableID 
    TableInfoArray.GameNum = byteArray:readUInt()--最大游戏局数
    TableInfoArray.curGameNum = byteArray:readUInt()--当前游戏局数
    TableInfoArray.strLen = byteArray:readShort()--规则长度
    TableInfoArray.rule = byteArray:readStringBytes(TableInfoArray.strLen)--规则
    TableInfoArray.landlord = byteArray:readUInt()--房主
    TableInfoArray.bankerUser = byteArray:readUInt()--庄家uid
    TableInfoArray.bankerSitId = byteArray:readUInt()--庄家sitid
    TableInfoArray.curPlayer = byteArray:readUInt()--当前玩家数量
    TableInfoArray.player={}
    TableInfoArray.playerUidData={}
    TableInfoArray.playerArray={}
    for i=1,TableInfoArray.curPlayer do
        local player = {}
        player.uid = byteArray:readUInt()--uid
        player.seatid = byteArray:readUInt()--椅子id

        local len = byteArray:readUShort()
        player.Score=tonumber(byteArray:readString(len)) --玩家金币

        player.isJoin = byteArray:readUInt()--自己是否入局
        player.goldNum = byteArray:readUInt()--玩家金币数
        player.maxGrapMul = byteArray:readUInt()--玩家最大抢庄倍数
        player.maxBrtMul = byteArray:readUInt()--玩家最大下注倍数
        player.oneScore = byteArray:readUInt()--单局得分
        player.allSocre = byteArray:readInt()--总得分
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
        TableInfoArray.playerUidData[player.uid] = player
        table.insert(TableInfoArray.player,player)
        local array = {}
        array.uid = player.uid
        array.seatid = player.seatid
        array.Score = player.Score
        array.isReady = player.isReady
        table.insert(TableInfoArray.playerArray,array)
    end

    if self._view then
        self._view:setTableInfoArrayData(TableInfoArray)
        self._view:updateTableInfo(TableInfoArray)
    end
end

--玩家列表
function GameManager:onPlayerList(event,data)
    print("玩家列表")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    local plsyerNum = byteArray:readUInt()
    local plsyerArray = {}
    for i=1,plsyerNum do
        local player ={}
        player.uid = byteArray:readUInt()
        player.seatid = byteArray:readUInt()
        local len = byteArray:readUShort()
        player.Score=tonumber(byteArray:readString(len)) --玩家金币
        player.isReady = byteArray:readUInt()
        table.insert(plsyerArray,player)
    end
    if self._view then
        self._view:onGamePlayerList(plsyerArray)
    end
end

--准备
function GameManager:onReady(event,data)
    print("准备")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    dataArray.readyUid = byteArray:readUInt()
    dataArray.readySit = byteArray:readUInt()
    if self._view then
        self._view:onGameReady(dataArray)
    end
end

-- 等待开始
function GameManager:onWaitStart(event,data)
    print("等待开始")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    dataArray.curGameNum = byteArray:readUInt()
    dataArray.freeTime = byteArray:readUInt()
    if self._view then
        self._view:onGameWaitStart(dataArray)
    end
end

--游戏开始
function GameManager:onStart(event,data)
    print("游戏开始")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    dataArray.bankTime = byteArray:readUInt()
    dataArray.playerNum = byteArray:readUInt()
    dataArray.playerArray = {}
    for i = 1,dataArray.playerNum do
        local player = {}
        player.uid = byteArray:readUInt()--uid
        player.seatid = byteArray:readUInt()--椅子id
        table.insert(dataArray.playerArray,player)
    end
    
    dataArray.cardNum = byteArray:readUInt()
    dataArray.cardDataArray={}
    for i=1,dataArray.cardNum do
        local cardValue = byteArray:readUInt()
        local value = string.format("%02X",cardValue)
        table.insert(dataArray.cardDataArray,value)
    end
    if self._view then
        self._view:onGameStart(dataArray)
    end
end

--抢庄
function GameManager:onGradBanker(event,data)
    print("抢庄")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    dataArray.uid = byteArray:readUInt()
    dataArray.seatId= byteArray:readUInt()
    dataArray.multiple = byteArray:readUInt()

    if self._view then
        self._view:onGameGradBanker(dataArray)
    end
end

--庄家ID
function GameManager:onGradBankerID(event,data)
    print("庄家ID")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    dataArray.brtTime = byteArray:readUInt()
    dataArray.bankUid = byteArray:readUInt()
    dataArray.bankSeatId = byteArray:readUInt()
    dataArray.bankNum = byteArray:readUInt()
    dataArray.bankSeatIdArray = {}
    for i=1, dataArray.bankNum do
        local Uid = byteArray:readUInt()
        local SeatId = byteArray:readUInt()
        table.insert(dataArray.bankSeatIdArray,SeatId)
    end

    if self._view then
        self._view:onGameGradBankerID(dataArray)
    end
end

--下注
function GameManager:onGradBrtting(event,data)
    print("下注")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    dataArray.uid = byteArray:readUInt()
    dataArray.seatId = byteArray:readUInt()
    dataArray.multiple = byteArray:readUInt()

    if self._view then
        self._view:onGameGradBrtting(dataArray)
    end
end

--下注结束
function GameManager:onGradBrttingEnd(event,data)
    print("下注结束")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    dataArray.baipaiTime = byteArray:readUInt()
    dataArray.playerNum = byteArray:readUInt()
    dataArray.playerArray = {}
    for i = 1,dataArray.playerNum do
        local player = {}
        player.uid = byteArray:readUInt()--uid
        player.seatid = byteArray:readUInt()--椅子id
        table.insert(dataArray.playerArray,player)
    end
    dataArray.niuType = byteArray:readUInt()
    dataArray.cardNum = byteArray:readUInt()
    dataArray.cardData = {}
    for i=1,dataArray.cardNum do
        local cardValue = byteArray:readUInt()
        local value = string.format("%02X",cardValue)
        table.insert(dataArray.cardData,value)
    end

    if self._view then
        self._view:onGameGradBrttingEnd(dataArray)
    end
end

--摊牌
function GameManager:onShowCard(event,data)
    print("摊牌")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    dataArray.uid = byteArray:readUInt()
    dataArray.seatid = byteArray:readUInt()

    if self._view then
        self._view:onGameShowCard(dataArray)
    end
end

--结束
function GameManager:onEnd(event,data)
    print("结束")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    dataArray.PlayerNum = byteArray:readUInt()
    dataArray.PlayerArray={}
    for i=1,dataArray.PlayerNum do
        local player={}
        player.playerUid = byteArray:readUInt()
        player.playerSeatId = byteArray:readUInt()
        player.playerCardType = byteArray:readUInt()
        player.playerGoal = byteArray:readInt()
        player.AllGoal = byteArray:readInt()
        player.playerCardNum = byteArray:readUInt()
        player.time = os.date("%Y-%m-%d %H:%M")
        player.CardArray={}
        for j=1,player.playerCardNum do
            local cardValue = byteArray:readUInt()
            table.insert(player.CardArray,cardValue)
        end
        table.insert(dataArray.PlayerArray,player)
    end
    if self._view then
        self._view:onGameEnd(dataArray)
    end
end

--总结算
function GameManager:onAllResult(event,data)
    print("总结算")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    dataArray.countPlayer = byteArray:readUInt()
    dataArray.playerArr = {}
    dataArray.resultType = 0
    for i=1,dataArray.countPlayer do
        local player = {}
        player.uid = byteArray:readUInt()
        player.seatid = byteArray:readUInt()
        player.bankerCount = byteArray:readUInt()
        player.vicCount = byteArray:readUInt()
        player.allSocre = byteArray:readInt()
        table.insert(dataArray.playerArr,player)
    end

    if self._view then
        self._view:onGameAllResult(dataArray)
    end
end

--解散总结算
function GameManager:onJieSanResult(event,data)
    print("解散总结算")
    local dataArray = {}
    local byteArray = GameUtils.createByteArray(data)
    dataArray.countPlayer = byteArray:readUInt()
    dataArray.playerArr = {}
    for i=1,dataArray.countPlayer do
        local player = {}
        player.uid = byteArray:readUInt()
        player.seatid = byteArray:readUInt()
        player.bankerCount = byteArray:readUInt()
        player.vicCount = byteArray:readUInt()
        player.allSocre = byteArray:readInt()
        table.insert(dataArray.playerArr,player)
    end
    dataArray.resultType = 1

    if self._view then
        self._view:onGameAllResult(dataArray)
    end
end

function GameManager:onGameError(event,data)
    print("错误消息")
    local byteArray = GameUtils.createByteArray(data)
    local ErrorCode = byteArray:readUInt()
    print("收到错误码",ErrorCode)
    
    GameUtils.showMsg(conf.ErrorCodeStr[ErrorCode])
end

-- 聊天文本
function GameManager:onGameChatText(data)
    if self._view then
        print("聊天文本")
        self._view:onGameChatText(data)
    end
end

-- 聊天表情 
function GameManager:onGameChatBrow(data)
    if self._view then
        print("聊天表情")
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
        print("道具")
        self._view:onGameProp(data)
    end
end

function GameManager:startGameEventListener(view)
	self._view = view
    self:addEventListener(header.S2C_EnumKeyAction.S2C_PLAYER_READY,self.EVENT_SETOUT, self, self.onReady)
    self:addEventListener(header.S2C_EnumKeyAction.S2C_WAIT_START,self.EVENT_WAIT_GAMESTART, self, self.onWaitStart)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_GAME_START,self.EVENT_PLAYER_GAMESTART, self, self.onStart)
    self:addEventListener(header.S2C_EnumKeyAction.S2C_GAME_MULTIPLE,self.EVENT_PLAYER_GRADBANKER, self, self.onGradBanker)
    self:addEventListener(header.S2C_EnumKeyAction.S2C_GAME_BANKER,self.EVENT_GRADBANKER_MULTIPLE, self, self.onGradBankerID)
    self:addEventListener(header.S2C_EnumKeyAction.S2C_GAME_BRTTING,self.EVENT_PLAYER_BRTTING, self, self.onGradBrtting)
    self:addEventListener(header.S2C_EnumKeyAction.S2C_GAME_BRTTINGEND,self.EVENT_PLAYER_BRTTINGEND, self, self.onGradBrttingEnd)
    self:addEventListener(header.S2C_EnumKeyAction.S2C_GAME_SHOWCARD,self.EVENT_PLAYER_SWIGN, self, self.onShowCard)
    self:addEventListener(header.S2C_EnumKeyAction.S2C_GAME_END,self.EVENT_GAME_END, self, self.onEnd)
    self:addEventListener(header.S2C_EnumKeyAction.S2C_USER_READY,self.EVENT_GAME_RESULT, self, self.onAllResult)
    self:addEventListener(header.S2C_EnumKeyAction.S2C_PLAYER_LIST,self.EVENT_PLAYER_LIST,self,self.onPlayerList)
    self:addEventListener(header.S2C_EnumKeyAction.S2C_JIESAN_RESULT,self.EVENT_JIESAN_RESULT,self,self.onJieSanResult)
    self:addEventListener(header.S2C_EnumKeyAction.S2C_GAME_ERROR,self.EVENT_GAME_ERROR,self,self.onGameError)
end

function GameManager:stopGameEventListener()
	self._view = nil

    self:removeEventListener(self.EVENT_SETOUT, self)
    self:removeEventListener(self.EVENT_WAIT_GAMESTART, self)
	self:removeEventListener(self.EVENT_PLAYER_GAMESTART, self)
    self:removeEventListener(self.EVENT_PLAYER_GRADBANKER, self)
    self:removeEventListener(self.EVENT_GRADBANKER_MULTIPLE, self)
    self:removeEventListener(self.EVENT_PLAYER_BRTTING, self)
    self:removeEventListener(self.EVENT_PLAYER_BRTTINGEND,self)
    self:removeEventListener(self.EVENT_PLAYER_SWIGN,self)
    self:removeEventListener(self.EVENT_GAME_END,self)
    self:removeEventListener(self.EVENT_GAME_RESULT,self)
    self:removeEventListener(self.EVENT_PLAYER_LIST,self)
    self:removeEventListener(self.EVENT_JIESAN_RESULT,self)
    self:removeEventListener(self.EVENT_GAME_ERROR,self)
end

function GameManager:onDestory( ... )
    lib.EventUtils.removeAllListeners(self)
end

cc.exports.lib.singleInstance:bind(GameManager)

return GameManager
