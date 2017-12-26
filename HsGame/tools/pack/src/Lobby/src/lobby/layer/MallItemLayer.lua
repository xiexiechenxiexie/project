--[[
    名称  :   MallItemLayer  商城商品分类页面
    作者  :   Xiaxb   
    描述  :   MallItemLayer 	商城商品分类页面
    时间  :   2017-8-07
--]]

-- 金币购买界面
local MallItemGold = class("MallItemGold", ccui.ImageView)

function MallItemGold:ctor(line, mallDataList)
	-- print("MallItemGold:ctor")
	-- MallItemGold.super.ctor(self)
	if mallDataList then
		self:_initView(line, mallDataList)
	end
end

-- 初始化视图
function MallItemGold:_initView(line, mallDataList)
	self:setContentSize(cc.size(980, 311))
	self:loadTexture("TP/Mall/mall_item_bg.png", ccui.TextureResType.plistType)

	for i=1, 3 do

		local index = (line - 1) * 3 + i

		if not mallDataList[index] then
			return
		end

		-- 商品背景
		local itemGoldBg = ccui.ImageView:create("TP/Mall/mall_item_goods_bg.png", ccui.TextureResType.plistType)
		itemGoldBg:setPosition(cc.p((self:getContentSize().width - 30)* (1/3*i) - itemGoldBg:getContentSize().width/2, self:getContentSize().height/2 - 10))
		self:addChild(itemGoldBg)

		-- print("xiaxb----------index:" .. index)
		-- dump(mallDataList[index], "mallDataList[index]")
		-- 商品特惠标签
		if 2 == mallDataList[index].tag then
			local itemGoldSaleFlag = ccui.ImageView:create("TP/Mall/mall_sale_flag.png", ccui.TextureResType.plistType)
			itemGoldSaleFlag:setPosition(cc.p(itemGoldSaleFlag:getContentSize().width/2+10, itemGoldBg:getContentSize().height - itemGoldSaleFlag:getContentSize().height/2 + 5))
			itemGoldBg:addChild(itemGoldSaleFlag)
		end

		-- 商品名称
		local itemGoldName = ccui.Text:create()
		itemGoldName:setText(mallDataList[index].goodsName)
		itemGoldName:setFontSize(26)
		itemGoldName:setTextColor(cc.c4b(255, 255, 255, 255))
		itemGoldName:setAnchorPoint(cc.p(1, 0.5))
		itemGoldName:setPosition(cc.p(itemGoldBg:getContentSize().width - 35, itemGoldBg:getContentSize().height - 35))
		itemGoldName:setFontName(GameUtils.getFontName())
		itemGoldBg:addChild(itemGoldName)

		-- 商品图片
		-- local itemGoldIcon = ccui.ImageView:create("TP/Mall/mall_item_gold_1.png")
		-- itemGoldIcon:setPosition(cc.p(itemGoldBg:getContentSize().width/2, itemGoldBg:getContentSize().height*0.6))
		-- itemGoldBg:addChild(itemGoldIcon)

		local itemGoldIcon = lib.node.RemoteImageView:create("TP/Mall/mall_item_gold.png", ccui.TextureResType.plistType)
		itemGoldIcon:setDownloadParams({
			dir = "mall",
			url = mallDataList[index].imageUrl
		})
		itemGoldIcon:setPosition(cc.p(itemGoldBg:getContentSize().width/2, itemGoldBg:getContentSize().height*0.6))
		itemGoldBg:addChild(itemGoldIcon)

		-- 赠送金币文字图片
		local itemGoldTitleSend = ccui.ImageView:create("TP/Mall/mall_item_gold_title_send.png", ccui.TextureResType.plistType)
		itemGoldTitleSend:setPosition(cc.p(itemGoldBg:getContentSize().width/2, itemGoldBg:getContentSize().height*0.35))
		itemGoldBg:addChild(itemGoldTitleSend)

		-- 赠送金币数量
		local itemGoldTextSendNum = ccui.TextAtlas:create(GameUtils.formatMoneyNumber(tostring(mallDataList[index].number)), "res/GameLayout/Mall/mall_txt_num.png", 18, 24, ".")
		itemGoldTextSendNum:setPosition(cc.p(itemGoldBg:getContentSize().width / 2, itemGoldBg:getContentSize().height * 0.25))
		itemGoldBg:addChild(itemGoldTextSendNum)

		-- 购买button
		local itemGoldBtnBuy = ccui.Button:create()
		itemGoldBtnBuy:loadTextureNormal("TP/Mall/mall_item_goods_btn_buy.png", ccui.TextureResType.plistType)
		itemGoldBtnBuy:setTag(index)
		itemGoldBtnBuy:setPressedActionEnabled(true)
		itemGoldBtnBuy:setPosition(cc.p(itemGoldBg:getContentSize().width/2, itemGoldBg:getContentSize().height * 0.05))
		itemGoldBg:addChild(itemGoldBtnBuy, 5)

		local function btnBuyCallback(sender)
			Mall.MallManager:getInstance():buyGoods(mallDataList[sender:getTag()])
		end
		itemGoldBtnBuy:addClickEventListener(btnBuyCallback)

		-- 购买图标
		local itemGoldBtnBuyIcon = ccui.ImageView:create("TP/Mall/mall_item_gold_btn_buy_icon.png", ccui.TextureResType.plistType)
		itemGoldBtnBuyIcon:setPosition(cc.p(itemGoldBtnBuy:getContentSize().width*0.2, itemGoldBtnBuy:getContentSize().height/2))
		itemGoldBtnBuy:addChild(itemGoldBtnBuyIcon)

		-- 购买文字
		local itemGoldBtnBuyText = ccui.Text:create()
		itemGoldBtnBuyText:setText(tostring(GameUtils.getIntPart(tonumber(mallDataList[index].amount))))
		itemGoldBtnBuyText:setFontSize(36)
		itemGoldBtnBuyText:setTextColor(cc.c4b(255, 255, 255, 255))
		-- itemGoldName:setAnchorPoint(cc.p(1, 0.5))
		itemGoldBtnBuyText:setPosition(cc.p(itemGoldBtnBuy:getContentSize().width*0.6, itemGoldBtnBuy:getContentSize().height*0.55))
		itemGoldBtnBuyText:setFontName(GameUtils.getFontName())
		itemGoldBtnBuy:addChild(itemGoldBtnBuyText)

		-- 商品射灯
		local itemLight = ccui.ImageView:create("TP/Mall/mall_item_light.png", ccui.TextureResType.plistType)
		itemLight:setPosition(cc.p(itemGoldBg:getContentSize().width/2, itemGoldBg:getContentSize().height - itemLight:getContentSize().height/2 + 25))
		itemGoldBg:addChild(itemLight)
	end
