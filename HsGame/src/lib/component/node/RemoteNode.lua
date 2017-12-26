--[[--
@author fly 远程资源节点创建组件
	UIButton 例子
	local remoteView = cc.exports.lib.node.RemoteButton:create(self:findDefaultItemImg(),self:findDefaultItemImg(),self:findDefaultItemImg())
	remoteView:setDownloadParams({
		dir = "lobbyplay",
		url = "http://192.168.1.213:8086/6.png"
		})
	remoteView:setPosition(cc.p(200,200))
	remoteView:setPressedActionEnabled(true)
	self:addChild(remoteView) 


	ImageView 例子
	local remoteView = cc.exports.lib.node.RemoteImageView:create(self:findDefaultItemImg())
	remoteView:setDownloadParams({
		dir = "lobbyplay",
		url = "http://192.168.1.213:8086/6.png"
		})
	remoteView:setPosition(cc.p(200,200))
	self:addChild(remoteView)
]]

local function bind( __nodeClazz )

	__nodeClazz._downloadParams = nil
	__nodeClazz._offsetSize = nil
	__nodeClazz._defaultFile = nil
	__nodeClazz._dowloadFinishCallback = nil
	__nodeClazz._size = nil
	function __nodeClazz:ctor(...)
		local arg = {...}
		self._defaultFile = arg[1]
		self:reloadExtTexture(self._defaultFile)
		self:registerScriptHandler(handler(self,self.onNodeEvent))
		self.__nodeClazz = nil
		self._downloadParams = nil
		self._dowloadFinishCallback = nil
	end

    function __nodeClazz:onNodeEvent(event)
        if "enter" == event then
            self:onEnter()
        elseif "exit" == event then
            self:onExit()
        end
    end

    --[[--
		__params = {
			url = "http://..." --必须
			fileName = "xx"  --可选(保存文件名，默认以url链接为主)
			dir = ""  --存储路径 writablePath + dir + "/" + fileName  可选
		}
    ]]
    function __nodeClazz:setDownloadParams( __params )
		assert(__params and  __params.url ,"invalid download Url")
		self._downloadParams = __params
		if __params.size then self._size = __params.size end
    end

    function __nodeClazz:setDownloadFinishCallback( __callback )
    	self._dowloadFinishCallback = __callback
    end

    function __nodeClazz:onEnter( ... )
    	if self._downloadParams then 
	    	local eventKey = self._downloadParams.url
			if eventKey and type(eventKey) == "string" and eventKey ~= ""  then 
				local listener = lib.EventUtils.createEventCustomListener(eventKey,handler(self,self.onDownloadFinishEventCallback))
				lib.EventUtils.registeListener(self,listener)
			end
			----print("RemoteImageView:onEnter",self:getContentSize().width,self:getAnchorPoint().x,self:getAnchorPoint().y,self:getPositionX(),self:getPositionX())
			self._offsetSize = cc.size(self:getContentSize().width,self:getContentSize().height)
			local DownloadClazz = cc.exports.lib.download.DownLoadManager
			if self._downloadParams then
				--下载图片
				DownloadClazz:getInstance():download(self._downloadParams.dir,self._downloadParams.url,handler(self,self.onDownloadFinish),self._downloadParams.fileName)
			end
    	end
	end

	function __nodeClazz:onExit( ... )
		local DownloadClazz = cc.exports.lib.download.DownLoadManager
		if self._downloadParams then
			DownloadClazz:getInstance():removeCallBackByUrl(self._downloadParams.url)
		end
		lib.EventUtils.removeAllListeners(self)
	end

	function __nodeClazz:reloadExtTexture( fullFileName )

	end 

	function __nodeClazz:onDownloadFinishEventCallback( __event)
		--print("__nodeClazz:onDownloadFinishEventCallback")
		if __event and __event.fullFileName then 
			self:reloadExtTexture(__event.fullFileName)
			local size = self._offsetSize
			if size.width <= 0 and self._size then 
				size = self._size
			end
			if size.width > 0 then
				local scale = size.width / self:getContentSize().width
				--print("scale",scale,self:getContentSize().width,size.width)
				self:setScale(scale)
			end
			if self._dowloadFinishCallback then self._dowloadFinishCallback(__event.fullFileName) end
		end
	end

	function __nodeClazz:onDownloadFinish( errorMsg,fullFileName )
		----print("__nodeClazz:onDownloadFinish1",errorMsg,fullFileName)
		if not errorMsg then
			self:reloadExtTexture(fullFileName)
			local size = self._offsetSize
			if size.width <= 0 and self._size then 
				size = self._size
			end
			if size.width > 0 then
				local scale = size.width / self:getContentSize().width
				--print("scale",scale,self:getContentSize().width,size.width)
				self:setScale(scale)
			end
			if self._dowloadFinishCallback then self._dowloadFinishCallback(fullFileName) end
		else
			-- self:setPosition(self:getPositionX()+self:getContentSize().width / 2,self:getPositionY()+self:getContentSize().height / 2)
		end

	end
end

local RemoteImageView = class("RemoteNode", ccui.ImageView)
bind(RemoteImageView)
function RemoteImageView:reloadExtTexture( fullFileName )
	----print("RemoteImageView reloadExtTexture")
	self:loadTexture(fullFileName)
end
cc.exports.lib.node.RemoteImageView = RemoteImageView




local RemoteButton = class("RemoteNode",ccui.Button)
bind(RemoteButton)
function RemoteButton:reloadExtTexture( fullFileName )
	self:loadTextures(fullFileName,fullFileName,fullFileName)
end
cc.exports.lib.node.RemoteButton = RemoteButton






local RemoteSprite = class("RemoteSprite",cc.Sprite)
bind(RemoteSprite)
function RemoteSprite:reloadExtTexture( fullFileName )
	----print("RemoteSprite:reloadExtTexture")
	self:setTexture(fullFileName)
end
cc.exports.lib.node.RemoteSprite = RemoteSprite