--
-- author fly
--
--unicode编码
-- require("json")
-- local bit = require("bit")

-- --[[--
-- 字符串unicode to utf-8
-- ]]
-- local function unicode_to_utf8(convertStr)
--     if type(convertStr)~="string" then
--         return convertStr
--     end

--     local resultStr=""
--     local i=1
--     while true do
--         local num1=string.byte(convertStr,i)
--         local unicode
--         if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
--             unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5))
--             i=i+6
--         elseif num1~=nil then
--             unicode=num1
--             i=i+1
--         else
--             break
--         end

--         ----print(unicode)

--         if unicode <= 0x007f then
--             resultStr=resultStr..string.char(bit.band(unicode,0x7f))
--         elseif unicode >= 0x0080 and unicode <= 0x07ff then
--             resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
--             resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
--         elseif unicode >= 0x0800 and unicode <= 0xffff then
--             resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
--             resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
--             resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
--         end
--     end

--     resultStr=resultStr..'\0'
--     ----print(resultStr)
--     return resultStr
-- end


-- local function utf8_to_unicode(convertStr)

--     if type(convertStr)~="string" then
--         return convertStr
--     end
--     local resultStr=""
--     local i=1
--     local num1=string.byte(convertStr,i)
--     while num1~=nil do
--         ----print(num1)
--         local tempVar1,tempVar2
--         if num1 >= 0x00 and num1 <= 0x7f then
--             tempVar1=num1
--             tempVar2=0
--         elseif bit.band(num1,0xe0)== 0xc0 then
--             local t1 = 0
--             local t2 = 0
--             t1 = bit.band(num1,bit.rshift(0xff,3))
--             i=i+1
--             num1=string.byte(convertStr,i)
--             t2 = bit.band(num1,bit.rshift(0xff,2))
--             tempVar1=bit.bor(t2,bit.lshift(bit.band(t1,bit.rshift(0xff,6)),6))
--             tempVar2=bit.rshift(t1,2)
--         elseif bit.band(num1,0xf0)== 0xe0 then
--             local t1 = 0
--             local t2 = 0
--             local t3 = 0
--             t1 = bit.band(num1,bit.rshift(0xff,3))
--             i=i+1
--             num1=string.byte(convertStr,i)
--             t2 = bit.band(num1,bit.rshift(0xff,2))
--             i=i+1
--             num1=string.byte(convertStr,i)
--             t3 = bit.band(num1,bit.rshift(0xff,2))
--             tempVar1=bit.bor(bit.lshift(bit.band(t2,bit.rshift(0xff,6)),6),t3)
--             tempVar2=bit.bor(bit.lshift(t1,4),bit.rshift(t2,2))
--         end
--         resultStr=resultStr..string.format("\\u%02x%02x",tempVar2,tempVar1)
--         ----print(resultStr)
--         i=i+1
--         num1=string.byte(convertStr,i)
--     end
--     ----print(resultStr)
--     return resultStr
-- end


local function urlEncode(s)  
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)  
    return string.gsub(s, " ", "+")  
end  
  
local function urlDecode(s)  
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)  
    return s  
end  


local HttpClient = class("HttpClient")
local _instance = nil

HttpClient.MachineCode = VIRTUAL_MACHINECODE        --设备硬件码（硬件唯一标示）

HttpClient.NET_REQUEST_TIME_OUT = "NET_REQUEST_TIME_OUT"
HttpClient.NET_REQUEST_RSP_ERROR = "NET_REQUEST_RSP_ERROR"
HttpClient.NET_REQUEST_RSP_NOT_HANDLED = "NET_REQUEST_RSP_NOT_HANDLED"
HttpClient.EVENT_NO_INTERACTION = "EVENT_NO_INTERACTION"
HttpClient.EVENT_ALLOW_INTERACTION = "EVENT_ALLOW_INTERACTION"
HttpClient._deviceModel = nil
function HttpClient:ctor( ... )
    self._deviceModel = nil
end
function HttpClient:getInstance()
    if not _instance then
        _instance = self
    end
    return _instance
