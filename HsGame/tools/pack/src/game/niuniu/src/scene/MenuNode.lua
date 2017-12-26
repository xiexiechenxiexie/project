-- 游戏菜单

local GameResPath  = "game/niuniu/res/GameLayout/NiuNiu/moreList/"
local GameRequest = require "game/niuniu/src/request/GameRequest"

local BTN_BACK 				= 1				-- 返回 离开房间(退出)
local BTN_DISSOLUTION		= 2				-- 申请解散桌子(换桌)
local BTN_CARDTYPE          = 3             -- 牌型
local BTN_SET               = 4             -- 设置
local BTN_CHOOSE            = 5 			
local BTN_STAND             = 6 

local BTN_TAG 	                = 10            -- 私人按钮标签
local GOLDBTN_TAG               = 20            -- 金币按钮标签

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

 	for i=1,4 do
 		local bgBtn = ccui.Button:create(GameResPath.."menuBtn_bg_0.png",GameResPath.."menuBtn_bg_1.png")
 		bgBtn:setPosition(x,x-86+(i-1)*89)
 		bgBtn:setTag(BTN_TAG+i)
 		bgBtn:addClickEventListener(function(sender) self:onButtonClickedEvent(sender) end)
 		moreList:addChild(bgBtn)
 		if i == 1 then
 			self.DissolutionBtn = bgBtn
 		end
 	end

 	local ExitBtn = display.newSprite(GameResPath.."btn_quit_0.png")
 	ExitBtn:setPosition(x,x+181)
 	moreList:addChild(ExitBtn)
 	--牌型
 	local CardTypeBtn = display.newSprite(GameResPath.."btn_help_0.png")
 	CardTypeBtn:setPosition(x,x+92)
 	moreList:addChild(CardTypeBtn)
 	--设置
 	local SetBtn = display.newSprite(GameResPath.."btn_set_0.png")
 	SetBtn:setPosition(x,x+3)
 	moreList:addChild(SetBtn)
 	--解散
 	local DissolutionBtn = display.newSprite(GameResPath.."btn_dissolve_0.png")
 	DissolutionBtn:setPosition(x,x-86)
 	moreList:addChild(DissolutionBtn)
 	-- self.DissolutionBtn = DissolutionBtn

 	self.node:setPosition(250,915)
 	self:setCPPos(cc.p(250,915),cc.p(250,515))

end

function MenuNode:initGold()
	local listBg = cc.Sprite:create(GameResPath.."list_bg.png")
 	self.node:addChild(listBg,101)
 	local x,y = listBg:getContentSize().width/2,listBg:getContentSize().height/2

 	for i=1,5 do
 		local bgBtn = ccui.Button:create(GameResPath.."menuBtn_bg_0.png",GameResPath.."menuBtn_bg_1.png")
 		bgBtn:setPosition(x,y-178+(i-1)*90)
 		bgBtn:setTag(GOLDBTN_TAG+i)
 		bgBtn:addClickEventListener(function(sender) self:onGoldButtonClickedEvent(sender) end)
 		listBg:addChild(bgBtn)
 	end

 	local quit = display.newSprite(GameResPath.."btn_quit_0.png")
 	quit:setPosition(x,y+178)
 	listBg:addChild(quit)
 	local choose = display.newSprite(GameResPath.."btn_choose_0.png")
 	choose:setPosition(x,y+89)
 	listBg:addChild(choose)
 	local stand = display.newSprite(GameResPath.."btn_stand_0.png")
 	stand:setPosition(x,y)
 	listBg:addChild(stand)
 	local card = display.newSprite(GameResPath.."btn_cardType_0.png")
 	card:setPosition(x,y-89)
 	listBg:addChild(card)
 	local set = display.newSprite(GameResPath.."btn_set_0.png")
 	set:setPosition(x,y-178)
 	listBg:addChild(set)

 	self.node:setPosition(250,965)
 	self:setCPPos(cc.p(250,965),cc.p(250,500))
end

function MenuNode:setDissolutionBtnState(b)
	if self.DissolutionBtn then
		self.DissolutionBtn:setBright(b)
    	self.DissolutionBtn:setTouchEnabled(b)
	end
end

function MenuNode:onGoldButtonClickedEvent( sender )
	local tag = sender:getTag()
	self:closeLayer()
	if tag == GOLDBTN_TAG+5 then
		self._gameRequest:RequestLeaveTable()
	elseif tag == GOLDBTN_TAG+4 then
		self._gameRequest:RequestChangeTable()
	elseif tag == GOLDBTN_TAG+3 then
		self._gameRequest:RequestPlayerStandUp()
	elseif tag == GOLDBTN_TAG+2 then
		if self:getParent().ShowCardTypeLayer then
    		self:getParent():ShowCardTypeLayer()
    	end
	elseif tag == GOLDBTN_TAG+1 then
		if self:getParent().setAct then
    		self:getParent():setAct()
    	end
	end
end

function MenuNode:onButtonClickedEvent(sender)
	local tag = sender:getTag()
	self:closeLayer()
	if tag == BTN_TAG+4 then
		self._gameRequest:RequestLeaveTable()
	elseif tag == BTN_TAG+3 then
		if self:getParent().ShowCardTypeLayer then
    		self:getParent():ShowCardTypeLayer()
    	end
	elseif tag == BTN_TAG+2 then
		if self:getParent().setAct then
    		self:getParent():setAct()
    	end
	elseif tag == BTN_TAG+1 then
		self._gameRequest:RequestDissolutionTabel()
	end
	-- if tag == BTN_BACK then
	-- 	self._gameRequest:RequestLeaveTable()
	-- elseif tag == BTN_DISSOLUTION then
	-- 	self._gameRequest:RequestDissolutionTabel()
	-- elseif tag == BTN_CARDTYPE then
	-- 	if self:getParent().ShowCardTypeLayer then
 --    		self:getParent():ShowCardTypeLayer()
 --    	end
	-- elseif tag == BTN_SET then
	-- 	if self:getParent().setAct then
 --    		self:getParent():setAct()
 --    	end
 --    elseif tag == BTN_CHOOSE then
 --    	self._gameRequest:RequestChangeTable()
 --    elseif tag == BTN_STAND then
 --    	self._gameRequest:RequestPlayerStandUp()
	-- end
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