cc.exports.Mall = cc.exports.Mall or {}

local scheduler = require "cocos/framework/scheduler"
local GameRequest = require "request/GameRequest"

-- 商城金币
local MallData = class("MallData")

MallData.goodsId = 0							-- 商品id
MallData.goodsName = "" 						-- 商品名称
MallData.imageUrl = ""					        -- 商品图片地址
MallData.number = 0						        -- 赠送金币数量 (金币模式为兑换金币数量，房卡模式为有效期)
MallData.amount = 0						        -- 商品价格
MallData.date = 0						        -- 房卡剩余天数
MallData.tag = 0						        -- 优惠标签
MallData.appleProductIdentifier = ""            -- 苹果支付标识
MallData.payment = ""					        -- 选择支付方式
MallData.expendType = 0				            -- 支付货币  1为现金支付, 2钻石虚拟支付
MallData.paymentPlatform = 0				    -- 支持支付渠道
MallData.curPayment = ""						-- 当前选中支付渠道

function MallData:ctor(params)
	self.goodsId = params.goodsId or 0								        -- 商品id
	self.goodsName = params.goodsName or "" 					            -- 商品名称
	self.imageUrl = params.imageUrl or ""						            -- 图标下载地址
	self.number = params.number or 0							            -- 价格
	self.amount = params.amount or 0 						                -- 消耗钻石
	self.date = params.date 												-- 房卡有效期
	self.tag = params.tag or 0						                        -- 0没有角标，1房卡免费，2专属优惠，3未XXXXX
	self.appleProductIdentifier = params.appleProductIdentifier or ""     	-- 苹果支付标识
	self.payment = params.payment or ""						                -- 支持支付方式
	self.expendType = params.expendType or 0				                -- 支付货币  1为现金支付, 2钻石虚拟支付
	self.paymentPlatform = params.paymentPlatform or 0						-- 当前支付渠道
	self.curPayment = params.curPayment or ""
end

local MallManager = class("MallManager")

-- 支付方式
MallManager.EXPENDTYPE_CASH = 1								-- 现金支付
MallManager.EXPENDTYPE_DIAMOND = 2							-- 钻石虚拟支付


-- 支付渠道
-- MallManager.PayType_Diamond = 0 					-- 钻石内购
-- MallManager.PayType_Iap = 1 						-- 苹果支付
-- MallManager.PayType_Ipaynow = 2 					-- 现在支付

MallManager.PayType_Diamond            	= 0     			-- 钻石内购
MallManager.PayType_Iap           		= 1     			-- 苹果支付
MallManager.PayType_Ipaynow             = 2     			-- 现在支付

MallManager.PayResult_Success        	= 1     			-- 登录成功
MallManager.PayinResult_Fail           	= 2     			-- 登录失败
MallManager.PayinResult_Cancel         	= 3     			-- 登录取消

MallManager.PayResultCode = {}
MallManager.PayResultCode[1] = "购买成功!"               	  	-- 登录成功
MallManager.PayResultCode[2] = "购买失败!"               	  	-- 登录失败
MallManager.PayResultCode[3] = "购买取消!"               	  	-- 登录取消
MallManager.PayResultCode[4] = "购买中!"                	  	 -- 登录成功
MallManager.PayResultCode[5] = "购买超时!"               	 	-- 登录成功
MallManager.PayResultCode[6] = "客户端不支持购买!"          	 -- 登录成功
MallManager.PayResultCode[7] = "未安装客户端!"             	  -- 登录成功
MallManager.PayResultCode[8] = "未找到商品信息!"               	   -- 登录成功


local _curMallDataListType = 0								-- 当前商品列表

-- 商城列表数据
local _mallDataList = {}									-- 商城数据列表
local _mallDataListLayers = {}								-- 商城列表层
local _storeDataListDialogs = {}							-- 游戏小商城弹窗层
local _mallLayer = nil										-- 商城场景层
local _storeDialog = nil									-- 游戏小商城弹窗层
local _mallData = nil 										-- 当前支付菜单

-- 游戏提示语
MallManager.GET_MALL_LIST_FAIL 				= "商品列表获取失败！"
MallManager.GET_MALL_INFO_FAIL 				= "获取商品信息失败！"
MallManager.GET_MALL_ORDER_FAIL 			= "获取商品订单失败！"
MallManager.GOTO_DIAMOND_LIST_FAIL 			= "跳转钻石列表失败！"
MallManager.UNSURPORT_IAP 					= "无法使用苹果支付！"
MallManager.LOADING_MALL_INFO 				= "正在加载商品信息..."
MallManager.DIAMOND_LOST 					= "钻石不足，将为您自动跳转到钻石购买页面！"
MallManager.UNKNOW_MALL_INFO 				= "未知商品!"
MallManager.UNKNOW_PAY_TYPE 				= "未知支付渠道"
MallManager.PAY_FAIL 						= "支付失败!"
MallManager.BUY_FAIL 						= "购买失败！"
MallManager.BUY_SUCCESS 					= "购买成功！"