end

--创建xmlhttprequest
function HttpClient:_createXmlRequest( __xmlRequestRspType )
	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = __xmlRequestRspType
    xhr.timeout = 30000
    xhr.withCredentials = true
    return xhr
end

--请求回调函数处理   response = {status:xxx,message:xxx,data:xxx}
function HttpClient:_onReadyStateChanged( __xhr,__callback )
	local _xhr = __xhr
    local _cb = __callback
    if _xhr.readyState == 4 and (_xhr.status >= 200 and _xhr.status < 207) then
        print("__xhr.requestUrl",__xhr.requestUrl,"_xhr.response begin " .. _xhr.response .. "----- end")
        -- local headers = _xhr:getResponseHeader("Date")
        -- print(headers)
        local brIndex ,value = string.find(_xhr.response,"<br",1 ,true)
        -- print("brIndex ,value:",brIndex ,value)
        if not brIndex or brIndex <  0 then
            local jsonObj = cc.exports.lib.JsonUtil:decode(_xhr.response) 
            ----print("jsonObj.origin".. jsonObj.origin)
            if _cb ~= nil then 
                _cb(nil,jsonObj)
                local dispatcher = cc.Director:getInstance():getEventDispatcher()
                local event = cc.EventCustom:new(HttpClient.EVENT_ALLOW_INTERACTION)
                dispatcher:dispatchEvent(event)  
                _xhr:unregisterScriptHandler()
            else
                local dispatcher = cc.Director:getInstance():getEventDispatcher()
                local event = cc.EventCustom:new(HttpClient.NET_REQUEST_RSP_NOT_HANDLED)
                event.requestUrl = _xhr.requestUrl
                dispatcher:dispatchEvent(event)  
            end
        else
            reportMsgToServer(_xhr.response)
            if _cb then _cb({status = _xhr.status,msg = "服务器响应错误"} ,nil) end
            local dispatcher = cc.Director:getInstance():getEventDispatcher()
            local event = cc.EventCustom:new(HttpClient.NET_REQUEST_RSP_ERROR)
            event.requestUrl = _xhr.requestUrl
            dispatcher:dispatchEvent(event)  
            print("服务器响应错误")
        end
    elseif _xhr.status == 408  then
            if _cb then _cb({status = _xhr.status,msg = "响应超时"}  ,nil) end
            local dispatcher = cc.Director:getInstance():getEventDispatcher()
            local event = cc.EventCustom:new(HttpClient.NET_REQUEST_TIME_OUT)
            event.requestUrl = _xhr.requestUrl
            dispatcher:dispatchEvent(event)
    elseif _xhr.status == 9000  then
            local function callback(event)
                if "ok" == event then
                    LoginManager:enterLogin()
                end
            end
            local parm = {type = ConstantsData.ShowMgsBoxType.NORMAL_TYPE, msg = "token异常，请重新登录", btn = {"ok"}, callback = callback}
            GameUtils.showMsgBox(parm)
    else
        --print("_xhr.readyState is:", _xhr.readyState, "__xhr.status is: ",_xhr.status)
        if _cb then 
            _cb({status = _xhr.status,msg = "request failed"},nil)
        end
    end


end



