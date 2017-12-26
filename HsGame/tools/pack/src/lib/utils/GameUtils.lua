-- 游戏通用工具   通用弹窗显示以及移除之类
-- @date 2017.07.11
-- @author tangwen

local GameUtils = {}

local msgBox = nil
--[[
@brief 消息弹框
@param params.msg 提示消息
@param params.btns 按钮，table，值为"ok","cancel"
@param params.type 默认为0 ConstantsData.ShowMgsBoxType.NORMAL_TYPE 设置1的时候为大的框
@param params.callback 返回值可选，返回false或nil时点击不关闭弹框，其他情况点击后关闭弹框

默认接收一个msg参数，只显示一个ok按钮，要使用cancel并回调时需要手动传入参数

e.g.
~
         local param = { msg = "桌子已解散", btn = {"ok"}, type = 1, callback = function(event)
            if event == "ok" then
                print("ok")
            end
            return true
        end}
        GameUtils.showMsgBox(param)
~
]]
local msgBox = nil

-- 这里显示  1行 弹窗信息 带确定按钮的。
function GameUtils.showMsgBox(__params)
    local scene = cc.Director:getInstance():getRunningScene()
    if scene == nil then 
        return
    end
    if msgBox ~= nil then
        GameUtils.removeNode(msgBox)
        msgBox = nil
    end



    local msgBoxUI = require "lib/view/MsgBoxUI"
    msgBox = msgBoxUI.new()
    msgBox:setLocalZOrder(999)
    msgBox:setPosition(display.cx, display.cy)

    scene:addChild(msgBox)

    msgBox:showMsgBox(__params)
    
    msgBox:enableNodeEvents()
    msgBox.onEnter = function  ( ... )
        print("msgBox.onEnter")
    end
    msgBox.onExit = function  ( ... )
        print("msgBox.onExit")
        msgBox = nil
    end
    GameUtils.popUpNode(msgBox)
end

function GameUtils.hideMsgBox()
    if msgBox then
        GameUtils.popDownNode(msgBox, function()
            GameUtils.removeNode(msgBox)
            msgBox = nil
        end)
    end
end

-- -- 这里显示的是 2行及2行以上的 弹窗信息 带确定按钮的。
-- function GameUtils.showBigMsgBox( msg, btns, callback)
--     local scene = cc.Director:getInstance():getRunningScene()
--     if not tolua.isnull(bigMsgBox) then
--         GameUtils.removeNode(bigMsgBox)
--         bigMsgBox = nil
--     end

--     local msgBoxUI = require "lib.view.BigMsgBoxUI"
--     bigMsgBox = msgBoxUI.new()
--     bigMsgBox:setLocalZOrder(999)
--     bigMsgBox:setPosition(display.cx, display.cy)

--     scene:addChild(bigMsgBox)

--     bigMsgBox:showMsgBox(msg, btns, callback)

--     GameUtils.popUpNode(bigMsgBox)
-- end

-- function GameUtils.hideBigMsgBox()
--     if bigMsgBox then
--         GameUtils.popDownNode(bigMsgBox, function()
--             GameUtils.removeNode(bigMsgBox)
--             bigMsgBox = nil
--         end)
--     end
-- end


--[[
@brief 显示信息
@param msg 消息 
@param time 时间 默认时间 2s

e.g.
~
GameUtils.showMsg("兑换成功"，2)
~
]]
local msgText = nil
function GameUtils.showMsg(msg, time,__isTouchIgnore)
 
    time = time or 2
    if time < 0 then
        time = 99999999
    end

    local scene = cc.Director:getInstance():getRunningScene()
    if __isTouchIgnore then 
        scene = cc.Director:getInstance():getNotificationNode()
    end
    if scene == nil then 
        return
    end


    if msgText ~= nil then
        GameUtils.removeNode(msgText)
        msgText = nil
    end

    local mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), display.width, display.height)
    mask:setTouchEnabled(true)
    scene:addChild(mask, 999)

    local listener = cc.EventListenerTouchOneByOne:create()
   
    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchMove(touch, event)
    end

    local function onTouchEnd(touch, event)
        GameUtils.hideMsg()
    end

    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)

    listener:setSwallowTouches(true)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, mask)

    local bg = ccui.ImageView:create("common_msg_bg.png", ccui.TextureResType.plistType)
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setPosition(display.cx, display.cy)
    mask:addChild(bg)

    -- local label = cc.Label:createWithTTF("", "Lobby/res/common/fonts/normalFont.otf", 36)
    local label = cc.Label:create()
    label:setSystemFontSize(36)
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setPosition(462, 79)
    label:setColor(cc.c3b(255,255,255))
    label:setString(msg)
    bg:addChild(label)

    msgText = mask
    msgText:enableNodeEvents()
    msgText.onEnter = function  ( ... )
        print("msgText.onEnter")
    end
    msgText.onExit = function  ( ... )
        print("msgText.onExit")
        msgText = nil
    end
    bg:performWithDelay(function()
        GameUtils.hideMsg()
        if callback then
            callback()
        end
    end, time)
