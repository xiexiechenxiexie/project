-- 游戏消息和逻辑基类 用于处理一些通用的逻辑和消息 基类
-- @date 2017.07.13
-- @author tangwen

local ManagerModel = require "logic/GameManager"
local header = require "game/brnn/src/header/headerFile"
local GameManager = class("GameManager", ManagerModel)

GameManager.EVENT_ACTION_ERR 	= "EVENT_ACTION_ERR"				--错误提示
GameManager.EVENT_FREE_TIME 	= "EVENT_FREE_TIME"					--空闲时间
GameManager.EVENT_BET_STRAT 	= "EVENT_BET_STRAT"					--开始下注
GameManager.EVENT_BETING 		= "EVENT_BETING"					--下注中
GameManager.EVENT_BET_END 		= "EVENT_BET_END"					--下注结束
GameManager.EVENT_SEND_CARD 	= "EVENT_SEND_CARD"					--发牌
GameManager.EVENT_SETTLEMENT 	= "EVENT_SETTLEMENT"				--结算
GameManager.EVENT_CALL_BANKER 	= "EVENT_CALL_BANKER"				--上庄
GameManager.EVENT_SEAT			= "EVENT_SEAT"						--坐下
GameManager.EVENT_PLAYER_LIST	= "EVENT_PLAYER_LIST"				--玩家列表
GameManager.EVENT_SCORE_LIST	= "EVENT_SCORE_LIST"				--玩家购买成功,更新金币

-- 初始化界面
function GameManager:ctor()
    GameManager.super.ctor(self)
    self:reset()
end

function GameManager:startGameEventListener(view)
	self._view = view
	self:addEventListener(header.S2C_EnumKeyAction.S2C_ACTION_ERR,self.EVENT_ACTION_ERR, self, self.OnGameActionErr)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_FREE_TIME,self.EVENT_FREE_TIME, self, self.OnGameFreeTime)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_BET_STRAT,self.EVENT_BET_STRAT, self, self.OnGameBetStart)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_BETING,self.EVENT_BETING, self, self.OnGameBeting)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_BET_END,self.EVENT_BET_END, self, self.OnGameBetEnd)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_SEND_CARD,self.EVENT_SEND_CARD, self, self.OnGameSendCard)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_SETTLEMENT,self.EVENT_SETTLEMENT, self, self.OnGameSettilement)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_CALL_BANKER,self.EVENT_CALL_BANKER, self, self.OnGameCallBanker)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_SEAT,self.EVENT_SEAT, self, self.OnGameSeat)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_PLAYER_LIST,self.EVENT_PLAYER_LIST, self, self.OnGamePlayerList)
	self:addEventListener(header.S2C_EnumKeyAction.S2C_SCORE_LIST,self.EVENT_SCORE_LIST, self, self.OnGameScoreList)
end

function GameManager:stopGameEventListener()
	self._view = nil
	self:removeEventListener(self.EVENT_ACTION_ERR, self)
	self:removeEventListener(self.EVENT_FREE_TIME, self)
	self:removeEventListener(self.EVENT_BET_STRAT, self)
	self:removeEventListener(self.EVENT_BETING, self)
	self:removeEventListener(self.EVENT_BET_END, self)
	self:removeEventListener(self.EVENT_SEND_CARD, self)
	self:removeEventListener(self.EVENT_SETTLEMENT, self)
	self:removeEventListener(self.EVENT_CALL_BANKER, self)
	self:removeEventListener(self.EVENT_SEAT, self)
	self:removeEventListener(self.EVENT_PLAYER_LIST, self)
	self:removeEventListener(self.EVENT_SCORE_LIST, self)
end

function GameManager:OnGameActionErr(event,data)
	if self._view then
		self._view:OnGameActionErr(data)
	end
end
function GameManager:OnGameFreeTime(event,data)
	if self._view then
		self._view:OnGameFreeTime(data)
	end
end
function GameManager:OnGameBetStart(event,data)
	if self._view then
		self._view:OnGameBetStart(data)
	end
end
function GameManager:OnGameBeting(event,data)
	if self._view then
		self._view:OnGameBeting(data)
	end
end
function GameManager:OnGameBetEnd(event,data)
	if self._view then
		self._view:OnGameBetEnd(data)
	end
end
function GameManager:OnGameSendCard(event,data)
	if self._view then
		self._view:OnGameSendCard(data)
	end
end
function GameManager:OnGameSettilement(event,data)
	if self._view then
		self._view:OnGameSettilement(data)
	end
end
function GameManager:OnGameCallBanker(event,data)
	if self._view then
		self._view:OnGameCallBanker(data)
	end
end
function GameManager:OnGameSeat(event,data)
	if self._view then
		self._view:OnGameSeat(data)
	end
end
function GameManager:OnGamePlayerList(event,data)
	if self._view then
		self._view:OnGamePlayerList(data)
	end
end
function GameManager:OnGameScoreList(event,data)
	if self._view then
		self._view:OnGameScoreList(data)
	end
end
-- 桌子的所有数据
function GameManager:onTableInfo(event,data)
	if self._view then
		self._view:onTableInfo(data)
	end
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
	if self._view then
		self._view:onGameChatTalk(data)
	end
end
-- 道具 
function GameManager:onGameProp(data)
	if self._view then
		self._view:onGameProp(data)
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

function GameManager:onDestory( ... )
    lib.EventUtils.removeAllListeners(self)
end

cc.exports.lib.singleInstance:bind(GameManager)

return GameManager
