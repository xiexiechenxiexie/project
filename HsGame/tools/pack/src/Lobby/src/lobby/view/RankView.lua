-- 排行榜
-- @date 2017.08.05
-- @author tangwen

local RankView = class("RankView", lib.layer.BaseLayer)

local PlayerInfo = require "PlayerInfoView"

-- 这里初始化所有滑动界面信息，如有特殊的单独处理
local RANK_RICH_SCROLLVIEW_SIZE = cc.size(400, 412)  -- 财富榜滑动界面大小
local RANK_FRIEND_SCROLLVIEW_SIZE = cc.size(400, 385)  -- 好友榜滑动界面大小
local RANK_RICH_VIEW_POSITION = cc.p(0, 10)		-- 滑动界面初始化位置
local RANK_FRIEND_VIEW_POSITION = cc.p(0, 30)		-- 滑动界面初始化位置
local RECORD_SIZE = cc.size(378,111)   			--滑动界面节点大小 记录节点大小 
local RANK_INTERVAL_V = 113   --每条记录之间的间距 竖 
local RANK_BG_POS = cc.p(-445,0)

local RANK_RICH_TITLE_POS = cc.p(-550,210)
local RANK_FRIEND_TITLE_POS = cc.p(-359,210)

local RankTag = {
	RANKING_IMG_TAG = 1,
	RANKING_LABEL_TAG = 2,
	LIST_BTN_TAG = 3,
	MONEY_ICON_IMG_TAG = 4,
	MONEY_TEXT_TAG = 5,
}

-- local MOVETIME = 0.2

function RankView:ctor()
	self:setPosition(display.cx,display.cy)
	self:enableNodeEvents() 
	self:createView()
	self._isRichRankLoaded = false  -- 财富榜记录
	self._isFriendRankListLoaded = false  -- 好友榜记录
	self._rickRankScrollView = nil
end

function RankView:createView( ... )
	--透明遮罩层
	local layer = cc.LayerColor:create(cc.c4b(10, 10, 10, 120), display.width*2, display.height)
	layer:setPosition(-667,-375)
    self:addChild(layer)
    local function onTouchBegan(touch, event)
    	return true
    end
    local function onTouchMove(touch, event)
    	return true
    end
    local function onTouchEnd(touch, event)
    	self:closeLayer()
    	return true
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:setSwallowTouches(false)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,layer)
    self.listener=listener

    local node=cc.Node:create()
	layer:addChild(node)
	self.node=node
end

function RankView:initView()
	self._RichListbg = ccui.ImageView:create("ranking_bg.png", ccui.TextureResType.plistType)
    self._RichListbg:setAnchorPoint(cc.p(0.5, 0.5))
    self._RichListbg:setPosition(RANK_BG_POS)
    self.node:addChild(self._RichListbg)
    self._RichListbg:show()

    self._FriendListbg = ccui.Button:create("ranking_bg.png","ranking_bg.png","ranking_bg.png", ccui.TextureResType.plistType)
    self._FriendListbg:setAnchorPoint(cc.p(0.5, 0.5))
    self._FriendListbg:setPosition(RANK_BG_POS)
    self.node:addChild(self._FriendListbg)
    self._FriendListbg:hide()

    local labelFriend = cc.Label:createWithTTF("按好友周盈利进行排名",GameUtils.getFontName(),20)
    labelFriend:setPosition(200, 16)
    labelFriend:setColor(cc.c3b(255,255,255))
    self._FriendListbg:addChild(labelFriend)

    local RichImg = "ranking_btn_select.png"
    self._btnRich  = ccui.Button:create(RichImg, RichImg, RichImg, ccui.TextureResType.plistType)
	self._btnRich:setPosition(RANK_RICH_TITLE_POS)
	self.node:addChild(self._btnRich,2)
	self._btnRich:addClickEventListener(function()
		self:requestRichRankView()
	end)
	self._btnRich:show()

	local FriendImg = "ranking_btn_select.png"
    self._btnFriend  = ccui.Button:create(FriendImg, FriendImg, FriendImg, ccui.TextureResType.plistType)
	self._btnFriend:setPosition(RANK_FRIEND_TITLE_POS)
	self.node:addChild(self._btnFriend,2)
	self._btnFriend:setOpacity(0)
	self._btnFriend:addClickEventListener(function()
		self:requestFriendRankView()
	end)
	self._btnFriend:show()

	self._RichTitle = cc.Label:createWithTTF("财富榜",GameUtils.getFontName(),30)
    self._RichTitle:setColor(cc.c3b(236, 224, 184))
    self._RichTitle:setPosition(RANK_RICH_TITLE_POS)
    self.node:addChild(self._RichTitle,3)
    self._RichTitle:show()

    self._FriendTitle = cc.Label:createWithTTF("好友榜",GameUtils.getFontName(),30)
    self._FriendTitle:setColor(cc.c3b(185, 183, 181))
    self._FriendTitle:setPosition(RANK_FRIEND_TITLE_POS)
    self.node:addChild(self._FriendTitle,3)
    self._FriendTitle:show()

    self._RankModelNode = self:createRankCloneNode()
    self._RankModelNode:retain()

    self.node:setPosition(0,375)
 	self:setCPPos(cc.p(0,375),cc.p(667,375))