end

-- *************************我只是分割线******************************** --

-- 购钻石界面
local MallItemDiamond = class("MallItemDiamond", ccui.ImageView)

function MallItemDiamond:ctor(line, mallDataList)
	-- print("MallItemDiamond:ctor")
	-- MallItemGold.super.ctor(self)
	if mallDataList then 
		self:_initView(line, mallDataList)
	end
end

-- 初始化视图
function MallItemDiamond:_initView(line, mallDataList)
	self:setContentSize(cc.size(980, 311))
	self:loadTexture("TP/Mall/mall_item_bg.png", ccui.TextureResType.plistType)

	for i=1, 3 do

		local index = (line - 1) * 3 + i

		if not mallDataList[index] then
			return
		end

		-- 商品背景
		local itemDiamondBg = ccui.ImageView:create("TP/Mall/mall_item_goods_bg.png", ccui.TextureResType.plistType)
		itemDiamondBg:setPosition(cc.p((self:getContentSize().width - 30)* (1/3*i) - itemDiamondBg:getContentSize().width/2, self:getContentSize().height/2 - 10))
		self:addChild(itemDiamondBg)

		-- 商品特惠标签
		if 2 == mallDataList[index].tag then
			local itemDiamondSaleFlag = ccui.ImageView:create("TP/Mall/mall_sale_flag.png", ccui.TextureResType.plistType)
			itemDiamondSaleFlag:setPosition(cc.p(itemDiamondSaleFlag:getContentSize().width/2+10, itemDiamondBg:getContentSize().height - itemDiamondSaleFlag:getContentSize().height/2 + 5))
			itemDiamondBg:addChild(itemDiamondSaleFlag)
		end

		-- 商品名称
		local itemDiamondName = ccui.Text:create()
		itemDiamondName:setText(mallDataList[index].goodsName)
		itemDiamondName:setFontSize(26)
		itemDiamondName:setTextColor(cc.c4b(255, 255, 255, 255))
		itemDiamondName:setAnchorPoint(cc.p(1, 0.5))
		itemDiamondName:setPosition(cc.p(itemDiamondBg:getContentSize().width - 35, itemDiamondBg:getContentSize().height - 35))
		itemDiamondName:setFontName(GameUtils.getFontName())
		itemDiamondBg:addChild(itemDiamondName)

		-- 商品图片
		-- local itemDiamondIcon = ccui.ImageView:create("TP/Mall/mall_item_diamond_1.png")
		-- itemDiamondIcon:setPosition(cc.p(itemDiamondBg:getContentSize().width/2, itemDiamondBg:getContentSize().height*0.5))
		-- itemDiamondBg:addChild(itemDiamondIcon)

		local itemDiamondIcon = lib.node.RemoteImageView:create("TP/Mall/mall_item_diamond.png", ccui.TextureResType.plistType)
		itemDiamondIcon:setDownloadParams({
			dir = "mall",
			url = mallDataList[index].imageUrl
		})
		itemDiamondIcon:setPosition(cc.p(itemDiamondBg:getContentSize().width/2, itemDiamondBg:getContentSize().height*0.5))
		itemDiamondBg:addChild(itemDiamondIcon)

		-- 赠送金币文字图片
		-- local itemDiamondTitleSend = ccui.ImageView:create("TP/Mall/mall_item_diamond_title_send.png")
		-- itemDiamondTitleSend:setPosition(cc.p(itemDiamondBg:getContentSize().width/2, itemDiamondBg:getContentSize().height*0.35))
		-- itemDiamondBg:addChild(itemDiamondTitleSend)

		-- 赠送金币数量
		-- local itemDiamondTextSendNum = ccui.TextAtlas:create("66/000", "TP/Mall/mall_item_gold_send_num.png", 20, 26, "/")
		-- itemDiamondTextSendNum:setPosition(cc.p(itemDiamondBg:getContentSize().width / 2, itemDiamondBg:getContentSize().height * 0.25))
		-- itemDiamondBg:addChild(itemDiamondTextSendNum)

		-- 购买button
		local itemDiamondBtnBuy = ccui.Button:create()
		itemDiamondBtnBuy:loadTextureNormal("TP/Mall/mall_item_goods_btn_buy.png", ccui.TextureResType.plistType)
		itemDiamondBtnBuy:setTag(index)
		itemDiamondBtnBuy:setPosition(cc.p(itemDiamondBg:getContentSize().width/2, itemDiamondBg:getContentSize().height * 0.05))
		itemDiamondBg:addChild(itemDiamondBtnBuy)

		local function btnBuyCallback(sender)
			-- body
			-- dump(mallDataList[sender:getTag()], "xiaxb------------menuData")
			-- print(mallDataList[sender:getTag()].appleProductIdentifier)

			-- local function payCallback( ... )
			-- 	print("xiaxb----------payCallback")
			-- end

			-- local iap = config.SDKConfig.IAP
			-- iap.info = mallDataList[sender:getTag()].appleProductIdentifier
			-- print("xiaxb--------------buy------id:" .. mallDataList[sender:getTag()].goodsId)


			-- Mall.MallManager:getInstance():getGoodsOrder("wx", mallDataList[sender:getTag()].id)
			-- MultiPlatform:getInstance():thirdPartyPay(config.SDKConfig.ThirdParty.IAP, {appleProductIdentifier = mallDataList[sender:getTag()].appleProductIdentifier}, payCallback)

			-- Mall.MallManager:getInstance():buyGoods(mallDataList[sender:getTag()].payment, mallDataList[sender:getTag()].appleProductIdentifier, mallDataList[sender:getTag()].id)	
			Mall.MallManager:getInstance():buyGoods(mallDataList[sender:getTag()])
		end
		itemDiamondBtnBuy:addClickEventListener(btnBuyCallback)

		-- 购买图标
		-- local itemDiamondBtnBuyIcon = ccui.ImageView:create("TP/Mall/mall_item_gold_btn_buy_icon.png")
		-- itemDiamondBtnBuyIcon:setPosition(cc.p(itemDiamondBtnBuy:getContentSize().width*0.2, itemDiamondBtnBuy:getContentSize().height/2))
		-- itemDiamondBtnBuy:addChild(itemDiamondBtnBuyIcon)

		-- 购买价格文字
		local itemDiamondBtnBuyText = ccui.Text:create()
		itemDiamondBtnBuyText:setText(mallDataList[index].amount .. "元")
		itemDiamondBtnBuyText:setFontSize(36)
		itemDiamondBtnBuyText:setTextColor(cc.c4b(255, 255, 255, 255))
		-- itemGoldName:setAnchorPoint(cc.p(1, 0.5))
		itemDiamondBtnBuyText:setPosition(cc.p(itemDiamondBtnBuy:getContentSize().width/2, itemDiamondBtnBuy:getContentSize().height*0.55))
		itemDiamondBtnBuyText:setFontName(GameUtils.getFontName())
		itemDiamondBtnBuy:addChild(itemDiamondBtnBuyText)

		-- 商品射灯
		local itemLight = ccui.ImageView:create("TP/Mall/mall_item_light.png", ccui.TextureResType.plistType)
		itemLight:setPosition(cc.p(itemDiamondBg:getContentSize().width/2, itemDiamondBg:getContentSize().height - itemLight:getContentSize().height/2 + 25))
		itemDiamondBg:addChild(itemLight)
	end
