-- 游戏玩家列表

local GameResPath  = "game/brnn/res/GameLayout/"
local goldResPath="game/brnn/res/GameLayout/gold_ico.png"
local conf = require"game/brnn/src/scene/Conf"
--随机区域
local Rand_X=conf.Rand_X
local Rand_Y=conf.Rand_Y
--金币总数量
local GOLD_NUM=conf.GOLD_NUM
--下注区域数量
local QUYU_NUM=conf.QUYU_NUM
--椅子座位数量
local SIT_NUM=conf.SIT_NUM

local GoldLayer = class("GoldLayer", cc.Layer)

function GoldLayer:ctor()
	self.GoldMovePos={}
	--所有金币
	self.GoldTab={}

	--区域金币
	self.QuYuGoldTab={}

    self:init()
end

function GoldLayer:init()
	self.GoldTab.SpArray={}
	for i=1,GOLD_NUM do
		sp=cc.Sprite:create(goldResPath)
		sp:setVisible(false)
		self:addChild(sp)
		table.insert(self.GoldTab.SpArray,sp)
	end
	--当前已显示金币数量
	self.GoldTab.ShowNum=0

	--各区域已显示金币数量
	self.QuYuShowNum={}

	for i=1,QUYU_NUM do
		local tab={}
		tab.SpArray={}
		table.insert(self.QuYuGoldTab,tab)
		table.insert(self.QuYuShowNum,0)
	end
	--设置随机数种子
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	for i=1,conf.SIT_NUM do
		--玩家座位
		local s_pos=cc.p(conf.PlayerNodePos[i].x,conf.PlayerNodePos[i].y+50)
		local str="Player"..tostring(i)
		self:setGoldMovePos(str,s_pos)
	end

	--自己位置
	self.GoldMovePos.Player7=conf.MyHeadPos
	--庄家位置
	self.GoldMovePos.Player8=conf.ZhuangHeadPos

	--记录金币位置
	self.GoldPos={}
end

--玩家下注
function GoldLayer:PlayerXiaZhu(SrcIndex,DestIndex,goldIndex,uid)
	if SrcIndex<-1 or SrcIndex >5 or DestIndex<0 or DestIndex>3 then
		printInfo("玩家下注索引错误")
		return 
	end
	local srcIndex=SrcIndex
	local uuid=uid or 0
	if tostring(uuid)==tostring(UserData.userId) then
		srcIndex=6
	end
	srcIndex=srcIndex+1
	local destIndex=DestIndex+1
	local GoldNum=self:IndexToGoldNum(goldIndex)
	local srcPos=nil
	local destPos=nil
	local str="Player"..tostring(srcIndex)
	srcPos=self.GoldMovePos[str]
	str= "xiazhu"..tostring(destIndex)
	destPos=self.GoldMovePos[str]
	if self.GoldTab.ShowNum+GoldNum>GOLD_NUM then
		printInfo("金币数太大")
		return
	end
	for i=self.GoldTab.ShowNum+1,self.GoldTab.ShowNum+GoldNum do
		--随机分散坐标
		local index=i-self.GoldTab.ShowNum
		local Dpos=self:setPosRand(destPos)
		self:XiaZhuMoveAction(self.GoldTab.SpArray[i],srcPos,Dpos,index)
		table.insert(self.QuYuGoldTab[destIndex].SpArray,self.GoldTab.SpArray[i])
	end
	self.QuYuShowNum[destIndex]=self.QuYuShowNum[destIndex]+GoldNum
	self.GoldTab.ShowNum=self.GoldTab.ShowNum+GoldNum
end

