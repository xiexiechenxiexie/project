--[[
    名称  :   ChangeLoginTypeDialog  切换登陆弹窗
    作者  :   Xiaxb   
    描述  :   ChangeLoginTypeDialog 	切换登陆弹窗
    时间  :   2017-8-07
--]]


-- 切换登陆弹窗
local ChangeLoginTypeDialog = class("ChangeLoginTypeDialog", lib.layer.BaseDialog)

function ChangeLoginTypeDialog:ctor()
	print("ChangeLoginTypeDialog:ctor")
	ChangeLoginTypeDialog.super.ctor(self)
	self:_initView()
end

-- 初始化试图视图
function ChangeLoginTypeDialog:_initView()

	-- 弹窗背景
	local dialogBg = ccui.ImageView:create("res/common/denglu_tishi_dikuang.png")
	dialogBg:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
	self:addChild(dialogBg)

	self:_onRootPanelInit(dialogBg)

	local dialogClose = ccui.Button:create("res/common/denglu_tishi_guanbi.png","res/common/denglu_tishi_guanbi1.png","")
	dialogClose:setPosition(cc.p(dialogBg:getContentSize().width - dialogClose:getContentSize().width/2 - 20, dialogBg:getContentSize().height - dialogClose:getContentSize().height/2 - 20))
	dialogBg:addChild(dialogClose)

	local function callback_Close( ... )
		-- body
		self:onCloseCallback()
	end

	dialogClose:addClickEventListener(callback_Close)

	local txt1 = ccui.Text:create()
	txt1:setText("尊敬的玩家，您正在使用【游客模式】进行游戏，\n游客模式下的游戏数据会在删除游戏、更换设备后清空。")
	txt1:setFontSize(24)
	txt1:setTextColor(cc.c4b(255, 255, 255, 255))
	txt1:setAnchorPoint(cc.p(0.5, 0.5))
	txt1:setPosition(cc.p(dialogBg:getContentSize().width/2, dialogBg:getContentSize().height*0.7))

	dialogBg:addChild(txt1)

	local txt2 = ccui.Text:create()
	txt2:setText("为了保障您的虚拟财产安全以及获得更完善的游戏体验，\n我们强烈建议您使用QQ或微信登录进行游戏！")
	txt2:setFontSize(24)
	txt2:setTextColor(cc.c4b(255, 255, 255, 255))
	txt2:setAnchorPoint(cc.p(0.5, 0.5))
	txt2:setPosition(cc.p(dialogBg:getContentSize().width/2, dialogBg:getContentSize().height*0.5))

	dialogBg:addChild(txt2)

	-- 切换登陆点击事件
	local function callback_Login( sender )
		print("callback_Login")
		self:removeFromParent()
		net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
			require("lobby/scene/LoginScene"):create():runWithScene()
		end)
	end 

	local btnQQLogin = ccui.Button:create("res/common/btn_qq_login.png")
	btnQQLogin:setPosition(cc.p(dialogBg:getContentSize().width*0.3, dialogBg:getContentSize().height*0.2))
	dialogBg:addChild(btnQQLogin)
	btnQQLogin:setVisible(false)

	btnQQLogin:addClickEventListener(callback_Login)

	local btnWechatLogin = ccui.Button:create("res/common/btn_wechat_login.png")
	btnWechatLogin:setPosition(cc.p(dialogBg:getContentSize().width*0.5, dialogBg:getContentSize().height*0.2))
	dialogBg:addChild(btnWechatLogin)
	btnWechatLogin:addClickEventListener(callback_Login)

	-- local isWXInstall =  MultiPlatform:getInstance():isPlatformInstalled(LoginManager.LoginType_Wechat)
 --    if "no" == isWXInstall then
 --    	btnWechatLogin:hide()
 --    	btnQQLogin:setPositionX(dialogBg:getContentSize().width*0.5)
	-- end


end

return ChangeLoginTypeDialog