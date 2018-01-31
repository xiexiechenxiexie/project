
local GameIconFactory = require "GameIconFactory"
local JoinRoomView = require "JoinRoomView"


require "GameCreateRommManager"


local ScrollViewEx = class("ScrollViewEx",ccui.ScrollView)

ScrollViewEx._nodeCount = 0
ScrollViewEx._lastNodeX = 0
ScrollViewEx._padding = 0
function ScrollViewEx:ctor( ... )
	--print("ScrollViewEx:ctor")
	self._nodeCount = 0
	self:addEventListener(function (obj, eventType )
    	if eventType == ccui.ScrollviewEventType.touchReleased then
			self:onTouchReleased()
    	end
    end)
end

function ScrollViewEx:addItem( __item )
	assert(__item,"invalid __item")

	__item:setAnchorPoint(0.5,0.5)
	local containerLayer = self:getInnerContainer()
	local width = self:getContentSize().width
	local height = self:getContentSize().height
	local itemWidth = __item:getContentSize().width
	local itemHeight = __item:getContentSize().height

	if self._padding <= 0 then
		self._padding = (width - itemWidth * 3.5 ) * 0.25
	end

	local containerWidth = containerLayer:getContentSize().width
	local isScrollEnbale = false;
	local offsetX = itemWidth * 0.25
	local x = 0  
	local y = itemHeight * 0.5
	self._nodeCount = self._nodeCount + 1
	if self._nodeCount > 1 then
		x = self._lastNodeX + itemWidth + self._padding
	else
		x = offsetX + self._padding + itemWidth * 0.5 
	end
	self._lastNodeX = x
	__item:setPosition(x,y)
	isScrollEnbale = false
	local realWidth = x + itemWidth * 0.75 + self._padding
	if realWidth > containerWidth then
		containerWidth = realWidth 	
		isScrollEnbale = true		
	end
	containerLayer:addChild(__item)
	containerLayer:setContentSize(cc.size(containerWidth,height))
	self:setBounceEnabled(isScrollEnbale)
end

--[[--
释放触摸事件
]]
function ScrollViewEx:onTouchReleased( ... )
	--print("ScrollViewEx:onTouchReleased")
	--print(self:getInnerContainer():getPositionX())
	local dx = self:getInnerContainer():getContentSize().width - self:getContentSize().width
	if math.abs(dx) < 0.1 then
		return
	end
	local containerX = self:getInnerContainer():getPositionX()
	local xInContainerWorld = self:getContentSize().width * 0.5 - containerX
	local arrChildren = self:getChildren()
	local minX = self:getContentSize().width
	local targetNode = nil
	for i,v in ipairs(arrChildren) do
		local childX = v:getPositionX()
		local absX   = math.abs(xInContainerWorld - childX)
		print("absX" .. absX)
		if minX > absX then
			minX = absX
			targetNode = v
		end
	end
	print("minX" .. minX )
	local destX = targetNode:getPositionX()
	if xInContainerWorld > destX then
		xInContainerWorld = xInContainerWorld  - minX
	else
		xInContainerWorld = xInContainerWorld + minX	
	end
	local percent = (xInContainerWorld -  self:getContentSize().width * 0.5 ) / (self:getInnerContainer():getContentSize().width - self:getContentSize().width ) * 100
	print("percent" .. percent)
	if percent > 100 then 
		percent = 100
	elseif percent < 0 then
		percent = 0
	end
	self:scrollToPercentHorizontal(percent,0.25,true)
end

--[[--
滑动到指定位置，要某个Item中心点停留在在scrollview裁剪窗口中间
]]
function ScrollViewEx:scrollAfterDrag( ... )

end


local LobbyGameEnter = class("LobbyGameEnter", cc.Layer)
LobbyGameEnter.OVER_LAY = 1
LobbyGameEnter.OVER_UPDATE = 2
LobbyGameEnter.OVER_DOWNLOAD_ZIP = 3
LobbyGameEnter.OVER_LOCK = 4

local lobbyEnter = ""
local LOBBY_GAME_ENTER_DIR = ""
local BRNN_DIR = ""
local HHDZ_DIR = ""
local PSZ_DIR = ""
local KPQZ_DIR = ""
local SRF_DIR = ""
local KSKS_DIR = ""
local STAR_DIR = ""


