-- 个人信息界面 资料卡
-- @date 2017.08.14
-- @author tangwen

local PersonalInfoView = class("PersonalInfoView", lib.layer.Window)

local AVATAR_TAG = 200

function PersonalInfoView:ctor()
    PersonalInfoView.super.ctor(self,ConstantsData.WindowType.WINDOW_MIDDLE)
	self:initView()
end

function PersonalInfoView:initView()
    local bg = self._root
    self._bg = bg

	local bgSize = bg:getContentSize()

	local MidLineImg = ccui.ImageView:create("PlayInfo_line_mid.png",ccui.TextureResType.plistType)
	MidLineImg:setPosition(bgSize.width/2 - 100, bgSize.height/2)
	bg:addChild(MidLineImg)

	local LeftLineImg = ccui.ImageView:create("PlayInfo_line_right.png",ccui.TextureResType.plistType)
	LeftLineImg:setPosition(bgSize.width/2 + 50, bgSize.height/2 - 100)
	bg:addChild(LeftLineImg)

	local RightLineImg = ccui.ImageView:create("PlayInfo_line_left.png",ccui.TextureResType.plistType)
	RightLineImg:setPosition(bgSize.width/2 + 350, bgSize.height/2  - 100)
	bg:addChild(RightLineImg)

	local GameNameText = cc.Label:createWithTTF("看牌抢庄",GameUtils.getFontName(),30)
    GameNameText:setAnchorPoint(cc.p(0.5, 0.5))
    GameNameText:setPosition(bgSize.width/2 + 200, bgSize.height/2 - 100)
    bg:addChild(GameNameText)

    local WinText = cc.Label:createWithTTF("胜:",GameUtils.getFontName(),28)
    WinText:setColor(cc.c3b(224,221,245))
    WinText:setAnchorPoint(cc.p(0.5, 0.5))
    WinText:setPosition(bgSize.width/2, bgSize.height/2 - 160)
    bg:addChild(WinText)

    self._WinNumText = cc.Label:createWithTTF("",GameUtils.getFontName(),28)
    self._WinNumText:setAnchorPoint(cc.p(0, 0.5))
    self._WinNumText:setColor(cc.c3b(255,210,0))
    self._WinNumText:setPosition(bgSize.width/2 + 25 , bgSize.height/2 - 160)
    bg:addChild(self._WinNumText)
    self._WinNumText:hide()

    local LoseText = cc.Label:createWithTTF("负:",GameUtils.getFontName(),28)
    LoseText:setColor(cc.c3b(224,221,245))
    LoseText:setAnchorPoint(cc.p(0.5, 0.5))
    LoseText:setPosition(bgSize.width/2 + 170, bgSize.height/2 - 160)
    bg:addChild(LoseText)

    self._LoseNumText = cc.Label:createWithTTF("",GameUtils.getFontName(),28)
    self._LoseNumText:setAnchorPoint(cc.p(0, 0.5))
    self._LoseNumText:setColor(cc.c3b(194,84,28))
    self._LoseNumText:setPosition(bgSize.width/2 + 195, bgSize.height/2 - 160)
    bg:addChild(self._LoseNumText)
    self._LoseNumText:hide()

    local writeImg = "PlayInfo_btn_write.png"
    local btnWrite  = ccui.Button:create(writeImg, writeImg, writeImg, ccui.TextureResType.plistType)
	btnWrite:addClickEventListener(function()
		self:showCompileName()
	end)
	btnWrite:setPosition(bgSize.width/2 + 220, bgSize.height - 115)
	bg:addChild(btnWrite)

	local SelectSexImg = "PlayInfo_btn_sex_select.png"
    local btnSelectMan  = ccui.Button:create(SelectSexImg, SelectSexImg, SelectSexImg, ccui.TextureResType.plistType)
	btnSelectMan:addClickEventListener(function()
        local __param = { token = UserData.token, NickName = UserData.nickName, Gender= ConstantsData.SexType.SEX_MAN}
        logic.PlayerInfoManager:getInstance():requestReviseSelfInfo(__param, function( result )
            if result then
                UserData.gender = ConstantsData.SexType.SEX_MAN
                self:showSexSelect(ConstantsData.SexType.SEX_MAN)
                self:updataAvatar()
            end
        end)	
	end)
	btnSelectMan:setPosition(bgSize.width/2 + 120, bgSize.height - 195)
	bg:addChild(btnSelectMan)

    local btnSelectWomen  = ccui.Button:create(SelectSexImg, SelectSexImg, SelectSexImg, ccui.TextureResType.plistType)
	btnSelectWomen:addClickEventListener(function()
        local __param = { token = UserData.token, NickName = UserData.nickName, Gender= ConstantsData.SexType.SEX_WOMEN}
        logic.PlayerInfoManager:getInstance():requestReviseSelfInfo(__param, function( result )
            if result then
                UserData.gender = ConstantsData.SexType.SEX_WOMEN
                self:showSexSelect(ConstantsData.SexType.SEX_WOMEN)
                self:updataAvatar()
            end
        end)
	end)
	btnSelectWomen:setPosition(bgSize.width/2 + 275, bgSize.height - 195)
	bg:addChild(btnSelectWomen)

    local btnSelectUnknown  = ccui.Button:create(SelectSexImg, SelectSexImg, SelectSexImg, ccui.TextureResType.plistType)
	btnSelectUnknown:addClickEventListener(function()
        local __param = { token = UserData.token, NickName = UserData.nickName, Gender= ConstantsData.SexType.SEX_UNKNOW}
        logic.PlayerInfoManager:getInstance():requestReviseSelfInfo(__param, function( result )
            if result then
                UserData.gender = ConstantsData.SexType.SEX_UNKNOW
                self:showSexSelect(ConstantsData.SexType.SEX_UNKNOW)
                self:updataAvatar()
            end
        end)
	end)
	btnSelectUnknown:setPosition(bgSize.width/2 + 420, bgSize.height - 195)
	bg:addChild(btnSelectUnknown)

	self._selectManImg = ccui.ImageView:create("PlayInfo_img_select.png",ccui.TextureResType.plistType)
	self._selectManImg:setPosition(bgSize.width/2 + 120, bgSize.height - 195)
	bg:addChild(self._selectManImg)
	self._selectManImg:hide()

	self._selectWomenImg = ccui.ImageView:create("PlayInfo_img_select.png",ccui.TextureResType.plistType)
	self._selectWomenImg:setPosition(bgSize.width/2 + 275, bgSize.height - 195)
	bg:addChild(self._selectWomenImg)
	self._selectWomenImg:hide()

	self._selectUnknowImg = ccui.ImageView:create("PlayInfo_img_select.png",ccui.TextureResType.plistType)
	self._selectUnknowImg:setPosition(bgSize.width/2 + 420, bgSize.height - 195)
	bg:addChild(self._selectUnknowImg)
	self._selectUnknowImg:hide()

    local WinRateText = cc.Label:createWithTTF("胜率:",GameUtils.getFontName(),28)
    WinRateText:setColor(cc.c3b(224,221,245))
    WinRateText:setAnchorPoint(cc.p(0.5, 0.5))
    WinRateText:setPosition(bgSize.width/2 + 330, bgSize.height/2 - 160)
    bg:addChild(WinRateText)

    self._WinRateNumText = cc.Label:createWithTTF("",GameUtils.getFontName(),28)
    self._WinRateNumText:setAnchorPoint(cc.p(0, 0.5))
    self._WinRateNumText:setColor(cc.c3b(255,210,0))
    self._WinRateNumText:setPosition(bgSize.width/2 + 370, bgSize.height/2 - 160)
    bg:addChild(self._WinRateNumText)
    self._WinRateNumText:hide()

    local NickNameText = cc.Label:createWithTTF("昵称:",GameUtils.getFontName(),28)
    NickNameText:setAnchorPoint(cc.p(0.5, 0.5))
    NickNameText:setColor(cc.c3b(224,221,245))
    NickNameText:setPosition(bgSize.width/2 - 30, bgSize.height - 115)
    bg:addChild(NickNameText)

    self._NickName = cc.Label:createWithTTF("",GameUtils.getFontName(),28)
    self._NickName:setAnchorPoint(cc.p(0, 0.5))
    self._NickName:setColor(cc.c3b(224,221,245))
    self._NickName:setPosition(bgSize.width/2+ 10, bgSize.height - 115)
    bg:addChild(self._NickName)
    self._NickName:hide()

    local SexText = cc.Label:createWithTTF("性别:",GameUtils.getFontName(),28)
    SexText:setAnchorPoint(cc.p(0.5, 0.5))
    SexText:setColor(cc.c3b(224,221,245))
    SexText:setPosition(bgSize.width/2 -30, bgSize.height - 195)
    bg:addChild(SexText)

    local manSexLabel = cc.Label:createWithTTF("男",GameUtils.getFontName(),28)
    manSexLabel:setAnchorPoint(cc.p(0.5, 0.5))
    manSexLabel:setColor(cc.c3b(224,221,245))
    manSexLabel:setPosition(bgSize.width/2 + 70, bgSize.height - 195)
    bg:addChild(manSexLabel)

    local womenSexLabel = cc.Label:createWithTTF("女",GameUtils.getFontName(),28)
    womenSexLabel:setAnchorPoint(cc.p(0.5, 0.5))
    womenSexLabel:setColor(cc.c3b(224,221,245))
    womenSexLabel:setPosition(bgSize.width/2 + 225, bgSize.height - 195)
    bg:addChild(womenSexLabel)

    local unknowSexLabel = cc.Label:createWithTTF("保密",GameUtils.getFontName(),28)
    unknowSexLabel:setAnchorPoint(cc.p(0.5, 0.5))
    unknowSexLabel:setColor(cc.c3b(224,221,245))
    unknowSexLabel:setPosition(bgSize.width/2 + 360, bgSize.height - 195)
    bg:addChild(unknowSexLabel)

    local manSexImg = ccui.ImageView:create("PlayInfo_img_man.png",ccui.TextureResType.plistType)
	manSexImg:setPosition(bgSize.width/2 + 30, bgSize.height - 195)
	bg:addChild(manSexImg)

	local womenSexImg = ccui.ImageView:create("PlayInfo_img_women.png",ccui.TextureResType.plistType)
	womenSexImg:setPosition(bgSize.width/2 + 190, bgSize.height - 195)
	bg:addChild(womenSexImg)

	local IdText = cc.Label:createWithTTF("ID:",GameUtils.getFontName(),28)
    IdText:setAnchorPoint(cc.p(0.5, 0.5))
    IdText:setColor(cc.c3b(224,221,245))
    IdText:setPosition(65, bgSize.height/2 - 45)
    bg:addChild(IdText)

    self._IDLabel = cc.Label:createWithTTF("",GameUtils.getFontName(),28)
    self._IDLabel:setAnchorPoint(cc.p(0, 0.5))
    self._IDLabel:setColor(cc.c3b(224,221,245))
    self._IDLabel:setPosition(90, bgSize.height/2 - 45)
    bg:addChild(self._IDLabel)
    self._IDLabel:hide()

    local btnCopy = cc.exports.lib.uidisplay.createLabelButton({
            textureType = ccui.TextureResType.plistType,
            normal = "common_small_blue_btn.png",
            callback = function() 
                MultiPlatform:getInstance():copyToClipboard(self._IDLabel:getString())
            end,
            isActionEnabled = true,
            pos = cc.p(280, bgSize.height/2 - 45),
            text = "复 制",
            outlineColor = cc.c4b(24,31,92,255),
            outlineSize = 2,
            labPos = cc.p(0,2),
            scale = 0.5,
    })
    bg:addChild(btnCopy,3)
    self.btnCopy = btnCopy

	local diamondImg = ccui.ImageView:create("PlayInfo_icon_diamond.png",ccui.TextureResType.plistType)
	diamondImg:setPosition(120, bgSize.height/2 - 105)
	bg:addChild(diamondImg)

    self._DiamondLabel = GameUtils.createSwitchNumNode(0)
    self._DiamondLabel:setAnchorPoint(cc.p(0, 0.5))
    self._DiamondLabel:setPosition(160, bgSize.height/2 - 105)
    bg:addChild(self._DiamondLabel)
    self._DiamondLabel:hide()

	local coinsImg = ccui.ImageView:create("PlayInfo_icon_coisn.png",ccui.TextureResType.plistType)
	coinsImg:setPosition(120, bgSize.height/2 - 170)
	bg:addChild(coinsImg)

    self._CoinsLabel = GameUtils.createSwitchNumNode(0)
    self._CoinsLabel:setAnchorPoint(cc.p(0, 0.5))
    self._CoinsLabel:setPosition(160, bgSize.height/2 - 170)
    bg:addChild(self._CoinsLabel)
    self._CoinsLabel:hide()

    local roomCardImg = ccui.ImageView:create("PlayInfo_icon_roomcard.png",ccui.TextureResType.plistType)
	roomCardImg:setPosition(120, bgSize.height/2 - 235)
	bg:addChild(roomCardImg)

    self._RoomCardLabel = GameUtils.createSwitchNumNode(0)
    self._RoomCardLabel:setAnchorPoint(cc.p(0, 0.5))
    self._RoomCardLabel:setPosition(160, bgSize.height/2 - 235)
    bg:addChild(self._RoomCardLabel)
    self._RoomCardLabel:hide()

    local editBoxSize = cc.size(178,44)
    self._EditBox = cc.EditBox:create(editBoxSize,"Lobby_Promote_view_editBox_bg.png", ccui.TextureResType.plistType)
    self._EditBox:setPosition(bgSize.width/2 + 100, bgSize.height - 115)
    self._EditBox:setFontName(GameUtils.getFontName())
    self._EditBox:setFontSize(24)
    self._EditBox:setFontColor(cc.c3b(255,255,255))
    self._EditBox:setMaxLength(6)
    self._EditBox:setPlaceHolder("请输入姓名:")
    self._EditBox:setPlaceholderFontColor(cc.c3b(255,255,255))
    self._EditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self._EditBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self._EditBox:registerScriptEditBoxHandler(function(strEventName,pSender)self:editBoxTextEventHandle(strEventName,pSender)end)
    self._bg:addChild(self._EditBox)
    self._EditBox:hide()

