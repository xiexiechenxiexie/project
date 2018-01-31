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

local okFile = "common_btn_sure.png"
local cancelFile = "common_btn_cancel.png"
local resType = ccui.TextureResType.plistType
function MessageBox:ctor( __params )

	MessageBox.super.ctor(self,lib.layer.Window.SMALL)

	self._okCallback = __params.okFunc
	self._cancelCallback = __params.cancelFunc
	local size = self._root:getContentSize()

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
		btn:setPosition(size.width * 0.25 ,size.height * 0.25)
		btn:setPressedActionEnabled(true)
		btn:addClickEventListener(handler(self,self._onCancel))
		local btn = ccui.Button:create(okFileName  , okFileName,okFileName,resType)
		self._root:addChild(btn)
		btn:setPosition(size.width * 0.75 ,size.height * 0.25)
		btn:setPressedActionEnabled(true)
		btn:addClickEventListener(handler(self,self._onOk))
	else
		local btn = ccui.Button:create(okFileName  , okFileName,okFileName,resType)
		self._root:addChild(btn)
		btn:setPosition(size.width * 0.75 ,size.height * 0.25)
		btn:setPressedActionEnabled(true)
		btn:addClickEventListener(handler(self,self._onOk))
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