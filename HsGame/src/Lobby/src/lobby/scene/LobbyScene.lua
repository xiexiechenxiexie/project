--[[
    名称  :   LobbyScene  大厅场景
    作者  :   Xiaxb   
    描述  :   LobbyScene大厅场景，包含游客和QQ以及微信第三方登录
    时间  :   2017-7-12
--]]

local LOGINSCENE_CSB = "GameLayout/Lobby/LobbyScene.csb"
require "LobbyGameEnterManager"
require "lobby/model/MallManager"
require "external/ShareManager"

local SocketClient = require "Lobby/src/net/SocketClient"
local GameManager = require "logic/GameManager"
local LobbyManager = require "logic/LobbyManager"
local FriendManager = require "logic/FriendManager"
local header = require "header/headFile"

local LobbyGameEnter = require "LobbyGameEnter"
local PromoteLayer = require "lobby/layer/PromoteLayer"
local NoticeView = require "NoticeView"
local SignView = require "SignView"
local FriendView = require "FriendView"
local TaskView = require "TaskView"

local LobbyScene = class("LobbyScene", cc.Layer)

-- 功能按钮标识
LobbyScene.BTN_MORE 		    = 1				-- 更多(收起)
LobbyScene.BTN_MORE_SHOW 		= 2				-- 更多(展开)
LobbyScene.BTN_MAIL 			= 3			    -- 邮件
LobbyScene.BTN_TASK 			= 4			    -- 任务
LobbyScene.BTN_FRIENDS 			= 5			    -- 好友
LobbyScene.BTN_SPREAD 			= 6 			-- 推广
LobbyScene.BTN_SHOP 			= 7 			-- 商城
LobbyScene.IMAGE_MORE_OUT_BG	= 8			    -- 更多的触摸背景
LobbyScene.RANKLIST             = 9             --排行榜列表（出）
LobbyScene.RANK                 = 10            --排行榜（进）


local btnListRes = {}
btnListRes[LobbyScene.BTN_MORE_SHOW] = {}
btnListRes[LobbyScene.BTN_MORE_SHOW]["NORMAL"] = "lobby_btn_more_show.png"
btnListRes[LobbyScene.BTN_MORE_SHOW]["SELECTED"] = "lobby_btn_more_show1.png"
btnListRes[LobbyScene.BTN_MORE_SHOW]["POS"] = cc.p(75, 40)

btnListRes[LobbyScene.BTN_MAIL] = {}
btnListRes[LobbyScene.BTN_MAIL]["NORMAL"] = "lobby_btn_mail.png"
btnListRes[LobbyScene.BTN_MAIL]["SELECTED"] = "lobby_btn_mail1.png"
btnListRes[LobbyScene.BTN_MAIL]["POS"] = cc.p(205, 40)

btnListRes[LobbyScene.BTN_TASK] = {}
btnListRes[LobbyScene.BTN_TASK]["NORMAL"] = "lobby_btn_task.png"
btnListRes[LobbyScene.BTN_TASK]["SELECTED"] = "lobby_btn_task1.png"
-- btnListRes[LobbyScene.BTN_TASK]["POS"] = cc.p(340, 40)
btnListRes[LobbyScene.BTN_TASK]["POS"] = cc.p(205, 40)

btnListRes[LobbyScene.BTN_FRIENDS] = {}
btnListRes[LobbyScene.BTN_FRIENDS]["NORMAL"] = "lobby_btn_friends.png"
btnListRes[LobbyScene.BTN_FRIENDS]["SELECTED"] = "lobby_btn_friends1.png"
-- btnListRes[LobbyScene.BTN_FRIENDS]["POS"] = cc.p(460, 40)
btnListRes[LobbyScene.BTN_FRIENDS]["POS"] = cc.p(340, 40)

