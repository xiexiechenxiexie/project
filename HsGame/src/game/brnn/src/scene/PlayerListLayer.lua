-- 游戏玩家列表
local PlayerListLayer_CSB = "game/brnn/res/PlayerListNode.csb"
local GameResPath  = "game/brnn/res/PlayerListLayout/"
local conf = require"game/brnn/src/scene/Conf"
local PlayerInfoView = require "PlayerInfoView"
local GameUserData=require "game/brnn/src/scene/GameUserData"
local Avatar=cc.exports.lib.node.Avatar
local Tag=conf.Tag
local ItemNum=3
--玩家头像按钮tag
local PLAYER_HEAD_TAG=200

local PlayerListLayer = class("PlayerListLayer", lib.layer.BaseWindow)

function PlayerListLayer:ctor()
	PlayerListLayer.super.ctor(self)
    self:CreateView()
    self:init()
end

function PlayerListLayer:CreateView()
    local RootNode = cc.CSLoader:createNode(PlayerListLayer_CSB)
    RootNode:setPosition(667,375)
	self:addChild(RootNode)
	self.RootNode=RootNode

	self:_onRootPanelInit(self.RootNode)
end

function PlayerListLayer:init()
	--关闭按钮
	local close_btn=self.RootNode:getChildByName("close")
	close_btn:setTag(Tag.Close)
	close_btn:addClickEventListener(handler(self,self.onCloseCallback))

	--人数
	self.PlayerNumLab=self.RootNode:getChildByName("PlayerNum")
	self.PlayerNumLab:setFontName(GameUtils.getFontName())

	--调整字体
	local text=self.RootNode:getChildByName("text")
	text:setFontName(GameUtils.getFontName())

	--玩家列表
	self.PlayerList = self.RootNode:getChildByName("PlayerList")
	--item大小
	self.ItemSize=cc.size(920,140)

	self.data={}

	--玩家列表数量
	self.PlayerNum=0
	--玩家列表玩家信息
	self.playerInfo={}

	--uid列表
	self.uidArray={}
end

function PlayerListLayer:setData(dataArray)
	self.uidArray=dataArray
	self:updateSZList()
end

function PlayerListLayer:updateSZList()
	local dataArray=self.uidArray
	self.playerInfo={}
	self.PlayerNum=#dataArray
	self.PlayerNumLab:setString(tostring(self.PlayerNum))

	self.PlayerList:removeAllItems()
	if self.PlayerNum>0 then
		local col=math.modf(self.PlayerNum/ItemNum)
		for i=1,col do
			local colTab={}
			for j=1,ItemNum do
				local info=self:getInfo(dataArray[(i-1)*ItemNum+j])
				table.insert(colTab,info)
			end
			table.insert(self.playerInfo,colTab)
		end

		local lastNum=self.PlayerNum-col*ItemNum
		if lastNum>0 then
			local ttab={}
			for i=1,lastNum do
				local info=self:getInfo(dataArray[col*ItemNum+i])
				table.insert(ttab,info)
			end
			table.insert(self.playerInfo,ttab)
		end
	end
	self:RenderPlayerList()
end

function PlayerListLayer:RenderPlayerList()
	if self.PlayerNum<=0 then
		return
	end
	for i,v in ipairs(self.playerInfo) do
		self:createItem(self.playerInfo[i],i)
	end
end

function PlayerListLayer:createItem(data,index)
	local xx=300
	local layout=ccui.Layout:create()
	layout:setContentSize(self.ItemSize)

	for i,v in ipairs(data) do
		local info=v
		local x,y=self.ItemSize.width/2+(i+1-ItemNum)*xx,self.ItemSize.height/2
		local bg=cc.Sprite:create(GameResPath.."wuzuoweiwanjia.png")
		bg:setPosition(cc.p(x,y))
		layout:addChild(bg)

		local btn=ccui.Button:create("game/brnn/res/GameLayout/head_clip_bg.png")
  	 	btn:setPosition(x-75,y)
  	 	btn:setTag(PLAYER_HEAD_TAG+(index-1)*ItemNum+i)
  	 	btn:addClickEventListener(function(sender)self:onHeadButtonClickedEvent(sender)end)
  	 	layout:addChild(btn)

		local paramTab={}
		paramTab.avatarUrl=v.AvatarUrl or ""
		paramTab.stencilFile="game/brnn/res/GameLayout/head_bg.png"
		paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(info.Gender)
		local headnode=Avatar:create(paramTab)
		headnode:setPosition(cc.p(x-124,y-49))
		headnode:setScale(1.05)
		layout:addChild(headnode)

		local nameStr=nil
		local scoreStr=nil
		if next(info)==nil then
			nameStr="???"
			scoreStr="???"
		else
			nameStr=string.getMaxLen(info.NickName)
			scoreStr=conf.switchNum(info.Score)
		end

		local labelConfig =	{
				fontName = GameUtils.getFontName(),
				fontSize = 22,
				text =string.getMaxLen(nameStr),
				alignment = cc.TEXT_ALIGNMENT_CENTER,
				color = cc.c4b(255,242,233, 255),
				pos = cc.p(x+10,y+18),
				anchorPoint = cc.p(0,0.5)
			}
		local nameLab = cc.exports.lib.uidisplay.createLabel(labelConfig)
		layout:addChild(nameLab)

		labelConfig =	{
				fontName = GameUtils.getFontName(),
				fontSize = 20,
				text =scoreStr,
				alignment = cc.TEXT_ALIGNMENT_CENTER,
				color = cc.c4b(255,246,198, 255),
				pos = cc.p(x+10,y-18),
				anchorPoint = cc.p(0,0.5)
			}
		local scoreLab = cc.exports.lib.uidisplay.createLabel(labelConfig)
		layout:addChild(scoreLab)
	end
	self.PlayerList:pushBackCustomItem(layout)
end

function PlayerListLayer:getInfo(uid)
	local Info=GameUserData:getInstance():getUserInfo(uid)
	return Info
end

function PlayerListLayer:onHeadButtonClickedEvent(sender)
	local tag=sender:getTag()
	local index=tag-PLAYER_HEAD_TAG
	local uid=self.uidArray[index]
	local info=GameUserData:getInstance():getUserInfo(uid)
	local playerInfoView=PlayerInfoView.new(uid)
	playerInfoView:setInfoData(info)
 	self:getParent():addChild(playerInfoView,conf.LayZ.playerInfo)
end

return PlayerListLayer