MallManager.GET_CUSTOMERSERVICE_FAIL 		= "获取客服失败！"

function MallManager:ctor()
	self:resetData()
	self._gameRequest = GameRequest:new()
end

-- **************************商城客服************************** --

function MallManager:getCustomerService(callback)
	local url = config.ServerConfig:findModelDomain() .. config.MallApiConfig.REQUEST_MALL_SERVER_INFO
	local function onGetCustomerService(__error, __response)
		if __error then
			GameUtils.showMsg(MallManager.GET_CUSTOMERSERVICE)
		else
			if 200 == __response.status then
				callback(__response.data)
			end
		end
	end
	HttpClient:getInstance():get(url, onGetCustomerService)
end

-- function MallManager:onGetCustomerService(__error, __response)
	
-- end

-- **************************商城数据请求************************** --

function MallManager:getReqURL(index)
	local reqMallURl = config.ServerConfig:findModelDomain() .. config.MallApiConfig.REQUEST_MALL_LIST_DATA..index.."?token="..UserData.token
	return reqMallURl
end

-- 请求金币列表
function MallManager:reqGoldList()
	-- body
	-- 请求金币列表
	local url = self:getReqURL(1)
	HttpClient:getInstance():get(url, handler(self, self.onMallListCallBack), true)
end

-- 请求钻石列表
function MallManager:reqDiamondList()
	-- body
	-- 请求钻石列表
	local url = self:getReqURL(2)
	HttpClient:getInstance():get(url,handler(self, self.onMallListCallBack), true)
end

-- 请求房卡列表
function MallManager:reqRoomCardList()
	-- body
	-- 请求房卡列表
	local url = self:getReqURL(3)
	HttpClient:getInstance():get(url,handler(self, self.onMallListCallBack), true)
end

-- **************************商城数据************************** --

-- 商城数据回调
function MallManager:onMallListCallBack(__error, __response)
	dump(__response)
	-- body
	if __error then
    	-- print("Table config net error")
		GameUtils.showMsg(MallManager.GET_MALL_LIST_FAIL)
    else
    	if 200 == __response.status then
     		self:initMallDataList(__response.data)
			-- dump(__response.data, "xiaxb-----resp---data:")
            if _mallLayer and _mallDataList[_curMallDataListType] and #_mallDataList[_curMallDataListType] > 0 then
				-- 列表数据已存在
				-- dump(_mallDataList[_curMallDataListType], "xiaxb--------_mallDataList[_curMallDataListType]")
				self:refreshMallDataLayer(_mallDataList[_curMallDataListType])
				return
			end

			if _storeDialog and _mallDataList[_curMallDataListType] then
				-- 列表数据已存在
				-- dump(_mallDataList[_curMallDataListType], "xiaxb--------_mallDataList[_curMallDataListType]")
				self:refreshStoreDataLayer(_mallDataList[_curMallDataListType])
				return
			end
    	end
    end
end

-- 初始化商城数据
function MallManager:initMallDataList( data )
	-- body
	for i = 1, #data do
		_mallDataList[_curMallDataListType][i] = MallData.new({
		goodsId = data[i].id or 0,								    --商品id
		goodsName = data[i].name or "", 					            --商品名称
		imageUrl = config.ServerConfig:findResDomain() .. data[i].img or "",						        --图标下载地址
		number = data[i].score or 0,							            --兑换金币
		amount = data[i].diamondPrice or 0, 						            --消耗钻石
		-- date = data[i].Date or 0,									        --房卡有效期
		tag = data[i].tag or 0,						                    --0没有角标，1房卡免费，2专属优惠，3未XXXXX
		appleProductIdentifier = data[i].appleIdentifier or "",	--苹果支付标签
		payment = data[i].Payment or "",						            --支持支付方式					
		expendType = data[i].payment or 0,				                --支付货币  1为现金支付, 2钻石虚拟支付
		paymentPlatform = data[i].paymentPlatform or ""								--当前支付方式
		})
	end
end

