-- 小弹窗 显示弹窗信息
-- @date 2017.07.29
-- @author tangwen

local MsgBoxUI = class("MsgBoxUI", function()
	return display.newNode()
end)

local OK_POS = cc.p(150, -133)
local CANCEL_POS = cc.p(-150, -133)
local BTN_CENTER_POS = cc.p(0, -133)
local TITLE_POS = cc.p(0, 185)
local LABEL_POS = cc.p(0, 50)
local LABEL_BIG_POS = cc.p(0, 50)
local LINE_HEIGHT = 40 -- 行间距
local DIMENSIONS_SIZE = cc.size(600,0) --字体总长宽

function MsgBoxUI:ctor()
	local bg = ccui.ImageView:create("common_little_bg.png",ccui.TextureResType.plistType)
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setPosition(0,0)
    bg:setScale9Enabled(true)
    self:addChild(bg)
    self._bg = bg

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

	local okBtn = cc.exports.lib.uidisplay.createLabelButton({
			textureType = ccui.TextureResType.plistType,
			normal = "common_big_blue_btn.png",
			isActionEnabled = true,
			pos = OK_POS,
			text = "确定",
			outlineColor = cc.c4b(24,31,92,255),
			outlineSize = 2,
			labPos = cc.p(0,2),
	})
	self:addChild(okBtn,2)
	self._okBtn = okBtn

	local cancelBtn = cc.exports.lib.uidisplay.createLabelButton({
			textureType = ccui.TextureResType.plistType,
			normal = "common_big_yellow_btn.png",
			isActionEnabled = true,
			pos = CANCEL_POS,
			text = "取消",
			outlineColor = cc.c4b(112,45,2,255),
			outlineSize = 2,
			labPos = cc.p(0,2),
	})
	self:addChild(cancelBtn,2)
	self._cancelBtn = cancelBtn

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

end

return MsgBoxUI