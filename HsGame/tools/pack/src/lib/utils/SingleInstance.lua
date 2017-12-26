--[[--
author fly

]]
local SingleInstance = {}

function SingleInstance:bind( classz )
	classz.instance = nil
	if not classz.getInstance then
		function classz:getInstance( ... )
			if classz.instance == nil  then
				classz.instance = classz:new()
			end
			return classz.instance
		end	
	end

	if not classz.destory then 
		function classz.destory( ... )
			local arg = {...}
			if classz.instance ~= nil  then
				if classz.instance.onDestory then
					classz.instance:onDestory()
				end
				classz.instance = nil
			end
		end	
	end
end

cc.exports.lib.singleInstance  = SingleInstance