-- 游戏聊天
local ChatLayer_CSB = "gamecommon/chat/res/ChatNode.csb"
local GameRequest = require "request/GameRequest"
local Avatar=cc.exports.lib.node.Avatar
local ChatLayer = class("ChatLayer", cc.Node)

local BROW_NUM=30 		--表情总数量
local BROW_LINE_NUM=4 	--一行表情数量
local BROW_ROW_NUM=8 	--一列表情数量
local TEXT_TAG=10
local BROW_TAG=30
local CHAT_TEXT={
	"快点吧，我等的花儿都谢了！",
	"投降输一半，速度投降吧！",
	"你的牌打的太好了！",
	"吐了个槽的整个一个悲剧啊！",
	"天灵灵，地灵灵，给手好牌行不行！",
	"大清早的鸡还没叫呢，慌什么嘛！",
	"不要走，决战到天亮！",
	"大家好，很高兴见到各位！",
	"出来混迟早要还的！",
	"再见啦，我会想念大家的！",
}

local CHAT_SIZE=cc.size(430,530)
function ChatLayer:ctor()
	self:enableNodeEvents()
    self:CreateView()
    self:init()
    self._gameRequest = GameRequest:new()
end

function ChatLayer:CreateView()
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
    listener:setSwallowTouches(true)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,layer)
    self.listener=listener

	local node=cc.Node:create()
	layer:addChild(node)

	self.node=node
end

function ChatLayer:init()
	local bg = cc.Sprite:createWithSpriteFrameName("chat_bg1.png")
	self.node:addChild(bg)
	local bg2 = cc.Scale9Sprite:createWithSpriteFrameName("chat_bg2.png")
	bg2:setPosition(0,59)
	bg2:setOpacity(140)
	bg2:setContentSize(cc.size(530,550))
	self.node:addChild(bg2)

	--短语按钮
	local BtnArray={}
	local duanyuBtn = ccui.CheckBox:create("chat_btn_chat_.png",
											"chat_btn_chat_1.png",
											"chat_btn_chat_1.png",
											"chat_btn_chat_.png",
											"chat_btn_chat_.png",
											ccui.TextureResType.plistType
											)
	duanyuBtn:setPosition(-221.54,239.04)
	self.node:addChild(duanyuBtn)

	local browBtn = ccui.CheckBox:create("chat_btn_emoticons_0.png",
											"chat_btn_emoticons_1.png",
											"chat_btn_emoticons_1.png",
											"chat_btn_emoticons_0.png",
											"chat_btn_emoticons_0.png",
											ccui.TextureResType.plistType
											)
	browBtn:setPosition(-221.54,60)
	self.node:addChild(browBtn)

	local jiluBtn = ccui.CheckBox:create("chat_btn_jilu_0.png",
											"chat_btn_jilu_1.png",
											"chat_btn_jilu_1.png",
											"chat_btn_jilu_0.png",
											"chat_btn_jilu_0.png",
											ccui.TextureResType.plistType
											)
	jiluBtn:setPosition(-221.54,-119.04)
	self.node:addChild(jiluBtn)

	duanyuBtn:setTag(1)
	browBtn:setTag(2)
	jiluBtn:setTag(3)
	duanyuBtn:setSelected(true)
	duanyuBtn:addClickEventListener(function(sender)self:onCheckButtonClickedEvent(sender)end)
	browBtn:addClickEventListener(function(sender)self:onCheckButtonClickedEvent(sender)end)
	jiluBtn:addClickEventListener(function(sender)self:onCheckButtonClickedEvent(sender)end)
	table.insert(BtnArray,duanyuBtn)
	table.insert(BtnArray,browBtn)
	table.insert(BtnArray,jiluBtn)
	self.BtnArray=BtnArray

	local sendBtn=ccui.Button:create("chat_btn_send.png","chat_btn_send_1.png","chat_btn_send.png",ccui.TextureResType.plistType)
	sendBtn:setPosition(187.48,-278.38)
	self.node:addChild(sendBtn)

	sendBtn:setTag(4)
	sendBtn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	--输入框
	local editBoxSize=cc.size(350,70)
	local editbox = cc.EditBox:create(editBoxSize,"chat_bg2.png",ccui.TextureResType.plistType)
	editbox:setPosition(-84.78,-278.38)
	editbox:setFontName(GameUtils.getFontName())
	editbox:setFontSize(24)
    editbox:setFontColor(cc.c3b(147,109,89))
    editbox:setPlaceHolder("请输入:")
    editbox:setPlaceholderFontColor(cc.c3b(147,109,89))
    editbox:setOpacity(200)
    -- editbox:setMaxLength(8)
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	editbox:registerScriptEditBoxHandler(function(strEventName,pSender)self:editBoxTextEventHandle(strEventName,pSender)end)
	self.node:addChild(editbox)
	self.editbox=editbox

	--容器
	local pageviewSize=CHAT_SIZE
	local pageview=ccui.PageView:create()
    pageview:setTouchEnabled(false)--触摸的属性
    pageview:setBounceEnabled(true)--弹回的属性
    pageview:setInertiaScrollEnabled(false)--滑动的惯性
    pageview:setScrollBarEnabled(false)
    -- scrollview:setDirection(ccui.ScrollViewDir.vertical)
    pageview:setDirection(ccui.ScrollViewDir.horizontal)
    pageview:setContentSize(pageviewSize)
    pageview:setInnerContainerSize(cc.size(CHAT_SIZE.width*3,CHAT_SIZE.height))
    pageview:setPosition(-174.97,-203.93)
    self.node:addChild(pageview)
    self.pageview=pageview

    self.listViewArray={}

    self.recordData=nil

    self.IsPop = false

    self:createTextLayout()
    self:createBrowLayout()
    self:createRecordLayout()