end

function GameUtils.hideMsg()
    if msgText then
        msgText:removeFromParent()
        msgText = nil
        print("hideMsg()")
    end
end

--[[
@brief 开始读条
@param msg 消息，默认参数 正在加载,请稍等...
@param time 时间 默认时间 3S
@param callback 回调函数

e.g.
~
GameUtils.startLoading()
GameUtils.startLoading("正在重新连接，请稍后...",20)
~
]]


local loading = nil

function GameUtils.startLoadingForever(msg)
    GameUtils.startLoading(msg,-1,nil)
end

function GameUtils.startLoading( msg, time, callback )
    print("startLoading",msg,time)
    GameUtils.stopLoading()
    msg = msg or "正在加载,请稍等..."
    time = time or 30

    local scene = cc.Director:getInstance():getRunningScene()
    if scene == nil then 
        return
    end
    local mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), display.width, display.height)
    mask:setTouchEnabled(true)
    scene:addChild(mask, 999)

    local listener = cc.EventListenerTouchOneByOne:create()
   
    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchMove(touch, event)
    end

    local function onTouchEnd(touch, event)
    end

    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)

    listener:setSwallowTouches(true)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, mask)


    local bg = ccui.ImageView:create("common_loading_bg.png", ccui.TextureResType.plistType)
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setPosition(display.cx, display.cy)
    mask:addChild(bg)

    local label = cc.Label:createWithTTF("",GameUtils.getFontName(),20)
    label:setAnchorPoint(cc.p(0, 0.5))
    label:setPosition(170, 36.5)
    label:setHorizontalAlignment(kCCTextAlignmentLeft); 
    label:setString(msg)
    bg:addChild(label)

    local loadingUI = require("lib/view/LoadingUI").new()
    loadingUI:setPosition(100,36.5)
    loadingUI:play()
    bg:addChild(loadingUI)


    loading = mask
    loading:enableNodeEvents()
    loading.onEnter = function  ( ... )
        print("loading.onEnter")
    end
    loading.onExit = function  ( ... )
        print("loading.onExit")
        loading = nil
    end
    if time > 0 then
        bg:performWithDelay(function()
            GameUtils.stopLoading()
            if callback then
                callback()
            end
        end, time)
    end

end

function GameUtils.stopLoading()
    if loading then
        loading:removeFromParent()
        loading = nil
        print("stopLoading()")
    end
end

--[[
@brief 开始读条
@param msg 消息，默认参数 正在加载,请稍等...
@param time 时间 默认时间 3S
@param callback 回调函数

e.g.
~
GameUtils.startLoading()
GameUtils.startLoading("正在重新连接，请稍后...",20)
~
]]


local loadingHttp = nil

function GameUtils.startLoadingHttpForever(msg)
    GameUtils.startLoadingHttp(msg,-1,nil)
end

function GameUtils.startLoadingHttp( msg, time, callback )
    print("startLoadingHttp",msg,time)
    GameUtils.stopLoading()
    msg = msg or "正在加载,请稍等..."
    time = time or 30

    local scene = cc.Director:getInstance():getRunningScene()
    if scene == nil then 
        return
    end
    local mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), display.width, display.height)
    mask:setTouchEnabled(true)
    scene:addChild(mask, 999)

    local listener = cc.EventListenerTouchOneByOne:create()
   
    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchMove(touch, event)
    end

    local function onTouchEnd(touch, event)
    end

    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)

    listener:setSwallowTouches(true)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, mask)


    local bg = ccui.ImageView:create("common_loading_bg.png", ccui.TextureResType.plistType)
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setPosition(display.cx, display.cy)
    mask:addChild(bg)

    local label = cc.Label:createWithTTF("",GameUtils.getFontName(),20)
    label:setAnchorPoint(cc.p(0, 0.5))
    label:setPosition(170, 36.5)
    label:setHorizontalAlignment(kCCTextAlignmentLeft); 
    label:setString(msg)
    bg:addChild(label)

    local loadingUI = require("lib/view/LoadingUI").new()
    loadingUI:setPosition(100,36.5)
    loadingUI:play()
    bg:addChild(loadingUI)


    loadingHttp = mask
    loadingHttp:enableNodeEvents()
    loadingHttp.onEnter = function  ( ... )
        print("loadingHttp.onEnter")
    end
    loadingHttp.onExit = function  ( ... )
        print("loadingHttp.onExit")
        loadingHttp = nil
    end
    if time > 0 then
        bg:performWithDelay(function()
            GameUtils.stopLoadingHttp()
            if callback then
                callback()
            end
        end, time)
    end

