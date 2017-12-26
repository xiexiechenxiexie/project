-- loading界面
-- @date 2017.07.31
-- @author tangwen

local LoadingUI = class("LoadingUI", function()
	return display.newNode()
end)

local LOADING_SPRITE_NUM = 4
local COLOUR_BG_LENGTH = 99
local STENCIL_LENGTH = 33

function LoadingUI:ctor()

    local colourbg = ccui.ImageView:create("common_loading_colour_bg.png",ccui.TextureResType.plistType)
    colourbg:setAnchorPoint(cc.p(0.5, 0.5))
    colourbg:setPosition(0,0)
    self:enableNodeEvents()

    local stencilPathList = {}
    local posList = {}
    local tagList = {}
    for i=1,LOADING_SPRITE_NUM do
    	local pos = cc.p(STENCIL_LENGTH-(i-1)*STENCIL_LENGTH,0)
    	table.insert(posList,pos)
    	table.insert(tagList,i)
    	local loadingStr = string.format("common_loading%d.png",i)
    	table.insert(stencilPathList,loadingStr)
    end

    local clipNode = GameUtils.exchangeImageToClipNode(self, colourbg , posList, stencilPathList, tagList,ccui.TextureResType.plistType, 1)
    local loadSprite = clipNode:getStencil()
    self._ClipNode  = clipNode
    self._loadSprite = loadSprite
    self._loadSpriteChild1 = self._loadSprite:getChildByTag(1)
    self._loadSpriteChild2 = self._loadSprite:getChildByTag(2)
    self._loadSpriteChild3 = self._loadSprite:getChildByTag(3)
    self._loadSpriteChild4 = self._loadSprite:getChildByTag(4)
end

function LoadingUI:play()
 	self:playAnimeSpriteOne()
 	self:playAnimeSpriteTwo()
 	self:playAnimeSpriteThree()
 	self:playAnimeSpriteFour()
end

function LoadingUI:playAnimeSpriteOne()
    if not self._loadSpriteChild1 then return end
	local mb1 = cc.MoveBy:create(0.6, cc.p(STENCIL_LENGTH,0))
	local st1 = cc.ScaleTo:create(0.6,1,1)
	local st2 = cc.ScaleTo:create(0.6,0.75,0.75)
	local st3 = cc.ScaleTo:create(0.6,0.5,0.5)
	local ft1 = cc.FadeTo:create(0.6,100)
	local ft2 = cc.FadeTo:create(0.6,175)  
	local ft3 = cc.FadeTo:create(0.6,255) 	
	local callFunc1 = cc.CallFunc:create(function()
    	local posX = self._loadSpriteChild1:getPositionX()
    	self._loadSpriteChild1:setPositionX(posX - (COLOUR_BG_LENGTH+STENCIL_LENGTH))
    end)
    local seq1 = cc.Sequence:create(cc.Spawn:create(mb1,st3,ft1), callFunc1, cc.Spawn:create(mb1,st2,ft2), cc.Spawn:create(mb1,st1,ft3), cc.Spawn:create(mb1,st2,ft2))
    local RepeaAction1 = cc.RepeatForever:create(seq1)
    self._loadSpriteChild1:stopAllActions()
    self._loadSpriteChild1:runAction(RepeaAction1)
end

function LoadingUI:playAnimeSpriteTwo()
    if not self._loadSpriteChild2 then return end
	local mb2 = cc.MoveBy:create(0.6, cc.p(STENCIL_LENGTH,0))
	local st1 = cc.ScaleTo:create(0.6,1,1)
	local st2 = cc.ScaleTo:create(0.6,0.75,0.75)
	local st3 = cc.ScaleTo:create(0.6,0.5,0.5)
	local ft1 = cc.FadeTo:create(0.6,100)
	local ft2 = cc.FadeTo:create(0.6,175)  
	local ft3 = cc.FadeTo:create(0.6,255) 	
    local callFunc2 = cc.CallFunc:create(function()
    	local posX = self._loadSpriteChild2:getPositionX()
    	self._loadSpriteChild2:setPosition(posX - (COLOUR_BG_LENGTH+STENCIL_LENGTH),0)
    end)
    local seq2 = cc.Sequence:create(cc.Spawn:create(mb2,st2,ft2), cc.Spawn:create(mb2,st3,ft1), callFunc2, cc.Spawn:create(mb2,st2,ft2),cc.Spawn:create(mb2,st1,ft3))
    local RepeaAction2 = cc.RepeatForever:create(seq2)
    self._loadSpriteChild2:stopAllActions()
    self._loadSpriteChild2:runAction(RepeaAction2)
