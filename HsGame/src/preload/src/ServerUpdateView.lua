-- 更新大包界面
-- Author: tangwen
-- Date: 2017-10-12 14:54:14
--
local ServerUpdateView = class("ServerUpdateView", cc.Layer)
function ServerUpdateView:ctor(data)
	self._data = data
	self:addChild(cc.LayerColor:create(cc.c4b(10,10,10,120), display.width, display.height))
	self:initView()
end

function ServerUpdateView:initView()
	-- local bg = self._root
	local bg = ccui.Scale9Sprite:create(cc.rect(100,135,8,8),"src/preload/res/update_little_bg.png")
	self._bg = bg
    self._bg:setContentSize({width = 720,height = 300})
    self:addChild(self._bg)
    self._bg:setPosition(display.width / 2,display.height / 2)

    local bgSize = bg:getContentSize()
    local title = ccui.ImageView:create("src/preload/res/update_title.png", ccui.TextureResType.localType)
    title:setPosition(bgSize.width/2, bgSize.height - 25)
    bg:addChild(title)

	local labelConfig =	{
		fontName = GameUtils.getFontName(),
		fontSize = 23,
		text = self._data.info,
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(194,84,29, 255),
		pos = cc.p(bgSize.width * 0.5 ,bgSize.height * 0.65),
		anchorPoint = cc.p(0.5,0.5)
	}
	local label = cc.exports.lib.uidisplay.createLabel(labelConfig)
	bg:addChild(label)



	local configImg = "src/preload/res/btnConfig.png"
    self._configBtn = lib.uidisplay.createUIButton({
        normal = configImg,
        textureType = ccui.TextureResType.localType,
        isActionEnabled = true,
        callback = function() 
            self:onConfigCallback()           
        end
        })
	self._configBtn:setPosition(bgSize.width / 2, 50)
    bg:addChild(self._configBtn)
    self._configBtn:setScale(0.8)

	local labelConfig =	{
		fontName = GameUtils.getFontName(),
		fontSize = 30,
		text = "知道了",
		alignment = cc.TEXT_ALIGNMENT_CENTER,
		color = cc.c4b(255,255,255, 255),
		pos = cc.p(self._configBtn:getContentSize().width * 0.5 ,self._configBtn:getContentSize().height * 0.5),
		anchorPoint = cc.p(0.5,0.5)
	}
	local label = cc.exports.lib.uidisplay.createLabel(labelConfig)
	self._configBtn:addChild(label)

end



-- 不更新 下次再说 
function ServerUpdateView:onConfigCallback( ... )
	cc.Director:getInstance():endToLua()
end

function ServerUpdateView:onEnter( ... )
end

function ServerUpdateView:onExit()

end

return ServerUpdateView