btnListRes[LobbyScene.BTN_SPREAD] = {}
btnListRes[LobbyScene.BTN_SPREAD]["NORMAL"] = "lobby_btn_spread.png"
btnListRes[LobbyScene.BTN_SPREAD]["SELECTED"] = "lobby_btn_spread1.png"
-- btnListRes[LobbyScene.BTN_SPREAD]["POS"] = cc.p(590, 40)
btnListRes[LobbyScene.BTN_SPREAD]["POS"] = cc.p(460, 40)

local LobbyLocalZOrder = {
	LOBBYSCENE_CSB = 1,
	RANK_LAYER = 2,
	GAMEENTER_LAYER = 3,
	PROMOTER_LAYER = 4,
	TOP_VIEW = 5,
	MORE_LAYER = 900,
}

local LOBBY_MORE_POS = cc.p(295, 138)

function LobbyScene:ctor()
    self:enableNodeEvents()  -- 注册 onEnter onExit 时间 by  tangwen
    self:initData()
    self:initView()
end

function LobbyScene:initData()
	self._taskInfoData = nil
end

-- 初始化视图控件
function LobbyScene:initView()
	-- self.layer = cc.LayerColor:create(cc.c4b(10, 10, 10, 120), display.width, display.height)
	-- self.layer:hide()
 --    self:addChild(self.layer,998)
 --    local function onTouchBegan(touch, event)
 --    	return true
 --    end
 --    local function onTouchMove(touch, event)
 --    	return true
 --    end
 --    local function onTouchEnd(touch, event)
 --    	self:closeLayer()
 --    	return true
 --    end
 --    local listener = cc.EventListenerTouchOneByOne:create()
 --    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
 --    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
 --    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
 --    listener:setSwallowTouches(true)
 --    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self.layer)
 --    self.listener=listener

	local lobbySceneBg = ccui.ImageView:create("GameLayout/Lobby/lobby_bg.png", ccui.TextureResType.localType)
	lobbySceneBg:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
	self:addChild(lobbySceneBg)

	local lobbySceneGirl = ccui.ImageView:create("GameLayout/Lobby/lobby_girl.png", ccui.TextureResType.localType)
	lobbySceneGirl:setPosition(cc.p(self:getContentSize().width/2-220, lobbySceneGirl:getContentSize().height/2))
	self:addChild(lobbySceneGirl)

	local lobbySceneDi = ccui.ImageView:create("GameLayout/Lobby/lobby_di.png", ccui.TextureResType.localType)
	lobbySceneDi:setPosition(cc.p(self:getContentSize().width/2, lobbySceneDi:getContentSize().height/2))
	self:addChild(lobbySceneDi)
	for i=1,4 do
		local lobbySceneShu = ccui.ImageView:create("GameLayout/Lobby/Lobby_di_shu.png", ccui.TextureResType.localType)
		lobbySceneShu:setPosition(cc.p(140+(i-1)*130, lobbySceneDi:getContentSize().height/2))
		self:addChild(lobbySceneShu)
	end

	-- self.bottomBg = ccui.ImageView:create("lobby_bottom_bg.png", ccui.TextureResType.plistType)
	-- self.bottomBg:setPosition(cc.p(lobbySceneBg:getContentSize().width/2, self.bottomBg:getContentSize().height/2))
	-- self.bottomBg:hide()
	-- lobbySceneBg:addChild(self.bottomBg)

    -- 为所有可响应点击的控件设置点击事件
	local function btnCallBack(sender)
		self:onButtonClickedEvent(sender:getTag(), sender)
    end

	for index = LobbyScene.BTN_MORE_SHOW, LobbyScene.BTN_SPREAD do
		local btnMenu = ccui.Button:create(btnListRes[index]["NORMAL"], btnListRes[index]["SELECTED"], "", ccui.TextureResType.plistType)
		btnMenu:setPosition(btnListRes[index]["POS"])
		btnMenu:setTag(index)
		self:addChild(btnMenu)
		btnMenu:addClickEventListener(btnCallBack)

		if LobbyScene.BTN_MAIL == index then
			btnMenu:setVisible(false)
		end

		if LobbyScene.BTN_MORE_SHOW == index then
			self.btnMore = btnMenu
		end
	end

	-- 商城按钮
	local btnMall = ccui.Button:create("lobby_btn_shop_bg.png", "", "", ccui.TextureResType.plistType)
	btnMall:setTag(LobbyScene.BTN_SHOP)
	btnMall:addClickEventListener(btnCallBack)
	btnMall:setPosition(cc.p(self:getContentSize().width - 160, 40))
	self:addChild(btnMall)

	local dir = "GameLayout/Animation/shop_Animation/"
	local node = ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."shop_Animation0.png",dir.."shop_Animation0.plist",dir.."shop_Animation.ExportJson")  
    local adAnim = ccs.Armature:create("shop_Animation") 
    adAnim:setPosition(cc.p(btnMall:getContentSize().width/2, btnMall:getContentSize().height/2)) 
    btnMall:addChild(adAnim);
    adAnim:getAnimation():playWithIndex(0)
    adAnim:getAnimation():setSpeedScale(0.8)

	-- self:_addShopSaoiGuang(btnMall)

	-- -- 商城闪光
	-- local btnMallFlashLeft = ccui.ImageView:create("lobby_mall_flash.png", ccui.TextureResType.plistType)
	-- btnMallFlashLeft:setScale(0.8)
	-- btnMallFlashLeft:setOpacity(0)
	-- btnMallFlashLeft:setPosition(cc.p(btnMall:getContentSize().width * 0.15, btnMall:getContentSize().height *0.4))
	-- btnMall:addChild(btnMallFlashLeft)


	-- local flashLeft = cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(5/60), cc.Spawn:create(cc.ScaleTo:create(30/60, 1), cc.RotateBy:create(30/60, 180)), cc.Spawn:create(cc.ScaleTo:create(30/60, 0.1), cc.RotateBy:create(30/60, 180)), cc.FadeOut:create(5/60), cc.DelayTime:create(2)))
	-- btnMallFlashLeft:runAction(flashLeft)

	-- local btnMallFlashRigth = ccui.ImageView:create("lobby_mall_flash.png", ccui.TextureResType.plistType)
	-- btnMallFlashRigth:setScale(0.1)
	-- btnMallFlashRigth:setOpacity(0)
	-- btnMallFlashRigth:setPosition(cc.p(btnMall:getContentSize().width * 0.95, btnMall:getContentSize().height *0.8))
	-- btnMall:addChild(btnMallFlashRigth)

	-- local flashRigth = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.FadeIn:create(5/60), cc.Spawn:create(cc.ScaleTo:create(30/60, 1.5), cc.RotateBy:create(30/60, 180)), cc.Spawn:create(cc.ScaleTo:create(30/60, 0.1), cc.RotateBy:create(30/60, 180)), cc.FadeOut:create(5/60), cc.DelayTime:create(1)))
	-- btnMallFlashRigth:runAction(flashRigth)

	-- local imageShopAni1 = ccui.ImageView:create("lobby_btn_shop_ani.png", ccui.TextureResType.plistType)
	-- imageShopAni1:setTag(LobbyScene.BTN_SHOP)
	-- imageShopAni1:setPosition(cc.p(self:getContentSize().width - 150, 40))
	-- imageShopAni1:setTouchEnabled(true)
	-- self:addChild(imageShopAni1)
	-- imageShopAni1:addClickEventListener(btnCallBack)

	-- local imageShopAni2 = ccui.ImageView:create("lobby_btn_shop_ani.png", ccui.TextureResType.plistType)
	-- imageShopAni2:setTag(LobbyScene.BTN_SHOP)
	-- imageShopAni2:setPosition(cc.p(self:getContentSize().width - 120, 40))
	-- imageShopAni2:setTouchEnabled(true)
	-- self:addChild(imageShopAni2)
	-- imageShopAni2:addClickEventListener(btnCallBack)

	-- local imageShopAni3 = ccui.ImageView:create("lobby_btn_shop_ani.png", ccui.TextureResType.plistType)
	-- imageShopAni3:setTag(LobbyScene.BTN_SHOP)
	-- imageShopAni3:setPosition(cc.p(self:getContentSize().width - 90, 40))
	-- imageShopAni3:setTouchEnabled(true)
	-- self:addChild(imageShopAni3)
	-- imageShopAni3:addClickEventListener(btnCallBack)


	-- local lightAc1 = cc.Sequence:create(cc.FadeOut:create(20/60), cc.DelayTime:create(20/60), cc.FadeIn:create(20/60), cc.DelayTime:create(20/60))
	-- local lightAc2 = cc.Sequence:create(cc.DelayTime:create(10/60), cc.FadeOut:create(20/60), cc.DelayTime:create(20/60), cc.FadeIn:create(20/60), cc.DelayTime:create(10/60))
	-- local lightAc3 = cc.Sequence:create(cc.DelayTime:create(20/60),cc.FadeOut:create(20/60), cc.DelayTime:create(20/60), cc.FadeIn:create(20/60))

	-- local lightSqu1 = cc.RepeatForever:create(lightAc1)
	-- local lightSqu2 = cc.RepeatForever:create(lightAc2)
	-- local lightSqu3 = cc.RepeatForever:create(lightAc3)

	-- imageShopAni1:runAction(lightSqu1)
	-- imageShopAni2:runAction(lightSqu2)
	-- imageShopAni3:runAction(lightSqu3)
	-- imageShopAni1:setVisible(false)
	-- imageShopAni2:setVisible(false)
	-- imageShopAni3:setVisible(false)

	
	-- 添加顶部信息栏
	self._LobbyTopInfoView =  require("lobby/view/LobbyTopInfoView")
	self:addChild(self._LobbyTopInfoView:create(self._LobbyTopInfoView.Lobby), LobbyLocalZOrder.TOP_VIEW)

    

    -- 游戏入口
	local _lobbyEnter = LobbyGameEnter.new()
	self:addChild(_lobbyEnter,LobbyLocalZOrder.GAMEENTER_LAYER)

    -- 初始化红点
	self._redPointNodeList = {}
	for i=1,3 do
		local redPointNode = ccui.ImageView:create("common_redPoint.png", ccui.TextureResType.plistType)
    	redPointNode:setPosition(160 + (i-2)*130,75)
    	redPointNode:hide()
    	self:addChild(redPointNode)
    	table.insert(self._redPointNodeList,redPointNode)
	end

	-- 监听android实体按键
	local function onrelease(code, event)
		if code == cc.KeyCode.KEY_BACK then
			-- 返回键
			local function callback(event)
				if "ok" == event then
					-- local loginManager = require("LoginManager")
					net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
  						LoginManager:enterLogin()
	    			end)
				elseif "cancel" == event then
					GameUtils.hideMsgBox()
				end
			end
			local parm = {type = ConstantsData.ShowMgsBoxType.NORMAL_TYPE, msg = "确定退出游戏？", btn = {"ok","cancel"}, callback = callback}
			GameUtils.showMsgBox(parm)
		elseif code == cc.KeyCode.KEY_HOME then
			-- HOME无效
			-- cc.Director:getInstance():endToLua()
		end
	end

	local listener = cc.EventListenerKeyboard:create()	
	listener:registerScriptHandler(onrelease, cc.Handler.EVENT_KEYBOARD_RELEASED)	

	local eventDispatcher = lobbySceneBg:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, lobbySceneBg)

    -- 商城补单
	Mall.MallManager:getInstance():reIapVerify()

	-- 排行榜
	self.rankListView = require("lobby/view/RankListView").new()
	self:addChild(self.rankListView,LobbyLocalZOrder.RANK_LAYER)

	local RichBtn = "rankingList_btn.png"
    self._BtnRankList  = ccui.Button:create(RichBtn, RichBtn, RichBtn, ccui.TextureResType.plistType)
	self._BtnRankList:setPosition(-535,5)
	self._BtnRankList:setTag(LobbyScene.RANKLIST)
	self.rankListView:addChild(self._BtnRankList)
	self._BtnRankList:addClickEventListener(function(sender)
		self:requestRankView(sender)
	end)
	self._BtnRankList:setOpacity(0)

	self.rankView = require("lobby/view/RankView").new()
	self:addChild(self.rankView,LobbyLocalZOrder.RANK_LAYER+1)
	self.rankView:setPosition(0,375)

	local RankBtn = "rankingList_btn1.png"
    self._BtnRank  = ccui.Button:create(RankBtn, RankBtn, RankBtn, ccui.TextureResType.plistType)
	self._BtnRank:setPosition(-245,5)
	self.rankView:addChild(self._BtnRank)
	self._BtnRank:setTag(LobbyScene.RANK)
	self._BtnRank:addClickEventListener(function(sender)
		self:requestRankView(sender)
	end)
	self._BtnRank:setOpacity(0)
