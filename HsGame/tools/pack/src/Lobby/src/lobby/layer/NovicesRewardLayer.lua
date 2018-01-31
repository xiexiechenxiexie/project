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

	local bg = ccui.ImageView:create("res/GameLayout/Reward/Reward_bg.png")
    bg:setPosition(display.cx,display.cy)
    self:addChild(bg)
    self._bg = bg

    local girl = ccui.ImageView:create("res/GameLayout/Reward/Reward_girl.png")
    girl:setAnchorPoint(0,0)
    girl:setPosition(10,0)
    bg:addChild(girl)

    local dir = "GameLayout/Animation/xinshoujiangli_Animation/"
    local node = ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."xinshoujiangli_Animation0.png",dir.."xinshoujiangli_Animation0.plist",dir.."xinshoujiangli_Animation.ExportJson")  
    local adAnim = ccs.Armature:create("xinshoujiangli_Animation") 
    adAnim:setPosition(bg:getContentSize().width/2+180,bg:getContentSize().height/2) 
    bg:addChild(adAnim);
    adAnim:getAnimation():playWithIndex(0)

    -- local node =cc.CSLoader:createNode("GameLayout/Reward/xinshoujiangli.csb")
    -- bg:addChild(node)
    -- self._giftLiftBg = node:getChildByName("beijinguang2")

    -- local act = cc.CSLoader:createTimeline("GameLayout/Reward/xinshoujiangli.csb")
    -- act:setTimeSpeed(1) --设置执行动画速度
    -- node:runAction(act)
    -- act:gotoFrameAndPlay(0,false)
    -- act:setLastFrameCallFunc(function()
    --     local rb1 = cc.RotateBy:create(1, 60)
    --     local sb1 = cc.ScaleTo:create(1,0.9)
    --     local rb2 = cc.RotateBy:create(1, -60)
    --     local sb2 = cc.ScaleTo:create(1,1)
    --     local spawn1 = cc.Spawn:create({rb1,sb1})
    --     local spawn2 = cc.Spawn:create({rb2,sb2})
    --     local RepeaAction = cc.RepeatForever:create(transition.sequence({ spawn1, spawn2 }))
    --     self._giftLiftBg:runAction(RepeaAction)
    -- end)


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
    		iconImg = "Reward_icon_gold.png"
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
    	giftIcon:setPosition(giftBg:getContentSize().width/2,giftBg:getContentSize().height/2+10)
    	giftBg:addChild(giftIcon)

    	local giftText = cc.Label:createWithTTF(iconText,GameUtils.getFontName(),30)
    	giftText:setPosition(giftBg:getContentSize().width/2, 25)
        giftText:setColor(cc.c3b(255,210,0))
    	giftBg:addChild(giftText)
        self:UpRewardNodeAni(giftBg)
	end

    local startText = cc.Label:createWithTTF("恭喜获得新手奖励~让我陪你一起玩游戏吧~",GameUtils.getFontName(),32)
    startText:setPosition(display.cx + 170, 190)
    self:addChild(startText)
    self:UpRewardNodeAni(startText)

    local okImg = "Reward_btn_start.png"
    local btnOk = lib.uidisplay.createUIButton({
        normal = okImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            logic.NovicesRewardManager:getInstance():requestNovicesRewardReceive(function( result )
                if result then
                    GameUtils.removeNode(self)
                    require("lobby/scene/LobbyScene"):create():runWithScene()
                end
            end)
        end
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