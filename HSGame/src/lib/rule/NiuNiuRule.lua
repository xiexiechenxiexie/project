-- 牛牛游戏数据
-- @author Tangwen
-- @date 2017.7.31

local RuleTitle = {"底        分:","局        数:","算        牛:","授权入座:","支付方式:","翻倍规则:","特殊牌型:"}
local fanbei_text = {"牛牛x4      牛九x3      牛八x2      牛七x2","牛牛x3      牛九x2      牛八x2"}
local special_card_text = {"同花顺(10倍)","炸弹牛(8倍)","葫芦牛(7倍)","同花牛(6倍)","五花牛(5倍)","顺子牛(5倍)"}
local TextColor = cc.c4b(191, 169, 125, 255) --标题颜色
local ValueColor = cc.c4b(255,255,255,255) --数值颜色
local MPQZ_TAG = 1
local ZYQZ_TAG = 2
local NNSZ_TAG = 3
local specialCard_Tag = 100

-- local RuleWindow = require "RuleWindow"

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

function NiuNiuRule:createRuleLayer(tag)
	local layer = cc.Layer:create()

	local listView=ccui.ListView:create()
	listView:setPosition(300,130)
	listView:setTouchEnabled(false)--触摸的属性
    listView:setBounceEnabled(false)--弹回的属性
    listView:setInertiaScrollEnabled(false)--滑动的惯性
    listView:setScrollBarEnabled(false)
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setContentSize(1000,400)
	layer:addChild(listView)

	for i=1,#RuleTitle do
		local item = self:createRuleItem(i,tag)
		if item then
			listView:pushBackCustomItem(item)
		end
	end

	-- local button = cc.exports.lib.uidisplay.createUIButton({
	-- 		textureType = ccui.TextureResType.plistType,
	-- 		normal = "btnNiuniuShangzhuang.png",
	-- 		callback = handler(self,self._onBtnClick),
	-- 		isActionEnabled = true,
	-- 		pos = cc.p(757-260,155)
	-- })
	-- button:setTag(NNSZ_TAG)
	-- layer:addChild(button)
	-- button = cc.exports.lib.uidisplay.createUIButton({
	-- 		textureType = ccui.TextureResType.plistType,
	-- 		normal = "btnZiyouqiangzhuang.png",
	-- 		callback = handler(self,self._onBtnClick),
	-- 		isActionEnabled = true,
	-- 		pos = cc.p(757,155)
	-- })
	-- button:setTag(ZYQZ_TAG)
	-- layer:addChild(button)
	-- button = cc.exports.lib.uidisplay.createUIButton({
	-- 		textureType = ccui.TextureResType.plistType,
	-- 		normal = "btnMingpaiqiangzhuang.png",
	-- 		callback = handler(self,self._onBtnClick),
	-- 		isActionEnabled = true,
	-- 		pos = cc.p(757+260,155)
	-- })
	-- button:setTag(MPQZ_TAG)
	-- layer:addChild(button)

	self.layer = layer

	return layer
end

