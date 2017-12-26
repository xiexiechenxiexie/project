--[[--
author fly
本节点是负责进度显示  水平方向  圆形
例子如下
		local overlay = cc.exports.lib.comp.ProgressToSprite.new(cc.Sprite:createWithSpriteFrameName("TP/lobbyEnter/btnHHDZ/imgHHDZOverlay.png"),cc.PROGRESS_TIMER_TYPE_RADIAL)
		local size = item:getContentSize()
		overlay:setPosition(size.width / 2,size.height / 2)
		item:addChild(overlay)
		self._scrollView:addItem(item)
		print(size.width,size.height)
		overlay:setScaleX(-1)
		overlay:setTotalTime(3)
		overlay:setPercent(100)
		overlay:setProgcessTo(0)
]]
local ProgressToSprite = class("ProgressToSprite",cc.Node)
ProgressToSprite._progressTimer = nil 
ProgressToSprite._progressTotalTime = 3 --0-100动画运行总时间
function ProgressToSprite:ctor( __sprite,__processType,__midpoint)
	assert(__sprite,"invalid __sprite")
	__processType = __processType or  cc.PROGRESS_TIMER_TYPE_BAR
	__midpoint = __midpoint or cc.p(0.5,0.5)
	self._progressTimer = cc.ProgressTimer:create(__sprite)
    self._progressTimer:setType(__processType)
    self._progressTimer:setMidpoint(__midpoint)
    self:addChild(self._progressTimer)
end

function ProgressToSprite:setPercent( __percent )
	assert(__percent >= 0,"invalid __percent")
	self._progressTimer:setPercentage(__percent)
end

function ProgressToSprite:setProgcessTo( __to ,__callback)
	local percent = self._progressTimer:getPercentage()
	if __to >= 0 then 
		local toAct = cc.ProgressTo:create((math.abs(__to - percent)) / 100 * self._progressTotalTime, __to)
		if not __callback then 
			self._progressTimer:runAction(toAct)
		else
			self._progressTimer:runAction(cc.Sequence:create(toAct,cc.CallFunc:create(function ( ... )
				print("setProgcessTo callback >>>>>>")
				__callback(self)
			end)))
		end
		
	end
end

function ProgressToSprite:getPercent()
	if self._progressTimer then return self._progressTimer:getPercentage() end
	return 0
end

function ProgressToSprite:setTotalTime( __time )
	self._progressTotalTime = __time
end

function ProgressToSprite:setProgressType(__progressType )
	assert(__progressType == cc.PROGRESS_TIMER_TYPE_BAR or __progressType == cc.PROGRESS_TIMER_TYPE_RADIAL,"invalid PROGRESS_TIMER_TYPE_RADIALType")
	self._progressTimer:setPercentage(0)
	self._progressTimer:setType(__progressType)
end

cc.exports.lib.comp.ProgressToSprite = ProgressToSprite