-- 牛牛游戏数据
-- @author Tangwen
-- @date 2017.7.31

local RuleTitle = {"底        分:","局        数:","算        牛:","授权入座:","支付方式:"}
local TextColor = cc.c4b(191, 169, 125, 255) --标题颜色
local ValueColor = cc.c4b(255,255,255,255) --数值颜色
local MPQZ_TAG = 1
local ZYQZ_TAG = 2
local NNSZ_TAG = 3

local RuleWindow = require "RuleWindow"

local NiuNiuRule = class("NiuNiuRule")

function NiuNiuRule:ctor()
	self.GameID = 1   	     	-- 游戏的ID号 唯一标识号
	self.score = 1 --底分
	self.chess = 10 --局数
	self.isAutoNiu = 0 --是否自动算牛
	self.isOpenRightToSeat = 0 --是否开启授权入座
	self.isCostToSeat = 0 --是否开启收费入座
	self.niuniuType = 0 --牛牛牌型 默认明牌抢庄(0明牌抢庄1自由抢庄2牛牛抢庄)
	self.fanbeiRule = 0 --牛牛翻倍规则 默认牛牛4倍，牛九3倍，牛七牛八2倍
	self.specialCard = "111111" --牛牛翻倍规则 默认牛牛4倍，牛九3倍，牛七牛八2倍
	self.maxQZ = 1 
	self.cost = 3 --房卡消耗
	self.roomNum = 5

	self._MAX_FLOOR_SCORE = 10 --最大底分
	self._MAX_CHESS_NUM = 100 --最大局数
end

--算牛方法   游戏底分  授权入座 收费入座
function NiuNiuRule:createRule()
	local maxQZ = 0
	if self.niuniuType == 0 then
		maxQZ = self.maxQZ
	end
	local rule = ""..self.isAutoNiu..(self.score-1)..self.isOpenRightToSeat..self.isCostToSeat..self.niuniuType..self.fanbeiRule..self.specialCard..maxQZ
	return rule
end

function NiuNiuRule:parseRule( __str )
	assert(__str and type(__str) == "string" and  __str ~= "" ,"invalid params")
	local data = {}
	local i = 1
	data.AccountType = tonumber(string.sub(__str,i ,i))
	i = i + 1
	data.GameBet =  tonumber(string.sub(__str,i ,i )) + 1 
	i = i + 1
	data.AuthorizeSit  =  tonumber(string.sub(__str,i ,i))
	i = i + 1
	data.ChargeSit  =  tonumber(string.sub(__str,i ,i))
	i = i + 1
	data.niuniuType  =  tonumber(string.sub(__str,i ,i))
	i = i + 1
	data.fanbeiRule  =  tonumber(string.sub(__str,i ,i))
	i = i + 1
	data.SpecialCard = string.sub(__str,i ,i + 5)
	i = i + 6
	data.maxQZ = tonumber(string.sub(__str,i ,i))
	return data
end

function NiuNiuRule:isOpen( __value )
	return __value == 1
end

function NiuNiuRule:createRuleLayer()
	local layer = cc.Layer:create()

	local listView=ccui.ListView:create()
	listView:setPosition(300,170)
	listView:setTouchEnabled(false)--触摸的属性
    listView:setBounceEnabled(false)--弹回的属性
    listView:setInertiaScrollEnabled(false)--滑动的惯性
    listView:setScrollBarEnabled(false)
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setContentSize(1000,360)
	layer:addChild(listView)

	for i=1,#RuleTitle do
		local item = self:createRuleItem(i)
		if item then
			listView:pushBackCustomItem(item)
		end
	end

	local button = cc.exports.lib.uidisplay.createUIButton({
			textureType = ccui.TextureResType.plistType,
			normal = "btnNiuniuShangzhuang.png",
			callback = handler(self,self._onBtnClick),
			isActionEnabled = true,
			pos = cc.p(757-260,155)
	})
	button:setTag(NNSZ_TAG)
	layer:addChild(button)
	button = cc.exports.lib.uidisplay.createUIButton({
			textureType = ccui.TextureResType.plistType,
			normal = "btnZiyouqiangzhuang.png",
			callback = handler(self,self._onBtnClick),
			isActionEnabled = true,
			pos = cc.p(757,155)
	})
	button:setTag(ZYQZ_TAG)
	layer:addChild(button)
	button = cc.exports.lib.uidisplay.createUIButton({
			textureType = ccui.TextureResType.plistType,
			normal = "btnMingpaiqiangzhuang.png",
			callback = handler(self,self._onBtnClick),
			isActionEnabled = true,
			pos = cc.p(757+260,155)
	})
	button:setTag(MPQZ_TAG)
	layer:addChild(button)

	self.layer = layer

	return layer