end

-- 显示选择的性别
function PersonalInfoView:showSexSelect(index)
	if index == ConstantsData.SexType.SEX_MAN then 
		self._selectManImg:show()
		self._selectWomenImg:hide()
		self._selectUnknowImg:hide()
	elseif index == ConstantsData.SexType.SEX_WOMEN then
		self._selectManImg:hide()
		self._selectWomenImg:show()
		self._selectUnknowImg:hide()
	elseif index == ConstantsData.SexType.SEX_UNKNOW then
		self._selectManImg:hide()
		self._selectWomenImg:hide()
		self._selectUnknowImg:show()
	else
		print("选择性别索引号错误 index:",index)
	end

    local event = cc.EventCustom:new(config.EventConfig.EVENT_REFRESH_USER_AVATAR)
    lib.EventUtils.dispatch(event)
end

-- 显示编辑名字
function PersonalInfoView:showCompileName()
    self._NickName:hide()
    self._EditBox:show()
end

function PersonalInfoView:editBoxTextEventHandle(strEventName,pSender)
    if strEventName == "began" then  
        self._EditBox:setText("") 
        self._EditBox:setPlaceHolder("")                   --光标进入，清空内容/选择全部  
    elseif strEventName == "ended" then  
        --self._EditBox:setPlaceHolder("请输入姓名:")        --当编辑框失去焦点并且键盘消失的时候被调用  
    elseif strEventName == "return" then 
        self._NickName:show()
        self._EditBox:setPlaceHolder("请输入姓名:")
        self._EditBox:hide() 
        self:updateNickName()                                            --当用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用  
    elseif strEventName == "changed" then  
                                                    --输入内容改变时调用   
    end  
