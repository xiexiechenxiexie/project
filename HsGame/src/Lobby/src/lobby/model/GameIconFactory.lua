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
-- GameIconFactory.imgBigStar = STAR_DIR .. "imgBigStar.png"
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
	-- assert(__targetNode,"invalid __targetNode")
	-- local imgLight = ccui.ImageView:create(self.imgRotate,ccui.TextureResType.plistType)
	-- -- __targetNode:addChild(imgLight)
	-- local size = __targetNode:getContentSize()
	-- imgLight:setPosition(size.width * 0.5,size.height * 0.5)
 --    local action = cc.RepeatForever:create(cc.RotateBy:create(3, 360))
 --    imgLight:runAction(action)

 --    local imgScale = ccui.ImageView:create(self.imgScale,ccui.TextureResType.plistType)
	-- __targetNode:addChild(imgScale)
	-- local size = __targetNode:getContentSize()
	-- imgScale:setPosition(size.width * 0.5,size.height * 0.5)
	-- local actionTo = cc.ScaleTo:create(1.0, 0.3)
	-- imgScale:setOpacity(0)

 --    local action = cc.RepeatForever:create(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(1),cc.DelayTime:create(math.random(1,20) * 0.1)),actionTo,cc.CallFunc:create(function (sender )
 --    	sender:setOpacity(0)
 --    	sender:setScale(1)

 --    end)))
 --    imgScale:runAction(action)
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
	local parentDir = KPQZ_DIR
	local btnKPQZ = parentDir .. "btnbig_bg.png"
	local button = ccui.Button:create(btnKPQZ,btnKPQZ,btnKPQZ,ccui.TextureResType.plistType)
	button:setPressedActionEnabled(true)
	button:addClickEventListener(__callback)
	button:setTag(__gameId)

	local dir = "GameLayout/Animation/brnn_Animation/"
	local node = ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."brnn_Animation0.png",dir.."brnn_Animation0.plist",dir.."brnn_Animation.ExportJson")  
    local adAnim = ccs.Armature:create("brnn_Animation") 
    adAnim:setPosition(button:getContentSize().width/2,button:getContentSize().height/2) 
    button:addChild(adAnim);
    adAnim:getAnimation():playWithIndex(0)
    adAnim:getAnimation():setSpeedScale(0.5)

	return button

end

function GameIconFactory:_createKPQZIconBtn( __gameId ,__callback )
	local parentDir = KPQZ_DIR
	local btnKPQZ = parentDir .. "btnbig_bg.png"
	local button = ccui.Button:create(btnKPQZ,btnKPQZ,btnKPQZ,ccui.TextureResType.plistType)
	button:setPressedActionEnabled(true)
	button:addClickEventListener(__callback)
	button:setTag(__gameId)

	local dir = "GameLayout/Animation/qznn_Animation/"
	local node = ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."qznn_Animation0.png",dir.."qznn_Animation0.plist",dir.."qznn_Animation.ExportJson")  
    local adAnim = ccs.Armature:create("qznn_Animation") 
    adAnim:setPosition(button:getContentSize().width/2,button:getContentSize().height/2) 
    button:addChild(adAnim);
    adAnim:getAnimation():playWithIndex(0)
    adAnim:getAnimation():setSpeedScale(0.5)


	return button
end

function GameIconFactory:_createPSZIconBtn( __gameId ,__callback)
	local parentDir = PSZ_DIR
	local btnPSZ = parentDir .. "btnbig_bg.png"
	local button = ccui.Button:create(btnPSZ,btnPSZ,btnPSZ,ccui.TextureResType.plistType)
	button:setPressedActionEnabled(true)
	button:addClickEventListener(__callback)
	button:setTag(__gameId)

	local dir = "GameLayout/Animation/zjh_Animation/"
	local node = ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."zjh_Animation0.png",dir.."zjh_Animation0.plist",dir.."zjh_Animation.ExportJson")  
    local adAnim = ccs.Armature:create("zjh_Animation") 
    adAnim:setPosition(button:getContentSize().width/2,button:getContentSize().height/2) 
    button:addChild(adAnim);
    adAnim:getAnimation():playWithIndex(0)
    adAnim:getAnimation():setSpeedScale(0.5)

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