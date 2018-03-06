--规则弹窗


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

	self.ruleBg = ruleBg
end

function RuleWindow:ruleData()
	
end

return RuleWindow