function NiuNiuRule:createRuleItem(index,tag)
	local item=ccui.Layout:create()
	local itemSize=cc.size(1000,50)
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
		textSize = 20,
		textColor = cc.c4b(255,255,255,255),
		textFont = GameUtils.getFontName(),
		num = self.score,
		maxNum = self._MAX_FLOOR_SCORE,
		minNum = 1,
		dNum = 1
		})
		item:addChild(node)
		node:setPosition(195,25)
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
		textSize = 20,
		textColor = cc.c4b(255,255,255,255),
		textFont = GameUtils.getFontName(),
		num = self.chess,
		maxNum = self._MAX_CHESS_NUM,
		minNum = 10,
		dNum = 10
		})
		item:addChild(node)
		node:setPosition(195,25)
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

	if index == 6 then
		--翻牌规则
		local fanbei_bg = ccui.ImageView:create("rule_kuang.png",ccui.TextureResType.plistType)
		fanbei_bg:setScale(0.8)
		fanbei_bg:setPosition(350,30)
		item:addChild(fanbei_bg)

		local fanbei_str = fanbei_text[self:getfanbeiRule()+1]
		local fanbei_lab = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
																fontSize = 24,
																text = fanbei_str,
																alignment = cc.TEXT_ALIGNMENT_CENTER,
																color = ValueColor,
																pos = cc.p(20,fanbei_bg:getContentSize().height/2),
																anchorPoint = cc.p(0,0.5)}
																)
		fanbei_bg:addChild(fanbei_lab)
		
		local fanbei_btn = ccui.CheckBox:create("xiala_select.png",
												"xiala_select.png",
												"xiala_select.png",
												"xiala_select.png",
												"xiala_select.png",
												ccui.TextureResType.plistType
												)
		fanbei_btn:setPosition(fanbei_bg:getContentSize().width/2,fanbei_bg:getContentSize().height/2)
		fanbei_btn:addClickEventListener(function(sender)self:onXLButtonClickedEvent(sender)end)
		fanbei_bg:addChild(fanbei_btn)

		local fanbei_sp = cc.Sprite:createWithSpriteFrameName("xiala_btn.png")
		fanbei_sp:setPosition(fanbei_bg:getContentSize().width-31,fanbei_bg:getContentSize().height/2-1)
		fanbei_bg:addChild(fanbei_sp)
		self.fanbei_sp = fanbei_sp


		self.fanbei_btn = fanbei_btn
		self.fanbei_lab = fanbei_lab
	end

	if index == 7 then
		--特殊牌型
		local specialCardStr = self:getSpecialCardRule()
		local specialCardTab = string.toTable(specialCardStr)
		for i=1,6 do
			local specialCard_btn = ccui.CheckBox:create("btnRadioBg1.png",
												"btnRadioBg.png",
												"btnRadioBg.png",
												"btnRadioBg1.png",
												"btnRadioBg1.png",
												ccui.TextureResType.plistType
												)
			local post_x = 160 + 200*((i-1)%3)
			local post_y = 30
			if i>3 then
				post_y = -20
			end
			specialCard_btn:setPosition(post_x,post_y)
			specialCard_btn:setTag(specialCard_Tag+i)
			specialCard_btn:addClickEventListener(function(sender)self:onCheckButtonClickedEvent(sender)end)
			item:addChild(specialCard_btn)

			if specialCardTab[i] == "0" then
				specialCard_btn:setSelected(true)
			elseif specialCardTab[i] == "1" then
				specialCard_btn:setSelected(false)
			end

			local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
																fontSize = 24,
																text = special_card_text[i],
																alignment = cc.TEXT_ALIGNMENT_CENTER,
																color = ValueColor,
																pos = cc.p(post_x+20,post_y),
																anchorPoint = cc.p(0,0.5)}
																)
			item:addChild(label)
		end

		if tag == ConstantsData.GameType.TYPE_MINGPAI then
			local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
															fontSize = 24,
															text = "最大抢庄:",
															alignment = cc.TEXT_ALIGNMENT_CENTER,
															color = TextColor,
															pos = cc.p(0,-70),
															anchorPoint = cc.p(0,0.5)}
															)
			item:addChild(label)
			local PosTab = {}
			for i=1,3 do
				local pos_t = {}
				pos_t.x = 160 + 200*(i-1)
				pos_t.y = -70
				table.insert(PosTab,pos_t)
			end
			local maxQZ = self:getMaxQZRule()
			cc.exports.lib.uidisplay.createRadioGroup({
				groupPos = cc.p(0,0),
				parent = item,
				fileSelect = btnRadioSelected,
				fileUnselect = btnRadioBg,
				num = 3,
				textureType = ccui.TextureResType.plistType,
				poses = PosTab,
				selectNum = maxQZ,
				callback = handler(self,self._onMaxQZButtonClickedEvent)
			})

			for i=1,3 do
				local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
																	fontSize = 24,
																	text = i.."倍",
																	alignment = cc.TEXT_ALIGNMENT_CENTER,
																	color = ValueColor,
																	pos = cc.p(PosTab[i].x+20,PosTab[i].y),
																	anchorPoint = cc.p(0,0.5)}
																	)
				item:addChild(label)
			end
			local line = ccui.ImageView:create("imgCreateRoomLine.png",ccui.TextureResType.plistType)
			line:setPosition(450,-95)
			item:addChild(line)
		end
	end

	local line = ccui.ImageView:create("imgCreateRoomLine.png",ccui.TextureResType.plistType)
	line:setPosition(450,5)
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

	if index > 6 then
		line:setPosition(450,-45)
	end

	self.niuniuType = tag

	return item
end

function NiuNiuRule:onXLButtonClickedEvent( sender )
	local status = sender:isSelected()
	if not status then
		self:popFBLayer()
		self.fanbei_sp:initWithSpriteFrameName("shangla_btn.png")
	end
end

