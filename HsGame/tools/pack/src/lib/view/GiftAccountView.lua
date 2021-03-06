-- 获得物品展示
-- @date 2017.08.21
-- @author tangwen


local GiftAccountView = class("GiftAccountView", function()
	return display.newNode()
end)

function GiftAccountView:ctor(__params)
    self._params = __params
	self:enableNodeEvents() 
	self:initView()
    self:initGiftByData()
end

function GiftAccountView:initView()

    local node =cc.CSLoader:createNode("GameLayout/Reward/GiftAccount.csb")
    self:addChild(node)
    self._giftLiftBg = node:getChildByName("gift_light_1_1_4")

    local act = cc.CSLoader:createTimeline("GameLayout/Reward/GiftAccount.csb")
    act:setTimeSpeed(1) --设置执行动画速度
    node:runAction(act)
    act:gotoFrameAndPlay(0,false)
    act:setLastFrameCallFunc(function()
        local rb = cc.RotateBy:create(1, 9.82)
        local RepeaAction = cc.RepeatForever:create(rb)
        self._giftLiftBg:runAction(RepeaAction)
    end)

    local btnOk = cc.exports.lib.uidisplay.createLabelButton({
            textureType = ccui.TextureResType.plistType,
            normal = "common_big_yellow_btn.png",
            callback = function() 
                GameUtils.popDownNode(self,function()
                    GameUtils.hideGiftAccount()
                end)
            end,
            isActionEnabled = true,
            pos = cc.p(0, -255),
            text = "确 定",
            outlineColor = cc.c4b(112,45,2,255),
            outlineSize = 2,
            labPos = cc.p(0,2),
    })
    self:addChild(btnOk,999)
    
end

-- 根据数值显示领取物品
function GiftAccountView:initGiftByData()
	if self._params == nil then
        return
    end
    local bgSize = cc.size(1334,750)
	local good_posX = - 180 * (#self._params / 2 - 0.5)
	local good_posY = -20
	for k,v in pairs(self._params) do
		local giftBg = ccui.ImageView:create("Reward_gift_bg.png", ccui.TextureResType.plistType)
    	giftBg:setPosition(good_posX,good_posY)
    	self:addChild(giftBg)
    	good_posX = good_posX + 180

    	local iconImg = ""
    	local iconText = ""
    	if v.type == ConstantsData.PointType.POINT_COINS then  -- 金币 
    		iconImg = "Lobby_sign_recond_icon_2.png"
    		iconText = "金币X" .. v.score
    	elseif v.type == ConstantsData.PointType.POINT_DIAMOND then --钻石
    		iconImg = "Reward_icon_diamond.png"
    		iconText = "钻石X" .. v.score
    	elseif v.type == ConstantsData.PointType.POINT_ROOMCARD then --房卡
    		iconImg = "Reward_icon_roomcard.png"
    		iconText = "房卡X" ..v.score
    	else
    		print("奖励物品格式错误:",v.type)
    	end
    	local giftIcon = ccui.ImageView:create(iconImg, ccui.TextureResType.plistType)
    	giftIcon:setPosition(73,69)
    	giftBg:addChild(giftIcon)

    	local giftText = cc.Label:createWithTTF(iconText,GameUtils.getFontName(),24)
    	giftText:setPosition(73, -30)
    	giftBg:addChild(giftText)
	end

end

function GiftAccountView:onEnter()
    GameUtils.popUpNode(self)
end

function GiftAccountView:onExit()
	self:stopAllActions()
end

return GiftAccountView