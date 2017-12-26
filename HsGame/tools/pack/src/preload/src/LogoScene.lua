--[[
    名称  :   LogoScene  封页场景
    作者  :   Xiaxb   
    描述  :   封页Logo显示场景，包含游戏强制更新和大厅热更新模块
    时间  :   2017-7-12
--]]
require "src/lib/utils/EventUtils.lua"

local LogoScene = class("LogoScene", cc.Layer)

function LogoScene:ctor()
	--第一次用的是本地包版本号 不允许用热更新的 不然一些旧的热更缓存的版本号或者其他功能会运行，比如整包更新之后,不需要不就的热更缓存，就得用新包里面版本号来判断清楚热更搜索路径
    Boot:boot(true)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	local winSize = cc.Director:getInstance():getWinSize()

	self.loadResArr = {}
    self._loadedCount = 0

    self:initView(logoScene)
    self:_initNodeEvent()
end  

function LogoScene:_initNodeEvent( ... )
    local function onNodeEvent(event)
        if "enter" == event then
            self:onEnter()           
        elseif "exit" == event then
            self:onExit()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end  


function LogoScene:onEnter( ... )
	self:addEventListerns()
	self:checkHotUpdate()
end

function LogoScene:onExit( ... )
	print("LogoScene:onExit")
	self:removeEventListeners()
end

function LogoScene:addEventListerns()
	local listeners = self:onListersInitCallback()
	if listeners then
		lib.EventUtils.registeAllListeners(self,listeners)
	end
end

function LogoScene:removeEventListeners( ... )
	lib.EventUtils.removeAllListeners(self)
end

function LogoScene:onListersInitCallback( ... )
	local listeners = {
		lib.EventUtils.createEventCustomListener(lib.download.HotUpdateManager.EVENT_UPDATE_SUCCESS,handler(self,self.onUpdateFinish)),
		lib.EventUtils.createEventCustomListener(lib.download.HotUpdateManager.EVENT_UPDATE_ERROR,handler(self,self.onUpdateError)),
		lib.EventUtils.createEventCustomListener(lib.download.HotUpdateManager.EVENT_UPDATE_MAXVERSION,handler(self,self.onUpdateMaxVersionFound)),
		lib.EventUtils.createEventCustomListener(lib.download.HotUpdateManager.EVENT_UPDATE_PROGRESS,handler(self,self.onUpdateProgress)),
	}
	return listeners
end

function LogoScene:onUpdateFinish( event )
	print("LogoScene:onUpdateFinish")
    self:queryServerState()
end

function LogoScene:queryServerState( ... )
	local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_CHECK_STATUS
    HttpClient:get(url,function ( __error,__response )
    	if __error or not __response then 
			Boot:boot()
    		self:addResourceAnsy()
    		return
    	end
    	if tonumber(__response.status) == 0 then --0停服更新  1 正常
			local Clazz = require "src/preload/src/ServerUpdateView.lua"
			local msgStr = "停服更新!"
			if __response.msg and __response.msg.content then msgStr = __response.msg.content end
			local view = Clazz.new({info = msgStr})
			self:addChild(view)
		else
			Boot:boot()
    		self:addResourceAnsy()
    	end
    end)
end


function LogoScene:onUpdateError( event )
	-- if self._hotUpdateNode  then 
	-- 	self._hotUpdateNode:removeFromParent()
	-- end
	-- self._hotUpdateNode = lib.download.HotUpdateManager.new(-1,nil) 
	-- self:addChild(self._hotUpdateNode)
	-- self._hotUpdateNode:checkUpdate()
	-- if self._hotUpdateNode then self._hotUpdateNode:downloadFailedAssets() end
end