end

-- *************************我只是分割线******************************** --

-- 购房卡界面
local MallItemRoomCard = class("MallItemRoomCard", ccui.ImageView)

function MallItemRoomCard:ctor(line, mallDataList)
	-- print("MallItemRoomCard:ctor")
	-- MallItemGold.super.ctor(self)
	if mallDataList then
		self:_initView(line, mallDataList)
	end
end

-- 初始化视图
function MallItemRoomCard:_initView(line, mallDataList)
	self:setContentSize(cc.size(980, 311))
	-- local itemBg = ccui.ImageView:create("TP/Mall/mall_item_bg.png")
	-- itemBg:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
	-- self:addChild(itemBg)
	self:loadTexture("TP/Mall/mall_item_bg.png", ccui.TextureResType.plistType)
	for i=1, 3 do

		local index = (line - 1) * 3 + i

		if not mallDataList[index] then
			return
		end

		-- 商品背景
		local itemRoomCardBg = ccui.ImageView:create("TP/Mall/mall_item_goods_bg.png", ccui.TextureResType.plistType)
		itemRoomCardBg:setPosition(cc.p((self:getContentSize().width - 30)* (1/3*i) - itemRoomCardBg:getContentSize().width/2, self:getContentSize().height/2 - 10))
		self:addChild(itemRoomCardBg)

		-- 商品特惠标签
		if 2 == mallDataList[index].tag then
			local itemRoomCardSaleFlag = ccui.ImageView:create("TP/Mall/mall_sale_flag.png", ccui.TextureResType.plistType)
			itemRoomCardSaleFlag:setPosition(cc.p(itemRoomCardSaleFlag:getContentSize().width/2+10, itemRoomCardBg:getContentSize().height - itemRoomCardSaleFlag:getContentSize().height/2 + 5))
			itemRoomCardBg:addChild(itemRoomCardSaleFlag)
		end

		-- 商品名称
		local itemRoomCardName = ccui.Text:create()
		itemRoomCardName:setText(mallDataList[index].goodsName)
		itemRoomCardName:setFontSize(26)
		itemRoomCardName:setTextColor(cc.c4b(255, 255, 255, 255))
		itemRoomCardName:setAnchorPoint(cc.p(1, 0.5))
		itemRoomCardName:setPosition(cc.p(itemRoomCardBg:getContentSize().width - 35, itemRoomCardBg:getContentSize().height - 35))
		itemRoomCardName:setFontName(GameUtils.getFontName())
		itemRoomCardBg:addChild(itemRoomCardName)

		-- 商品图片
		-- local itemRoomCardIcon = ccui.ImageView:create("TP/Mall/mall_item_room_card_1.png")
		-- itemRoomCardIcon:setPosition(cc.p(itemRoomCardBg:getContentSize().width/2, itemRoomCardBg:getContentSize().height*0.6))
		-- itemRoomCardBg:addChild(itemRoomCardIcon)

		local itemRoomCardIcon = lib.node.RemoteImageView:create("TP/Mall/mall_item_room_card.png", ccui.TextureResType.plistType)
		itemRoomCardIcon:setDownloadParams({
			dir = "mall",
			url = mallDataList[index].imageUrl
		})
		-- itemRoomCardIcon:setPosition(cc.p(itemRoomCardBg:getContentSize().width/2, itemRoomCardBg:getContentSize().height*0.6))
		itemRoomCardBg:addChild(itemRoomCardIcon)

		if 0 < mallDataList[index].date then
			itemRoomCardIcon:setPosition(cc.p(itemRoomCardBg:getContentSize().width/2, itemRoomCardBg:getContentSize().height*0.55))
			-- 有效期文字图片
			local itemRoomCardDate = ccui.ImageView:create("TP/Mall/mall_item_room_card_title_date.png", ccui.TextureResType.plistType)

			-- itemRoomCardDate:setPosition(cc.p(itemRoomCardBg:getContentSize().width*0.32, itemRoomCardBg:getContentSize().height*0.3))
			-- itemRoomCardBg:addChild(itemRoomCardDate)

			-- 剩余天数
			local itemRoomCardTextDate = ccui.TextAtlas:create(tostring(mallDataList[index].date), "res/GameLayout/Mall/mall_txt_num.png", 18, 24, ".")

			-- itemRoomCardTextDate:setPosition(cc.p(itemRoomCardBg:getContentSize().width * 0.55, itemRoomCardBg:getContentSize().height * 0.31))
			-- itemRoomCardBg:addChild(itemRoomCardTextDate)

			-- 天文字图片
			local itemRoomCardDay = ccui.ImageView:create("TP/Mall/mall_item_room_card_title_days.png", ccui.TextureResType.plistType)

			-- itemRoomCardDay:setPosition(cc.p(itemRoomCardBg:getContentSize().width*0.72, itemRoomCardBg:getContentSize().height*0.3))
			-- itemRoomCardBg:addChild(itemRoomCardDay)


			local totalWidth = itemRoomCardDate:getContentSize().width + itemRoomCardTextDate:getContentSize().width + itemRoomCardDay:getContentSize().width

			local dateX = itemRoomCardBg:getContentSize().width/2 - totalWidth/2

			itemRoomCardDate:setAnchorPoint(cc.p(0, 0.5))
			itemRoomCardDate:setPosition(cc.p(dateX - 5, itemRoomCardBg:getContentSize().height*0.3))
			itemRoomCardBg:addChild(itemRoomCardDate)

			local textDateX = itemRoomCardBg:getContentSize().width/2 - totalWidth/2 + itemRoomCardDate:getContentSize().width + itemRoomCardTextDate:getContentSize().width/2

			itemRoomCardTextDate:setPosition(cc.p(textDateX, itemRoomCardBg:getContentSize().height * 0.31))
			itemRoomCardBg:addChild(itemRoomCardTextDate)

			local dayX = itemRoomCardBg:getContentSize().width/2 + totalWidth/2

			itemRoomCardDay:setAnchorPoint(cc.p(1, 0.5))
			itemRoomCardDay:setPosition(cc.p(dayX + 5, itemRoomCardBg:getContentSize().height*0.3))
			itemRoomCardBg:addChild(itemRoomCardDay)
		else
			
			itemRoomCardIcon:setPosition(cc.p(itemRoomCardBg:getContentSize().width/2, itemRoomCardBg:getContentSize().height*0.5))
		end

		-- 购买button
		local itemRoomCardBtnBuy = ccui.Button:create()
		itemRoomCardBtnBuy:loadTextureNormal("TP/Mall/mall_item_goods_btn_buy.png", ccui.TextureResType.plistType)
		itemRoomCardBtnBuy:setTag(index)-- itemRoomCardBtnBuy:setUserObject(itemData)
		itemRoomCardBtnBuy:setPosition(cc.p(itemRoomCardBg:getContentSize().width/2, itemRoomCardBg:getContentSize().height * 0.05))
		itemRoomCardBg:addChild(itemRoomCardBtnBuy)

		-- local itemData = mallDataList[index]
		-- itemRoomCardBtnBuy:setUserData(itemData)

		local function btnBuyCallback(sender)
			-- body
			-- dump(mallDataList[sender:getTag()], "xiaxb------------menuData")
			Mall.MallManager:getInstance():buyGoods(mallDataList[sender:getTag()])
		end
		itemRoomCardBtnBuy:addClickEventListener(btnBuyCallback)

		-- 购买图标
		local itemRoomCardBtnBuyIcon = ccui.ImageView:create("TP/Mall/mall_item_gold_btn_buy_icon.png", ccui.TextureResType.plistType)
		itemRoomCardBtnBuyIcon:setPosition(cc.p(itemRoomCardBtnBuy:getContentSize().width*0.2, itemRoomCardBtnBuy:getContentSize().height/2))
		itemRoomCardBtnBuy:addChild(itemRoomCardBtnBuyIcon)

		-- 房卡限时免费
		if 1 == mallDataList[index].tag then

			local itemRoomCardBtnBuyText = ccui.Text:create()
			itemRoomCardBtnBuyText:setText(tostring(GameUtils.getIntPart(tonumber(mallDataList[index].amount))))
			itemRoomCardBtnBuyText:setFontSize(24)
			itemRoomCardBtnBuyText:setTextColor(cc.c4b(255, 255, 255, 255))
			-- itemGoldName:setAnchorPoint(cc.p(1, 0.5))
			itemRoomCardBtnBuyText:setPosition(cc.p(itemRoomCardBtnBuy:getContentSize().width*0.55, itemRoomCardBtnBuy:getContentSize().height*0.55))
			itemRoomCardBtnBuyText:setFontName(GameUtils.getFontName())
			itemRoomCardBtnBuy:addChild(itemRoomCardBtnBuyText)

			local txtLine = cc.Scale9Sprite:createWithSpriteFrameName("TP/Mall/mall_txt_line.png", cc.rect(0, 0, 2, 2))
			txtLine:setContentSize(cc.size(itemRoomCardBtnBuyText:getContentSize().width ,4))
			txtLine:setAnchorPoint(cc.p(0.5, 0.5))
    		txtLine:setPosition(itemRoomCardBtnBuyText:getContentSize().width/2, itemRoomCardBtnBuyText:getContentSize().height/2)
    		txtLine:setScale9Enabled(true)
			itemRoomCardBtnBuyText:addChild(txtLine)

			local itemRoomCardBtnBuyTextSale = ccui.Text:create()
			itemRoomCardBtnBuyTextSale:setText("0")
			itemRoomCardBtnBuyTextSale:setFontSize(36)
			itemRoomCardBtnBuyTextSale:setTextColor(cc.c4b(255, 255, 255, 255))
			-- itemGoldName:setAnchorPoint(cc.p(1, 0.5))
			itemRoomCardBtnBuyTextSale:setPosition(cc.p(itemRoomCardBtnBuy:getContentSize().width*0.8, itemRoomCardBtnBuy:getContentSize().height*0.55))
			itemRoomCardBtnBuyTextSale:setFontName(GameUtils.getFontName())
			itemRoomCardBtnBuy:addChild(itemRoomCardBtnBuyTextSale)
		else
			local itemRoomCardBtnBuyText = ccui.Text:create()
			itemRoomCardBtnBuyText:setText(tostring(GameUtils.getIntPart(tonumber(mallDataList[index].amount))))
			itemRoomCardBtnBuyText:setFontSize(36)
			itemRoomCardBtnBuyText:setTextColor(cc.c4b(255, 255, 255, 255))
			-- itemGoldName:setAnchorPoint(cc.p(1, 0.5))
			itemRoomCardBtnBuyText:setPosition(cc.p(itemRoomCardBtnBuy:getContentSize().width*0.6, itemRoomCardBtnBuy:getContentSize().height*0.55))
			itemRoomCardBtnBuyText:setFontName(GameUtils.getFontName())
			itemRoomCardBtnBuy:addChild(itemRoomCardBtnBuyText)
		end

		-- 商品射灯
		local itemLight = ccui.ImageView:create("TP/Mall/mall_item_light.png", ccui.TextureResType.plistType)
		itemLight:setPosition(cc.p(itemRoomCardBg:getContentSize().width/2, itemRoomCardBg:getContentSize().height - itemLight:getContentSize().height/2 + 25))
		itemRoomCardBg:addChild(itemLight)
	end