end

function LobbyScene:requestRankView( sender )
	local tag = sender:getTag()
	print("我要找tag",tag)
	if tag == LobbyScene.RANKLIST then
		self.rankView:show()
		self.rankView:runAction(cc.MoveTo:create(0.2,cc.p(667,375)))
		self.rankListView:hide()
	elseif tag == LobbyScene.RANK then
		self.rankView:runAction(cc.MoveTo:create(0.2,cc.p(0,375)))
		self.rankListView:show()
	end
end

-- 商城扫光动画
function LobbyScene:_addShopSaoiGuang(__targetNode)

	local clip = cc.ClippingNode:create()  --创建裁剪节点
	local ivShop = ccui.ImageView:create("lobby_btn_shop.png", ccui.TextureResType.plistType)		--创建模板
	clip:setStencil(ivShop)					--设置模板
	clip:setAlphaThreshold(0)				--设置裁剪阈值
	clip:setContentSize(cc.size(ivShop:getContentSize()))			--设置裁剪大小
	clip:setPosition(cc.p(clip:getContentSize().width/2, clip:getContentSize().height/2))
	clip:addChild(ivShop)

	local spark1 = ccui.ImageView:create("lobby_mall_saoguang.png", ccui.TextureResType.plistType)
	spark1:setPosition(cc.p(-spark1:getContentSize().width- 50, 0))
	clip:addChild(spark1)

	local spark2 = ccui.ImageView:create("lobby_mall_saoguang.png", ccui.TextureResType.plistType)
	spark2:setPosition(cc.p(-spark2:getContentSize().width - 50, 0))
	clip:addChild(spark2)

	clip:setPosition(cc.p(__targetNode:getContentSize().width/2, __targetNode:getContentSize().height/2))
	__targetNode:addChild(clip)

	local moveAction1 = cc.MoveBy:create(1, cc.p(ivShop:getContentSize().width + spark1:getContentSize().width, 0))
	local seq1 = cc.Sequence:create(moveAction1, cc.DelayTime:create(math.random(2, 2)), cc.CallFunc:create( function (sender)
    	sender:setPosition(cc.p(-sender:getContentSize().width - 50, 0))
    	end
	) )
	local repeatAction1 = cc.RepeatForever:create(seq1)
	spark1:runAction(repeatAction1)

	local moveAction2 = cc.MoveBy:create(1, cc.p(ivShop:getContentSize().width + spark2:getContentSize().width, 0))
	local seq2 = cc.Sequence:create(cc.DelayTime:create(math.random(2, 2)),moveAction2,  cc.CallFunc:create( function (sender)
    	sender:setPosition(cc.p(-sender:getContentSize().width - 50, 0))
    	end
	) )
	local repeatAction2 = cc.RepeatForever:create(seq2)
	
	spark2:runAction(repeatAction2)
