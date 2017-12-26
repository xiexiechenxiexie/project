--[[
    名称  :   BaseWindow  弹窗基类
    作者  :   Xiaxb   
    描述  :   BaseWindow 	弹窗基类
    时间  :   2017-8-10
--]]
local BaseWindow =  class("BaseWindow", lib.layer.BaseLayer)
BaseWindow._root = nil
BaseWindow._isActing = false
function BaseWindow:ctor( ... )
	BaseWindow.super.ctor(self)
	self:addChild(cc.LayerColor:create(cc.c4b(10,10,10,120), display.width, display.height))
end

function BaseWindow:_onRootPanelInit( __root )
	self._root = __root
end

function BaseWindow:onEnter( ... )
	print("fly","BaseWindow:onEnter")
	self:_addTouchEvent()
	self:addEventListerns()
	if self._root then
		print("fly","self._root")
		self._root:setScale(0.1)
		self._root:setOpacity(0.2)

		local duration = 0.4

		local act = cc.Sequence:create(
			cc.Spawn:create(cc.FadeIn:create(duration),cc.Sequence:create(
				cc.ScaleTo:create(duration ,1),
				cc.CallFunc:create(function ( ... )
					self._isActing = false
				end))))
		self._isActing = true
		self._root:runAction(cc.EaseExponentialOut:create(act))
	end

end

function BaseWindow:onCloseCallback( ... )
	if self._root then
		print("fly","self._root")
		local duration = 0.15
		local size = self._root:getContentSize()
		local act = cc.Sequence:create(
			cc.ScaleTo:create(duration ,1.05),
			cc.Spawn:create(cc.FadeOut:create(duration),cc.Sequence:create(
				cc.ScaleTo:create(duration ,0.2),cc.CallFunc:create(function ( ... )
					print("start to remove ")
					self:removeFromParent()
				end))))
		self._root:runAction(act)
	end

end

function BaseWindow:onExit( ... )
	print("BaseWindow:onExit")
	self:_removeTouchEvent()
	self:removeEventListeners()
end

function BaseWindow:onTouchBegan(touch, event)
	if self._root and not self._isActing then
		local pos = touch:getLocation()
		print(pos.x,pos.y)
		local rect = self._root:getBoundingBox()
		if not (rect.x < pos.x and pos.x < rect.x + rect.width  and pos.y > rect.y and pos.y < rect.y + rect.height) then 
			self:onCloseCallback()
		end
	end
	return true
end


cc.exports.lib.layer.BaseWindow = BaseWindow