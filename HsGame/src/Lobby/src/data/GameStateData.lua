-- 状态数据
-- @date 2017.08.19
-- @author tangwen

local GameStateData = GameStateData or {}

function GameStateData.reset()
	GameStateData.NoticeEventState      = 1       -- 进入大厅时, 控制活动公告弹出
	GameStateData.SignState 			= 1       -- 进入大厅时, 控制签到弹出
end

cc.exports.GameStateData = GameStateData