-- 请求商城数据
function MallManager:getMallList(node, mallDataListType)
	_mallLayer = node
	_curMallDataListType = mallDataListType or config.MallLayerConfig.Type_Gold
	local isShow = false
	for i=config.MallLayerConfig.Type_Gold, config.MallLayerConfig.Type_RoomCard do
		-- dump(_mallDataListLayers[i], "xiaxb--------_mallDataListLayers[" .. i .. "]:")
		if _mallDataListLayers[i] then
			if i == _curMallDataListType then
				_mallDataListLayers[i]:setVisible(true)
				isShow = true
			else
				_mallDataListLayers[i]:setVisible(false)
			end
		end
	end

	if isShow then
		return
	end

	-- print("MallManager:getMallList")
	-- _mallLayer = node
	-- _curMallDataListType = mallDataListType or config.MallLayerConfig.Type_Gold

	-- if _mallDataListLayers[_curMallDataListType] then
	-- 	self:refreshMallDataLayerWithIndex()
	-- 	return
	-- end

	if _mallDataList[_curMallDataListType] and #_mallDataList[_curMallDataListType] > 1 then
		-- 列表数据已存在
		-- dump(_mallDataList[_curMallDataListType], "xiaxb--------_mallDataList[_curMallDataListType]")
		self:refreshMallDataLayer(_mallDataList[_curMallDataListType])
		return
	end

	if config.MallLayerConfig.Type_Gold == _curMallDataListType then
		self:reqGoldList()
	elseif config.MallLayerConfig.Type_Diamond == _curMallDataListType then
		self:reqDiamondList()
	elseif config.MallLayerConfig.Type_RoomCard == _curMallDataListType then
		self:reqRoomCardList()
	else
		-- print("xiaxb", "unknow type!")
		GameUtils.showMsg(MallManager.GET_MALL_INFO_FAIL)	
	end
end


-- 刷新商城列表
function MallManager:refreshMallDataLayer(mallDataList)
	-- body
	-- 商城商品分类
	-- dump(mallDataList, "xiaxb--------mallDataList")
	-- print("xiaxb", "refreshMallDataLayer")
	-- dump(_mallDataListLayers, "xiaxb--------_mallDataListLayers:")
	
	local mallItemLayer = require("src/lobby/layer/MallItemLayer"):create(_curMallDataListType, mallDataList)
	-- dump(_mallLayer, "xiaxb--------_mallLayer:")
	-- dump(mallItemLayer, "xiaxb--------mallItemLayer:")
	if _mallLayer and mallItemLayer then
		_mallDataListLayers[_curMallDataListType] = mallItemLayer
		-- mallItemLayer:setTag("")
		_mallLayer:addChild(mallItemLayer)
	end
end

-- 刷新商城列表
-- function MallManager:refreshMallDataLayerWithIndex()
-- 	-- body
-- 	-- 商城商品分类
-- 	-- dump(mallDataList, "xiaxb--------mallDataList")
-- 	-- print("xiaxb", "refreshMallDataLayerWithIndex")
-- 	for i=config.MallLayerConfig.Type_Gold, config.MallLayerConfig.Type_RoomCard do
-- 		if _mallDataListLayers[i] then
-- 			if i == _curMallDataListType then
-- 				_mallDataListLayers[i]:setVisible(true)
-- 			else
-- 				_mallDataListLayers[i]:setVisible(false)
-- 			end
-- 		end
-- 	end
-- end

-- **************************商城弹窗数据************************** --
-- 请求商城弹窗数据
function MallManager:getStoreList(node, mallDataListType)
	_storeDialog = node
	_curMallDataListType = mallDataListType or config.MallLayerConfig.Type_Gold

	local isShow = false
	for i=config.MallLayerConfig.Type_Gold, config.MallLayerConfig.Type_RoomCard do
		if _storeDataListDialogs[i] then
			if i == _curMallDataListType then
				_storeDataListDialogs[i]:setVisible(true)
				isShow = true
				-- return
			else
				_storeDataListDialogs[i]:setVisible(false)
			end
		end
	end

	if isShow then
		return
	end

	-- _storeDialog = node
	-- _curMallDataListType = mallDataListType or config.MallLayerConfig.Type_Gold

	-- 插入测试数据
	-- self:testData()

	-- if _storeDataListDialogs[_curMallDataListType] then
	-- 	self:refreshStoreDataLayerWithIndex()
	-- 	return
	-- end

	if _mallDataList[_curMallDataListType] and #_mallDataList[_curMallDataListType] > 1 then
		-- 列表数据已存在
		-- dump(_mallDataList[_curMallDataListType], "xiaxb--------_mallDataList[_curMallDataListType]")
		self:refreshStoreDataLayer(_mallDataList[_curMallDataListType])
		return
	end

	if config.MallLayerConfig.Type_Gold == _curMallDataListType then
		self:reqGoldList()
	elseif config.MallLayerConfig.Type_Diamond == _curMallDataListType then
		self:reqDiamondList()
	elseif config.MallLayerConfig.Type_RoomCard == _curMallDataListType then
		self:reqRoomCardList()
	else
		-- print("xiaxb", "unknow type!")
		GameUtils.showMsg(MallManager.GET_MALL_INFO_FAIL)
	end
