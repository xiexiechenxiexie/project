-- 小弹窗 显示弹窗信息
-- @date 2017.07.29
-- @author tangwen

local MsgBoxUI = class("MsgBoxUI", function()
	return display.newNode()
end)

local OK_POS = cc.p(150, -133)
local CANCEL_POS = cc.p(-150, -133)
local CLOSE_POS = cc.p(249,171.5)
local BTN_CENTER_POS = cc.p(0, -133)
local TITLE_POS = cc.p(0, 185)
local LABEL_POS = cc.p(0, 20)
local LABEL_BIG_POS = cc.p(0, 50)
local LINE_HEIGHT = 40 -- 行间距
local DIMENSIONS_SIZE = cc.size(600,0) --字体总长宽

function MsgBoxUI:ctor()
	local bg = ccui.ImageView:create("common_msgbox_bg.png",ccui.TextureResType.plistType)
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setPosition(0,0)
    bg:setScale9Enabled(true)
    self:addChild(bg)
    self._bg = bg

    local title = ccui.ImageView:create("common_exit_title.png",ccui.TextureResType.plistType)
    title:setAnchorPoint(cc.p(0.5, 0.5))
    title:setPosition(bg:getContentSize().width/2,bg:getContentSize().height-55)
    bg:addChild(title)

    local label = cc.Label:createWithTTF("",GameUtils.getFontName(),30,DIMENSIONS_SIZE)
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setPosition(LABEL_POS)
    label:setColor(cc.c3b(255,255,255))
    label:setHorizontalAlignment(kCCTextAlignmentCenter)
    self:addChild(label,1)
    self._label = label
    self._label:hide()

    local bigLabel = cc.Label:createWithTTF("",GameUtils.getFontName(),25,DIMENSIONS_SIZE)
    bigLabel:setAnchorPoint(cc.p(0.5, 0.5))
    bigLabel:setPosition(LABEL_BIG_POS)
    bigLabel:setColor(cc.c3b(255,255,255))
    bigLabel:setLineHeight(LINE_HEIGHT)
    bigLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
    self:addChild(bigLabel,1)
    self._bigLabel = bigLabel
    self._bigLabel:hide()

    local okImg = "common_btn_sure.png"
    local okBtn  = ccui.Button:create(okImg, okImg, okImg, ccui.TextureResType.plistType)
	okBtn:setPosition(OK_POS)
	okBtn:setPressedActionEnabled(true)
	self:addChild(okBtn,2)
	self._okBtn = okBtn

	local cancelImg = "common_btn_cancel.png"
	local cancelBtn = ccui.Button:create(cancelImg, cancelImg, cancelImg, ccui.TextureResType.plistType)
	cancelBtn:setPosition(CANCEL_POS)
	cancelBtn:setPressedActionEnabled(true)
	self:addChild(cancelBtn,2)
	self._cancelBtn = cancelBtn

	local closeImg = "common/common_btn_close.png"
	local closeImg1 = "common/common_btn_close1.png"
	local closeBtn = ccui.Button:create(closeImg, closeImg1, "")
	closeBtn:setPosition(CLOSE_POS)
	self:addChild(closeBtn,2)
	self.closeBtn = closeBtn

end

function MsgBoxUI:showMsgBox(__params)
	local msg = string.gsub(__params.msg, "\\n", function(s) return "\n" end)   
	local showType =  __params.type or ConstantsData.ShowMgsBoxType.NORMAL_TYPE
	if showType == ConstantsData.ShowMgsBoxType.NORMAL_TYPE then 
		self._label:setString(msg)
		self._label:show()
	else
		self._bigLabel:setString(msg)
		self._bigLabel:show()
	end

		-- 按钮
	local btns = __params.btn or {"ok"}
	local callback = __params.callback
	self._okBtn:hide()
	self._cancelBtn:hide()
	if #btns >= 2 then
		self._okBtn:setPosition(OK_POS)
		self._cancelBtn:setPosition(CANCEL_POS)
	else
		self._okBtn:setPosition(BTN_CENTER_POS)
		self._cancelBtn:setPosition(BTN_CENTER_POS)
	end
	for i=1, #btns do
		if btns[i] == "ok" then
			self._okBtn:show()
		elseif btns[i] == "cancel" then
			self._cancelBtn:show()
		end
	end

	-- 回调
	self._okBtn:addClickEventListener(function()
		local result = true
		if callback then
			result = callback("ok")
		end
		if result then
			GameUtils.hideMsgBox()
		end
	end)
	self._cancelBtn:addClickEventListener(function()
		local result = true
		if callback then
			result = callback("cancel")
		end
		if result then
			GameUtils.hideMsgBox()
		end
	end)
	self.closeBtn:addClickEventListener(function()
		local result = true
		if callback then
			result = callback("cancel")
		end
		if result then
			GameUtils.hideMsgBox()
		end
	end)

end

return MsgBoxUI