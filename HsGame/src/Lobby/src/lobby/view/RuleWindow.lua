--规则弹窗

local fanbei_text = {"牛牛x4      牛九x3      牛八x2      牛七x2","牛牛x3      牛九x2      牛八x2"}
local TextColor = cc.c4b(235,201,126, 255) --标题颜色
local ValueColor = cc.c4b(255,255,255,255) --数值颜色
local btnRadioBg = "btnRadioBg.png"
local btnRadioSelected = "btnRadioSelected.png"

local RuleWindow = class("RuleWindow", lib.layer.BaseDialog)

function RuleWindow:ctor()
	print("RuleWindow:ctor")
	RuleWindow.super.ctor(self)
	self:initView()
end

-- 初始化试图视图
function RuleWindow:initView()

	-- 弹窗背景
	local ruleBg = ccui.ImageView:create("res/common/denglu_tishi_dikuang.png")
	ruleBg:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2-20))
	self:addChild(ruleBg)

	self:_onRootPanelInit(ruleBg)

	local ruleClose = ccui.Button:create("res/common/denglu_tishi_guanbi.png","res/common/denglu_tishi_guanbi1.png","")
	ruleClose:setPosition(cc.p(ruleBg:getContentSize().width - ruleClose:getContentSize().width/2 - 20, ruleBg:getContentSize().height - ruleClose:getContentSize().height/2 - 20))
	ruleBg:addChild(ruleClose)

	local function callback_Close( ... )
		-- body
		self:onCloseCallback()
	end

	ruleClose:addClickEventListener(callback_Close)

	local x,y = ruleBg:getContentSize().width,ruleBg:getContentSize().height

	local NiuNiuRule=cc.exports.lib.rule.NiuNiuRule:getInstance()
	local type_index = NiuNiuRule:getNiuNiuType()
	local title_str = "imgMingpaiqiangzhuang.png"
	if type_index == 1 then
		title_str = "imgZiyouqiangzhuang.png"
	elseif type_index == 2 then
		title_str = "imgNiuniushangzhuang.png"
	end

	local title_sp = ccui.ImageView:create(title_str,ccui.TextureResType.plistType)
	title_sp:setPosition(x/2,y-55)
	ruleBg:addChild(title_sp)

	local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
															fontSize = 26,
															text = "翻牌规则",
															alignment = cc.TEXT_ALIGNMENT_CENTER,
															color = TextColor,
															pos = cc.p(130,410),
															anchorPoint = cc.p(0,0.5)}
															)
	ruleBg:addChild(label)

	local label = cc.exports.lib.uidisplay.createLabel({fontName = GameUtils.getFontName(),
															fontSize = 26,
															text = "特殊牌型",
															alignment = cc.TEXT_ALIGNMENT_CENTER,
															color = TextColor,
															pos = cc.p(130,310),
															anchorPoint = cc.p(0,0.5)}
															)
	ruleBg:addChild(label)

	local fanbei_bg = ccui.ImageView:create("rule_kuang.png",ccui.TextureResType.plistType)
	fanbei_bg:setPosition(x/2+60,410)
	ruleBg:addChild(fanbei_bg)

	local fanbei_str = fanbei_text[NiuNiuRule:getfanbeiRule()+1]
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
	fanbei_btn:addClickEventListener(function(sender)self:onCheckButtonClickedEvent(sender)end)
	fanbei_bg:addChild(fanbei_btn)

	local fanbei_sp = cc.Sprite:createWithSpriteFrameName("xiala_btn.png")
	fanbei_sp:setPosition(fanbei_bg:getContentSize().width-31,fanbei_bg:getContentSize().height/2-1)
	fanbei_bg:addChild(fanbei_sp)
	self.fanbei_sp = fanbei_sp


	self.fanbei_btn = fanbei_btn
	self.fanbei_lab = fanbei_lab

	local button = cc.exports.lib.uidisplay.createUIButton({
		textureType = ccui.TextureResType.plistType,
		normal = "btnCreateRoomCmd.png",
		callback = handler(self,self._onCreateRoomClick),
		isActionEnabled = true,
		pos = cc.p(x/2,100)
		})
	ruleBg:addChild(button)
end

function RuleWindow:onCheckButtonClickedEvent(sender)
	local status = sender:isSelected()
	if not status then
		self:popFBLayer()
		self.fanbei_sp:initWithSpriteFrameName("shangla_btn.png")
	end
end

function RuleWindow:_onCreateRoomClick()
	local manager = cc.exports.lobby.CreateRoomManager:getInstance()
	local NiuNiuRule=cc.exports.lib.rule.NiuNiuRule:getInstance()
	local data = NiuNiuRule:getCurrRule()
	if not Mall.MallManager.checkNeedGotoMallBuyRoomCard(manager:findNotEnoughRoomCardString(), data.cost) then 
		manager:requestCreateRoom( data,manager:findActGameId(),data.roomNum)	
	end
end

function RuleWindow:popFBLayer()
	local maskLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 0), display.width, display.height)
    self:addChild(maskLayer)
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
	bg:setPosition(display.width/2+60,405)
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

	local fanbei_select_bg = cc.Sprite:createWithSpriteFrameName(btnRadioBg)
	fanbei_select_bg:setPosition(30,y*3/4)
	bg:addChild(fanbei_select_bg)

	local fanbei_select_bg = cc.Sprite:createWithSpriteFrameName(btnRadioBg)
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

	local fanbei_select1 = cc.Sprite:createWithSpriteFrameName(btnRadioSelected)
	fanbei_select1:setPosition(30,y*3/4)
	bg:addChild(fanbei_select1)
	
	local fanbei_select2 = cc.Sprite:createWithSpriteFrameName(btnRadioSelected)
	fanbei_select2:setPosition(30,y/4)
	bg:addChild(fanbei_select2)

	if fanPaiIndex > 0 then
		fanbei_select1:setVisible(false)
	else
		fanbei_select2:setVisible(false)
	end

	self.fanbei_select1 = fanbei_select1
	self.fanbei_select2 = fanbei_select2

	local 
	

	self.maskLayer = maskLayer
end

function RuleWindow:closeFBLayer()
	if self.listener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
	end
	self.maskLayer:removeFromParent()
	self.fanbei_btn:setSelected(false)
	self.fanbei_sp:initWithSpriteFrameName("xiala_btn.png")
end

function RuleWindow:onFanBeiButtonClickedEvent(__selectRadioButton,__index,_eventType)
	print("翻倍翻倍翻倍翻倍翻倍",__index)
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

return RuleWindow