-- 游戏菜单

local MenuLayer_CSB = "game/brnn/res/MenuNode.csb"
local GameResPath  = "game/brnn/res/MenuLayout/"
local conf = require"game/brnn/src/scene/Conf"
local Tag=conf.Tag

local MenuLayer = class("MenuLayer", cc.Node)

function MenuLayer:ctor()
	self:enableNodeEvents() 
    self:CreateView()
    self:init()
end

function MenuLayer:CreateView()
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

    local RootNode = cc.CSLoader:createNode(MenuLayer_CSB)
	node:addChild(RootNode)
	self.RootNode=RootNode
	self.node=node
end

function MenuLayer:init()
	--退出按钮
	local back_btn=self.RootNode:getChildByName("back_btn")
	back_btn:setTag(Tag.back)
	back_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	-- --帮助按钮
	local help_btn=self.RootNode:getChildByName("help_btn")
	help_btn:setTag(Tag.help)
	help_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
end


function MenuLayer:onButtonClickedEvent(sender)
	local tag=sender:getTag()
	if tag==Tag.back then
		self:getParent():onBackBtnEvent()
	elseif tag==Tag.help then
		self:getParent():onHelpBtnEvent()
	end
end

--关闭界面
function MenuLayer:closeLayer()
	if self.listener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
	end
	local a={}
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.1, cc.p(180,648)))
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.2, cc.p(180,840)))
    a[#a+1] = cc.CallFunc:create(
    	function(sender)
    		if self:getParent().setMenuBtn then
    			self:getParent():setMenuBtn(false)
    		end
    		
    		self:removeFromParent()
    	end)
    self.node:stopAllActions()
 	self.node:runAction(cc.Sequence:create(a))
end

--弹出界面
function MenuLayer:popLayer()
	self.node:setPosition(cc.p(180,840))
	local a={}
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.2,cc.p(180,658)))
	a[#a+1]= cc.EaseSineOut:create(cc.MoveTo:create(0.1,cc.p(180,678)))
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.1,cc.p(180,658)))
 	self.node:runAction(cc.Sequence:create(a))
end

function MenuLayer:onEnter()
	self:popLayer()
end

function MenuLayer:onExit()

end

return MenuLayer