end

function GameUtils.stopLoadingHttp()
    if loadingHttp then
        loadingHttp:removeFromParent()
        loadingHttp = nil
        print("stopLoading()")
    end
end


--[[
@brief 裁剪区域
@param view 显示的主界面
@param imgNode 底板图片
@param stencilPos 模板位置传入 {cc.p{0,0}，cc.p{33,0}} 传入列表
@param stencilPath 模板路径传入 传入列表
@param stencilTag  模板tag传入 传入列表
@param index 索引号

e.g.
~
local clipNode = GameUtils.exchangeImageToClipNode(self ,colourbg , posList,stencilPathList, ccui.TextureResType.plistType,1)
end)
~
]]
function GameUtils.exchangeImageToClipNode(view, imgNode, stencilPos, stencilPath, stencilTag, TextureResType, index)  
    local clipnode = view:getChildByName("ClipNode"..tostring(index))  
    if clipnode then  
        clipnode:removeFromParent()  
    end  
  
    local clipNodeEx = cc.ClippingNode:create()  
    view:addChild(clipNodeEx) 

    local textureResType = TextureResType or ccui.TextureResType.localType 

    local stencileNode = display.newNode()
    for i= 1,#stencilPath do
        local sprite = ccui.ImageView:create(stencilPath[i],textureResType)
        sprite:setPosition(stencilPos[i])
        sprite:setTag(stencilTag[i])
        stencileNode:addChild(sprite)
    end

    clipNodeEx:addChild(imgNode)   -- 设置底板  需要裁剪的底图
    clipNodeEx:setStencil(stencileNode)   -- 设置模板
    clipNodeEx:setName("ClipNode"..tostring(index))  
    clipNodeEx:setInverted(false)  
    clipNodeEx:setAlphaThreshold(0.5)  
  
    return clipNodeEx  
end 


GameUtils.popStack = {} -- 多层级弹出用栈
GameUtils.popMask = nil
--[[
@brief 由小变大，最后停在display.cx/display.cy屏幕中点，请确保node的坐标系与屏幕保持一致
]]
function GameUtils.popUpNode(node, callback)
    if node then
        -- 创建mask层
        if tolua.isnull(GameUtils.popMask) then
            GameUtils.popMask = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
            GameUtils.popMask:setScale(5.0)
            GameUtils.popMask:setLocalZOrder(-999)
            GameUtils.popMask:retain()
        end

        -- 初始化node
        --node:setPosition(display.cx, 0)
        node:setOpacity(100)
        node:setScale(0)

        -- 把mask层加到弹出的窗口，遮住其他窗口
        GameUtils.popMask:setOpacity(0.0)
        GameUtils.removeNode(GameUtils.popMask)

        node:addChild(GameUtils.popMask)
    
        GameUtils.popMask:setTouchEnabled(true)

        local listener = cc.EventListenerTouchOneByOne:create()
   
        local function onTouchBegan(touch, event)
            return true
        end

        local function onTouchMove(touch, event)
        end

        local function onTouchEnd(touch, event)

        end

        listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)

        listener:setSwallowTouches(true)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, GameUtils.popMask)

        local time = 0.1
        -- 弹出动画
        local actions = {}
        table.insert(actions, CCScaleTo:create(time, 1,1))
        local spawn = cc.Spawn:create({transition.sequence(actions), CCFadeTo:create(time, 255)})
        local callFunc = CCCallFunc:create(function()
            if callback then
                callback()
            end
        end)
        local sequence = transition.sequence({ spawn, callFunc })
        node:runAction(sequence)
        GameUtils.popMask:runAction(CCFadeTo:create(time, 180))


        table.insert(GameUtils.popStack, node)
    end
end

--[[
@brief 对应popUpNode的关闭用方法
]]

