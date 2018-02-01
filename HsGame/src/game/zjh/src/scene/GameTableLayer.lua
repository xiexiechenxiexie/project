-- 游戏主界面
local MusicManager=cc.exports.manager.MusicManager

local GameRequest = require "game/zjh/src/request/GameRequest"
local ChatLayer=require "gamecommon/chat/src/ChatLayer"
local PlayerNode = require "game/zjh/src/scene/PlayerNode"

local GamePlayerInfoView = require "GamePlayerInfoView"
local Subsidy = require "gamecommon/subsidy/src/SubsidyLayer"
local conf = require"game/zjh/src/scene/Conf"
local Avatar=cc.exports.lib.node.Avatar
local FrameAniFactory = cc.exports.lib.factory.FrameAniFactory
local Tag = conf.Tag
local LayZ = conf.LayZ
local GameResPath = "game/zjh/res/GameLayout/"

local GameTableLayer = class("GameTableLayer", cc.Layer)

function GameTableLayer:ctor()
	self:enableNodeEvents() 
    self:preloadUI()
    self:init()
    self._gameRequest = GameRequest:new()
end

function GameTableLayer:preloadUI()

end

-- 初始化界面
function GameTableLayer:init()
	local bg = display.newSprite(GameResPath.."zjh_bg.png")
	bg:setPosition(667,375)
	bg:setScaleX(1334/1136)
	bg:setScaleY(750/640)
	self:addChild(bg,-1)

	local girl_sp = display.newSprite(GameResPath.."zjh_girl.png")
	girl_sp:setPosition(681.50,640.24)
	girl_sp:setScaleX(1334/1136)
	girl_sp:setScaleY(750/640)
	self:addChild(girl_sp,-1)

	--主控件节点
	local node = cc.Node:create()
	self:addChild(node,LayZ.ButtonNode)

	--返回按钮
	local back_btn = ccui.Button:create(GameResPath.."zjh_quit_btn.png",GameResPath.."zjh_quit_btn.png",GameResPath.."zjh_quit_btn.png",ccui.TextureResType.localType)
	back_btn:setPosition(60,690)
	back_btn:setPressedActionEnabled(true)
	back_btn:setTag(Tag.back)
	back_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	node:addChild(back_btn)

	--规则按钮
	local rule_btn = ccui.Button:create(GameResPath.."zjh_rule_btn.png",GameResPath.."zjh_rule_btn.png",GameResPath.."zjh_rule_btn.png",ccui.TextureResType.localType)
	rule_btn:setPosition(150,690)
	rule_btn:setPressedActionEnabled(true)
	rule_btn:setTag(Tag.rule)
	rule_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	node:addChild(rule_btn)

	--设置按钮
	local set_btn = ccui.Button:create(GameResPath.."zjh_set_btn.png",GameResPath.."zjh_set_btn.png",GameResPath.."zjh_set_btn.png",ccui.TextureResType.localType)
	set_btn:setPosition(1278,690)
	set_btn:setPressedActionEnabled(true)
	set_btn:setTag(Tag.set)
	set_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	node:addChild(set_btn)

	--商城按钮
	local shop_btn = ccui.Button:create(GameResPath.."zjh_chongzhi.png",GameResPath.."zjh_chongzhi.png",GameResPath.."zjh_chongzhi.png",ccui.TextureResType.localType)
	shop_btn:setPosition(1278,100)
	shop_btn:setPressedActionEnabled(true)
	shop_btn:setTag(Tag.shop)
	shop_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	node:addChild(shop_btn)

	--弃牌按钮
	local pass_btn = ccui.Button:create(GameResPath.."zjh_bottom_btn0.png",GameResPath.."zjh_bottom_btn0.png",GameResPath.."zjh_bottom_btn0.png",ccui.TextureResType.localType)
	pass_btn:setPosition(100,40)
	pass_btn:setPressedActionEnabled(true)
	pass_btn:setTag(Tag.pass)
	pass_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
	node:addChild(pass_btn)

	--全押，比牌，加注，跟注，看牌等按钮
	for i=1,5 do
		local res_str =  GameResPath.."zjh_bottom_btn"..i..".png"
		local btn = ccui.Button:create(res_str,res_str,res_str,ccui.TextureResType.localType)
		btn:setPosition(400+i*150,40)
		btn:setPressedActionEnabled(true)
		btn:setTag(Tag.all+i-1)
		btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
		node:addChild(btn)
	end

	--跟到底单选按钮
	local GDD_str = GameResPath.."zjh_bottom_btn7.png"
	local GDD_select_str = GameResPath.."zjh_bottom_btn7_1.png"
	local GDDBtn = ccui.CheckBox:create(GDD_str,
										GDD_select_str,
										GDD_select_str,
										GDD_str,
										GDD_str,
										ccui.TextureResType.localType
										)
	GDDBtn:setPosition(400+5*150,40)
	node:addChild(GDDBtn)
	GDDBtn:setTag(Tag.gdd)
	GDDBtn:setSelected(false)
	GDDBtn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	--初始化玩家
	self:initPlayer()
end

-- 初始化玩家
function GameTableLayer:initPlayer()
	local node = cc.Node:create()
	self:addChild(node,LayZ.PlayerNode)

	--玩家表现节点
	local player_effect_node = cc.Node:create()
	self:addChild(player_effect_node,LayZ.PlayerEffect)

	self.PlayerArray = {}
	self.PlayerCompareArray = {}
	for i=1,conf.MaxPlayerNum do
		local compare_btn = ccui.Button:create(GameResPath.."zjh_compare.png",GameResPath.."zjh_compare.png",GameResPath.."zjh_compare.png",ccui.TextureResType.localType)
		compare_btn:setPosition(conf.PlayerNodePos[i])
		compare_btn:setTag(Tag.PlayerCompare1+i-1)
		compare_btn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)
		player_effect_node:addChild(compare_btn)
		table.insert(self.PlayerCompareArray,compare_btn)

		local Player = PlayerNode.new()
		node:addChild(Player)
		Player:setPosition(conf.PlayerNodePos[i])
		table.insert(self.PlayerArray,Player)		
	end
end

function GameTableLayer:onButtonClickedEvent(sender)
	local tag=sender:getTag()
	if tag ==Tag.back then
		print("退出")
		-- self._gameRequest:RequestTest()
	elseif tag ==Tag.rule then
		print("规则")
	elseif tag ==Tag.set then
		print("设置")
	elseif tag ==Tag.pass then
		print("弃牌")
	elseif tag ==Tag.all then
		print("全押")
	elseif tag ==Tag.compare then
		print("比牌")
	elseif tag ==Tag.add then
		print("加注")
	elseif tag ==Tag.tracking then
		print("跟注")
	elseif tag ==Tag.see then
		print("看牌")
	elseif tag ==Tag.gdd then
		if sender:isSelected() then
			print("取消跟到底")
		else
			print("跟到底")
		end
	elseif tag ==Tag.shop then
		print("商城")
	elseif tag >=Tag.PlayerCompare1 and tag <=Tag.PlayerCompare5 then
		local index = tag -Tag.PlayerCompare1+1
		print("和玩家比牌",index)
	end
end

function GameTableLayer:onEnter()
	-- MusicManager:getInstance():playSound()
end

function GameTableLayer:onExit()
	self._gameRequest = nil
end

return GameTableLayer