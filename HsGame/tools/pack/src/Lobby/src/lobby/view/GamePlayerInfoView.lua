-- 游戏玩家信息界面  游戏资料卡
-- @date 2017.08.14
-- @author tangwen

local GamePlayerInfoView = class("GamePlayerInfoView", lib.layer.Window)

local GameRequest = require "request/GameRequest"
local MAX_FACE_NUM = 10 --最大表情数

-- 这里初始化所有滑动界面信息，如有特殊的单独处理
local FACE_SCROLLVIEW_SIZE = cc.size(554, 140)  -- 滑动界面大小
local FACE_VIEW_POSITION = cc.p(0, 0)		-- 滑动界面初始化位置
local RECORD_SIZE = cc.size(127, 123)   			--滑动界面节点大小 记录节点大小 
local FACE_INTERVAL_H = 137   --每条记录之间的间距 


function GamePlayerInfoView:ctor(__userID)
    self._userID = __userID
    GamePlayerInfoView.super.ctor(self,ConstantsData.WindowType.WINDOW_MIDDLE)
	self:initView()

    if self._userID ~= UserData.userId then
        self:initFaceList()
    end
	self._gameRequest = GameRequest:new() 
end

function GamePlayerInfoView:initView()
    local bg = self._root
    self._bg = bg

	local bgSize = bg:getContentSize()

	local MidLineImg = ccui.ImageView:create("PlayInfo_line_mid.png",ccui.TextureResType.plistType)
	MidLineImg:setPosition(bgSize.width/2 - 120, bgSize.height/2)
	bg:addChild(MidLineImg)

	local LeftLineImg = ccui.ImageView:create("PlayInfo_line_right.png",ccui.TextureResType.plistType)
	LeftLineImg:setPosition(bgSize.width/2 + 50, bgSize.height/2 + 40)
	bg:addChild(LeftLineImg)
    self.LeftLineImg = LeftLineImg

	local RightLineImg = ccui.ImageView:create("PlayInfo_line_left.png",ccui.TextureResType.plistType)
	RightLineImg:setPosition(bgSize.width/2 + 350, bgSize.height/2  + 40)
	bg:addChild(RightLineImg)
    self.RightLineImg = RightLineImg

	local GameNameText = cc.Label:createWithTTF("看牌抢庄",GameUtils.getFontName(),30)
    GameNameText:setAnchorPoint(cc.p(0.5, 0.5))
    GameNameText:setPosition(bgSize.width/2 + 200, bgSize.height/2 + 40)
    bg:addChild(GameNameText)
    self.GameNameText = GameNameText

    local WinText = cc.Label:createWithTTF("胜:",GameUtils.getFontName(),28)
    WinText:setColor(cc.c3b(224,221,245))
    WinText:setAnchorPoint(cc.p(0.5, 0.5))
    WinText:setPosition(bgSize.width/2, bgSize.height/2 - 20)
    bg:addChild(WinText)
    self.WinText = WinText

    self._WinNumText = cc.Label:createWithTTF("",GameUtils.getFontName(),28)
    self._WinNumText:setAnchorPoint(cc.p(0, 0.5))
    self._WinNumText:setColor(cc.c3b(255,210,0))
    self._WinNumText:setPosition(bgSize.width/2 + 25 , bgSize.height/2 - 20)
    bg:addChild(self._WinNumText)
    self._WinNumText:hide()

    local LoseText = cc.Label:createWithTTF("负:",GameUtils.getFontName(),28)
    LoseText:setColor(cc.c3b(224,221,245))
    LoseText:setAnchorPoint(cc.p(0.5, 0.5))
    LoseText:setPosition(bgSize.width/2 + 170, bgSize.height/2 - 20)
    bg:addChild(LoseText)
    self.LoseText = LoseText

    self._LoseNumText = cc.Label:createWithTTF("",GameUtils.getFontName(),28)
    self._LoseNumText:setAnchorPoint(cc.p(0, 0.5))
    self._LoseNumText:setColor(cc.c3b(194,84,28))
    self._LoseNumText:setPosition(bgSize.width/2 + 195, bgSize.height/2 - 20)
    bg:addChild(self._LoseNumText)
    self._LoseNumText:hide()


    local WinRateText = cc.Label:createWithTTF("胜率:",GameUtils.getFontName(),28)
    WinRateText:setColor(cc.c3b(224,221,245))
    WinRateText:setAnchorPoint(cc.p(0.5, 0.5))
    WinRateText:setPosition(bgSize.width/2 + 330, bgSize.height/2 - 20)
    bg:addChild(WinRateText)
    self.WinRateText = WinRateText

    self._WinRateNumText = cc.Label:createWithTTF("",GameUtils.getFontName(),28)
    self._WinRateNumText:setAnchorPoint(cc.p(0, 0.5))
    self._WinRateNumText:setColor(cc.c3b(255,210,0))
    self._WinRateNumText:setPosition(bgSize.width/2 + 370, bgSize.height/2 - 20)
    bg:addChild(self._WinRateNumText)
    self._WinRateNumText:hide()

    local NickNameText = cc.Label:createWithTTF("昵称:",GameUtils.getFontName(),28)
    NickNameText:setAnchorPoint(cc.p(0.5, 0.5))
    NickNameText:setColor(cc.c3b(224,221,245))
    NickNameText:setPosition(bgSize.width/2 - 10, bgSize.height - 95)
    bg:addChild(NickNameText)

    self._NickName = cc.Label:createWithTTF("",GameUtils.getFontName(),28)
    self._NickName:setAnchorPoint(cc.p(0, 0.5))
    self._NickName:setColor(cc.c3b(224,221,245))
    self._NickName:setPosition(bgSize.width/2+ 30, bgSize.height - 95)
    bg:addChild(self._NickName)
    self._NickName:hide()

    local SexText = cc.Label:createWithTTF("性别:",GameUtils.getFontName(),28)
    SexText:setAnchorPoint(cc.p(0.5, 0.5))
    SexText:setColor(cc.c3b(224,221,245))
    SexText:setPosition(bgSize.width/2 -10, bgSize.height - 175)
    bg:addChild(SexText)

    self._SexLabel = cc.Label:createWithTTF("男",GameUtils.getFontName(),28)
    self._SexLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self._SexLabel:setColor(cc.c3b(224,221,245))
    self._SexLabel:setPosition(bgSize.width/2 + 95, bgSize.height - 175)
    bg:addChild(self._SexLabel)
    self._SexLabel:hide()

    self._SexImg = ccui.ImageView:create("PlayInfo_img_man.png",ccui.TextureResType.plistType)
	self._SexImg:setPosition(bgSize.width/2 + 50, bgSize.height - 175)
	bg:addChild(self._SexImg)
	self._SexImg:hide()

	local IdText = cc.Label:createWithTTF("ID:",GameUtils.getFontName(),28)
    IdText:setAnchorPoint(cc.p(0.5, 0.5))
    IdText:setColor(cc.c3b(224,221,245))
    IdText:setPosition(65, bgSize.height/2 - 45)
    bg:addChild(IdText)
    self.IdText = IdText

    self._IDLabel = cc.Label:createWithTTF("",GameUtils.getFontName(),28)
    self._IDLabel:setAnchorPoint(cc.p(0, 0.5))
    self._IDLabel:setColor(cc.c3b(224,221,245))
    self._IDLabel:setPosition(90, bgSize.height/2 - 45)
    bg:addChild(self._IDLabel)

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

	local coinsImg = ccui.ImageView:create("PlayInfo_icon_coisn.png",ccui.TextureResType.plistType)
	coinsImg:setPosition(90, bgSize.height/2 - 120)
	bg:addChild(coinsImg)
    self.coinsImg = coinsImg

    self._CoinsLabel = GameUtils.createSwitchNumNode(0)
    self._CoinsLabel:setAnchorPoint(cc.p(0, 0.5))
    self._CoinsLabel:setPosition(130, bgSize.height/2 - 120)
    bg:addChild(self._CoinsLabel)
    self._CoinsLabel:hide()


    self._btnAddFriend = cc.exports.lib.uidisplay.createLabelButton({
            textureType = ccui.TextureResType.plistType,
            normal = "common_big_green_btn.png",
            callback = function() 
                self:requestAddFriend(self._userID)
            end,
            isActionEnabled = true,
            pos = cc.p(185, 65),
            text = "加为好友",
            outlineColor = cc.c4b(24,73,30,255),
            outlineSize = 2,
            labPos = cc.p(0,2),
    })
    bg:addChild(self._btnAddFriend,3)
    self._btnAddFriend:hide()

    self._btnRemoveFriend = cc.exports.lib.uidisplay.createLabelButton({
            textureType = ccui.TextureResType.plistType,
            normal = "common_big_red_btn.png",
            callback = function() 
                self:requestDeleteFriend(self._userID)
            end,
            isActionEnabled = true,
            pos = cc.p(185, 65),
            text = "删除好友",
            outlineColor = cc.c4b(113,26,-6,255),
            outlineSize = 2,
            labPos = cc.p(0,2),
    })
    bg:addChild(self._btnRemoveFriend,3)
    self._btnRemoveFriend:hide()

    self.InfoData=nil
