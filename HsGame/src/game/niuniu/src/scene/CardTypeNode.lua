-- 游戏菜单

local GameResPath  = "game/niuniu/res/GameLayout/NiuNiu/"

local CardTypeNode = class("CardTypeNode", cc.Node)

function CardTypeNode:ctor()
	self:enableNodeEvents() 
    self:CreateView()
end

function CardTypeNode:CreateView()
	--透明遮罩层
	local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), display.width, display.height)
    self:addChild(layer)
    local function onTouchBegan(touch, event)
    	self:closeLayer()
    	return true
    end
    local function onTouchMove(touch, event)
    	return true
    end
    local function onTouchEnd(touch, event)
    	return true
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:setSwallowTouches(true)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,layer)
    self.listener=listener

    local node=cc.Node:create()
	layer:addChild(node)

	local sp = cc.Sprite:create(GameResPath.."goldNiu_cardType.png")
 	node:addChild(sp)


 	node:setPosition(-160,375)
 	self:setCPPos(cc.p(-160,375),cc.p(160,375))

 	self.node = node
end

function CardTypeNode:setCPPos(hidePos,showPos)
	self.hidePos=hidePos
	self.showPos=showPos
end

--关闭界面
function CardTypeNode:closeLayer()
	if self.listener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
	end
	local pos=self.hidePos or cc.p(-280,375)
	local a={}
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.2, pos))
    a[#a+1] = cc.CallFunc:create(
    	function(sender)
    		self:removeFromParent()
    	end)
    self.node:stopAllActions()
 	self.node:runAction(cc.Sequence:create(a))
end

--弹出界面
function CardTypeNode:popLayer()
	local pos1=self.hidePos or cc.p(-280,375)
	local pos2=self.showPos or cc.p(280,375)
	self.node:setPosition(pos1)
	local a={}
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.2, pos2))
	self.node:stopAllActions()
 	self.node:runAction(cc.Sequence:create(a))
end

function CardTypeNode:onEnter()
	self:popLayer()
end

function CardTypeNode:onExit()

end

return CardTypeNode