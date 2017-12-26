--[[
    名称  :   TouchPoint  商城左侧菜单
    作者  :   Xiaxb   
    描述  :   TouchPoint 	商城的左侧菜单层
    时间  :   2017-8-07
--]]

local TouchPoint = class("TouchPoint", cc.Node)

function TouchPoint:ctor( ... )
	print("xiaxb", "TouchPoint:ctor")
	-- MallMenuView.super.ctor(self)
	self:_initView()
end

function TouchPoint:_initView( __parentNode )
end

-- 菜单按钮点击事件回掉
function TouchPoint:_btnMenuTouchListener(tag)
end


return MallMenuView