end

function GamePlayerInfoView:requestAddFriend(__userID)
    logic.FriendManager:getInstance():requestAddFriendData(__userID, function( result )
        if result then
            GameUtils.showMsg("请等待对方同意！")
            self._btnAddFriend:hide()
        end
    end)
end

function GamePlayerInfoView:requestDeleteFriend(__userID)
    logic.FriendManager:getInstance():requestDeleteFriendData(__userID, function( result )
        if result then
            self._btnRemoveFriend:hide()
        end
    end)
end

-- 初始化表情列表
function GamePlayerInfoView:initFaceList()
	local bgSize = self._bg:getContentSize()
	local faceListbgImg = ccui.ImageView:create("PlayInfo_img_faceList_bg.png",ccui.TextureResType.plistType)
	faceListbgImg:setPosition(bgSize.width/2 + 180, 115)
	self._bg:addChild(faceListbgImg)

	local listBgSize = faceListbgImg:getContentSize()
	local aboutText = cc.Label:createWithTTF("每次使用消耗200金币",GameUtils.getFontName(),18)
    aboutText:setAnchorPoint(cc.p(0.5, 0.5))
    aboutText:setColor(cc.c3b(150,161,219))
    aboutText:setPosition(listBgSize.width/2,listBgSize.height - 30)
    faceListbgImg:addChild(aboutText)

    local ScrollView = self:createScrollView(MAX_FACE_NUM)
	ScrollView:setPosition(5,0)
	faceListbgImg:addChild(ScrollView,1)

	local contentSize = cc.size(RECORD_SIZE.width + (MAX_FACE_NUM - 1) * FACE_INTERVAL_H + 20, RECORD_SIZE.height )
    if contentSize.width < FACE_SCROLLVIEW_SIZE.width then
        contentSize = FACE_SCROLLVIEW_SIZE
    end
    local offset = cc.p(0, contentSize.height)
    local PosX = 0

    for i=1,MAX_FACE_NUM do
    	local record= self:createFaceNode(i)
        local x = (i - 1) * FACE_INTERVAL_H + FACE_INTERVAL_H/2 + 2
        local y =-50 + offset.y
        record:setPosition(x,y)
        ScrollView:addChild(record)
    end
