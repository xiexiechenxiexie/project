-- 游戏路单

local WinRecordLayer_CSB = "game/brnn/res/WinRecordNode.csb"
local GameResPath  = "game/brnn/res/WinRecordLayout/"
local conf = require"game/brnn/src/scene/Conf"
local Tag=conf.Tag

local WinRecordLayer = class("WinRecordLayer", lib.layer.BaseWindow)

function WinRecordLayer:ctor()
	WinRecordLayer.super.ctor(self)
    self:CreateView()
    self:init()
end

function WinRecordLayer:CreateView()
    local RootNode = cc.CSLoader:createNode(WinRecordLayer_CSB)
    RootNode:setPosition(667,375)
	self:addChild(RootNode)
	self.RootNode=RootNode

	self:_onRootPanelInit(self.RootNode)
end

function WinRecordLayer:init()
	--关闭按钮
	local close_btn=self.RootNode:getChildByName("close")
	close_btn:setTag(Tag.Close)
	close_btn:addClickEventListener(handler(self,self.onCloseCallback))

	self.SpNode=cc.Node:create()
	self.RootNode:addChild(self.SpNode)

	self.SpTab={}
	local XX=-424
	local YY=85
	local x=84
	local y=100
	for i=1,conf.LUDAN_NUM do
		local Tab={}
		for j=1,conf.QUYU_NUM do
			local sp=cc.Sprite:createWithSpriteFrameName("data0.png")
			sp:setPosition(cc.p(XX+i*x,YY+(1-j)*y))
			self.SpNode:addChild(sp)
			table.insert(Tab,sp)
		end
		table.insert(self.SpTab,Tab)
	end
end

function WinRecordLayer:updateList(dataArray)
	if next(dataArray)==nil then
		self.SpNode:setVisible(false)
		return
	else
		self.SpNode:setVisible(true)
	end
	local num=#dataArray
	if num<conf.LUDAN_NUM then
		for i=num+1,conf.LUDAN_NUM do
			for j=1,conf.QUYU_NUM do
				self.SpTab[i][j]:setVisible(false)
			end
		end
	end
	for i,v in ipairs(dataArray) do
		for a,b in ipairs(v) do
			self.SpTab[num+1-i][a]:setVisible(true)
			local str="data"..tostring(b)..".png"
			self.SpTab[num+1-i][a]:initWithSpriteFrameName(str)
		end
	end
end

return WinRecordLayer