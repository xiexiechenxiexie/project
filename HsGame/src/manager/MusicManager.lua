--[[--
@author fly
]]
-- if cc.exports.manager.MusicManager then 
-- 	cc.exports.manager.MusicManager.destory()
-- 	cc.exports.manager.MusicManager = nil
-- end
-- if not cc.exports.manager.MusicManager then 
local audio = require "cocos/framework/audio.lua"

local MusicManager = class("MusicManager")

MusicManager.MUSICID_LOBBY = "Lobby/res/music/music.mp3"
MusicManager.MUSICID_BRNN = "game/brnn/res/music/music.mp3"
MusicManager.MUSICID_NIUNIU_SRF = "game/niuniu/res/music/music.mp3"
MusicManager.MUSICID_NIUNIU_COIN = "game/niuniu/res/music/music.mp3"
local MAX_AUDIO_INSTANCE = 30

local MUSIC_VOLUME="MUSIC_VOLUME"
local SOUND_VOLUME="SOUND_VOLUME"
local isAndroid = device.platform == "android"
MusicManager.musicId = ""
function MusicManager:ctor( ... )
	self:addEvents()
	local volume = cc.UserDefault:getInstance():getFloatForKey(MUSIC_VOLUME,1)
	if isAndroid  then
		audio.setMusicVolume(volume)
	end
	volume = cc.UserDefault:getInstance():getFloatForKey(SOUND_VOLUME,1)
	if isAndroid  then
		audio.setSoundsVolume(volume)
	end

	if not isAndroid then ccexp.AudioEngine:setMaxAudioInstance(MAX_AUDIO_INSTANCE) end
end

function MusicManager:addEvents( ... )
	print("MusicManager:addEvents")
	local listeners = {
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_SOUND_PLAY,handler(self,self.playSound)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_MUISIC_PLAY,handler(self,self.playMusic)),
		lib.EventUtils.createEventCustomListener(config.EventConfig.EVENT_MUISIC_STOP,handler(self,self.stopMusic)),
		lib.EventUtils.createEventCustomListener("APP_ENTER_BACKGROUND_EVENT",handler(self,self.background)),
		lib.EventUtils.createEventCustomListener("APP_ENTER_FOREGROUND_EVENT",handler(self,self.enter)),
	}
	lib.EventUtils.registeAllListeners(self,listeners)
end

function MusicManager:enter( ... )
	print("MusicManager:enter",self)
end

function MusicManager:background( ... )
	print("MusicManager:background",self)
end

function MusicManager:playMusic( __event )
	print("MusicManager:playMusic")
	if __event == nil then
		return 
	end
	local isLoop = true
	if type(__event.userdata.isLoop) == "boolean" then
		isLoop = __event.userdata.isLoop
	end
	local path  = nil
	if __event.userdata and __event.userdata.musicId  then path = __event.userdata.musicId end
	self:stopMusic()
	if path then
		if isAndroid  then 
			return audio.playMusic(path,isLoop)
		end
		MusicManager.musicId = path
		return ccexp.AudioEngine:play2d(path,isLoop,self:getMusicVolume())
	end
	return nil
	
end

function MusicManager:stopMusic( ... )
	print("MusicManager:stopMusic")
	if isAndroid  then 
		audio.stopMusic()
	else
		self:stopAudioEffect()
	end
	
end

--[[--
播放音乐文件
]]
function MusicManager:playSound( __event )
	print("MusicManager:playSound",self)
	if __event == nil then
		return 
	end
	local path = __event.userdata and __event.userdata.soundId or "Lobby/res/music/button_click.mp3"
	local isLoop = __event.isLoop
	if isLoop == nil then isLoop = false end
	if isAndroid  then return audio.playSound(path,isLoop) end
	return ccexp.AudioEngine:play2d(path,isLoop,self:getSoundsVolume())
end

function MusicManager:stopSound( ... )
	if isAndroid  then  audio.stopSound(true) end
end


function MusicManager:setMuscicVolume( __volume )
	if isAndroid  then  audio.setMusicVolume(__volume) end
	cc.UserDefault:getInstance():setFloatForKey(MUSIC_VOLUME,__volume)
	if not isAndroid then 
		self:stopAudioEffect()  
		print("重播音乐",MusicManager.musicId)
		ccexp.AudioEngine:play2d(self.musicId,true,__volume)  
	end
end



function MusicManager:setSoundVolume( __volume )
	if isAndroid  then  audio.setSoundsVolume(__volume) end
	cc.UserDefault:getInstance():setFloatForKey(SOUND_VOLUME,__volume)
	if __volume <= 0 then 
		self:stopAudioEffect()
	end
end

function MusicManager:stopAudioEffect( ... )
	if not isAndroid  then ccexp.AudioEngine:stopAll() print("stopAudioEffect") end
end

function MusicManager:stopAudioEffectById( __AudioeffectId )
	if not isAndroid  then ccexp.AudioEngine:stop(__AudioeffectId) end
end

function MusicManager:playAudioEffect( __path,__isLoop )
	if __isLoop == nil then __isLoop = false end
	if not isAndroid  then return ccexp.AudioEngine:play2d(__path,__isLoop,self:getSoundsVolume()) end
	return audio.playSound(__path,__isLoop)
end

function MusicManager:getMusicVolume( ... )
	local volume = cc.UserDefault:getInstance():getFloatForKey(MUSIC_VOLUME,1)
	return volume
end

function MusicManager:getSoundsVolume( ... )
	local  volume = cc.UserDefault:getInstance():getFloatForKey(SOUND_VOLUME,1)
	return volume
end

function MusicManager:onDestory( ... )
	print("MusicManager:onDestory")
	lib.EventUtils.removeAllListeners(self)
end

print("MusicManager load")
lib.singleInstance:bind(MusicManager)
cc.exports.manager.MusicManager = MusicManager
MusicManager:getInstance()
-- end
return cc.exports.manager.MusicManager
