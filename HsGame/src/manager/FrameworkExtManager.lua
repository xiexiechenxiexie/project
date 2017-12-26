--[[--
@author fly 在button回调中插入音效播放
]]
if not ccui.SYS_CCUI_WIDGET_CLICK_CALLBACK then 
	ccui.SYS_CCUI_WIDGET_CLICK_CALLBACK = ccui.Widget.addClickEventListener

	ccui.Widget.addClickEventListener = function ( __widget,__callback )

	     local outCall = function ( ... )
	     		print("outCall ccui.Widget Click")
	     		 __callback(...);
	     		if __widget.isNoSound then  return end
	     		local event = cc.EventCustom:new(config.EventConfig.EVENT_SOUND_PLAY)
				lib.EventUtils.dispatch(event)	
	     end
	     ccui.SYS_CCUI_WIDGET_CLICK_CALLBACK(__widget,outCall)
	end
end

if not ccui.SYS_CCUI_WIDGET_TOUCH_CALLBACK then
	ccui.SYS_CCUI_WIDGET_TOUCH_CALLBACK = ccui.Widget.addTouchEventListener
	ccui.Widget.addTouchEventListener = function (__target, __selector )
		print("outCall ccui.Widget addTouchEventListener")	
		local outCall = function ( ... )
			local arg = {...}
			__selector(...);
			if __target.isNoSound then  return end
			if arg[2]  ==  ccui.TouchEventType.ended then
				print("rouch ended")
	     		local event = cc.EventCustom:new(config.EventConfig.EVENT_SOUND_PLAY)
				lib.EventUtils.dispatch(event)	
			end
		end
		ccui.SYS_CCUI_WIDGET_TOUCH_CALLBACK(__target,outCall)
	end
end
print("FrameworkExtManager load ")