end

function RankView:setCPPos(hidePos,showPos)
	self.hidePos=hidePos
	self.showPos=showPos
end

--关闭界面
function RankView:closeLayer()
	if self.listener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self.listener)
	end
	local pos=self.hidePos or cc.p(0,375)
	local a={}
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.2, pos))
    a[#a+1] = cc.CallFunc:create(
    	function(sender)
    		if self:getParent().RankViewHide then
    			self:getParent():RankViewHide()
    		end
    		self:removeFromParent()
    	end)
    self.node:stopAllActions()
 	self.node:runAction(cc.Sequence:create(a))
end

--弹出界面
function RankView:popLayer()
	local pos1=self.hidePos or cc.p(0,375)
	local pos2=self.showPos or cc.p(667,375)
	self.node:setPosition(pos1)
	local a={}
	a[#a+1]= cc.EaseSineIn:create(cc.MoveTo:create(0.2, pos2))
	self.node:stopAllActions()
 	self.node:runAction(cc.Sequence:create(a))
end

-- 创建scrollView界面
function RankView:createRichScrollView(rowNum)
	local contentSize = cc.size(RANK_RICH_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (rowNum - 1) * RANK_INTERVAL_V + 11)
    local _RankScrollView = ccui.ScrollView:create()
    _RankScrollView:setTouchEnabled(true)--触摸的属性
    _RankScrollView:setBounceEnabled(true)--弹回的属性
    _RankScrollView:setInertiaScrollEnabled(true)--滑动的惯性
    _RankScrollView:setScrollBarEnabled(false)
    _RankScrollView:setDirection(ccui.ScrollViewDir.vertical)
    _RankScrollView:setContentSize(RANK_RICH_SCROLLVIEW_SIZE)
    _RankScrollView:setInnerContainerSize(contentSize)
    _RankScrollView:setPosition(RANK_RICH_VIEW_POSITION)

    return _RankScrollView
end

function RankView:createFriendScrollView(rowNum)
	local contentSize = cc.size(RANK_FRIEND_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (rowNum - 1) * RANK_INTERVAL_V + 11)
    local _RankScrollView = ccui.ScrollView:create()
    _RankScrollView:setTouchEnabled(true)--触摸的属性
    _RankScrollView:setBounceEnabled(true)--弹回的属性
    _RankScrollView:setInertiaScrollEnabled(true)--滑动的惯性
    _RankScrollView:setScrollBarEnabled(false)
    _RankScrollView:setDirection(ccui.ScrollViewDir.vertical)
    _RankScrollView:setContentSize(RANK_FRIEND_SCROLLVIEW_SIZE)
    _RankScrollView:setInnerContainerSize(contentSize)
    _RankScrollView:setPosition(RANK_FRIEND_VIEW_POSITION)

    return _RankScrollView
end

function RankView:createRankCloneNode()
	local size = cc.size(360, 86)
	local record = ccui.Layout:create()

   	local bg =  ccui.ImageView:create("ranking_player_bg.png", ccui.TextureResType.plistType)
    bg:setContentSize(size)
    bg:setPosition(cc.p(5,0))
    record:addChild(bg)

	local rankingImg = ccui.ImageView:create("ranking_no_1.png", ccui.TextureResType.plistType)
	rankingImg:setPosition(-size.width/2 + 35, 0)
	rankingImg:setTag(RankTag.RANKING_IMG_TAG)
	rankingImg:hide()
	record:addChild(rankingImg)

	local rankingLabel = ccui.TextAtlas:create("","GameLayout/Lobby/Ranking/ranking_no_other.png",32,46,"0")
	rankingLabel:hide()
	rankingLabel:setTag(RankTag.RANKING_LABEL_TAG)
	rankingLabel:setPosition(-size.width/2 + 35, 0)
	record:addChild(rankingLabel)

	local listBtnImg = "ranking_player_bg.png"
	local listBtn = ccui.Button:create(listBtnImg,listBtnImg,listBtnImg,ccui.TextureResType.plistType)
	listBtn:setPosition(0,0)
	listBtn:setOpacity(0)
	listBtn:setTag(RankTag.LIST_BTN_TAG)
	record:addChild(listBtn)

 	local moneyText = GameUtils.createSwitchNumNode(0)
 	moneyText:setTag(RankTag.MONEY_TEXT_TAG)
	moneyText:setPosition(90, -23)
	record:addChild(moneyText)

    return record
end

-- 创建排行榜记录条
function RankView:createRankRecord(ranking,data,__type)
	if data == nil then
		return
	end

	local record = self._RankModelNode:clone()

	local size = cc.size(360, 86)
	
	--local record = ccui.Layout:create()

   	record.ranking = ranking

	if ranking <= 3 then
		local rankingImg = record:getChildByTag(RankTag.RANKING_IMG_TAG)
		local rankingStr = string.format("ranking_no_%d.png",record.ranking)
		rankingImg:show()
		rankingImg:loadTexture(rankingStr, ccui.TextureResType.plistType)
	else
		local rankingLabel = record:getChildByTag(RankTag.RANKING_LABEL_TAG)
		rankingLabel:setString(record.ranking)
		rankingLabel:show()
	end

	local listBtn = record:getChildByTag(RankTag.LIST_BTN_TAG)
	listBtn:addClickEventListener(function()
		local playerInfoView = PlayerInfo.new(data.userId)
		self:getParent():addChild(playerInfoView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
	end)

	local NickName = data.nickName or ""
	NickName = GameUtils.FormotGameNickName(NickName,6)

    local nameText = cc.Label:createWithTTF(NickName,GameUtils.getFontName(),24)
	nameText:setColor(cc.c3b(255,255,255))
    nameText:setAnchorPoint(cc.p(0, 0.5))
    nameText:setPosition(0, 20)
    record:addChild(nameText)

    local Gender = data.gender or 0
    local GenderStr = GameUtils.getDefalutHeadFileByGender(Gender)

    local AvatarUrl = data.avatar or ""
    local awatar = lib.node.Avatar:create({
	 avatarUrl = AvatarUrl,
	 stencilFile = "res/Avatar/head_rect_round_stencil_94_94.png",
	 defalutFile = GenderStr,
	 frameFile = nil,
		})
	awatar:setPosition(-105, -size.height/2-5)
	record:addChild(awatar)

	local moneyText = record:getChildByTag(RankTag.MONEY_TEXT_TAG)
	GameUtils.updateSwitchNumNode(moneyText,data.score or 0)

    return record
end


function RankView:requestRichRankView()
	self._RichListbg:show()
	self._FriendListbg:hide()
	self._RichTitle:setColor(cc.c3b(185, 183, 181))
	self._btnRich:setOpacity(255)
	self._FriendTitle:setColor(cc.c3b(236, 224, 184))
	self._btnFriend:setOpacity(0)

	if self._isRichRankLoaded then
		return
	end

	logic.LobbyRankManager:getInstance():requestRickRankList(function( result )
		if result then
			self:showRichRankView(result)
		end
	end)

end

function RankView:showRichRankView(__rankListData,__isNotLoadAll)
	print("财富排行榜数据")
	dump(__rankListData)
	if __rankListData == nil then
        return
    end

    if self._rickRankScrollView == nil then 
		self._rickRankScrollView = self:createRichScrollView(#__rankListData)
		self._RichListbg:addChild(self._rickRankScrollView)
    end


	local contentSize = cc.size(RANK_RICH_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (#__rankListData - 1) * RANK_INTERVAL_V + 18)
	if contentSize.height < RANK_RICH_SCROLLVIEW_SIZE.height then
		contentSize = RANK_RICH_SCROLLVIEW_SIZE
	end
    local offset = cc.p(0, contentSize.height)
    local PosY = 0

    self._isRichRankLoaded = #__rankListData > 1

    local indexNum = 5
    if not __isNotLoadAll then indexNum = #__rankListData end
	for i, v in ipairs(__rankListData) do
		if i <= indexNum then 
	        local record = self:createRankRecord(i,v,ConstantsData.RankType.RANK_RICK)
	        local row = i
	        local x = offset.x +RECORD_SIZE.width/2 + 7
	        local y = 50 + offset.y - row * RANK_INTERVAL_V
	        record:setPosition(x,y)
	        self._rickRankScrollView:addChild(record)
		end
    end
end

function RankView:loadAll( ... )
 
end

function RankView:requestFriendRankView()
	self._RichListbg:hide()
	self._FriendListbg:show()
	self._RichTitle:setColor(cc.c3b(236, 224, 184))
	self._btnRich:setOpacity(0)
	self._FriendTitle:setColor(cc.c3b(185, 183, 181))
	self._btnFriend:setOpacity(255)

	if self._isFriendRankListLoaded  then return end

	logic.LobbyRankManager:getInstance():requestFriendRankList(function( result )
		if result then
			self:showFriendRankView(result)
		end
	end)

end

function RankView:showFriendRankView(__rankListData)
	dump(__rankListData)
	if __rankListData == nil then
        return
    end

	self._rickRankScrollView = self:createFriendScrollView(#__rankListData)
	self._FriendListbg:addChild(self._rickRankScrollView)

	local contentSize = cc.size(RANK_FRIEND_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (#__rankListData - 1) * RANK_INTERVAL_V + 18)
	if contentSize.height < RANK_FRIEND_SCROLLVIEW_SIZE.height then
		contentSize = RANK_FRIEND_SCROLLVIEW_SIZE
	end
    local offset = cc.p(0, contentSize.height)
    local PosY = 0

    self._isFriendRankListLoaded = #__rankListData > 0
	for k, v in ipairs(__rankListData) do
        local record= self:createRankRecord(k,v,ConstantsData.RankType.RANK_FRIEND)
        local row = k
        local x = offset.x +RECORD_SIZE.width/2 + 7
        local y =51 + offset.y - row * RANK_INTERVAL_V
        record:setPosition(x,y)
        self._rickRankScrollView:addChild(record)
    end
end

function RankView:onEnter()
	self:popLayer()
	self:_addTouchEvent()
	self:addEventListerns()

	-- self:requestRichRankView()
	if self._RichListbg then
        local size = self._RichListbg:getContentSize()
        GameUtils.comeOutEffectSlower(self,manager.ViewManager:getInstance():findLobbyComeOutEffectTime(),size,GameUtils.COMEOUT_LEFT,handler(self,self.requestRichRankView))
    end
end

function RankView:onExit()
	self:_removeTouchEvent()
	self:removeEventListeners()
	if self._RankModelNode then self._RankModelNode:release() self._RankModelNode = nil end
end

return RankView