end

--短语界面
function ChatLayer:createTextLayout()
	local layout=ccui.Layout:create()
	layout:setContentSize(CHAT_SIZE)

	local TextlistView=ccui.ListView:create()
	TextlistView:setTouchEnabled(true)--触摸的属性
    TextlistView:setBounceEnabled(true)--弹回的属性
    TextlistView:setInertiaScrollEnabled(false)--滑动的惯性
    TextlistView:setScrollBarEnabled(false)
    TextlistView:setDirection(ccui.ScrollViewDir.vertical)
    TextlistView:setContentSize(CHAT_SIZE)
    -- TextlistView:setInnerContainerSize(CHAT_SIZE)
    -- TextlistView:setPosition(0,0)
	layout:addChild(TextlistView)
	for i=1,#CHAT_TEXT do
		local item=self:createTextItem(i)
		TextlistView:pushBackCustomItem(item)
	end
	self.pageview:addChild(layout)
	self.TextlistView=TextlistView
end

--表情界面
function ChatLayer:createBrowLayout()
	local layout=ccui.Layout:create()
	layout:setContentSize(CHAT_SIZE)

	local BrowlistView=ccui.ListView:create()
	BrowlistView:setTouchEnabled(true)--触摸的属性
    BrowlistView:setBounceEnabled(true)--弹回的属性
    BrowlistView:setInertiaScrollEnabled(false)--滑动的惯性
    BrowlistView:setScrollBarEnabled(false)
    BrowlistView:setDirection(ccui.ScrollViewDir.vertical)
    BrowlistView:setContentSize(CHAT_SIZE)
	layout:addChild(BrowlistView)
	for i=1,BROW_ROW_NUM do
		local item=self:createBrowItem(i)
		BrowlistView:pushBackCustomItem(item)
	end
	self.pageview:addChild(layout)
	self.BrowlistView=BrowlistView
end

--记录界面
function ChatLayer:createRecordLayout()
	local layout=ccui.Layout:create()
	layout:setContentSize(CHAT_SIZE)

	local RecordlistView=ccui.ListView:create()
	RecordlistView:setTouchEnabled(true)--触摸的属性
    RecordlistView:setBounceEnabled(true)--弹回的属性
    RecordlistView:setInertiaScrollEnabled(false)--滑动的惯性
    RecordlistView:setScrollBarEnabled(false)
    RecordlistView:setDirection(ccui.ScrollViewDir.vertical)
    RecordlistView:setContentSize(CHAT_SIZE)
	layout:addChild(RecordlistView)
	self.pageview:addChild(layout)
	self.RecordlistView=RecordlistView
end

