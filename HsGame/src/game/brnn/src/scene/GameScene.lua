-- 游戏主界面

local GameModel = require "gamemodel/scene/GameModelScene"
local GameTableLayer=require "game/brnn/src/scene/GameTableLayer"
local GameManager = require "game/brnn/src/logic/GameManager"
local header = require "game/brnn/src/header/headerFile"
local conf=require "game/brnn/src/scene/Conf"
local GameUserData=require "game/brnn/src/scene/GameUserData"
local GameRequest = require "game/brnn/src/request/GameRequest"

local GameScene = class("GameScene", GameModel)

function GameScene:ctor()
    GameScene.super.ctor(self)
    self:enableNodeEvents()  -- 注册 onEnter onExit 时间 by  tangwen
    self:init()
    self._gameRequest = GameRequest:new()
end

-- 初始化
function GameScene:init()
	local TableLayer = GameTableLayer.new()
	self:addChild(TableLayer)
	self.m_TableLayer=TableLayer
end

--游戏消息处理
function GameScene:onTableInfo(data)
	GameUtils.stopLoading()
	printInfo("收到桌子信息")
	if self.m_TableLayer then
		self.m_TableLayer:resetTable()
	end
	local byteArray = GameUtils.createByteArray(data)
	local TableInfo={}
	GameData.TableID=byteArray:readUInt()

	--最大倍数
	TableInfo.MaxBeiShu = byteArray:readUInt()
	--税率
	local len = byteArray:readUShort()
	TableInfo.shuilv=tonumber(byteArray:readString(len))

	--上庄条件
	local len = byteArray:readUShort()
	TableInfo.zhuangMinScore=tonumber(byteArray:readString(len))

	--坐下条件
	local len = byteArray:readUShort()
	TableInfo.sitMinScore=tonumber(byteArray:readString(len))

	TableInfo.State = byteArray:readUInt()
	TableInfo.StateTime = byteArray:readUInt()
	--玩家列表
	TableInfo.PlayerListNum=byteArray:readUInt()
	TableInfo.PlayerListArray={}
	for i=1,TableInfo.PlayerListNum do
		local value=byteArray:readUInt()
		table.insert(TableInfo.PlayerListArray,value)
	end
	
	--座位列表
	TableInfo.SitListArray={}
	for i=1,conf.SIT_NUM do
		local value=byteArray:readUInt()
		table.insert(TableInfo.SitListArray,value)
	end

	--庄家列表
	TableInfo.zhuangListNum=byteArray:readUInt()
	TableInfo.zhuangListArray={}
	for i=1,TableInfo.zhuangListNum do
		local value=byteArray:readInt()
		table.insert(TableInfo.zhuangListArray,value)
	end
	--走势
	local LudanListNum=byteArray:readUInt()
	local ludanArray={}
	for i=1,LudanListNum do
		local tab={}
		for j=1,conf.QUYU_NUM do
			local value=byteArray:readUInt()
			table.insert(tab,value)
		end
		table.insert(ludanArray,tab)
	end

	--个人下注，总下注
	local myXiaZhuScoreArray={}
	for i=1,conf.QUYU_NUM do
		local len = byteArray:readUShort()
		local score = tonumber(byteArray:readString(len))
		table.insert(myXiaZhuScoreArray,score)
	end

	local AllXiaZhuScoreArray={}
	for i=1,conf.QUYU_NUM do
		local len = byteArray:readUShort()
		local score=tonumber(byteArray:readString(len))
		table.insert(AllXiaZhuScoreArray,score)
	end

	--同步自己的钱
	local len = byteArray:readUShort()
	TableInfo.MyMoney=tonumber(byteArray:readString(len))

	dump(TableInfo)

	--玩家金币同步
	local playerNum=byteArray:readUInt()
	local scoreArray={}
	for i=1,playerNum do
		local tab={}
		tab.UserId=byteArray:readUInt()
		local len = byteArray:readUShort()
		tab.Score=tonumber(byteArray:readString(len))
		table.insert(scoreArray,tab)
	end

	if self.m_TableLayer then
		self.m_TableLayer:PreservationUserData(scoreArray)
	end

	--设置批量获取玩家信息回调
	if self.m_TableLayer then
		GameUserData:getInstance():setRequestUserInfoCallBack(function()
			self.m_TableLayer:updataPlayerSit()
			self.m_TableLayer:updataSZlist()
		end)
	end
	
	GameUserData:getInstance():RequestUserInfoArray()
	GameUserData:getInstance():initData(TableInfo.PlayerListArray)
	GameUserData:getInstance():updataScore(scoreArray)

	if self.m_TableLayer then
		self.m_TableLayer:SetMaxBeiShu(TableInfo.MaxBeiShu)
		self.m_TableLayer:SetSuiLv(TableInfo.shuilv)
		self.m_TableLayer:SetSZMinScore(TableInfo.zhuangMinScore)
		self.m_TableLayer:SetSitMinScore(TableInfo.sitMinScore)
		self.m_TableLayer:updataPlayerList(TableInfo.PlayerListArray)
		self.m_TableLayer:setPlayerSit(TableInfo.SitListArray)
		self.m_TableLayer:setSZlist(TableInfo.zhuangListArray)
		self.m_TableLayer:setLudanListData(ludanArray)
		self.m_TableLayer:updateSmallLDNode()
		self.m_TableLayer:updateList()
		self.m_TableLayer:setMyMoney(TableInfo.MyMoney)
	end

	if TableInfo.State==header.S2C_EnumKeyAction.S2C_FREE_TIME then
		if self.m_TableLayer then
			self.m_TableLayer:setTishiScheduler("休息一下",TableInfo.StateTime,"秒")
		end
	elseif TableInfo.State==header.S2C_EnumKeyAction.S2C_BET_STRAT then
		if self.m_TableLayer then
			self.m_TableLayer:setTishiScheduler("正在下注",TableInfo.StateTime,"秒")
			self.m_TableLayer:OnGameXiaZhuScene(myXiaZhuScoreArray,AllXiaZhuScoreArray)
			self.m_TableLayer:StartXiaZhu()
		end
	elseif TableInfo.State==header.S2C_EnumKeyAction.S2C_SETTLEMENT then
		local CardData={}
		CardData.CardDataArray={}
		for i=1,conf.AllCardNum do
			local card=byteArray:readUInt()
			table.insert(CardData.CardDataArray,card)
		end
		CardData.CardTyprArray={}
		for i=1,conf.CardNodeNum do
			local cardType=byteArray:readUInt()
			table.insert(CardData.CardTyprArray,cardType)
		end

		CardData.BeiShuArray={}
		for i=1,conf.CardNodeNum do
			local BeiShu=byteArray:readUInt()
			table.insert(CardData.BeiShuArray,BeiShu)
		end
		TableInfo.CardData=CardData

		local ResultData={}
		ResultData.ludanArray=ludanArray
		ResultData.MyScore=TableInfo.MyMoney
		ResultData.zhuangWinArray={}
		for i=1,conf.QUYU_NUM do
			local len = byteArray:readUShort()
			local score=tonumber(byteArray:readString(len))
			table.insert(ResultData.zhuangWinArray,score)
		end
		ResultData.myXiaZhuScoreArray={}
		for i=1,conf.QUYU_NUM do
			local len = byteArray:readUShort()
			local score=tonumber(byteArray:readString(len))
			table.insert(ResultData.myXiaZhuScoreArray,score)
		end
		ResultData.myWinArray={}
		for i=1,conf.QUYU_NUM do
			local len = byteArray:readUShort()
			local score=tonumber(byteArray:readString(len))
			table.insert(ResultData.myWinArray,score)
		end
		ResultData.sitWinArray={}
		for i=1,conf.SIT_NUM do
			local sitTab={}
			sitTab.score={}
			sitTab.uid=byteArray:readInt()
			for j=1,conf.QUYU_NUM do
				local len = byteArray:readUShort()
				local score=tonumber(byteArray:readString(len))
				table.insert(sitTab.score,score)
			end
			table.insert(ResultData.sitWinArray,sitTab)
		end
		TableInfo.ResultData=ResultData

		if self.m_TableLayer then
			self.m_TableLayer:setTishiText("结算中，请稍后...")
			self.m_TableLayer:setCardData(TableInfo.CardData)
			self.m_TableLayer:setResultData(TableInfo.ResultData)
		end
		if TableInfo.StateTime<conf.ResultTime then
			if TableInfo.StateTime<conf.GoldActionTime then
				if self.m_TableLayer then
					self.m_TableLayer:OnGameOverFaPaiScene()
				end
			else
				if self.m_TableLayer then
					self.m_TableLayer:OnGameOverFaPaiScene()
					self.m_TableLayer:OnGameXiaZhuScene(myXiaZhuScoreArray,AllXiaZhuScoreArray)
					self.m_TableLayer:StartResultGold()
				end
			end
		else
			if self.m_TableLayer then
				self.m_TableLayer:OnGameXiaZhuScene(myXiaZhuScoreArray,AllXiaZhuScoreArray)
				self.m_TableLayer:StartFaPai()
			end
		end
	end