function LobbyGameEnter:ctor()
	print("LobbyGameEnter:ctor >>> 1")
	local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end
    self._scrollView = nil
    self:registerScriptHandler(onNodeEvent)
    
    local fastButton = self:createFastStartBtn()
    if not manager.UserManager:getInstance():findAppCloseRoomCardFlag() then
    	self:createPrivateRoomBtn()
    else
    	if fastButton then fastButton:setPosition(662,217) end
    end
 	
 	cc.exports.lobby.LobbyGameEnterManager:getInstance():requestGameList()
end

function LobbyGameEnter:_createScrollView( ... )
    local _scrollView = ScrollViewEx:create()
    _scrollView:setDirection(ccui.ScrollViewDir.horizontal);--设置方向为垂直
    _scrollView:setTouchEnabled(true)--触摸的属性
    _scrollView:setBounceEnabled(true)--弹回的属性
    _scrollView:setScrollBarEnabled(false)
    _scrollView:setInertiaScrollEnabled(false)--滑动的惯性

    local size = {width = 895,height = 230}
    _scrollView:setContentSize(cc.size(size.width, size.height))--设置scrollView的大小，相当于是显示的区域
    _scrollView:setInnerContainerSize(cc.size(size.width, size.height))--设置容器的大小
    _scrollView:setAnchorPoint(cc.p(0,0));
    _scrollView:setPosition(cc.p(438,378));
    self:addChild(_scrollView)
    self._scrollView = _scrollView
end

function LobbyGameEnter:initScrollViewData( ... )
	local gameListData = lobby.LobbyGameEnterManager:getInstance():findShowGameList()
	for i=1,#gameListData do
		print("initScrollViewData",i,gameListData[i].gameId)
		local item = GameIconFactory:createIconBtn(gameListData[i].gameId,handler(self,self.onItemClick))
		self._scrollView:addItem(item)
	end
end

--[[--
LobbyGameEnter.OVER_LAY = 1
LobbyGameEnter.OVER_UPDATE = 2
LobbyGameEnter.OVER_DOWNLOAD_ZIP = 2
LobbyGameEnter.OVER_LOCK = 2
]]
function LobbyGameEnter:_refreshGameList()
	print("_refreshGameList")
	if self._scrollView == nil then self:_createScrollView() self:initScrollViewData()  end
	local children = self._scrollView:getChildren() 
	local manager = cc.exports.lobby.LobbyGameEnterManager:getInstance()
	for __,child in pairs(children) do

		local tag = child:getTag()
		print("tag---"..type(tag))
		local isEnablePlay = manager:isGameEnablePlay(tag)
		local isNeedUpdate = false
		local isDownLoadZip = false

		if isEnablePlay and manager:isGameNeedDownload(tag) then
			isDownLoadZip = true
			isNeedUpdate = true	
		elseif isEnablePlay and manager:isGameNeedUpdate(tag) then
			isDownLoadZip = false
			isNeedUpdate = true
		end

		print("_refreshGameList >> ",isEnablePlay,isNeedUpdate)
		local overlay = child:getChildByTag(LobbyGameEnter.OVER_LAY)
		if (not isEnablePlay) or (isEnablePlay and isNeedUpdate ) then
			if not overlay then
				overlay = cc.exports.lib.comp.ProgressToSprite.new(cc.Sprite:createWithSpriteFrameName(LOBBY_GAME_ENTER_DIR.."imgGameOverlay.png"),cc.PROGRESS_TIMER_TYPE_RADIAL)
				local size = child:getContentSize()
				overlay:setPosition(size.width / 2,size.height / 2)
				child:addChild(overlay)
				print(size.width,size.height)
				overlay:setScaleX(-1)
				overlay:setTotalTime(3)
				overlay:setPercent(100)
				overlay:setTag(LobbyGameEnter.OVER_LAY)
			end
			overlay:setVisible(true)
		else
			if overlay then overlay:setVisible(false) end
		end


		local lockTip = child:getChildByTag(LobbyGameEnter.OVER_UPDATE)
		if lockTip then lockTip:setVisible(false) end
		local downloadZip = child:getChildByTag(LobbyGameEnter.OVER_DOWNLOAD_ZIP)
		if downloadZip then downloadZip:setVisible(false) end
		local lockZip = child:getChildByTag(LobbyGameEnter.OVER_LOCK)
		if lockZip then lockZip:setVisible(false) end

		if not isEnablePlay then
			self:_addLockTip(child)--还没开发好，没的更新，没得玩，加把锁
		elseif isNeedUpdate then
			if isDownLoadZip then
				self:_addDownloadTip(child)--整包更新
			else	
				self:_addUpateTip(child)	--部分文件更新
			end
		end
	end
	self:_addKSKSTip()
