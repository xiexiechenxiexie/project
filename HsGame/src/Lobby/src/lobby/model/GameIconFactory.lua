local GameIconFactory = {}

GameIconFactory.funcDict = nil

local LOBBY_ENTER_DIR =  ""
local STAR_DIR =  "" 
local BRNN_DIR =  ""
local HHDZ_DIR =  ""
local KPQZ_DIR =  ""
local PSZ_DIR = ""

GameIconFactory.imgRotate = LOBBY_ENTER_DIR .. "imgRotate.png"
GameIconFactory.imgScale = LOBBY_ENTER_DIR .. "imgScale.png"
GameIconFactory.imgBigStar = STAR_DIR .. "imgBigStar.png"
GameIconFactory.imgSmallStar = STAR_DIR ..  "imgSmallStar.png"

function GameIconFactory:createIconBtn( __gameId ,__callback)
	assert(__gameId and __callback,"invalid __gameId or __callback")
	self:_init()
	dump(self.funcDict)
	local func = self.funcDict[__gameId]
	return func(__gameId ,__callback)
end



function GameIconFactory:_init( ... )
	if self.funcDict == nil  then
		self.funcDict = {
			[cc.exports.lobby.LobbyGameEnterManager.BRNN] =  handler(self,self._createBRNNIconBtn),
			[cc.exports.lobby.LobbyGameEnterManager.KPQZ] =  handler(self,self._createKPQZIconBtn),
			[cc.exports.lobby.LobbyGameEnterManager.PSZ]  =  handler(self,self._createPSZIconBtn),
			[cc.exports.lobby.LobbyGameEnterManager.HHDZ] =  handler(self,self._createHHDZIconBtn)
		}
	end
end

function GameIconFactory:_createButton(__normalIcon,__pressedIcon,__disableIcon,__textureResType,__gameId,__callback )
	assert(__normalIcon and __textureResType and __gameId and __callback,"invalid paramas")
	__pressedIcon = __pressedIcon or __normalIcon
	__disableIcon = __disableIcon or __normalIcon
	local button = ccui.Button:create(__normalIcon,__pressedIcon,__disableIcon,__textureResType)
	button:setPressedActionEnabled(true)

	button:addClickEventListener(__callback)
	button:setTag(__gameId)
	return button
end

function GameIconFactory:addStarEffect(__targetNode,__imgStarFile,__posArr)
	assert(__targetNode and __imgStarFile and __posArr,"invalid pos")
	for __,point in pairs(__posArr) do
		assert(point.x and point.y ,"invalid point")
		local imgStar = ccui.ImageView:create(__imgStarFile,ccui.TextureResType.plistType)
		imgStar:setPosition(point.x,point.y)
		__targetNode:addChild(imgStar)
		local actInTime = 1
		local actOutTime = 0.5
		local actScale = 1.5
		local actHideScale = 0.2
		imgStar:setOpacity(0)
		local actDelay = cc.DelayTime:create(math.random(1,100) * 0.035)
		local actIn = cc.Spawn:create(cc.FadeIn:create(actInTime),cc.ScaleTo:create(actScale,actInTime))
		local actOut = cc.Spawn:create(cc.FadeOut:create(actOutTime),cc.ScaleTo:create(actHideScale,actOutTime))
		local seq = cc.Sequence:create(actDelay,actIn,actOut)
		local action = cc.RepeatForever:create(seq)
    	imgStar:runAction(action)
    	imgStar:runAction(cc.RepeatForever:create(cc.RotateBy:create(3,360)))
	end
end

