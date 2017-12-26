-- 文件通用工具   
-- @date 2017.08.28
-- @author tangwen

local FileSystemUtils = {}

function FileSystemUtils.getFileList( __dirPath )
	local fileList = {}

    if device.platform == "ios" then
        __dirPath = cc.FileUtils:getInstance():fullPathForFilename(__dirPath)
    end

	for file in lfs.dir(__dirPath) do
        if file ~= "." and file ~= ".." then
            -- 判断是否是目录
            local i = string.find(file, "%.")
            -- 文件夹，递归查找
            if not i then
                local subList = FileSystemUtils.getFileList(__dirPath.."/"..file)
                -- 合并子列表
                for k, v in pairs(subList) do
                    table.insert(fileList, file.."/"..v)
                end
            -- 非文件夹，添加到列表
            else
                table.insert(fileList, file)
            end
        end
    end
    return fileList
end


-- 加载资源并使用加载界面的
function FileSystemUtils.loadResourceByLayer( __resList, __callback )
	local __scene = cc.Director:getInstance():getRunningScene()
	if __scene == nil then
		print("界面不存在")
		return
	end

	local resList = __resList
	local __params = {callback =__callback, resList = resList , dirPath = __dirPath}
	local loadResLayer = require "lib/view/LoadResLayer"
    local loadRes = loadResLayer.new(__params)
    __scene:addChild(loadRes,ConstantsData.LocalZOrder.DIY_DIALOAG_LAYER)
    GameUtils.stopLoading()

end

function FileSystemUtils.getResPathByData( __data,__dirPath)
	local resList = {}
	local dirPathSize = string.len(__dirPath)
	for k,v in pairs(__data) do
        if string.sub(__dirPath,5,dirPathSize) == string.sub(v,1,dirPathSize-4) then
        	table.insert(resList,v)
        end
    end
    return resList
end

-- 只是加载资源
function FileSystemUtils.addResource( __dirPath )
	local resList = {}
	print("__dirPath",__dirPath)
	if #ResPathData.pathData == 0 then
		local data = cc.FileUtils:getInstance():getStringFromFile("ResPath.json")
		local resPathData = lib.JsonUtil:decode(data)
		for k,v in pairs(resPathData.files) do
        	table.insert(ResPathData.pathData, resPathData.files[k].name)
    	end
    	resList = FileSystemUtils.getResPathByData(ResPathData.pathData,__dirPath)
	else
		resList = FileSystemUtils.getResPathByData(ResPathData.pathData,__dirPath)
	end

	dump(resList)
	return resList

end

function FileSystemUtils.removePlistResource( __dirPath )
	local resList = {}
	if #ResPathData.pathData == 0 then
		local data = cc.FileUtils:getInstance():getStringFromFile("ResPath.json")
		local resPathData = lib.JsonUtil:decode(data)
		for k,v in pairs(resPathData.files) do
        	table.insert(ResPathData.pathData, resPathData.files[k].name)
    	end
    	resList = FileSystemUtils.getResPathByData(ResPathData.pathData,__dirPath)
	else
		resList = FileSystemUtils.getResPathByData(ResPathData.pathData,__dirPath)
	end

	--dump(resList)

	local imgList = {}
	local plistList = {}
	-- 划分图片文件和plist文件
	for k, v in pairs(resList) do
		local ext = v:match("%.(%w+)$")
		ext = string.lower(ext)
		-- 图片文件列表
		if ext == "plist" then
			table.insert(plistList, v)
			local resLen = string.len(v)
			local imgStr = string.sub(v,1,resLen-5) .. "png"
			table.insert(imgList, imgStr)			
		end
	end

	for k,v in pairs(imgList) do
		cc.Director:getInstance():getTextureCache():removeTextureForKey(v)
		--print("Wen","removePlistResource:", v)
	end

	for k,v in pairs(plistList) do
		cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(v)
		--print("Wen","removePlistResource:", v)
	end
end


cc.exports.FileSystemUtils = FileSystemUtils