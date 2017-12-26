-- 邮件
-- @date 2017.08.05
-- @author tangwen

local MailView = class("MailView", lib.layer.Window)

-- 这里初始化所有滑动界面信息，如有特殊的单独处理
local MAIL_SCROLLVIEW_SIZE = cc.size(1060, 520)  -- 滑动界面大小
local MAIL_VIEW_POSITION = cc.p(-463, -230)		-- 滑动界面初始化位置
local RECORD_SIZE = cc.size(925,93)   			--滑动界面节点大小 记录节点大小 
local MAIL_INTERVAL_V = 117   --每条记录之间的间距 竖 
local MAIL_MAX_COL = 1		 -- 列数
local MAIL_MAX_ROW = 30 	 -- 最大行数

function MailView:ctor(__data)
	MailView.super.ctor(self,ConstantsData.WindowType.WINDOW_BIG)
    self._MailListData = __data
	self:initView()
end

function MailView:initView()
    local bg = self._root
    self._bg = bg

    self._MailNodeList = {}

    local bgSize = self._bg:getContentSize()
    -- local title = ccui.ImageView:create("Lobby_mail_title.png", ccui.TextureResType.plistType)
    -- title:setPosition(bgSize.width/2, bgSize.height - 25)
    -- self._bg:addChild(title)
    local titleBg = ccui.ImageView:create("res/common/common_title_bg.png")
    titleBg:setPosition(bgSize.width/2, bgSize.height - 25)
    bg:addChild(titleBg)

    local title = cc.Label:createWithTTF("邮件",GameUtils.getFontName(), 36)
    title:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2+3)
    title:setTextColor(cc.c3b(141,62,30))
    title:enableOutline(cc.c3b(255, 250, 152),2)
    titleBg:addChild(title)

	self._mailScrollView = self:createScrollView(#self._MailListData)
	self._mailScrollView:setPosition(25,20)
	self._bg:addChild(self._mailScrollView,1)

	local contentSize = cc.size(MAIL_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (#self._MailListData - 1) * MAIL_INTERVAL_V + 36)
	if contentSize.height < MAIL_SCROLLVIEW_SIZE.height then
		contentSize = MAIL_SCROLLVIEW_SIZE
	end

    local offset = cc.p(0, contentSize.height)
    local PosY = 0

    self._list = {}

	for k, v in ipairs(self._MailListData) do
        local record= self:createMailRecord(v)
        local row = k
        local x = 40 + offset.x +RECORD_SIZE.width/2 
        local y = 70 + offset.y - row * MAIL_INTERVAL_V
        record:setPosition(x,y)
        self._mailScrollView:addChild(record)
        table.insert(self._MailNodeList,record)
    end

    self._NoTaskText = cc.Label:createWithTTF("暂时没有邮件哟!",GameUtils.getFontName(),32)
    self._NoTaskText:setPosition(bgSize.width/2, bgSize.height/2)
    bg:addChild(self._NoTaskText)
    self._NoTaskText:hide()

    if #self._MailListData == 0 then
        self._NoTaskText:show()
    end

end

-- 创建scrollView界面
function MailView:createScrollView(rowNum)
	local contentSize = cc.size(MAIL_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (rowNum - 1) * MAIL_INTERVAL_V + 36)

	local _MailScrollView = ccui.ScrollView:create()
    _MailScrollView:setTouchEnabled(true)--触摸的属性
    _MailScrollView:setBounceEnabled(true)--弹回的属性
    _MailScrollView:setInertiaScrollEnabled(true)--滑动的惯性
    _MailScrollView:setScrollBarEnabled(false)
    _MailScrollView:setDirection(ccui.ScrollViewDir.vertical)
    _MailScrollView:setContentSize(MAIL_SCROLLVIEW_SIZE)
    _MailScrollView:setInnerContainerSize(contentSize)
    _MailScrollView:setPosition(MAIL_VIEW_POSITION)

    return _MailScrollView
end


-- 创建排行榜记录条
function MailView:createMailRecord(data)
	if data == nil then
		return
	end

    dump(data)

	local size = cc.size(1000, 93)
	local record = ccui.Layout:create()

   	local bg = ccui.Scale9Sprite:createWithSpriteFrameName("Lobby_mail_list_bg.png",cc.rect(20,20,8,8))
    bg:setContentSize(size)
    bg:setPosition(cc.p(0,0))
    record:addChild(bg)

    record.GameID = data.gameID
	record.TableID = data.tableID
    record.ApplyUserID = data.applyUserID

	record._hasOkImg =  ccui.ImageView:create("Lobby_mail_hasAgree.png", ccui.TextureResType.plistType)
    record._hasOkImg:setPosition(size.width/2 - 116, 0)
    record:addChild(record._hasOkImg)
    record._hasOkImg:hide()

    record._hasRefuseImg =  ccui.ImageView:create("Lobby_mail_hasRefuse.png", ccui.TextureResType.plistType)
    record._hasRefuseImg:setPosition(size.width/2 - 116, 0)
    record:addChild(record._hasRefuseImg)
    record._hasRefuseImg:hide()

    local _nameStr = "["..string.getMaxLen(data.nickName).."]"
    local _gameName  = "私人房"..GameListData.getPrivateGameData(data.gameID).Name
    local _gameStr = _gameName.."--"..data.tableID.."号桌" 

    local __RichTextList = {{Color3B = cc.c3b(224,221,245), opacity = 255, richText = "玩家", fontSize = 22},
                        {Color3B = cc.c3b(44,224,0), opacity = 255, richText = _nameStr, fontSize = 22},
                        {Color3B = cc.c3b(224,221,245), opacity = 255, richText = "申请加入您创建的", fontSize = 22},
                    	{Color3B = cc.c3b(255,174,0), opacity = 255, richText = _gameStr, fontSize = 22},
                    	{Color3B = cc.c3b(224,221,245), opacity = 255, richText = "进行游戏", fontSize = 22}}

	local _richText = GameUtils.createRichText(__RichTextList)
	_richText:setAnchorPoint(cc.p(0, 0.5))
	_richText:setPosition(-size.width/2 + 20, 0)
	record:addChild(_richText)

    record._okBtn = cc.exports.lib.uidisplay.createLabelButton({
            textureType = ccui.TextureResType.plistType,
            normal = "common_small_green_btn.png",
            callback = function() 
                request.LobbyRequest:RequestAuthorizeAction(ConstantsData.ActionIndexType.ACTION_INDEX_AGREE,record.ApplyUserID,record.TableID)
            end,
            isActionEnabled = true,
            pos = cc.p(size.width/2 - 60, 0),
            text = "同意",
            outlineColor = cc.c4b(24,73,30,255),
            outlineSize = 2,
            labPos = cc.p(0,2),
    })
    record:addChild(record._okBtn)


    record._refuseBtn = cc.exports.lib.uidisplay.createLabelButton({
            textureType = ccui.TextureResType.plistType,
            normal = "common_small_yellow_btn.png",
            callback = function() 
                request.LobbyRequest:RequestAuthorizeAction(ConstantsData.ActionIndexType.ACTION_INDEX_REFUSE,record.ApplyUserID,record.TableID)
            end,
            isActionEnabled = true,
            pos = cc.p(size.width/2 - 180, 0),
            text = "拒绝",
            outlineColor = cc.c4b(112,45,2,255),
            outlineSize = 2,
            labPos = cc.p(0,2),
    })
    record:addChild(record._refuseBtn)
    return record
end

function MailView:updataMailNode(__params)
    for k,v in pairs(self._MailNodeList) do
        if __params.applyUserID == v.ApplyUserID and __params.tableID == v.TableID and __params.gameID == v.GameID then
            if __params.actionID == ConstantsData.ActionIndexType.ACTION_INDEX_REFUSE then
                v._hasRefuseImg:show()
                v._okBtn:hide()
                v._refuseBtn:hide()
            elseif __params.actionID == ConstantsData.ActionIndexType.ACTION_INDEX_AGREE then
                v._hasOkImg:show()
                v._okBtn:hide()
                v._refuseBtn:hide()
            end
        end
    end

end

function MailView:onEnter( ... )
	MailView.super.onEnter(self)
end

function MailView:onExit( ... )
	-- body
end
return MailView