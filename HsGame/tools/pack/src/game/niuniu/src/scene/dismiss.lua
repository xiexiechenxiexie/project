-------------------------------------
--解散界面
-------------------------------------
local dismiss = class("dismiss",lib.layer.BaseWindow)
local GameResPath  = "game/niuniu/res/GameLayout/NiuNiu/"
local conf = require"game/niuniu/src/scene/conf"
local GameRequest = require "game/niuniu/src/request/GameRequest"
local Time = require "game/niuniu/src/scene/Time"

local DIS_COLOR1 = cc.c3b(86,255,166)--昵称
local DIS_COLOR2 = cc.c3b(255,228,209)
local DIS_COLOR3 = cc.c3b(255,140,140)--提示
local DIS_COLOR4 = cc.c3b(255,236,109)--同意


function dismiss:ctor()
	dismiss.super.ctor(self)
	self:enableNodeEvents() 
	self:init()
	self._gameRequest = GameRequest:new()
end

function dismiss:init()
	local dism = cc.CSLoader:createNode(GameResPath.."dismiss_time.csb")
	self:addChild(dism)
	local bg = dism:getChildByName("dismiss_bg_1")
	self:_onRootPanelInit(bg)
	local x,y = bg:getContentSize().width,bg:getContentSize().height

	local close = bg:getChildByName("disTime_close")
	close:setTag(conf.dism.dis_close)
	close:addClickEventListener(function(sender) self:onClickBack(sender) end)
	local quxiao = bg:getChildByName("disTime_quxiao")
	quxiao:setTag(conf.dism.dis_quxiao)
	quxiao:addClickEventListener(function(sender) self:onClickBack(sender) end)
	quxiao:setVisible(false)
	self.quxiao=quxiao
	local queding = bg:getChildByName("disTime_queding")
	queding:setTag(conf.dism.dis_queding)
	queding:addClickEventListener(function(sender) self:onClickBack(sender) end)
	queding:setVisible(false)
	self.queding=queding

    local node=cc.Node:create()
    node:setPosition(x/2-display.cx,y/2-display.cy)
    bg:addChild(node)
    self.rootNode=node
    self.size=cc.size(x,y)

    self.bg=bg

    self.playerInfoData = {}
    self.DismissArrayInfo = {}
end

function dismiss:initAction(DismissArrayInfo,playerInfoData)
	self.rootNode:removeAllChildren()
	self.quxiao:setVisible(false)
	self.queding:setVisible(false)
	local x,y=self.size.width,self.size.height
	local dismissArray=DismissArrayInfo.DismissArray
	local reqUid=DismissArrayInfo.ReqUid
	local playerNum=#dismissArray

	for i,v in ipairs(dismissArray) do
		if tostring(UserData.userId)==tostring(v.uid) then
			if v.isDissolution==2 then
				self.quxiao:setVisible(true)
				self.queding:setVisible(true)
			end
		end
	end

	local host_name_str = nil
	if playerInfoData[reqUid] then
		host_name_str = string.getMaxLen(playerInfoData[reqUid].NickName,10)
	else
		self.playerInfoData = playerInfoData
		self.DismissArrayInfo = DismissArrayInfo
		self:RequestUserInfo(reqUid)
		self.rootNode:removeAllChildren()
		return
	end

	local text = cc.Label:createWithTTF("房间".."["..host_name_str.."]".."要求解散该房间，是否同意解散？",GameUtils.getFontName(),30)
	text:setColor(DIS_COLOR2)
	text:setPosition(x-180,y/2+240)
	self.rootNode:addChild(text)

	local tishiStr = nil
	if DismissArrayInfo.alltime > 60 then
		tishiStr = "(超过"..tostring((DismissArrayInfo.alltime)/60).."分钟未选择，默认为同意)"
	else
		tishiStr = "(超过"..tostring(DismissArrayInfo.alltime).."秒未选择，默认为同意)"
	end
	local tishi = cc.Label:createWithTTF(tishiStr,GameUtils.getFontName(),30)
	tishi:setColor(DIS_COLOR3)
	tishi:setPosition(x-180,y/2+200)
	self.rootNode:addChild(tishi)

	local time = Time.new(DismissArrayInfo.time)
	time:setPosition(x-190,y-333)
	self.rootNode:addChild(time)

	for i=1,playerNum do
		local str=nil
		if dismissArray[i].isDissolution==0 then
			str="选择拒绝"
		elseif dismissArray[i].isDissolution==1 then
			str="选择同意"
		elseif dismissArray[i].isDissolution==2 then
			str="等待选择"
		end

		local player_name_str = string.getMaxLen(playerInfoData[dismissArray[i].uid].NickName,10)

		local text= cc.Label:createWithTTF("["..player_name_str.."]"..":"..str,GameUtils.getFontName(),30)
		text:setAnchorPoint(0,0)
	    if i%2 == 1 then
    		text:setPosition(x-560,y-120-(self:getIntPart((i-1)/2)*50))
	    else
    		text:setPosition(x-160,y-120-(self:getIntPart((i-1)/2)*50))
	    end
	    text:setColor(DIS_COLOR2)
	    self.rootNode:addChild(text)
	end
end

function dismiss:onClickBack(sender)
	local tag = sender:getTag()
	if tag == conf.dism.dis_close then
		self._gameRequest:RequestDissolutionAction(0)
		self:CloseDismissTime()
	elseif tag == conf.dism.dis_quxiao then
		self._gameRequest:RequestDissolutionAction(0)
	elseif tag == conf.dism.dis_queding then
		self._gameRequest:RequestDissolutionAction(1)
	end
end

function dismiss:CloseDismissTime()
	self:onCloseCallback()
end

-- 请求用户信息
function dismiss:RequestUserInfo( __userID)
    local config = cc.exports.config
    local url = config.ServerConfig:findModelDomain() .. config.ApiConfig.REQUEST_PLAYER_INFO .. __userID
    cc.exports.HttpClient:getInstance():get(url,handler(self,self._onInfoCallback))
end

function dismiss:_onInfoCallback( __error,__response )
    if __error then
        print("Player Info net error")
    else
        if 200 == __response.status then
        	local data = __response.data.profile
        	if next(data)~=nil then
        		local index = data.UserId
        		self.playerInfoData[index] = {}
				self.playerInfoData[index].NickName=data.NickName
				self:initAction(self.DismissArrayInfo,self.playerInfoData)
        	end 
        end
    end
end

function dismiss:getIntPart(x)
  if x <= 0 then
     return math.ceil(x);
  end

  if math.ceil(x) == x then
     x = math.ceil(x);
  else
     x = math.ceil(x) - 1;
  end
  return x;
end

function dismiss:onEnter()
	dismiss.super.onEnter(self)
end

function dismiss:onTouchBegan(touch, event)
	return true
end

return dismiss