--庄家大于牛七,庄家赢了,玩家多倍赔钱
function GoldLayer:PlayerPeiGold(DataArray)
	local myWinArray=DataArray.myWinArray
	local sitWinArray=DataArray.sitWinArray
	local zhuangWinArray=DataArray.zhuangWinArray
	if myWinArray==nil or sitWinArray==nil or zhuangWinArray==nil then
		return
	end
	local numTab={}
	for i,v in ipairs(zhuangWinArray) do
		local num=nil
		if v>0 then
			num=self:ScoretoGoldNum(v)
		else
			num=0
		end
		table.insert(numTab,num)
	end
	for i,v in ipairs(myWinArray) do
		if v<0 then
			local num=self:ScoretoGoldNum(v)
			if self.GoldTab.ShowNum+num>GOLD_NUM then
				printInfo("金币数太大")
				for i,v in ipairs(numTab) do
					v=0
				end
				return
			end
			local str= "xiazhu"..tostring(i)
			local destPos=self.GoldMovePos[str]
			local srcPos=self.GoldMovePos.Player7
			local TempIndex=0.5/num
			for j=self.GoldTab.ShowNum+1,self.GoldTab.ShowNum+num do
				local index=j-self.GoldTab.ShowNum
				local Dpos=self:setPosRand(destPos)
				self:PlayerPeiGoldMoveAction(self.GoldTab.SpArray[j],srcPos,Dpos,index,TempIndex)
				table.insert(self.QuYuGoldTab[i].SpArray,self.GoldTab.SpArray[j])
			end
			self.QuYuShowNum[i]=self.QuYuShowNum[i]+num
			self.GoldTab.ShowNum=self.GoldTab.ShowNum+num
			numTab[i]=numTab[i]-num
		end
	end
	local isHaveSit={false,false,false,false,false,false}
	local tab={}
	for i,v in ipairs(sitWinArray) do
		local score=0
		if tostring(v.uid)~=tostring(UserData.userId) then
			for a,b in ipairs(v.score) do
				if b<0 then
					local num=self:ScoretoGoldNum(b)
					if self.GoldTab.ShowNum+num>GOLD_NUM then
						printInfo("金币数太大")
						for i,v in ipairs(numTab) do
							v=0
						end
						return
					end
					if num>self.QuYuShowNum[a] then
						num=self.QuYuShowNum[a]
					end
					local str= "xiazhu"..tostring(a)
					local destPos=self.GoldMovePos[str]
					str="Player"..tostring(i)
					local srcPos=self.GoldMovePos[str]
					local TempIndex=0.5/num
					for j=self.GoldTab.ShowNum+1,self.GoldTab.ShowNum+num do
						local index=j-self.GoldTab.ShowNum
						local Dpos=self:setPosRand(destPos)
						self:PlayerPeiGoldMoveAction(self.GoldTab.SpArray[j],srcPos,Dpos,index,TempIndex)
						table.insert(self.QuYuGoldTab[a].SpArray,self.GoldTab.SpArray[j])
					end
					self.QuYuShowNum[a]=self.QuYuShowNum[a]+num
					self.GoldTab.ShowNum=self.GoldTab.ShowNum+num
					numTab[a]=numTab[a]-num
				end
			end
		end
	end
	for i,v in ipairs(numTab) do
		if v>0 then
			local num=v
			if self.GoldTab.ShowNum+num>GOLD_NUM then
				printInfo("金币数太大")
				return
			end
			local str= "xiazhu"..tostring(i)
			local destPos=self.GoldMovePos[str]
			local srcPos=self.GoldMovePos.Player0
			local TempIndex=0.5/num
			for j=self.GoldTab.ShowNum+1,self.GoldTab.ShowNum+num do
				local index=j-self.GoldTab.ShowNum
				local Dpos=self:setPosRand(destPos)
				self:PlayerPeiGoldMoveAction(self.GoldTab.SpArray[j],srcPos,Dpos,index,TempIndex)
				table.insert(self.QuYuGoldTab[i].SpArray,self.GoldTab.SpArray[j])
			end
			self.QuYuShowNum[i]=self.QuYuShowNum[i]+num
			self.GoldTab.ShowNum=self.GoldTab.ShowNum+num
		end
	end
end

--庄家收钱
function GoldLayer:ZhuangGetGold(SrcIndex)
	if self.QuYuGoldTab[SrcIndex+1].num==0 then
		printInfo("没钱庄家不能收钱")
		return
	end
	if SrcIndex<0 or SrcIndex>3 then
		printInfo("庄家收钱索引错误",SrcIndex)
		return 
	end
	local srcIndex=SrcIndex+1
	local destPos=self.GoldMovePos.Player8
	local TempIndex=0.5/self.QuYuShowNum[srcIndex]
	for i=1,self.QuYuShowNum[srcIndex] do
		self:ZhuangGetMoveAction(self.QuYuGoldTab[srcIndex].SpArray[i],destPos,i,TempIndex)
	end
	self.QuYuGoldTab[srcIndex].SpArray={}
	self.QuYuShowNum[srcIndex]=0
end