--短语item
function ChatLayer:createTextItem(index)
	local layout=ccui.Layout:create()
	local ItemSize=cc.size(CHAT_SIZE.width,77)
	layout:setContentSize(ItemSize)
	local labelConfig =	{
				fontName = GameUtils.getFontName(),
				fontSize = 26,
				text =CHAT_TEXT[index],
				alignment = cc.TEXT_ALIGNMENT_CENTER,
				color = cc.c4b(255,215,176,255),
				pos = cc.p(10,ItemSize.height/2),
				anchorPoint = cc.p(0,0.5)
			}
	local tex=cc.exports.lib.uidisplay.createLabel(labelConfig)
	layout:addChild(tex)
	local line=cc.Sprite:createWithSpriteFrameName("chat_line.png")
	line:setPosition(ItemSize.width/2,0)
	layout:addChild(line)

	local btn=ccui.Button:create("block.png",ccui.TextureResType.plistType)
	btn:setScale9Enabled(true)
	btn:setContentSize(ItemSize)
	btn:setPosition(ItemSize.width/2,ItemSize.height/2)
	btn:setTag(TEXT_TAG+index)
	btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	layout:addChild(btn)

	return layout
end

--表情item
function ChatLayer:createBrowItem(index)
	local layout=ccui.Layout:create()
	local ItemSize=cc.size(CHAT_SIZE.width,105)
	layout:setContentSize(ItemSize)
	local xx=CHAT_SIZE.width/4

	for i=1,BROW_LINE_NUM do
		local brow_id=(index-1)*BROW_LINE_NUM+i
		if brow_id<=BROW_NUM then
			local str="brow"..tostring(brow_id).."_0.png"
			local btn = ccui.Button:create()
			btn:loadTextureNormal(str, UI_TEX_TYPE_PLIST)
			btn:setPosition(50+xx*(i-1),ItemSize.height/2)
			btn:setTag(BROW_TAG+brow_id)
			btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
			layout:addChild(btn)
		end
	end
	return layout
end

--记录其他人短语item
function ChatLayer:createOtherTextRecordItem(info,str)
	local layout=ccui.Layout:create()
	if info ==nil then
		return
	end

	local AvatarUrl=info.AvatarUrl or ""
	local NickName=info.NickName or "玩家"

	local textlabConfig =	{
				fontName = GameUtils.getFontName(),
				fontSize = 26,
				text =str,
				alignment = cc.TEXT_ALIGNMENT_LEFT,
				color = cc.c4b(255,215,176,255),
				pos = cc.p(0,0),
				anchorPoint = cc.p(0,1)
			}
	local textlab=cc.exports.lib.uidisplay.createLabel(textlabConfig)
	layout:addChild(textlab)
	textlab:setMaxLineWidth(CHAT_SIZE.width-80)
	local ItemSize=cc.size(CHAT_SIZE.width,50+textlab:getContentSize().height)
	textlab:setPosition(70,ItemSize.height-45)
	layout:setContentSize(ItemSize)

	local paramTab={}
	paramTab.avatarUrl=AvatarUrl
	paramTab.stencilFile="Lobby/res/Avatar/head_circle_stencil_94_94.png"
	paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(info.Gender)
	local headnode=Avatar:create(paramTab)
	headnode:setScale(0.6)
	headnode:setPosition(10,ItemSize.height-70)
	layout:addChild(headnode)

	local namelabConfig =	{
				fontName = GameUtils.getFontName(),
				fontSize = 24, 
				text =string.getMaxLen(NickName,25),
				alignment = cc.TEXT_ALIGNMENT_CENTER,
				color = cc.c4b(241,109,39,255),
				pos = cc.p(70,ItemSize.height-25),
				anchorPoint = cc.p(0,0.5)
			}
	local name=cc.exports.lib.uidisplay.createLabel(namelabConfig)
	layout:addChild(name)

	self.RecordlistView:pushBackCustomItem(layout)
end