end


function LoadingUI:playAnimeSpriteThree()
    if not self._loadSpriteChild3 then return end
	local mb3 = cc.MoveBy:create(0.6, cc.p(STENCIL_LENGTH,0))
	local st1 = cc.ScaleTo:create(0.6,1,1)
	local st2 = cc.ScaleTo:create(0.6,0.75,0.75)
	local st3 = cc.ScaleTo:create(0.6,0.5,0.5)
	local ft1 = cc.FadeTo:create(0.6,100)
	local ft2 = cc.FadeTo:create(0.6,175)  
	local ft3 = cc.FadeTo:create(0.6,255) 	
    local callFunc3 = cc.CallFunc:create(function()
    	local posX = self._loadSpriteChild3:getPositionX()
    	self._loadSpriteChild3:setPosition(posX - (COLOUR_BG_LENGTH+STENCIL_LENGTH),0)
    end)
    local seq3 = cc.Sequence:create(cc.Spawn:create(mb3,st1,ft3), cc.Spawn:create(mb3,st2,ft2), cc.Spawn:create(mb3,st3,ft1), callFunc3, cc.Spawn:create(mb3,st2,ft2))
    local RepeaAction3 = cc.RepeatForever:create(seq3)
    self._loadSpriteChild3:stopAllActions()
    self._loadSpriteChild3:runAction(RepeaAction3)
end


function LoadingUI:playAnimeSpriteFour()
    if not self._loadSpriteChild4 then return end
	local mb4 = cc.MoveBy:create(0.6, cc.p(STENCIL_LENGTH,0))
	local st1 = cc.ScaleTo:create(0.6,1,1)
	local st2 = cc.ScaleTo:create(0.6,0.75,0.75)
	local st3 = cc.ScaleTo:create(0.6,0.5,0.5)
	local ft1 = cc.FadeTo:create(0.6,100)
	local ft2 = cc.FadeTo:create(0.6,175)  
	local ft3 = cc.FadeTo:create(0.6,255) 	
    local callFunc4 = cc.CallFunc:create(function()
    	local posX = self._loadSpriteChild4:getPositionX()
    	self._loadSpriteChild4:setPosition(posX - (COLOUR_BG_LENGTH+STENCIL_LENGTH),0)
    end)
    local seq4 = cc.Sequence:create(cc.Spawn:create(mb4,st2,ft2), cc.Spawn:create(mb4,st1,ft3), cc.Spawn:create(mb4,st2,ft2), cc.Spawn:create(mb4,st3,ft1), callFunc4)
    local RepeaAction4 = cc.RepeatForever:create(seq4)
    self._loadSpriteChild4:stopAllActions()
    self._loadSpriteChild4:runAction(RepeaAction4)
end


function LoadingUI:stop()
    if self._loadSpriteChild1 then
        self._loadSpriteChild1:stopAllActions()
    end
    if self._loadSpriteChild2 then
        self._loadSpriteChild2:stopAllActions()
    end
    if self._loadSpriteChild3 then
        self._loadSpriteChild3:stopAllActions()
    end
    if self._loadSpriteChild4 then
        self._loadSpriteChild4:stopAllActions()
    end
	-- self:stopAllActions()
end

function LoadingUI:onExit( ... )
    self._loadSpriteChild1 = nil
    self._loadSpriteChild2 = nil
    self._loadSpriteChild3 = nil
    self._loadSpriteChild4 = nil
end

return LoadingUI
