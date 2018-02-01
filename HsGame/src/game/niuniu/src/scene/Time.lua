----------------------------------
--倒计时
----------------------------------

local Time = class("Time",cc.Node)
local GameResPath  = "game/niuniu/res/GameLayout/NiuNiu/"
local scheduler = cc.Director:getInstance():getScheduler()

function Time:ctor(time)
	self:enableNodeEvents()
	self.CountTime = nil
	self:init(time)
end

function Time:init(time)
	local timeBg = display.newSprite(GameResPath.."action/time_bg.png")
	self:addChild(timeBg)
	self.timeBg = timeBg
 	local atlasFile = GameResPath.."action/time_num.png"
	local atlasNode = ccui.TextAtlas:create(tostring(time),atlasFile,33,49,"0")
	atlasNode:setPosition(timeBg:getContentSize().width/2,timeBg:getContentSize().height/2+5)
	atlasNode:setScale(0.8)
	timeBg:addChild(atlasNode)
	self.atlasNode = atlasNode
	self.CountTime = scheduler:scheduleScriptFunc(handler(self, self.upDateTime), 1, false)

	local timePre = display.newSprite(GameResPath.."action/time.png")
	local timeProgress = cc.ProgressTimer:create(timePre)
	timeProgress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL) --设置为圆形 type:cc.PROGRESS_TIMER_TYPE_BAR条形 
    timeProgress:setPercentage(100) -- 设置初始进度为100
    timeProgress:setPosition(timeBg:getContentSize().width/2,timeBg:getContentSize().height/2)
    timeBg:addChild(timeProgress)
    --让进度条一直从0--100重复的act  
    local progressTo = cc.ProgressTo:create(time,0)
    local clear = cc.CallFunc:create(function ()
        timeProgress:setPercentage(100)
    end)  
    local seq = cc.Sequence:create(progressTo,clear)  
    timeProgress:runAction(cc.RepeatForever:create(seq))
    self.time = time
    -- return timeBg
end
function Time:upDateTime()
	self.time = self.time-1
	self.atlasNode:setString(tostring(self.time))
	if self.time == 0 and self.CountTime then
		scheduler:unscheduleScriptEntry(self.CountTime)
		self.timeBg:setVisible(false)

	end
end

function Time:onEnter()
end
function Time:onExit()
	scheduler:unscheduleScriptEntry(self.CountTime)
end

return Time