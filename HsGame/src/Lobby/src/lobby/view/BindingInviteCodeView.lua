-- 绑定邀请码
-- @date 2017.09.01
-- @author tangwen

local BindingInviteCodeView = class("BindingInviteCodeView", lib.layer.Window)

function BindingInviteCodeView:ctor(__data)
	BindingInviteCodeView.super.ctor(self,ConstantsData.WindowType.WINDOW_MIDDLE)
    self._promoteData = __data
	self:initView()
end

function BindingInviteCodeView:initView()
    local bg = self._root
    self._bg = bg

    local bgSize = self._bg:getContentSize()
    local title = ccui.ImageView:create("Lobby_Promote_view_title_code.png", ccui.TextureResType.plistType)
    title:setPosition(bgSize.width/2, bgSize.height - 25)
    self._bg:addChild(title)

    local InviteCodeText = cc.Label:createWithTTF("邀请码:",GameUtils.getFontName(),40)
    InviteCodeText:setAnchorPoint(cc.p(0.5, 0.5))
    InviteCodeText:setColor(cc.c3b(255,255,255))
    InviteCodeText:setPosition(215, bgSize.height/2 + 25)
    bg:addChild(InviteCodeText)

    self._CodeEditBox = cc.EditBox:create(cc.size(435,71),"Lobby_Promote_view_editBox_bg.png", ccui.TextureResType.plistType)
    self._CodeEditBox:setPosition(bgSize.width/2 + 35, bgSize.height/2 + 25)
    self._CodeEditBox:setFontName(GameUtils.getFontName())
    self._CodeEditBox:setFontSize(44)
    self._CodeEditBox:setFontColor(cc.c3b(255,255,255))
    self._CodeEditBox:setMaxLength(8)
    self._CodeEditBox:setPlaceholderFontColor(cc.c3b(255,255,255))
    self._CodeEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self._CodeEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    self._CodeEditBox:registerScriptEditBoxHandler(function(strEventName,pSender)self:inviteCodeEditBoxTextEventHandle(strEventName,pSender)end)
    self._bg:addChild(self._CodeEditBox)

    local okImg = "common_btn_sure.png"
    local btnOk = lib.uidisplay.createUIButton({
        normal = okImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            self:requestBindingInviteCode()
        end
        })

    btnOk:setPosition(bgSize.width/2, 96)
    bg:addChild(btnOk,2)
end

function BindingInviteCodeView:requestBindingInviteCode()
    logic.PromoteManager:getInstance():requestBindingInviteCodeData(self._CodeEditBox:getText(), function( result ) 
        if result then
            local event = cc.EventCustom:new(config.EventConfig.EVENT_REFRESH_USER_INFO)
            lib.EventUtils.dispatch(event)

            local __params = {}
            for i=1,#self._promoteData.reward do
                local reward = {type = self._promoteData.reward[i].type, score = self._promoteData.reward[i].number }
                table.insert(__params,reward)
            end
            GameUtils.showGiftAccount(__params)
            GameUtils.removeNode(self) 
        end
    end)
end

function BindingInviteCodeView:inviteCodeEditBoxTextEventHandle(strEventName,pSender)
    if strEventName == "began" then                         --光标进入，清空内容/选择全部 
        self._CodeEditBox:setText("") 
        self._CodeEditBox:setPlaceHolder("")                    
    elseif strEventName == "ended" then                     --当编辑框失去焦点并且键盘消失的时候被调用
                                                              
    elseif strEventName == "return" then                     --当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用 

    elseif strEventName == "changed" then  
                                                    --输入内容改变时调用   
    end  
end

function BindingInviteCodeView:onEnter( ... )
	BindingInviteCodeView.super.onEnter(self)
end

function BindingInviteCodeView:onExit( ... )
	-- body
end

return BindingInviteCodeView

