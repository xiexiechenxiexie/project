-- 活动公告和系统公告
-- @date 2017.08.16
-- @author tangwen

local NoticeView = class("NoticeView", lib.layer.Window)

local NOTICE_TEXT_SCROLLVIEW_SIZE = cc.size(824, 460)  -- 文字滑动界面大小
local NOTICE_TEXT_VIEW_POSITION = cc.p(0, 0)		-- 滑动界面初始化位置

local NOTICE_TITLE_SCROLLVIEW_SIZE = cc.size(200, 470)  -- 标签滑动界面大小
local NOTICE_TITLE_VIEW_POSITION = cc.p(-208, 0)		-- 滑动界面初始化位置
local RECORD_SIZE = cc.size(168,74)   			--滑动界面节点大小 记录节点大小 
local NOTICE_INTERVAL_V = 100   --每条记录之间的间距 竖 

local DIMENSIONS_SIZE = cc.size(780,0) --字体总长宽


function NoticeView:ctor(data)
	self._HotEventList = {}
	self._SystemEventList = {}
	NoticeView.super.ctor(self,ConstantsData.WindowType.WINDOW_BIG)
	self:initData(data)
	self:initView()
end

function NoticeView:initData(data)
	self._data = data
	self._SyStemEventData = {}
	self._HotEventData = {}
	for k,v in pairs(self._data) do
		if v.type == ConstantsData.NoticeType.NOTICE_HOTEVENT then 
			table.insert(self._HotEventData,v)
		elseif v.type == ConstantsData.NoticeType.NOTICE_SYSTEMEVENT then
			table.insert(self._SyStemEventData,v)
		else
			print("系统公告数据格式不对")
		end
	end
end

function NoticeView:initView()
    local bg = self._root
    self._bg = bg

    local bgSize = bg:getContentSize()

	local btnBgImg = ccui.ImageView:create("Lobby_notice_btn_bg.png", ccui.TextureResType.plistType)
	btnBgImg:setPosition(bgSize.width/2, bgSize.height - 70)
	bg:addChild(btnBgImg)

	local btnBgSize = btnBgImg:getContentSize()
	self._HotEventText = cc.Label:createWithTTF("活动公告",GameUtils.getFontName(),30)
    self._HotEventText:setAnchorPoint(cc.p(0.5, 0.5))
    self._HotEventText:setColor(cc.c3b(255,255,255))
    self._HotEventText:setPosition(btnBgSize.width/2 - 125, btnBgSize.height/2)
    btnBgImg:addChild(self._HotEventText,2)

    self._SystemEventText = cc.Label:createWithTTF("系统公告",GameUtils.getFontName(),30)
    self._SystemEventText:setAnchorPoint(cc.p(0.5, 0.5))
    self._SystemEventText:setColor(cc.c3b(104,96,169))
    self._SystemEventText:setPosition(btnBgSize.width/2 + 125, btnBgSize.height/2)
    btnBgImg:addChild(self._SystemEventText,2)

    local btnImg = "common_btn_select.png"
    self._btnHotEvent  = ccui.Button:create(btnImg, btnImg, btnImg, ccui.TextureResType.plistType)
	self._btnHotEvent:addClickEventListener(function()
		self:showNoticeView(ConstantsData.NoticeType.NOTICE_HOTEVENT)
	end)
	self._btnHotEvent:setPosition(btnBgSize.width/2 - 125, btnBgSize.height/2)
	btnBgImg:addChild(self._btnHotEvent)
	self._btnHotEvent:setOpacity(0)

	self._btnSystemEvent  = ccui.Button:create(btnImg, btnImg, btnImg, ccui.TextureResType.plistType)
	self._btnSystemEvent:addClickEventListener(function()
		self:showNoticeView(ConstantsData.NoticeType.NOTICE_SYSTEMEVENT)
	end)
	self._btnSystemEvent:setPosition(btnBgSize.width/2 + 125, btnBgSize.height/2)
	btnBgImg:addChild(self._btnSystemEvent)
	self._btnSystemEvent:setOpacity(0)

	self._HotEventImg = ccui.ImageView:create("common_btn_select.png", ccui.TextureResType.plistType)
	self._HotEventImg:setPosition(btnBgSize.width/2 - 125, btnBgSize.height/2)
	btnBgImg:addChild(self._HotEventImg)
	self._HotEventImg:show()

	self._SystemEventImg = ccui.ImageView:create("common_btn_select.png", ccui.TextureResType.plistType)
	self._SystemEventImg:setPosition(btnBgSize.width/2 + 125, btnBgSize.height/2)
	btnBgImg:addChild(self._SystemEventImg)
	self._SystemEventImg:hide()

	self._HotEventBg = ccui.ImageView:create("Lobby_notice_list_bg.png", ccui.TextureResType.plistType)
	self._HotEventBg:setPosition(bgSize.width/2 + 95, bgSize.height/2 - 53)
	bg:addChild(self._HotEventBg)
	self._HotEventBg:show()

	self._SystemEventBg = ccui.ImageView:create("Lobby_notice_list_bg.png", ccui.TextureResType.plistType)
	self._SystemEventBg:setPosition(bgSize.width/2 + 95, bgSize.height/2 - 53)
	bg:addChild(self._SystemEventBg)
	self._SystemEventBg:hide()
