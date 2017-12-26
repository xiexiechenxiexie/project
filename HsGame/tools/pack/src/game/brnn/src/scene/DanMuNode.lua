-- 游戏帮助

local GameResPath  = "game/brnn/res/GameLayout/"
local conf = require"game/brnn/src/scene/Conf"
local Avatar=cc.exports.lib.node.Avatar
local FrameAniFactory=cc.exports.lib.factory.FrameAniFactory
local DANMU_NUM=3
local DANMU_Y=60
local DANMU_HEIGHT=50
local UPDATA_TIME=0.5
local DANMU_TIME=3
local BROW_TAG=30
local DanMuNode = class("DanMuNode",cc.Node)
local GameUserData=require "game/brnn/src/scene/GameUserData"

function DanMuNode:ctor()
	self:enableNodeEvents()
	self.m_DanMuScheduler=nil--弹幕定时器
    self:init()
end

function DanMuNode:init()
	self.count = 0
	self.danmuArray = {}
	self.dataArray = {} 
	self.oldHeadUrl = {}
	for i=1,DANMU_NUM do
		local node=cc.Node:create()
		node:setVisible(false)
		node:setPosition(0,(2-i)*DANMU_Y)
		self:addChild(node)

		local bgSp=cc.Scale9Sprite:create(GameResPath.."chat_game_bg.png")
		local Ssize=bgSp:getContentSize()
		bgSp:setAnchorPoint(cc.p(0,0.5))
		bgSp:setPosition(0,0)
		bgSp:setName("bgSp")
		node:addChild(bgSp)
		bgSp:setPreferredSize(cc.size(100,DANMU_HEIGHT))

		local headbg=cc.Sprite:create(GameResPath.."head_clip_bg.png")
		headbg:setPosition(20,0)
		headbg:setName("headbg")
		headbg:setScale(0.45)
		node:addChild(headbg)

		local browSp=cc.Sprite:createWithSpriteFrameName("brow1_1.png")
		browSp:setPosition(70,0)
		browSp:setName("browSp")
		browSp:setScale(0.5)
		node:addChild(browSp)
		browSp:setTag(BROW_TAG)

		local labelConfig =	{
				fontName = GameUtils.getFontName(),
				fontSize = 22,
				text ="",
				alignment = cc.TEXT_ALIGNMENT_CENTER,
				color = cc.c4b(24,59,87,255),
				pos = cc.p(50,0),
				anchorPoint = cc.p(0,0.5)
			}
		local lab = cc.exports.lib.uidisplay.createLabel(labelConfig)
		lab:setName("lab")
		node:addChild(lab)

		table.insert(self.danmuArray,node)
		table.insert(self.oldHeadUrl,0)
	end
end

function DanMuNode:addData(uid,type,value)
	local tab={}
	tab.uid=uid
	tab.type=type
	tab.value=value
	table.insert(self.dataArray,tab)
	if self.m_DanMuScheduler == nil then
		self:UpdateNode()
		local scheduler = cc.Director:getInstance():getScheduler()  
		self.m_DanMuScheduler = scheduler:scheduleScriptFunc(function()
   			self:UpdateNode()
		end,UPDATA_TIME,false)
	end
end

function DanMuNode:UpdateNode()
	local CurNum = #self.dataArray
	if CurNum == 0 then
		local scheduler = cc.Director:getInstance():getScheduler()
    	scheduler:unscheduleScriptEntry(self.m_DanMuScheduler)
    	self.m_DanMuScheduler=nil
    	self.dataArray={}
    	self.count=0
    	for i,v in ipairs(self.danmuArray) do
    		v:setVisible(false)
    	end
    	return
	end
	self.count=self.count+1

	for i=1,DANMU_NUM do
		if self.dataArray[i] then
			local uid = self.dataArray[i].uid
			local dtype = self.dataArray[i].type
			local value = self.dataArray[i].value
			local bgSp = self.danmuArray[i]:getChildByName("bgSp")
			local headbg = self.danmuArray[i]:getChildByName("headbg")
			local browSp = self.danmuArray[i]:getChildByName("browSp")
			local lab = self.danmuArray[i]:getChildByName("lab")
			local info = GameUserData:getInstance():getUserInfo(uid)
			local paramTab = {}
			paramTab.avatarUrl = info.AvatarUrl
			paramTab.stencilFile = "game/brnn/res/GameLayout/head_bg.png"
			paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(info.Gender)
			if self.oldHeadUrl[i] ~= info.AvatarUrl then
				local headnode = Avatar:create(paramTab)
				headnode:setPosition(5,5)
				headbg:removeAllChildren()
				headbg:addChild(headnode)
				self.oldHeadUrl[i] = info.AvatarUrl
			end
			if dtype==0 then
				lab:setVisible(true)
				browSp:setVisible(false)
				browSp:stopAllActions()
				browSp:setTag(BROW_TAG)
				lab:setString(value)
				local len=lab:getContentSize().width
				bgSp:setPreferredSize(cc.size(80+len,DANMU_HEIGHT))
			elseif dtype==1 then
				lab:setVisible(false)
				browSp:setVisible(true)
				local str="brow"..tostring(value).."_1.png"
				if browSp:getTag() ~= BROW_TAG+value then
					browSp:initWithSpriteFrameName(str)
					local act=FrameAniFactory:getInstance():getBrowAnimationById(value)
					browSp:stopAllActions()
					browSp:runAction(cc.RepeatForever:create(act))
					browSp:setTag(BROW_TAG+value)
				end
				bgSp:setPreferredSize(cc.size(100,DANMU_HEIGHT))
			end
			self.danmuArray[i]:setVisible(true)
		else
			self.danmuArray[i]:setVisible(false)
		end
	end
	if self.dataArray then
		if self.count>=DANMU_TIME/UPDATA_TIME then
			self.count=0
			table.remove(self.dataArray,1)
		end
	end
end

function DanMuNode:onExit()
	if self.m_DanMuScheduler then
		local scheduler = cc.Director:getInstance():getScheduler()
    	scheduler:unscheduleScriptEntry(self.m_DanMuScheduler)
	end
end

return DanMuNode