end

function LobbyGameEnter:_addUpateTip( __targetNode )
	-- 196 209
	local imgUpadte = __targetNode:getChildByTag(LobbyGameEnter.OVER_UPDATE)
	if not imgUpadte then
		local parentDir = LOBBY_GAME_ENTER_DIR..""
		local updateFile = parentDir .. "imgGameUpdateText.png"
		imgUpadte = ccui.ImageView:create(updateFile,ccui.TextureResType.plistType)
		imgUpadte:setPosition(196,209)
		imgUpadte:setTag(LobbyGameEnter.OVER_UPDATE)
		__targetNode:addChild(imgUpadte)
	end
	imgUpadte:setVisible(true)
end

function LobbyGameEnter:_addDownloadTip( __targetNode )
	local parentDir = LOBBY_GAME_ENTER_DIR..""
	local downloadFile = parentDir .. "imgGameDownload.png"
	local imgDownloadZip = __targetNode:getChildByTag(LobbyGameEnter.OVER_DOWNLOAD_ZIP)
	if not imgDownloadZip then
		imgDownloadZip = ccui.ImageView:create(downloadFile,ccui.TextureResType.plistType)
		imgDownloadZip:setPosition(196,209)
		__targetNode:addChild(imgDownloadZip)
		imgDownloadZip:setTag(LobbyGameEnter.OVER_DOWNLOAD_ZIP)
	end
	imgDownloadZip:setVisible(true)
end

function LobbyGameEnter:_addLockTip( __targetNode )
	local parentDir = LOBBY_GAME_ENTER_DIR..""
	local lockFile = parentDir .. "imgGameLock.png"
	local imgLock = __targetNode:getChildByTag(LobbyGameEnter.OVER_LOCK)
	if not imgLock then
		imgLock = ccui.ImageView:create(lockFile,ccui.TextureResType.plistType)
		imgLock:setPosition(__targetNode:getContentSize().width / 2,__targetNode:getContentSize().height / 2)
		__targetNode:addChild(imgLock)
		imgLock:setTag(LobbyGameEnter.OVER_LOCK)



	end
	imgLock:setVisible(true)

	local  lockLabel = cc.Label:createWithTTF("敬请期待",GameUtils.getFontName(),20)
    lockLabel:setAnchorPoint(cc.p(0.5, 0.5))
    lockLabel:setOpacity(175)
    lockLabel:setColor(cc.c3b(255,255,255))
    lockLabel:setPosition(26,-14)
    imgLock:addChild(lockLabel)

end



function LobbyGameEnter:createPrivateRoomBtn( ... )
	-- 662 217
	local parentDir = SRF_DIR
	local btnSrf =  parentDir .. "btnSRF.png"
	local imgSRFMM = parentDir .. "imgSRFMM.png"
	local imgSRFText = parentDir .. "imgSRFText.png" 
	local imgPaoGuang = LOBBY_GAME_ENTER_DIR.."imgPaoGuang.png"
	local button = ccui.Button:create(btnSrf,btnSrf,btnSrf,ccui.TextureResType.plistType)
	button:setPressedActionEnabled(true)
	button:setPosition(662,217)
	button:addClickEventListener(handler(self,self.onSRFCallback))
	self:addChild(button)
	self:_addPaoGuang(button)

	local size = button:getContentSize()
	
	local imgSRFMM = ccui.ImageView:create(imgSRFMM,ccui.TextureResType.plistType)
	button:addChild(imgSRFMM)
	imgSRFMM:setPosition(284,size.height / 2 + 23)

	local imgSRFText = ccui.ImageView:create(imgSRFText,ccui.TextureResType.plistType)
	button:addChild(imgSRFText)
	imgSRFText:setPosition(imgSRFText:getContentSize().width / 2 + 30,size.height / 2 + 4)

	GameIconFactory:addStarEffect(imgSRFText,GameIconFactory.imgBigStar,{{x = 62,y = 80},{x = 120,y = 70},{x = 140,y = 40}})
	GameIconFactory:addStarEffect(imgSRFMM,GameIconFactory.imgBigStar,{{x = 120,y = 120}})
	