end

function PersonalInfoView:updateNickName()
    local checkStr = self._EditBox:getText()
    if #checkStr == 0 then
        return
    end

    local __param = { token = UserData.token, NickName = self._EditBox:getText(), Gender= UserData.gender}
    logic.PlayerInfoManager:getInstance():requestReviseSelfInfo(__param, function( result )
        if result then
            UserData.nickName = self._EditBox:getText()
            self._NickName:setString(UserData.nickName)
            local event = cc.EventCustom:new(config.EventConfig.EVENT_REFRESH_USER_NICKNAME)
            lib.EventUtils.dispatch(event)
        end
    end)
end

function PersonalInfoView:requestPersonalInfoData()
    logic.PlayerInfoManager:getInstance():requestPersonalInfoData(function( result )
        if result then
            self:showPersonalView(result)
        end
    end)
end

function PersonalInfoView:showPersonalView(data)
    if data == nil then
        return
    end

    local Gender = data.Gender or 0
    local GenderStr = GameUtils.getInfoBigHeadFileByGender(Gender)

    local AvatarUrl = UserData.avatarUrl or ""
    local awatar = lib.node.Avatar:create({
     avatarUrl = AvatarUrl,
     stencilFile = "res/Avatar/head_rect_round_stencil_225_225.png",
     defalutFile = GenderStr,
     frameFile = nil,
        })
    awatar:setPosition(80,270)
    awatar:setTag(AVATAR_TAG)
    self._bg:addChild(awatar)

    self._IDLabel:setString(data.UserId or "")
    self._IDLabel:show()

    local Gender = data.Gender or 0
    self:showSexSelect(Gender)

    data.NickName = GameUtils.FormotGameNickName(data.NickName,6)
    self._NickName:setString(data.NickName)
    self._NickName:show()

    GameUtils.updateSwitchNumNode(self._CoinsLabel,data.Score or 0)
    self._CoinsLabel:show()

    GameUtils.updateSwitchNumNode(self._RoomCardLabel,data.RoomCardNum or 0)
    self._RoomCardLabel:show()

    GameUtils.updateSwitchNumNode(self._DiamondLabel,data.diamond or 0)
    self._DiamondLabel:show()

    local winNum = data.winroundsum or 0
    self._WinNumText:setString(winNum)
    self._WinNumText:show()

    local loseNum = data.losesum or 0
    self._LoseNumText:setString(loseNum)
    self._LoseNumText:show()

    local winRateNum = data.winning or 0
    self._WinRateNumText:setString(winRateNum*100 .. "%")
    self._WinRateNumText:show()

    
end

function PersonalInfoView:updataAvatar( ... )
    if  UserData.avatarUrl ~= nil and UserData.avatarUrl ~= "" then
        return
    end

    self._bg:removeChildByTag(AVATAR_TAG, true)

    local Gender = UserData.gender or 0
    local GenderStr = GameUtils.getInfoBigHeadFileByGender(Gender)

    local AvatarUrl = UserData.avatarUrl or ""
    local awatar = lib.node.Avatar:create({
     avatarUrl = AvatarUrl,
     stencilFile = "res/Avatar/head_rect_round_stencil_225_225.png",
     defalutFile = GenderStr,
     frameFile = nil,
        })
    awatar:setPosition(80,270)
    awatar:setTag(AVATAR_TAG)
    self._bg:addChild(awatar)
end

function PersonalInfoView:onEnter()
	PersonalInfoView.super.onEnter(self)
	self:requestPersonalInfoData()
end



return PersonalInfoView