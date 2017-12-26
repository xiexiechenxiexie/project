-- 新手奖励
-- @date 2017.08.21
-- @author tangwen

local NovicesRewardLayer = class("NovicesRewardLayer", cc.Layer)

function NovicesRewardLayer:ctor(data)
	self:enableNodeEvents() 
	self:initView()
	self:initGiftByData(data)
end

function NovicesRewardLayer:initView()
    local mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
    mask:setScale(5.0)
    mask:setLocalZOrder(-999)
    mask:setOpacity(0.0)
    self:addChild(mask)
    mask:setTouchEnabled(true)

    local listener = cc.EventListenerTouchOneByOne:create()

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchMove(touch, event)
    end

    local function onTouchEnd(touch, event)
    	
    end

    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)

    listener:setSwallowTouches(true)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,mask)

	local bg = display.newNode()
    bg:setPosition(display.cx,display.cy)
    self:addChild(bg)
    self._bg = bg

    local node =cc.CSLoader:createNode("GameLayout/Reward/xinshoujiangli.csb")
    bg:addChild(node)
    self._giftLiftBg = node:getChildByName("beijinguang2")

    local act = cc.CSLoader:createTimeline("GameLayout/Reward/xinshoujiangli.csb")
    act:setTimeSpeed(1) --设置执行动画速度
    node:runAction(act)
    act:gotoFrameAndPlay(0,false)
    act:setLastFrameCallFunc(function()
        local rb1 = cc.RotateBy:create(1, 60)
        local sb1 = cc.ScaleTo:create(1,0.9)
        local rb2 = cc.RotateBy:create(1, -60)
        local sb2 = cc.ScaleTo:create(1,1)
        local spawn1 = cc.Spawn:create({rb1,sb1})
        local spawn2 = cc.Spawn:create({rb2,sb2})
        local RepeaAction = cc.RepeatForever:create(transition.sequence({ spawn1, spawn2 }))
        self._giftLiftBg:runAction(RepeaAction)
    end)


end

-- 根据数值显示领取物品
function NovicesRewardLayer:initGiftByData(data)
	if data == nil then
        return
    end

	local bgSize = cc.size(1334,750)
	local good_posX = bgSize.width/2 + 170 - 200 * (#data / 2 - 0.5)
	local good_posY = bgSize.height/2

	for k,v in pairs(data) do
		local giftBg = ccui.ImageView:create("Reward_gift_bg.png", ccui.TextureResType.plistType)
    	giftBg:setPosition(good_posX,good_posY)
    	self:addChild(giftBg)
    	good_posX = good_posX + 200

    	local iconImg = ""
    	local iconText = ""
    	if v.type == ConstantsData.PointType.POINT_COINS then  -- 金币 
    		iconImg = "Lobby_sign_recond_icon_2.png"
    		iconText = v.number.."金币"
    	elseif v.type == ConstantsData.PointType.POINT_DIAMOND then --钻石
    		iconImg = "Reward_icon_diamond.png"
    		iconText = v.number.."钻石"
    	elseif v.type == ConstantsData.PointType.POINT_ROOMCARD then --房卡
    		iconImg = "Reward_icon_roomcard.png"
    		iconText = v.number.."房卡"
    	else
    		print("奖励物品格式错误:",v.type)
    	end
    	local giftIcon = ccui.ImageView:create(iconImg, ccui.TextureResType.plistType)
    	giftIcon:setPosition(73,69)
    	giftBg:addChild(giftIcon)

    	local giftText = cc.Label:createWithTTF(iconText,GameUtils.getFontName(),30)
    	giftText:setPosition(73, -30)
    	giftBg:addChild(giftText)
        self:UpRewardNodeAni(giftBg)
	end

    local startText = cc.Label:createWithTTF("恭喜获得新手奖励~让我陪你一起玩游戏吧~",GameUtils.getFontName(),32)
    startText:setPosition(display.cx + 170, 190)
    self:addChild(startText)
    self:UpRewardNodeAni(startText)

    local btnOk = cc.exports.lib.uidisplay.createLabelButton({
            textureType = ccui.TextureResType.plistType,
            normal = "common_big_yellow_btn.png",
            callback = function() 
                logic.NovicesRewardManager:getInstance():requestNovicesRewardReceive(function( result )
                    if result then
                        GameUtils.removeNode(self)
                        require("lobby/scene/LobbyScene"):create():runWithScene()
                    end
                end)
            end,
            isActionEnabled = true,
            pos = cc.p(display.cx + 170, 100),
            text = "进入游戏",
            outlineColor = cc.c4b(112,45,2,255),
            outlineSize = 2,
            labPos = cc.p(0,2),
    })

    btnOk:setPosition(display.cx + 170, 100)
    self:addChild(btnOk,3)
    self:UpRewardNodeAni(btnOk)

end

function NovicesRewardLayer:UpRewardNodeAni(__node,__callback)
    __node:setScale(0)
    __node:setOpacity(100)
    local time = 0.3
    -- 弹出动画
    local spawn = cc.Spawn:create({CCScaleTo:create(time, 1,1), CCFadeTo:create(time, 255)})
    local callFunc = CCCallFunc:create(function()
        if __callback then
            __callback()
        end
    end)
    local sequence = transition.sequence({ spawn, callFunc })
    __node:runAction(sequence)
end


function NovicesRewardLayer:onEnter()
    logic.NovicesRewardManager:getInstance():requestNovicesRewardInfo(function( result )
        if result then
            self:initGiftByData(result)
            local event = cc.EventCustom:new(config.EventConfig.EVENT_SOUND_PLAY)
            event.userdata = {soundId = "Lobby/res/music/getcoin.mp3"}
            lib.EventUtils.dispatch(event) 

        end
    end)
end

function NovicesRewardLayer:onExit()
    self:stopAllActions()
end

return NovicesRewardLayer