end

function LobbyGameEnter:_addPaoGuang( __targetNode )
	local imgPaoGuang = LOBBY_GAME_ENTER_DIR.."imgPaoGuang.png"
	local imgPaoGuangNode = ccui.ImageView:create(imgPaoGuang,ccui.TextureResType.plistType)
	imgPaoGuangNode:setPosition(imgPaoGuangNode:getContentSize().width / 2 ,__targetNode:getContentSize().height / 2 + 3)
	imgPaoGuangNode.orgX = imgPaoGuangNode:getPositionX()
	imgPaoGuangNode.orgY = imgPaoGuangNode:getPositionY()
	__targetNode:addChild(imgPaoGuangNode)

	imgPaoGuangNode:setOpacity(0.7)
	local actionBy = cc.MoveBy:create(0.7, cc.p(__targetNode:getContentSize().width - imgPaoGuangNode:getContentSize().width  - 140,0))
	local fadeIn   = cc.FadeIn:create(0.3)
	local fadeOut = cc.FadeOut:create(0.4)
	local fade = cc.Sequence:create(fadeIn,fadeOut)
	local func = cc.CallFunc:create(function ( sender )
		sender:setOpacity(0.5)
		sender:setPosition(sender.orgX,sender.orgY)
	end)
	local delayTime = cc.DelayTime:create(math.random(20,50) * 0.06)
	imgPaoGuangNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(actionBy,fade),func,delayTime)))

end

function LobbyGameEnter:_addKSKSTip( ... )
	local managerClazz =  cc.exports.lobby.LobbyGameEnterManager
	local imgCache = {
		[managerClazz.KPQZ] = {
			imgFile = KPQZ_DIR .."imgKPQZTip.png",
		},
		[managerClazz.BRNN] = {
			imgFile = BRNN_DIR.."imgBRNNTip.png",
		},
		[managerClazz.HHDZ] = {
			imgFile = HHDZ_DIR .."imgHHDZTip.png",
		},
		[managerClazz.PSZ] = {
			imgFile = PSZ_DIR .. "imgPSZTip.png",
		}
	}

	local gameId = managerClazz:getInstance():findKSKSGameId()
	print("ksks gameId",gameId)
	local imgFileFrameName = imgCache[gameId].imgFile
	local imgTipFileFrameName = LOBBY_GAME_ENTER_DIR.."imgTipPaoPao.png"
    local imgTipNode = ccui.ImageView:create(imgTipFileFrameName,ccui.TextureResType.plistType)
    imgTipNode:setLocalZOrder(-1)

	local targetNode = self._btnKSKS
	targetNode:addChild(imgTipNode)
	local action = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(1,cc.p(0,10)),cc.MoveBy:create(1,cc.p(0,-10))))
	imgTipNode:runAction(action)
	imgTipNode:setPosition(targetNode:getContentSize().width / 2 - 20 ,targetNode:getContentSize().height + 25)

	local imgTipText = ccui.ImageView:create(imgFileFrameName,ccui.TextureResType.plistType)
	imgTipNode:addChild(imgTipText)
	imgTipText:setPosition(imgTipNode:getContentSize().width / 2,imgTipNode:getContentSize().height / 2 + 10)


        --创建动画
	local spriteFrame  = cc.SpriteFrameCache:getInstance()
   	spriteFrame:addSpriteFrames("Lobby/res/GameLayout/Lobby/LobbyEnter/lightEffect.plist",
        "Lobby/res/GameLayout/Lobby/LobbyEnter/lightEffect.png")

    local animation =cc.Animation:create()
    for i=1,12 do  
        local frameName = string.format("qipaopaoguang_%d.png",i)
        local sFrame = spriteFrame:getSpriteFrame(frameName)
        animation:addSpriteFrame(sFrame)
    end
    animation:setDelayPerUnit(0.1)          --设置两个帧播放时间
    animation:setRestoreOriginalFrame(true)
    local action =cc.Animate:create(animation)
    
    local testSprite = cc.Sprite:createWithSpriteFrameName("qipaopaoguang_1.png")
    testSprite:setPosition(imgTipNode:getContentSize().width / 2,imgTipNode:getContentSize().height / 2)
    imgTipNode:addChild(testSprite)
    testSprite:runAction(cc.RepeatForever:create(action))
