-- 签到
-- @date 2017.08.05
-- @author tangwen

local SignView = class("SignView", lib.layer.Window)

local SIGN_MAX_RECORD = 8 	 -- 最大奖励

function SignView:ctor(data,callback)
	self._signData = data
	self._callback = callback
	SignView.super.ctor(self,ConstantsData.WindowType.WINDOW_SIGN)
	self:initView()
end

function SignView:initView()
    local bg = self._root
    self._bg = bg

    local bgSize = bg:getContentSize()

    local title = ccui.ImageView:create("Lobby_sign_title.png", ccui.TextureResType.plistType)
    title:setPosition(bgSize.width/2, bgSize.height-60)
	bg:addChild(title)

	local text = cc.Label:createWithTTF("累计登陆7天即可获得相应奖励",GameUtils.getFontName(),32)
	text:setColor(cc.c3b(237, 203, 128))
	text:setAnchorPoint(1,0.5)
    text:setPosition(bgSize.width-270, 70)
    bg:addChild(text)

    local signImg = "Lobby_sign_btn_sign.png"
    local signImg0 = "Lobby_sign_btn_sign0.png"
    self._btnSign = lib.uidisplay.createUIButton({
        normal = signImg,
        pressed = signImg,
        disable = signImg0,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            self:requestSignCheckIn()
        end
        })
	self._btnSign:setPosition(bgSize.width-150, 70)
	bg:addChild(self._btnSign,3)

	-- self._imgGotSign = ccui.ImageView:create("Lobby_sign_btn_got.png", ccui.TextureResType.plistType)
 --    self._imgGotSign:setPosition(bgSize.width/2, 50)
	-- bg:addChild(self._imgGotSign,4)
	-- self._imgGotSign:hide()

	self._SignList = {}

	for i=1,SIGN_MAX_RECORD do
		local record = self:createSignNode(i,self._signData.checkInSetting[i])
		if i <= 4 then
			record:setPosition(180 + (i-1)*188+230, bgSize.height/2 + 122)
		else
			record:setPosition(180 + (i-5)*188+230, bgSize.height/2 - 113)
		end
		table.insert(self._SignList,record)
		bg:addChild(record)
	end

	self:showCurSignView()

	-- local __AniNode =cc.CSLoader:createNode("GameLayout/Lobby/Sign/qiandao.csb")
 --    __AniNode:setPosition(bgSize.width/2, bgSize.height/2 + 25)
 --    bg:addChild(__AniNode)
 --    self._giftLiftBg = __AniNode:getChildByName("sanxinguang")

 --    local act = cc.CSLoader:createTimeline("GameLayout/Lobby/Sign/qiandao.csb")
 --    act:setTimeSpeed(1) --设置执行动画速度
 --    __AniNode:runAction(act)
 --    act:gotoFrameAndPlay(0,false)
 --    act:setLastFrameCallFunc(function()
 --        local sb1 = cc.ScaleTo:create(2/3,0.7)
 --        local sb2 = cc.ScaleTo:create(2/3,0.6)
 --        local ft1 = cc.FadeTo:create(2/3,255*0.7)
	-- 	local ft2 = cc.FadeTo:create(2/3,255*0.6)  
 --        local spawn1 = cc.Spawn:create({sb1,ft1})
 --        local spawn2 = cc.Spawn:create({sb2,ft2})
 --        local RepeaAction = cc.RepeatForever:create(transition.sequence({ spawn2, spawn1 }))
 --        self._giftLiftBg:runAction(RepeaAction)
 --    end)

end

function SignView:requestSignCheckIn()
	logic.LobbyManager:getInstance():requestSignCheckIn(function( data )
    	if data then
        	-- self._btnSign:hide()
        	-- self._imgGotSign:show()

        	self._btnSign:setBright(false)
        	self._btnSign:setTouchEnabled(false)

			local curSignNum = self._signData.checkedDays+1
			if curSignNum > 8 then
				curSignNum = 8
			end

			self._SignList[curSignNum].maskBg:show()
			-- self._SignList[curSignNum].imgGot:show()

			self._curSignAni:stopAllActions()
			self._curSignAni:hide()

			local d_type = 0
		    local d_num = 0
		    if data.bonusScore > 0 then
		    	d_type = ConstantsData.PointType.POINT_COINS
		    	d_num = data.bonusScore
		    elseif data.bonusDiamond > 0 then
		    	d_type = ConstantsData.PointType.POINT_COINS
		    	d_num = data.bonusDiamond
		    elseif data.bonusRoomCard > 0 then
		    	d_type = ConstantsData.PointType.POINT_COINS
		    	d_num = data.bonusRoomCard
		    end

			local __params = {{type = d_type, score = d_num}}
			GameUtils.showGiftAccount(__params)
			
			local event = cc.EventCustom:new(config.EventConfig.EVENT_REFRESH_USER_INFO)
			lib.EventUtils.dispatch(event)
    	end
	end)
