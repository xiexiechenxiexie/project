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

    -- local node =cc.CSLoader:createNode("GameLayout/Reward/GiftAccount.csb")
    -- self:addChild(node)
    -- self._giftLiftBg = node:getChildByName("gift_light_1_1_4")

    -- local act = cc.CSLoader:createTimeline("GameLayout/Reward/GiftAccount.csb")
    -- act:setTimeSpeed(1) --设置执行动画速度
    -- node:runAction(act)
    -- act:gotoFrameAndPlay(0,false)
    -- act:setLastFrameCallFunc(function()
    --     local rb = cc.RotateBy:create(1, 9.82)
    --     local RepeaAction = cc.RepeatForever:create(rb)
    --     self._giftLiftBg:runAction(RepeaAction)
    -- end)

    local dir = "GameLayout/Animation/qiandao_Animation/"
    local node = ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(dir.."qiandao_Animation0.png",dir.."qiandao_Animation0.plist",dir.."qiandao_Animation.ExportJson")  
    local adAnim = ccs.Armature:create("qiandao_Animation") 
    adAnim:setPosition(self:getContentSize().width/2,self:getContentSize().height/2) 
    self:addChild(adAnim);
    adAnim:getAnimation():playWithIndex(0)

    local okImg = "Reward_btn_ok.png"
    local btnOk = lib.uidisplay.createUIButton({
        normal = okImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            GameUtils.popDownNode(self,function()
                GameUtils.hideGiftAccount()
            end)
        end
        })
    btnOk:setPosition(0, -255)
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
    	giftBg:setPosition(good_posX,good_posY+15)
    	self:addChild(giftBg)
    	good_posX = good_posX + 180

    	local iconImg = ""
    	local iconText = ""
    	if v.type == ConstantsData.PointType.POINT_COINS then  -- 金币 
    		iconImg = "Reward_icon_gold.png"
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
    	giftIcon:setPosition(giftBg:getContentSize().width/2,giftBg:getContentSize().height/2+10)
    	giftBg:addChild(giftIcon)

    	local giftText = cc.Label:createWithTTF(iconText,GameUtils.getFontName(),24)
    	giftText:setPosition(giftBg:getContentSize().width/2, 25)
        giftText:setColor(cc.c3b(255,210,0))
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