end
function GameScene:OnGameActionErr(data)
	local byteArray = GameUtils.createByteArray(data)
	local ErrorCode = byteArray:readUInt()
	printLog("收到错误码",conf.ErrorCodeStr[ErrorCode])
	
	GameUtils.showMsg(conf.ErrorCodeStr[ErrorCode])
end
function GameScene:OnGameFreeTime(data)
	printInfo("收到空闲时间")
	local byteArray = GameUtils.createByteArray(data)
	local xiuxiTime = byteArray:readUInt()

	if self.m_TableLayer then
		self.m_TableLayer:resetTable()
		self.m_TableLayer:setTishiScheduler("休息一下",xiuxiTime,"秒")
	end
end
function GameScene:OnGameBetStart(data)
	printInfo("收到开始下注")
	local byteArray = GameUtils.createByteArray(data)
	local xiazhuTime = byteArray:readUInt()

	if self.m_TableLayer then
		self.m_TableLayer:setTishiScheduler("正在下注",xiazhuTime,"秒")
		self.m_TableLayer:StartXiaZhu()
		self.m_TableLayer:resetXiaZhuScore()
		self.m_TableLayer:StartXiaZhuAction()
	end
end
function GameScene:OnGameBeting(data)
	local byteArray = GameUtils.createByteArray(data)
	local uid = byteArray:readUInt()
	local betIndex = byteArray:readUInt()
	local areaIndex = byteArray:readUInt()
	local sitIndex = byteArray:readInt()
	local len = byteArray:readUShort()
	local curScore = tonumber(byteArray:readString(len))

	if self.m_TableLayer then
		self.m_TableLayer:PlayerXiaZhu(sitIndex,areaIndex,betIndex,uid,curScore)
	end
