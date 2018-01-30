--[[--
window 类 初始化了 地板以及关闭按钮  子类只需要关心地板uI以及其他交互内容即可
]]

local Window = class("Window",lib.layer.BaseWindow)

Window.BIG = 1
Window.MIDDLE = 2
Window.SMALL = 3
Window.SERVICE = 4
Window.TASK = 5
Window.SIGN = 6
Window.PAY = 7

-- local exitImgInfo = {path = "common_bg_exitImg.png",textureResType = ccui.TextureResType.plistType,dPos = {dxFromRight = 85,dyFromTop = 50}}
local btnCloseInfo = {path = "src/Lobby/res/common/common_btn_close.png",path1 = "src/Lobby/res/common/common_btn_close1.png",textureResType = ccui.TextureResType.localType,dPos = {dxFromRight = 112,dyFromTop = 57}}

local WindowDict = {
	[Window.BIG] = {size = {width = 1091,height = 683},imgBg = "common_big_bg.png",textureResType = ccui.TextureResType.plistType,exitImgInfo = exitImgInfo,btnCloseInfo = btnCloseInfo},
	[Window.MIDDLE] = {size = {width = 903,height = 568},imgBg = "common_mid_bg.png",textureResType = ccui.TextureResType.plistType,exitImgInfo = exitImgInfo,btnCloseInfo = btnCloseInfo},
	[Window.SMALL] = {size = {width = 721,height = 457},imgBg = "common_msgbox_bg.png",textureResType = ccui.TextureResType.plistType,exitImgInfo = exitImgInfo,btnCloseInfo = btnCloseInfo},
	[Window.SERVICE] = {size = {width = 1091,height = 683},imgBg = "lobby_service_bg.png",textureResType = ccui.TextureResType.plistType,exitImgInfo = exitImgInfo,btnCloseInfo = btnCloseInfo},
	[Window.TASK] = {size = {width = 1091,height = 683},imgBg = "lobby_task_bg.png",textureResType = ccui.TextureResType.plistType,exitImgInfo = exitImgInfo,btnCloseInfo = btnCloseInfo},
	[Window.SIGN] = {size = {width = 1091,height = 692},imgBg = "lobby_sign_bg.png",textureResType = ccui.TextureResType.plistType,exitImgInfo = exitImgInfo,btnCloseInfo = btnCloseInfo},
	[Window.PAY] = {size = {width = 903,height = 568},imgBg = "shop_pay_bg.png",textureResType = ccui.TextureResType.plistType,exitImgInfo = exitImgInfo,btnCloseInfo = btnCloseInfo},
}


function Window:ctor( __type )
	__type = __type or Window.BIG
	Window.super.ctor(self,__type)
	local info = WindowDict[__type]
	local imgBg = nil
	if info.textureResType == ccui.TextureResType.plistType then
		imgBg = ccui.ImageView:create(info.imgBg,info.textureResType)
	else
		imgBg = ccui.ImageView:create(info.imgBg,info.textureResType)
	end
	assert(imgBg,"error invalid imgBg file , or create error ")
	
	imgBg:setContentSize(info.size)
	self:addChild(imgBg)
	imgBg:setPosition(display.width / 2,display.height / 2)
	self._root = imgBg

	local btnCloseInfo = info.btnCloseInfo
	if not btnCloseInfo then return  end
	local btnClose =  ccui.Button:create(btnCloseInfo.path,btnCloseInfo.path1,"",btnCloseInfo.textureResType)
	self._root:addChild(btnClose)
	btnClose:setPosition(info.size.width -  btnCloseInfo.dPos.dxFromRight,info.size.height -  btnCloseInfo.dPos.dyFromTop)
	-- btnClose:setPressedActionEnabled(false)
	btnClose:addClickEventListener(handler(self,self.onCloseCallback))
	if __type == Window.SIGN then
		btnClose:setPosition(info.size.width -  btnCloseInfo.dPos.dxFromRight+1,info.size.height -  btnCloseInfo.dPos.dyFromTop-9)
	end

	-- local exitImgInfo = info.exitImgInfo
	-- if not exitImgInfo then return  end
	-- local exitImg  = ccui.ImageView:create(exitImgInfo.path,exitImgInfo.textureResType)
	-- self._root:addChild(exitImg)
	-- exitImg:setPosition(info.size.width -  exitImgInfo.dPos.dxFromRight,info.size.height -  exitImgInfo.dPos.dyFromTop)
end

cc.exports.lib.layer.Window = Window