--庄家吐钱
function GoldLayer:ZhuangLossGold(DestIndex,Score)
	local GoldNum=self:ScoretoGoldNum(Score)
	if  DestIndex<0 or DestIndex>3 then
		printInfo("庄家吐钱索引错误",srcIndex,destIndex)
		return 
	end
	local srcIndex=SrcIndex
	local destIndex=DestIndex+1
	local str="xiazhu"..tostring(destIndex)
	local srcPos=self.GoldMovePos.Player8
	local destPos=self.GoldMovePos[str]
	if self.GoldTab.ShowNum+GoldNum>GOLD_NUM then
		printInfo("金币数太大")
		GoldNum=0
	end
	local TempIndex=0.5/GoldNum
	for i=self.GoldTab.ShowNum+1,self.GoldTab.ShowNum+GoldNum do
		--随机分散坐标
		local Dpos=self:setPosRand(destPos)
		local index=i-self.GoldTab.ShowNum
		self:ZhuangLossMoveAction(self.GoldTab.SpArray[i],srcPos,Dpos,index,TempIndex)
		table.insert(self.QuYuGoldTab[destIndex].SpArray,self.GoldTab.SpArray[i])
	end
	self.QuYuShowNum[destIndex]=self.QuYuShowNum[destIndex]+GoldNum
	self.GoldTab.ShowNum=self.GoldTab.ShowNum+GoldNum
end

--玩家收钱
function GoldLayer:PlayerGetGold(DataArray)
	local myWinArray=DataArray.myWinArray
	local sitWinArray=DataArray.sitWinArray
	if sitWinArray==nil or myWinArray==nil then
		return
	end
	for i,v in ipairs(myWinArray) do
		if v>0 then
			local num=self:ScoretoGoldNum(v)*2
			if num>self.QuYuShowNum[i] then
				num=self.QuYuShowNum[i]
			end
			local destPos=self.GoldMovePos.Player7
			local TempIndex=0.5/num
			for j=self.QuYuShowNum[i]-num+1,self.QuYuShowNum[i] do
				local index=j-self.QuYuShowNum[i]+num
				self:PlayerGetGoldMoveAction(self.QuYuGoldTab[i].SpArray[j],destPos,index,TempIndex)
			end
			self.QuYuShowNum[i]=self.QuYuShowNum[i]-num
		end
	end

	for i,v in ipairs(sitWinArray) do
		if tostring(v.uid)~=tostring(UserData.userId) then
			for a,b in ipairs(v.score) do
				if b>0 then
					local num=self:ScoretoGoldNum(b)*2
					if num>self.QuYuShowNum[a] then
						num=self.QuYuShowNum[a]
					end
					local str="Player"..tostring(i)
					local destPos=self.GoldMovePos[str]
					local TempIndex=0.5/num
					for j=self.QuYuShowNum[a]-num+1,self.QuYuShowNum[a] do
						local index=j-self.QuYuShowNum[a]+num
						self:PlayerGetGoldMoveAction(self.QuYuGoldTab[a].SpArray[j],destPos,index,TempIndex)
					end
					self.QuYuShowNum[a]=self.QuYuShowNum[a]-num
				end
			end
		end
	end
	for i,v in ipairs(self.QuYuShowNum) do
		if v>0 then
			local destPos=self.GoldMovePos.Player0
			local TempIndex=0.5/v
			for j=1,v do
				self:PlayerGetGoldMoveAction(self.QuYuGoldTab[i].SpArray[j],destPos,j,TempIndex)
			end
		end
	end
end

--下注索引转换为金币数量
function GoldLayer:IndexToGoldNum(goldIndex)
	local num=goldIndex+1
	-- local num=goldIndex+1+goldIndex*5
	return num
end

--下注金额装换为金币数量
function GoldLayer:ScoretoGoldNum(Score)
	local num=0
	local score=math.abs(Score)
	if math.modf(score/1000000)>0 then
		num=num+math.modf(score/1000000)*5
		score=score%1000000
	end
	if math.modf(score/100000)>0 then
		num=num+math.modf(score/100000)*4
		score=score%100000
	end
	if math.modf(score/10000)>0 then
		num=num+math.modf(score/10000)*3
		score=score%10000
	end
	if math.modf(score/1000)>0 then
		num=num+math.modf(score/1000)*2
		score=score%1000
	end
	if math.modf(score/100)>0 then
		num=num+math.modf(score/100)*1
		score=score%100
	end
	return num
end

--设置金币移动节点位置
function GoldLayer:setGoldMovePos(keyStr,p)
    self.GoldMovePos[keyStr]=p
end

--重置
function GoldLayer:reset()
	for i,v in ipairs(self.QuYuGoldTab) do
		for a,b in ipairs(v.SpArray) do
			b:setVisible(false)
		end
		v.SpArray={}
		self.QuYuShowNum[i]=0
	end
	for i=1,self.GoldTab.ShowNum do
		if self.GoldTab.SpArray[i] then
			self.GoldTab.SpArray[i]:setVisible(false)
			self.GoldTab.SpArray[i]:stopAllActions()
		end
	end
    self.GoldTab.ShowNum = 0
end

