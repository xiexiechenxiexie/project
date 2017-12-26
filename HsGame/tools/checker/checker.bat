
cd ../../
::srcPath 源码目录
set projectPath=%cd%
echo "project path:"%projectPath% 
set srcPath=%projectPath% 

::version 项目版本 
set /p version="version:"
::packageUrl 远程链接
set /p channel="channel:"

java -jar %cd%\tools\checker\checker.jar  -s %srcPath% -v %version% -c %channel%
pause