set ZDIR=%~dp0
::生成ResPath.json
cd %ZDIR%\pack
call %ZDIR%\pack\resPath.bat


::参数矫正 正式环境
cd %ZDIR%\checker
call %ZDIR%\checker\checker.bat

::编译luac   tools\pack\encrypt\src
cd ..
call %ZDIR%\pack\encrypt\encrypt_all_platform.bat 
call %ZDIR%\pack\encrypt\build.bat

::生成热更文件   pkg\
cd %ZDIR%\hot_update
call %ZDIR%\hot_update\package.bat