end

-- 刷新商城弹窗列表
function MallManager:refreshStoreDataLayer(mallDataList)
	-- print("xiaxb", "refreshStoreDataLayer")
	
	local storeItemLayer = require("src/lobby/layer/StoreItemLayer"):create(_curMallDataListType, mallDataList)
	if _storeDialog then
		_storeDataListDialogs[_curMallDataListType] = storeItemLayer
		-- mallItemLayer:setTag("")
		storeItemLayer:setPosition(cc.p(_storeDialog:getContentSize().width/2, _storeDialog:getContentSize().height * 0.40))
		_storeDialog:addChild(storeItemLayer)
	end
end

-- 刷新商城弹窗列表
function MallManager:refreshStoreDataLayerWithIndex()
	-- body
	-- 商城商品分类
	-- dump(mallDataList, "xiaxb--------mallDataList")
	-- print("xiaxb", "refreshStoreDataLayerWithIndex")
	for i=config.MallLayerConfig.Type_Gold, config.MallLayerConfig.Type_RoomCard do
		if _storeDataListDialogs[i] then
			if i == _curMallDataListType then
				_storeDataListDialogs[i]:setVisible(true)
			else
				_storeDataListDialogs[i]:setVisible(false)
			end
		end
	end
end

-- *****************************请求支付信息********************************* --

function MallManager:buyGoods(mallData)
	-- dump(mallData, "xiaxb--------malldata:" )
	if MallManager.EXPENDTYPE_CASH == mallData.expendType then
		-- 现金支付
		-- print("xiaxb", "payment:" .. mallData.payment)
		local paymentList = GameUtils.split(mallData.payment, "|")
		-- dump(paymentList, "xiaxb------paymentList:")
		if not paymentList or #paymentList == 0 then
			-- 没有配置任何支付方式
			GameUtils.showMsg(MallManager.UNKNOW_PAY_TYPE)
		elseif 1 == #paymentList then
			-- 默认支付方式 直接支付
			mallData.curPayment = mallData.payment
			self:pay(mallData)
		else
			-- 拥有多种支付方式
			-- print("XIAXB", "curPayment:" .. mallData.curPayment)
			if not mallData.curPayment or "" == mallData.curPayment then
				local payTypeDialog = require("Lobby/src/lobby/layer/PayTypeDialog"):create(mallData)
				cc.Director:getInstance():getRunningScene():addChild(payTypeDialog, 1000)
			else
				self:pay(mallData)
			end	
		end 

	elseif MallManager.EXPENDTYPE_DIAMOND == mallData.expendType then
	    -- 钻石虚拟支付
	    if tonumber(mallData.amount) > UserData.diamond and 1 ~= mallData.tag then
			-- 钻石不足
	    	GameUtils.showMsg(MallManager.DIAMOND_LOST)
	    	self:gotoBuyDiamond()
		else
			self:getGoodsOrder(mallData.goodsId)
		end
	else
		GameUtils.showMsg(MallManager.UNKNOW_MALL_INFO)
	end
end

-- 钻石不足，前往购买钻石
function MallManager:gotoBuyDiamond( ... )
	if _mallLayer then
		_mallLayer:gotoBuyDiamond()
	elseif _storeDialog then
		_storeDialog:getParent():gotoBuyDiamond()
	else 
		-- print("xiaxb-----------gotoBuyDiamond:fail")
		GameUtils.showMsg(MallManager.GOTO_DIAMOND_LIST_FAIL)
	end
end

