-- 客服界面
-- Author: tangwen
-- Date: 2017-10-13 14:27:51
--

local ServiceView = class("ServiceView", lib.layer.Window)

function ServiceView:ctor(data)
	self._ServiceData = data
    ServiceView.super.ctor(self,ConstantsData.WindowType.WINDOW_BIG)
	self:initView()
end

function ServiceView:initView()
    local bg = self._root
    self._bg = bg

    local bgSize = bg:getContentSize()

    local serviceBg = ccui.ImageView:create("Lobby_service_title.png", ccui.TextureResType.plistType)
    serviceBg:setPosition(bgSize.width/2, bgSize.height - 25)
    bg:addChild(serviceBg)

    local title = ccui.ImageView:create("Lobby_service_bg.png", ccui.TextureResType.plistType)
    title:setPosition(bgSize.width/2, bgSize.height/2 - 25)
    bg:addChild(title)

    local meinvImg = ccui.ImageView:create("meinv.png", ccui.TextureResType.plistType)
    meinvImg:setScale(0.73)
    meinvImg:setPosition(198, bgSize.height/2 - 42)
    bg:addChild(meinvImg)


    local codeImg = ccui.ImageView:create("Lobby_service_code.png", ccui.TextureResType.plistType)
    codeImg:setPosition(bgSize.width/2 + 100, 135)
    bg:addChild(codeImg)

    local qqServiceStr = self._ServiceData.QQService or ""
    local qqProxyStr = self._ServiceData.QQProxy or ""
    local weChatProxyStr = self._ServiceData.WechatProxy or ""

    local textStrList = {}

    local textStr1 = "房卡代理商QQ:" .. qqProxyStr
    local textStr2 = "产品代理联运微信:" .. weChatProxyStr
    local textStr3 = "游戏咨询QQ:" .. qqServiceStr
    local textStr4 = "官方公众号:花色互娱"
    table.insert(textStrList,textStr1)
    table.insert(textStrList,textStr2)
    table.insert(textStrList,textStr3)
    table.insert(textStrList,textStr4)

    for i=1,4 do
        local textStr = string.format("Lobby_service_tex_%d.png", i)
        local textImg = ccui.ImageView:create(textStr, ccui.TextureResType.plistType)
        textImg:setPosition(bgSize.width/2 - 55, bgSize.height - (i-1)*75 - 125)
        bg:addChild(textImg)

        local textLabel = cc.Label:createWithTTF(textStrList[i],GameUtils.getFontName(),30)
        textLabel:setPosition(bgSize.width/2 - 10 , bgSize.height - (i-1)*75 - 125)
        textLabel:setAnchorPoint(0,0.5)
        bg:addChild(textLabel)
    end

end


function ServiceView:onEnter( ... )
	ServiceView.super.onEnter(self)
end

function ServiceView:onExit()

end

return ServiceView
