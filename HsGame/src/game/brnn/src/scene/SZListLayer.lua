-- 游戏上庄列表

local GameRequest = require "game/brnn/src/request/GameRequest"
local SZList_CSB = "game/brnn/res/SZListNode.csb"
local GameResPath  = "game/brnn/res/SZListLayout/"
local GameUserData=require "game/brnn/src/scene/GameUserData"
local HttpClient=cc.exports.HttpClient
local conf = require"game/brnn/src/scene/Conf"
local Tag=conf.Tag

local SZListLayer = class("SZListLayer", lib.layer.BaseWindow)

function SZListLayer:ctor()
	SZListLayer.super.ctor(self)
	self.data={}
    self:CreateView()
    self:init()
    self._gameRequest = GameRequest:new()
end

function SZListLayer:CreateView()
    local RootNode = cc.CSLoader:createNode(SZList_CSB)
    RootNode:setPosition(667,375)
	self:addChild(RootNode)
	self.RootNode=RootNode
	self:_onRootPanelInit(self.RootNode)
end

function SZListLayer:init()
	--关闭按钮
	local close_btn=self.RootNode:getChildByName("close")
	close_btn:setTag(Tag.Close)
	close_btn:addClickEventListener(handler(self,self.onCloseCallback))

	--申请上庄按钮
	local SZ_btn=self.RootNode:getChildByName("SZ_btn")
	SZ_btn:setTag(Tag.shangzhuang)
	SZ_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	self.SZ_btn=SZ_btn

	--调整字体
	local text1=self.RootNode:getChildByName("text1")
	text1:setFontName(GameUtils.getFontName())
	local text2=self.RootNode:getChildByName("text2")
	text2:setFontName(GameUtils.getFontName())
	self.sz_score_lab=text2
	local text3=self.RootNode:getChildByName("text3")
	text3:setFontName(GameUtils.getFontName())


	--取消申请按钮
	local QX_btn=self.RootNode:getChildByName("QX_btn")
	QX_btn:setTag(Tag.quxiao)
	QX_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	QX_btn:setVisible(false)
	self.QX_btn=QX_btn

	--申请下庄按钮
	local XZ_btn=self.RootNode:getChildByName("XZ_btn")
	XZ_btn:setTag(Tag.xiazhuang)
	XZ_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	XZ_btn:setVisible(false)
	self.XZ_btn=XZ_btn

	--上庄人数
	local listNumText=self.RootNode:getChildByName("DDNum")
	listNumText:setString("0")
	listNumText:setFontName(GameUtils.getFontName())
	self.listNumText=listNumText

	--上庄列表
	self.SZ_list = self.RootNode:getChildByName("PlayerList")
	--item大小
	self.ItemSize=cc.size(780,70)

	--庄家列表数量
	self.SZnum=0
	--上庄列表玩家信息
	self.playerInfo={}
end

function SZListLayer:setData(dataArray,zhuangMinScore)
	self.data=dataArray
	self:updateSZList()
	if zhuangMinScore then
		self:setSZScore(zhuangMinScore)
	end
end

function SZListLayer:updateSZList()
	local dataArray=self.data
	self.playerInfo={}
	self.SZnum=#dataArray
	self.listNumText:setString(tostring(self.SZnum-1))
	self.SZ_list:removeAllItems()

	local IsInSZlist=false
	local Myindex=0
	for i,v in ipairs(dataArray) do
		if tostring(v)==tostring(UserData.userId) then
			IsInSZlist=true
			Myindex=i
		end
	end

	if IsInSZlist then
		if Myindex==1 then
			self.SZ_btn:setVisible(false)
			self.QX_btn:setVisible(false)
			self.XZ_btn:setVisible(true)
		else
			self.SZ_btn:setVisible(false)
			self.QX_btn:setVisible(true)
			self.XZ_btn:setVisible(false)
		end
	else
		self.SZ_btn:setVisible(true)
		self.QX_btn:setVisible(false)
		self.XZ_btn:setVisible(false)
	end

	if self.SZnum>0 then
		for i=1,self.SZnum do
			if dataArray[i]<=0 then
				local Info={}
				Info.nickName=string.getMaxLen(conf.HostZhuangName)
				Info.score= "系统当庄"
				table.insert(self.playerInfo,Info)
			else
				local Info=GameUserData:getInstance():getUserInfo(dataArray[i])
				table.insert(self.playerInfo,Info)
			end
		end
	end
	self:RenderSZList()
end

function SZListLayer:RenderSZList()
	if self.SZnum<=0 then
		return
	end
	for i=1,self.SZnum do
		self:createItem(self.playerInfo[i],i)
	end
end

function SZListLayer:createItem(data,index)
	local layout=ccui.Layout:create()
	layout:setContentSize(self.ItemSize)
	if index==1 then
		local spBg=cc.Sprite:create(GameResPath.."banker_list_effect.png")
		spBg:setPosition(cc.p(self.ItemSize.width/2,self.ItemSize.height/2))
		layout:addChild(spBg)

		local sp=cc.Sprite:create(GameResPath.."banker_ico.png")
		sp:setPosition(cc.p(30,self.ItemSize.height/2))
		layout:addChild(sp)
	end
	-- local sp_line=cc.Sprite:createWithSpriteFrameName("chat_line.png")
	-- sp_line:setPosition(cc.p(self.ItemSize.width/2,5))
	-- layout:addChild(sp_line)

	local nameStr=nil
	local scoreStr=nil
	if data==nil then
		nameStr="???"
		scoreStr="???"
	else
		nameStr=data.nickName
		scoreStr=conf.switchNum(data.score)
	end

	local labelConfig =	{
			fontName = GameUtils.getFontName(),
			fontSize = 23,
			text =nameStr,
			alignment = cc.TEXT_ALIGNMENT_CENTER,
			color = cc.c4b(255,242,201, 255),
			pos = cc.p(80,self.ItemSize.height/2),
			anchorPoint = cc.p(0,0.5)
		}
	local nameLab = cc.exports.lib.uidisplay.createLabel(labelConfig)
	layout:addChild(nameLab)


	labelConfig =	{
			fontName = GameUtils.getFontName(),
			fontSize = 22,
			text =scoreStr or "系统当庄",
			alignment = cc.TEXT_ALIGNMENT_CENTER,
			color = cc.c4b(255,246,198, 255),
			pos = cc.p(760,self.ItemSize.height/2),
			anchorPoint = cc.p(1,0.5)
		}
	local scoreLab = cc.exports.lib.uidisplay.createLabel(labelConfig)
	layout:addChild(scoreLab)

	self.SZ_list:pushBackCustomItem(layout)
end

function SZListLayer:setSZScore(score)
	self.sz_score_lab:setString("上庄条件:金币大于"..conf.switchNum(score))
end

function SZListLayer:onButtonClickedEvent(sender)
	local tag=sender:getTag()
	if tag==Tag.shangzhuang then
		printInfo("发送上庄")
		self._gameRequest:RequestGameShangZhuang(1)
	elseif tag==Tag.quxiao then
		printInfo("发送取消申请")
		self._gameRequest:RequestGameShangZhuang(0)
	elseif tag==Tag.xiazhuang then
		printInfo("发送下庄")
		self._gameRequest:RequestGameShangZhuang(0)
	end
end

return SZListLayer