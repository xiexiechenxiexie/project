-- 游戏菜单

local GameResPath  = "game/niuniu/res/GameLayout/NiuNiu/moreList/"
local GameRequest = require "game/niuniu/src/request/GameRequest"

local BTN_BACK 				= 1				-- 返回 离开房间(退出)
local BTN_DISSOLUTION		= 2				-- 申请解散桌子(换桌)
local BTN_CARDTYPE          = 3             -- 牌型
local BTN_SET               = 4             -- 设置
local BTN_CHOOSE            = 5 			
local BTN_STAND             = 6 

local MenuNode = class("MenuNode", cc.Node)

function MenuNode:ctor()
	self:enableNodeEvents()
	self._gameRequest = GameRequest:new() 
    self:CreateView()
end

function MenuNode:CreateView()
	--透明遮罩层
	local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), display.width, display.height)
    self:addChild(layer)
    local function onTouchBegan(touch, event)
    	return true
    end
    local function onTouchMove(touch, event)
    	return true
    end
    local function onTouchEnd(touch, event)
    	self:closeLayer()
    	return true
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:setSwallowTouches(false)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,layer)
    self.listener=listener

    local node=cc.Node:create()
	layer:addChild(node)

	self.node=node
end

function MenuNode:init()
	local moreList = cc.Sprite:create(GameResPath.."most_list.png")
 	self.node:addChild(moreList)
 	

 	local x = moreList:getContentSize().width/2
 	local ExitBtn = ccui.Button:create(GameResPath.."btn_quit_0.png",GameResPath.."btn_quit_1.png")
 	ExitBtn:setTag(BTN_BACK)
 	ExitBtn:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	ExitBtn:setPosition(x,x+170)
 	moreList:addChild(ExitBtn)
 	--牌型
 	local CardTypeBtn = ccui.Button:create(GameResPath.."btn_cardType_0.png",GameResPath.."btn_cardType_1.png")
 	CardTypeBtn:setTag(BTN_CARDTYPE)
 	CardTypeBtn:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	CardTypeBtn:setPosition(x,x+97.5)
 	moreList:addChild(CardTypeBtn)
 	--设置
 	local SetBtn = ccui.Button:create(GameResPath.."btn_set_0.png",GameResPath.."btn_set_1.png")
 	SetBtn:setTag(BTN_SET)
 	SetBtn:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	SetBtn:setPosition(x,x+22.5)
 	moreList:addChild(SetBtn)
 	--解散
 	local DissolutionBtn = ccui.Button:create(GameResPath.."btn_dissolve_0.png",GameResPath.."btn_dissolve_1.png")
 	DissolutionBtn:setTag(BTN_DISSOLUTION)
 	DissolutionBtn:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	DissolutionBtn:setPosition(x,x-50)
 	moreList:addChild(DissolutionBtn)
 	self.DissolutionBtn = DissolutionBtn

 	self.node:setPosition(200,915)
 	self:setCPPos(cc.p(200,915),cc.p(200,565))

end

function MenuNode:initGold()
	local listBg = cc.Sprite:create(GameResPath.."list_bg.png")
 	self.node:addChild(listBg,101)
 	local x,y = listBg:getContentSize().width/2,listBg:getContentSize().height/2

 	local quit = ccui.Button:create(GameResPath.."btn_quit_0.png",GameResPath.."btn_quit_1.png")
 	quit:setPosition(x,y+146)
 	quit:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	quit:setTag(BTN_BACK)
 	listBg:addChild(quit)
 	local choose = ccui.Button:create(GameResPath.."btn_choose_0.png",GameResPath.."btn_choose_1.png")
 	choose:setPosition(x,y+73)
 	choose:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	choose:setTag(BTN_CHOOSE)
 	listBg:addChild(choose)
 	local stand = ccui.Button:create(GameResPath.."btn_stand_0.png",GameResPath.."btn_stand_1.png")
 	stand:setPosition(x,y)
 	stand:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	stand:setTag(BTN_STAND)
 	listBg:addChild(stand)
 	local card = ccui.Button:create(GameResPath.."btn_cardType_0.png",GameResPath.."btn_cardType_1.png")
 	card:setPosition(x,y-73)
 	card:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	card:setTag(BTN_CARDTYPE)
 	listBg:addChild(card)
 	local set = ccui.Button:create(GameResPath.."btn_set_0.png",GameResPath.."btn_set_1.png")
 	set:setPosition(x,y-146)
 	set:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 	set:setTag(BTN_SET)
 	listBg:addChild(set)

 	self.node:setPosition(200,965)
 	self:setCPPos(cc.p(200,965),cc.p(200,540))
end

function MenuNode:setDissolutionBtnState(b)
	if self.DissolutionBtn then
		self.DissolutionBtn:setBright(b)
    	self.DissolutionBtn:setTouchEnabled(b)
	end
end


function MenuNode:onButtonClickedEvent(sender)
	local tag = sender:getTag()
	self:closeLayer()
	if tag == BTN_BACK then
		self._gameRequest:RequestLeaveTable()
	elseif tag == BTN_DISSOLUTION then
		self._gameRequest:RequestDissolutionTabel()
	elseif tag == BTN_CARDTYPE then
		if self:getParent().ShowCardTypeLayer then
    		self:getParent():ShowCardTypeLayer()
    	end
	elseif tag == BTN_SET then
		if self:getParent().setAct then
    		self:getParent():setAct()
    	end
    elseif tag == BTN_CHOOSE then
    	self._gameRequest:RequestChangeTable()
    elseif tag == BTN_STAND then
    	self._gameRequest:RequestPlayerStandUp()
	end
end

function MenuNode:setCPPos(hidePos,showPos)
	self.hidePos=hidePos
	self.showPos=showPos
end

--关闭界面
function MenuNode:closeLayer()
	if self.listener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
	end
	local pos=self.hidePos or cc.p(-280,375)
	local a={}
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.2, pos))
    a[#a+1] = cc.CallFunc:create(
    	function(sender)
    		if self:getParent().moreListHide then
    			self:getParent():moreListHide()
    		end
    		self:removeFromParent()
    	end)
    self.node:stopAllActions()
 	self.node:runAction(cc.Sequence:create(a))
end

--弹出界面
function MenuNode:popLayer()
	local pos1=self.hidePos or cc.p(-280,375)
	local pos2=self.showPos or cc.p(280,375)
	self.node:setPosition(pos1)
	local a={}
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.2, pos2))
	self.node:stopAllActions()
 	self.node:runAction(cc.Sequence:create(a))
end

function MenuNode:onEnter()
	self:popLayer()
end

function MenuNode:onExit()
	self._gameRequest = nil
end

return MenuNode