--记录其他人表情item
function ChatLayer:createOtherBrowRecordItem(info,brow_id)
	local layout=ccui.Layout:create()
	if info ==nil then
		return
	end

	local AvatarUrl=info.AvatarUrl or ""
	local NickName=info.NickName or "玩家"

	local ItemSize=cc.size(CHAT_SIZE.width,100)
	layout:setContentSize(ItemSize)

	local paramTab={}
	paramTab.avatarUrl=AvatarUrl
	paramTab.stencilFile="Lobby/res/Avatar/head_circle_stencil_94_94.png"
	paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(info.Gender)
	local headnode=Avatar:create(paramTab)
	headnode:setScale(0.6)
	headnode:setPosition(10,ItemSize.height-70)
	layout:addChild(headnode)

	local namelabConfig =	{
				fontName = GameUtils.getFontName(),
				fontSize = 24, 
				text =string.getMaxLen(NickName,25),
				alignment = cc.TEXT_ALIGNMENT_CENTER,
				color = cc.c4b(241,109,39,255),
				pos = cc.p(70,ItemSize.height-25),
				anchorPoint = cc.p(0,0.5)
			}
	local name=cc.exports.lib.uidisplay.createLabel(namelabConfig)
	layout:addChild(name)

	local str="brow"..tostring(brow_id).."_0.png"
	local browSp=cc.Sprite:createWithSpriteFrameName(str)
	browSp:setPosition(100,ItemSize.height-70)
	browSp:setScale(0.6)
	layout:addChild(browSp)

	self.RecordlistView:pushBackCustomItem(layout)
end

--记录自己短语item
function ChatLayer:createMyTextRecordItem(str)
	local layout=ccui.Layout:create()
	local textlabConfig =	{
				fontName = GameUtils.getFontName(),
				fontSize = 26,
				text =str,
				alignment = cc.TEXT_ALIGNMENT_LEFT,
				color = cc.c4b(255,215,176,255),
				pos = cc.p(0,0),
				anchorPoint = cc.p(1,1)
			}
	local textlab=cc.exports.lib.uidisplay.createLabel(textlabConfig)
	layout:addChild(textlab)
	textlab:setMaxLineWidth(CHAT_SIZE.width-80)
	local ItemSize=cc.size(CHAT_SIZE.width,50+textlab:getContentSize().height)
	textlab:setPosition(CHAT_SIZE.width-70,ItemSize.height-45)
	layout:setContentSize(ItemSize)

	local paramTab={}
	paramTab.avatarUrl=UserData.avatarUrl
	paramTab.stencilFile="Lobby/res/Avatar/head_circle_stencil_94_94.png"
	paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(UserData.Gender)
	local headnode=Avatar:create(paramTab)
	headnode:setScale(0.6)
	headnode:setPosition(ItemSize.width-60,ItemSize.height-70)
	layout:addChild(headnode)

	local namelabConfig =	{
				fontName = GameUtils.getFontName(),
				fontSize = 24, 
				text =string.getMaxLen(UserData.nickName,25),
				alignment = cc.TEXT_ALIGNMENT_CENTER,
				color = cc.c4b(241,109,39,255),
				pos = cc.p(ItemSize.width-70,ItemSize.height-25),
				anchorPoint = cc.p(1,0.5)
			}
	local name=cc.exports.lib.uidisplay.createLabel(namelabConfig)
	layout:addChild(name)
	
	self.RecordlistView:pushBackCustomItem(layout)
end

--记录自己表情item
function ChatLayer:createMyBrowRecordItem(brow_id)
	local layout=ccui.Layout:create()

	local ItemSize=cc.size(CHAT_SIZE.width,100)
	layout:setContentSize(ItemSize)

	local paramTab={}
	paramTab.avatarUrl=UserData.avatarUrl
	
	paramTab.stencilFile="Lobby/res/Avatar/head_circle_stencil_94_94.png"
	paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(UserData.Gender)
	local headnode=Avatar:create(paramTab)
	headnode:setScale(0.6)
	headnode:setPosition(ItemSize.width-60,ItemSize.height-70)
	layout:addChild(headnode)

	local namelabConfig =	{
				fontName = GameUtils.getFontName(),
				fontSize = 24, 
				text =string.getMaxLen(UserData.nickName,25),
				alignment = cc.TEXT_ALIGNMENT_CENTER,
				color = cc.c4b(241,109,39,255),
				pos = cc.p(ItemSize.width-70,ItemSize.height-25),
				anchorPoint = cc.p(1,0.5)
			}
	local name=cc.exports.lib.uidisplay.createLabel(namelabConfig)
	layout:addChild(name)

	local str="brow"..tostring(brow_id).."_0.png"
	local browSp=cc.Sprite:createWithSpriteFrameName(str)
	browSp:setPosition(ItemSize.width-100,ItemSize.height-70)
	browSp:setScale(0.6)
	layout:addChild(browSp)

	self.RecordlistView:pushBackCustomItem(layout)
	self.RecordlistView:jumpToBottom()
