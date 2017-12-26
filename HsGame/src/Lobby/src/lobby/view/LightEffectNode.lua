--[[
    名称  :   LightEffectNode  扫光特效
    作者  :   Afarways   
    描述  :   LightEffectNode  扫光特效
    时间  :   2017-09-25
--]]
local LightEffectResPath = "GameLayout/LightEffect/"

local LightEffectNode = class("LightEffectNode", cc.Node)

--[[
@__params.starPath      星星图片的路径
@__params.lightPath     扫光图片的路径
@__params.lightSpeed     扫光图片的路径
@__params.stencilSprite   扫光图片的蒙版图片的路径
@--params.delayTime     动画开始播放延时时间
@--params.starPosArray  星星动画展示的位置  
@--params.starScaleArray  星星动画展示的位置    
--]]
function LightEffectNode:ctor(__params)
    self._params = checktable(__params)
    self._params.delayTime = __params.delayTime or 0
end


--创建星星动画
function LightEffectNode:starAnimation()
	local starPath = self._params.starPath or LightEffectResPath .. "star.png"

	local starPosArray = checktable(self._params.starPosArray)
	local starScaleArray = checktable(self._params.starScaleArray)
	
    local length = #starPosArray
	local delayTime = 1.5
	
	--创建星星动画
	for i=1,length do
    	local starSprite = cc.Sprite:create(starPath)
        self:addChild(starSprite)
        starSprite:setPosition(starPosArray[i])
        starSprite:setOpacity(0)
        local scale =starScaleArray[i]
        starSprite:setScale(scale)

    	local delay = cc.DelayTime:create(delayTime*(i-1))
    	local delay1 = cc.DelayTime:create(delayTime*(length - i))
        
        local action1 = cc.FadeTo:create(0.2,255)
        local action2 = cc.FadeTo:create(1,0)
        local action3 = cc.RotateTo:create(1,180)
        local action4 = cc.RotateTo:create(1,360)


        local seq1 = cc.RepeatForever:create(cc.Sequence:create(delay,action1,action2,delay1))
        local seq2 = cc.RepeatForever:create(cc.Sequence:create(action3,action4))
        starSprite:runAction(seq1)
        starSprite:runAction(seq2)	
	end
end

--创建扫光图片动画
function LightEffectNode:lightAnimation()
    if self._params.stencilSprite == nil then
        print("扫光特效未设置 遮罩资源 请检查")
        return
    end
    local speed = self._params.lightSpeed or 40

    local lightPath = self._params.lightPath or LightEffectResPath .. "light.png"

    local width = self._params.stencilSprite:getContentSize().width

    local clipNode = cc.ClippingNode:create()
    self:addChild(clipNode)
    clipNode:setInverted(false)
    clipNode:setAlphaThreshold(0.7)
    clipNode:setStencil(self._params.stencilSprite)
    clipNode:setPosition(cc.p(0,0))

    local lightSprite = cc.Sprite:create(lightPath)
    clipNode:addChild(lightSprite)
    lightSprite:setPositionX(-width)

  
	local delay = cc.DelayTime:create(self._params.delayTime+0.5);
    local action1 = cc.MoveTo:create(width/speed,cc.p(width,0))
    local callFunc = cc.CallFunc:create(function ()
            lightSprite:setPositionX(-width)
        end)

    local seq1 = cc.RepeatForever:create(cc.Sequence:create(delay,action1,callFunc))
    lightSprite:runAction(seq1)
end

return LightEffectNode