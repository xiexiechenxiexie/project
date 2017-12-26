local ViewManager = class("ViewManager")
ViewManager._listViewCache = {}
ViewManager._viewCount = 0 --計算層級的數量  為0 的時候是首頁 或者 scene初始化界面
ViewManager._isLobbyScene = false
function ViewManager:ctor( ... )
	 self._listViewCache = {}
	 self._isLobbyScene = false
end

function ViewManager:isLobbyScene( ... )
	return self._isLobbyScene
end

function ViewManager:enterLobbyScene( ... )
	self._isLobbyScene = true
end

function ViewManager:exitLobbyScene( ... )
	print("ViewManager:exitLobbyScene")
	self._isLobbyScene = false
end

function ViewManager:pushView(__viewClazz )
	local view = __viewClazz.create()
	local scene = cc.Director:getInstance():getRunningScene()
	scene:addChild(view)
	return view
end

function ViewManager:replaceView( ... )

end

function ViewManager:popView( ... )

end

function ViewManager:addViewToScene( ... )

end

function ViewManager:addViewCount( ... )
	if not self._isLobbyScene  then return end
	self._viewCount = self._viewCount + 1
	print("ViewManager:addViewCount",self._viewCount)
end

function ViewManager:minusViewCount( ... )
	if not self._isLobbyScene  then return end
	if self._viewCount > 0 then
		self._viewCount = self._viewCount - 1
	end
	
	if self._isLobbyScene  and self._viewCount <= 0  then
		print("弹出框")
			local event = cc.EventCustom:new(config.EventConfig.EVENT_LOGIN_TIP_SHOW)
			lib.EventUtils.dispatch(event)
	end
	print("ViewManager:minusViewCount",self._viewCount)
end

function ViewManager:addEvents( ... )
	local listeners = {
		-- lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_SOUND_PLAY,handler(self,self.playSound)),
		-- lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_MUISIC_PLAY,handler(self,self.playMusic)),
		-- lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_MUISIC_STOP,handler(self,self.stopMusic)),
	}
	lib.EventUtils.registeAllListeners(self,listeners)
end

function ViewManager:removeEventsAll( ... )
	lib.EventUtils.removeAllListeners(self)
end

function ViewManager:onDestory( ... )
	self:removeEventsAll()
end

function ViewManager:findLobbyComeOutEffectTime( ... )
	return 0.6
end

cc.exports.lib.singleInstance:bind(ViewManager)
cc.exports.manager.ViewManager = ViewManager
ViewManager:getInstance()
return ViewManager