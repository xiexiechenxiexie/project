-- 设置
--20170816
--chenzihao
local MusicManager=cc.exports.manager.MusicManager
local Tag_Music_Off=1
local Tag_Music_On=2
local Tag_Effect_Off=3
local Tag_Effect_On=4


local SetView = class("SetView", lib.layer.Window)

--tytle --0表示大厅 ，1表示子游戏
function SetView:ctor(tytle)
	SetView.super.ctor(self,ConstantsData.WindowType.WINDOW_MIDDLE)
	self:enableNodeEvents()
	self:preloadUI()
	self:initData()
	if tytle==0 then
		self:initHallSet()
	elseif tytle==1 then
		self:initGameSet()
	end
end

function SetView:preloadUI()
	display.loadSpriteFrames("res/GameLayout/Set/Set.plist",
							"res/GameLayout/Set/Set.png")
end

function SetView:initData( ... )
	local hotUpdateManager = lib.download.HotUpdateManager
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	self._VersionCode = config.channle.VERSION   
end

function SetView:initHallSet()
    local bg = self._root
    self._bg = bg

    local bgSize = bg:getContentSize()

    local title = ccui.ImageView:create("set_title.png", ccui.TextureResType.plistType)
    title:setPosition(bgSize.width/2, bgSize.height - 50)
    bg:addChild(title)

    -- local line = ccui.ImageView:create("line.png", ccui.TextureResType.plistType)
    -- line:setPosition(bgSize.width/2-120, bgSize.height/2-30)
    -- bg:addChild(line)

    local yinyueSp = cc.Label:createWithTTF("音乐:",GameUtils.getFontName(),30)
    yinyueSp:setPosition(bgSize.width/2+80-30, bgSize.height/2+80)
    bg:addChild(yinyueSp)

    local OffBtnImg="off.png"
    local OnBtnImg="on.png"

    self.MusicBtn={}
    local MusicOffBtn = ccui.Button:create(OffBtnImg,OffBtnImg,OffBtnImg,ccui.TextureResType.plistType)
	MusicOffBtn:setPosition(bgSize.width/2+250-30, bgSize.height/2+80)
	MusicOffBtn:setTag(Tag_Music_On)
	bg:addChild(MusicOffBtn)
	MusicOffBtn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	local MusicOnBtn = ccui.Button:create(OnBtnImg,OnBtnImg,OnBtnImg,ccui.TextureResType.plistType)
	MusicOnBtn:setPosition(bgSize.width/2+250-30, bgSize.height/2+80)
	MusicOnBtn:setTag(Tag_Music_Off)
	bg:addChild(MusicOnBtn)
	MusicOnBtn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	if MusicManager:getMusicVolume()>0 then
		MusicOffBtn:setVisible(false)
		MusicOnBtn:setVisible(true)
	else
		MusicOffBtn:setVisible(true)
		MusicOnBtn:setVisible(false)
	end
	table.insert(self.MusicBtn,MusicOffBtn)
	table.insert(self.MusicBtn,MusicOnBtn)

    local yinxiaoSp = cc.Label:createWithTTF("音效:",GameUtils.getFontName(),30)
    yinxiaoSp:setPosition(bgSize.width/2+80-30, bgSize.height/2-80)
    bg:addChild(yinxiaoSp)

    self.EffectBtn={}
    local EffectOffBtn = ccui.Button:create(OffBtnImg,OffBtnImg,OffBtnImg,ccui.TextureResType.plistType)
	EffectOffBtn:setPosition(bgSize.width/2+250-30, bgSize.height/2-80)
	EffectOffBtn:setTag(Tag_Effect_On)
	bg:addChild(EffectOffBtn)
	EffectOffBtn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	local EffectOnBtn = ccui.Button:create(OnBtnImg,OnBtnImg,OnBtnImg,ccui.TextureResType.plistType)
	EffectOnBtn:setPosition(bgSize.width/2+250-30, bgSize.height/2-80)
	EffectOnBtn:setTag(Tag_Effect_Off)
	bg:addChild(EffectOnBtn)
	EffectOnBtn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	if MusicManager:getSoundsVolume()>0 then
		EffectOffBtn:setVisible(false)
		EffectOnBtn:setVisible(true)
	else
		EffectOffBtn:setVisible(true)
		EffectOnBtn:setVisible(false)
	end
	table.insert(self.EffectBtn,EffectOffBtn)
	table.insert(self.EffectBtn,EffectOnBtn)


    local Headbg=ccui.ImageView:create("headBg.png", ccui.TextureResType.plistType)
    Headbg:setPosition(bgSize.width/2-300+5, bgSize.height/2+100-30-5)
    bg:addChild(Headbg)
    Headbg:setScale(0.9)

    local Gender = UserData.gender or 0
    local GenderStr = GameUtils.getDefalutHeadFileByGender(Gender)

	local AvatarUrl = UserData.avatarUrl
    local awatar = lib.node.Avatar:create({
     avatarUrl = AvatarUrl,
     stencilFile = "res/Avatar/head_rect_round_stencil_94_94.png",
     defalutFile = GenderStr,
     frameFile = nil,
        })

    awatar:setScale((Headbg:getContentSize().width)/(awatar:getContentSize().width))
	Headbg:addChild(awatar)

    local IDLabel = cc.Label:createWithTTF("ID："..tostring(UserData.userId),GameUtils.getFontName(),24)
    IDLabel:setAnchorPoint(cc.p(0,0.5))
    IDLabel:setPosition(bgSize.width/2-380, bgSize.height/2-50-30)
    IDLabel:setColor(cc.c3b(224,221,245))
    bg:addChild(IDLabel)

    local ChangeBtnImg = "changeBtn.png"
    local ChangeBtn = ccui.Button:create(ChangeBtnImg,ChangeBtnImg,ChangeBtnImg,ccui.TextureResType.plistType)
	ChangeBtn:setPosition(bgSize.width/2-300, bgSize.height/2-120-30)
	bg:addChild(ChangeBtn)
	ChangeBtn:addClickEventListener(function()
		print("切换账号")
	  	net.SocketClient:getInstance():closeSocket(ConstantsData.CloseScoketType.NOMAL_CLOSE,function()
  			LoginManager:enterLogin(false)
	    end)
	end)

	local VersionLabel = cc.Label:createWithTTF("版本号：".. self._VersionCode,GameUtils.getFontName(),24)
    VersionLabel:setPosition(bgSize.width/2-300, bgSize.height/2-230)
    VersionLabel:setColor(cc.c3b(236, 224, 184))
    -- VersionLabel:setColor(cc.c3b(224,221,245))
    bg:addChild(VersionLabel)

