local  MobClickForLua = {}

--[[ 设置是否打印sdk的log信息,默认不开启
	 @param value 设置为true,umeng SDK 会输出log信息,记得release产品时要设置回false.
	 @return .
	 @exception .
 ]]

function MobClickForLua.setLogEnabled(value)
	if umeng_setLogEnabled then umeng_setLogEnabled(value) end
end

--[[ 设置是否在android 6.0下获取mac信息,默认不开启
     @param value 设置为true,umeng SDK 采集mac信息.
     @return .
     @exception .
 ]]

function MobClickForLua.setCheckDevice(value)
    if umeng_setCheckDevice then umeng_setCheckDevice(value) end
end

--[[
	设置app切到后台经过多少秒之后，切到前台会启动新session,默认30
    @param seconds 秒数
    @return .
    @exception .
]]
function MobClickForLua.setSessionIdleLimit( seconds )
	-- body
	if umeng_setSessionIdleLimit then umeng_setSessionIdleLimit(seconds) end
end

--[[
    设置是否对日志信息进行加密, 默认false(不加密).
    @param value 设置为true, umeng SDK 会将日志信息做加密处理
    @return void.
]]
function MobClickForLua.setEncryptEnabled( value )
	-- body
	if umeng_setEncryptEnabled then umeng_setEncryptEnabled(value) end
end

--[[
	自定义事件,数量统计.
    使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID
         
    @param  eventId 网站上注册的事件Id.
    @param  label 分类标签。不同的标签会分别进行统计，方便同一事件的不同标签的对比,为NULL或空字符串时后台会生成和eventId同名的标签.
    @return void
    
    static void event(const char * eventId, const char * label = NULL);    

    自定义事件,数量统计.
    请注意：key不能含有“,”字符，value不能含有"|"字符
    这是因为不同shared library之间传递std对象可能引发兼容性问题，所以需要先将std对象转换成c语言的基本类型，
    在这里我会把eventDict转换成“k1,v1|k2,v2”形式的字符串
    使用前，请先到友盟App管理后台的设置->编辑自定义事件 中添加相应的事件ID，然后在工程中传入相应的事件ID
    
    static void event(const char * eventId, eventDict * attributes, int counter = 0)
]]
function MobClickForLua.event(eventId,...)
	-- body
	if umeng_event then umeng_event(eventId,...) end
end

--[[
    ---------------------------------------------------------------------------------------
    @name  页面计时
    --------------------------------------------------------------------------------------- 
]]
--[[ 
    页面时长统计,记录某个view被打开多长时间,可以自己计时也可以调用beginLogPageView,endLogPageView自动计时     
    @param pageName 需要记录时长的view名称.
    @return void.
]]
function MobClickForLua.beginLogPageView( pageViewName )
    -- body
    if umeng_beginLogPageView then umeng_beginLogPageView(pageViewName) end
end
function MobClickForLua.endLogPageView( pageViewName )
    -- body
    if umeng_endLogPageView then umeng_endLogPageView(pageViewName) end
end

--[[
    游戏统计开始    
    ---------------------------------------------------------------------------------------
    @name  账号
    ---------------------------------------------------------------------------------------
]]
--[[
    active user sign-in.
    使用sign-In函数后，如果结束该PUID的统计，需要调用sign-Off函数
    @param puid : user's ID
    @param provider : 不能以下划线"_"开头，使用大写字母和数字标识; 如果是上市公司，建议使用股票代码。
    @return void.
]]
function MobClickForLua.profileSignIn(puid,...)
    -- body
    if umeng_profileSignIn then umeng_profileSignIn(puid,...) end
end
--[[
    active user sign-off.
    停止sign-in PUID的统计
    @return void.
]]
function MobClickForLua.profileSignOff()
    -- body
    if umeng_profileSignOff then umeng_profileSignOff() end
end
--[[
    ---------------------------------------------------------------------------------------
    @name  玩家属性设置
    ---------------------------------------------------------------------------------------
]]
--[[
    设置玩家的等级、游戏中的唯一Id、性别、年龄和来源.    
    设置玩家等级属性.
    @param level 玩家等级
    @return void
]]
function MobClickForLua.setUserLevel( level )
    -- body
    if umeng_setUserLevel then  umeng_setUserLevel(level) end
end