function MallManager:pay(mallData)
	_mallData = mallData
	-- body
	-- local payment = "" == mallData.curPayment and mallData.payment or mallData.curPayment
	-- print("xiaxb-----------配置默认支付方式：" .. payment)
	-- dump(mallData, "xiaxb")
	if "iap" == mallData.curPayment then
		local targetPlatform = cc.Application:getInstance():getTargetPlatform()
		if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
			-- local function payCallback( ... )
			-- 	print("xiaxb----------payCallback")
			-- end
			self:getGoodsOrder(mallData.goodsId, MallManager.PayType_Iap, mallData.curPayment)
			-- MultiPlatform:getInstance():thirdPartyPay(config.SDKConfig.ThirdParty.IAP, {appleProductIdentifier = mallData.appleProductIdentifier}, payCallback)
		elseif cc.PLATFORM_OS_ANDROID == targetPlatform then
			GameUtils.showMsg(MallManager.UNSURPORT_IAP)
		else
			GameUtils.showMsg(MallManager.UNSURPORT_IAP)
		end
	else 
		-- 渠道id
		self:getGoodsOrder(mallData.goodsId, MallManager.PayType_Ipaynow, mallData.curPayment)
		-- Mall.MallManager:getInstance():getReqGoodsOrderURL(paymentList[1])
	end	
	mallData.curPayment = ""		
end

-- 获取商品订单号请求URL
function MallManager:getReqGoodsOrderURL()
	return config.ServerConfig:findModelDomain() .. config.MallApiConfig.REQUEST_MALL_GOODS_ORDER
end

-- 获取商品订单号参数
function MallManager:getReqGoodsOrderParam(_goodsId, _paymentPlatform, _payment)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	local _platform = 0
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		_platform = config.SDKConfig.Platform.IOS
	elseif  (cc.PLATFORM_OS_ANDROID == targetPlatform) then
		_platform = config.SDKConfig.Platform.ANDROID
	else
		_platform = config.SDKConfig.Platform.OTHER
	end

	local param = {}
	if not _paymentPlatform then
		-- print("xiaxb", "not _paymentPlatform")
		param = { token = UserData.token, platform = _platform, goodsId = _goodsId}
	else
		-- print("xiaxb", "_payment" .. _payment)
		param = { paymentPlatform = _paymentPlatform, token = UserData.token, platform = _platform, paymentChannel= _payment, goodsId = _goodsId}
	end
	-- dump(param, "xiaxb---------params:")
	return param
end

-- 请求订单号
function MallManager:getGoodsOrder(_goodsId, _paymentPlatform, _payment)
	local url = self:getReqGoodsOrderURL()
	local param = self:getReqGoodsOrderParam(_goodsId, _paymentPlatform, _payment)
	GameUtils.startLoadingForever(MallManager.LOADING_MALL_INFO)
	HttpClient:getInstance():post(url, param, handler(self, self.onGetGoodsOrder))
end

-- 获取订单号
function MallManager:onGetGoodsOrder(__errorMsg, __response)
	print("xiaxb------onGetGoodsOrder")
	GameUtils.stopLoading()
    if __errorMsg then
    	GameUtils.showMsg(MallManager.GET_MALL_ORDER_FAIL)
    else
        if 200 == __response.status then
        	-- dump(__response, "xiaxb-----onGetGoodsOrder--------__response:")
        	local paymentPlatform = __response.data.paymentPlatform
        	local _payData = __response.data.PayData
        	local orderCode = __response.data.OrderCode

        	if MallManager.PayType_Diamond == paymentPlatform then
        		self:refreshUserInfo(__response.data)
				GameUtils.showMsg(MallManager.BUY_SUCCESS)
        	elseif MallManager.PayType_Iap == paymentPlatform then
        		-- print("xiaxb-----iap --- pay ")
        		-- 苹果支付方式
        		if orderCode then
		        	local function payCallback(result)
						GameUtils.stopLoading()
						-- print("xiaxb------stopLoading")
						self:onPayResult(paymentPlatform, result, orderCode)
					end
					GameUtils.startLoadingForever(MallManager.LOADING_MALL_INFO)
					-- print("xiaxb------startLoading")
		        	MultiPlatform:getInstance():thirdPartyPay(paymentPlatform, _mallData.appleProductIdentifier, payCallback)
		        end
    		elseif MallManager.PayType_Ipaynow == paymentPlatform then
    			if _payData then
		        	local function payCallback(result)
						-- print("xiaxb", "result:" .. result)
		        		self:onPayResult(paymentPlatform, result, orderCode)
		        	end
		        	-- GameUtils.showMsg(_payData)
		        	-- MultiPlatform:getInstance():thirdPartyPay(paymentPlatform, _payData, payCallback)
		        	self._orderCode = orderCode
		        	MultiPlatform:getInstance():openWebView(_payData)
		        	return
	        	end
    		else
    			GameUtils.showMsg(MallManager.GET_MALL_ORDER_FAIL)
    		end
		else
			GameUtils.showMsg(MallManager.GET_MALL_ORDER_FAIL)
        end
    end
end