function GameIconFactory:_addLightEffect( __targetNode )
	assert(__targetNode,"invalid __targetNode")
	local imgLight = ccui.ImageView:create(self.imgRotate,ccui.TextureResType.plistType)
	__targetNode:addChild(imgLight)
	local size = __targetNode:getContentSize()
	imgLight:setPosition(size.width * 0.5,size.height * 0.5)
    local action = cc.RepeatForever:create(cc.RotateBy:create(3, 360))
    imgLight:runAction(action)

    local imgScale = ccui.ImageView:create(self.imgScale,ccui.TextureResType.plistType)
	__targetNode:addChild(imgScale)
	local size = __targetNode:getContentSize()
	imgScale:setPosition(size.width * 0.5,size.height * 0.5)
	local actionTo = cc.ScaleTo:create(1.0, 0.3)
	imgScale:setOpacity(0)

    local action = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(1),cc.DelayTime:create(math.random(1,20) * 0.1)),actionTo,cc.CallFunc:create(function (sender )
    	sender:setOpacity(0)
    	sender:setScale(1)

    end)))
    imgScale:runAction(action)
end

function GameIconFactory:_addHuangDongEffect( __targetNode,__time,__rotation )
	assert(__targetNode and __time and __rotation,"invalid params")
    local actionTo = cc.RotateTo:create( __time, __rotation)
    local actionTo2 = cc.RotateTo:create( __time, -__rotation)
    local delayTime = cc.DelayTime:create( math.random(1,50) * 0.0)
    local action = cc.RepeatForever:create(cc.Sequence:create(actionTo, actionTo2,delayTime))
    __targetNode:runAction(action)
    __targetNode:setAnchorPoint(0.5,0)
    __targetNode:setPosition(__targetNode:getPositionX(),__targetNode:getPositionY() - __targetNode:getContentSize().height * 0.5)
end

function GameIconFactory:addUpDownEffect( __targetNode,__time,__height )
	assert(__targetNode and __time and __height,"invalid params")
	local random = math.random(1,10)
	print("__height >> " .. __height)
	local delay = math.random(0.2,1)
    local act1 = cc.MoveBy:create(__time ,cc.p(0, __height))
    local act2 = cc.MoveBy:create(__time ,cc.p(0, -__height))
    local action = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(delay),act1, act2))
    __targetNode:runAction(action)
    __targetNode:setAnchorPoint(0.5,0)
    __targetNode:setPosition(__targetNode:getPositionX(),__targetNode:getPositionY() - __targetNode:getContentSize().height * 0.5)
end


function GameIconFactory:_addLeftRightEffect( __targetNode,__time,__width )
	assert(__targetNode and __time and __width,"invalid params")
	local random = math.random(1,10)
	print("height >> " .. __width)
    local act1 = cc.MoveBy:create(__time ,cc.p(__width ,0))
    local act2 = cc.MoveBy:create(__time ,cc.p(-__width, 0))
    local delayTime = cc.DelayTime:create( 0)
    local action = cc.RepeatForever:create(cc.Sequence:create(act1, act2,delayTime))
    __targetNode:runAction(action)
    __targetNode:setAnchorPoint(0.5,0)
    __targetNode:setPosition(__targetNode:getPositionX(),__targetNode:getPositionY() - __targetNode:getContentSize().height * 0.5)
end

function GameIconFactory:_createBRNNIconBtn( __gameId ,__callback )
	local parentDir = BRNN_DIR

	local btnBRNN = parentDir .. "btnBRNN.png"
	local imgBRNNBody = parentDir .. "imgBRNNBody.png"
	local imgBRNNHead = parentDir .. "imgBRNNHead.png"
	local imgBRNNLight = parentDir .. "imgBRNNLight.png"
	local imgBRNNPork  = parentDir .. "imgBRNNPork.png"
	local imgBRNNText = parentDir .. "imgBRNNText.png"

	local button = ccui.Button:create(btnBRNN,btnBRNN,btnBRNN,ccui.TextureResType.plistType)
	button:setPressedActionEnabled(true)

	button:addClickEventListener(__callback)
	button:setTag(__gameId)

	local size = button:getContentSize()
	print("size.width " .. size.width)

	self:_addLightEffect(button)

	local pork = ccui.ImageView:create(imgBRNNPork,ccui.TextureResType.plistType)
	button:addChild(pork)

	pork:setPosition(size.width *  0.38,size.height *  0.47)
    self:_addHuangDongEffect(pork,2,3)

	local head = ccui.ImageView:create(imgBRNNHead,ccui.TextureResType.plistType)
	button:addChild(head)
	head:setPosition(size.width * 0.57,size.height * 0.655 )
	self:addStarEffect(head,self.imgBigStar,{{x = 110,y = 60},{x = 130,y = 40}})
	self:addStarEffect(head,self.imgBigStar,{{x = 25,y = 110}})
    self:_addHuangDongEffect(head,1,3)

	local imgBRNNBody = ccui.ImageView:create(imgBRNNBody,ccui.TextureResType.plistType)
	button:addChild(imgBRNNBody)
	imgBRNNBody:setPosition(size.width * 0.6,size.height * 0.364)

	local imgBRNNText = ccui.ImageView:create(imgBRNNText,ccui.TextureResType.plistType)
	button:addChild(imgBRNNText)
	imgBRNNText:setPosition(size.width * 0.5,size.height * 0.15)

	return button

