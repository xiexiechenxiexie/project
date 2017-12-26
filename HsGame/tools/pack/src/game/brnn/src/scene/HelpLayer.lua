-- 游戏帮助

local HelpLayer_CSB = "game/brnn/res/HelpNode.csb"
local GameResPath  = "game/brnn/res/HelpLayout/"
local conf = require"game/brnn/src/scene/Conf"
local Tag=conf.Tag

local HelpLayer = class("HelpLayer", lib.layer.BaseWindow)

function HelpLayer:ctor()
	HelpLayer.super.ctor(self)
    self:CreateView()
    self:init()
end

function HelpLayer:CreateView()
    local RootNode = cc.CSLoader:createNode(HelpLayer_CSB)
    RootNode:setPosition(667,375)
	self:addChild(RootNode)
	self.RootNode=RootNode

	self:_onRootPanelInit(self.RootNode)
end

function HelpLayer:init()
	--退出按钮
	local close_btn=self.RootNode:getChildByName("close")
	close_btn:setTag(Tag.Close)
	close_btn:addClickEventListener(handler(self,self.onCloseCallback))
end

return HelpLayer