end

function ChatLayer:setData(dataArray)
	self.recordData=dataArray
	self:UpdateRecordlist()
end

function ChatLayer:addData(data)
	if tostring(data.uid)==tostring(UserData.userId) then
		if data.type==0 then
			self:createMyTextRecordItem(data.value)
		elseif data.type==1 then
			self:createMyBrowRecordItem(data.value)
		end
	else
		if data.type==0 then
			self:createOtherTextRecordItem(data.info,data.value)
		elseif data.type==1 then
			self:createOtherBrowRecordItem(data.info,data.value)
		end
	end
	self.RecordlistView:jumpToBottom()
end

function ChatLayer:UpdateRecordlist()
	for i,v in ipairs(self.recordData) do
		if tostring(v.uid)==tostring(UserData.userId) then
			if v.type==0 then
				self:createMyTextRecordItem(v.value)
			elseif v.type==1 then
				self:createMyBrowRecordItem(v.value)
			end
		else
			if v.type==0 then
				self:createOtherTextRecordItem(v.info,v.value)
			elseif v.type==1 then
				self:createOtherBrowRecordItem(v.info,v.value)
			end
		end
	end
	self.RecordlistView:jumpToBottom()
end

function ChatLayer:onCheckButtonClickedEvent(sender)
	local tag=sender:getTag()
	for i,v in ipairs(self.BtnArray) do
		v:setSelected(false)
	end
	self.pageview:scrollToItem(tag-1)
end

function ChatLayer:editBoxTextEventHandle(eventType)
	if eventType == "began" then
		self.IsPop = true
	elseif eventType == "ended" then
		self.IsPop = false
	elseif eventType == "return" then
	elseif eventType == "changed" then
	end
end

function ChatLayer:onButtonClickedEvent(sender)
	if self.IsPop == true then
		return
	end
	local tag=sender:getTag()
	if tag==4 then
		local str=self.editbox:getText()
		self:sendText(str,1)
	elseif tag>TEXT_TAG and tag<BROW_TAG then 
		local index=tag-TEXT_TAG
		self:sendText(tostring(index),2)
		self:closeLayer()
	elseif tag>BROW_TAG then
		local index=tag-BROW_TAG
		self:sendBrow(index)
		self:closeLayer()
	end
end

function ChatLayer:sendText(str,str_type)
	if str ~= "" then
		if str_type == 1 then
			self._gameRequest:RequestChatText("F"..str)
			self.editbox:setText("")
			self:closeLayer()
		elseif str_type == 2 then
			self._gameRequest:RequestChatText("T"..str)
			self.editbox:setText("")
			self:closeLayer()
		end
	end
end

function ChatLayer:sendBrow(BrowIndex)
	if BrowIndex>0 then
		self._gameRequest:RequestChatBrow(BrowIndex)
	end
end

function ChatLayer:setCPPos(hidePos,showPos)
	self.hidePos=hidePos
	self.showPos=showPos
end

--关闭界面
function ChatLayer:closeLayer()
	if self.listener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
	end
	local pos=self.hidePos or cc.p(-280,375)
	local a={}
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.1, pos))
    a[#a+1] = cc.CallFunc:create(
    	function(sender)
    		self:removeFromParent()
    	end)
    self.node:stopAllActions()
 	self.node:runAction(cc.Sequence:create(a))
end

--弹出界面
function ChatLayer:popLayer()
	local pos1=self.hidePos or cc.p(-280,375)
	local pos2=self.showPos or cc.p(280,375)
	self.node:setPosition(pos1)
	local a={}
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.1, pos2))
	self.node:stopAllActions()
 	self.node:runAction(cc.Sequence:create(a))
end

function ChatLayer:onEnter()
	self:popLayer()
end

function ChatLayer:onExit()

	self._gameRequest = nil
end

return ChatLayer