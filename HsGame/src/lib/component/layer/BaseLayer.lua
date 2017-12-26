--[[--
author:fly 封装layer通用 节点事件 触摸事件
]]

local BaseLayer =  class("BaseLayer",cc.Layer)

BaseLayer._listener = nil

function BaseLayer:ctor( ... )
	print("BaseLayer:ctor",...)
	self:_initNodeEvent()

end

--[[--
私有方法不可重写，初始化 node 事件
]]
function BaseLayer:_initNodeEvent( ... )
    local function onNodeEvent(event)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

--[[--
触摸事件初始化添加 不可重写  
__isSwallowed 默认为true
]]
function BaseLayer:_addTouchEvent( __isSwallowed )
	if __isSwallowed == nil or type(__isSwallowed) ~=  "boolean" then  __isSwallowed = true end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(handler(self,self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(handler(self,self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(handler(self,self.onTouchCancelled), cc.Handler.EVENT_TOUCH_CANCELLED)
	listener:registerScriptHandler(handler(self,self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
	self._listener = listener
	self._listener:setSwallowTouches(__isSwallowed)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)
end

function BaseLayer:_removeTouchEvent( ... )
	cc.Director:getInstance():getEventDispatcher():removeEventListener(self._listener)
end

function BaseLayer:onEnter( ... )
	self:_addTouchEvent()
	self:addEventListerns()
	self:_onRequest()
	manager.ViewManager:getInstance():addViewCount()	
end

function BaseLayer:onExit( ... )
	print("BaseLayer:onExit")
	self:_removeTouchEvent()
	self:removeEventListeners()
	manager.ViewManager:getInstance():minusViewCount()
end

function BaseLayer:_onRequest( ... )

end

function BaseLayer:onListersInitCallback( ... )
	return nil
end

function BaseLayer:addEventListerns()
	local listeners = self:onListersInitCallback()
	if listeners then
		lib.EventUtils.registeAllListeners(self,listeners)
	end
end

function BaseLayer:removeEventListeners( ... )
	lib.EventUtils.removeAllListeners(self)
end

function BaseLayer:setSwallowTouch( __swallowed )
	if self._listener then self._listener:setSwallowTouches(__swallowed) end
end

function BaseLayer:onTouchBegan(touch, event)
	print("BaseLayer:onTouchBegan")
	return true
end

function BaseLayer:onTouchMoved(touch, event)
	print("BaseLayer:onTouchMoved")
end

function BaseLayer:onTouchCancelled(touch, event)
	print("BaseLayer:onTouchCancelled")
end

function BaseLayer:onTouchEnded(touch, event)
	print("BaseLayer:onTouchEnded")
end

function BaseLayer:back( ... )
	self:removeFromParent()
end

cc.exports.lib.layer.BaseLayer = BaseLayer