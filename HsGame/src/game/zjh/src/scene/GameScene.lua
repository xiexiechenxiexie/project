-- 游戏逻辑层

local GameModel = require "gamemodel/scene/GameModelScene"
local GameTableLayer=require "game/zjh/src/scene/GameTableLayer"
local GameManager = require "game/zjh/src/logic/GameManager"
local header = require "game/zjh/src/header/headerFile"
local conf=require "game/zjh/src/scene/Conf"
local GameRequest = require "game/zjh/src/request/GameRequest"

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

end


function GameScene:onEnter()
	-- GameScene.super.onEnter(self)
	-- GameManager:getInstance():startEventListener(self)     -- 父类的监听
	-- GameManager:getInstance():startGameEventListener(self) -- 子类的监听
	-- self._gameRequest:RequestTabelInfo()
	-- self:_onMusicPlay(manager.MusicManager.MUSICID_BRNN)
end

function GameScene:onExit()
 --    print("游戏退出")
 --    local resPathList = {config.GamePathResConfig:getGameResourcePath(config.GameIDConfig.BRNN),
 --                    config.GamePathResConfig:getGameCommonResourcePath()}
 --    for k,v in pairs(resPathList) do
 --        FileSystemUtils.removePlistResource(v)
 --    end
 --    print("游戏模块资源释放完毕")
 --    GameData.reset()
 --    self._gameRequest = nil
	-- GameManager.destory()
	-- GameUserData:getInstance():onDestory()
end

return GameScene