--重置
function GoldLayer:getShowGoldNum()
	return self.GoldTab.ShowNum
end

--设置下注区域位置随机
function GoldLayer:setPosRand(Pos)
	local xx=Rand_X/2-Rand_X*math.random()
	local yy=Rand_Y/2-Rand_Y*math.random()
	local ppos={}
	ppos.x=Pos.x+xx
	ppos.y=Pos.y+yy-5
	return ppos
end

--玩家下注金币动画
function GoldLayer:XiaZhuMoveAction(Target,srcPos,destpos,index)
	Target:stopAllActions()
	Target:setPosition(srcPos)
	Target:setVisible(true)
	local bezier = {
		srcPos,
    	cc.p((srcPos.x+destpos.x)/2,(srcPos.y+destpos.y)/2+100),
    	destpos,
  	}
  	local bezierForward = cc.BezierTo:create(0.5+(index-1)*0.05, bezier)
    Target:runAction(bezierForward)
end


--玩家多倍赔钱金币动画
function GoldLayer:PlayerPeiGoldMoveAction(Target,srcPos,destpos,index,tempIndex)
	Target:stopAllActions()
	Target:setPosition(srcPos)
	Target:setVisible(true)
	local bezier = {
		srcPos,
    	cc.p((srcPos.x+destpos.x)/2,(srcPos.y+destpos.y)/2+100),
    	destpos,
  	}
  	local bezierForward = cc.BezierTo:create(0.4+(index-1)*tempIndex, bezier)
  	Target:runAction(bezierForward)
end

--庄家收钱金币动画
function GoldLayer:ZhuangGetMoveAction(Target,destpos,index,tempIndex)
	Target:stopAllActions()
	Target:setVisible(true)
  	local xx,yy=Target:getPosition()
  	local srcPos=cc.p(xx,yy)
 	local bezier = {
		srcPos,
    	cc.p((srcPos.x+destpos.x)/2,(srcPos.y+destpos.y)/2+100),
    	destpos,
  	}
  	local bezierForward = cc.BezierTo:create(0.4+(index-1)*tempIndex, bezier)
  	local callfunc=cc.CallFunc:create(function(sender)
    		sender:setVisible(false)
    	end)
  	local  seq=cc.Sequence:create(bezierForward,callfunc)
  	Target:runAction(seq)
end

--庄家吐钱金币动画
function GoldLayer:ZhuangLossMoveAction(Target,srcPos,destpos,index,tempIndex)
	Target:stopAllActions()
	Target:setPosition(srcPos)
	Target:setVisible(true)

    local bezier = {
		srcPos,
    	cc.p((srcPos.x+destpos.x)/2,(srcPos.y+destpos.y)/2+100),
    	destpos,
  	}
  	local bezierForward = cc.BezierTo:create(0.4+(index-1)*tempIndex, bezier)
    Target:runAction(bezierForward)
end

--玩家得金币动画
function GoldLayer:PlayerGetGoldMoveAction(Target,destpos,index,tempIndex)
	Target:stopAllActions()
	Target:setVisible(true)
	local xx,yy=Target:getPosition()
  	local srcPos=cc.p(xx,yy)
	local bezier = {
		srcPos,
    	cc.p((srcPos.x+destpos.x)/2,(srcPos.y+destpos.y)/2+100),
    	destpos,
  	}
  	local bezierForward = cc.BezierTo:create(0.4+(index-1)*tempIndex, bezier)
  	local callfunc=cc.CallFunc:create(function(sender)
    		sender:setVisible(false)
    	end)
  	local  seq=cc.Sequence:create(bezierForward,callfunc)
  	Target:runAction(seq)
end

-------------------------------------------------断线重连的一些接口-------------------------------------------------
--玩家下注
function GoldLayer:setXiaZhuGold(dataArray)
	if dataArray==nil then
		return
	end
	for i,v in ipairs(dataArray) do
		local GoldNum=self:ScoretoGoldNum(v)
		local str= "xiazhu"..tostring(i)
		local destPos=self.GoldMovePos[str]
		for j=self.GoldTab.ShowNum+1,self.GoldTab.ShowNum+GoldNum do
			self.GoldTab.SpArray[j]:setPosition(self:setPosRand(destPos))
			self.GoldTab.SpArray[j]:setVisible(true)
			table.insert(self.QuYuGoldTab[i].SpArray,self.GoldTab.SpArray[j])
		end
		self.QuYuShowNum[i]=GoldNum
		self.GoldTab.ShowNum=self.GoldTab.ShowNum+GoldNum
	end
end
-------------------------------------------------断线重连的一些接口-------------------------------------------------

return GoldLayer