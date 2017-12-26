-- 心跳管理器
-- @date 2017.07.13
-- @author tangwen
-- @ 游戏消息分发。

local HeadJumpManager = class("HeadJumpManager")

function HeadJumpManager:ctor()
	self._headJumpMsgNum = 0  -- 心跳的信息
	self._reConnectNum = 0 -- 重连的次数
end

function HeadJumpManager:initHeadJumpState( __event )
	self._headJumpMsgNum  = 0
	--print("initHeadJumpState")
end

function HeadJumpManager:updateHeadJumpState( __event )
	self._headJumpMsgNum  = self._headJumpMsgNum + 1
	if self._headJumpMsgNum >= 4 then
		print("3次心跳没收到 重新连接socket")
		self:updataReConnectState()
	end

end

function HeadJumpManager:initReConnectState( __event )
	self._reConnectNum = 0
end

-- 更新重连状态
function HeadJumpManager:updataReConnectState( __event )
	net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
		self._reConnectNum  = self._reConnectNum + 1
		if self._reConnectNum == 1 then
			local event = cc.EventCustom:new(config.EventConfig.EVENT_RECONNECT_SOCKET)
			lib.EventUtils.dispatch(event)
		elseif self._reConnectNum >= 2 and self._reConnectNum <= 3 then
			GameUtils.stopLoading()
			net.SocketClient:getInstance():stopHeartbeat()  --弹提示 关闭心跳
			local function callback(event)
				if "ok" == event then
					GameUtils.hideMsgBox()
					local event = cc.EventCustom:new(config.EventConfig.EVENT_RECONNECT_SOCKET)
					lib.EventUtils.dispatch(event)
				elseif "cancel" == event then
					GameUtils.hideMsgBox()
					print("网络状态不稳定,退出登陆大厅")
	  				LoginManager:enterLogin()
				end
			end
			local parm = {type = ConstantsData.ShowMgsBoxType.NORMAL_TYPE, msg = "您当前网络状态不稳定，是否继续重连？", btn = {"ok","cancel"}, callback = callback}
			GameUtils.showMsgBox(parm)
		elseif  self._reConnectNum > 3 then
			self._reConnectNum = 0
		  	GameUtils.stopLoading()
			net.SocketClient:getInstance():stopHeartbeat()  --弹提示 关闭心跳
			local function callback(event)
				if "ok" == event then
					GameUtils.hideMsgBox()
					LoginManager:enterLogin()
				end
			end
			local parm = {type = ConstantsData.ShowMgsBoxType.NORMAL_TYPE, msg = "网络不稳定，重新登陆游戏。", btn = {"ok"}, callback = callback}
			GameUtils.showMsgBox(parm)
		end

	end)

end


function HeadJumpManager:addEvents( ... )
	print("HeadJumpManager:加入监听")
	local listeners = {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_SEND_HEAD_JUMP,handler(self,self.updateHeadJumpState)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_RECEIVE_HEAD_JUMP,handler(self,self.initHeadJumpState)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_INIT_RECONNECT_STATE,handler(self,self.initReConnectState)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_UPDATA_RECONNECT_FAIL_STATE,handler(self,self.updataReConnectState)),
	}
	lib.EventUtils.registeAllListeners(self,listeners)
end
function HeadJumpManager:onDestory( ... )
	lib.EventUtils.removeAllListeners(self)
end


lib.singleInstance:bind(HeadJumpManager)
cc.exports.logic.HeadJumpManager = HeadJumpManager
return HeadJumpManager

