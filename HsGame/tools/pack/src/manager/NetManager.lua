--[[--
@author 负责处理网络错误异常
]]

local NetManager = class("NetManager")

function NetManager:ctor( ... )
	print("NetManager:ctor")
	self:addEventListeners()
end

function NetManager:addEventListeners( ... )
	print("NetManager:addEventListeners")
	local listeners = {
		lib.EventUtils.createEventCustomListener(HttpClient.NET_REQUEST_TIME_OUT,handler(self,self.onTomeOutError)),
		lib.EventUtils.createEventCustomListener(HttpClient.NET_REQUEST_RSP_ERROR,handler(self,self.onRspError)),
		lib.EventUtils.createEventCustomListener(HttpClient.NET_REQUEST_RSP_NOT_HANDLED,handler(self,self.onRspNotHandled)),
		lib.EventUtils.createEventCustomListener(HttpClient.EVENT_NO_INTERACTION,handler(self,self.onNoInterAction)),
		lib.EventUtils.createEventCustomListener(HttpClient.EVENT_ALLOW_INTERACTION,handler(self,self.onAllowInterAction)),
	}
	lib.EventUtils.registeAllListeners(self,listeners)
end

function NetManager:removeListeners( ... )
	print("NetManager:removeListeners")
	lib.EventUtils.removeAllListeners(self)
end

function NetManager:onTomeOutError(__event )
	print("NetManager:onTomeOutError")
    GameUtils.showMsg(self:findTimeOutString() ,2)
end

function NetManager:onRspError( __event )
	print("NetManager:onRspError")
	-- GameUtils.showMsg(self:findNetErrorString().. ":"..__event.requestUrl,10)
end
--[[--
		--播放等待动画
        local event = cc.EventCustom:new(config.EventConfig.EVENT_NO_INTERACTION)
        event.msg = "正在处理请稍后"  --自定义 可以不传
        event.time = 30   --自定义 可以不传
        event.callbakc = xxx --自定义 可以不传
        lib.EventUtils.dispatch(event)
		--取消等待动画
        local event = cc.EventCustom:new(config.EventConfig.EVENT_ALLOW_INTERACTION)
        lib.EventUtils.dispatch(event)
]]
function NetManager:onRspNotHandled( __event )
	print("NetManager:onRspNotHandled")
	print("消息未处理:",__event.requestUrl)
	--GameUtils.showMsg(self:findNetRspNotHandled().. ":"..__event.requestUrl,10)
end

function NetManager:onNoInterAction( __event )
	print("NetManager:onNoInterAction",__event.url)
	local time = __event.time or 30
	local msg = __event.msg or self:findNetProcessingString()
	local callback = __event.callback or nil
	GameUtils.startLoadingHttp(msg ,time,callback)
end

function NetManager:onAllowInterAction( __event )
	print("NetManager:onAllowInterAction")
	GameUtils.stopLoadingHttp()
end
function NetManager:onDestory( ... )
	print("NetManager:onDestory")
	self:removeListeners()
end

function NetManager:findNetProcessingString( ... )
	return "正在处理请稍后!!!"
end

function NetManager:findTimeOutString( ... )
	return "服务器响应超时!!!请稍后重试"
end

function NetManager:findNetErrorString( ... )
	return "服务器响应错误,json无法解析"
end

function NetManager:findNetRspNotHandled( ... )
	return "服务器响应没做处理"
end

lib.singleInstance:bind(NetManager)
cc.exports.manager.NetManager = NetManager
NetManager:getInstance()
return NetManager