-- 处理支付结果
function MallManager:onPayResult(payType, result, orderCode)
	-- GameUtils.stopLoading()
	if type(result) == "string" and string.len(result) > 0 then
        local ok, _result = pcall(function()
            return lib.JsonUtil:decode(result)
        end)
        -- print("xiaxb-------------ok:", ok)
		-- dump(_result, "xiaxb-------_result")
        if ok and type(_result) == "table" then
			-- dump(_result, "XIAXB--------_RESULT:")
        	if MallManager.PayResult_Success == _result["result"] then
        		if MallManager.PayType_Iap == payType then
        			self:iapVerify(orderCode, _result["receipt"])
        		elseif MallManager.PayType_Ipaynow == payType then
        			self:payResultVerify(orderCode)
        		else
					-- print("xiaxb----------支付渠道未知:" .. payType)
					GameUtils.showMsg(MallManager.BUY_SUCCESS)
        		end
			-- elseif 	MallManager.PayinResult_Cancel == _result["result"] then
        	else
				-- print("xiaxb----------购买失败：" .. _result["result"])
        		GameUtils.showMsg(MallManager.PayResultCode[_result["result"]])
        	end
        else
			-- print("xiaxb", "1支付回调数据错误！")
        	GameUtils.showMsg(MallManager.BUY_FAIL)
        end
    else
		-- print("xiaxb", "2支付回调数据错误！")
		GameUtils.showMsg(MallManager.BUY_FAIL)
    end
    _mallData = nil
end

function MallManager:getIapVerifyURL( ... )
	return config.ServerConfig:findModelDomain() .. config.MallApiConfig.REQUEST_MALL_IAP_VERIFY
end

function MallManager:getIapVerifyParam(orderCode, receipt)
	-- body
	local param = { token = UserData.token, orderCode = orderCode, receipt = receipt }
	return param
end

-- 苹果支付校验
function MallManager:iapVerify(orderCode, receipt)

	self:savaIapOrder(orderCode, receipt)
	-- UserDefault
	local url = self:getIapVerifyURL()
	local param = self:getIapVerifyParam(orderCode, receipt)
	-- dump(param, "xiaxb-------param:")
	HttpClient:getInstance():post(url, param, handler(self, self.onIapVerify))
end

function MallManager:onIapVerify(__errorMsg, __response)
	if __errorMsg then
		GameUtils.showMsg("购买失败，请联系客服",3)
	else
		if __response then
			if 200 == __response.status then
				-- GameUtils.showMsg("购买成功！", 3)
				-- print("xiaxb---------ordercode:" .. __response.data.ordercode)
				GameUtils.showMsg(MallManager.BUY_SUCCESS)
				self:removeIapOrder(__response.data.ordercode)
				-- 需要刷新数据
				self:refreshUserInfo(__response.data)
			else
			 	-- GameUtils.showMsg("购买失败！",3)
				 GameUtils.showMsg(MallManager.BUY_FAIL)
			end
		else
			-- GameUtils.showMsg("购买失败！",3)
			GameUtils.showMsg(MallManager.BUY_FAIL)
		end
	end
end

function MallManager:getPayResultVerifyURL( ... )
	return config.ServerConfig:findModelDomain() .. config.MallApiConfig.REQUEST_MALL_PAY_RESULT_VERIFY
end

-- function MallManager:getPayResultVerifyParam(orderCode, receipt)
-- 	-- body
-- 	local param = { token = UserData.token, orderCode = orderCode, receipt = receipt }
-- 	return param
-- end

function MallManager:getPayStatus( ... )
	-- body
	local url = self:getPayResultVerifyURL() .. self._orderCode .. "/" .. UserData.token
	HttpClient:getInstance():get(url, handler(self, self.onPayResultVerify))
end

-- 支付校验
function MallManager:payResultVerify(orderCode)
    scheduler.performWithDelayGlobal(handler(self, self.getPayStatus), 1)
end

function MallManager:onPayResultVerify(__errorMsg, __response)
	if __errorMsg then
		GameUtils.showMsg(MallManager.BUY_FAIL)
	else
		if __response then
			if 200 == __response.status then
				dump(__response, "xiaxb 校验订单")
				-- 需要刷新数据
				self:refreshUserInfo(__response.data)
				GameUtils.showMsg(MallManager.BUY_SUCCESS)
				self._checkPayStatusCount = 1
			else
		 		if 4 > self._checkPayStatusCount then
					self:reCheckPayStatus()
				else
					self._checkPayStatusCount = 1
				end
			end
		else
			if 4 > self._checkPayStatusCount then
				self:reCheckPayStatus()
			else
				self._checkPayStatusCount = 1
			end
		end
	end
