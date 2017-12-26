local  MessageBox = class("MessageBox",lib.layer.Window)

MessageBox.TYPE_CONFIG = 1
MessageBox.TYPE_SELECT = 2
--[[--
__params = {
content = "content",
okFunc = function,
cancelFunc  =function ,
title = "",
showType = MessageBox.TYPE_CONFIG or MessageBox.TYPE_SELECT,
resType = ccui.TextureResType.localType or ccui.TextureResType.plistType,
okFile = ,
cancelFile ,
}
]]

local okFile = "common_small_blue_btn.png"
local cancelFile = "common_small_yellow_btn.png"
local resType = ccui.TextureResType.plistType
function MessageBox:ctor( __params )

	MessageBox.super.ctor(self,lib.layer.Window.SMALL)

	self._okCallback = __params.okFunc
	self._cancelCallback = __params.cancelFunc
	local size = self._root:getContentSize()

	local okText = __params.okText or "确定"
	local cancelText = __params.cancelText or "取消"
	local okOutlineColor = __params.okOutlineColor or cc.c4b(255,255,255, 255)
	local cancelOutlineColor = __params.cancelOutlineColor or cc.c4b(255,255,255, 255)
	local okOutlineSize  = __params.okOutlineSize or -1
	local cancelOutlineSize  = __params.cancelOutlineSize or -1
	local okPos = __params.okPos or cc.p(0,0)
	local cancelPos = __params.cancelPos or cc.p(0,0)
	local alignment = cc.TEXT_ALIGNMENT_CENTER
	local ttfConfig = {}
	ttfConfig.fontFilePath= GameUtils.getFontName()
	ttfConfig.fontSize = __params.fontSize or 36

	if __params.title then 
		local tipLabel = cc.Label:createWithTTF(__params.title,GameUtils.getFontName(),26,cc.size(size.width * 0.8,0),kCCTextAlignmentCenter)
	    tipLabel:setPosition(size.width * 0.5,size.height * 0.85)
	    self._root:addChild(tipLabel)
	end

	local tipLabel = cc.Label:createWithTTF(__params.content or "",GameUtils.getFontName(),25,cc.size(size.width * 0.8,0),kCCTextAlignmentCenter)
    tipLabel:setPosition(size.width * 0.5,size.height * 0.65)
    self._root:addChild(tipLabel)
    local okFileName = __params.okFile or okFile
    local cancelFile = __params.cancelFile or cancelFile
    local resType = __params.resType or resType
    if MessageBox.TYPE_SELECT then 
	    local btn =  ccui.Button:create(cancelFile  , cancelFile,cancelFile,resType)
		self._root:addChild(btn)
		btn:setPosition(size.width * 0.30 ,size.height * 0.25)
		btn:setPressedActionEnabled(true)
		btn:addClickEventListener(handler(self,self._onCancel))

		local label = cc.Label:createWithTTF(ttfConfig, cancelText, alignment)
		label:setPosition(btn:getContentSize().width/2+cancelPos.x,btn:getContentSize().height/2+cancelPos.y)
		label:enableOutline(cancelOutlineColor,cancelOutlineSize)
		btn:addChild(label)

		local btn = ccui.Button:create(okFileName  , okFileName,okFileName,resType)
		self._root:addChild(btn)
		btn:setPosition(size.width * 0.70 ,size.height * 0.25)
		btn:setPressedActionEnabled(true)
		btn:addClickEventListener(handler(self,self._onOk))

		local label = cc.Label:createWithTTF(ttfConfig, okText, alignment)
		label:setPosition(btn:getContentSize().width/2+okPos.x,btn:getContentSize().height/2+okPos.y)
		label:enableOutline(okOutlineColor,okOutlineSize)
		btn:addChild(label)
	else
		local btn = ccui.Button:create(okFileName  , okFileName,okFileName,resType)
		self._root:addChild(btn)
		btn:setPosition(size.width * 0.50 ,size.height * 0.25)
		btn:setPressedActionEnabled(true)
		btn:addClickEventListener(handler(self,self._onOk))

		local label = cc.Label:createWithTTF(ttfConfig, okText, alignment)
		label:setPosition(btn:getContentSize().width/2+okPos.x,btn:getContentSize().height/2+okPos.y)
		label:enableOutline(cancelOutlineColor,cancelOutlineSize)
		btn:addChild(label)
    end


end


function MessageBox:_onOk( ... )

	if self._okCallback then self._okCallback() end
	self:onCloseCallback()
end

function MessageBox:_onCancel( ... )
	if self.cancelFunc then self.cancelFunc() end
	self:onCloseCallback()
end

function MessageBox.showMsgBox( __params )
	local node = lib.layer.MessageBox.new(__params)
	cc.Director:getInstance():getRunningScene():addChild(node)
end

cc.exports.lib = cc.exports.lib or {}
cc.exports.lib.layer = cc.exports.lib.layer or {}
cc.exports.lib.layer.MessageBox = MessageBox