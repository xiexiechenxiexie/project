local ExitGameDialg = class("ExitGameDialg", lib.layer.Window)

function ExitGameDialg:ctor()
	ExitGameDialg.super.ctor(self, lib.layer.Window.SMALL)
	self:_initView()
end

function ExitGameDialg:_initView()

    local dialogbg = self._root
    -- body
    local tip = ccui.Text:create()
    tip:setText(mallDataList[index].goodsName)
    tip:setFontSize(22)
    tip:setTextColor(cc.c4b(202, 195, 248, 255))
    tip:setAnchorPoint(cc.p(1, 0.5))
    tip:setPosition(cc.p(dialogbg:getContentSize().width/2, dialogbg:getContentSize().height*0.65))
    dialogbg:addChild(tip)

    local exitBtn = ccui.Button:create("res/common/btn_qq_login.png")
    exitBtn:setPosition(cc.p(dialogbg:getContentSize().width/2, dialogbg:getContentSize().height*0.25))
    dialogbg:addChild(exitBtn)

    local function callback()
        cc.Director:getInstance():endToLua()
    end
    exitBtn:addClickListener(callback)
end


return ExitGameDialg