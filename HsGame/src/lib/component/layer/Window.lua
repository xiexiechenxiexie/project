--[[--
window 类 初始化了 地板以及关闭按钮  子类只需要关心地板uI以及其他交互内容即可
]]

local Window = class("Window",lib.layer.BaseWindow)

Window.BIG = 1
Window.MIDDLE = 2
Window.SMALL = 3

local exitImgInfo = {path = "common_bg_exitImg.png",textureResType = ccui.TextureResType.plistType,dPos = {dxFromRight = 85,dyFromTop = 50}}
local btnCloseInfo = {path = "src/Lobby/res/common/common_btn_close.png",textureResType = ccui.TextureResType.localType,dPos = {dxFromRight = 45,dyFromTop = 40}}

local WindowDict = {
	[Window.BIG] = {size = {width = 1060,height = 640},imgBg = "common_big_bg.png",textureResType = ccui.TextureResType.plistType,capInsets = cc.rect(100,135,8,8),exitImgInfo = exitImgInfo,btnCloseInfo = btnCloseInfo},
	[Window.MIDDLE] = {size = {width = 940,height = 560},imgBg = "common_mid_bg.png",textureResType = ccui.TextureResType.plistType,capInsets = cc.rect(100,135,8,8),exitImgInfo = exitImgInfo,btnCloseInfo = btnCloseInfo},
	[Window.SMALL] = {size = {width = 720,height = 410},imgBg = "common_little_bg.png",textureResType = ccui.TextureResType.plistType,capInsets = cc.rect(100,135,8,8),exitImgInfo = exitImgInfo,btnCloseInfo = btnCloseInfo},
}


function Window:ctor( __type )
	__type = __type or Window.BIG
	Window.super.ctor(self,__type)
	local info = WindowDict[__type]
	local imgBg = nil
	if info.textureResType == ccui.TextureResType.plistType then
		imgBg = ccui.Scale9Sprite:createWithSpriteFrameName(info.imgBg,info.capInsets)
	else
		imgBg = ccui.Scale9Sprite:create(info.capInsets,info.imgBg)
	end
	assert(imgBg,"error invalid imgBg file , or create error ")
	
	imgBg:setContentSize(info.size)
	self:addChild(imgBg)
	imgBg:setPosition(display.width / 2,display.height / 2)
	self._root = imgBg

	local btnCloseInfo = info.btnCloseInfo
	if not btnCloseInfo then return  end
	local btnClose =  ccui.Button:create(btnCloseInfo.path,btnCloseInfo.path,btnCloseInfo.path,btnCloseInfo.textureResType)
	self._root:addChild(btnClose)
	btnClose:setPosition(info.size.width -  btnCloseInfo.dPos.dxFromRight,info.size.height -  btnCloseInfo.dPos.dyFromTop)
	btnClose:setPressedActionEnabled(false)
	btnClose:addClickEventListener(handler(self,self.onCloseCallback))

	local exitImgInfo = info.exitImgInfo
	if not exitImgInfo then return  end
	local exitImg  = ccui.ImageView:create(exitImgInfo.path,exitImgInfo.textureResType)
	self._root:addChild(exitImg)
	exitImg:setPosition(info.size.width -  exitImgInfo.dPos.dxFromRight,info.size.height -  exitImgInfo.dPos.dyFromTop)
end

cc.exports.lib.layer.Window = Window