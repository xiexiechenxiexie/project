--[[--
@author fly
]]
local UIDisplay = {

	createLabel = function ( __params )

		local ttfConfig = {}
	    ttfConfig.fontFilePath= __params.fontName or GameUtils.getFontName()
	    ttfConfig.fontSize = __params.fontSize or 14
	    local text = __params.text or ""
	    local alignment = __params.alignment or cc.TEXT_ALIGNMENT_CENTER
	    local color = __params.color or cc.c4b(255,255,255, 255)
	    local pos = __params.pos or cc.p(0,0)
	    local anchorPoint = __params.anchorPoint or cc.p(0.5,0.5)

		local label = cc.Label:createWithTTF(ttfConfig, text, alignment)
		label:setTextColor(color)
		label:setAnchorPoint(anchorPoint)
		label:setPosition(pos)
		return label
	end,
	
	createUIButton = function ( __params )
		assert(__params.normal,"invalid file param")
		local normal = __params.normal 
		local pressed = __params.pressed or normal
		local disable = __params.disable or normal
		local textureType = __params.textureType or ccui.TextureResType.localType
		local pos = __params.pos or cc.p(0,0)
		local callback = __params.callback or function ()end
		local isActionEnabled = __params.isActionEnabled 
		local button = ccui.Button:create(normal,pressed,disable,textureType)
		button:setPressedActionEnabled(isActionEnabled)
		button:addClickEventListener(callback)
		button:setPosition(pos)
		return button
	end,

	--[[--
		创建单选组件
	]]
	createRadioGroup = function ( __params )
		assert(__params.fileSelect and __params.fileUnselect,"invalid params ")
		local parent = __params.parent
		local groupPos = __params.groupPos or cc.p(0,0)
		local fileSelect = __params.fileSelect
		local fileUnselect = __params.fileUnselect
		local textureType = __params.textureType or ccui.TextureResType.localType
		local callback = __params.callback
		local poses = __params.poses or {}
		local num = __params.num or 1
		local selectNum = __params.selectNum or 1

		local group = ccui.RadioButtonGroup:create()
		group:setPosition(groupPos)
		if parent then
			parent:addChild(group)
		end

		for i = 1,num do
			local pos = poses[i] or cc.p(0,0)
			local radioButton = ccui.RadioButton:create(fileUnselect,fileUnselect,fileSelect,fileUnselect,fileUnselect,textureType)
			group:addRadioButton(radioButton)
			
			radioButton:setPosition(pos)	
			if i == selectNum then
				group:setSelectedButtonWithoutEvent(radioButton)
			end
			if parent  then
				parent:addChild(radioButton)
			end
		end
		group:addEventListener(callback)
		return group
	end,

	--  创建该样式的节点  - [ 99  ]  +
	createAddMinusNode = function( __params )
		local imgBg = __params.imgBg
		local callback = __params.callback or function()end
		local imgMinus = __params.imgMinus
		local imgMinusPrssed = __params.imgMinusPrssed or imgMinus
		local imgMinusDisabled = __params.imgMinusDisabled or imgMinus
		local imgMinusSize = __params.imgMinusSize or cc.size(53,53)
		local imgAdd = __params.imgAdd
		local imgAddPrssed = __params.imgAddPrssed or imgAdd
		local imgAddDisabled = __params.imgAddDisabled or imgAdd
		local imgAddSize = __params.imgAddSize or cc.size(53,53)
		local textureType = __params.textureType
		local textSize = __params.textSize or 16
		local textColor = __params.textColor or cc.c4b(255,255,255,255)
		local textFont = __params.textFont or ""
		local num = __params.num
		local dNum = __params.dNum or 1
		local maxNum = __params.maxNum or -1
		local minNum = __params.minNum or -1
		
		imgBg = ccui.ImageView:create(imgBg,textureType)
		local size = imgBg:getContentSize()

		local buttonMinus = ccui.Button:create(imgMinus,imgMinusPrssed,imgMinusDisabled,textureType)
		buttonMinus:setPressedActionEnabled(true)

		buttonMinus:setPosition(cc.p(imgMinusSize.width/2-5,size.height * 0.5-2))
		imgBg:addChild(buttonMinus)


		local buttonAdd = ccui.Button:create(imgAdd,imgAddPrssed,imgAddDisabled,textureType)
		buttonAdd:setPressedActionEnabled(true)
		buttonAdd:addClickEventListener(callback)
		buttonAdd:setPosition(cc.p(size.width - imgAddSize.height/2+5 ,size.height * 0.5-2))
		imgBg:addChild(buttonAdd)
		buttonAdd:setTag(1)

		local ttfConfig = {}
	    ttfConfig.fontFilePath= __params.textFont
	    ttfConfig.fontSize = __params.textSize 
		local label = cc.Label:createWithTTF(ttfConfig, "" .. num, cc.TEXT_ALIGNMENT_CENTER)
		label:setTextColor(textColor)
		label:setPosition(size.width * 0.5,size.height * 0.5)
		imgBg:addChild(label)

		buttonMinus:addClickEventListener(function ( ... )
			if num > dNum then
				num = num -dNum
				if minNum > 0 and num  <= minNum then  num = minNum  end
				label:setString(""..num)
				callback(num,label)
			end

		end)

		buttonAdd:addClickEventListener(function ( ... )
			num = num + dNum
			if maxNum > 0 and num  > maxNum then  num = maxNum  end
			label:setString(""..num)
			callback(num,label)
		end)
		return imgBg
	
	end
}

cc.exports.lib.uidisplay = UIDisplay