end

function NiuNiuRule:createRuleItem(index)
	local item=ccui.Layout:create()
	local itemSize=cc.size(1000,75)
	item:setContentSize(itemSize)

	--底分
	if index == 1 then
		local node = cc.exports.lib.uidisplay.createAddMinusNode({
		imgBg = "imgAddMinus.png",
		callback = handler(self,self._onAddMinsScoreClick),
		imgMinus = "btnMinus.png",
		imgMinusPrssed = "btnMinus.png",
		imgMinusDisabled = "btnMinus.png",
		imgMinusSize = cc.size(53,53),
		imgAdd = "btnAdd.png",
		imgAddPrssed = "btnAdd.png",
		imgAddDisabled = "btnAdd.png",
		imgAddSize = cc.size(53,53),
		textureType = ccui.TextureResType.plistType,
		textSize = 30,
		textColor = cc.c4b(255,255,255,255),
		textFont = GameUtils.getFontName(),
		num = self.score,
		maxNum = self._MAX_FLOOR_SCORE,
		minNum = 1,
		dNum = 1
		})
		item:addChild(node)
		node:setPosition(220,30)
	end
	--局数
	if index == 2 then
		local node = cc.exports.lib.uidisplay.createAddMinusNode({
		imgBg = "imgAddMinus.png",
		callback = handler(self,self._onAddMinsChessClick),
		imgMinus = "btnMinus.png",
		imgMinusPrssed = "btnMinus.png",
		imgMinusDisabled = "btnMinus.png",
		imgMinusSize = cc.size(53,53),
		imgAdd = "btnAdd.png",
		imgAddPrssed = "btnAdd.png",
		imgAddDisabled = "btnAdd.png",
		imgAddSize = cc.size(53,53),
		textureType = ccui.TextureResType.plistType,
		textSize = 30,
		textColor = cc.c4b(255,255,255,255),
		textFont = GameUtils.getFontName(),
		num = self.chess,
		maxNum = self._MAX_CHESS_NUM,
		minNum = 10,
		dNum = 10
		})
		item:addChild(node)
		node:setPosition(220,30)
	end

	local btnRadioBg = "btnRadioBg.png"
	local btnRadioSelected =  "btnRadioSelected.png"
	--自动还是手动算牛
	if index == 3 then
		cc.exports.lib.uidisplay.createRadioGroup({
			groupPos = cc.p(160,30),
			parent = item,
			fileSelect = btnRadioSelected,
			fileUnselect = btnRadioBg,
			num = 2,
			textureType = ccui.TextureResType.plistType,
			poses = {cc.p(160,30),cc.p(380,30)},
			callback = handler(self,self._onCalculateRadioGroupClick)
		})

		local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
														fontSize = 24,
														text = "自动算牛",
														alignment = cc.TEXT_ALIGNMENT_CENTER,
														color = ValueColor,
														pos = cc.p(180,30),
														anchorPoint = cc.p(0,0.5)}
														)
		item:addChild(label)

		local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
															fontSize = 24,
															text = "手动算牛",
															alignment = cc.TEXT_ALIGNMENT_CENTER,
															color = ValueColor,
															pos = cc.p(400,30),
															anchorPoint = cc.p(0,0.5)}
															)
		item:addChild(label)
	end

	if index == 4 then
		local isGrantAuthorizationShow = cc.exports.lobby.CreateRoomManager:getInstance():isGrantAuthorizationShow()
		if isGrantAuthorizationShow then
			cc.exports.lib.uidisplay.createRadioGroup({
				groupPos = cc.p(160,30),
				parent = item,
				fileSelect = btnRadioSelected,
				fileUnselect = btnRadioBg,
				num = 2,
				textureType = ccui.TextureResType.plistType,
				poses = {cc.p(160,30),cc.p(380,30)},
				callback = handler(self,self._onOpenClosedRadioGroupClick)
				})

			local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
															fontSize = 24,
															text = "关闭",
															alignment = cc.TEXT_ALIGNMENT_CENTER,
															color = ValueColor,
															pos = cc.p(180,30),
															anchorPoint = cc.p(0,0.5)}
															)
			item:addChild(label)

			local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
																fontSize = 24,
																text = "开启",
																alignment = cc.TEXT_ALIGNMENT_CENTER,
																color = ValueColor,
																pos = cc.p(400,30),
																anchorPoint = cc.p(0,0.5)}
																)
			item:addChild(label)
		else
			return nil
		end
	end
	
	if index == 5 then
		local isCostSitSelectionShow = cc.exports.lobby.CreateRoomManager:getInstance():isCostSitSelectionShow()
		if isCostSitSelectionShow then
			cc.exports.lib.uidisplay.createRadioGroup({
				groupPos = cc.p(160,30),
				parent = item,
				fileSelect = btnRadioSelected,
				fileUnselect = btnRadioBg,
				num = 2,
				textureType = ccui.TextureResType.plistType,
				poses = {cc.p(160,30),cc.p(380,30)},
				callback = handler(self,self._onYesNoRadioGroupClick)
				})

			local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
															fontSize = 24,
															text = "AA支付",
															alignment = cc.TEXT_ALIGNMENT_CENTER,
															color = ValueColor,
															pos = cc.p(180,30),
															anchorPoint = cc.p(0,0.5)}
															)
			item:addChild(label)

			local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
																fontSize = 24,
																text = "房主支付",
																alignment = cc.TEXT_ALIGNMENT_CENTER,
																color = ValueColor,
																pos = cc.p(400,30),
																anchorPoint = cc.p(0,0.5)}
																)
			item:addChild(label)
		else
			return nil
		end
	end

	local line = ccui.ImageView:create("imgCreateRoomLine.png",ccui.TextureResType.plistType)
	line:setPosition(450,0)
	item:addChild(line)

	local titleLabel = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
														fontSize = 24,
														text = RuleTitle[index],
														alignment = cc.TEXT_ALIGNMENT_CENTER,
														color = TextColor,
														pos = cc.p(0,30),
														anchorPoint = cc.p(0,0.5)}
														)
	item:addChild(titleLabel)

	return item