function LogoScene:onUpdateMaxVersionFound( event )
	local info = self._hotUpdateNode:findDownloadInfo()
    -- self._downloadInfo.version  --版本
    -- self._downloadInfo.description --描述
    -- self._downloadInfo.allowance   --补偿
    -- self._downloadInfo.isForce  --是否强制更新 
    -- self._downloadInfo.updateUrl  --更新链接
    -- self._downloadInfo.releaseTime  -- 发布时间
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if device.platform == "android"  then
		--todo:调动系统,下载整包,去安装界面
	elseif device.platform == "ios" or device.platform == "mac"  then 

	elseif device.platform == "windows" then

	end
end

function LogoScene:onUpdateProgress( event )
	self:updateBar(event.userdata.percent,self:findUpdateProgressString())
end

--[[--
检测热更新(大厅部分)
]]
function LogoScene:checkHotUpdate( ... )
	local gameId = -1
	local updateFunc = function ( ... )
		if lib.download.HotUpdateManager:isGameModelNeedToUpadte(gameId) then 
			local hot = lib.download.HotUpdateManager.new(-1,nil) 
			self._hotUpdateNode = hot
			self:addChild(hot)
			hot:checkUpdate()
		else
			print("跳过热更新")
			self:onUpdateFinish()
		end
	end	

	lib.download.HotUpdateManager:queryManifests(function ( ... )
		--检测大包
		local downloadInfo = lib.download.HotUpdateManager:findDownloadInfo()
		if downloadInfo then
			local version = downloadInfo.version;
			if version  then
				print("fly","config.channle.VERSION",config.channle.VERSION)
				local code = lib.download.HotUpdateManager:findVersionChangedCode(config.channle.VERSION,version)
				if code then
					print("强制更新...")
					local updateBigPackage = require "src/preload/src/UpdateBigPackageView"
					self:addChild(updateBigPackage.new(downloadInfo))
				else
					updateFunc()
				end
			else
				updateFunc()
			end
		else
			updateFunc()
		end
	end)

end


-- 初始化视图控件
function LogoScene:initView(logoScene)

	local bg = ccui.ImageView:create("src/preload/res/bg.png")
	self:addChild(bg)
	bg:setPosition(display.width * 0.5,display.height * 0.5)

	local imgGirl = ccui.ImageView:create("src/preload/res/imgGirl.png")
	bg:addChild(imgGirl)

	imgGirl:setPosition(cc.p(667,345))

		
 	local loadBarBg = ccui.ImageView:create("src/preload/res/loading_bg.png")
	bg:addChild(loadBarBg)
	loadBarBg:setPosition(display.width * 0.5,150)
	local size = loadBarBg:getContentSize()

	self.loadingBar = ccui.LoadingBar:create("src/preload/res/loading.png")
	loadBarBg:addChild(self.loadingBar)
	self.loadingBar:setPosition(size.width * 0.5,size.height * 0.5)
 

	local labelConfig =	{
		fontName = GameUtils.getFontName(),
		fontSize = 23,
		text = "0%",
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(display.width * 0.5 ,loadBarBg:getPositionY() - 50),
		anchorPoint = cc.p(0.5,0.5)
	}
	self.textTip = cc.exports.lib.uidisplay.createLabel(labelConfig)
	bg:addChild(self.textTip)

	local labelConfig =	{
		fontName = GameUtils.getFontName(),
		fontSize = 28,
		text = "...",
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(display.width * 0.5 + size.width * 0.5 + 20,loadBarBg:getPositionY()),
		anchorPoint = cc.p(0,0.5)
	}
	self.textProgressValue = cc.exports.lib.uidisplay.createLabel(labelConfig)
	bg:addChild(self.textProgressValue)

    self:playWaitingAnimation()
end

