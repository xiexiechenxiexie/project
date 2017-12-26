  -- todo:编译问题
  -- /Users/xiaxb/Documents/hsgm_client_android/HsGame/frameworks/cocos2d-x/cocos/scripting/lua-bindings/proj.android/../../../../external/lua/lsqlite3/sqlite3.c:29846:42: error: 'mmap' undeclared here (not in a function)
  --    { "mmap",         (sqlite3_syscall_ptr)mmap,            0 },
  --                                           ^
  -- [armeabi] Compile++ arm  : cocos2d_lua_static <= lua_cocos2dx_coco_studio_manual.cpp
  -- make: *** [/Users/xiaxb/Documents/hsgm_client_android/HsGame/frameworks/runtime-src/proj.android-studio/app/build/intermediates/ndkBuild/debug/obj/local/armeabi/objs-debug/cocos2d_lua_static/__/__/__/__/external/lua/lsqlite3/sqlite3.o] Error 1
  -- make: *** Waiting for unfinished jobs....
  -- /Users/xiaxb/Documents/hsgm_client_android/HsGame/frameworks/cocos2d-x/cocos/scripting/lua-bindings/proj.android/../manual/cocostudio/lua_cocos2dx_coco_studio_manual.cpp: In function 'int lua_cocos2dx_extension_Bone_getIgnoreMovementBoneData(lua_State*)':
  -- /Users/xiaxb/Documents/hsgm_client_android/HsGame/frameworks/cocos2d-x/cocos/scripting/lua-bindings/proj.android/../manual/cocostudio/lua_cocos2dx_coco_studio_manual.cpp:386:62: warning: 'virtual bool cocostudio::Bone::getIgnoreMovementBoneData() const' is deprecated (declared at /Users/xiaxb/Documents/hsgm_client_android/HsGame/frameworks/cocos2d-x/cocos/3d/../editor-support/cocostudio/CCBone.h:194) [-Wdeprecated-declarations]
  --          tolua_pushboolean(L, self->getIgnoreMovementBoneData());
                                                                -- ^





    -- dump(sqlite3)
    -- require "src/lib/db/Sqlite3Tool.lua"
    -- local dbPath = cc.FileUtils:getInstance():getWritablePath() .. "test.db"
    -- os.remove(dbPath)
    -- print(dbPath)
    -- db.Sqlite3Tool.createDB(dbPath)
    -- db.Sqlite3Tool.createTable()
    -- db.Sqlite3Tool.insert()
    -- local result = db.Sqlite3Tool.query()
    -- dump(result)

    -- db.Sqlite3Tool.close()
local Sqlite3Tool = {}

local function checkSqlite3Env( ... )
	assert(sqlite3,"invalid sqlite3")
end

local db = nil
Sqlite3Tool.createDB = function ( __dbName )
	checkSqlite3Env()
	os.remove(__dbName)
	db = sqlite3.open(__dbName)
end

Sqlite3Tool.createTable = function ( ... )
	checkSqlite3Env()
	if db then 
		db:exec('CREATE TABLE t(a, b)') 
		db:exec('commit') 
	end
end

Sqlite3Tool.query = function ( ... )
	checkSqlite3Env()
	if db then 
		assert(db:exec('select * from t', function (ud, ncols, values, names)
			
		    print(ud, ncols, values, names)
		    print((unpack or table.unpack)(values))

		end) == sqlite3.OK)
	end
end

Sqlite3Tool.insert = function ( ... )
	checkSqlite3Env()
	-- db:prepare('insert into t values(?, :bork)')
	if db then 
	    local vm = db:prepare('insert into t values(?, ?)')
	    db:exec('begin')
	    for i = 1, 100 do
	        vm:bind_values(i, i * 2 * -1^i)
	        vm:step()
	        vm:reset()
	    end
	    vm:finalize()
	    db:exec('commit')
	end
end

Sqlite3Tool.update = function ( ... )
	checkSqlite3Env()
	if db then 
		db:prepare('update tale set a = 123') 
		db:exec('commit') 
	end
end

Sqlite3Tool.delete = function ( ... )
	checkSqlite3Env()
end

Sqlite3Tool.close = function ( ... )
	checkSqlite3Env()
	assert(db:close() == sqlite3.OK)
end
cc.exports.db = cc.exports.db or {}
cc.exports.db.Sqlite3Tool = Sqlite3Tool