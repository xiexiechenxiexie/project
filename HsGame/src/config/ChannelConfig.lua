--[[--
@author fly
]]

local ChannleConfig = {channels = {}}
ChannleConfig.channels.CDNTEST = "cdntest" -- 

ChannleConfig.channels.YANGE = "yange"  --外网上线渠道号
ChannleConfig.channels.WINDOWS = "windows" -- 开发测试环境
ChannleConfig.channels.GUOQING = "guoqing" -- 国庆包
ChannleConfig.channels.OFFLINE = "n_xianxia_01" --线下渠道


ChannleConfig.channels.nn_appstore_01 = "nn_appstore_01" --appstore线上包
ChannleConfig.channels.nn_xianxia_01 = "nn_xianxia_01"  --appstore线上包

ChannleConfig.channels.nn_gf_android_01 = "nn_gf_android_01" --android 

cc.exports.config.ChannleConfig = ChannleConfig

cc.exports.config.channle = cc.exports.config.channle or {}
cc.exports.config.channle.VERSION = "1.1.0"