end

-- 创建scrollView界面
function GamePlayerInfoView:createScrollView(rowNum)
	local contentSize = cc.size(RECORD_SIZE.width+ (rowNum - 1) * FACE_INTERVAL_H + 20, RECORD_SIZE.height)
	print(contentSize.width)

	local _MailScrollView = ccui.ScrollView:create()
    _MailScrollView:setTouchEnabled(true)--触摸的属性
    _MailScrollView:setBounceEnabled(true)--弹回的属性
    _MailScrollView:setInertiaScrollEnabled(true)--滑动的惯性
    _MailScrollView:setScrollBarEnabled(false)
    _MailScrollView:setDirection(ccui.ScrollViewDir.horizontal)
    _MailScrollView:setContentSize(FACE_SCROLLVIEW_SIZE)
    _MailScrollView:setInnerContainerSize(contentSize)
    _MailScrollView:setPosition(FACE_VIEW_POSITION)

    return _MailScrollView
end


function GamePlayerInfoView:createFaceNode(index)
	local size = cc.size(127, 123)
	
	local face = ccui.Layout:create()

   	local bg =  ccui.ImageView:create("PlayInfo_img_face_bg.png", ccui.TextureResType.plistType)
    bg:setContentSize(size)
    bg:setPosition(cc.p(0,0))
    face:addChild(bg)


    local faceBtnImg = string.format("PlayInfo_btn_face_%d.png",index)
	local faceBtn = ccui.Button:create(faceBtnImg,faceBtnImg,faceBtnImg,ccui.TextureResType.plistType)
	faceBtn:setPosition(0,0)
	face:addChild(faceBtn)
	faceBtn:addClickEventListener(function()
		self._gameRequest:RequestProp(self._userID, index)
        self:onCloseCallback()
	end)

	return face

