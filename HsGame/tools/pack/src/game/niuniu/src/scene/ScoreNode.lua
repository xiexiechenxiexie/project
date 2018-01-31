--------------------------------------------------
-- 分数节点
----------------------------------------------------

local GameResPath  = "game/niuniu/res/GameLayout/NiuNiu/"
local ScoreNode = class("ScoreNode", cc.Node)
local conf = require "game/niuniu/src/scene/conf"


function ScoreNode:ctor(id,str)
    self:init(id,str)
end

function ScoreNode:init(id,str)
	if str==nil then
		print("传入参数错误")
		return 
	end
	local strFile = nil
	local scoreNode = nil
	local scoreBg = nil
	if tonumber(str) < 0 then
		strFile=GameResPath.."score_num_shu.png"
		scoreBg = cc.Sprite:create(GameResPath.."score_num_shu_bg.png")
	else
		strFile=GameResPath.."score_num_add.png"
		scoreBg = cc.Sprite:create(GameResPath.."score_num_add_bg.png")
	end
	scoreNode = ccui.TextAtlas:create(str,strFile,36,43,"/")
	scoreNode:setPosition(scoreBg:getContentSize().width/2,scoreBg:getContentSize().height/2)
	scoreBg:addChild(scoreNode)
	scoreNode:setString("/"..str)
	scoreBg:setPosition(0,0)
	scoreBg:setScale(0.7)
	local node = cc.Node:create()
	node:setPosition(conf.popPosArray[id])
	node:addChild(scoreBg)
	self.node = node
	self.scoreBg = scoreBg
	self:addChild(node)

	self:scoreAct()
end

function ScoreNode:scoreAct()
	local a = {}
	a[#a+1] = cc.MoveBy:create(0.2,cc.p(0,60))
	a[#a+1] = cc.DelayTime:create(1)
	a[#a+1] = cc.CallFunc:create(function () self.node:hide() end)
	self.node:runAction(cc.Sequence:create(a))
end

return ScoreNode