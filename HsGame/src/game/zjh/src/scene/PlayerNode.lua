-- 玩家节点
local conf = require"game/zjh/src/scene/Conf"
local Avatar=cc.exports.lib.node.Avatar
local Tag = conf.Tag
local LayZ = conf.LayZ
local GameResPath = "game/zjh/res/GameLayout/"

local PlayerNode = class("PlayerNode", cc.Node)

function PlayerNode:ctor()
    self:init()
end

function PlayerNode:init()
	local bg1 = cc.Sprite:create(GameResPath.."zjh_player_bg.png")
	self:addChild(bg1)

	local bg2 = cc.Sprite:create(GameResPath.."zjh_player_bg2.png")
	bg2:setPosition(0,-90)
	self:addChild(bg2)

	local HeadNode = cc.Node:create()
	self:addChild(HeadNode)
	local paramTab={}
	paramTab.avatarUrl=""
	paramTab.stencilFile=GameResPath.."zjh_head_bg.png"
	paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(2)
	local AvatarNode=Avatar:create(paramTab)
	AvatarNode:setPosition(-AvatarNode:getContentSize().width/2,-AvatarNode:getContentSize().height/2)
	HeadNode:addChild(AvatarNode)
	HeadNode:setName("Head")

	local kuang_sp = cc.Sprite:create(GameResPath.."zjh_head_bg1.png")
	self:addChild(kuang_sp)
	kuang_sp:setName("kuang")

	local labelConfig =	{
		fontName = GameUtils.getFontName(),
		fontSize = 18,
		text =string.getMaxLen("哈哈哈哈哈哈哈哈",6),
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255,255),
		pos = cc.p(0,55),
		anchorPoint = cc.p(0.5,0.5)
	}
	local name_lab = cc.exports.lib.uidisplay.createLabel(labelConfig)
	self:addChild(name_lab)
	name_lab:setName("name")

	labelConfig =	{
		fontName = GameUtils.getFontName(),
		fontSize = 20,
		text =1000,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255,255),
		pos = cc.p(0,-55),
		anchorPoint = cc.p(0.5,0.5)
	}
	local all_score_lab = cc.exports.lib.uidisplay.createLabel(labelConfig)
	self:addChild(all_score_lab)
	all_score_lab:setName("allscore")

	local score_sp = cc.Sprite:create(GameResPath.."zjh_scroe_icon.png")
	score_sp:setPosition(-30,-90)
	self:addChild(score_sp)

	labelConfig =	{
		fontName = GameUtils.getFontName(),
		fontSize = 20,
		text =1000,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255,255),
		pos = cc.p(-10,-90),
		anchorPoint = cc.p(0,0.5)
	}
	local score_lab = cc.exports.lib.uidisplay.createLabel(labelConfig)
	self:addChild(score_lab)
	score_lab:setName("score")
end

function PlayerNode:setName(str)
	self:getChildByName("name"):setString(string.getMaxLen(str,6))
end

function PlayerNode:setAllScore(num)
	self:getChildByName("allscore"):setString(tostring(num))
end

function PlayerNode:setScore(num)
	self:getChildByName("score"):setString(tostring(num))
end

function PlayerNode:setHead(avatarUrl)
	local head = self:getChildByName("Head")
	head:removeAllChildren()
	local paramTab={}
	paramTab.avatarUrl=avatarUrl
	paramTab.stencilFile=GameResPath.."zjh_head_bg.png"
	paramTab.defalutFile = GameUtils.getDefalutHeadFileByGender(2)
	local AvatarNode=Avatar:create(paramTab)
	AvatarNode:setPosition(-AvatarNode:getContentSize().width/2,-AvatarNode:getContentSize().height/2)
	head:addChild(AvatarNode)
end

return PlayerNode