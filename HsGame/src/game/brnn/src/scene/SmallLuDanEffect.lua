-- 游戏路单变换特效

local GameResPath  = "game/brnn/res/SmallLuDanNode/"
local conf = require"game/brnn/src/scene/Conf"
local MusicManager = cc.exports.manager.MusicManager
local SmallLuDanEffect = class("SmallLuDanEffect", cc.Node)

function SmallLuDanEffect:ctor()
    self:init()
end

function SmallLuDanEffect:init()
    local particlefly = cc.ParticleSystemQuad:create(GameResPath.."quyu_effect_fly.plist")
    particlefly:setPositionType(cc.POSITION_TYPE_FREE )
    particlefly:setPosition(0,0)
    particlefly:setScale(0.2)
    self:addChild(particlefly)
    particlefly:setBlendFunc(cc.blendFunc(gl.SRC_ALPHA,gl.ONE))
    particlefly:stop()

    self.particlefly = particlefly


    local endparticle = cc.ParticleSystemQuad:create(GameResPath.."quyu_effect_bomb.plist")
    endparticle:setPositionType(cc.POSITION_TYPE_GROUPED )
    endparticle:setPosition(0,0)
    self:addChild(endparticle)
    endparticle:setScale(0.3)
    endparticle:setBlendFunc(cc.blendFunc(gl.ONE,gl.ONE))
    endparticle:stop()

    self.endparticle = endparticle

    --开始坐标
    self.StartPos = cc.p(0,0)
    --结束坐标
    self.EndPos = cc.p(0,0)
end

function SmallLuDanEffect:setActionPos(StartPos,EndPos)
	self.StartPos = StartPos
	self.EndPos =  EndPos
end

function SmallLuDanEffect:StartAction()
	self.particlefly:stopAllActions()
    self.particlefly:setPosition(self.StartPos)
    self.particlefly:start()
    self.endparticle:stop()
	self.endparticle:setPosition(self.EndPos)

    MusicManager:getInstance():playAudioEffect(conf.Music["ludan_effect"],false)

    local bezier = {
        self.StartPos,
        cc.p(self.EndPos.x,self.StartPos.y),
        self.EndPos,
    }

	local a = {}
	a[#a+1] = cc.BezierTo:create(1, bezier)
	-- a[#a+1] = cc.DelayTime:create(1)
    a[#a+1] = cc.CallFunc:create(function()
        self:BownParticle()
    end)

	self.particlefly:runAction(cc.Sequence:create(a))
end

function SmallLuDanEffect:BownParticle()
    self.endparticle:start()
    self.particlefly:stop()
    if self.callback then
        self.callback()
    end
end

function SmallLuDanEffect:setCallBack(callback)
    self.callback = callback
end

function SmallLuDanEffect:reset()
    self.endparticle:stop()
    self.particlefly:stop()
    self.particlefly:stopAllActions()
end

return SmallLuDanEffect