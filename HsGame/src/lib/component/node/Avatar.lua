--[[--
@author fly
]]

local Avatar = {}

--[[--
用模板裁剪頭像
	local awatar = lib.node.Avatar:create({
	 avatarUrl = "http://192.168.1.213:8086/6.png",
	 stencilFile = "res/Avatar/chessDetail/LCDAwatarstencil.png",
	 defalutFile = "Lobby/res/Avatar/default_100_100.png",
	 frameFile = "res/Avatar/chessDetail/LCDAwatarFrame.png",
		})
	awatar:setPosition(100,100)
	self:addChild(awatar)
]]
function Avatar:create( __param )
	assert(__param,"invalid param")
	local avatarUrl = __param.avatarUrl  --头像url
	local stencilFile = __param.stencilFile  --裁剪模板文件
	local defalutFile = __param.defalutFile --默认文件
	local frameFile = __param.frameFile --头像边框文件
	local floorFile = __param.floorFile --地板文件
	local node = cc.Node:create()
	local sprite = nil
	-- if avatarUrl and type(avatarUrl) == "string" and avatarUrl ~= "" then
	-- 	sprite = lib.node.RemoteSprite:create(defalutFile)
	-- 	sprite:setDownloadParams({dir = "awatar",url = avatarUrl})
	-- else
	-- 	sprite = cc.Sprite:create(defalutFile)
	-- end

	-- 添加了头像资源路径的获取 config.ServerConfig:findResDomain() add by tangwen
	if avatarUrl and type(avatarUrl) == "string" and avatarUrl ~= "" then
		sprite = lib.node.RemoteImageView:create(defalutFile)
		-- sprite:setDownloadParams({dir = "awatar",url = config.ServerConfig:findResDomain() .. avatarUrl,userId= userId})
		sprite:setDownloadParams({dir = "awatar",url = avatarUrl,userId= userId})
	else
		sprite = ccui.ImageView:create(defalutFile)
	end


	local size = sprite:getContentSize()
	node:setContentSize(size)
	local pos = cc.p(size.width * 0.5,size.height * 0.5)

	--地板
	if floorFile then
    	local floorSprite = cc.Sprite:create(floorFile)
    	floorSprite:setPosition(pos)
    	node:addChild(floorSprite)
    end

    local stencilNode = display.newNode()
	local stencilSprite = cc.Sprite:create(stencilFile)
	
	local clip = cc.ClippingNode:create()
	clip:addChild(sprite)
    clip:setStencil(stencilNode)
    stencilNode:addChild(stencilSprite)
    clip:setAlphaThreshold(0.5)
    clip:setInverted(false)
    clip:setPosition(pos)
    node:addChild(clip)

    if frameFile then
    	local frameSprite = cc.Sprite:create(frameFile)
    	if frameSprite then 
	    	frameSprite:setPosition(pos)
	    	node:addChild(frameSprite)
    	end
    end

    return node
end

cc.exports.lib.node.Avatar = Avatar