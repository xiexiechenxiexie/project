set projectPath=%cd%
echo "project path:"%projectPath% 
cd ../../
::srcPath 源码目录
set srcPath=%cd%\tools\pack\encrypt\src 
::set srcPath=%cd%\src 
::dest 差异文件目录 目前没用到
set destPath=%cd%\dest
::pkg 热更文列表目录
set outPutpath=%cd%\pkg
::engineVersion 引擎目录
set engineVersion=3.15.0
::version 项目版本 
set /p version="input version string"
::packageUrl 远程链接
set /p packageUrl="input pkg url"
::packageUrl 是否生成本地描述文件
set /p local="if local manifestcreate y or n "


java -jar %cd%\tools\hot_update\hotupdate.jar  -src %srcPath% -dest %destPath% -pkgUrl %packageUrl%%version%/ -ev %engineVersion% -v %version%  -o %outPutpath% -a y 


set  model=Lobby
set  includes=Lobby,manager,config,lib,gamemodel,net,preload,gamecommon
java -jar %cd%\tools\hot_update\hotupdate.jar  -src %srcPath% -dest %destPath% -pkgUrl %packageUrl%%version%/%model%/ -ev %engineVersion% -v %version%  -o %outPutpath% -m %model%  -includes %includes% -local %local%

set  model=niuniu
set  includes=niuniu
java -jar %cd%\tools\hot_update\hotupdate.jar  -src %srcPath% -dest %destPath% -pkgUrl %packageUrl%%version%/%model%/ -ev %engineVersion% -v %version%  -o %outPutpath% -m %model%  -includes %includes% -local %local%


set  model=brnn
set  includes=brnn
java -jar %cd%\tools\hot_update\hotupdate.jar  -src %srcPath% -dest %destPath% -pkgUrl %packageUrl%%version%/%model%/ -ev %engineVersion% -v %version%  -o %outPutpath% -m %model%  -includes %includes% -local %local%

pause