--[[
    ---------------------------------------------------------------------------------------
    @name  关卡统计
    ---------------------------------------------------------------------------------------    
    记录玩家进入关卡，通过关卡及失败的情况.
]]
--[[
    进入关卡.
    @param level 关卡
    @return void
]]
function MobClickForLua.startLevel(level)
    -- body
    if umeng_startLevel then umeng_startLevel(level) end
end
--[[
    通过关卡.
    @param level 关卡,如果level == NULL 则为当前关卡
    @return void
]]
function MobClickForLua.finishLevel(level)
    -- body
    if umeng_finishLevel then umeng_finishLevel(level) end
end
--[[
    未通过关卡.
    @param level 关卡,如果level == NULL 则为当前关卡
    @return void
]]
function MobClickForLua.failLevel( level )
    -- body
    if umeng_failLevel then   umeng_failLevel(level)  end
end
--[[
    ---------------------------------------------------------------------------------------
    @name  支付统计
    ---------------------------------------------------------------------------------------  
    记录玩家使用真实货币的消费情况  
]]
--[[
    玩家支付货币兑换虚拟币.
    @param cash 真实货币数量
    @param source 支付渠道
    @param coin 虚拟币数量
    @return void
    static void pay(double cash, int source, double coin);

    @param cash 真实货币数量
    @param source 支付渠道
    @param item 道具名称
    @param amount 道具数量
    @param price 道具单价
    @return void
    static void pay(double cash, int source, const char * item, int amount, double price);
]]
function MobClickForLua.pay(cash,source,...)
    -- body
    if umeng_pay then umeng_pay(cash,source,...) end 
end
--[[
    ---------------------------------------------------------------------------------------
    @name  虚拟币购买统计
    ---------------------------------------------------------------------------------------    
    记录玩家使用虚拟币的消费情况
]]
--[[
    玩家使用虚拟币购买道具
    @param item 道具名称
    @param amount 道具数量
    @param price 道具单价
    @return void
]]
function MobClickForLua.buy( item,amount,price )
    -- body
    if umeng_buy then umeng_buy( item,amount,price ) end
end
--[[
    ---------------------------------------------------------------------------------------
    @name  道具消耗统计
    ---------------------------------------------------------------------------------------    
    记录玩家道具消费情况
]]
--[[
    玩家使用虚拟币购买道具
    @param item 道具名称
    @param amount 道具数量
    @param price 道具单价
    @return void
]]
function MobClickForLua.use( item,amount,price )
    -- body
    if umeng_use then  umeng_use(item,amount,price) end
end
--[[
    ---------------------------------------------------------------------------------------
    @name  虚拟币及道具奖励统计
    ---------------------------------------------------------------------------------------
    记录玩家获赠虚拟币及道具的情况
]]
--[[
    玩家获虚拟币奖励
    @param coin 虚拟币数量
    @param source 奖励方式
    @return void
    static void bonus(double coin, int source);

        
    玩家获道具奖励
    @param item 道具名称
    @param amount 道具数量
    @param price 道具单价
    @param source 奖励方式
    @return void
    static void bonus(const char * item, int amount, double price, int source);
]]
function MobClickForLua.bonus( ... )
    -- body
    if umeng_bonus then umeng_bonus(...) end
end

function MobClickForLua.setLatency(latency)
    -- body
    if umeng_setLatency then umeng_setLatency(latency) end
end

--[[
	开启sdk
	@param key appkey
    @param channel 渠道
    MOBCLICKCPP_START_WITH_APPKEY_AND_CHANNEL(appkey,channel)
]]
function MobClickForLua.startMobclick(key,...)
    -- body
    if key == "" or key == nil then
    	print("(MobClickCpp::startWithAppkey) appKey can not be NULL or \"\"!")
    	return
    end
    if umeng_mobclickstart then umeng_mobclickstart(key,...) end
end

-- 友盟key
MobClickForLua.Umeng_AppKey = "599eb2dae88bad22ed001075"

MobClickForLua.shareQQUrl = "shareQQUrl"                                -- 推广QQ分享
MobClickForLua.shareQQZoneUrl = "shareQQZoneUrl"                        -- 推广空间分享
MobClickForLua.shareWechatUrl = "shareWechatUrl"                        -- 推广微信分享
MobClickForLua.shareWechatCircleUrl = "shareWechatCircleUrl"            -- 推广QQ分享

cc.exports.MobClickForLua = MobClickForLua
-- return MobClickForLua