end


function LobbyGameEnter:createFastStartBtn( ... )
	--1093 217
	local parentDir = KSKS_DIR
	local btnKSKS = parentDir .. "btnKSKS.png"
	local imgKSKSText = parentDir .. "imgKSKSText.png"
	local imgKSKSHuoJian = parentDir .. "imgKSKSHuoJian.png"
	
	local button = ccui.Button:create(btnKSKS,btnKSKS,btnKSKS,ccui.TextureResType.plistType)
	button:setPressedActionEnabled(true)
	button:setPosition(1093,217)
	button:addClickEventListener(handler(self,self.onKsksCallback))
	self._btnKSKS = button
	self:addChild(button)
	self:_addPaoGuang(button)
	local size = button:getContentSize()

	local imgKSKSText = ccui.ImageView:create(imgKSKSText,ccui.TextureResType.plistType)
	imgKSKSText:setPosition(125,size.height / 2 + 4)
	button:addChild(imgKSKSText)

	local imgKSKSHuoJian = ccui.ImageView:create(imgKSKSHuoJian,ccui.TextureResType.plistType)
	button:addChild(imgKSKSHuoJian)
	imgKSKSHuoJian:setPosition(284,90)
	GameIconFactory:addStarEffect(imgKSKSText,GameIconFactory.imgBigStar,{{x = 62,y = 80},{x = 120,y = 70},{x = 140,y = 40}})
	GameIconFactory:addStarEffect(imgKSKSHuoJian,GameIconFactory.imgBigStar,{{x = 75,y = 132}})
	return button
end





-- LobbyGameEnter.OVER_LAY = 1
-- LobbyGameEnter.OVER_UPDATE = 2
-- LobbyGameEnter.OVER_DOWNLOAD_ZIP = 3
-- LobbyGameEnter.OVER_LOCK = 4
function LobbyGameEnter:_hotUpdateCallback(__data )
	print("LobbyGameEnter:_hotUpdateCallback",__data.gameId,__data.percent,__data.error)
	local data = __data
	local percent = __data.percent
	local manager = lobby.LobbyGameEnterManager:getInstance()
	if self._scrollView then
		local child = self._scrollView:getInnerContainer():getChildByTag(data.gameId)

		local overlay = child:getChildByTag(LobbyGameEnter.OVER_LAY )
		if  overlay then
			if __data.error then
				-- overlay:setProgcessTo(100)
				-- manager:tryReUpdate(data.gameId,handler(self,self._hotUpdateCallback))	
				return	
			else
				print("percent",percent,overlay:getPercent())
				local process = function ( __percent,__gameId )
					
					if __percent > 0 and __percent ~= (100 - overlay:getPercent()) then 
						print("percent>>...",__percent,overlay:getPercent())
						overlay:setProgcessTo(100 - __percent,function ( __target )
							print("process TO")
							if __percent >= 100 then 
								print("finish dowload act")
								manager:finishDownload(__gameId)
							end
						end)	
					end
				end
				process(__data.percent,__data.gameId)
				
			end
		end

		if __data.percent >= 100 then
			local update = child:getChildByTag(LobbyGameEnter.OVER_UPDATE )
			if update then
				update:removeFromParent()
			end
			local downloadZip = child:getChildByTag(LobbyGameEnter.OVER_DOWNLOAD_ZIP )
			if downloadZip then
				downloadZip:removeFromParent()
			end
		end

		-- local lock = child:getChildByTag(LobbyGameEnter.OVER_LOCK )
		-- if lock then
		-- 	lock:removeFromParent()
		-- end
	end
end


function LobbyGameEnter:_checkUpdate(__gameId )
	local manager = cc.exports.lobby.LobbyGameEnterManager:getInstance()
	if not manager:isGameEnablePlay(__gameId) then
		print("不能玩游戏")
		GameUtils.showMsg("攻城狮玩命开发中...")
		return true
	end
	if manager:isGameNeedUpdate(__gameId) then
		print("需要更新游戏")
		manager:update(__gameId,handler(self,self._hotUpdateCallback))
		return true
	end
	if manager:isGameNeedDownload(__gameId) then
		print("需要下载游戏")
		manager:update(__gameId,handler(self,self._hotUpdateCallback))
		return true
	end
	return false