end

function NoticeView:showNoticeView(index)
	if  index == ConstantsData.NoticeType.NOTICE_HOTEVENT then 
		self._HotEventText:setColor(cc.c3b(255,255,255))
		self._SystemEventText:setColor(cc.c3b(104,96,169))
		self._HotEventImg:show()
		self._SystemEventImg:hide()
		self:showHotEventView()
	elseif index == ConstantsData.NoticeType.NOTICE_SYSTEMEVENT then
		self._HotEventText:setColor(cc.c3b(104,96,169))
		self._SystemEventText:setColor(cc.c3b(255,255,255))
		self._HotEventImg:hide()
		self._SystemEventImg:show()
		self:showSystemEventView()
	else
		print("公告格式不正确")
	end
	self:showNoticeContentByData(index,1)
end

-- 显示
function NoticeView:showHotEventView()
	self._HotEventBg:show()
	self._SystemEventBg:hide()

	if #self._HotEventList > 0 or next(self._HotEventData) == nil then
		return
	end

	local data = self._HotEventData
	self._NoticeTitleScrollView = self:createNoticeTitleScrollView(#data)
	self._HotEventBg:addChild(self._NoticeTitleScrollView)

	local contentSize =cc.size(NOTICE_TITLE_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (#data - 1) * NOTICE_INTERVAL_V + 30)
	if contentSize.height < NOTICE_TITLE_SCROLLVIEW_SIZE.height then
		contentSize = NOTICE_TITLE_SCROLLVIEW_SIZE
	end
    local offset = cc.p(0, contentSize.height)
    local PosY = 0
    local bgSize = self._HotEventBg:getContentSize()

    self._HotEventList = {}
	for k, v in ipairs(data) do
        local titleNode= self:createNoticeTitleNode(k,v,ConstantsData.NoticeType.NOTICE_HOTEVENT)
        local row = k
        local x = offset.x + RECORD_SIZE.width/2 + 18
        local y =50 + offset.y - row * NOTICE_INTERVAL_V
        titleNode:setPosition(x,y)
        
        self._NoticeTitleScrollView:addChild(titleNode)

        local noticeNode = nil
        if v.description ~= nil then
			local textLabel = cc.Label:createWithTTF(v.description,GameUtils.getFontName(),26,DIMENSIONS_SIZE)
		    textLabel:setAnchorPoint(cc.p(0.5, 0.5))
		    --textLabel:setPosition(412,440)
		    textLabel:setLineHeight(50)
		    textLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
		    local TextSize = textLabel:getContentSize()
		    local y = 0
			if TextSize.height > NOTICE_TEXT_SCROLLVIEW_SIZE.height then 
				y =  450 + TextSize.height/2  - NOTICE_TEXT_SCROLLVIEW_SIZE.height + 20
			else
				y =  450 - TextSize.height/2
			end

		    noticeNode = self:createNoticeTextScrollView(TextSize)
		    noticeNode:addChild(textLabel,1)

        	textLabel:setPosition(412,y)
		    
		    self._HotEventBg:addChild(noticeNode)

		elseif v.ImageUrl ~= nil then -- 显示图片
			local imgUrl = config.ServerConfig:findResDomain() .. v.ImageUrl
			noticeNode = lib.node.RemoteImageView:create("Lobby_Notice_bg.png", ccui.TextureResType.plistType)
			noticeNode:setDownloadParams({
				dir = "notice",
				url = imgUrl
			})
			noticeNode:setPosition(bgSize.width/2,bgSize.height/2)
			self._HotEventBg:addChild(noticeNode)
		else
			print("createnoticeNode type error")
		end

		local params = { title = titleNode, notice = noticeNode, id = v.id }
		table.insert(self._HotEventList,params)

    end

end

function NoticeView:showSystemEventView()
	self._HotEventBg:hide()
	self._SystemEventBg:show()

	if #self._SystemEventList > 0 or next(self._SyStemEventData) == nil then
		return
	end

	local data = self._SyStemEventData
	self._SystemTitleScrollView = self:createNoticeTitleScrollView(#data)
	self._SystemEventBg:addChild(self._SystemTitleScrollView)

	local contentSize =cc.size(NOTICE_TITLE_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (#data - 1) * NOTICE_INTERVAL_V + 30)
	if contentSize.height < NOTICE_TITLE_SCROLLVIEW_SIZE.height then
		contentSize = NOTICE_TITLE_SCROLLVIEW_SIZE
	end
    local offset = cc.p(0, contentSize.height)
    local PosY = 0
    local bgSize = self._SystemEventBg:getContentSize()

    self._SystemEventList = {}
	for k, v in ipairs(data) do
        local titleNode= self:createNoticeTitleNode(k,v,ConstantsData.NoticeType.NOTICE_SYSTEMEVENT)
        local row = k
        local x = offset.x + RECORD_SIZE.width/2 + 18
        local y = 50 + offset.y - row * NOTICE_INTERVAL_V
        titleNode:setPosition(x,y)
        self._SystemTitleScrollView:addChild(titleNode)

		local noticeNode = nil

        if v.description ~= nil then --显示文字
			local textLabel = cc.Label:createWithTTF(v.description,GameUtils.getFontName(),26,DIMENSIONS_SIZE)
		    textLabel:setAnchorPoint(cc.p(0.5, 0.5))
		    --textLabel:setPosition(412,440)
		    textLabel:setLineHeight(50)
		    textLabel:setHorizontalAlignment(kCCTextAlignmentLeft)
		    local TextSize = textLabel:getContentSize()
		    local y = 0
			if TextSize.height > NOTICE_TEXT_SCROLLVIEW_SIZE.height then 
				y =  450 + TextSize.height/2  - NOTICE_TEXT_SCROLLVIEW_SIZE.height + 20
			else
				y =  450 - TextSize.height/2
			end

		    noticeNode = self:createNoticeTextScrollView(TextSize)
		    noticeNode:addChild(textLabel,1)

        	textLabel:setPosition(bgSize.width/2,y)
		    
		    self._SystemEventBg:addChild(noticeNode)

		elseif v.ImageUrl ~= nil then -- 显示图片
			local imgUrl = config.ServerConfig:findResDomain() .. v.ImageUrl
			noticeNode = lib.node.RemoteImageView:create("Lobby_Notice_bg.png", ccui.TextureResType.plistType)
			noticeNode:setDownloadParams({
				dir = "notice",
				url = imgUrl
			})
			noticeNode:setPosition(bgSize.width/2,bgSize.height/2)
			self._SystemEventBg:addChild(noticeNode)
		else
			print("createnoticeNode type error")
		end

		local params = { title = titleNode, notice = noticeNode, id = v.id}
		table.insert(self._SystemEventList,params)
    end
end


-- 显示 公告内容
function NoticeView:showNoticeContentByData(index, num)
	self:showNoticeTitle(index,num)
	if index == ConstantsData.NoticeType.NOTICE_HOTEVENT and next(self._HotEventList) ~= nil then --活动公告
		for k,v in pairs(self._HotEventList) do
			if k == num then
				v.notice:show()
			else
				v.notice:hide()
			end
		end
	elseif index == ConstantsData.NoticeType.NOTICE_SYSTEMEVENT and next(self._SystemEventList) ~= nil then -- 系统
		for k,v in pairs(self._SystemEventList) do
			if k == num then
				v.notice:show()
			else
				v.notice:hide()
			end
		end
	else
		print("showNotice type error")
	end
end

function NoticeView:showNoticeTitle(index,num)
	if index == ConstantsData.NoticeType.NOTICE_HOTEVENT then --活动公告
		for k,v in pairs(self._HotEventList) do
			if k == num then
				v.title.titleBtn:setOpacity(255)
				v.title.RedImg:hide()
			else
				v.title.titleBtn:setOpacity(0)
			end
		end
	elseif index == ConstantsData.NoticeType.NOTICE_SYSTEMEVENT then -- 系统
		for k,v in pairs(self._SystemEventList) do
			if k == num then
				v.title.titleBtn:setOpacity(255)
				v.title.RedImg:hide()
			else
				v.title.titleBtn:setOpacity(0)
			end
		end
	else
		print("showNoticeTitle type error")
	end
end


-- 创建标签
function NoticeView:createNoticeTitleNode(index,data,showType)
	if data == nil then
		return
	end

	local NoticeIndex ="NOTICE_ID_"..data.id
	if index == 1 then
	    cc.UserDefault:getInstance():setFloatForKey(NoticeIndex,1)
	end

	local record = ccui.Layout:create()
	local size = cc.size(168, 74)
   	record.bg =  ccui.ImageView:create("Lobby_notice_title.png", ccui.TextureResType.plistType)
    record.bg:setContentSize(size)
    record.bg:setPosition(cc.p(0,0))
    record:addChild(record.bg)

    local bgSize = record.bg:getContentSize()

    local titleBtnImg = "Lobby_notice_title_bg.png"
	record.titleBtn = ccui.Button:create(titleBtnImg,titleBtnImg,titleBtnImg,ccui.TextureResType.plistType)
	record.titleBtn :setPosition(7,0)
	record.titleBtn :setOpacity(0)
	record:addChild(record.titleBtn,2)
	record.titleBtn :addClickEventListener(function()
		cc.UserDefault:getInstance():setFloatForKey(NoticeIndex,1)
		self:showNoticeContentByData(showType,index)
	end)

	record.NewImg = ccui.ImageView:create("Lobby_notice_new.png", ccui.TextureResType.plistType)
    record.NewImg:setPosition(cc.p(-size.width/2 + 27,size.height/2 -20))
    record:addChild(record.NewImg,3)
    if data.tag == ConstantsData.NoticeShowType.NOTICE_NORMAL then
    	record.NewImg:hide()
    elseif data.tag == ConstantsData.NoticeShowType.NOTICE_NEW then
    	record.NewImg:show()
    else
    	record.NewImg:hide()
    end


    record.RedImg = ccui.ImageView:create("common_redPoint.png", ccui.TextureResType.plistType)
    record.RedImg:setPosition(cc.p(size.width/2 - 2,size.height/2 - 2))
    record:addChild(record.RedImg,4)

   	local redShow = cc.UserDefault:getInstance():getFloatForKey(NoticeIndex)
   	if redShow == 0 then
   		record.RedImg:show()
   	else
   		record.RedImg:hide()
   	end

	local nameText = cc.Label:createWithTTF(data.title,GameUtils.getFontName(),30)
    nameText:setAnchorPoint(cc.p(0.5, 0.5))
    nameText:setPosition(0,0)
    record:addChild(nameText,5)

    return record
    
end

-- 创建标签scrollView界面
function NoticeView:createNoticeTitleScrollView(rowNum)
	local contentSize = cc.size(NOTICE_TITLE_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (rowNum - 1) * NOTICE_INTERVAL_V + 30)
    local _NoticeTitleScrollView = ccui.ScrollView:create()
    _NoticeTitleScrollView:setTouchEnabled(true)--触摸的属性
    _NoticeTitleScrollView:setBounceEnabled(true)--弹回的属性
    _NoticeTitleScrollView:setInertiaScrollEnabled(true)--滑动的惯性
    _NoticeTitleScrollView:setScrollBarEnabled(false)
    _NoticeTitleScrollView:setDirection(ccui.ScrollViewDir.vertical)
    _NoticeTitleScrollView:setContentSize(NOTICE_TITLE_SCROLLVIEW_SIZE)
    _NoticeTitleScrollView:setInnerContainerSize(contentSize)
    _NoticeTitleScrollView:setPosition(NOTICE_TITLE_VIEW_POSITION)

    return _NoticeTitleScrollView
end

-- 创建文字滑动界面
function NoticeView:createNoticeTextScrollView(TextSize)
	local size = TextSize
	local contentSize = cc.size(790, 460)
	contentSize.height = size.height + 20
    local _NoticeTextScrollView = ccui.ScrollView:create()
    _NoticeTextScrollView:setTouchEnabled(true)--触摸的属性
    _NoticeTextScrollView:setBounceEnabled(true)--弹回的属性
    _NoticeTextScrollView:setInertiaScrollEnabled(true)--滑动的惯性
    _NoticeTextScrollView:setScrollBarEnabled(false)
    _NoticeTextScrollView:setDirection(ccui.ScrollViewDir.vertical)
    _NoticeTextScrollView:setContentSize(NOTICE_TEXT_SCROLLVIEW_SIZE)
    _NoticeTextScrollView:setInnerContainerSize(contentSize)
    _NoticeTextScrollView:setPosition(NOTICE_TEXT_VIEW_POSITION)

    return _NoticeTextScrollView
end

function NoticeView:onEnter( ... )
	NoticeView.super.onEnter(self)
	self:showNoticeView(ConstantsData.NoticeType.NOTICE_HOTEVENT)
end

function NoticeView:onExit( ... )

end
return NoticeView