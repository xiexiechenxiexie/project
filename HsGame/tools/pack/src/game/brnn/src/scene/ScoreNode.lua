-- 分数节点
local GameResPath  = "game/brnn/res/GameLayout/"
local conf = require"game/brnn/src/scene/Conf"
local ScoreNode = class("ScoreNode", cc.Node)
local TEMP_X = 18    		--字体间隔
local TEMP_TIME = 0.05		--字体弹出时间间隔
local REMOVE_TIME = 1.5		--移除字体延迟时间


function ScoreNode:ctor(str)
    self:init(str)
end

function ScoreNode:init(str)
	local LabArray={}
	local StrArray=string.toTable(str)
	if StrArray==nil then
		print("传入参数错误")
		return 
	end
	
	local strFile=nil
	if StrArray[1]=="-" then
		strFile=GameResPath.."num_lose.png"
	else
		strFile=GameResPath.."num_win.png"
		table.insert(StrArray,1,"+")
	end
	local node=cc.Node:create()
	self:addChild(node)
	local ppos=0
	for i,v in ipairs(StrArray) do
		local ScoreLab=cc.Label:createWithCharMap(strFile,31,34,string.byte(','))
		node:addChild(ScoreLab)
		local value=nil
		if v=="万" then
			value=","
			ppos=ppos+TEMP_X+10
		elseif v=="亿" then
			value="-"
			ppos=ppos+TEMP_X+10
		elseif v=="." then
			value="."
			ppos=ppos+TEMP_X
		elseif v=="+" then
			value="/"
			ppos=ppos+TEMP_X
		elseif v=="-" then
			value="/"
			ppos=ppos+TEMP_X
		elseif string.byte(v)>=string.byte('0') and string.byte(v)<=string.byte('9') then
			value=v
			ppos=ppos+TEMP_X
		end
		if i==1 then
			ppos=0
		end
		ScoreLab:setPosition(ppos,0)
		ScoreLab:setString(value)
		table.insert(LabArray,ScoreLab)
	end
	node:setPosition(-ppos/2,0)
	self.LabArray=LabArray
	if self.LabArray==nil then
		return
	end
	local num=#LabArray
	for i,v in ipairs(self.LabArray) do
		local pposx=v:getPositionX()
		self:ScoreAct(v,i,pposx,num)
	end
end

function ScoreNode:ScoreAct(target,index,pposx,num)
	local a={}
	a[#a+1]=cc.DelayTime:create((index-1)*TEMP_TIME)
	a[#a+1]=cc.JumpTo:create(0.2, cc.p(pposx,60),30,1)
	if index==num then
		a[#a+1]=cc.CallFunc:create(function()
			self:reset()
		end)
	end
	if target then
		target:runAction(cc.Sequence:create(a))
	end
end

function ScoreNode:reset()
	local a={}
	a[#a+1]=cc.DelayTime:create(REMOVE_TIME)
	a[#a+1]=cc.CallFunc:create(function()
			self:removeFromParent()
	end)
	self:runAction(cc.Sequence:create(a))
end

return ScoreNode