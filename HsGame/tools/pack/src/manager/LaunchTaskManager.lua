--[[--
启动任务管理
]]

local LaunchTaskManager = class("LaunchTaskManager")
local KEY_FOR_TASK_NAME = "url_schemes_task"
local KEY_FOR_TASK_PRE_NAME = "url_schemes_"

local INVITE_TO_PRIVATE_ROOM = "privateroom"
local KEY_FOR_GAMEID = "kindid"
local KEY_FOR_ROOMID = "tableid"


local BaseTask = class("BaseTask")
function BaseTask:ctor( __param )

end
function BaseTask:excute( ... )

end


--该任务优先于断线重连
local InviteToRoomTask = class("InviteToRoomTask",BaseTask)
InviteToRoomTask.roomId = nil
InviteToRoomTask.gameId = nil
function InviteToRoomTask:ctor( __param)
	InviteToRoomTask.super.ctor(self)
	self.roomId = __param.tableId
	self.gameId = __param.gameId
end
function InviteToRoomTask:excute(  )
	cc.UserDefault:getInstance():setStringForKey(KEY_FOR_TASK_NAME,"")
	cc.UserDefault:getInstance():setIntegerForKey(KEY_FOR_TASK_PRE_NAME..KEY_FOR_GAMEID,0)
	cc.UserDefault:getInstance():setIntegerForKey(KEY_FOR_TASK_PRE_NAME ..KEY_FOR_ROOMID,0)
	InviteToRoomTask.super.excute(self)
	-- lobby.LobbyGameEnterManager:getInstance():needToEnterInviteGameRoom(self.gameId,self.roomId)
end



--[[--启动游戏任务管理器]]
function LaunchTaskManager:ctor( ... )
	-- local roomId = 522067
	-- cc.UserDefault:getInstance():setStringForKey(KEY_FOR_TASK_NAME,INVITE_TO_PRIVATE_ROOM)
	-- cc.UserDefault:getInstance():setIntegerForKey(KEY_FOR_TASK_PRE_NAME..KEY_FOR_GAMEID,config.GameIDConfig.KPQZ)
	-- cc.UserDefault:getInstance():setIntegerForKey(KEY_FOR_TASK_PRE_NAME ..KEY_FOR_ROOMID,roomId)
end

function LaunchTaskManager:findLaunchTask( ... )
	local taskName = cc.UserDefault:getInstance():getStringForKey(KEY_FOR_TASK_NAME,"")
	print("taskName",taskName)
	if taskName == INVITE_TO_PRIVATE_ROOM then
		local gameId = cc.UserDefault:getInstance():getIntegerForKey(KEY_FOR_TASK_PRE_NAME..KEY_FOR_GAMEID,0)
		local tableId = cc.UserDefault:getInstance():getIntegerForKey(KEY_FOR_TASK_PRE_NAME ..KEY_FOR_ROOMID,0)
		print("gameId",gameId,"tableId",tableId)
		return InviteToRoomTask.new({taskName = taskName,gameId= gameId,tableId = tableId})
	end
	return nil
end

function LaunchTaskManager:launch( ... )
	local task = self:findLaunchTask()
	if task then 
		print("LaunchTaskManager:launch")
		task:excute()
		return task
	end
	return nil
end

cc.exports.manager = cc.exports.manager or {}
cc.exports.manager.launchTaskManager = LaunchTaskManager.new()