end

--底分
function NiuNiuRule:_onAddMinsScoreClick( __num,__label)
	self.score = __num
end

--局数
function NiuNiuRule:_onAddMinsChessClick(__num,__label)
	self.chess = __num
	local manager = cc.exports.lobby.CreateRoomManager:getInstance()
	local cardCost = manager:findRoomCardCost(__num)
	self.cost = cardCost
end

--自动还是手动算牛
function NiuNiuRule:_onCalculateRadioGroupClick(__selectRadioButton,__index,_eventType)
	self.isAutoNiu = __index
end

--授权入座
function NiuNiuRule:_onOpenClosedRadioGroupClick(__selectRadioButton,__index,_eventType)
	self.isOpenRightToSeat = __index
end

--支付方式
function NiuNiuRule:_onYesNoRadioGroupClick(__selectRadioButton,__index,_eventType)
	self.isCostToSeat = __index
end

function NiuNiuRule:_onBtnClick(sender)
	local index = sender:getTag() - 1
	self.niuniuType = index
	local RuleWindow = RuleWindow:new()
	self.layer:addChild(RuleWindow)
end

function NiuNiuRule:getCurrRule()
	local data = {}
	data.score = self.score
	data.chess = self.chess
	data.isAutoNiu = self.isAutoNiu
	data.isOpenRightToSeat = self.isOpenRightToSeat
	data.isCostToSeat = self.isCostToSeat
	data.cost = self.cost
	data.roomNum = self.roomNum

	return data
end

function NiuNiuRule:getNiuNiuType()
	return self.niuniuType
end

function NiuNiuRule:setfanbeiRule(fanbeiRule)
	self.fanbeiRule = fanbeiRule
end

function NiuNiuRule:getfanbeiRule()
	return self.fanbeiRule
end

function NiuNiuRule:setSpecialCardRule(SpecialCard)
	self.specialCard = SpecialCard
end

function NiuNiuRule:getSpecialCardRule()
	return self.specialCard
end

function NiuNiuRule:setMaxQZRule(maxQZ)
	self.maxQZ = maxQZ
end

function NiuNiuRule:getMaxQZRule()
	return self.maxQZ
end


cc.exports.lib.singleInstance:bind(NiuNiuRule)

cc.exports.lib.rule.NiuNiuRule = NiuNiuRule

return NiuNiuRule