end

function GamePlayerInfoView:setInfoData(data)
    self.InfoData = data
end

function GamePlayerInfoView:requestGamePlayerInfoData()
    logic.PlayerInfoManager:getInstance():requestPlayerInfoData(self._userID,function( result )
        if result then
            self:showGamePlayerInfoView(result)     
        end
    end)
end


--百人场系统庄家信息面板
function GamePlayerInfoView:setSystemZhuangInfo()
    self.IdText:hide()
    self._IDLabel:hide()
    self.coinsImg:hide()
    self._CoinsLabel:hide()
    self._btnAddFriend:hide()
    self._btnRemoveFriend:hide()
    self.LeftLineImg:hide()
    self.RightLineImg:hide()
    self.GameNameText:hide()
    self.WinText:hide()
    self._WinNumText:hide()
    self.LoseText:hide()
    self._LoseNumText:hide()
    self.WinRateText:hide()
    self._WinRateNumText:hide()
    self.btnCopy:hide()
end

function GamePlayerInfoView:showGamePlayerInfoView(data)
    if data.UserId == nil and self.InfoData == nil then
        return
    end

    local Gender = data.Gender or 0
    local GenderStr = GameUtils.getInfoBigHeadFileByGender(Gender)

    local AvatarUrl = data.AvatarUrl or ""
    local awatar = lib.node.Avatar:create({
     avatarUrl = AvatarUrl,
     stencilFile = "res/Avatar/head_rect_round_stencil_225_225.png",
     defalutFile = GenderStr,
     frameFile = nil,
        })
    awatar:setPosition(80,270)
    self._bg:addChild(awatar)

    self._IDLabel:setString(data.UserId or "")
    self._IDLabel:show()

    local Gender = data.Gender or 0
    self:showSexSelect(Gender)

    self._NickName:setString(data.NickName or "")
    self._NickName:show()

    GameUtils.updateSwitchNumNode(self._CoinsLabel,data.Score or 0)
    self._CoinsLabel:show()

    local winNum = data.winroundsum or 0
    self._WinNumText:setString(winNum)
    self._WinNumText:show()

    local loseNum = data.losesum or 0
    self._LoseNumText:setString(loseNum)
    self._LoseNumText:show()

    local winRateNum = data.winning or 0
    self._WinRateNumText:setString(winRateNum*100 .. "%")
    self._WinRateNumText:show()

    local friendInfo = UserData.findFriendByIndex(data.UserId)
    if friendInfo ~= nil then
        self._btnAddFriend:hide()
        self._btnRemoveFriend:show()
    else
        self._btnAddFriend:show()
        self._btnRemoveFriend:hide()
    end

    if friendInfo == 1 then
        self._btnAddFriend:hide()
        self._btnRemoveFriend:hide()
    end

    if data.UserId == 0 then
        self:setSystemZhuangInfo()
    end
end

-- 显示选择的性别
function GamePlayerInfoView:showSexSelect(index)
    if index == ConstantsData.SexType.SEX_MAN then 
        self._SexLabel:setString("男")
        self._SexLabel:show()
        self._SexImg:loadTexture("PlayInfo_img_man.png", UI_TEX_TYPE_PLIST)
        self._SexImg:show()
    elseif index == ConstantsData.SexType.SEX_WOMEN then
        self._SexLabel:setString("女")
        self._SexLabel:show()
        self._SexImg:loadTexture("PlayInfo_img_women.png", UI_TEX_TYPE_PLIST)
        self._SexImg:show()
    elseif index == ConstantsData.SexType.SEX_UNKNOW then
        self._SexLabel:setString("未知")
        self._SexLabel:show()
        --self._SexImg:loadTexture("PlayInfo_img_man.png", UI_TEX_TYPE_PLIST)
        self._SexImg:hide()
    else
        print("选择性别索引号错误 index:",index)
    end
end


function GamePlayerInfoView:onEnter()
    GamePlayerInfoView.super.onEnter(self)
    if self.InfoData  == nil then
        self:requestGamePlayerInfoData()
    else
        self:showGamePlayerInfoView(self.InfoData)
    end
end

function GamePlayerInfoView:onExit()
	
end

return GamePlayerInfoView