end

function LobbyScene:setMoreBtnTexture(index)
	local state = index or 0
	cc.SpriteFrameCache:getInstance():addSpriteFrames("GameLayout/Lobby/Lobby.plist")
	if index == 1 then 
		self.btnMore:loadTextureNormal("lobby_btn_more_hide.png", UI_TEX_TYPE_PLIST)
	else
		self.btnMore:loadTextureNormal("lobby_btn_more_show.png", UI_TEX_TYPE_PLIST)
	end
end

--按钮事件
function LobbyScene:onButtonClickedEvent(tag, sender)
	if LobbyScene.IMAGE_MORE_OUT_BG == tag then
		self.btnMore:loadTextureNormal("lobby_btn_more_show.png", UI_TEX_TYPE_PLIST)
	
	elseif LobbyScene.BTN_MORE == tag or LobbyScene.TEXT_MORE == tag or LobbyScene.BTN_MORE_SHOW == tag then
		self._moreView = require("lobby/view/MoreView").new()
		self._moreView:setPosition(LOBBY_MORE_POS)
		self:addChild(self._moreView,LobbyLocalZOrder.MORE_LAYER)
		self:setMoreBtnTexture(1)

	elseif LobbyScene.BTN_MAIL == tag or LobbyScene.TEXT_MAIL == tag then
		-- request.LobbyRequest:RequestAuthorizeSitList()

	elseif LobbyScene.BTN_TASK == tag or LobbyScene.TEXT_TASK == tag then
		self:requestTaskInfo()
	elseif LobbyScene.BTN_FRIENDS == tag or LobbyScene.TEXT_FRIENDS == tag then
		self:requestFriendInfo()
	elseif LobbyScene.BTN_SPREAD == tag or LobbyScene.TEXT_SPREAD == tag then
		if 0 == UserData.loginType then
			local scene = cc.Director:getInstance():getRunningScene()
			if scene then 
				scene:addChild(require("src/lobby/layer/ChangeLoginTypeDialog"):create(),ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
			end
		else
			self:requestPromoteInfo()
		end

		-- 录音
		-- MultiPlatform:getInstance():startRcecord()
	elseif LobbyScene.BTN_SHOP == tag then
	  	self:addChild(require("src/lobby/layer/MallLayer"):create(config.MallLayerConfig.Type_Gold),ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
	
		--   MultiPlatform:getInstance():openBrowser("https://itunes.apple.com/cn/app/%E5%BE%AE%E4%BF%A1/id414478124?mt=8&v0=WWW-GCCN-ITSTOP100-FREEAPPS&l=&ign-mpt=uo%3D4")
		-- 结束录音
		-- MultiPlatform:getInstance():stopRcecord()
	else
		print("xiaxb=================unknow btn tag：" .. tag)
	end
end

function LobbyScene:showRedPointByIndex(__index)
	self._redPointNodeList[__index]:show()
end

function LobbyScene:hideRedPointByIndex(__index)
	self._redPointNodeList[__index]:hide()
end

function LobbyScene:showMailViewByData(__data)
	self:hideRedPointByIndex(ConstantsData.LobbyRedPointType.REDPOINT_MAIL)
	self._mailView = require("lobby/view/MailView").new(__data)
	self:addChild(self._mailView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
end

function LobbyScene:updataMailNode(__applyUserID,__ActionID)
	self._mailView:updataMailNode(__applyUserID,__ActionID)
end

function LobbyScene:requestPromoteInfo()
	logic.PromoteManager:getInstance():requestPromoteInfoData(function( result )
        if result then
			local _promoteLayer = PromoteLayer.new(result)
			self:addChild(_promoteLayer,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
        end
    end)
end

function LobbyScene:requestNoticeInfo()
	logic.LobbyManager:getInstance():requestNoticeInfoData(function( result )
        if result then
            local noticeView = NoticeView.new(result)
			self:addChild(noticeView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
        end
    end)
end

function LobbyScene:requestFriendInfo()
	local friendView = FriendView.new()
	self:addChild(friendView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
end

function LobbyScene:requestSignInfo()
	logic.LobbyManager:getInstance():requestSignInfoData(function( result )
        if result then
            local signView = SignView.new(result)
			self:addChild(signView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
        end
    end)
end

function LobbyScene:requestTaskInfo()
	if self._taskInfoData ~= nil then
		self:hideRedPointByIndex(ConstantsData.LobbyRedPointType.REDPOINT_TASK)
		local taskView = TaskView.new(self._taskInfoData)
		self:addChild(taskView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
	else
		logic.LobbyManager:getInstance():requestTaskInfoData(function( result )
        	if result then
        		self:hideRedPointByIndex(ConstantsData.LobbyRedPointType.REDPOINT_TASK)
            	local taskView = TaskView.new(result)
				self:addChild(taskView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
        	end
    	end)
	end
end

function LobbyScene:updateSignState()
	print("LobbyScene:updateSignState")
	if GameStateData.SignState == 1 then
		logic.LobbyManager:getInstance():requestSignSetData(function( result )
	       	if result.isShow == 1 then
	       		print("显示签到界面")
	        	logic.LobbyManager:getInstance():requestSignInfoData(function(signResult) 
	        		if signResult then
	        			local signView = SignView.new(signResult, function() self:updateNoticeState() end)
						self:addChild(signView,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
						GameStateData.SignState = 0
	        		end
	        	end)
	        else
	        	self:updateNoticeState()	
	        end
	    end)
	else
		self:updateNoticeState()
	end
end

function LobbyScene:updateNoticeState()
	print("LobbyScene:updateNoticeState")
	if GameStateData.NoticeEventState == 1 then
		logic.LobbyManager:getInstance():requestNoticeSetData(function( result )
			if result.switch == 1 then 
				logic.LobbyManager:getInstance():requestNoticeInfoData(function( result )
		        	if result then
		            	local noticeView = NoticeView.new(result)
						self:addChild(noticeView, ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
						GameStateData.NoticeEventState = 0
		        	end
		    	end)
			end
		end)
	end
end

-- 更新朋友列表信息
function LobbyScene:updateFriendListInfo()
	print("updateFriendListInfo")
	logic.FriendManager:getInstance():requestFriendListData(function( result )
		if result then
			UserData.FriendList = result
			print("好友数量:",#UserData.FriendList)
		end
	end)

end

function LobbyScene:updateLobbyServerInfoData()
	print("updateLobbyServerInfoData")
	GameUtils.startLoadingForever("正在连接大厅服...")
	logic.LobbyManager:getInstance():requestLobbyServerInfoData(function( result )
		if result then
			print("请求大厅服务器配置成功,IP,PORT:",LobbyData.LobbyServerIP,LobbyData.LobbyServerPort)
			logic.LobbyManager:getInstance():LoginLobbyServer()
		end
	end)
end

function LobbyScene:updateTaskInfoData()
	print("updateTaskInfoData")
	logic.LobbyManager:getInstance():requestTaskInfoData(function( result )
        if result then
        	self._taskInfoData = result
        	self:updataTaskRedPointByData(self._taskInfoData)
        end
    end)
end

function LobbyScene:updataTaskRedPointByData( __data )
	if __data == 0 then
		return
    end
	for k, v in ipairs(__data) do
		if v.process  >=  v.Count then -- 完成任务
			self:showRedPointByIndex(ConstantsData.LobbyRedPointType.REDPOINT_TASK)
			break
    	end
    end
end

function LobbyScene:runWithScene()
	local scene = cc.Scene:create()
	scene:addChild(self)
	if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end
end

function LobbyScene:onEnterGame()
	print("LobbyScene:onEnterGame",GameData.GameType)
	manager.ViewManager:getInstance():exitLobbyScene()
	local resList = {}
	print("GameID:",GameData.GameID)
    local resPathList = {config.GamePathResConfig:getGameResourcePath(GameData.GameID),
                    config.GamePathResConfig:getGameCommonResourcePath()}
    for k,v in pairs(resPathList) do
        local res = FileSystemUtils.addResource(v)
        for i,j in pairs(res) do
        	table.insert(resList,j)
        end
    end
    FileSystemUtils.loadResourceByLayer(resList,self.runGameScene)

    --self:runGameScene()
end

function LobbyScene:runGameScene()
	local __sceneRes = nil
	GameUtils.stopLoading()
	if GameData.GameType == config.GameType.COIN then --金币场
		__sceneRes = config.GamePathResConfig:getGoldGameSceneResPathRes()
	elseif GameData.GameType == config.GameType.SRF then  --私人房
		__sceneRes = config.GamePathResConfig:getPrivateGameSceneResPathRes()
	else
		print("进入游戏场景格式错误")
		return
	end
	print("__sceneRes",__sceneRes)	
	local gameScene = require(__sceneRes).new()
	if cc.Director:getInstance():getRunningScene() then
       	cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
end

function LobbyScene:onEnter()
	print("LobbyScene:onEnter===================================")
	UserData.RunSceneType = ConstantsData.SceneType.LOBBY_SCENE_TYPE
	logic.LobbyManager:getInstance():startEventListener(self)

	manager.ViewManager:getInstance():enterLobbyScene()

    local event = cc.EventCustom:new(config.EventConfig.EVENT_MUISIC_PLAY)
    event.userdata = {musicId = manager.MusicManager.MUSICID_LOBBY}
	lib.EventUtils.dispatch(event)

	-- if self.bottomBg then
 --        local size = self.bottomBg:getContentSize()
 --        GameUtils.comeOutEffectSlower(self.bottomBg,manager.ViewManager:getInstance():findLobbyComeOutEffectTime(),size,GameUtils.COMEOUT_BOTTON)
 --    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.001),cc.CallFunc:create(function ( ... )
    	print("登录大厅服务器...")
    	GameUtils.startLoadingForever("登录大厅服务器...")
    end)))
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.02),cc.CallFunc:create(function ( ... )
    	GameUtils.stopLoading()
	    manager.UserManager:getInstance():refreshUserInfo()
		if  lobby.LobbyGameEnterManager:getInstance():needToEnterInviteGameRoom() then  --邀请好友优先级比较高
		elseif lobby.LobbyGameEnterManager:getInstance():needEnterPreGameRoom()   then 
		else
			self:updateSignState()
			self:updateFriendListInfo()
			self:updateLobbyServerInfoData()
			self:updateTaskInfoData()
		end
    end)))

    local listeners = {
		lib.EventUtils.createEventCustomListener("APP_ENTER_FOREGROUND_EVENT",handler(self,self.checkTaskForEnterForeground)),
	}
	lib.EventUtils.registeAllListeners(self,listeners)
end

function LobbyScene:checkTaskForEnterForeground( ... )
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
			lobby.LobbyGameEnterManager:getInstance():needToEnterInviteGameRoom()
	end)))
end

function LobbyScene:onShowLoginTip( ... )
	if 0 == UserData.loginType then
		local scene = cc.Director:getInstance():getRunningScene()
		if scene then scene:addChild(require("src/lobby/layer/ChangeLoginTypeDialog"):create(),ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER) end
	end
end

function LobbyScene:onExit()
	print("LobbyScene:onExit")
	logic.LobbyManager:getInstance():stopEventListener()
	manager.ViewManager:getInstance():exitLobbyScene()
	lib.EventUtils.removeAllListeners(self)
end

return LobbyScene