end

function GameIconFactory:_createKPQZIconBtn( __gameId ,__callback )
	local parentDir = KPQZ_DIR

	local btnKPQZ = parentDir .. "btnKPQZ.png"
	local imgKPQZBody = parentDir .. "imgKPQZBody.png"
	local imgKPQZHead = parentDir .. "imgKPQZHead.png"
	local imgKPQZLight = parentDir .. "imgKPQZLight.png"
	local imgKPQZ  = parentDir .. "imgKPQZ.png"
	local imgKPQZText = parentDir .. "imgKPQZText.png"


	local button = ccui.Button:create(btnKPQZ,btnKPQZ,btnKPQZ,ccui.TextureResType.plistType)
	button:setPressedActionEnabled(true)

	button:addClickEventListener(__callback)
	button:setTag(__gameId)

	self:_addLightEffect(button)

	local size = button:getContentSize()
	print("size.width " .. size.width)

	local head = ccui.ImageView:create(imgKPQZHead,ccui.TextureResType.plistType)
	button:addChild(head)
	head:setPosition(size.width * 0.43,size.height * 0.655)
	self:_addHuangDongEffect(head,1,2)
	self:addStarEffect(head,self.imgBigStar,{{x = 150,y = 71}})
	self:addStarEffect(head,self.imgBigStar,{{x = 20,y = 106}})

	local imgKPQZ = ccui.ImageView:create(imgKPQZ,ccui.TextureResType.plistType)
	button:addChild(imgKPQZ)
	imgKPQZ:setPosition(head:getPositionX() - head:getContentSize().width *  0.26,head:getPositionY() + head:getContentSize().height *  0.32)
	self:_addHuangDongEffect(imgKPQZ,1,5)

	local imgKPQZBody = ccui.ImageView:create(imgKPQZBody,ccui.TextureResType.plistType)
	button:addChild(imgKPQZBody)
	imgKPQZBody:setPosition(size.width * 0.49,size.height * 0.364)

	local imgKPQZText = ccui.ImageView:create(imgKPQZText,ccui.TextureResType.plistType)
	button:addChild(imgKPQZText)
	imgKPQZText:setPosition(size.width * 0.5,size.height * 0.15)

	return button
end

