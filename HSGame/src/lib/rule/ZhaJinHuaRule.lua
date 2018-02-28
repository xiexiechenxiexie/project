-- 炸金花游戏数据
-- @author Tangwen
-- @date 2017.7.31

local ZhaJinHuaRule = class("ZhaJinHuaRule")

function ZhaJinHuaRule.create()
   self.GameID = 1003   	     	-- 游戏的ID号 唯一标识号
   self.GameRound = 0   	   	-- 游戏底分轮数
   self.GameBet = 0  		  	   -- 游戏底分 0-9 减一传给服务器
   self.AccountType = 0       	-- 算牛方法， 自动算牛"0"，手动算牛"1"，
   self.AuthorizeSitOpen = 0     -- 授权入座开启  0不开启，1表示开启
   self.AuthorizeSit = 0    	   -- 授权入座  0 默认关闭，1表示开启
   self.ChargeSit = 0 	   	   -- 收费入座  0 默认关闭，1表示开启
end

--算牛方法   游戏底分  授权入座 收费入座
function ZhaJinHuaRule.createRule()
	local rule = ""..ZhaJinHuaRule.AccountType..ZhaJinHuaRule.GameBet..ZhaJinHuaRule.AuthorizeSit..ZhaJinHuaRule.ChargeSit
	return rule
end

function ZhaJinHuaRule.parseRule( __str )
	assert(__str and type(__str) == "string" and  __str ~= "" ,"invalid params")
	local data = {}
	local i = 1
	data.AccountType = tonumber(string.sub(__str,i ,i))
	i = i + 1
	data.GameBet =  tonumber(string.sub(__str,i ,i )) + 1 
	i = i + 1
	data.AuthorizeSit  =  tonumber(string.sub(__str,i ,i))
	i = i + 1
	data.ChargeSit  =  tonumber(string.sub(__str,i ,i))
	return data
end

function ZhaJinHuaRule.isOpen( __value )
	return __value == 1
end

cc.exports.lib.singleInstance:bind(ZhaJinHuaRule)

cc.exports.lib.rule.ZhaJinHuaRule = ZhaJinHuaRule

return ZhaJinHuaRule