end
function GameScene:OnGameBetEnd(data)
	printInfo("收到下注结束")
	if self.m_TableLayer then
		self.m_TableLayer:StopXiaZhu()
	end
end
function GameScene:OnGameSendCard(data)
	printInfo("收到开牌")
	local byteArray = GameUtils.createByteArray(data)
	local CardData={}
	CardData.CardDataArray={}
	for i=1,conf.AllCardNum do
		local card=byteArray:readUInt()
		table.insert(CardData.CardDataArray,card)
	end
	CardData.CardTyprArray={}
	for i=1,conf.CardNodeNum do
		local cardType=byteArray:readUInt()
		table.insert(CardData.CardTyprArray,cardType)
	end
	CardData.BeiShuArray={}
	for i=1,conf.CardNodeNum do
		local BeiShu=byteArray:readUInt()
		table.insert(CardData.BeiShuArray,BeiShu)
	end

	if self.m_TableLayer then
		self.m_TableLayer:setCardData(CardData)
		self.m_TableLayer:StartFaPai()
	end
end 

function GameScene:OnGameSettilement(data)
	printInfo("收到结算")
	local byteArray = GameUtils.createByteArray(data)
	local ResultData={}
	local len = byteArray:readUShort()
	ResultData.MyScore = tonumber(byteArray:readString(len))
	ResultData.ZhuangUid = byteArray:readInt()
	local len = byteArray:readUShort()
	ResultData.ZhuangScore = tonumber(byteArray:readString(len))
	local zhuangWinArray = {}
	for i=1,conf.QUYU_NUM do
		local len = byteArray:readUShort()
		local score=tonumber(byteArray:readString(len))
		table.insert(zhuangWinArray,score)
	end
	local myXiaZhuScoreArray={}
	for i=1,conf.QUYU_NUM do
		local len = byteArray:readUShort()
		local score=tonumber(byteArray:readString(len))
		table.insert(myXiaZhuScoreArray,score)
	end
	local myWinArray={}
	for i=1,conf.QUYU_NUM do
		local len = byteArray:readUShort()
		local score=tonumber(byteArray:readString(len))
		table.insert(myWinArray,score)
	end
	local sitWinArray={}
	for i=1,conf.SIT_NUM do
		local sitTab={}
		sitTab.score={}
		sitTab.uid=byteArray:readInt()
		for j=1,conf.QUYU_NUM do
			local len = byteArray:readUShort()
			local score=tonumber(byteArray:readString(len))
			table.insert(sitTab.score,score)
		end
		table.insert(sitWinArray,sitTab)
	end
	local ludanArray={}
	local ludanNum=byteArray:readUInt()
	for i=1,ludanNum do
		local tab={}
		for j=1,conf.QUYU_NUM do
			local value=byteArray:readUInt()
			table.insert(tab,value)
		end
		table.insert(ludanArray,tab)
	end
	ResultData.zhuangWinArray=zhuangWinArray
	ResultData.myXiaZhuScoreArray=myXiaZhuScoreArray
	ResultData.myWinArray=myWinArray
	ResultData.sitWinArray=sitWinArray

	--玩家金币实时更新
	local playerNum=byteArray:readUInt()
	local scoreArray={}
	for i=1,playerNum do
		local tab={}
		tab.UserId=byteArray:readUInt()
		local len = byteArray:readUShort()
		tab.Score=tonumber(byteArray:readString(len))
		table.insert(scoreArray,tab)
	end
	if self.m_TableLayer then
		self.m_TableLayer:setLudanListData(ludanArray)
		self.m_TableLayer:setResultData(ResultData)
	end
	if self.m_TableLayer then
		self.m_TableLayer:PreservationUserData(scoreArray)
	end
