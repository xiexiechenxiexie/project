-- 消息基类
-- @date 2017.07.11
-- @author tangwen

local ManagerBase = class("ManagerBase")

function ManagerBase:ctor()
    self.name = "ManagerBase"
end

function ManagerBase:reset()
    self._msgFunc = {}			-- 消息函数表
    self.listeners_ = {}
    self.listenerHandleIndex_ = 0
end

-- 消息注册
function ManagerBase:addEventListener(msgID, eventName, target, listener)
    eventName = string.upper(eventName)
    if self.listeners_[eventName] == nil then
        self.listeners_[eventName] = {}
    end

    self.listeners_[eventName][target] = listener

    local EventData = {msgid = msgID , EnvetName = eventName}
    table.insert(self._msgFunc,EventData)

    if DEBUG > 1 then
        printInfo("[EventDispatcher] addEventListener() - eventName: %s, target: %s, listener: %s", eventName, tostring(target), tostring(listener))
    end        
end

--  消息分发
function ManagerBase:dispatchEvent(eventName, data)
    print("ManagerBase:dispatchEvent ",eventName)
    eventName = string.upper(eventName)
    if self.listeners_[eventName] == nil then return end

   	for target,listener in pairs(self.listeners_[eventName]) do
   		if listener then
	        if DEBUG > 1 then
	            --printInfo("[EventDispatcher] dispatchEvent() - dispatching event %s to listener %s, target: %s", eventName, tostring(listener), tostring(target))
	        end       			
   			listener(target, eventName, data)
   		end
   	end
end

-- 消息监听移除
function ManagerBase:removeEventListener(eventName, target)
    eventName = string.upper(eventName)
    if self.listeners_[eventName] == nil then return end

    for k,v in pairs(self._msgFunc) do
        if eventName == v.EnvetName then 
            table.remove(self._msgFunc,k)
        end
    end

   	for _target,listener in pairs(self.listeners_[eventName]) do
   		if _target == target then
   			self.listeners_[eventName][target] = nil
	        if DEBUG > 1 then
	            print("[EventDispatcher] removeEventListener() - dispatching event %s, target: %s", eventName, tostring(target))
	        end       			
   			break
   		end
   	end
end

-- 消息分发
function ManagerBase:dispatchMsg(msgId,data)
    local isFound = false
    for k,v in pairs(self._msgFunc) do
        if msgId == v.msgid then
          isFound = true 
          self:dispatchEvent(v.EnvetName, data)
        end
    end
    if not isFound then 
      print("ManagerBase:dispatchMsg ",msgId,"消息未处理") 
      local dispatcher = cc.Director:getInstance():getEventDispatcher()
      local event = cc.EventCustom:new(HttpClient.NET_REQUEST_RSP_NOT_HANDLED)
      event.requestUrl = tostring(msgId)
      dispatcher:dispatchEvent(event)  
    end
end

return ManagerBase