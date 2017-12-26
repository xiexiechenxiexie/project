-- 游戏常量
-- @author Tangwen
-- @date 2017.7.20


local GameData = GameData or {}

function GameData.reset()
	GameData.GameID = 0   	-- 游戏的ID号 唯一标识号
	GameData.GameToken = "nilStr"  -- 登陆返回的一个token 登陆游戏时需要传入
   GameData.TableID = 0		-- 房间号
   GameData.GameGradeType = 0	-- 游戏等级格式 新手 精英  大师
   GameData.GameType = 0 -- 游戏房间格式  金币场 私人房
   GameData.GameIP = "nilStr"		-- 游戏的网关
   GameData.GamePort = "nilStr"	-- 网关端口
   GameData.isCreator = nil -- 是否是房主 每次返回大厅则初始化数据
   GameData.GameRoundNum = 0      	-- 游戏局数 
   GameData.GamePlayerNum = 0       -- 游戏人数
   GameData.GameName = "nilStr"		-- 游戏名称
   GameData.IntoGameType = nil   -- 进入游戏方式 0 创建房间 1 加入房间
   GameData.writeTableID = nil     -- 输入的房间号  加入房间使用
end

cc.exports.GameData = GameData