end

function MallManager:reCheckPayStatus()
	scheduler.performWithDelayGlobal(handler(self, self.getPayStatus), 5)
	self._checkPayStatusCount = self._checkPayStatusCount + 1
end

-- 保存苹果支付订单
function MallManager:savaIapOrder(orderCode, receipt)
	local orderList = cc.UserDefault:getInstance():getStringForKey("orderList", "")
	local orderListTable = GameUtils.split(orderList, ",")
	for k, v in pairs(orderListTable) do
		-- 去除重复订单
		if orderCode == v then
			return
		end
    end

    if "" == orderList then
        cc.UserDefault:getInstance():setStringForKey("orderList", orderCode)
        cc.UserDefault:getInstance():setStringForKey(tostring(orderCode), tostring(receipt))     
    else
        cc.UserDefault:getInstance():setStringForKey("orderList", orderList .. "," .. orderCode)
        cc.UserDefault:getInstance():setStringForKey(tostring(orderCode), tostring(receipt))
    end
    -- print("xiaxb--------savaIapOrder")
    self:printOrderList()
end

-- 清空已经完成校验的苹果支付订单
function MallManager:removeIapOrder(orderCode)
	local orderList = cc.UserDefault:getInstance():getStringForKey("orderList", "")
	cc.UserDefault:getInstance():setStringForKey("orderList", "")
	local orderListTable = GameUtils.split(orderList, ",")
	local orderListStr = ""
	for k, v in pairs(orderListTable) do
		if orderCode == v then
			cc.UserDefault:getInstance():deleteValueForKey(v)
		else
			self:savaIapOrder(v, cc.UserDefault:getInstance():getStringForKey(v, ""))
		end
    end
    -- print("xiaxb--------removeIapOrder")
    self:printOrderList()    
end

function MallManager:printOrderList( ... )
	-- body
	local orderList = cc.UserDefault:getInstance():getStringForKey("orderList")
	-- print("xiaxb------------orderList:" .. orderList)
	local orderListTable = GameUtils.split(orderList, ",")
	for k, v in pairs(orderListTable) do
		-- print("xiaxb--------order:" .. v)
		-- print("xiaxb-----------receipt" .. cc.UserDefault:getInstance():getStringForKey(v, ""))
    end

end

-- 重新校验未完成的苹果支付订单
function MallManager:reIapVerify( ... )
	local orderList = cc.UserDefault:getInstance():getStringForKey("orderList", "")
	if "" == orderList then
		return
	end
  	-- print("xiaxb------------orderList:" .. orderList)
    local orderListTable = GameUtils.split(orderList, ",")
    for k, v in pairs(orderListTable) do
        -- if v == orderCode then
    	local receipt = cc.UserDefault:getInstance():getStringForKey(v, "")
        self:iapVerify(v, receipt)
        -- end
    end
end

-- 支付成功(更新用户信息)
function MallManager:refreshUserInfo( data )
	-- dump(data, "xiaxb----------data:")
	UserData.coins = data.UserInfo.Score
	UserData.diamond = data.UserInfo.diamond
	UserData.roomCards = data.UserInfo.RoomCardNum
	local event = cc.EventCustom:new(config.EventConfig.EVENT_REFRESH_USER_INFO)
	event.coins = UserData.coins
	event.diamond = UserData.diamond
	event.roomCards = UserData.roomCards
	lib.EventUtils.dispatch(event)

	self._gameRequest:RequestShopSucceed()
end

-- 重置数据
function MallManager:resetData()
	-- body
	-- 金币列表
	_mallDataList[config.MallLayerConfig.Type_Gold] = {}
	-- 钻石列表
	_mallDataList[config.MallLayerConfig.Type_Diamond] = {}
	-- 房卡列表
	_mallDataList[config.MallLayerConfig.Type_RoomCard] = {}

	-- 金币列表视图层
	_mallDataListLayers[config.MallLayerConfig.Type_Gold] = nil
	-- 钻石列表视图层
	_mallDataListLayers[config.MallLayerConfig.Type_Diamond] = nil
	-- 房卡列表视图层
	_mallDataListLayers[config.MallLayerConfig.Type_RoomCard] = nil

	-- 金币列表视图层
	_storeDataListDialogs[config.MallLayerConfig.Type_Gold] = nil
	-- 钻石列表视图层
	_storeDataListDialogs[config.MallLayerConfig.Type_Diamond] = nil
	-- 房卡列表视图层
	_storeDataListDialogs[config.MallLayerConfig.Type_RoomCard] = nil

	_mallLayer = nil
	
	_storeDialog = nil

	_mallData = nil

	self._checkPayStatusCount = 1