function GameIconFactory:_createPSZIconBtn( __gameId ,__callback )
	local parentDir = PSZ_DIR

	local btnPSZ = parentDir .. "btnPSZ.png"
	local imgPSZHongChouMa = parentDir .. "imgPSZHongChouMa.png"
	local imgPSZHuangChouMa = parentDir .. "imgPSZHuangChouMa.png"
	local imgPSZLvChouMa = parentDir .. "imgPSZLvChouMa.png"
	local imgPSZPork  = parentDir .. "imgPSZPork.png"
	local imgPSZLight  = parentDir .. "imgPSZLight.png"
	local imgPSZText = parentDir .. "imgPSZText.png"


	local button = ccui.Button:create(btnPSZ,btnPSZ,btnPSZ,ccui.TextureResType.plistType)
	button:setPressedActionEnabled(true)

	button:addClickEventListener(__callback)
	button:setTag(__gameId)

	self:_addLightEffect(button)

	local size = button:getContentSize()
	print("size.width " .. size.width)

	local imgPSZPork = ccui.ImageView:create(imgPSZPork,ccui.TextureResType.plistType)
	button:addChild(imgPSZPork)
	imgPSZPork:setPosition(size.width * 0.6,size.height * 0.61)
	self:_addHuangDongEffect(imgPSZPork,1,3)
	self:addStarEffect(imgPSZPork,self.imgBigStar,{{x = 155,y = 35}})

	local chouMaNode = cc.Node:create()
	chouMaNode:setContentSize(size)
	chouMaNode:setPosition(0,0)
	button:addChild(chouMaNode)

	local chouMaIcons = {
		[1] = {iconName = imgPSZHuangChouMa,pos = {x = size.width * 0.53,y = size.height * 0.33},starPos = {x = 79,y = 39}},
		[2] = {iconName = imgPSZLvChouMa,pos = {x = size.width * 0.34,y = size.height * 0.4},starPos = {x = 79,y = 39}},
		[3] = {iconName = imgPSZHongChouMa,pos = {x = size.width * 0.25,y = size.height * 0.46},starPos = {x = 50,y = 45}}
	} 
	for i=1,#chouMaIcons do
		local chouMaIcon = chouMaIcons[i]
		print("---" .. chouMaIcon.iconName .. "...")
		local imgIcon = ccui.ImageView:create(chouMaIcon.iconName,ccui.TextureResType.plistType)
		chouMaNode:addChild(imgIcon)
		imgIcon:setPosition(chouMaIcon.pos.x,chouMaIcon.pos.y)
		if math.mod(i,2) == 0  then 
			self:addUpDownEffect(imgIcon,2,-3)
		else
			self:addUpDownEffect(imgIcon,2,3)
		end

		if i == 3 then
			self:addStarEffect(imgIcon,self.imgBigStar,{chouMaIcon.starPos})
		end
	end

	local imgPSZText = ccui.ImageView:create(imgPSZText,ccui.TextureResType.plistType)
	button:addChild(imgPSZText)
	imgPSZText:setPosition(size.width * 0.5,size.height * 0.15)

	return button
end

function GameIconFactory:_createHHDZIconBtn( __gameId ,__callback )
	local parentDir = HHDZ_DIR

	local btnHHDZ = parentDir .. "btnHHDZ.png"
	local imgHHDZBlack = parentDir .. "imgHHDZBlack.png"
	local imgHHDZRed = parentDir .. "imgHHDZRed.png"
	local imgHHDZText = parentDir .. "imgHHDZText.png"
	local imgHHDZLight = parentDir .. "imgHHDZLight.png"

	local button = ccui.Button:create(btnHHDZ,btnHHDZ,btnHHDZ,ccui.TextureResType.plistType)
	button:setPressedActionEnabled(true)

	button:addClickEventListener(__callback)
	button:setTag(__gameId)

	self:_addLightEffect(button)

	local size = button:getContentSize()
	print("size.width " .. size.width)

	local imgHHDZRed = ccui.ImageView:create(imgHHDZRed,ccui.TextureResType.plistType)
	button:addChild(imgHHDZRed)
	imgHHDZRed:setPosition(size.width * 0.65,size.height * 0.45)
	self:_addLeftRightEffect(imgHHDZRed,1,-5)
	self:addStarEffect(imgHHDZRed,self.imgBigStar,{{x = 93,y=107}})

	local imgHHDZBlack = ccui.ImageView:create(imgHHDZBlack,ccui.TextureResType.plistType)
	button:addChild(imgHHDZBlack)
	imgHHDZBlack:setPosition(size.width * 0.35,size.height * 0.53)
	self:_addLeftRightEffect(imgHHDZBlack,1,5)
	self:addStarEffect(imgHHDZBlack,self.imgBigStar,{{x = 96,y=106}})

	local imgHHDZText = ccui.ImageView:create(imgHHDZText,ccui.TextureResType.plistType)
	button:addChild(imgHHDZText)
	imgHHDZText:setPosition(size.width * 0.5,size.height * 0.15)

	return button
end

return GameIconFactory