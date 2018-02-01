-- 客服界面
-- Author: tangwen
-- Date: 2017-10-13 14:27:51
--

local ServiceView = class("ServiceView", lib.layer.Window)

function ServiceView:ctor(data)
	self._ServiceData = data
    ServiceView.super.ctor(self,ConstantsData.WindowType.WINDOW_SERVICE)
	self:initView()
end

function ServiceView:initView()
    local bg = self._root
    self._bg = bg

    local bgSize = bg:getContentSize()

    local title = ccui.ImageView:create("Lobby_service_title.png", ccui.TextureResType.plistType)
    title:setPosition(bgSize.width/2, bgSize.height - 25-35)
    bg:addChild(title)

    local contact = ccui.ImageView:create("Lobby_service_lianxi.png", ccui.TextureResType.plistType)
    contact:setPosition(bgSize.width/2, bgSize.height - 135)
    bg:addChild(contact)


    -- local codeImg = ccui.ImageView:create("Lobby_service_code.png", ccui.TextureResType.plistType)
    -- codeImg:setPosition(bgSize.width/2 + 240, 165)
    -- bg:addChild(codeImg)

    local qqServiceStr = self._ServiceData.qqProxy or ""
    local qqProxyStr = self._ServiceData.qqService or ""
    local weChatProxyStr = self._ServiceData.qqServiceStr or ""

    local textStrList = {}

    local textStr1 = "招房卡代理商QQ:" .. qqServiceStr
    local textStr2 = "招代理商微信:" .. qqProxyStr
    local textStr3 = "游戏客服QQ:" .. weChatProxyStr
    -- local textStr4 = "官方公众号"
    table.insert(textStrList,textStr1)
    table.insert(textStrList,textStr2)
    table.insert(textStrList,textStr3)
    -- table.insert(textStrList,textStr4)

    for i=1,3 do
        local textLabel = cc.Label:createWithTTF(textStrList[i],GameUtils.getFontName(),30)
        textLabel:setPosition(bgSize.width/2-70 , bgSize.height - (i-1)*75 - 125-75)
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
