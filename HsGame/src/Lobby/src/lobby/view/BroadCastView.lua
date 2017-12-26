--[[
    名称  :   BroadCastView  广播
    作者  :   Afarways   
    描述  :   BroadCastView 	系统广播
    时间  :   2017-09-20
--]]
local BroadCastResPath = "GameLayout/BroadCast/"

local headFile = require "Lobby/src/header/headFile.lua"


local BroadCastResponse = class("BroadCastResponse",net.ResponseBase)
BroadCastResponse.msgType = 0
BroadCastResponse.length = 0
BroadCastResponse.text = ""
function BroadCastResponse:ctor( __params)
	BroadCastResponse.super.ctor(self,__params)
	self.msgType = 0
	self.length = 0
	self.text = ""
end


function BroadCastResponse:readContent(  )
	BroadCastResponse.super.readContent(self)
	self.msgType = self._byteArray:readUInt()
	
    local length = self._byteArray:readShort()
	self.text = self._byteArray:readString(length) --广播内容
end


local BroadCastView = class("BroadCastView", cc.Node)
--当前场景类型
local CURRENT_SCENE_TYPE = {
    HALL = 0, --大厅
    GAME = 1, --游戏场景
}

--index 区分是否有返回按钮的情况 0 大厅 1游戏
function BroadCastView:ctor(index)
	self:_preLoadRes()
    

    self:_initData()
    self:_initView()
    self:_playTextAnimation()

    local function onNodeEvent(event)
        if "enter" == event then
            self:onEnter()           
        elseif "exit" == event then
            self:onExit()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function BroadCastView:onEnter()
    self:addEventListerns()
end

function BroadCastView:onExit()
    self:removeEventListeners()
end


--设置广播文本
function BroadCastView:setBroadCasrText(params)
    params = checktable(params)
    --新来的广播插入到队列首位置
    --播放过后的从队列末尾删除
    if params.text then
        table.insert(self._textTable,1,params.text)
        self:_playTextAnimation()
    end

end

--初始化数据
function BroadCastView:_initData(index)
    self._broadCastIndex = index or CURRENT_SCENE_TYPE.GAME --记录当前广播类型
    self._textTable = {
    --"Blue sky and the wind in my hair蓝天下微风拂起我的发White clouds and the sunlight is here again能再见到阳光白云真好Take my hand, hey, where have you been抓住我的手，嘿，你上哪去了"
    }
end

--加载资源
function BroadCastView:_preLoadRes()
	self._frameCache = cc.SpriteFrameCache:getInstance() 
    self._frameCache:addSpriteFrames(BroadCastResPath .."broadcast.plist",
							BroadCastResPath .."broadcast.png")
end

--初始化界面UI
function BroadCastView:_initView()
    self._rootNode = cc.Node:create()
    self:addChild(self._rootNode)

    if self._broadCastIndex == CURRENT_SCENE_TYPE.HALL then
        self:_initViewHall()
    else
        self:_initViewGame()
    end
    
    self._rootNode:setVisible(false)
end

--初始化大厅广播UI
function BroadCastView:_initViewHall()   
    self._rootNode:setPosition(cc.p(860,700))
    self._bgSprite = cc.Sprite:createWithSpriteFrameName("bg_hall.png")
    self._rootNode:addChild(self._bgSprite)

    self._bgWidth = self._bgSprite:getContentSize().width

    self._bgSprite:setPosition(cc.p(self._bgWidth/2,0))

    self._broadSprite = cc.Sprite:createWithSpriteFrameName("broadcast1.png")
    self._rootNode:addChild(self._broadSprite)
    self._broadSprite:setPosition(cc.p(-35,0))

    local clipNode = cc.ClippingNode:create()
    self._rootNode:addChild(clipNode)
    clipNode:setInverted(false)
    clipNode:setAlphaThreshold(0.1)
    clipNode:setStencil(cc.Sprite:createWithSpriteFrameName("bg_hall.png"))
    clipNode:setPosition(cc.p(self._bgWidth/2,0))

    self:_createTextNode(clipNode)
end

