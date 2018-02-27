-- 游戏路单

local GameResPath  = "game/brnn/res/SmallLuDanNode/"
local conf = require"game/brnn/src/scene/Conf"
local SmallLuDanNode = class("SmallLuDanNode", cc.Node)

function SmallLuDanNode:ctor()
	self:enableNodeEvents()
	self:preloadUI()
    self:init()
end

function SmallLuDanNode:preloadUI()
	display.loadSpriteFrames(GameResPath.."SmallLuDanNode.plist",
							GameResPath.."SmallLuDanNode.png")
end

function SmallLuDanNode:init()
	self.SpNode=cc.Node:create()
	self:addChild(self.SpNode)
	self.YuanQuanTab={}
	local xx=18
	for i=1,conf.LUDAN_NUM do
		local sp=cc.Sprite:createWithSpriteFrameName("yuanquan0.png")
		sp:setPosition(cc.p(xx*(1-i),20))
		self.SpNode:addChild(sp)
		sp:setVisible(false)
		table.insert(self.YuanQuanTab,sp)
	end
end

function SmallLuDanNode:onExit()
	display.removeSpriteFrames(GameResPath.."SmallLuDanNode.plist",
							GameResPath.."SmallLuDanNode.png")
end

function SmallLuDanNode:update()
	if self.dataArray==nil then
		self.SpNode:setVisible(false)
		return
	end
	
	self.SpNode:setVisible(true)

	local num=#self.dataArray
	if num<conf.LUDAN_NUM then
		for i=num+1,conf.LUDAN_NUM do
			self.YuanQuanTab[i]:setVisible(false)
		end
	end
	for i,v in ipairs(self.dataArray) do
		local str="yuanquan"..tostring(v)..".png"
		self.YuanQuanTab[num+1-i]:initWithSpriteFrameName(str)
		self.YuanQuanTab[num+1-i]:setVisible(true)
	end
end

function SmallLuDanNode:adjustPos()
	if self.dataArray==nil then
		self.SpNode:setVisible(false)
		return
	end
	
	self.SpNode:setVisible(true)

	local num=#self.dataArray
	if num<conf.LUDAN_NUM then
		for i=num+1,conf.LUDAN_NUM do
			self.YuanQuanTab[i]:setVisible(false)
		end
	end
	for i,v in ipairs(self.dataArray) do
		local str="yuanquan"..tostring(v)..".png"
		self.YuanQuanTab[num+1-i]:initWithSpriteFrameName(str)
		if num -i ~= 0 then
			self.YuanQuanTab[num+1-i]:setVisible(true)
		else
			self.YuanQuanTab[num+1-i]:setVisible(false)
		end
	end
end

function SmallLuDanNode:setData(dataArray)
	self.dataArray = dataArray
end

return SmallLuDanNode