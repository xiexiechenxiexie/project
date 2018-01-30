--[[
    名称  :   LoginScene  登录场景
    作者  :   Xiaxb   
    描述  :   Login登录场景，包含游客和QQ以及微信第三方登录
    时间  :   2017-7-12
--]]

local SocketClient = require "Lobby/src/net/SocketClient"

-- local LOGINSCENE_BG = "GameLayout/Login/bg.jpg"

local LoginScene = class("LoginScene", cc.Layer)

LoginScene.isAutoLogin = true

function LoginScene:ctor()

    LoginManager:initSDK()
	
    self:initView()
    self:enableNodeEvents()
end

function LoginScene:onEnter( ... )
	-- body
	manager.MusicManager:getInstance():stopMusic()
	if LoginScene.isAutoLogin then
    	LoginManager:autoLogin()
    end

end

function LoginScene:onExit( ... )
	-- body

end

-- 初始化视图控件
function LoginScene:initView()

	local loginScene = display.newSprite("GameLayout/Login/bg.png")
    loginScene:setPosition(667,375)
	self:addChild(loginScene)

	local dir = "GameLayout/Animation/DL_Animation/"
	local node = ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."DL_Animation0.png",dir.."DL_Animation0.plist",dir.."DL_Animation.ExportJson")  
    local adAnim = ccs.Armature:create("DL_Animation") 
    adAnim:setPosition(loginScene:getContentSize().width/2,loginScene:getContentSize().height/2) 
    loginScene:addChild(adAnim);
    adAnim:getAnimation():playWithIndex(0)

	local info = display.newSprite("GameLayout/Login/info.png")
    info:setPosition(667,50)
	loginScene:addChild(info)

	-- 微信安装检查 return yes or  no
	local isWXInstall =  MultiPlatform:getInstance():isPlatformInstalled(LoginManager.LoginType_Wechat)


	
	-- 游客登录
	self.btnGuest = lib.uidisplay.createUIButton({
        normal = "GameLayout/Login/btnTourist.png",
        isActionEnabled = true,
        pos = cc.p(270,165)
        })
	self.btnGuest:setTag(LoginManager.LoginType_Guest)
    self:addChild(self.btnGuest)

	-- QQ登录
	self.btnQQ = lib.uidisplay.createUIButton({
        normal = "GameLayout/Login/btnQQLogin.png",
        isActionEnabled = true,
        pos = cc.p(667,165)       
        })
	self.btnQQ:setTag(LoginManager.LoginType_QQ)
    self:addChild(self.btnQQ)
	
    -- 微信登录
	self.btnWechat = lib.uidisplay.createUIButton({
        normal = "GameLayout/Login/btnWX.png",
        isActionEnabled = true,
        pos = cc.p(1065,165)       
        })
	self.btnWechat:setTag(LoginManager.LoginType_Wechat)	
    self:addChild(self.btnWechat)

    if "no" == isWXInstall then
    	self.btnWechat:hide()
    	self.btnQQ:setPosition(display.width * 0.7,165)
    	self.btnGuest:setPosition(display.width * 0.3,165)
	end

	local function btnCallBack(sender)
		local targetPlatform = cc.Application:getInstance():getTargetPlatform()
		if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform) then
			LoginManager:thirdPartyLogin(sender:getTag(), self)
		else
			local loginURL = config.SDKConfig.getGuestLoginURL()
			LoginManager:login(loginURL)
			-- GameUtils.showMsg("不支持的登录平台")
		end
		return
	end

    self.loadingUI = require("lib/view/LoadingUI").new()
	-- self.loadingUI:play()
	self.loadingUI:setVisible(false)

	self.loginTip = ccui.Text:create()
	self.loginTip:setString("正在登录中...")
	self.loginTip:setFontSize(36)
	self.loginTip:setVisible(false)

	self.loadingUI:setPosition(cc.p(600 , self:getContentSize().height*0.25))
	self:addChild(self.loadingUI)

	self.loginTip:setPosition(cc.p(780, self:getContentSize().height*0.25))
	self:addChild(self.loginTip)

	-- 设置监听
	self.btnGuest:addClickEventListener(btnCallBack)
	self.btnQQ:addClickEventListener(btnCallBack)
	self.btnWechat:addClickEventListener(btnCallBack)
 
	-- 加载测试玩家列表
	-- self:showTestPlayerList()

    -- self:playWaitingAnimation()
	
	-- 监听android实体按键
	local function onrelease(code, event)
		if code == cc.KeyCode.KEY_BACK then
			-- 返回键
			local function callback(event)
				if "ok" == event then
					cc.Director:getInstance():endToLua()
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

	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

-- 登录完成则跳转到大厅场景
function LoginScene:enterLobby(isAutoLogin)
	require("lobby.scene.LobbyScene"):create():runWithScene()
end

function LoginScene:runWithScene(isAutoLogin)
	local scene = cc.Scene:create()
	scene:addChild(self)
	if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(scene)
    else
        cc.Director:getInstance():runWithScene(scene)
    end
    LoginScene.isAutoLogin = isAutoLogin
end