end

function LobbyGameEnter:onGamePreEnter( __gameId )
	print("LobbyGameEnter:onItemClick >> " .. __gameId) 
	local managerClazz = lobby.LobbyGameEnterManager
	if managerClazz:getInstance():isDoingEnterGameRoom() then 
		GameUtils.showMsg("正在准备进入游戏中...")
		return false
	end
	if self:_checkUpdate(__gameId) then 
		return false
	end
	
	return true
end

--[[--
游戏列表按钮回调
]]
function LobbyGameEnter:onItemClick( sender )
	local gameId = sender:getTag()
	print("游戏列表按钮回调",gameId) 
	if self:onGamePreEnter(gameId) then self:_enterGame(gameId) end
end

function LobbyGameEnter:_gotoSelectPlayScene(__gameId )
	print("去选择场次 私人房和场次",__gameId)
	lobby.LobbyGameEnterManager:getInstance():enterPlays(gameId)
end


function LobbyGameEnter:_enterGame( __gameId )
	local managerClazz = lobby.LobbyGameEnterManager

	managerClazz:getInstance():setSelectGameId(__gameId)
	if managerClazz:getInstance():isNeedToSelectPlayScene(__gameId) then
		self:_gotoSelectPlayScene(__gameId)
		return
	end
	if __gameId == managerClazz.BRNN then
		print("百人牛牛入口")
		logic.LobbyTableManager:getInstance():RequestQuickJoinTable()
	elseif __gameId == managerClazz.KPQZ then
		logic.LobbyManager:getInstance():LoginGameServer()
		print("看牌强庄")
	elseif __gameId == managerClazz.PSZ then
		print("拼三张")
		logic.LobbyManager:getInstance():LoginGameServer()
	elseif __gameId == managerClazz.HHDZ then
		print("红黑大战")
	else 

	end

end

--[[--
私人房  目前私人房只有一个游戏 后续可能会是多个
]]
function LobbyGameEnter:onSRFCallback(  )
	print("LobbyGameEnter:onSRFCallback")
	local managerClazz = lobby.LobbyGameEnterManager
	if self:onGamePreEnter(managerClazz:getInstance():findSRFGameId()) then 
		local managerClazz = cc.exports.lobby.LobbyGameEnterManager
		if managerClazz:getInstance():findSRFGameId() > 0 then 
			managerClazz:getInstance():setSelectGameId(managerClazz:getInstance():findSRFGameId())
			local view  = JoinRoomView.create()
			cc.Director:getInstance():getRunningScene():addChild(view)
		end
	end 
end

--[[--
快速开始
]]
function LobbyGameEnter:onKsksCallback( ... )
	print("LobbyGameEnter1111:onKsksCallback")
	local ksksGameId = cc.exports.lobby.LobbyGameEnterManager:getInstance():findKSKSGameId()
	if self:onGamePreEnter(ksksGameId) then self:_enterGame(ksksGameId) end
end

function LobbyGameEnter:onExit( ... )
	lib.EventUtils.removeAllListeners(self)
end

function LobbyGameEnter:onEnterGameEventCallback( __event )
	print("LobbyGameEnter:onEnterGameEventCallback")
	assert(__event.userdata,"invalid event")
	local gameId = __event.userdata.gameId
	self:_checkUpdate(gameId)
end

function LobbyGameEnter:onEnter( ... )
	local size = {width = 895,height = 230}
	GameUtils.comeOutEffectSlower(self,manager.ViewManager:getInstance():findLobbyComeOutEffectTime(),size,GameUtils.COMEOUT_RIGHT)
	local listeners = {
		lib.EventUtils.createEventCustomListener(config.EventConfig.PIPLE_TO_ENTER_GAME,handler(self,self.onEnterGameEventCallback)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_GAME_LIST_REFRESH,handler(self,self._refreshGameList)), 
	}
	lib.EventUtils.registeAllListeners(self,listeners)
end

function LobbyGameEnter:onDestory( ... )
	
end
return LobbyGameEnter