--[[--

HttpClient:getInstance():get("http://httpbin.org/get",
    --__error : {status：xxx ,message :xxx}网络错误
    --__response : {status:xxx,message:xxx,data:xxx} status 错误码 message 错误消息  data正常包内容
    function (__error, __response )  
        --print("LogoSce ctor resp get >>> " .. tostring(__response))
    end
)
为了能够连续发包这里的闭包，目的是执行临时参数拷贝  保证收发一对一
__urlParam 请求url
__cbParam 回调函数
__forceNoInteraction true 弹出网络交互动画 禁止玩家操作  不传或者false 不会播放动画
]]
function HttpClient:get( __urlParam ,__cbParam,__forceNoInteraction,__jsonParam)
    print("HttpClient:get >>> " .. __urlParam,__cbParam)
	local executeFunc = function (__url,__json,__cb)
        local xhr = self:_createXmlRequest(cc.XMLHTTPREQUEST_RESPONSE_STRING)
        xhr.requestUrl = __urlParam
        xhr:open("GET", __url,true)
        xhr:registerScriptHandler(function (  )
            self:_onReadyStateChanged(xhr,__cb)
        end)

        local _strParam = nil
        self:initExtendHead(xhr)
        if  __json then 
            -- _strParam = cc.exports.lib.JsonUtil:encode(__json)
            _strParam = cc.exports.lib.JsonUtil:decodeform(__json)
        end
        self:initExtendHead(xhr)
        if _strParam then 
            xhr:send(_strParam)
        else
            xhr:send()
        end

    end

    if __forceNoInteraction  then
        local dispatcher = cc.Director:getInstance():getEventDispatcher()
        local event = cc.EventCustom:new(HttpClient.EVENT_NO_INTERACTION)
        event.url = __urlParam
        dispatcher:dispatchEvent(event)  
    end
    executeFunc( __urlParam,__jsonParam,__cbParam)
end

--[[--
local param = {username="LegendX",password = "123456"}
  HttpClient:getInstance():post("http://192.168.1.213:8081/api/v1/user/register",param,
    --__error : {status：xxx ,message :xxx}网络错误
    --__response : {status:xxx,message:xxx,data:xxx} status 错误码 message 错误消息  data正常包内容
    function (__error, __response )
        --print("LogoSce ctor resp post >>> " .. __response.status)
    end
)
为了能够连续发包这里的闭包，目的是执行临时参数拷贝  保证收发一对一
__urlParam 请求url
__cbParam 回调函数
__forceNoInteraction true 弹出网络交互动画 禁止玩家操作  不传或者false 不会播放动画
]]
function HttpClient:post( __urlParam,__jsonParam ,__cbParam,__forceNoInteraction)
    --print("HttpClient:post >>> " .. __urlParam)
	local executeFunc = function (__url,__json ,__cb)
        local xhr = self:_createXmlRequest(cc.XMLHTTPREQUEST_RESPONSE_JSON)
        xhr.requestUrl = __urlParam
        xhr:open("POST",__url,true)
        xhr:registerScriptHandler(function ( ... )
           self:_onReadyStateChanged(xhr,__cb)
        end)
        local _strParam = nil
        self:initExtendHead(xhr)
        if  __json then 
            -- _strParam = cc.exports.lib.JsonUtil:encode(__json)
            _strParam = cc.exports.lib.JsonUtil:decodeform(__json)
        end
        if _strParam then 
            xhr:send(_strParam)
        else
            xhr:send()
        end
    end
    if __forceNoInteraction  then 
        local dispatcher = cc.Director:getInstance():getEventDispatcher()
        local event = cc.EventCustom:new(HttpClient.EVENT_NO_INTERACTION)
        dispatcher:dispatchEvent(event)  
    end
    executeFunc(__urlParam,__jsonParam ,__cbParam)
end



--[[--
Client-Device:设备型号
Client-MachineCode:设备标识
Client-ChannelId:渠道标识
Client-VersionId:版本号标石
]]
function HttpClient:initExtendHead(xhr)
    if self._deviceModel == nil then self._deviceModel = MultiPlatform:getInstance():getDeviceName() end
    xhr:setRequestHeader("clientDevice",self._deviceModel)
    xhr:setRequestHeader("clientMachineCode",HttpClient.MachineCode)
    -- xhr:setRequestHeader("Client-ChannelId",config.channle.CHANNLE_ID)
    xhr:setRequestHeader("clientVersion",config.channle.VERSION)
    xhr:setRequestHeader("clientOS",config.channle.clientOS)
    xhr:setRequestHeader("content-type","application/x-www-form-urlencoded")
    
end

function HttpClient:urlDecode( __urlString )
    return urlDecode(__urlString)
end

function HttpClient:urlEncode( __urlString )
    return urlEncode(__urlString)
end

cc.exports.HttpClient = HttpClient
return HttpClient
