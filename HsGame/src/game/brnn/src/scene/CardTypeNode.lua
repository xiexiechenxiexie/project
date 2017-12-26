-- 牛牛牌型及输赢得分节点

local GameResPath  = "game/brnn/res/GameLayout/"
local conf = require"game/brnn/src/scene/Conf"
local BRNN_NUM_CSB = "game/brnn/res/NiuNiuNumNode.csb"

local Card_Num=5 		--牌数
local Card_Size=0.4 	--牌的大小
local Card_X=20 		--牌的间隔

local CardTypeNode = class("CardTypeNode", cc.Node)

function CardTypeNode:ctor()
    self:preloadUI()
    self.CardArray={}
    self:init()
end

function CardTypeNode:preloadUI()
	local container = cc.CSLoader:createNode(BRNN_NUM_CSB)
	self:addChild(container)
	self.RootNode=container
end

-- 初始化
function CardTypeNode:init()
	--牛一到牛九
	local text_niu_num = self.RootNode:getChildByName("text_niu_num")
	text_niu_num:setVisible(false)
	self.text_niu_num = text_niu_num
	--没牛,炸弹等特殊牌型
	local txt_niu_sp = self.RootNode:getChildByName("txt_niu_sp")
	txt_niu_sp:setVisible(false)
	self.txt_niu_sp = txt_niu_sp
	--没有下注
	local meiyouxiazhu = self.RootNode:getChildByName("meiyouxiazhu")
	meiyouxiazhu:setVisible(false)
	meiyouxiazhu:setFontName(GameUtils.getFontName())
	self.meiyouxiazhu = meiyouxiazhu
	--倍数
	local beishu = self.RootNode:getChildByName("beishu")
	beishu:setVisible(false)
	beishu:setFontName(GameUtils.getFontName())
	self.beishu = beishu
	--得分
	local score = self.RootNode:getChildByName("score")
	score:setFontName(GameUtils.getFontName())
	score:setVisible(false)
	self.score=score

	local node = self.RootNode:getChildByName("effect_node")
	--粒子
    local particle1 = cc.ParticleSystemQuad:create(GameResPath.."particle_niu_type2.plist")
    particle1:setPositionType(cc.POSITION_TYPE_GROUPED)
    node:addChild(particle1)
    particle1:setPosition(0,0)
    particle1:setScale(0.4)
    particle1:stop()
    self.particle1 = particle1
end

--设置倍数
function CardTypeNode:setBeiShu(value)
	local str=tostring(value).."倍"
	self.beishu:setString(str)
end

--设置分数
function CardTypeNode:setScore(value)
	local str=""
	if value>0 then
		self.meiyouxiazhu:setVisible(false)
		self.beishu:setVisible(true)
		self.score:setVisible(true)
		str="+"..conf.switchNum(value)
		self.beishu:setColor(cc.c3b(255,212,120))
		self.score:setColor(cc.c3b(255,212,120))
	elseif value<0 then
		self.meiyouxiazhu:setVisible(false)
		self.beishu:setVisible(true)
		self.score:setVisible(true)
		str=conf.switchNum(value)
		self.beishu:setColor(cc.c3b(112,205,255))
		self.score:setColor(cc.c3b(112,205,255))
	elseif value==0 then
		self.meiyouxiazhu:setVisible(true)
		self.beishu:setVisible(false)
		self.score:setVisible(false)
		self.meiyouxiazhu:setColor(cc.c3b(201,196,255))
	end
	self.score:setString(str)
end

--设置牌型
function CardTypeNode:HideMyResult()
	self.meiyouxiazhu:setVisible(false)
	self.beishu:setVisible(false)
	self.score:setVisible(false)
	self.meiyouxiazhu:setVisible(false)
end

--播放牌型动画 
function CardTypeNode:setNiuType(value,niuniuActionType)
	if niuniuActionType>0 then
		self.particle1:start()
	end
	local str=""
	local scat1=cc.ScaleTo:create(0.2,1.1)
	local scat11=cc.ScaleTo:create(0.2,0.9)
	local scat2=cc.ScaleTo:create(0.15,0.95)
	local scat22=cc.ScaleTo:create(0.1,1.05)
	local scat3=cc.ScaleTo:create(0.1,1.0)
	local seq1=cc.Sequence:create(scat1,scat11,scat3)
	local seq2=cc.Sequence:create(scat2,scat22,scat3)
	if value==0 then
		self.text_niu_num:setVisible(false)
		self.txt_niu_sp:setVisible(true)
		self.txt_niu_sp:setTexture(GameResPath.."txt_niunum0.png")
		if niuniuActionType>0 then
			self.txt_niu_sp:stopAllActions()
			self.txt_niu_sp:setScale(5)
			self.txt_niu_sp:runAction(seq2)
		else
			self.txt_niu_sp:stopAllActions()
			self.txt_niu_sp:setScale(0)
			self.txt_niu_sp:runAction(seq1)
		end
	elseif value>0 and value<=9 then
		self.text_niu_num:setVisible(true)
		self.txt_niu_sp:setVisible(false)
		if value==1 then
			self.text_niu_num:setString("./")
		else
			self.text_niu_num:setString("."..tostring(value-2))
		end
		if niuniuActionType>0 then
			self.text_niu_num:stopAllActions()
			self.text_niu_num:setScale(5)
			self.text_niu_num:runAction(seq2)
		else
			self.text_niu_num:stopAllActions()
			self.text_niu_num:setScale(0)
			self.text_niu_num:runAction(seq1)
		end
	elseif value>9 then
		self.text_niu_num:setVisible(false)
		self.txt_niu_sp:setVisible(true)
		local str=GameResPath.."txt_niunum"..tostring(value..".png")
		self.txt_niu_sp:setTexture(str)
		if niuniuActionType>0 then
			self.txt_niu_sp:stopAllActions()
			self.txt_niu_sp:setScale(5)
			self.txt_niu_sp:runAction(seq2)
		else
			self.txt_niu_sp:stopAllActions()
			self.txt_niu_sp:setScale(0)
			self.txt_niu_sp:runAction(seq1)
		end
	end
end

-------------------------------------------------断线重连的一些接口-------------------------------------------------
function CardTypeNode:setNiuTypeScene(value)
	if value==0 then
		self.text_niu_num:setVisible(false)
		self.txt_niu_sp:setVisible(true)
		self.txt_niu_sp:setTexture(GameResPath.."txt_niunum0.png")
	elseif value>0 and value<=9 then
		self.text_niu_num:setVisible(true)
		self.txt_niu_sp:setVisible(false)
		if value==1 then
			self.text_niu_num:setString("./")
		else
			self.text_niu_num:setString("."..tostring(value-2))
		end
	elseif value>9 then
		self.text_niu_num:setVisible(false)
		self.txt_niu_sp:setVisible(true)
		local str=GameResPath.."txt_niunum"..tostring(value..".png")
		self.txt_niu_sp:setTexture(str)
	end
end
-------------------------------------------------断线重连的一些接口-------------------------------------------------

return CardTypeNode