function NiuNiuRule:popFBLayer()
	local maskLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 0), display.width, display.height)
    self.layer:addChild(maskLayer)
    local function onTouchBegan(touch, event)
    	return true
    end
    local function onTouchMove(touch, event)
    	return true
    end
    local function onTouchEnd(touch, event)
    	self:closeFBLayer()
    	return true
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:setSwallowTouches(true)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,maskLayer)
    self.listener=listener

    local bg = ccui.ImageView:create("xiala_kuang.png",ccui.TextureResType.plistType)
	bg:setPosition(display.width/2+35,240)
	maskLayer:addChild(bg)

	local x,y = bg:getContentSize().width,bg:getContentSize().height
	local NiuNiuRule=cc.exports.lib.rule.NiuNiuRule:getInstance()
	local fanPaiIndex = NiuNiuRule:getfanbeiRule()

	cc.exports.lib.uidisplay.createRadioGroup({
			groupPos = cc.p(0,0),
			parent = bg,
			fileSelect = "xiala_select.png",
			fileUnselect = "xiala_select.png",
			num = 2,
			textureType = ccui.TextureResType.plistType,
			poses = {cc.p(x/2,y*3/4),cc.p(x/2,y/4)},
			selectNum = fanPaiIndex+1,
			callback = handler(self,self.onFanBeiButtonClickedEvent)
		})

	local fanbei_select_bg = cc.Sprite:createWithSpriteFrameName("btnRadioBg.png")
	fanbei_select_bg:setPosition(30,y*3/4)
	bg:addChild(fanbei_select_bg)

	local fanbei_select_bg = cc.Sprite:createWithSpriteFrameName("btnRadioBg.png")
	fanbei_select_bg:setPosition(30,y/4)
	bg:addChild(fanbei_select_bg)

	local fanbei_lab = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
															fontSize = 24,
															text = fanbei_text[1],
															alignment = cc.TEXT_ALIGNMENT_CENTER,
															color = ValueColor,
															pos = cc.p(60,y*3/4),
															anchorPoint = cc.p(0,0.5)}
															)
	bg:addChild(fanbei_lab)

	local fanbei_lab = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
															fontSize = 24,
															text = fanbei_text[2],
															alignment = cc.TEXT_ALIGNMENT_CENTER,
															color = ValueColor,
															pos = cc.p(60,y/4),
															anchorPoint = cc.p(0,0.5)}
															)
	bg:addChild(fanbei_lab)

	local fanbei_select1 = cc.Sprite:createWithSpriteFrameName("btnRadioSelected.png")
	fanbei_select1:setPosition(30,y*3/4)
	bg:addChild(fanbei_select1)
	
	local fanbei_select2 = cc.Sprite:createWithSpriteFrameName("btnRadioSelected.png")
	fanbei_select2:setPosition(30,y/4)
	bg:addChild(fanbei_select2)

	if fanPaiIndex > 0 then
		fanbei_select1:setVisible(false)
	else
		fanbei_select2:setVisible(false)
	end

	self.fanbei_select1 = fanbei_select1
	self.fanbei_select2 = fanbei_select2

	self.maskLayer = maskLayer
end

function NiuNiuRule:closeFBLayer()
	if self.listener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
	end
	self.maskLayer:removeFromParent()
	self.fanbei_btn:setSelected(false)
	self.fanbei_sp:initWithSpriteFrameName("xiala_btn.png")
end

function NiuNiuRule:onFanBeiButtonClickedEvent(__selectRadioButton,__index,_eventType)
	if __index > 0 then
		self.fanbei_select1:setVisible(false)
		self.fanbei_select2:setVisible(true)
	else
		self.fanbei_select1:setVisible(true)
		self.fanbei_select2:setVisible(false)
	end
	local NiuNiuRule=cc.exports.lib.rule.NiuNiuRule:getInstance()
	NiuNiuRule:setfanbeiRule(__index)
	self.fanbei_lab:setString(fanbei_text[__index+1])
end

function NiuNiuRule:onCheckButtonClickedEvent(sender)
	local status = sender:isSelected()
	local index = sender:getTag() - specialCard_Tag
	local NiuNiuRule=cc.exports.lib.rule.NiuNiuRule:getInstance()
	local specialCardStr = NiuNiuRule:getSpecialCardRule()
	local specialCardTab = string.toTable(specialCardStr)
	if status then
		specialCardTab[index] = "1"
	else
		specialCardTab[index] = "0"
	end
	local str = ""
	for i,v in ipairs(specialCardTab) do
		str = str..v
	end
	self:setSpecialCardRule(str)
end

function NiuNiuRule:_onMaxQZButtonClickedEvent(__selectRadioButton,__index,_eventType)
	self:setMaxQZRule(__index+1)
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

-- function NiuNiuRule:_onBtnClick(sender)
-- 	local index = sender:getTag() - 1
-- 	self.niuniuType = index
-- 	local RuleWindow = RuleWindow:new()
-- 	self.layer:addChild(RuleWindow)
-- end

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