-- 加载测试账号列表
function LoginScene:showTestPlayerList()
	local listView = ccui.ListView:create()
	listView:setContentSize(180, 500)
    listView:setPosition(0, 0)
    listView:setDirection(1)
    listView:setItemsMargin(5)
   	listView:setBounceEnabled(true)
    listView:setInertiaScrollEnabled(true) 
	listView:setTouchEnabled(true)

	self:addChild(listView)

	local userList = cc.UserDefault:getInstance():getStringForKey("userList", "")
	--print("xiaxb------------userList:" .. userList)
	local userListTable = GameUtils.split(userList, ",")

	-- dump(userListTable, "xiaxb------userListTable")
	--print("xiaxb----------userListTable.size:" .. #userListTable)

	for k, v in pairs(userListTable) do
		--print("xiaxb-----------k:" .. k .. ",v:" .. v)
		local txtUser = ccui.Text:create()
		txtUser:setFontSize(36)
		txtUser:setString(v)
		txtUser:setTouchEnabled(true)
		listView:addChild(txtUser)	

		local function txtUserCallBack(sender, eventType)
			--print("xiaxb===========btnUserCallBack")
			local loginURL = config.SDKConfig.getTokenLoginURL() .. cc.UserDefault:getInstance():getStringForKey(v)
			--print("xiaxb-----------loginURL:" .. loginURL)
			-- require("lobby/model/LoginReq"):login(loginURL)
			LoginManager:login(loginURL)
			return
		end
		txtUser:addClickEventListener(txtUserCallBack)
	end
end

function LoginScene:playLoginAnimation()
	print("xiaxb", "playLoginAnimation   1")

	if self.btnGuest then
		self.btnGuest:setVisible(false)
		print("xiaxb", "playLoginAnimation   2")
	end

	if self.btnQQ then
		self.btnQQ:setVisible(false)
		print("xiaxb", "playLoginAnimation   3")
	end
	
	if self.btnWechat then
		self.btnWechat:setVisible(false)
		print("xiaxb", "playLoginAnimation   4")
	end

	if self.loginTip then
		self.loginTip:setVisible(true)
		print("xiaxb", "playLoginAnimation   5")
	end

	if self.loadingUI then
		self.loadingUI:setVisible(true)
		self.loadingUI:play()
		print("xiaxb", "playLoginAnimation   6")
	end
	print("xiaxb", "playLoginAnimation   7")
end

function LoginScene:showLoginBtns()
	print("xiaxb", "showLoginBtns   1")
	if self.btnGuest then
		self.btnGuest:setVisible(true)
		print("xiaxb", "showLoginBtns   2")
	end
	if self.btnQQ then
		self.btnQQ:setVisible(true)
		print("xiaxb", "showLoginBtns   3")
	end
	if self.btnWechat then	
		self.btnWechat:setVisible(true)
		print("xiaxb", "showLoginBtns   4")
	end
	if self.loginTip then
		self.loginTip:setVisible(false)
		print("xiaxb", "showLoginBtns   5")
	end
	if self.loadingUI then
		self.loadingUI:setVisible(false)
		self.loadingUI:stop()
		print("xiaxb", "showLoginBtns   6")
	end
	print("xiaxb", "showLoginBtns   7")
end

--播放加载时等待动画
function LoginScene:playWaitingAnimation()
    --红心扑克A的动画
    local redASprite = ccui.ImageView:create("GameLayout/Login/imgPork.png",ccui.TextureResType.localType)
    self:addChild(redASprite)
    redASprite:setPosition(cc.p(210,345))
    local shiningSprite = ccui.ImageView:create("GameLayout/Login/imgStarLight.png",ccui.TextureResType.localType)
    self:addChild(shiningSprite)
    shiningSprite:setPosition(cc.p(195,300))
    shiningSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.RotateTo:create(0.5,180),cc.RotateTo:create(0.5,360))))

    --动画
    local spriteAnimation = function (resPath,oriPos,aimPos)
        local girdNode = cc.NodeGrid:create()
        self:addChild(girdNode)
        girdNode:setPosition(oriPos)

        if resPath then
            girdNode:addChild(ccui.ImageView:create(resPath,ccui.TextureResType.localType))       
        end

        --Action
        local randomTime = math.random(100)/70.0+ 3     
        local actionMove1 = cc.MoveTo:create(randomTime,aimPos)
        local actionMove2 = cc.MoveTo:create(randomTime,oriPos)
        local actionShake = cc.Shaky3D:create(0.5,cc.size(12,12),1,false)
        local delayTime = cc.DelayTime:create(2.5)

        girdNode:runAction(cc.RepeatForever:create(cc.Sequence:create(actionMove1,actionMove2)))    
        girdNode:runAction(cc.RepeatForever:create(cc.Sequence:create(actionShake,delayTime)))
    end
    
    --骰子动画
    spriteAnimation("GameLayout/Login/imgDice.png",cc.p(460,530),cc.p(410,590))
                     
    --筹码动画       
    spriteAnimation("GameLayout/Login/imgChip.png",cc.p(1170,565),cc.p(1250,570))
                     
    --金币动画        
    spriteAnimation("GameLayout/Login/imgCoin.png",cc.p(1100,360),cc.p(1155,325))
                     
    --黑色扑克牌动画   
    spriteAnimation("GameLayout/Login/A.png",cc.p(940,560),cc.p(995,570))
end

return LoginScene