--[[--
@author fly
]]

local ChessesDetail = class("ChessesDetail",lib.layer.BaseLayer)

function ChessesDetail:ctor( ... )
	self:addChild(cc.LayerColor:create(cc.c4b(10,10,10,100),display.width,display.height))
	ChessesDetail.super.ctor(self)
	self:initView()


end

function ChessesDetail:initView( ... )
	-- 721 659
	local size = cc.size(721,659)
	local lCDBg = ccui.Scale9Sprite:createWithSpriteFrameName("LCDBg.png",cc.rect(166,120,20,4))
	lCDBg:setContentSize(size)
	self:addChild(lCDBg)
	lCDBg:setAnchorPoint(0,0)
	lCDBg:setPosition(312,44)

	-- local lCDTitle = ccui.ImageView:create("LCDTitle.png",ccui.TextureResType.plistType)
	-- lCDTitle:setPosition(size.width / 2,size.height - 22)
	-- lCDBg:addChild(lCDTitle)

	local titleBg = ccui.ImageView:create("res/common/common_title_bg.png")
    titleBg:setPosition(size.width/2, size.height - 22)
    lCDBg:addChild(titleBg)

    local title = cc.Label:createWithTTF("牌局详情",GameUtils.getFontName(), 36)
    title:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2+3)
    title:setTextColor(cc.c3b(141,62,30))
    title:enableOutline(cc.c3b(255, 250, 152),2)
    titleBg:addChild(title)

	local imgFile = self:_findBackBtnFile()
	local button = ccui.Button:create(imgFile,imgFile,imgFile)
	button:setPressedActionEnabled(true)
	button:addClickEventListener(handler(self,self.back))
	lCDBg:addChild(button)
	button:setPosition(size.width -40,size.height-30)

	self:_addDesc(lCDBg)
	self:_addGamersList(lCDBg)
end

