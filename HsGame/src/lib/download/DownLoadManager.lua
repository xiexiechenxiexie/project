--[[--
@author fly  http get方式 异步 
]]

local FILE_CHECK_KEY = "hs_game_res_upadte"

if not cc.exports.HttpClient then
    require "HttpClient"
end

local DownLoadManager = class("DownLoadManager")

DownLoadManager._downloadCallbacksDict = {}
DownLoadManager._callback = nil
DownLoadManager._downloadSeq = 1
function DownLoadManager:ctor( ... )
    self._downloadCallbacksDict = {}
    self._callback = nil
end

function DownLoadManager:_createXmlRequest( __xmlRequestRspType )
	local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = __xmlRequestRspType
    xhr.timeout = 30000
    xhr.withCredentials = true
    return xhr
end

function DownLoadManager:_onDownloadStateChanged( __xhr,__callback )
    local _xhr = __xhr
    --为了保持同一url下面 回调一对一 但是移除回调是 一个url对应多个回调，也就是说只要一个url回调不存在了 其他的都回调不成功
    --print(_xhr.gameRequestUrl,"DownLoadManager:_onDownloadStateChanged")
    --dump(self._downloadCallbacksDict)
    -- local  _cb = self._downloadCallbacksDict[_xhr.gameRequestUrl]
    -- if _cb == nil then 
    --     return
    -- end

    if _xhr.readyState == 4 and _xhr.status >= 200 and _xhr.status < 207 then
        --print("_xhr.response begin " .. _xhr.response .. "----- end")

        local url = _xhr.gameRequestUrl
        local match = ".+/([^/]*%.%w+)$"
        local fileName = string.match(url,match)
        if _xhr.fileName and type(_xhr.fileName) == "string" and _xhr.fileName ~= "" then 
            fileName = _xhr.fileName
        end
        if not fileName then
            local match = ".+/(%w+%/%w+)$"
            fileName = string.match(url,match)
            if not fileName then
                return
            else
                fileName = string.match(fileName,"%w+")
            end
            if not fileName then
                return
            end
        end

        local dir = cc.FileUtils:getInstance():getWritablePath() .. "download/"
        if _xhr.dir   and type(_xhr.dir) == "string"  and  _xhr.dir ~= "" then
            dir =  dir .. _xhr.dir .. "/"
        end

        if not cc.FileUtils:getInstance():isDirectoryExist(dir) then
            cc.FileUtils:getInstance():createDirectory(dir)
        end
        local fullFileName = dir .. fileName
        local file,errorMsg = io.open(fullFileName,"wb+")
        if file then
            file:write(_xhr.response)
            file:close()
            -- if _cb ~= nil then 
            --     _cb(nil,fullFileName) 
            -- end
            --print("下载完成派发事件",_xhr.gameRequestUrl)
            local event = cc.EventCustom:new(_xhr.gameRequestUrl)
            event.fullFileName = fullFileName
            lib.EventUtils.dispatch(event)  
        else
            -- if _cb ~= nil then
            --     _cb(errorMsg,fullFileName) 
            -- end
        end


    else
        --print("_onDownloadStateChanged _xhr.readyState is:", _xhr.readyState, "__xhr.status is: ",_xhr.status)
        -- if _cb ~= nil then
        --     _cb("failed",nil) 
        -- end
    end
    _xhr:unregisterScriptHandler()
end



--[[--  该接口没有文件md5比对功能
		--使用例子如下
		local url = "http://192.168.1.213:8086/" .. i .. ".png"
		cc.exports.lib.download.DownLoadManager:getInstance():download("lobbyplay",url,function ( errorMsg,fileName )
			if not  errorMsg then
				local node = ccui.ImageView:create(fileName,ccui.TextureResType.localType)
				self:addChild(node)
				node:setPosition(math.random(1,1000),math.random(1,750))
			else
				print("下载失败错误信息",errorMsg)
			end
		end)

		 __dir 下载模块的存储目录-最好根据模块来存储，防止文件名同名   可以为空
		__url下载地址 不能为空
		__callback 下载完成回调 可为空
        __fileName 自定义文件名
]]
function DownLoadManager:download( __dir,__urls,__callback,__fileName)
	assert(__urls,"invalid __urls")
	__dir = __dir or ""
    if type(__urls) == "string" then
          __urls = {__urls}  
    end
	__callback = __callback or function () end
	if self._downloadCallbacksDict == nil then
        self._downloadCallbacksDict = {}
    end
    for i,v in ipairs(__urls) do
        local url = v
        local isExist,fullFileName = self:isFileExist(__dir,url,__callback,__fileName)
        if isExist  then
            __callback(nil,fullFileName)
        else
            if not self._downloadCallbacksDict[url] then
                --print("url",url,"加入到_downloadCallbacksDict")
                self._downloadCallbacksDict[url] = __callback
            end

        
            local executeFunc = function (url,__cb)
                self._downloadSeq = self._downloadSeq + 1
                local xhr = self:_createXmlRequest(cc.XMLHTTPREQUEST_RESPONSE_STRING)
                xhr.gameRequestUrl = url
                xhr._callback = __callback
                xhr.dir = __dir
                xhr.fileName = __fileName
                xhr:open("GET", url,true)
                xhr:registerScriptHandler(function (  )
                    self:_onDownloadStateChanged(xhr)
                end)
                xhr:send()
            end
            executeFunc( url,__callback)
        end
    end
end

function DownLoadManager:isFileExist( __dir,__url,__callback,__fileName )
        local match = ".+/([^/]*%.%w+)$"
        local fileName = string.match(__url,match)
        if __fileName and type(__fileName) == "string" and __fileName ~= "" then 
            fileName = __fileName
        end
        --print("DownLoadManager:download",__url,fileName)
        if not fileName then
            return false
        end

        local dir = cc.FileUtils:getInstance():getWritablePath() .. "download/"
        if __dir   and type(__dir) == "string"  and  __dir ~= "" then
            dir =  dir .. __dir .. "/"
        end
        local fullName = dir .. fileName
        return cc.FileUtils:getInstance():isFileExist(fullName),fullName
end


--todo:服务器文件更新最新时间
function DownLoadManager:_findFileUpdateFromServer( ... )
    return tostring(os.time()) 
end


function DownLoadManager:_onDescfileDownload( ... )
    
end

function DownLoadManager:removeCallBackByUrl(__url )
    assert(__url,"invalid __url")
    if self._downloadCallbacksDict[__url] then
        self._downloadCallbacksDict[__url] = nil
    end
end


cc.exports.lib.singleInstance:bind(DownLoadManager)
cc.exports.lib.download.DownLoadManager = DownLoadManager