--播放加载时等待动画
function LogoScene:playWaitingAnimation()
    --红心扑克A的动画
    local redASprite = ccui.ImageView:create("src/preload/res/imgPork.png",ccui.TextureResType.localType)
    self:addChild(redASprite)
    redASprite:setPosition(cc.p(410,431))
    redASprite:runAction(cc.Sequence:create(cc.MoveTo:create(0.3,cc.p(210,345)),cc.CallFunc:create(
        function ()
            local shiningSprite = ccui.ImageView:create("src/preload/res/imgStarLight.png",ccui.TextureResType.localType)
            self:addChild(shiningSprite)
            shiningSprite:setPosition(cc.p(195,300))
            shiningSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateTo:create(0.5,180),cc.RotateTo:create(0.5,360))))    
        end)))

    --动画
    local spriteAnimation = function (resPath,oriPos,aimPos)
        local girdNode = cc.NodeGrid:create()
        self:addChild(girdNode)
        girdNode:setPosition(oriPos)

        if resPath then
            girdNode:addChild(ccui.ImageView:create(resPath,ccui.TextureResType.localType))       
        end

        --Action     
        local actionMove1 = cc.MoveTo:create(3,aimPos)
        local actionMove2 = cc.MoveTo:create(3,oriPos)
        local actionShake = cc.Shaky3D:create(0.5,cc.size(12,12),1,false)
        local delayTime = cc.DelayTime:create(2.5)

        girdNode:runAction(cc.RepeatForever:create(cc.Sequence:create(actionMove1,actionMove2)))    
        girdNode:runAction(cc.RepeatForever:create(cc.Sequence:create(actionShake,delayTime)))
    end
    
    --骰子动画
    spriteAnimation("src/preload/res/imgDice.png",cc.p(460,530),cc.p(410,590))

    --筹码动画
    spriteAnimation("src/preload/res/imgChip.png",cc.p(1170,565),cc.p(1250,570))

    --金币动画
    spriteAnimation("src/preload/res/imgCoin.png",cc.p(1100,360),cc.p(1155,325))

    --黑色扑克牌动画
    spriteAnimation("src/preload/res/A.png",cc.p(940,560),cc.p(995,570))
end


function LogoScene:onLoadCallback( ... )
	self._loadedCount = self._loadedCount  + 1
	self:updateBar(self._loadedCount/#self.loadResArr * 100)
	
	if self.loadResArr[self._loadedCount].plist ~= nil then
		cc.SpriteFrameCache:getInstance():addSpriteFrames(self.loadResArr[self._loadedCount].plist)
	end

	if self._loadedCount >= #self.loadResArr then
		require "lobby/model/LoginManager.lua"
		LoginManager:enterLogin(true)
	end
end

function LogoScene:addResourceAnsy( ... )
	print("addResourceAnsy")
	self.textTip:setString(self:findLoadResString())
	local ResourceManager = require "src/preload/src/ResourceManager.lua"
	self.loadResArr = 	ResourceManager.findResourceList()
	
	for i,v in ipairs(self.loadResArr) do
		cc.Director:getInstance():getTextureCache():addImageAsync(v.fileName, handler(self,self.onLoadCallback))
	end
end

-- 更新进度条
function LogoScene:updateBar(percent,tipString)

	if nil == self.loadingBar then
		return
	end
	if self.textProgressValue then
		local str = string.format("%d%%", percent)
		self.textProgressValue:setString(str)
	end
	self.loadingBar:setPercent(percent)
	if tipString then
		self.textTip:setString(tipString)
	end
end


-- 更新完成跳转至登录场景
-- function LogoScene:enterLogin()
-- 	local initData = require "data/initData"
--     initData.init()
-- 	require "LoginManager"
-- 	LoginManager:getInstance():enterLogin()
-- end

-- 登录完成则跳转到大厅场景
-- function LogoScene:enterLobby()
-- 	require("lobby.scene.LobbyScene"):create():runWithScene()
-- end

function LogoScene:runWithScene()
	local scene = cc.Scene:create()
	scene:addChild(self)
	if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end
end


function LogoScene:findUpdateProgressString( ... )
	return "正在热更新..."
end

function LogoScene:findLoadResString( ... )
	return "正在加载资源，不消耗任何流量..."
end

return LogoScene