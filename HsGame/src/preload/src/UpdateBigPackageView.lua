-- 更新大包界面
-- Author: tangwen
-- Date: 2017-10-12 14:54:14
--
local UpdateBigPackageView = class("UpdateBigPackageView", cc.Layer)

local UPDATE_TEXT_SCROLLVIEW_SIZE = cc.size(660, 330)  -- 文字滑动界面大小
local UPDATE_TEXT_VIEW_POSITION = cc.p(0, 130)		-- 滑动界面初始化位置

local DIMENSIONS_SIZE = cc.size(650,0) --字体总长宽
UpdateBigPackageView._listLabels = {}
function UpdateBigPackageView:ctor(data)
	self._data = data
	self._listLabels = {}
	self:addChild(cc.LayerColor:create(cc.c4b(10,10,10,120), display.width, display.height))
	-- UpdateBigPackageView.super.ctor(self,2)
	self:initView()
end

function UpdateBigPackageView:initView()
	-- local bg = self._root
	local bg = ccui.Scale9Sprite:create(cc.rect(100,135,8,8),"src/preload/res/update_little_bg.png")
	self._bg = bg
    self._bg:setContentSize({width = 720,height = 560})
    self:addChild(self._bg)
    self._bg:setPosition(display.width / 2,display.height / 2)

    local bgSize = bg:getContentSize()
    local title = ccui.ImageView:create("src/preload/res/update_title.png", ccui.TextureResType.localType)
    title:setPosition(bgSize.width/2, bgSize.height - 25)
    bg:addChild(title)


    local updateBtnImg = "src/preload/res/update_btn_update.png"
    self._updateBtn = lib.uidisplay.createUIButton({
        normal = updateBtnImg,
        textureType = ccui.TextureResType.localType,
        isActionEnabled = true,
        callback = function() 
            self:onUpdateCallback()           
        end
        })
	self._updateBtn:setPosition(bgSize.width - 200, 50)
    bg:addChild(self._updateBtn)

    if not self._data.isForce then  
    	local cancelBtnImg = "src/preload/res/update_btn_close.png"
	    self._cancelBtn = lib.uidisplay.createUIButton({
	        normal = cancelBtnImg,
	        textureType = ccui.TextureResType.localType,
	        isActionEnabled = true,
	        callback = function() 
	            self:onCancelCallback()           
	        end
	        })
		self._cancelBtn:setPosition(200, 50)
	    bg:addChild(self._cancelBtn)
	else
		self._updateBtn:setPosition(bgSize.width / 2, 50)    
    end




    self:initLables(bg)
	self._loadBarBg = ccui.ImageView:create("src/preload/res/update_bar_bg.png")
	bg:addChild(self._loadBarBg)
	self._loadBarBg:setPosition(bgSize.width/2,100)
	local size = self._loadBarBg:getContentSize()

	self.loadingBar = ccui.LoadingBar:create("src/preload/res/update_bar.png")
	self._loadBarBg:addChild(self.loadingBar)
	self.loadingBar:setPosition(size.width/2,size.height * 0.5)

	self._loadBarBg:hide()

	local labelConfig =	{
		fontName = GameUtils.getFontName(),
		fontSize = 23,
		text = "0%",
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(194,84,29, 255),
		pos = cc.p(display.width * 0.5 - 130 ,self._loadBarBg:getPositionY() - 50),
		anchorPoint = cc.p(0,0.5)
	}
	self.textProgressValue = cc.exports.lib.uidisplay.createLabel(labelConfig)
	bg:addChild(self.textProgressValue)
	self.textProgressValue:hide()

	local labelConfig =	{
		fontName = GameUtils.getFontName(),
		fontSize = 23,
		text = "正在下载安装包...",
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(bgSize.width/2 - 20,50),
		anchorPoint = cc.p(0.5,0.5)
	}
	self.textTip = cc.exports.lib.uidisplay.createLabel(labelConfig)
	bg:addChild(self.textTip)
	self.textTip:hide()

	local target = device.platform
	if target ~= "android" then
		local labelConfig =	{
			fontName = GameUtils.getFontName(),
			fontSize = 23,
			text = "请更新到最新版本!",
			alignment = cc.TEXT_ALIGNMENT_CENTER,
			color = cc.c4b(255,0,0, 255),
			pos = cc.p(bgSize.width /2, 110),
			anchorPoint = cc.p(0.5,0.5)
		}
		local label = cc.exports.lib.uidisplay.createLabel(labelConfig)
		bg:addChild(label)
	end
end

