------------------------------------------------
--授权通知

local AuthorizeSitView = class("AuthorizeSitView",cc.Node)
local GameResPath = "game/niuniu/res/GameLayout/NiuNiu/"
local GameRequest = require "request/GameRequest"
AuthorizeSitView._cacheApplySitInformNode = {}
function AuthorizeSitView:ctor()
	self._cacheApplySitInformNode = {}
	self.index = 0
	self._informNodeList = {}
	self:preloadUI()
	self._gameRequest = GameRequest:new()
end

function AuthorizeSitView:preloadUI()
	display.loadSpriteFrames(GameResPath.."inform.plist",
							GameResPath.."inform.png")
end

function AuthorizeSitView:createInformNode(__data)
	local informNode = cc.CSLoader:createNode(GameResPath .. "informNode.csb")

	local bg = informNode:getChildByName("inform_bg")
	local y = bg:getContentSize().height

	informNode.ApplyUserID = __data.applyUserID
	informNode.TableID = __data.tableID
	informNode.GameID = __data.gameID

	print("informNode.ApplyUserID:",informNode.ApplyUserID)

	local close = informNode:getChildByName("inform_close")
	local agree = informNode:getChildByName("inform_agree")
	local refuse = informNode:getChildByName("inform_refuse")

	close:addClickEventListener(function()
		-- GameUtils.removeNode(informNode)
		-- self:initInformNodePos()
		close:setTouchEnabled(false)
		agree:setTouchEnabled(false)
		refuse:setTouchEnabled(false)
		self._gameRequest:RequestAuthorizeAction(ConstantsData.ActionIndexType.ACTION_INDEX_REFUSE,informNode.ApplyUserID,informNode.TableID)
	end)
	agree:addClickEventListener(function()
		close:setTouchEnabled(false)
		agree:setTouchEnabled(false)
		refuse:setTouchEnabled(false)
		self._gameRequest:RequestAuthorizeAction(ConstantsData.ActionIndexType.ACTION_INDEX_AGREE,informNode.ApplyUserID,informNode.TableID)
	end)
	refuse:addClickEventListener(function()
		close:setTouchEnabled(false)
		agree:setTouchEnabled(false)
		refuse:setTouchEnabled(false)
		self._gameRequest:RequestAuthorizeAction(ConstantsData.ActionIndexType.ACTION_INDEX_REFUSE,informNode.ApplyUserID,informNode.TableID)
	end)


	local string = string.getMaxLen(__data.nickName).."申请加入您创建的斗牛"..__data.tableID.."号桌游戏,是否同意入桌?"
	local label = cc.Label:createWithSystemFont(string,SYSFONT,28)
	label:setAnchorPoint(0,0.5)
	label:setPosition(20,y/2)
	bg:addChild(label)

	return informNode
end

function AuthorizeSitView:initInformNode(__data)
	print("AuthorizeSitView:initInformNode >>")
	if self._cacheApplySitInformNode[__data.applyUserID] then return end 
	self.index = self.index+1
	local informNode = self:createInformNode(__data)
	informNode:setPosition(667,700-(#self._informNodeList)*80)
	self:addChild(informNode)
	informNode:setTag(self.index)
	table.insert(self._informNodeList,informNode)
    self:initInformNodePos()
    self._cacheApplySitInformNode[__data.applyUserID] = true
end

function AuthorizeSitView:initInformNodePos()
	if #self._informNodeList>4 then
		self._informNodeList[1]:removeFromParent()
		table.remove(self._informNodeList,1)
		for i,v in ipairs(self._informNodeList) do
			self._informNodeList[i]:runAction(cc.MoveTo:create(0.2,cc.p(667,700-(k-1)*80)))
		end
	end
end

function AuthorizeSitView:updataInformNode(__params)
	for k,v in pairs(self._informNodeList) do
		if __params.applyUserID == v.ApplyUserID and __params.tableID == v.TableID and __params.gameID == v.GameID then
			GameUtils.removeNode(v)
			table.remove(self._informNodeList,k)
		end
	end
	for k,v in pairs(self._informNodeList) do
		v:runAction(cc.MoveTo:create(0.2,cc.p(667,700-(k-1)*80)))
		-- v:runAction(cc.MoveBy:create(0.2,cc.p(0,40)))
	end
	self._cacheApplySitInformNode[__params.applyUserID] = nil
end

function AuthorizeSitView:onEnter()

end

function AuthorizeSitView:onExit()
	display.removeSpriteFrames(GameResPath.."inform.plist",
							GameResPath.."inform.png")
	self._gameRequest = nil
end

return AuthorizeSitView