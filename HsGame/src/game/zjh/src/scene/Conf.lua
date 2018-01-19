-- 游戏配置及一些设置
local conf = {}

conf.MaxPlayerNum=5 		--最大玩家数

--枚举方法
local function creatEnumTable(tbl, index) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + i 
    end 
    return enumtbl 
end

--主场景图层值
local LayZ={						
	"ButtonNode",						--控件层
	"PlayerNode",						--玩家节点层
	"PlayerEffect",						--玩家效果层
}

conf.LayZ=creatEnumTable(LayZ,1)

--游戏按钮标签
local Tag={
	"back",						--退出
	"rule",						--规则
	"set",						--设置
	"shop",						--商城
	"pass",						--弃牌
	"all",						--全押
	"compare",					--比牌
	"add",						--加注
	"tracking",					--跟注
	"see",						--看牌
	"gdd",						--跟到底
	"PlayerCompare1",			--玩家比较按钮
	"PlayerCompare2",
	"PlayerCompare3",
	"PlayerCompare4",
	"PlayerCompare5",
}

conf.Tag=creatEnumTable(Tag,100)

--玩家节点位置
conf.PlayerNodePos=
{
	cc.p(490.17,219.28),
	cc.p(91.98,397.31),
	cc.p(345.01,636.27),
	cc.p(1136.52,636.27),
	cc.p(1242.97,397.31),
}

return conf