end

function MallManager:testData()

	-- print("xiaxb", "_curMallDataListType", _curMallDataListType)

	_mallDataList[_curMallDataListType][1] = MallData.new({
			name = "帕萨特", 						--商品名称
			icon = 1, 								--图标id
			iconUrl = "", 							--图标url地址
			gold = 66000,							--兑换金币
			price = 60, 							--消耗钻石
			discountPrice = 0,						--折扣价
			date = 0,								--房卡剩余天数
			flag = 1								--优惠标签
		})

	_mallDataList[_curMallDataListType][2] = MallData.new({
			name = "奥迪A6L", 						--商品名称
			icon = 1, 								--图标id
			iconUrl = "", 							--图标url地址
			gold = 180000,							--兑换金币
			price = 180, 							--消耗钻石
			discountPrice = 0,					--折扣价
			date = 02,								--房卡剩余天数
			flag = 1								--优惠标签
		})


	_mallDataList[_curMallDataListType][3] = MallData.new({
			name = "奔驰G500",						--商品名称
			icon = 1, 								--图标id
			iconUrl = "", 							--图标url地址
			gold = 680000,							--兑换金币
			price = 680, 							--消耗钻石
			discountPrice = 0,					--折扣价
			date = 8,								--房卡剩余天数
			flag = 1								--优惠标签
		})

	_mallDataList[_curMallDataListType][4] = MallData.new({
			name = "兰博基尼", 						--商品名称
			icon = 1, 								--图标id
			iconUrl = "", 							--图标url地址
			gold = 5100000,							--兑换金币
			price = 3280,							--消耗钻石
			discountPrice = 0,					--折扣价
			date = 15,								--房卡剩余天数
			flag = 1								--优惠标签
		})
	_mallDataList[_curMallDataListType][5] = MallData.new({
			name = "德玛西亚", 						--商品名称
			icon = 1, 								--图标id
			gold = 5100000,							--兑换金币
			price = 3280,							--消耗钻石
			discountPrice = 0,					--折扣价
			date = 30,								--房卡剩余天数
			flag = 1								--优惠标签
		})
	_mallDataList[_curMallDataListType][6] = MallData.new({
			name = "王者荣耀", 						--商品名称
			icon = 1, 								--图标id
			iconUrl = "", 							--图标url地址
			gold = 5100000,							--兑换金币
			price = 3280,							--消耗钻石
			discountPrice = 0,					--折扣价
			date = 180,								--房卡剩余天数
			flag = 1								--优惠标签
		})
	_mallDataList[_curMallDataListType][7] = MallData.new({
			name = "老司机", 						--商品名称
			icon = 1, 								--图标id
			iconUrl = "", 							--图标url地址
			gold = 5100000,							--兑换金币
			price = 3280,							--消耗钻石
			discountPrice = 0,					--折扣价
			date = 365,								--房卡剩余天数
			flag = 1								--优惠标签
		})
end

MallManager.showMessageBox = function(__messageTip,__productType)
	local params = {
		content = __messageTip,
		okFunc = function ( ... )
			cc.Director:getInstance():getRunningScene():addChild(require("src/lobby/layer/MallDialog"):create(__productType))
		end,
		showType = lib.layer.MessageBox.TYPE_SELECT,
		resType = ccui.TextureResType.localType ,
		okFile = "src/Lobby/res/common/common_go_soon.png" ,
		cancelFile = "src/Lobby/res/common/common_cancel.png" ,
	}
	lib.layer.MessageBox.showMsgBox(params)
end

MallManager.checkNeedGotoMallBuyDiamond = function ( __messageTip,__cost )
	if UserData.diamond < __cost then 
		MallManager.showMessageBox(__messageTip,config.MallLayerConfig.Type_Diamond)
		return true
	end
	return false
end

MallManager.checkNeedGotoMallBuyCoins =  function ( __messageTip,__cost )
	if UserData.coins < __cost then 
		MallManager.showMessageBox(__messageTip,config.MallLayerConfig.Type_Gold)
		return true
	end
	return false
end

MallManager.checkNeedGotoMallBuyRoomCard = function ( __messageTip,__cost )
	if UserData.roomCards < __cost then 
		MallManager.showMessageBox(__messageTip,config.MallLayerConfig.Type_RoomCard)
		return true
	end
	return false
end


lib.singleInstance:bind(MallManager)
cc.exports.Mall.MallManager = MallManager
return MallManager