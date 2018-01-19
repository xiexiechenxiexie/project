-- 游戏消息和逻辑基类 用于处理一些通用的逻辑和消息 基类
-- @date 2017.07.13
-- @author tangwen

local ManagerModel = require "logic/GameManager"
local header = require "game/zjh/src/header/headerFile"
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
end

function GameManager:stopGameEventListener()
	self._view = nil
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
