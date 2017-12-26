---------------------------------------
--破产补助
---------------------------------------

local Subsidy = class("Subsidy",lib.layer.BaseWindow)
local GameResPath = "gamecommon/subsidy/res/"
local GameRequest = require "request/GameRequest"
Subsidy.share = 151				--破产补助分享
Subsidy.shop = 152				--破产补助商店
function Subsidy:ctor()
	Subsidy.super.ctor(self)
	self._gameRequest = GameRequest:new()
end

function Subsidy:initLayer(goldNum)
	print("破产补助",goldNum)
	local container = cc.CSLoader:createNode(GameResPath.."subsidy.csb")
	self:addChild(container)
	self.container = container
	local bg = container:getChildByName("subsidybg")
	self.bg = bg
	self:_onRootPanelInit(bg)
	local gold = cc.Label:createWithTTF(self:switchNum(goldNum).."金币",GameUtils.getFontName(),33)
    gold:setPosition(220,150)
    gold:setColor(cc.c3b(255,210,0))
    bg:addChild(gold)

    local close = bg:getChildByName("subClose")
	close:addClickEventListener(function(sender) self:onCloseCallback(sender) end)
	local lingqu = bg:getChildByName("subLingqu")
	lingqu:addClickEventListener(function(sender) self._gameRequest:RequestBankRupt() self:onCloseCallback(sender) end)
	local shop = bg:getChildByName("subShop")
	shop:setTag(Subsidy.shop)
	shop:addClickEventListener(function(sender)  self:onButtonClickedEvent(sender) end)

    local text = bg:getChildByName("Text_2")
    text:setFontName(GameUtils.getFontName())

    --金币牛牛场次信息
    local label = cc.Label:createWithTTF("很遗憾您已经破产了！",GameUtils.getFontName(), 33)
    label:setPosition(349,328)
    label:setColor(cc.c3b(224,220,242))
    bg:addChild(label)
end

function Subsidy:onButtonClickedEvent(sender)
	local tag = sender:getTag()
	if tag == Subsidy.shop then
		print("商城")
        if not manager.UserManager:getInstance():findAppCloseRoomCardFlag() then
		  self:ShopAct()
        end
	end
end

--进入商店
function Subsidy:ShopAct()
    print("进入商店")
    self:addChild(require("src/lobby/layer/MallDialog"):create(config.MallLayerConfig.Type_Gold),101)
end

function Subsidy:onEnter()
	Subsidy.super.onEnter(self)
end

function Subsidy:switchNum(num)
	if num == nil or type(num)~="number" then  
        printInfo("将数字改成以万，亿为单位，参数错误")  
    else
    	local IsZheng=true
		if num<0 then
			IsZheng=false
			num=0-num
		end  
        if num / 10^8 >=1 then  
            num = math.floor(num / 10^6)
            if IsZheng then
              	return(string.format("%.2f", num/10^2).."亿")
            else
            	return "-"..(string.format("%.2f", num/10^2).."亿")
            end
        elseif num / 10^4 >= 1 then  
            num = math.floor(num / 10^2)
            if IsZheng then
              	return(string.format("%.2f", num/10^2).."万")
            else
            	return "-"..(string.format("%.2f", num/10^2).."万")
            end
        else
        	if IsZheng then
              	return tostring(num)
            else
            	return "-"..tostring(num)
            end  
            return num  
        end  
    end 
end

return Subsidy