--
-- Author: 缓存资源界面
-- Date: 2017-10-14 15:20:44
--
local LoadResLayer = class("LoadResLayer", lib.layer.BaseLayer)

function LoadResLayer:ctor( __data )
	print("开始加载资源读条")
	LoadResLayer.super.ctor(self)
	self._loadResData = __data
	self:enableNodeEvents() 
	self:initData()
	self:initView()
	self:addResourceAnsy()
end

function LoadResLayer:initData( ... )
	self._resList = {}
	self._loadedCount = 0
end

function LoadResLayer:initView()

	local bg = ccui.ImageView:create("preload/res/bg.png",ccui.TextureResType.localType)
	self:addChild(bg)
	bg:setPosition(display.width * 0.5,display.height * 0.5)
	
	local logo = ccui.ImageView:create("preload/res/logo.png",ccui.TextureResType.localType)
	self:addChild(logo,10)
	logo:setPosition(display.width * 0.5,display.height * 0.5)

 	local loadBarBg = ccui.ImageView:create("preload/res/loading_bg.png",ccui.TextureResType.localType)
	bg:addChild(loadBarBg)
	loadBarBg:setPosition(display.width * 0.5,150)
	local size = loadBarBg:getContentSize()

	self.loadingBar = ccui.LoadingBar:create("preload/res/loading.png",ccui.TextureResType.localType)
	self.loadingBar:setPercent(0)
	loadBarBg:addChild(self.loadingBar)
	self.loadingBar:setPosition(size.width * 0.5,size.height * 0.5)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
 

	local labelConfig =	{
		fontName = GameUtils.getFontName(),
		fontSize = 23,
		text = "0%",
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(display.width * 0.5 ,loadBarBg:getPositionY() - 50),
		anchorPoint = cc.p(0.5,0.5)
	}
	self.textTip = cc.exports.lib.uidisplay.createLabel(labelConfig)
	bg:addChild(self.textTip)

	local labelConfig =	{
		fontName = GameUtils.getFontName(),
		fontSize = 23,
		text = "...",
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(display.width * 0.5 + 65,loadBarBg:getPositionY() - 50),
		anchorPoint = cc.p(0,0.5)
	}
	self.textProgressValue = cc.exports.lib.uidisplay.createLabel(labelConfig)
	bg:addChild(self.textProgressValue)

end


function LoadResLayer:addResourceAnsy( ... )
	local resList = self._loadResData.resList or {}
	local dirPath = self._loadResData.dirPath or ""

	-- 划分图片文件和plist文件
	for k, v in pairs(resList) do
		local ext = v:match("%.(%w+)$")
		ext = string.lower(ext)
		-- 图片文件列表
		if ext == "plist" then -- 必须保证plist 和 png 文件 一一对应
			local resLen = string.len(v)
			local imgStr = string.sub(v,1,resLen-5) .. "png"
			local res = {plist = v,fileName = imgStr}
			table.insert(self._resList,res)	
		end
	end
	self.textTip:setString(self:findLoadResString())
	local loadedCounts = 0

	for k,v in pairs(self._resList) do
		print("loaded fileName",v.fileName)
		cc.Director:getInstance():getTextureCache():addImageAsync(v.fileName, handler(self,self.onLoadCallback))
	end

end

function LoadResLayer:onLoadCallback( ... )
	self._loadedCount = self._loadedCount  + 1
	self:updateBar(self._loadedCount/#self._resList * 100)
	
	if self._resList[self._loadedCount].plist ~= nil then
		cc.SpriteFrameCache:getInstance():addSpriteFrames(self._resList[self._loadedCount].plist)
		print("loaded plist file",self._resList[self._loadedCount].plist)
	end

	if self._loadedCount >= #self._resList then
		if self._loadResData.callback then
			self._loadResData.callback()
		end
	end
end

-- 更新进度条
function LoadResLayer:updateBar(percent,tipString)
	if nil == self.loadingBar then
		return
	end
	local curPercent = math.ceil(percent)
	if curPercent >= 100 then
		curPercent = 100
	end
	if self.textProgressValue then
		local str = string.format("%d%%", curPercent)
		self.textProgressValue:setString(str)
	end
	self.loadingBar:setPercent(curPercent)
	if tipString then
		self.textTip:setString(tipString)
	end
end


function LoadResLayer:findLoadResString( ... )
	return "正在加载中..."
end

return LoadResLayer