function GameUtils.popDownNode(node, callback)
    if node then
        -- 期间锁定屏幕

        local time = 0.1
        GameUtils.removeNode(GameUtils.popMask)

        local spawn = cc.Spawn:create({ CCScaleTo:create(time, 0,0), CCFadeTo:create(time, 0) })
        local callFunc = CCCallFunc:create(function()
            if callback then
                callback()
            end
        end)
        local sequence = transition.sequence({ spawn, callFunc })
        node:runAction(sequence)

        -- 如果是多层级弹出，mask加回到上一层
        table.remove(GameUtils.popStack)
        while #GameUtils.popStack>0 do
            local pre_node = GameUtils.popStack[#GameUtils.popStack]

            if not tolua.isnull(pre_node) then
                pre_node:addChild(GameUtils.popMask)
                GameUtils.popMask:stopAllActions()
                GameUtils.popMask:setOpacity(100)
                break
            else
                table.remove(GameUtils.popStack)
            end
        end
    end
end

--[[
把一个node从父节点移除
]]
function GameUtils.removeNode(node)
    local parent = node:getParent()
    if parent then
        parent:removeChild(node)
        node = nil
    end

    return nil
end

--[[
游戏的默认字体
]]
function GameUtils.getFontName()
    return "src/preload/res/fonts/normalFont.ttf"
end

function GameUtils:findBoldFontName( ... )
    return "src/preload/res/fonts/normalFont.ttf"
end

-- table深拷贝
function GameUtils.copyTable(st)
    if not st then
        return nil
    end

    local tab = {}
    for k,v in pairs(st) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = table.copy(v)
        end
    end
    return tab
end

-- 生成一个新的 ByteArray
function GameUtils.createByteArray(data)
    local byteArray =  cc.hsGameUtils.ByteArray:new("ENDIAN_BIG")
    byteArray:writeBuf(data)
    byteArray:setPos(1)
    return byteArray
end

function GameUtils.split(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
		if not nFindLastIndex then  
			nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
			break  
		end  
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
		nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
		nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end 

--[[
@brief 创建富文本
@param __RichTextList

example
~
local __RichTextList = {{Color3B = cc.c3b(255,0,0), opacity = 255, richText = "这是案例", fontSize = 24},
                        {Color3B = cc.c3b(255,255,0), opacity = 255, richText = "，案例的结果", fontSize = 24}}

local _richText = GameUtils.createRichText(__RichTextList)
_richText:setPosition(display.cx, display.cy)
_richText:setSize( cc.size(600,250));  
self:addChild(_richText)


_richText:pushBackElement(label); --在元素末尾加入数据
_richText:insertElement(label, 1); --在指定位置加入数据  如有特殊需求则自行获取
~
]]

 
function GameUtils.createRichText(__RichTextList)
    local _richText = ccui.RichText:create();
    for k,v in pairs(__RichTextList) do
        local label = ccui.RichElementText:create(1, v.Color3B, v.opacity, v.richText, GameUtils.getFontName(), v.fontSize); 
        _richText:pushBackElement(label);
    end
    return _richText
end


--[[
@brief 创建获得界面
@param __params

例子：

    local __params = {{type = taskData[1].PropsId, score = taskData[1].number}}
    GameUtils.showGiftAccount(__params)

]]

local giftAccountView = nil
function GameUtils.showGiftAccount(__params)
    local scene = cc.Director:getInstance():getRunningScene()
    if scene == nil then 
        return
    end


    if giftAccountView ~= nil then
        GameUtils.removeNode(giftAccountView)
        giftAccountView = nil
    end

    local event = cc.EventCustom:new(config.EventConfig.EVENT_SOUND_PLAY)
    event.userdata = {soundId = "Lobby/res/music/getcoin.mp3"}
    lib.EventUtils.dispatch(event) 

    local giftAccountUI = require "lib/view/GiftAccountView"
    giftAccountView = giftAccountUI.new(__params)
    giftAccountView:setLocalZOrder(999)
    giftAccountView:setPosition(display.cx, display.cy)
    scene:addChild(giftAccountView)

    giftAccountView:enableNodeEvents()
    giftAccountView.onEnter = function  ( ... )
        print("giftAccountView.onEnter")
    end
    giftAccountView.onExit = function  ( ... )
        print("giftAccountView.onEnter")
        giftAccountView = nil
    end
end

function GameUtils.hideGiftAccount()
    if giftAccountView then
        giftAccountView:removeFromParent()
        giftAccountView = nil
    end
end

-- 小数取整
function GameUtils.getIntPart( float )
    if float <= 0 then
        return math.ceil(float)
    end
    if math.ceil(float) == float then
        float = math.ceil(float)
    else
        float = math.ceil(float)-1
    end
    return float
end

--将数字改成以万，亿为单位
function GameUtils.createSwitchNumNode(num)
    local numNode = ccui.TextAtlas:create("","common/common_score_num.png",14,24,".")
    local SCORE_IMG_TAG = 10
    if num == nil or type(num)~="number" then  
        print("将数字改成以万，亿为单位，参数错误")  
        return 
    else  
        if num / 10^8 >= 1 then  
            num = math.floor(num / 10^6)  
            numNode:setString(string.format("%.2f", num/10^2))
            local size = numNode:getContentSize()
            local scoreImg = ccui.ImageView:create("common_score_yi.png", ccui.TextureResType.plistType)
            local imgSize = scoreImg:getContentSize()
            scoreImg:setTag(SCORE_IMG_TAG)
            scoreImg:setPosition(size.width + imgSize.width/2,size.height/2)
            numNode:addChild(scoreImg)
        elseif num / 10^4 >= 1 then  
            num = math.floor(num / 10^2)  
            numNode:setString(string.format("%.2f", num/10^2))
            local size = numNode:getContentSize()
            local scoreImg = ccui.ImageView:create("common_score_wan.png", ccui.TextureResType.plistType)
            scoreImg:setTag(SCORE_IMG_TAG)
            local imgSize = scoreImg:getContentSize()
            scoreImg:setPosition(size.width + imgSize.width/2,size.height/2)
            numNode:addChild(scoreImg)
        else  
            numNode:setString(tostring(num))
        end
        return numNode  
    end 
end

function GameUtils.updateSwitchNumNode(__Node, num)
    if __Node == nil then 
        return
    end

    local SCORE_IMG_TAG = 10
    if num == nil or type(num)~="number" then  
        print("将数字改成以万，亿为单位，参数错误")  
        return 
    else  
        if num / 10^8 >= 1 then  
            num = math.floor(num / 10^6)  
            __Node:setString(string.format("%.2f", num/10^2))
            local size = __Node:getContentSize()
            local scoreImg = __Node:getChildByTag(SCORE_IMG_TAG)
            if scoreImg == nil then 
                scoreImg = ccui.ImageView:create("common_score_yi.png", ccui.TextureResType.plistType)
                scoreImg:setTag(SCORE_IMG_TAG)
                __Node:addChild(scoreImg)
            end
            local imgSize = scoreImg:getContentSize()
            scoreImg:loadTexture("common_score_yi.png", ccui.TextureResType.plistType)
            scoreImg:setPosition(size.width + imgSize.width/2,size.height/2)
            scoreImg:show()
        elseif num / 10^4 >= 1 then  
            num = math.floor(num / 10^2)  
            __Node:setString(string.format("%.2f", num/10^2))
            local size = __Node:getContentSize()
            local scoreImg = __Node:getChildByTag(SCORE_IMG_TAG)
            if scoreImg == nil then 
                scoreImg = ccui.ImageView:create("common_score_wan.png", ccui.TextureResType.plistType)
                scoreImg:setTag(SCORE_IMG_TAG)
                __Node:addChild(scoreImg)
            end
            local imgSize = scoreImg:getContentSize()
            scoreImg:loadTexture("common_score_wan.png", ccui.TextureResType.plistType)
            scoreImg:setPosition(size.width + imgSize.width/2,size.height/2)
            scoreImg:show()
        else  
            __Node:setString(tostring(num))
            local scoreImg = __Node:getChildByTag(SCORE_IMG_TAG)
            if scoreImg then 
                scoreImg:hide()
            end
        end
    end 
end

-- 格式化商城金币数量
function GameUtils.formatMoneyNumber( money )
    local count = 0
    local strTmp = ""
    for i=string.len(money), 1, -1 do
        if 0 == count % 3 and 0 ~= count then
           strTmp = string.sub(money, i, i) .. "." .. strTmp
        else
           strTmp = string.sub(money, i, i) .. strTmp
        end
        count = count + 1
    end
    return strTmp
end


GameUtils.COMEOUT_BOTTON = 1
GameUtils.COMEOUT_TOP = 2
GameUtils.COMEOUT_LEFT = 3
GameUtils.COMEOUT_RIGHT = 4
local offsetInitFun = function ( __orgX,__orgY,__size,__comeOutType)
    local offsetX = 0
    local offsetY = 0
    if GameUtils.COMEOUT_BOTTON == __comeOutType then
        offsetX = __orgX
        offsetY = __orgY - __size.height
    elseif  GameUtils.COMEOUT_TOP == __comeOutType then
        offsetX = __orgX
        offsetY = __orgY + __size.height
    elseif  GameUtils.COMEOUT_LEFT == __comeOutType then
        offsetX = __orgX - __size.width
        offsetY = __orgY 
    elseif  GameUtils.COMEOUT_RIGHT == __comeOutType then  
        offsetX = __orgX + __size.width
        offsetY = __orgY
    end
    return offsetX,offsetY
end
function GameUtils.comeOutEffectSlower( __targetNode,__duration,__size,__comeOutType,__func)
    local orgX = __targetNode:getPositionX()
    local orgY = __targetNode:getPositionY()
    local offsetX,offsetY = offsetInitFun(orgX,orgY,__size,__comeOutType)
    __targetNode:setPosition(offsetX,offsetY)
    local act = cc.Sequence:create(cc.MoveTo:create(__duration,cc.p(orgX,orgY)),cc.CallFunc:create(function ( ... )
        if __func then __func() end
    end))
    local action = cc.EaseExponentialOut:create(act)
    __targetNode:runAction(action)
    
end

function GameUtils.comeOutEffectElastic( __targetNode,__duration,__size,__comeOutType )
    local orgX = __targetNode:getPositionX()
    local orgY = __targetNode:getPositionY()
    local offsetX,offsetY = offsetInitFun(orgX,orgY,__size,__comeOutType)
    __targetNode:setPosition(offsetX,offsetY)
    
    local act = cc.Sequence:create(cc.MoveTo:create(__duration,cc.p(orgX,orgY)),cc.CallFunc:create(function ( ... )
        if __func then __func() end
    end))
    local action = cc.EaseBounceOut:create(act)
    __targetNode:runAction(action)
     if __func then __func() end
end

-- 截取名字长度
function GameUtils.FormotGameNickName(__NickName,__Len)
    if __NickName == nil then
        return ""
    end
    local lengthUTF_8 = #(string.gsub(__NickName, "[\128-\191]", ""))
    if lengthUTF_8 <= __Len then
        return __NickName
    else
        local matchStr = "^"
        for var=1, __Len do
            matchStr = matchStr..".[\128-\191]*"
        end
        local str = string.match(__NickName, matchStr)
        return string.format("%s...",str);
    end
end

function GameUtils.getDefalutHeadFileByGender( __index )
    local Gender = __index or 0
    local GenderStr = "res/Avatar/default_unkonw.png"
    if Gender == ConstantsData.SexType.SEX_MAN then 
        GenderStr = "res/Avatar/default_man.png"
    elseif Gender == ConstantsData.SexType.SEX_WOMEN then
        GenderStr = "res/Avatar/default_girl.png"
    elseif Gender == ConstantsData.SexType.SEX_UNKNOW then
        GenderStr = "res/Avatar/default_unkonw.png"
    end
    return GenderStr
end

function GameUtils.getInfoBigHeadFileByGender( __index )
    local Gender = __index or 0
    local GenderStr = "res/Avatar/default_unkonw_225.png"
    if Gender == ConstantsData.SexType.SEX_MAN then 
        GenderStr = "res/Avatar/default_man_225.png"
    elseif Gender == ConstantsData.SexType.SEX_WOMEN then
        GenderStr = "res/Avatar/default_girl_225.png"
    elseif Gender == ConstantsData.SexType.SEX_UNKNOW then
        GenderStr = "res/Avatar/default_unkonw_225.png"
    end
    return GenderStr
end



--全局toast函数(ios/android端调用)
cc.exports.g_NativeToast = function(msg)
    GameUtils.showMsg(msg)
end

--全局toast函数(ios/android端调用)
cc.exports.g_NativeLoading = function(msg)
    GameUtils.startLoadingForever(msg)
end

cc.exports.g_NativeLoading = function(msg)
    GameUtils.stopLoading()
end

cc.exports.g_NativePayResultVerify = function(msg)
    -- print("xiaxb", "ipaynow: ordercode:" .. Mall.MallManager:getInstance()._orderCode)
    -- MallManager:payResultVerify(self._orderCode)
    Mall.MallManager:getInstance():payResultVerify(Mall.MallManager:getInstance()._orderCode)
end


cc.exports.GameUtils = GameUtils
