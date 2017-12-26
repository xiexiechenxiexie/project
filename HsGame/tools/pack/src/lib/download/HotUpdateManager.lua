--[[--
author fly ：热更新
"HotUpdateManager","Boot","main","LogoScene" 三个是首屏必须引入的文件，在持续热更环节不能被修改
关于人更新之后lua文件重新加载到内存并且初始化数据逻辑详见 Boot.lua

打包的时候生成一个全文见的描述文件，
a: writablePath /hot_base/model/*manifest
b: writeblepath / update/model/project.manifest
第一次热更新或者玩家把缓存文件删掉
每个模块去下载或者热更的时候 ，根据模块生成对应的描述文件到 a 
然后用这个作为该模块的本地描述文件去热更新


指定热更新包地址已经版本逻辑如下
更新主要包含如下信息
        packageUrl = "http://127.0.0.1/niuniu/",
        remoteManifestUrl  = "http://127.0.0.1/niuniu/project_dev.manifest",
        remoteVersionUrl = "http://127.0.0.1/niuniu/version_dev.manifest",
        version = "1.0.0"
        searchPaths = "[]"

如果a,b  存在 就会去更新b描述文件 如果b不存在就去更新a的描述文件做热更新

版本号管理
主版本号：子版本号.bug修复版本号.版本日期号 不可以热更，需要整包更新
子版本号: 设计重大框架修改或者大功能跟新不能热更需要整包更新的才回去修改 可以热更
bug修复版本号：只是修复bug就做更改 可以热更
版本比对只比对前面三个的int值大小
版本日期修复号:20170510  年月日  可以热更

注意:
要断点续传需要 服务器只是 accepts_range  
AssetsManagerEx:setVersionCompareHandle

]]
--csjon算法进行了压缩优化操作内存占用率是文本的4倍左右

local json = require "cjson"

local HotUpdateManager = class("HotUpdateManager",cc.Node)
HotUpdateManager._assetsManager = nil;
HotUpdateManager._listener = nil;
HotUpdateManager._eventCallback = nil;
HotUpdateManager._gameId = nil;
HotUpdateManager._failCount = 0;
HotUpdateManager.TEST = false
HotUpdateManager._manifestDownCount = 0
HotUpdateManager._downloadInfo = nil
HotUpdateManager.SEARCH_PATHS = "SEARCH_PATH_HSGAME"

HotUpdateManager.MAX_VERSION = 2
HotUpdateManager.NEW_VERSION = 1
HotUpdateManager.NONE_VERSION = 0

HotUpdateManager.LOBBY_MODELID = -1
HotUpdateManager.LOBBY_MODEL_NAME = "Lobby"

HotUpdateManager.EVENT_UPDATE_SUCCESS   = "EVENT_UPDATE_SUCCESS"
HotUpdateManager.EVENT_UPDATE_ERROR     = "EVENT_UPDATE_ERROR"
HotUpdateManager.EVENT_UPDATE_PROGRESS  = "EVENT_UPDATE_PROGRESS"
HotUpdateManager.EVENT_UPDATE_MAXVERSION  = "EVENT_UPDATE_MAXVERSION"
HotUpdateManager.versionCache  = {}

HotUpdateManager.MODIFIED_FILEDS = {
    "packageUrl","remoteManifestUrl","remoteVersionUrl","searchPaths"
}

-- local GameIDConfig = {
--     BRNN = 1002, --百人牛牛
--     KPQZ = 1001, --  看牌强庄 牛牛
--     PSZ  = 1003, -- 拼三张  炸金花
--     HHDZ = 1004  --红黑大战  
-- }

-- HotUpdateManager.manifest = {
--     ["1001"] = {
--         model = "1001",
--         modelName = "niuniu",
--         packageUrl = "http://127.0.0.1/niuniu/",
--         remoteManifestUrl  = "http://127.0.0.1/niuniu/project_dev.manifest",
--         remoteVersionUrl = "http://127.0.0.1/niuniu/version_dev.manifest",
--         version = "8.2.1",
--         searchPaths = { "src/", "src/game/", "src/Lobby/", "src/Lobby/src/", "src/Lobby/res/"}
--     },
--     ["1002"] = {
--         model = "1002",
--         modelName = "brnn",
--         packageUrl = "http://127.0.0.1/brnn/",
--         remoteManifestUrl  = "http://127.0.0.1/brnn/project_dev.manifest",
--         remoteVersionUrl = "http://127.0.0.1/brnn/version_dev.manifest",
--         version = "8.2.1",
--         searchPaths = { "src/", "src/game/", "src/Lobby/", "src/Lobby/src/", "src/Lobby/res/"}
--     },
--     ["1003"] = {
--         model = "1003",
--         modelName = "psz",
--         packageUrl = "http://127.0.0.1/psz/",
--         remoteManifestUrl  = "http://127.0.0.1/psz/project_dev.manifest",
--         remoteVersionUrl = "http://127.0.0.1/psz/version_dev.manifest",
--         version = "8.2.1",
--         searchPaths = { "src/", "src/game/", "src/Lobby/", "src/Lobby/src/", "src/Lobby/res/"}
--     },
--     [tostring(HotUpdateManager.LOBBY_MODELID)] = {
--         model = tostring(HotUpdateManager.LOBBY_MODELID),  --大厅
--         modelName = HotUpdateManager.LOBBY_MODEL_NAME,
--         packageUrl = "http://127.0.0.1/"..HotUpdateManager.LOBBY_MODEL_NAME.."/",
--         remoteManifestUrl  = "http://127.0.0.1/"..HotUpdateManager.LOBBY_MODEL_NAME.."/project_dev.manifest",
--         remoteVersionUrl = "http://127.0.0.1/"..HotUpdateManager.LOBBY_MODEL_NAME.."/version_dev.manifest",
--         version = "1.2.1",
--         searchPaths = {  "src/", "src/game/", "src/Lobby/", "src/Lobby/src/", "src/Lobby/res/"}
--     }
-- }
function HotUpdateManager.initManifest( __paramList )
    HotUpdateManager.manifest = {}
    for key,value in ipairs(__paramList) do
        HotUpdateManager.manifest[value.model] = value
    end
end


function HotUpdateManager:ctor(__gameId, __eventCallback )
    print("HotUpdateManager:ctor")
    self._eventCallback = __eventCallback or function ( ... )end
    self._gameId = __gameId or -1
    self._assetsManager = nil
    print("gameId",__gameId, "__eventCallback",__eventCallback)
	if self.TEST  then
		return
	end

    local localManifest = "src/res/template/project.manifest"
    local params = HotUpdateManager.manifest[tostring(__gameId)]  --
    local storagePath = self:findStoragePathByGameId(__gameId)
    if params then
        local model = self:findModelByGameId(__gameId)
        assert(model,"invalid model")
        local isExit = cc.FileUtils:getInstance():isFileExist(localManifest)
        local modelName = params.modelName
        if  isExit then
            localManifest = self:findNewManifestDir(modelName) .. "project.manifest"
            --这里必须进行一次写入更新 因为在大版本整包下载更新之后会出现 writablePath /model/project.manifest不存在的情况
            --这个时候hot_base下面是存在的，所以必须更新template下面的描述文件 不然在大版本更新之热更新出现更新中断就会导致文件太久版本是
            --最初版本，就会导致再次大版本更新
            self:_createModelManifest(modelName,params)
        else
            print("src/res/template/project.manifest not exist,please check it exist")
            return
        end
        self:_updateProjectManiFest(__gameId,params);
        print(localManifest, storagePath,__gameId, __eventCallback)
    else
        if __gameId == -1 then
            localManifest = "src/res/Lobby/project.manifest"
        end
        print("从包体src/res/取配置")
    end
    self:init(localManifest, storagePath,__gameId, __eventCallback)

end

--[[--  hot_base 目录]]
function HotUpdateManager:findNewManifestDir( __modelName )
    print("fly","HotUpdateManager:findNewManifestDir",__modelName)
    return cc.FileUtils:getInstance():getWritablePath() .. "hot_base/"..__modelName.."/"
end



function HotUpdateManager:findStorageTempPathByGameId( __gameId )
    local modelName = self:findModelByGameId(__gameId)
    assert(modelName,"invalid model")
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    local storagePath = writablePath .. "update/"..modelName
    return storagePath
end

function HotUpdateManager:findStoragePathByGameId( __gameId )
    local modelName = self:findModelByGameId(__gameId)
    assert(modelName,"invalid modelName")
    local writablePath = cc.FileUtils:getInstance():getWritablePath()
    local storagePath = writablePath .. "update/"..modelName
    return storagePath
end

function HotUpdateManager:findModelByGameId( __gameId )
    print("HotUpdateManager:findModelByGameId",__gameId)
    if __gameId ==  HotUpdateManager.LOBBY_MODELID then
        return HotUpdateManager.LOBBY_MODEL_NAME
    else
        local info = HotUpdateManager.manifest[tostring(__gameId)]
        if  HotUpdateManager.manifest[tostring(__gameId)] then 
            return info.modelName   
        end 
    end
    return nil
end




function HotUpdateManager:init( __localManifest, __storagePath,__gameId, __eventCallback)
    assert(__localManifest and __gameId,"invalid __localManifest")
    __storagePath = __storagePath 
    local modelName = self:findModelByGameId(__gameId)
    assert(modelName,"invalid modelName")
    self._assetsManager = cc.AssetsManagerEx:create(__localManifest,  __storagePath)

    -- todo版本比对方式
    -- 暂时在luabind中不支持该接口,需要该framework  
    self._assetsManager:setVersionCompareHandle(function ( __localVersion,__remoteVersion )
        print("fly","VersionCompareHandle",__localVersion,__remoteVersion)
        __localVersion = __localVersion or ""
        __remoteVersion = __remoteVersion or ""
        local localVersionArr = string.split(__localVersion,".")
        local remoteVersionArr = string.split(__remoteVersion,".")
        local code = tonumber(localVersionArr[1]) - tonumber(remoteVersionArr[1])
        print("fly","code",code)
        if code ~= 0 then return code end
        code = tonumber(localVersionArr[2]) - tonumber(remoteVersionArr[2])
        print("fly","code",code)
        if code ~= 0 then return code end
        code = tonumber(localVersionArr[3]) - tonumber(remoteVersionArr[3])
        print("fly","code",code)
        if code ~= 0 then return code end
        return 0
    end)

    self._assetsManager:setMaxConcurrentTask(64);--设置任务数量
    self._assetsManager:retain()
    print("self._assetsManager11")

    local function onUpdateEvent(event)
        
        local eventCode = event:getEventCode()
        print("onUpdateEvent",eventCode)
        self._eventCallback(eventCode,percent)

        local dispatcher = cc.Director:getInstance():getEventDispatcher()
        if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then

            local event = cc.EventCustom:new(HotUpdateManager.EVENT_UPDATE_ERROR)
            event.userdata = {
                msg = "No local manifest file found, skip assets update.",
                code = eventCode,
                gameId = self._gameId
            }
            dispatcher:dispatchEvent(event)

        elseif  eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
            local assetId = event:getAssetId()
            local percent = event:getPercent()
            local strInfo = ""

            if assetId == cc.AssetsManagerExStatic.VERSION_ID then
                strInfo = string.format("Version file: %d%%", percent)
                percent = 5
            elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
                strInfo = string.format("Manifest file: %d%%", percent)
                percent = 10
            else
                if percent < 10 then 
                    percent = 10
                end
                strInfo = string.format("%d%%", percent)
            end
            print("strInfo",strInfo)
            
            local event = cc.EventCustom:new(HotUpdateManager.EVENT_UPDATE_PROGRESS)
            event.userdata = {
                msg = "progressing",
                assetId = assetId,  --三种类型文件 cc.AssetsManagerExStatic.VERSION_ID  ,cc.AssetsManagerExStatic.MANIFEST_ID,other 热更包
                percent = percent,--进度
                code = eventCode,
                gameId = self._gameId
            }
            dispatcher:dispatchEvent(event)

        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or 
               eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then

            local event = cc.EventCustom:new(HotUpdateManager.EVENT_UPDATE_ERROR)
            event.userdata = {
                msg = "download or parse failed",
                code = eventCode,
                gameId = self._gameId
            }
            dispatcher:dispatchEvent(event)

        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE or 
               eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then

            print("update finished !!!")
            local event = cc.EventCustom:new(HotUpdateManager.EVENT_UPDATE_SUCCESS)
            event.userdata = {
                msg = "upate finish",
                code = eventCode,
                gameId = self._gameId
            }
            self:setSearchPath(self._gameId)
            dispatcher:dispatchEvent(event)

        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING or eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED then
            local assetId = nil 
            if event and event.getAssetId then assetId = event:getAssetId() end
            local event = cc.EventCustom:new(HotUpdateManager.EVENT_UPDATE_ERROR)
            event.userdata = {
                msg ="error updateing",
                assetId = assetId,
                code = eventCode,
                gameId = self._gameId
            }
            dispatcher:dispatchEvent(event)
            self._assetsManager:downloadFailedAssets()
        elseif eventCode == cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND then  
            local code = self:findVersionChangedCode()
            if HotUpdateManager.MAX_VERSION == code then
                local event = cc.EventCustom:new(HotUpdateManager.EVENT_UPDATE_MAXVERSION)
                event.userdata = {
                    msg = "whole package update",
                    code = eventCode,
                    gameId = self._gameId
                }
                dispatcher:dispatchEvent(event)
                self._assetsManager:release()
                self._assetsManager = nil
                print("需要整包更新")
            elseif HotUpdateManager.NEW_VERSION == code then
                HotUpdateManager.versionCache[modelName] = nil
                self:update()
            end
            
        end
    end
            
    local listener = cc.EventListenerAssetsManagerEx:create(self._assetsManager,onUpdateEvent)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

    
    local function onNodeEvent(event)
        if "enter" == event then
            
        elseif "exit" == event then
            if self._assetsManager then self._assetsManager:release() end
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function HotUpdateManager:findLocalVersionFromAssetsManager( ... )
    assert(self._assetsManager,"invalid self._assetsManager")
    local version = self._assetsManager:getLocalManifest():getVersion();
    print("version",version)
    return version
end

function HotUpdateManager:findRemoteVersion( ... )
    assert(self._assetsManager,"invalid self._assetsManager")
    local version = self._assetsManager:getRemoteManifest():getVersion();
    print("version",version)
    return version
end

--[[--
获取本地版本
]]
function HotUpdateManager:findMainfestVersion( ... )
    local version = self._assetsManager:getRemoteManifest():getVersion();
	return version
end


--[[--
HotUpdateManager.MAX_VERSION = 2
HotUpdateManager.NEW_VERSION = 1
HotUpdateManager.NONE_VERSION = 1
--热更新过程中版本接口判断
]]
function HotUpdateManager:findVersionChangedCode( __localVersion,__remoteVersion)
    print("findVersionChangedCode",__localVersion,__remoteVersion)
    local version = __localVersion or self:findLocalVersionFromAssetsManager()
    local remoteVersion = __remoteVersion or  self:findRemoteVersion()
    if version == remoteVersion then
        return HotUpdateManager.NONE_VERSION
    end
    local localVersionArr = string.split(version,".")
    local remoteVersionArr = string.split(remoteVersion,".")
    print(version,remoteVersion,remoteVersionArr[1] , localVersionArr[1])
    if tonumber(remoteVersionArr[1]) > tonumber(localVersionArr[1]) then return HotUpdateManager.MAX_VERSION end
    if tonumber(remoteVersionArr[2]) > tonumber(localVersionArr[2]) then return HotUpdateManager.MAX_VERSION end
    if tonumber(remoteVersionArr[3]) > tonumber(localVersionArr[3]) then return HotUpdateManager.NEW_VERSION end
    return HotUpdateManager.NONE_VERSION 
end


--[[--
开始更新

]]
function HotUpdateManager:update( ... )
	print("HotUpdateManager:update")
	if self.TEST then
		self._eventCallback(self._gameId)
		return
	end
    if self._assetsManager then self._assetsManager:update() end 
end

function HotUpdateManager:compareVersion( __srcVersion,__destVersion )
        print("fly","VersionCompareHandle",__srcVersion,__destVersion)
        __srcVersion = __srcVersion or ""
        __destVersion = __destVersion or ""
        local srcVersionArr = string.split(__srcVersion,".")
        local destVersionArr = string.split(__destVersion,".")
        local code = tonumber(srcVersionArr[1]) - tonumber(destVersionArr[1])
        print("fly","code",code)
        if code ~= 0 then return code end
        code = tonumber(srcVersionArr[2]) - tonumber(destVersionArr[2])
        print("fly","code",code)
        if code ~= 0 then return code end
        code = tonumber(srcVersionArr[3]) - tonumber(destVersionArr[3])
        print("fly","code",code)
        if code ~= 0 then return code end
        return 0
end

function HotUpdateManager:setSearchPath( __gameId )
    local oldSearchPath = cc.FileUtils:getInstance():getSearchPaths()

    local gameId = -1
    if __gameId then 
        gameId = __gameId
    end
    if config and config.channle and config.channle.VERSION then 
        local pathDir = self:findStoragePathByGameId(gameId)
        local manifestPath = pathDir .. "/project.manifest"
        local model = self:findModelByGameId(gameId)
        local baseDir = self:findNewManifestDir(model)
        local hotBaseManifest = baseDir .. "project.manifest"
        
        local pkgManifest = "src/res/" .. model .. "/project.manifest"

        local arrManifests = {manifestPath,hotBaseManifest,pkgManifest}

        local version = nil
        for _,manifestPath in ipairs(arrManifests) do
            print("fly","manifestPath",manifestPath)
            if cc.FileUtils:getInstance():isFileExist(manifestPath) then 

                local data = cc.FileUtils:getInstance():getStringFromFile(manifestPath)
                local luaObj = json.decode(data)
                if luaObj.version then 
                    HotUpdateManager.versionCache[model] = luaObj.version
                end 
                version = luaObj.version
                break;
            end
        end
        print("config.channle.VERSION,version",config.channle.VERSION,version,self:compareVersion(config.channle.VERSION,version))
        if self:compareVersion(config.channle.VERSION,version) > 0  then 
            cc.UserDefault:getInstance():setStringForKey(HotUpdateManager.SEARCH_PATHS,"");
            return
        end
    end
    local searchPathsStr = cc.UserDefault:getInstance():getStringForKey(HotUpdateManager.SEARCH_PATHS,"");
    local searchPathArr = string.split(searchPathsStr,",")
    local oldSearchPath = cc.FileUtils:getInstance():getSearchPaths()
    for _,path in ipairs(oldSearchPath) do
        searchPathArr[#searchPathArr + 1] = path
    end
    print("fly","setSearchPaths")
    cc.FileUtils:getInstance():setSearchPaths(searchPathArr)   
end

function HotUpdateManager:saveNewSearchPath( __searchPaths)
    assert(__searchPaths,"invalid __searchPaths")
        print("HotUpdateManager:saveNewSearchPath")
    dump(__searchPaths)

    if type(__searchPaths) == "string" then
        __searchPaths = {__searchPaths}
    end

    print("fly","HotUpdateManager:saveNewSearchPath length ", #__searchPaths)
    local searchPathsStr = cc.UserDefault:getInstance():getStringForKey(HotUpdateManager.SEARCH_PATHS,"");
    local searchPathArr = string.split(searchPathsStr,",")
    local newArrayPath = {}
    for _,newPath in ipairs(__searchPaths) do
        newPath=string.gsub(newPath, "hot_base", "update");
        local isExit = false
        for _,existPath in ipairs(searchPathArr) do
            
            if existPath == newPath then
                isExit = true
                break
            end
        end
        if not isExit then
            newArrayPath[#newArrayPath +1] =  newPath
        end
        
    end
    for _,path in ipairs(searchPathArr) do
        newArrayPath[#newArrayPath +1] =  path
    end

    local str = newArrayPath[1];
    if #newArrayPath > 0 then
        for i=2,#newArrayPath do
            if newArrayPath[i] ~= "" then
                str = str .. "," .. newArrayPath[i];
            end
        end
    end
    cc.UserDefault:getInstance():setStringForKey(HotUpdateManager.SEARCH_PATHS,str)
end

--[[--
检测更新

]]
function HotUpdateManager:checkUpdate( ... )
    print("fly","HotUpdateManager:checkUpdate")
    if not self._assetsManager then
        printError("assetsmanager not create please look HotUpdateManager.manifests carefully")
        return 
    end
    
    local searchPaths = self._assetsManager:getLocalManifest():getSearchPaths()
    self:saveNewSearchPath(searchPaths)

    print("fly","getManifestFileUrl",self._assetsManager:getLocalManifest():getVersionFileUrl())
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function ( ... )
        if not self._assetsManager:getLocalManifest():isLoaded() then
            print("Fail to update assets, step skipped")
            return 
        else
            print("self._assetsManager:checkUpdate")
            self._assetsManager:checkUpdate()
        end
    end)))
end

function HotUpdateManager:tryReDownload( ... )
    if  self._assetsManager then self._assetsManager:downloadFailedAssets() end
end


function HotUpdateManager:_getModifiedManifestContent( __path,__params )
    local params = __params
    print("HotUpdateManager:_getModifiedManifestContent",__path)

    local data = cc.FileUtils:getInstance():getStringFromFile(__path);
    if not __params then
        printError("__params is nil,please check")
        return data
    end


    local obj = json.decode(data)
    obj.searchPaths = nil
    for _,filed in pairs(HotUpdateManager.MODIFIED_FILEDS) do
        if __params[filed] and "searchPaths" ~= filed then
            obj[filed] = __params[filed]
        end
    end

    local data = json.encode(obj);
    local index = string.find(__path,"version.manifest",1,true)
    if not index or  index < 0 then
        local searchPathsArr = json.decode(params.searchPaths)
        print("searchPathsArr",tostring(searchPathsArr))
        local paths = ",\"searchPaths\":["
        if searchPathsArr and #searchPathsArr > 0 then
            paths = paths .. "\"" .. searchPathsArr[1] .. "\""
            for key,v in ipairs(searchPathsArr) do
                paths = paths .. ",\"" .. v .. "\""
            end
        end
        paths  = paths .."]}"
        print(paths)
        
        
        data = string.sub(data, 1,string.len(data) -1)
        data = data .. paths
    end
    
    return data;

    --下面字符串算法内存占用率极高是文本的几十倍以上
    -- local orgArr = string.split(data,",")
    -- for i,str in ipairs(orgArr) do
    --     for key, value in pairs(params) do
    --         local index = string.find(str,key,1,true)
    --         if  index and index > 0 then
    --             local strArr = string.split(str,":")
    --             strArr[2] = value
    --             if key ~= "searchPaths" then
    --                 orgArr[i] = strArr[1] .. ":\"" .. strArr[2] .."\""
    --             else
    --                 orgArr[i] = strArr[1] .. ":" .. strArr[2] 
    --             end
    --         end
    --     end
    -- end
    -- local str = orgArr[1]
    -- for i=2,#orgArr do
    --     str = str  .. "," .. orgArr[i]
    -- end
    -- if str[#str] ~="}" then str = str .. "}" end
    -- print("str",str)
    -- return str

    
end


--[[--
修改update/model/project.manifest 如果不存在 修改 hot_base/model/project.manifest 
]]
function HotUpdateManager:_updateProjectManiFest( __gameId ,__params)
    local dir = self:findStoragePathByGameId(__gameId) .. "/"
    local params = __params
    local path = dir .. "project.manifest"
    print("path",path)
    local modelName = self:findModelByGameId(__gameId)
    assert(modelName,"invalid modelName")
    --第一步 判断storagePath下面的project.manifest文件存在否
    if not cc.FileUtils:getInstance():isFileExist(path) then  
        --第二步 判断hot_base缓存文件
        local dirHotBase = self:findNewManifestDir(modelName);
        local hotBasepath = dirHotBase .. "project.manifest"
        if  cc.FileUtils:getInstance():isFileExist(hotBasepath) then
            print("hotBasepath",hotBasepath)
            local str = self:_getModifiedManifestContent(hotBasepath,params)
            self:writeFile(str,dirHotBase,"project.manifest")
        else
            printError("hotBasepath " .. hotBasepath .." not exit please check") 
        end
        return
    end

    local str = self:_getModifiedManifestContent(path,params)
    self:writeFile(str,dir,"project.manifest")
end
--[[--
修改version.manifest
]]
function HotUpdateManager:_updateVersionManiFest( __gameId ,__params)
    local dir = self:findStoragePathByGameId(__gameId) .. "/"
    local params = __params
    local path = dir .. "version.manifest"
    print("path",path)


    if not cc.FileUtils:getInstance():isFileExist(path) then  
        local modelName = self:findModelByGameId(__gameId)
        assert(modelName,"invalid modelName")
        local dirHotBase = self:findNewManifestDir(modelName);
        local hotBasepath = dirHotBase .. "version.manifest"
        if cc.FileUtils:getInstance():isFileExist(hotBasepath) then
            local str = self:_getModifiedManifestContent(hotBasepath,params)
            self:writeFile(str,dirHotBase,"version.manifest")
        else
            printError("hotBasepath " .. " not exit please check")      
        end
        return
    end

    local str = self:_getModifiedManifestContent(path,params)
    self:writeFile(str,dir,"version.manifest")
end

function HotUpdateManager:reloadGame( ... )
    print("HotUpdateManager:reloadGame",self._gameId)
    -- if true then
    --     package.loaded["src/Lobby/src/Boot.lua"] = nil
    --     require "src/Lobby/src/Boot.lua"
    --     print("重新加载lua")
    -- end

    if self._gameId < 0 then
        --todo:加载大厅部分
        Boot:boot()
    else
        --游戏中更新
        local modelName = config.GameModelName[self._gameId]
        Boot:reloadGame(modelName)
    end
end

--[[--
热更新事件回调
]]
function HotUpdateManager:onEventCallback( event)

end




function HotUpdateManager:writeFile( __content,__destDir,__fileName )
    if not cc.FileUtils:getInstance():isDirectoryExist(__destDir) then
        cc.FileUtils:getInstance():createDirectory(__destDir)
    end

    local fileName = __fileName
    local file,errorMsg = io.open(__destDir .. fileName,"wb+")
    if file then
        file:write(__content)
        file:close()
        return true
    else
        return false
    end
end

function HotUpdateManager:_createModelManifest( __modelName,__params )
    print("HotUpdateManager:_createModelManifest",__modelName)
    local srcProjectManifest = "src/res/template/project.manifest"
    local srcVersionManifest = "src/res/template/version.manifest"
    
    local dir = self:findNewManifestDir(__modelName)
    local path = dir .. "project.manifest"
    local str = self:_getModifiedManifestContent(srcProjectManifest,__params)
    self:writeFile(str,dir,"project.manifest")

    dir = self:findNewManifestDir(__modelName)
    path = dir .. "version.manifest"
    local str = self:_getModifiedManifestContent(srcVersionManifest,__params)
    self:writeFile(str,dir,"version.manifest")

end

-- packageUrl = "http://127.0.0.1/niuniu/",
-- remoteManifestUrl  = "http://127.0.0.1/niuniu/project_dev.manifest",
-- remoteVersionUrl = "http://127.0.0.1/niuniu/version_dev.manifest",
-- version = "1.0.0"
-- searchPaths = "[]"
function HotUpdateManager:queryManifests( __callback )
    local url = config.ServerConfig:findModelDomain() ..config.ApiConfig.REQUEST_MANIFESTS_INFO
    HotUpdateManager.manifest = {}
    HttpClient:get(url,function ( errorMsg,respLuaObj )
        if not errorMsg then
            local lobbyhotfix = respLuaObj.data.lobbyhotfix
            local hotfix = respLuaObj.data.hotfix
            hotfix[#hotfix+1] = lobbyhotfix
            for _,info in ipairs(hotfix) do
                if info.game_id then
                    local data = {}
                    data.model = info.game_id
                    data.modelName = info.game_code
                    if data.modelName == "lobby" then
                        data.modelName = "Lobby"
                    end
                    data.packageUrl = info.update_url
                    data.version = info.version
                    data.remoteManifestUrl = info.manifest_url
                    data.remoteVersionUrl = info.version_manifest
                    data.searchPaths = info.search_path
                    HotUpdateManager.manifest[data.model] = data
                end
            end
            print("dump(HotUpdateManager.manifest)")
            dump(HotUpdateManager.manifest)

            if not self._downloadInfo then
                self._downloadInfo = {}
            end
            if respLuaObj.data.appupdate then
                self._downloadInfo.version = respLuaObj.data.appupdate.version
                self._downloadInfo.description = respLuaObj.data.appupdate.description
                self._downloadInfo.allowance = respLuaObj.data.appupdate.allowance  --补偿
                self._downloadInfo.isForce = respLuaObj.data.appupdate.is_force --是否强制更新 
                self._downloadInfo.updateUrl = respLuaObj.data.appupdate.update_url --更新链接
                self._downloadInfo.size =  respLuaObj.data.appupdate.size
                self._downloadInfo.releaseTime = respLuaObj.data.appupdate.release_time -- 发布时间
            end
            dump(self._downloadInfo)
            
        else
            print("热更新 请求失败错误信息")
        end
        dump(HotUpdateManager.manifest)


        __callback(errorMsg,respLuaObj)
    end)
end



function HotUpdateManager:findVersionChangeCodeFromLocalFile( __gameId )
    if not HotUpdateManager.manifest[tostring(__gameId)] then
        print("fly","HotUpdateManager:findVersionChangeCodeFromLocalFile none version",__gameId)
        return HotUpdateManager.NONE_VERSION 
    end

    local model = self:findModelByGameId(__gameId)
     assert(model,"HotUpdateManager:findVersionChangeCodeFromLocalFile invalid modelName")
    local version = HotUpdateManager.versionCache[model]
            
    if not version then 
        local pathDir = self:findStoragePathByGameId(__gameId)
        local manifestPath = pathDir .. "/project.manifest"

        local baseDir = self:findNewManifestDir(model)
        local hotBaseManifest = baseDir .. "project.manifest"

        local pkgManifest = "src/res/" .. model .. "/project.manifest"

        local arrManifests = {manifestPath,hotBaseManifest,pkgManifest}

        for _,manifestPath in ipairs(arrManifests) do
            print("fly","manifestPath",manifestPath)
            if cc.FileUtils:getInstance():isFileExist(manifestPath) then 

                local data = cc.FileUtils:getInstance():getStringFromFile(manifestPath)
                local luaObj = json.decode(data)
                if luaObj.version then 
                    HotUpdateManager.versionCache[model] = luaObj.version
                end 
                version = luaObj.version
                break;
            end
        end
    end
    local remoteVersion = self:findVersionCodeFromManifests(__gameId)
    if version and remoteVersion then 
        
        print("fly","remoteVersion",remoteVersion,"version",version)
        local code = self:findVersionChangedCode(version,self:findVersionCodeFromManifests(__gameId))
        return code
    else
        print("fly","remoteVersion",remoteVersion,"version",version)
    end
    return HotUpdateManager.NONE_VERSION 
end

-- add by tangwen  
-- 获取本地版本号 - IOS  不支持？
function HotUpdateManager:findVersionCodeFromLocalFile( __gameId )
    local model = self:findModelByGameId(__gameId)
    local version = HotUpdateManager.versionCache[model]
    if not version then 
        local pathDir = self:findStoragePathByGameId(__gameId)
        local manifestPath = pathDir .. "/project.manifest"

        local baseDir = self:findNewManifestDir(model)
        local hotBaseManifest = baseDir .. "project.manifest"

        local pkgManifest = "src/res/" .. model .. "/project.manifest"

        local arrManifests = {manifestPath,hotBaseManifest,pkgManifest}

        for _,manifestPath in ipairs(arrManifests) do
            print("fly","manifestPath",manifestPath)
            if cc.FileUtils:getInstance():isFileExist(manifestPath) then 

                local data = cc.FileUtils:getInstance():getStringFromFile(manifestPath)
                local luaObj = json.decode(data)
                if luaObj.version then 
                    HotUpdateManager.versionCache[model] = luaObj.version
                end 
                version = luaObj.version
                break;
            end
        end
    end
    return version
end

function HotUpdateManager:findVersionCodeFromManifests( __gameId )
    print("HotUpdateManager:findVersionCodeFromManifests",__gameId,HotUpdateManager.manifest[tostring(__gameId)].version)
    if HotUpdateManager.manifest[tostring(__gameId)] then return HotUpdateManager.manifest[tostring(__gameId)].version end
    return nil
    
end

function HotUpdateManager:findDownloadInfo( ... )
    return self._downloadInfo
end

--[[--
true 需要整包更新 先去src/res/路径下面去找manifest文件  没找到在到hot_base下面去找 两个文位置都不不存在整包下载
]]
function HotUpdateManager:isGameNeedWholePkgDownload(__gameId)
    if ENABLE_HOT_UPDATE then
        print("fly","HotUpdateManager:isGameNeedWholePkgDownload")
        if not HotUpdateManager.manifest[tostring(__gameId)] then
            return false
        end
        local model = self:findModelByGameId(__gameId)
         assert(model,"invalid modelName")
        local versionManifest = "src/res/"..model .. "/version.manifest"
        local isFileExist =  cc.FileUtils:getInstance():isFileExist(versionManifest)
        print("isGameNeedWholePkgDownload",versionManifest,isFileExist)
        if not isFileExist then
             versionManifest = self:findNewManifestDir(model) .. "version.manifest"
             isFileExist = cc.FileUtils:getInstance():isFileExist(versionManifest)
        end
       
        return not isFileExist
    end
    return false
end


--[[--
需要热更新
]]
function HotUpdateManager:isGameModelNeedToUpadte(__gameId )
    local isNeedUpdate = false
    if ENABLE_HOT_UPDATE then 
        local code = self:findVersionChangeCodeFromLocalFile(__gameId)
        isNeedUpdate = code ~= HotUpdateManager.NONE_VERSION 
    end
    print("fly","isModelNeedToUpadte",__gameId,ENABLE_HOT_UPDATE,isNeedUpdate)
    return isNeedUpdate
end
print("HotUpdateManager hot update load finish")
cc.exports.lib = cc.exports.lib or {}
cc.exports.lib.download = cc.exports.lib.download or {}
cc.exports.lib.download.HotUpdateManager = HotUpdateManager