--初始化游戏广播UI
function BroadCastView:_initViewGame()
    self._rootNode:setPosition(cc.p(670,700))

    self._bgSprite = cc.Sprite:createWithSpriteFrameName("bg_game.png")
    self._rootNode:addChild(self._bgSprite)

    self._bgWidth = self._bgSprite:getContentSize().width
    
    local clipNode = cc.ClippingNode:create()
    self._rootNode:addChild(clipNode)
    clipNode:setInverted(false)
    clipNode:setAlphaThreshold(0)
    clipNode:setStencil(cc.Sprite:createWithSpriteFrameName("bg_game.png"))
    clipNode:setPosition(cc.p(0,0))

    self:_createTextNode(clipNode)
end

--创建文本节点
function BroadCastView:_createTextNode(clipNode)
    self._textNode = cc.Node:create()
    clipNode:addChild(self._textNode)
    self._textNode:setPosition(cc.p(self._bgWidth/2+10,0))

    self._textBroad1 = cc.Label:createWithTTF("【系统广播】",GameUtils.getFontName(),28)
    self._textBroad1:setColor(cc.c3b(255,0,255))
    self._textBroad1:setAnchorPoint(cc.p(0,0.5))
    self._textNode:addChild(self._textBroad1)

    self._textBroad2 = cc.Label:createWithTTF("",GameUtils.getFontName(),28)
    self._textBroad2:setPositionX(self._textBroad1:getContentSize().width)
    self._textBroad2:setAnchorPoint(cc.p(0,0.5))
    self._textNode:addChild(self._textBroad2)
end

--播放广播动画
function BroadCastView:_playBroadAnimation()
    local animation = cc.Animation:create()
    for i=1,4 do  
        local frameName =string.format("broadcast%d.png",i)                                                          
        local spriteFrame = self._frameCache:getSpriteFrame(frameName)
        animation:addSpriteFrame(spriteFrame)                                                                  
    end
    animation:setDelayPerUnit(0.5) 
    animation:setRestoreOriginalFrame(true)

    local action =  cc.Animate:create(animation)                                                          
    self._broadSprite:runAction(cc.RepeatForever:create(action))       
end

--播放跑马灯动画
function BroadCastView:_playTextAnimation()
    if #self._textTable == 0 or self._isPlaying == true then
        if self._broadCastIndex == CURRENT_SCENE_TYPE.HALL then
            self._broadSprite:stopAllActions()
        end
        self._rootNode:setVisible(false)
        return
    end
    
    --播放喇叭动画
    if self._broadCastIndex == CURRENT_SCENE_TYPE.HALL then
        self:_playBroadAnimation()
    end

    self._textBroad2:setString(self._textTable[#self._textTable]) 
    table.remove(self._textTable,#self._textTable)
    self._isPlaying = true 

    local distance = self._textBroad1:getContentSize().width + self._textBroad2:getContentSize().width + self._textBroad1:getPositionX()
    local aimPosX = -(self._textBroad1:getContentSize().width + self._textBroad2:getContentSize().width) - self._bgWidth/2

    local moveAction = cc.MoveTo:create(distance/100,cc.p(aimPosX,0))
    local funCallBack = cc.CallFunc:create(
        function ()
            self._isPlaying = false
            self._textNode:setPosition(cc.p(self._bgWidth/2+10,0))            
            self:_playTextAnimation()         
        end)

    self._textNode:runAction(cc.Sequence:create(moveAction,funCallBack)) 

    self._rootNode:setVisible(true)
end

--事件相关
function BroadCastView:addEventListerns()
	local listeners = self:onListersInitCallback()
	if listeners then
		lib.EventUtils.registeAllListeners(self,listeners)
	end
end

function BroadCastView:removeEventListeners( ... )
	lib.EventUtils.removeAllListeners(self)
end

function BroadCastView:onListersInitCallback( ... )
	local listeners = {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_SYSTEN_BROADCAST_MSG,handler(self,self.onReceiveMessage)),
	}
    net.SocketClient:getInstance():registeRspClazz(headFile.S2C_EnumKeyAction.S2C_SEND_BORADCAST,BroadCastResponse,config.EventConfig.EVENT_SYSTEN_BROADCAST_MSG)
	return listeners
end

function BroadCastView:onReceiveMessage(__event)
	print("BroadCastView:BroadCastResp")
	if not __event then return end
	local broadCastRsp = __event.packet
	if broadCastRsp then 
        self:setBroadCasrText(broadCastRsp)
	end
end

return BroadCastView