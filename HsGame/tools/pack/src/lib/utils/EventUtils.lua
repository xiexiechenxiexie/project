--[[--
@author fly  使用数据

注册
	local listeners = {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_SOUND_PLAY,handler(self,self.playSound)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_MUISIC_PLAY,handler(self,self.playMusic)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_MUISIC_STOP,handler(self,self.stopMusic)),
	}
	lib.EventUtils.registeAllListeners(self,listeners)

发送
			local event = cc.EventCustom:new(config.EventConfig.EVENT_SOUND_PLAY)
			event.userdata --事件数据
			lib.EventUtils.dispatch(event)
移除
lib.EventUtils.removeAllListeners(self)   --该对象全部事件
lib.EventUtils.registeAllListeners(self,listeners)  --该对象部分事件
]]

local EventUtils = {}

EventUtils.registeListenerCache = {}

local self = EventUtils

EventUtils.createEventCustomListener = function (__listenerId,__callback)
	 local listener = cc.EventListenerCustom:create(__listenerId, __callback)
	 listener._listenerId = __listenerId
	 return listener
end

EventUtils.registeListener = function (__obj,__listener )
	assert(__obj and __listener,"invalid obj or listener please check")
	if not self.registeListenerCache[__obj] then
		self.registeListenerCache[__obj] = {}
	end

	local dispatcher = self:findEventDispatcher()
	dispatcher:addEventListenerWithFixedPriority(__listener, -1)

	local listenerId  =  __listener._listenerId
	print("listenerId",listenerId,self.registeListenerCache[__obj])
	self.registeListenerCache[__obj][listenerId] = __listener
end

EventUtils.registeAllListeners = function ( __obj,__listeners )
	assert(__obj and __listeners,"invalid obj or __listeners please check")
	for __,listener in ipairs(__listeners) do
		self.registeListener(__obj,listener)
	end
end

EventUtils.removeAllListeners = function ( __obj )
	assert(__obj,"invalid __obj")

	local listenersDict = self.registeListenerCache[__obj]
	if listenersDict then
		for _,listener in pairs(listenersDict) do
			local dispatcher = self:findEventDispatcher()
			dispatcher:removeEventListener(listener)
			print("removeAllListeners __obj",__obj)
		end
		self.registeListenerCache[__obj] = nil
	end
end

EventUtils.removeListenerByListenerId = function ( __obj,__listenerId )
    local listener = self.registeListenerCache[__obj][__listenerId]
    self:findEventDispatcher():removeEventListener(listener)
	self.registeListenerCache[__obj][__listenerId] = nil
end

EventUtils.dispatch = function ( __event )
	self:findEventDispatcher():dispatchEvent(__event)
end

EventUtils.findEventDispatcher = function ( ... )
	return cc.Director:getInstance():getEventDispatcher()
end

cc.exports.lib.EventUtils = EventUtils