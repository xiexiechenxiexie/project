-- 游戏数据初始化
-- @author Tangwen
-- @date 2017.7.20


local initData = {}

require "data/UserData"
require "data/GameData"
require "data/GameListData"
require "data/ConstantsData"
require "data/GameStateData"
require "data/LobbyData"
require "data/ServerData"
require "data/ResPathData"


function initData:init()
	UserData.reset()  -- 用户数据初始化
    GameData.reset()
    GameListData.reset()
    GameStateData.reset()
    LobbyData.reset()
    ServerData.reset()
    ResPathData.reset()
end

return initData