end

--上庄
function GameScene:OnGameCallBanker(data)
	printInfo("收到上庄")
	local byteArray = GameUtils.createByteArray(data)
	local SZUidNum=byteArray:readInt()
	local SZUidArray={}
	for i=1,SZUidNum do
		local uid=byteArray:readInt()
		table.insert(SZUidArray,uid)
	end
	if self.m_TableLayer then
		self.m_TableLayer:setSZlist(SZUidArray)
		self.m_TableLayer:updataSZlist()
	end
end

--坐下
function GameScene:OnGameSeat(data)
	printInfo("收到坐下")
	local byteArray = GameUtils.createByteArray(data)
	local SitUidArray={}
	for i=1,conf.SIT_NUM do
		local uid=byteArray:readInt()
		table.insert(SitUidArray,uid)
	end
	if self.m_TableLayer then
		self.m_TableLayer:setPlayerSit(SitUidArray)
		self.m_TableLayer:updataPlayerSit()
	end
end

--玩家列表
function GameScene:OnGamePlayerList(data)
	printInfo("收到玩家列表")
	local byteArray = GameUtils.createByteArray(data)
	local PlayerList={}
	local PlayerNum=byteArray:readUInt()
	for i=1,PlayerNum do
		local uid=byteArray:readUInt()
		table.insert(PlayerList,uid)
	end
	GameUserData:getInstance():UpdataData(PlayerList)
	if self.m_TableLayer then
		self.m_TableLayer:updataPlayerList(PlayerList)
	end
end
-- 聊天文本
function GameScene:onGameChatText(data)
	printInfo("收到聊天文本")
	if self.m_TableLayer then
		self.m_TableLayer:onGameChatText(data)
	end
end
-- 聊天表情 
function GameScene:onGameChatBrow(data)
	printInfo("收到聊天表情")
	if self.m_TableLayer then
		self.m_TableLayer:onGameChatBrow(data)
	end
end
-- 聊天语音 
function GameScene:onGameChatTalk(data)
	printInfo("收到聊天语音")
end
-- 道具 
function GameScene:onGameProp(data)
	printInfo("收到道具")
	if self.m_TableLayer then
		self.m_TableLayer:onGameProp(data)
	end
end

-- 破产补助 
function GameScene:onGameBankRupt(data)
	printInfo("破产补助")
	if self.m_TableLayer then
		self.m_TableLayer:onGameBankRupt(data)
	end
end

-- 破产补助领取成功 
function GameScene:onGameBankSucc(data)
	printInfo("破产补助领取成功")
	if self.m_TableLayer then
		self.m_TableLayer:onGameBankSucc(data)
	end
end
-- 申请返回大厅
function GameScene:backLobbyScene()
	printInfo("收到申请返回大厅")
end

--玩家购买成功,更新金币
function GameScene:OnGameScoreList(data)
	local byteArray = GameUtils.createByteArray(data)
	local uid = byteArray:readUInt()
	local len = byteArray:readUShort()
	local curScore = tonumber(byteArray:readString(len))

	if self.m_TableLayer then
		self.m_TableLayer:UpdataUserGold(uid,curScore)
	end
end

function GameScene:onEnter()
	GameScene.super.onEnter(self)
	GameManager:getInstance():startEventListener(self)     -- 父类的监听
	GameManager:getInstance():startGameEventListener(self) -- 子类的监听
	self._gameRequest:RequestTabelInfo()
	self:_onMusicPlay(manager.MusicManager.MUSICID_BRNN)
end

function GameScene:onExit()
    print("游戏退出")
    local resPathList = {config.GamePathResConfig:getGameResourcePath(config.GameIDConfig.BRNN),
                    config.GamePathResConfig:getGameCommonResourcePath()}
    for k,v in pairs(resPathList) do
        FileSystemUtils.removePlistResource(v)
    end
    print("游戏模块资源释放完毕")
    GameData.reset()
    self._gameRequest = nil
	GameManager.destory()
	GameUserData:getInstance():onDestory()
end

return GameScene