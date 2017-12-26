--[[
    名称  :   BaseDialog  弹窗基类
    作者  :   Xiaxb    edit by fly
    描述  :   BaseDialog 	弹窗基类
    时间  :   2017-8-10
--]]
local BaseDialog =  class("BaseDialog", lib.layer.BaseWindow)
BaseDialog._root = nil
function BaseDialog:ctor( ... )
	-- body
	BaseDialog.super.ctor(self)
end


cc.exports.lib.layer.BaseDialog = BaseDialog