-- 任务
-- @date 2017.08.22
-- @author tangwen

local TaskView = class("TaskView", lib.layer.Window)

-- 这里初始化所有滑动界面信息，如有特殊的单独处理
local TASK_SCROLLVIEW_SIZE = cc.size(1060, 520)  -- 滑动界面大小
local TASK_VIEW_POSITION = cc.p(-463, -270)		-- 滑动界面初始化位置
local RECORD_SIZE = cc.size(925,93)   			--滑动界面节点大小 记录节点大小 
local TASK_INTERVAL_V = 117   --每条记录之间的间距 竖 
local TASK_MAX_COL = 1		 -- 列数

function TaskView:ctor(data)
	self._taskData = data
    TaskView.super.ctor(self,ConstantsData.WindowType.WINDOW_BIG)
	self:initView()
end

function TaskView:initView()
    local bg = self._root
    self._bg = bg

    local bgSize = bg:getContentSize()
    local title = ccui.ImageView:create("Lobby_task_title.png", ccui.TextureResType.plistType)
    title:setPosition(bgSize.width/2, bgSize.height - 25)
    bg:addChild(title)

	self._taskScrollView = self:createScrollView(#self._taskData)
	self._taskScrollView:setPosition(25,20)
	bg:addChild(self._taskScrollView,1)

	local contentSize = cc.size(TASK_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (#self._taskData - 1) * TASK_INTERVAL_V + 36)
	if contentSize.height < TASK_SCROLLVIEW_SIZE.height then
		contentSize = TASK_SCROLLVIEW_SIZE
	end

    local offset = cc.p(0, contentSize.height)
    local PosY = 0

    self._TaskList = {}

	for k, v in ipairs(self._taskData) do
        local record= self:createTaskRecord(v)
        local row = k
        local x =40 + offset.x +RECORD_SIZE.width/2 
        local y =50 + offset.y - row * TASK_INTERVAL_V -- 第一个点最高
        record:setPosition(x,y)
        self._taskScrollView:addChild(record)
        table.insert(self._TaskList,record)
    end

    self._NoTaskText = cc.Label:createWithTTF("暂时没有任务哟!",GameUtils.getFontName(),32)
    self._NoTaskText:setPosition(bgSize.width/2, bgSize.height/2)
    bg:addChild(self._NoTaskText)
    self._NoTaskText:hide()

    if #self._taskData == 0 then
        self._NoTaskText:show()
    end

end

-- 创建scrollView界面
function TaskView:createScrollView(rowNum)
	local contentSize = cc.size(TASK_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (rowNum - 1) * TASK_INTERVAL_V + 36)

	local _ScrollView = ccui.ScrollView:create()
    _ScrollView:setTouchEnabled(true)--触摸的属性
    _ScrollView:setBounceEnabled(true)--弹回的属性
    _ScrollView:setInertiaScrollEnabled(true)--滑动的惯性
    _ScrollView:setScrollBarEnabled(false)
    _ScrollView:setDirection(ccui.ScrollViewDir.vertical)
    _ScrollView:setContentSize(TASK_SCROLLVIEW_SIZE)
    _ScrollView:setInnerContainerSize(contentSize)
    _ScrollView:setPosition(TASK_VIEW_POSITION)

    return _ScrollView
end


-- 创建排行榜记录条
function TaskView:createTaskRecord(data)
	if data == nil then
		return
	end

	local taskData = cc.exports.lib.JsonUtil:decode(data.Award)

	local size = cc.size(1000, 93)
	local record = ccui.Layout:create()

   	local bg =  ccui.Scale9Sprite:createWithSpriteFrameName("Lobby_task_record.png",cc.rect(20,20,8,8))
    bg:setContentSize(size)
    bg:setPosition(cc.p(0,0))
    record:addChild(bg)

    record.GameID = data.kind_id
    record.GameType = data.GameType
    record.TaskID = data.TaskId

    local iconBg = ccui.ImageView:create("Lobby_task_record_icon_bg.png", ccui.TextureResType.plistType)
    iconBg:setPosition(cc.p(-size.width/2 + 50,-1))
    record:addChild(iconBg)

    local iconImg = ""
    if taskData[1].PropsId == ConstantsData.PointType.POINT_COINS then  -- 金币 
    	iconImg = "Lobby_sign_recond_icon_2.png"
    elseif taskData[1].PropsId == ConstantsData.PointType.POINT_DIAMOND then --钻石
    	iconImg = "Reward_icon_diamond.png"
    elseif taskData[1].PropsId == ConstantsData.PointType.POINT_ROOMCARD then --房卡
    	iconImg = "Reward_icon_roomcard.png"
    else
    	print("奖励物品格式错误:",taskData[1].PropsId)
    end
    local giftIcon = ccui.ImageView:create(iconImg, ccui.TextureResType.plistType)
    giftIcon:setContentSize(86,82)
    giftIcon:setScale(0.7)
    giftIcon:setPosition(43,41)
    iconBg:addChild(giftIcon)

    local getBtnImg = "Lobby_task_btn_get.png"
    record._getBtn = lib.uidisplay.createUIButton({
        normal = getBtnImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            logic.LobbyManager:getInstance():requestTaskGetAwardData(record.TaskID,function( result )
                if result then
                    local __params = {{type = taskData[1].PropsId, score = taskData[1].number}}
                    GameUtils.showGiftAccount(__params)
                    self:updateScrollView(record)
                    local event = cc.EventCustom:new(config.EventConfig.EVENT_REFRESH_USER_INFO)
                    lib.EventUtils.dispatch(event)
                end
            end)
        end
        })
	record._getBtn:setPosition(size.width/2 - 60, 0)
	record:addChild(record._getBtn)
	record._getBtn:hide()

    local goBtnImg = "Lobby_task_btn_go.png"
    record._goBtn = lib.uidisplay.createUIButton({
        normal = goBtnImg,
        textureType = ccui.TextureResType.plistType,
        isActionEnabled = true,
        callback = function() 
            self:onCloseCallback()           
            local event = cc.EventCustom:new(config.EventConfig.EVENT_TASK_GOTO_GAME_SCENE)
            event.userdata = {
                gameId = data.kind_id,
                gameType = data.GameType
            }
            lib.EventUtils.dispatch(event)
        end
        })
	record._goBtn:setPosition(size.width/2 - 60, 0)
    record:addChild(record._goBtn)
	record._goBtn:hide()

	local taskNameText = cc.Label:createWithTTF(data.TaskName,GameUtils.getFontName(),24)
    taskNameText:setAnchorPoint(cc.p(0, 0.5))
    taskNameText:setPosition(-size.width/2 + 130, 0)
    record:addChild(taskNameText)

    local taskProcessStr = data.process .."/".. data.Count
    record._processText = cc.Label:createWithTTF(taskProcessStr,GameUtils.getFontName(),24)
    record._processText:setPosition(0, 0)
    record:addChild(record._processText)

    local __RichTextList = {{Color3B = cc.c3b(255,255,255), opacity = 255, richText = "奖励:", fontSize = 24},
                        {Color3B = cc.c3b(255,255,0), opacity = 255, richText = taskData[1].number, fontSize = 24},
                    	{Color3B = cc.c3b(255,255,255), opacity = 255, richText = taskData[1].name, fontSize = 22}}

	local _richText = GameUtils.createRichText(__RichTextList)
	_richText:setAnchorPoint(cc.p(0, 0.5))
	_richText:setPosition(140, 0)
	record:addChild(_richText)

    if data.process  >=  data.Count then -- 完成任务
        record._getBtn:show()
        record._goBtn:hide()
        record._processText:hide()
    else
        record._getBtn:hide()
        record._goBtn:show() 
        record._processText:show()     
    end
 
    return record
end

-- 更新ScrollView
function TaskView:updateScrollView(record)
	local index = 0
	for k, v in ipairs(self._taskData) do
		if v.TaskId == record.TaskID then
			index = k
			table.remove(self._taskData,k) 
			table.remove(self._TaskList,k) 
		end
	end
	GameUtils.removeNode(record)


	local contentSize = cc.size(TASK_SCROLLVIEW_SIZE.width, RECORD_SIZE.height + (#self._taskData - 1) * TASK_INTERVAL_V + 36)
	if contentSize.height < TASK_SCROLLVIEW_SIZE.height then
		contentSize = TASK_SCROLLVIEW_SIZE
	end
	self._taskScrollView:setInnerContainerSize(contentSize)

    local offset = cc.p(0, contentSize.height)
    local PosY = 0

	for k, v in ipairs(self._TaskList) do
        local row = k
        local x =40 + offset.x +RECORD_SIZE.width/2
        local y =50 + offset.y - row * TASK_INTERVAL_V -- 第一个点最高
        v:setPosition(x,y)
    end

    if #self._TaskList == 0 then
        self._NoTaskText:show()
    end
end

function TaskView:onEnter( ... )
	TaskView.super.onEnter(self)
end

function TaskView:onExit()

end

return TaskView