end

-- *************************我只是分割线******************************** --

-- 商城分类详情
local MallItemLayer = class("MallItemLayer", cc.Layer)

-- local _mallType = 0

function MallItemLayer:ctor(mallType, mallDataList)
	-- print("MallItemLayer:ctor")
	-- MallItemLayer.super.ctor(self)
	if mallDataList then
		-- dump(mallDataList, "xiaxb---------------mallDataList")
		self:_initView(mallType, mallDataList)
	end
end

-- 初始化试图视图
function MallItemLayer:_initView(mallType, mallDataList)
	local listView = ccui.ListView:create()

	listView:setContentSize(cc.size(980, 655))
	listView:setBackGroundColor(cc.c3b(120, 120, 120))
	listView:setPosition(cc.p(self:getContentSize().width-listView:getContentSize().width, 0))

	listView:setTouchEnabled(true)--触摸的属性
    listView:setBounceEnabled(false)--弹回的属性
    listView:setScrollBarEnabled(false)
    listView:setInertiaScrollEnabled(false)--滑动的惯性
	listView:setInnerContainerSize(cc.size(980, 655))--设置容器的大小

	self:addChild(listView)

	local layout = ccui.Layout:create()

	local line = #mallDataList%3 > 0 and math.floor(#mallDataList/3)+1 or math.floor(#mallDataList/3)
	layout:setContentSize(cc.size(980, 311*line + 20))
	for i=1,line do
		local item = nil
	 	if config.MallLayerConfig.Type_Gold == mallType then
			item = MallItemGold:create(i, mallDataList)
		elseif config.MallLayerConfig.Type_Diamond == mallType then
			item = MallItemDiamond:create(i, mallDataList)
		elseif config.MallLayerConfig.Type_RoomCard == mallType then
			item = MallItemRoomCard:create(i, mallDataList)
		else
			print("xiaxb", "unknow type!")
		end
		item:setPosition(cc.p(layout:getContentSize().width/2, (line - i + 0.5)*311 + 20))
		layout:addChild(item, line -i)
	end

	listView:addChild(layout)

end

return MallItemLayer