end

function SetView:initGameSet()
    local bg = self._root
    self._bg = bg

    local bgSize = bg:getContentSize()

    local setBg = ccui.ImageView:create("game_set_bg.png", ccui.TextureResType.plistType)
    setBg:setPosition(bgSize.width/2, bgSize.height/2)
    bg:addChild(setBg)

    local title = ccui.ImageView:create("set_title.png", ccui.TextureResType.plistType)
    title:setPosition(bgSize.width/2, bgSize.height - 50)
    bg:addChild(title)

    local yinyueSp = cc.Label:createWithTTF("音效:",GameUtils.getFontName(),30)
    yinyueSp:setPosition(bgSize.width/2-100, bgSize.height/2+80)
    bg:addChild(yinyueSp)

    local OffBtnImg="off.png"
    local OnBtnImg="on.png"

    self.MusicBtn={}
    local MusicOffBtn = ccui.Button:create(OffBtnImg,OffBtnImg,OffBtnImg,ccui.TextureResType.plistType)
	MusicOffBtn:setPosition(bgSize.width/2+100, bgSize.height/2+80)
	MusicOffBtn:setTag(Tag_Music_On)
	bg:addChild(MusicOffBtn)
	MusicOffBtn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	local MusicOnBtn = ccui.Button:create(OnBtnImg,OnBtnImg,OnBtnImg,ccui.TextureResType.plistType)
	MusicOnBtn:setPosition(bgSize.width/2+100, bgSize.height/2+80)
	MusicOnBtn:setTag(Tag_Music_Off)
	bg:addChild(MusicOnBtn)
	MusicOnBtn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	if MusicManager:getMusicVolume()>0 then
		MusicOffBtn:setVisible(false)
		MusicOnBtn:setVisible(true)
	else
		MusicOffBtn:setVisible(true)
		MusicOnBtn:setVisible(false)
	end
	table.insert(self.MusicBtn,MusicOffBtn)
	table.insert(self.MusicBtn,MusicOnBtn)

    local yinxiaoSp = cc.Label:createWithTTF("音效:",GameUtils.getFontName(),30)
    yinxiaoSp:setPosition(bgSize.width/2-100, bgSize.height/2-80)
    bg:addChild(yinxiaoSp)

    self.EffectBtn={}
    local EffectOffBtn = ccui.Button:create(OffBtnImg,OffBtnImg,OffBtnImg,ccui.TextureResType.plistType)
	EffectOffBtn:setPosition(bgSize.width/2+100, bgSize.height/2-80)
	EffectOffBtn:setTag(Tag_Effect_On)
	bg:addChild(EffectOffBtn)
	EffectOffBtn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	local EffectOnBtn = ccui.Button:create(OnBtnImg,OnBtnImg,OnBtnImg,ccui.TextureResType.plistType)
	EffectOnBtn:setPosition(bgSize.width/2+100, bgSize.height/2-80)
	EffectOnBtn:setTag(Tag_Effect_Off)
	bg:addChild(EffectOnBtn)
	EffectOnBtn:addClickEventListener(function(sender)self:onButtonClickedEvent(sender)end)

	if MusicManager:getSoundsVolume()>0 then
		EffectOffBtn:setVisible(false)
		EffectOnBtn:setVisible(true)
	else
		EffectOffBtn:setVisible(true)
		EffectOnBtn:setVisible(false)
	end
	table.insert(self.EffectBtn,EffectOffBtn)
	table.insert(self.EffectBtn,EffectOnBtn)
end

function SetView:onButtonClickedEvent(sender)
	local tag=sender:getTag()
	if tag==Tag_Music_Off then
		self.MusicBtn[1]:setVisible(true)
		self.MusicBtn[2]:setVisible(false)
		MusicManager:setMuscicVolume(0)
	elseif tag==Tag_Music_On then
		self.MusicBtn[1]:setVisible(false)
		self.MusicBtn[2]:setVisible(true)
		MusicManager:setMuscicVolume(100)
	elseif tag==Tag_Effect_Off then
		self.EffectBtn[1]:setVisible(true)
		self.EffectBtn[2]:setVisible(false)
		MusicManager:setSoundVolume(0)
	elseif tag==Tag_Effect_On then
		self.EffectBtn[1]:setVisible(false)
		self.EffectBtn[2]:setVisible(true)
		MusicManager:setSoundVolume(100)
	end
end

function SetView:onEnter( ... )
	SetView.super.onEnter(self)
end

function SetView:onExit( ... )
	display.removeSpriteFrames("res/GameLayout/Set/Set.plist",
							"res/GameLayout/Set/Set.png")
end

return SetView