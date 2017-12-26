-- 游戏界面基类	用于处理通用的游戏界面操作
-- @date 2017.07.13
-- @author tangwen

local AuthorizeSitView = require "gamemodel/view/AuthorizeSitView"
local GameRequest = require "request/GameRequest"

local GameModelScene = class("GameModelScene", function()
    return display.newScene()
end)


function GameModelScene:ctor()
	self:enableNodeEvents()  -- 注册 onEnter onExit 时间 by  tangwen
	self:createAuthorizeSitView()
	self._TableInfoArray = {}
	self._SitState = 1  --座位可点击的状态 1表示可以处理授权入座信息，0 表示 等待房主处理入座申请,请稍后
end


function GameModelScene:RequestAuthorizeSitApply()
	print(self._TableInfoArray.landlord,UserData.userId)
    if self._SitState == 1 then
    	if self._TableInfoArray.landlord == UserData.userId then
    		self._gameRequest:RequestAuthorizeSitApply()
	        self._SitState = 0
    	else
    		lobby.CreateRoomManager:getInstance():checkSitDown(self._TableInfoArray.tableID,function ( __roomInfo )
	            self._gameRequest:RequestAuthorizeSitApply()
	            self._SitState = 0
	        end)
    	end
    else
        GameUtils.showMsg("等待房主处理入座申请,请稍后...")
    end
end


function GameModelScene:AuthorizeResult(__resultState)
	if __resultState == 1 then  -- 授权入座，返回结果状态码1 成功
		print("授权入座成功，移除旁观者状态")
		self:removeSpectatorsState() -- 移除旁观者状态  
	elseif __resultState == 2 then -- 授权入座，返回结果状态码2 房卡不够
		print("授权入座失败，进入旁观者状态")
		self._SitState = 1
		self:SetSpectatorsState()  -- 设置旁观者状态 
		GameUtils.showMsg("房卡不够")
	else
		print("授权入座被拒绝，进入旁观者状态")
		self._SitState = 1
		self:SetSpectatorsState() -- 设置旁观状态
		GameUtils.showMsg("房主拒绝了您的入座申请！")
	end
end

--  子游戏处理具体实现逻辑
--  设置旁观者状态  站起 
function GameModelScene:SetSpectatorsState() 
	
end

--  解除旁观者状态  坐下
function GameModelScene:removeSpectatorsState()
	
end


function GameModelScene:createAuthorizeSitView()
	local authorizeSitView = AuthorizeSitView.new()
 	self:addChild(authorizeSitView,109)
 	self._AuthorizeSitView = authorizeSitView
end

function GameModelScene:showAuthorizeSitView(__param)
	self._AuthorizeSitView:initInformNode(__param)
end

function GameModelScene:updateInformView(__param)
    self._AuthorizeSitView:updataInformNode(__param)
end

-- 设置桌子信息列表
function GameModelScene:setTableInfoArrayData(__data)
	self._TableInfoArray = __data
end

function GameModelScene:getTableInfoArrayData()
	return self._TableInfoArray
end


function GameModelScene:onEnter(__musicId)
	print("__cname",self.__cname)
	UserData.RunSceneType = ConstantsData.SceneType.GAME_SCENE_TYPE	
end

function GameModelScene:_onMusicPlay( __musicId )
    local event = cc.EventCustom:new(config.EventConfig.EVENT_MUISIC_PLAY)
    event.userdata = {musicId = __musicId}
	lib.EventUtils.dispatch(event)
end

function GameModelScene:onExit()
    local event = cc.EventCustom:new(config.EventConfig.EVENT_MUISIC_STOP)
	lib.EventUtils.dispatch(event)
end

return GameModelScene