function ChessesDetail:_addDesc( __bg )
	local manager = lobby.CreateRoomManager:getInstance()
	local size = cc.size(655,91)
	local lCDDescFrame = ccui.Scale9Sprite:createWithSpriteFrameName("LCDDescFrame.png",cc.rect(16,16,4,4))
	lCDDescFrame:setContentSize(size)
	__bg:addChild(lCDDescFrame)
	lCDDescFrame:setAnchorPoint(0,0)
	lCDDescFrame:setPosition(30,483)

	local labelColor = cc.c3b(115,99,192)
	local valueColor = cc.c3b(224,221,245)
	local data = manager:findSelectedData()
	local topHeight = 60
	local buttonHeight = 28
	local params = {
		{fontName = GameUtils.getFontName(),fontSize = 19,text = manager:findRoomIdString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = labelColor,pos = cc.p(90,topHeight),anchorPoint = cc.p(1,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 19,text = tostring(data.roomId),alignment = cc.TEXT_ALIGNMENT_CENTER,color = valueColor,pos = cc.p(93,topHeight),anchorPoint = cc.p(0,0.5)},
		
		-- 创建者
		{fontName = GameUtils.getFontName(),fontSize = 19,text = manager:findCreateLabelName(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = labelColor,pos = cc.p(306,topHeight),anchorPoint = cc.p(1,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 19,text = data.createrName,alignment = cc.TEXT_ALIGNMENT_CENTER,color = valueColor,pos = cc.p(316,topHeight),anchorPoint = cc.p(0,0.5)},
		
		-- 时间
		{fontName = GameUtils.getFontName(),fontSize = 19,text = manager:findTimeLabelString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = labelColor,pos = cc.p(510,topHeight),anchorPoint = cc.p(1,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 19,text = data.timeOfCreateRoom,alignment = cc.TEXT_ALIGNMENT_CENTER,color = textColor,pos = cc.p(513,topHeight),anchorPoint = cc.p(0,0.5)},

		--局数
		{fontName = GameUtils.getFontName(),fontSize = 19,text = manager:findChessNumString("   "),alignment = cc.TEXT_ALIGNMENT_CENTER,color = labelColor,pos = cc.p(90,buttonHeight),anchorPoint = cc.p(1,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 19,text = tostring(data.gameRound),alignment = cc.TEXT_ALIGNMENT_CENTER,color = valueColor,pos = cc.p(93,buttonHeight),anchorPoint = cc.p(0,0.5)},
		
		-- 底分
		{fontName = GameUtils.getFontName(),fontSize = 19,text = manager:findMinScoreString("   "),alignment = cc.TEXT_ALIGNMENT_CENTER,color = labelColor,pos = cc.p(306,buttonHeight),anchorPoint = cc.p(1,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 19,text = data.gameBet,alignment = cc.TEXT_ALIGNMENT_CENTER,color = valueColor,pos = cc.p(316,buttonHeight),anchorPoint = cc.p(0,0.5)},
		
		-- 算牛
		{fontName = GameUtils.getFontName(),fontSize = 19,text = manager:findComNiuLabelString(),alignment = cc.TEXT_ALIGNMENT_CENTER,color = labelColor,pos = cc.p(510,buttonHeight),anchorPoint = cc.p(1,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 19,text = data.isAutoNiu and "自动" or "手动",alignment = cc.TEXT_ALIGNMENT_CENTER,color = valueColor,pos = cc.p(513,buttonHeight),anchorPoint = cc.p(0,0.5)},
	}	


	for i=1,#params do
		local param = params[i]
		local label = cc.exports.lib.uidisplay.createLabel(param)
		lCDDescFrame:addChild(label)
	end
end

function ChessesDetail:_addGamersList( __bg )
	local ManagerClazz = cc.exports.lobby.CreateRoomManager
	if self._listView == nil then
		self._listView = ccui.ListView:create()
		self._listView:setContentSize(cc.size(680,447))
		self._listView:setAnchorPoint(cc.p(0,0))
		self._listView:setDirection(ccui.ListViewDirection.vertical)
		self._listView:setScrollBarEnabled(false)
		__bg:addChild(self._listView)
		self._listView:setPosition(23,24)
	end

	self._listView:removeAllChildren()
	local items = ManagerClazz:getInstance():findDetailListGamers()
	for i=1,#items do
		local data = items[i]
		local itemNode = self:_createItem(data,i)
		self._listView:pushBackCustomItem(itemNode)
	end
end
		-- gameId = 1,
		-- gamerName = "",
		-- avatar = "",
		-- score = 1000,
		-- flag = 0
function ChessesDetail:_createItem( __data,__index )
	local layout = ccui.Widget:create()

	local itemBg = ccui.ImageView:create("LCDItem.png",ccui.TextureResType.plistType)
	local size = itemBg:getContentSize()
	layout:setContentSize(cc.size(size.width,size.height + 10))
	itemBg:setPosition(size.width/2,size.height / 2 + 5)
	
	local path = GameUtils.getDefalutHeadFileByGender(__data.gender)
	local awatar = lib.node.Avatar:create({
	 avatarUrl = __data.avatarUrl,
	 stencilFile = "res/Avatar/head_circle_stencil_94_94.png",
	 defalutFile = path,
	 frameFile = "Lobby/res/Avatar/LCDAwatarFrame.png",
		})
	awatar:setPosition(40,size.height / 2)
	awatar:setAnchorPoint(cc.p(0.5,0.5))
	awatar:setScale(61/awatar:getContentSize().width)
	itemBg:addChild(awatar)

	local scoreStr = "+" ..__data.score
	local scoreLabelColor = cc.c3b(255,236,109)
	if __data.score < 0 then
		scoreStr = "" ..__data.score
		scoreLabelColor = cc.c3b(80,209,250)
	end

	local params = {
		{fontName = GameUtils.getFontName(),fontSize = 23,text =__data.gamerName ,alignment = cc.TEXT_ALIGNMENT_CENTER,color = cc.c3b(255,255,255),pos = cc.p(86,36),anchorPoint = cc.p(0,0.5)},
		{fontName = GameUtils.getFontName(),fontSize = 23,text =scoreStr ,alignment = cc.TEXT_ALIGNMENT_CENTER,color = scoreLabelColor,pos = cc.p(491,36),anchorPoint = cc.p(0,0.5)},
	}
	for i=1,#params do
		local param = params[i]
		local label = cc.exports.lib.uidisplay.createLabel(param)
		itemBg:addChild(label)
	end
	layout:addChild(itemBg)
	return layout
end


function ChessesDetail:_findBackBtnFile( ... )
	return "res/common/common_btn_close.png"
end

return ChessesDetail