function UpdateBigPackageView:initLables( __bg )
	local bg = __bg
   	local scrollViewNode = self:createNoticeTextScrollView()
	bg:addChild(scrollViewNode)
	self._scrollViewNode = scrollViewNode

	self._data.description = string.gsub(self._data.description, "\\n", function(s) return "\r\n" end) 
	
	local rewardStr = ""
	if self._data.allowance then 
		for i,info in ipairs(self._data.allowance) do
			if i == 1 then 
				rewardStr = rewardStr .. " " .. info.name .. info.num 
			else
				rewardStr = rewardStr .. " , " .. info.name .. info.num
			end
		end
	end

	local item = ccui.Layout:create()
	item:setAnchorPoint(cc.p(0,1))
	local params = {
		pkgInfo = 	{{text = "安装包版本:",color = cc.c3b(224,221,245),anch = cc.p(0,1)},
		{text = self._data.version .. "      " or "?.?.?      ",color = cc.c3b(231,96,0),anch = cc.p(0,1)},
		{text = "更新包大小:",color = cc.c3b(224,221,245),anch = cc.p(0,1)},
		{text = self._data.size or "?",color = cc.c3b(231,96,0),anch = cc.p(0,1)}},

		tip = {{text = "请更新之后进入游戏!",color = cc.c3b(224,221,245),anch = cc.p(0,1)}},

		reward = {
			{text = "更新奖励:",color = cc.c3b(224,221,245),anch = cc.p(0,1)},
			{text = rewardStr or "?",color = cc.c3b(255,210,0),anch = cc.p(0,1)}
		},
		updateTitle = {{text = "主要更新内容:",color = cc.c3b(224,221,245),anch = cc.p(0,1)}},
		updateContent = {{text = self._data.description,color = cc.c3b(224,221,245),anch = cc.p(0,1)}},

	}

	local func = function ( __params)

		if type(__params) ~= "string" and #__params > 0 then 
			local params = __params
			local width  = 0
			local height = 0
			local layout = ccui.Layout:create()
			for i=1,#params do
				local info = params[i]
				local label = cc.Label:createWithTTF(info.text ,GameUtils.getFontName(),25)
				label:setAnchorPoint(info.anch)
				label:setColor(info.color)
				if height < label:getContentSize().height then height = label:getContentSize().height end
				layout:addChild(label)
				label:setPosition(width,height)
				label:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
				width = width + label:getContentSize().width
			end
			layout:setContentSize(cc.size(width,height))
			self:pushLabelItem(layout)
		elseif type(__params) == "string" then
			local info = params
			local label = cc.Label:createWithTTF(info.text ,GameUtils.getFontName(),25)
			label:setAnchorPoint(info.anch)
			label:setColor(info.color)
			label:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
			self:pushLabelItem(label)
		end
	end

	func(params.pkgInfo)
	func(params.tip)
	func(params.reward)
	func(params.updateTitle)
	func(params.updateContent)

    self:loadItemLabels()
end

function UpdateBigPackageView:pushLabelItem( __itemLabel )
	self._listLabels[#self._listLabels + 1] = __itemLabel
	__itemLabel:retain()
end

function UpdateBigPackageView:loadItemLabels( ... )
	if self._listLabels then 
		local layout = ccui.Layout:create()
		local num = #self._listLabels
		local height = 0
		for i=1,num do
			local index = num - i + 1
			local label = self._listLabels[index]
			height = height + label:getContentSize().height 
		end
		
		local dHeight = 0
		if height < self._scrollViewNode:getContentSize().height then 
			dHeight = self._scrollViewNode:getContentSize().height - height
		end
		height = dHeight
		for i=1,num do
			local index = num - i + 1
			local label = self._listLabels[index]
			label:setAnchorPoint(cc.p(0,1))
			height = height + label:getContentSize().height
			label:setPosition(100,height)
			layout:addChild(label)
			label:release()
		end

		if self._scrollViewNode then self._scrollViewNode:addChild(layout)  self._scrollViewNode:setInnerContainerSize(cc.size(790,height)) end
	end

end

-- 创建文字滑动界面
function UpdateBigPackageView:createNoticeTextScrollView()
	local contentSize = cc.size(790, 330)
    local _NoticeTextScrollView = ccui.ScrollView:create()
    _NoticeTextScrollView:setTouchEnabled(true)--触摸的属性
    _NoticeTextScrollView:setBounceEnabled(true)--弹回的属性
    _NoticeTextScrollView:setInertiaScrollEnabled(true)--滑动的惯性
    _NoticeTextScrollView:setScrollBarEnabled(false)
    _NoticeTextScrollView:setDirection(ccui.ScrollViewDir.vertical)
    _NoticeTextScrollView:setContentSize(UPDATE_TEXT_SCROLLVIEW_SIZE)
    _NoticeTextScrollView:setInnerContainerSize(UPDATE_TEXT_SCROLLVIEW_SIZE)
    _NoticeTextScrollView:setPosition(UPDATE_TEXT_VIEW_POSITION)
    return _NoticeTextScrollView
end

-- 更新 
function UpdateBigPackageView:onUpdateCallback( ... )
	-- body
	-- self._updateBtn:hide()
	-- self._cancelBtn :hide()
	-- self._loadBarBg:show()
	-- self.textTip:show()
	-- self.textProgressValue:show()
	-- self:updateBar(0)
	local target = device.platform
	if target ~= "android"  then
		--todo 请到appstore更新

	else
		cc.UserDefault:getInstance():setStringForKey(lib.download.HotUpdateManager.SEARCH_PATHS,"");
		print("打开网页",self._data.updateUrl)
		MultiPlatform:getInstance():openBrowser(self._data.updateUrl)
	end
end

-- 更新进度条
function UpdateBigPackageView:updateBar(percent)

	if nil == self.loadingBar then
		return
	end
	if self.textProgressValue then
		local str = string.format("%d", percent)
		self.textProgressValue:setString(str)
	end
	self.loadingBar:setPercent(percent)
end

-- 不更新 下次再说 
function UpdateBigPackageView:onCancelCallback( ... )
	if self._data.isForce then 
		cc.Director:getInstance():endToLua()
	end
end

function UpdateBigPackageView:onEnter( ... )
end

function UpdateBigPackageView:onExit()

end

return UpdateBigPackageView

