-- 大厅桌子消息管理 PHP相关
-- @date 2017.08.02
-- @author tangwen

local LobbyTableManager = class("LobbyTableManager")
function LobbyTableManager:ctor()
    self._GameID = nil 
end

function LobbyTableManager:setGameId( __gameId )
    self._GameID = __gameId
end

--[[
@brief 私人房请求加入房间
@param __GameID            游戏ID
@param __GameTableId      输入的房间号ID
@param __GameIp            游戏IP
@param __GamePort          游戏端口号
]]

function LobbyTableManager:RequestPrivateJoinTable(__GameID, __GameIp, __GamePort, __GameTableId)
    GameData.TableID = __GameTableId
    GameData.GameID = __GameID
    GameData.GameIP = __GameIp
    GameData.GamePort =__GamePort
    GameData.IntoGameType = ConstantsData.IntoGameType.PRIVATE_JOIN_TABLE_TYPE

    logic.LobbyManager:getInstance():LoginGameServer()
end

--[[
@brief 金币场场次列表请求加入房间
@param __GameID            游戏ID
@param __GameTableId      输入的房间号ID
@param __GameIp            游戏IP
@param __GamePort          游戏端口号
]]

function LobbyTableManager:RequestGoldJoinTable(__GameID, __GameIp, __GamePort, __GameType)
    GameData.GameGradeType = __GameType
    GameData.GameID = __GameID
    GameData.GameIP = __GameIp
    GameData.GamePort =__GamePort
    GameData.IntoGameType = ConstantsData.IntoGameType.GOLD_LIST_JOIN_TYPE
    logic.LobbyManager:getInstance():LoginGameServer()
end

--[[
@brief 大厅请求快速开始
@param __GameID            游戏ID
@param __GameIp            游戏IP
@param __GamePort          游戏端口号
]]

function LobbyTableManager:RequestQuickJoinTable()
    local quickData = GameListData.findQuickGameData()
    GameData.GameID = quickData.gameId
    GameData.GameIP = quickData.serverIp
    GameData.GamePort =quickData.serverPort
    GameData.IntoGameType = ConstantsData.IntoGameType.LOBBY_QUICK_JOIN_TYPE
    logic.LobbyManager:getInstance():LoginGameServer()
end

--[[
@brief 游戏列表请求快速开始金币场
@param __GameID            游戏ID
@param __GameIp            游戏IP
@param __GamePort          游戏端口号
]]

function LobbyTableManager:RequestGoldQuickJoinTable()
    local gameId = GameListData.findSelectGameId()
    local data = GameListData.getNormalGameData(gameId)
    GameData.GameID = data.gameId
    GameData.GameIP = data.serverIp
    GameData.GamePort =data.serverPort
    GameData.IntoGameType = ConstantsData.IntoGameType.GOLD_QUICK_JOIN_TYPE
    logic.LobbyManager:getInstance():LoginGameServer()
end

lib.singleInstance:bind(LobbyTableManager)
cc.exports.logic.LobbyTableManager = LobbyTableManager
return  LobbyTableManager
