-- 绑定手机号码
-- @date 2017.09.01
-- @author tangwen

local BindingMobileView = class("BindingMobileView", lib.layer.Window)
local scheduler = require("cocos.framework.scheduler")

local Promote_Code_time ="PROMOTE_CODE_TIMECODE_IMG"

function BindingMobileView:ctor()
	BindingMobileView.super.ctor(self,ConstantsData.WindowType.WINDOW_MIDDLE)
	self:initView()
end

function BindingMobileView:initView()
    local bg = self._root
    self._bg = bg

    local bgSize = self._bg:getContentSize()
    local title = ccui.ImageView:create("Lobby_Promote_view_title_mobilePhone.png", ccui.TextureResType.plistType)
    title:setPosition(bgSize.width/2, bgSize.height - 25)
    self._bg:addChild(title)

    local MobileText = cc.Label:createWithTTF("手机号:",GameUtils.getFontName(),40)
    MobileText:setAnchorPoint(cc.p(0.5, 0.5))
    MobileText:setColor(cc.c3b(255,255,255))
    MobileText:setPosition(210, bgSize.height - 161)
    bg:addChild(MobileText)

    local CodeText = cc.Label:createWithTTF("验证码:",GameUtils.getFontName(),40)
    CodeText:setAnchorPoint(cc.p(0.5, 0.5))
    CodeText:setColor(cc.c3b(255,255,255))
    CodeText:setPosition(210, bgSize.height/2 - 30)
    bg:addChild(CodeText)

    local SendImg = "Lobby_Promote_view_btn_send.png"
    self._btnSend = lib.uidisplay.createUIButton({
        normal = SendImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            self:requestMobileCode()
        end
        })

	self._btnSend:setPosition(bgSize.width/2 + 180, bgSize.height/2 - 30)
	bg:addChild(self._btnSend,3)

	self._TimeText = cc.Label:createWithTTF("60S",GameUtils.getFontName(),40)
    self._TimeText:setAnchorPoint(cc.p(0.5, 0.5))
    self._TimeText:setPosition(180,38)
    self._btnSend:addChild(self._TimeText)
    self._TimeText:hide()


    local okImg = "common_btn_sure.png"
    local btnOk = lib.uidisplay.createUIButton({
        normal = okImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            self:requestBindingMobile()
        end
        })

	btnOk:setPosition(bgSize.width/2, 96)
	bg:addChild(btnOk,2)

    self._MobileEditBox = cc.EditBox:create(cc.size(435,71),"Lobby_Promote_view_editBox_bg.png", ccui.TextureResType.plistType)
    self._MobileEditBox:setPosition(bgSize.width/2 + 35, bgSize.height - 161)
    self._MobileEditBox:setFontName(GameUtils.getFontName())
    self._MobileEditBox:setFontSize(44)
    self._MobileEditBox:setFontColor(cc.c3b(255,255,255))
    self._MobileEditBox:setMaxLength(11)
    self._MobileEditBox:setPlaceholderFontColor(cc.c3b(255,255,255))
    self._MobileEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self._MobileEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self._MobileEditBox:registerScriptEditBoxHandler(function(strEventName,pSender)self:mobileEditBoxTextEventHandle(strEventName,pSender)end)
    self._bg:addChild(self._MobileEditBox)

    self._CodeEditBox = cc.EditBox:create(cc.size(265,71),"Lobby_Promote_view_editBox_bg.png", ccui.TextureResType.plistType)
    self._CodeEditBox:setPosition(bgSize.width/2 - 45, bgSize.height/2 - 30)
    self._CodeEditBox:setFontName(GameUtils.getFontName())
    self._CodeEditBox:setFontSize(44)
    self._CodeEditBox:setFontColor(cc.c3b(255,255,255))
    self._CodeEditBox:setMaxLength(6)
    self._CodeEditBox:setPlaceholderFontColor(cc.c3b(255,255,255))
    self._CodeEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self._CodeEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self._CodeEditBox:registerScriptEditBoxHandler(function(strEventName,pSender)self:codeEditBoxTextEventHandle(strEventName,pSender)end)
    self._bg:addChild(self._CodeEditBox)

 --    local curTime = os.time()
 --    local sendTime = cc.UserDefault:getInstance():getFloatForKey(Promote_Code_time)
 --    local intervalTime = curTime - sendTime
 --    print("curTime,sendTime,intervalTime:",curTime,sendTime,intervalTime)
 --    if sendTime ~= 0 and intervalTime < 60 then
	-- 	self:updateTimeText(60 - intervalTime)
	-- end


end

function BindingMobileView:requestMobileCode()
	logic.PromoteManager:getInstance():requestMobileCodeData(self._MobileEditBox:getText(),function( result )
        if result then
        	-- local curTime = os.time()
        	-- print("写入的时间:",curTime)
        	-- cc.UserDefault:getInstance():setFloatForKey(Promote_Code_time,curTime)
            self:updateTimeText(60)
        end
    end)
end

function BindingMobileView:requestBindingMobile()
	logic.PromoteManager:getInstance():requestBindingMobileData(self._CodeEditBox:getText(), function( result ) 
        if result then
        	UserData.MobilePhone = self._MobileEditBox:getText()
            GameUtils.removeNode(self)
        end
    end)
end

function BindingMobileView:updateTimeText(__time)
	local timeNum = __time or 0
	if timeNum > 0 then
		self._TimeText:show()
    	self._btnSend:setEnabled(false)
   		self._TimeText:setString(timeNum.. "S")
		self._msgHandler = scheduler.scheduleGlobal(function()
			timeNum = timeNum - 1
			self._TimeText:setString(timeNum.. "S")
			if timeNum == 0 then
				self._TimeText:hide()
				self._btnSend:setEnabled(true)
				scheduler.unscheduleGlobal(self._msgHandler)
			end
		end, 1)
	end


end

function BindingMobileView:mobileEditBoxTextEventHandle(strEventName,pSender)
    if strEventName == "began" then  						--光标进入，清空内容/选择全部 
        self._MobileEditBox:setText("") 
        self._MobileEditBox:setPlaceHolder("")                    
    elseif strEventName == "ended" then  					--当编辑框失去焦点并且键盘消失的时候被调用
        											          
    elseif strEventName == "return" then 					 --当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用 

    elseif strEventName == "changed" then  
                                                    --输入内容改变时调用   
    end  
end


function BindingMobileView:codeEditBoxTextEventHandle(strEventName,pSender)
    if strEventName == "began" then  						--光标进入，清空内容/选择全部 
        self._CodeEditBox:setText("") 
        self._CodeEditBox:setPlaceHolder("")                    
    elseif strEventName == "ended" then  					--当编辑框失去焦点并且键盘消失的时候被调用
        											          
    elseif strEventName == "return" then 					 --当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用 
    	
    elseif strEventName == "changed" then  
                                                    --输入内容改变时调用   
    end  
end


function BindingMobileView:onEnter( ... )
	BindingMobileView.super.onEnter(self)
end

function BindingMobileView:onExit( ... )
	if self._msgHandler then 
		scheduler.unscheduleGlobal(self._msgHandler)
	end
end
return BindingMobileView

