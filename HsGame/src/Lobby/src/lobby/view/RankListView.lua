-- 排行榜
-- @date 2017.08.05
-- @author tangwen

local RankListView = class("RankListView", function()
	return display.newNode()
end)

local PlayerInfo = require "PlayerInfoView"

-- 这里初始化所有滑动界面信息，如有特殊的单独处理
local LIST_RECORD_SIZE = cc.size(378,111)   			--滑动界面节点大小 记录节点大小 
local RANK_INTERVAL = 113   --每条记录之间的间距 竖 
local RANK_LIST_POS = cc.p(-595,0)
local RANK_LIST_SCROLLVIEW_SIZE = cc.size(130,385) -- 排行榜滑动界面大小
local RECORDLIST_SIZE = cc.size(94,94)   			--滑动界面节点大小 记录节点大小 

function RankListView:ctor()
	self:setPosition(display.cx,display.cy)
	self:enableNodeEvents() 
	self:initListView()
	self._rickRankScrollView = nil
end

function RankListView:initListView( ... )
	self._RankListbg = ccui.ImageView:create("rankingList_bg.png", ccui.TextureResType.plistType)
    self._RankListbg:setAnchorPoint(cc.p(0.5, 0.5))
    self._RankListbg:setPosition(RANK_LIST_POS)
    self:addChild(self._RankListbg)

    self._RankPhb = ccui.ImageView:create("rankingList_phb.png", ccui.TextureResType.plistType)
    self._RankPhb:setAnchorPoint(cc.p(0.5, 0.5))
    self._RankPhb:setPosition(self._RankListbg:getContentSize().width/2-5,50)
    self._RankListbg:addChild(self._RankPhb)

    self._RankOut = ccui.ImageView:create("rankingList_out.png", ccui.TextureResType.plistType)
    self._RankOut:setAnchorPoint(cc.p(0.5, 0.5))
    self._RankOut:setPosition(self._RankListbg:getContentSize().width-12,self._RankListbg:getContentSize().height/2+5)
    self._RankListbg:addChild(self._RankOut)

    logic.LobbyRankManager:getInstance():requestRickRankList(function( result )
		if result then
			self:showRichRankListView(result)
		end
	end)
end

function RankListView:showRichRankListView( __rankListData,__isNotLoadAll )
	if __rankListData == nil then
        return
    end

    if self._rickRankScrollView == nil then 
		self._rickRankScrollView = self:createRichScrollListView(#__rankListData)
		self._RankListbg:addChild(self._rickRankScrollView)
    end


	local contentSize = cc.size(RANK_LIST_SCROLLVIEW_SIZE.width, RECORDLIST_SIZE.height + (#__rankListData - 1) * RANK_INTERVAL + 18)
	if contentSize.height < RANK_LIST_SCROLLVIEW_SIZE.height then
		contentSize = RANK_LIST_SCROLLVIEW_SIZE
	end
    local offset = cc.p(0, contentSize.height)
    local PosY = 0

    local indexNum = 5
    if not __isNotLoadAll then indexNum = #__rankListData end
	for i, v in ipairs(__rankListData) do
		if i <= indexNum then 
	        local record = self:createRankListRecord(i,v,ConstantsData.RankType.RANK_RICK)
	        local row = i
	        local x = offset.x +LIST_RECORD_SIZE.width/2 + 7
	        local y = 50 + offset.y - row * RANK_INTERVAL + 65
	        record:setPosition(x,y)
	        self._rickRankScrollView:addChild(record)
		end
    end
end

-- 创建scrollView界面(LIST)
function RankListView:createRichScrollListView(rowNum)
	local contentSize = cc.size(RANK_LIST_SCROLLVIEW_SIZE.width, LIST_RECORD_SIZE.height + (rowNum - 1) * RANK_INTERVAL + 11)
    local _RankScrollView = ccui.ScrollView:create()
    _RankScrollView:setTouchEnabled(true)--触摸的属性
    _RankScrollView:setBounceEnabled(true)--弹回的属性
    _RankScrollView:setInertiaScrollEnabled(true)--滑动的惯性
    _RankScrollView:setScrollBarEnabled(false)
    _RankScrollView:setDirection(ccui.ScrollViewDir.vertical)
    _RankScrollView:setContentSize(RANK_LIST_SCROLLVIEW_SIZE)
    _RankScrollView:setInnerContainerSize(contentSize)
    _RankScrollView:setPosition(-22,95)

    return _RankScrollView
end

-- 创建排行榜记录条(LIST)
function RankListView:createRankListRecord(ranking,data,__type)
	if data == nil then
		return
	end

	local size = cc.size(94, 94)
	local record = ccui.Layout:create()
	local listBtnImg = "res/Avatar/head_rect_round_stencil_94_94.png"
	local listBtn = ccui.Button:create(listBtnImg,listBtnImg,listBtnImg,ccui.TextureResType.localType)
	listBtn:setPosition(-112, -size.height/2)
	listBtn:setOpacity(0)
	listBtn:addClickEventListener(function()
		local playerInfoView = PlayerInfo.new(data.userId)
		self:getParent():addChild(playerInfoView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
	end)
	record:addChild(listBtn)

	local Gender = data.Gender or 0
    local GenderStr = GameUtils.getDefalutHeadFileByGender(Gender)

    local AvatarUrl = data.AvatarUrl or ""
    local awatar = lib.node.Avatar:create({
	 avatarUrl = AvatarUrl,
	 stencilFile = "res/Avatar/head_rect_round_stencil_94_94.png",
	 defalutFile = GenderStr,
	 frameFile = nil,
		})
	awatar:setPosition(0,0)
	listBtn:addChild(awatar)



    return record
end

function RankListView:onEnter()
	-- self:requestRichRankView()
	if self._RichListbg then
        local size = self._RichListbg:getContentSize()
        GameUtils.comeOutEffectSlower(self,manager.ViewManager:getInstance():findLobbyComeOutEffectTime(),size,GameUtils.COMEOUT_LEFT,handler(self,self.requestRichRankView))
    end
end

function RankListView:onExit()
	if self._RankModelNode then self._RankModelNode:release() self._RankModelNode = nil end
end

return RankListView