end

function SignView:createSignNode(__index, __data)
	local size = cc.size(185, 230)
	local record = ccui.Layout:create()

   	local bg =  ccui.ImageView:create("Lobby_sign_recond_bg.png", ccui.TextureResType.plistType)
    bg:setContentSize(size)
    bg:setPosition(cc.p(0,0))
    record:addChild(bg)

    record.imgLightAni = ccui.ImageView:create("Lobby_sign_recond_now.png", ccui.TextureResType.plistType)
    record.imgLightAni:setPosition(size.width/2,size.height/2)
	bg:addChild(record.imgLightAni)
	record.imgLightAni:hide()

 --    local lightBg = ccui.ImageView:create("Lobby_sign_recond_title.png", ccui.TextureResType.plistType)
 --    lightBg:setPosition(size.width/2,size.height/2 -10)
 --    lightBg:setOpacity(200)
 --    lightBg:setScale(0.9)
	-- bg:addChild(lightBg)

	local __DayStr = ""
	if __index > 7 then
		__DayStr = "第七天+"
	else
		__DayStr = string.format("第%d天",__index)
	end

	local dayText = cc.Label:createWithTTF(__DayStr,GameUtils.getFontName(),24)
    dayText:setAnchorPoint(cc.p(0.5, 0.5))
    dayText:setPosition(size.width/2, size.height - 25)
    bg:addChild(dayText)

    local d_type = 0
    local d_num = 0
    if __data.bonusScore > 0 then
    	d_type = ConstantsData.PointType.POINT_COINS
    	d_num = __data.bonusScore
    elseif __data.bonusDiamond > 0 then
    	d_type = ConstantsData.PointType.POINT_COINS
    	d_num = __data.bonusDiamond
    elseif __data.bonusRoomCard > 0 then
    	d_type = ConstantsData.PointType.POINT_COINS
    	d_num = __data.bonusRoomCard
    end

 	local iconStr = ""
 	if d_type == ConstantsData.PointType.POINT_COINS then --金币
 		iconStr = string.format("Lobby_sign_recond_icon_%d.png",__index)
 	end

    local imgIcon = ccui.ImageView:create(iconStr, ccui.TextureResType.plistType)
    imgIcon:setPosition(size.width/2,size.height/2)
	bg:addChild(imgIcon)

	record.coinsText = cc.Label:createWithTTF(d_num,GameUtils.getFontName(),24)
    record.coinsText:setAnchorPoint(cc.p(0.5, 0.5))
    record.coinsText:setColor(cc.c3b(255,210,0))
    record.coinsText:setPosition(size.width/2, 25)
    bg:addChild(record.coinsText)

    record.maskBg = ccui.ImageView:create("Lobby_sign_recond_mask.png", ccui.TextureResType.plistType)
    record.maskBg:setPosition(size.width/2,size.height/2)
	bg:addChild(record.maskBg)
	record.maskBg:hide()

	-- record.imgGot = ccui.ImageView:create("Lobby_sign_img_got.png", ccui.TextureResType.plistType)
 --    record.imgGot:setPosition(size.width/2,size.height/2)
	-- bg:addChild(record.imgGot)
	-- record.imgGot:hide()

    return record
end

function SignView:showCurSignView()
	if self._SignList == nil then
		return
	end
	local curSignNum = self._signData.checkedDays+1
	if curSignNum > 8 then
		curSignNum = 8
	end

	if self._signData.checkedDays >8 then
		self._signData.checkedDays = 8
	end
	for i=1,self._signData.checkedDays do
		self._SignList[i].maskBg:show()
		-- self._SignList[i].imgGot:show()
	end

	if self._signData.canCheckIn then  -- 表示当天没有领取奖励
		self._curSignAni = self._SignList[curSignNum].imgLightAni
		self._curSignAni:show()
		local ft1 = cc.FadeTo:create(0.6,175)  
		local ft2 = cc.FadeTo:create(0.6,255) 	
		local seq = cc.Sequence:create(ft1,ft2)
		local RepeaAction = cc.RepeatForever:create(seq)
		self._curSignAni:runAction(RepeaAction)
	else
		-- self._btnSign:hide()
		-- self._imgGotSign:show()

		self._btnSign:setBright(false)
		self._btnSign:setTouchEnabled(false)
	end

end

function SignView:onEnter( ... )
	SignView.super.onEnter(self)
end

function SignView:onExit( ... )
	self:stopAllActions()

	if self._callback then
        self._callback()
    end

end

return SignView