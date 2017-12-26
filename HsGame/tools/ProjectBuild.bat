:project_input  
@echo 请输入项目名称，按回车，例：HelloWorld  
@set /p project_name=  
@if "%project_name%"=="" echo.项目名称不能为空！！&goto :project_input  
  
  
:package_input  
@echo 请输入包名，按回车，例：com.sample.test  
@set /p package_name=  
@if "%package_name%"=="" echo.包名不能为空！！&goto :package_input  
  
:lan_input  
@echo 请输入语言类型(cpp lua js)，按回车，例：lua  
@set /p lan_name=  
@if "%lan_name%"=="" echo.语言类型不能为空！！&goto :lan_input  
  
:dir_input  
@echo 请输入工程文件夹，目录位置，按回车，例：cocos  
@set /p dir_name=  
@if "%dir_name%"=="" echo.工程文件夹不能为空！！&goto :dir_input  
  
  
@echo 开始创建工程:%project_name%，包名：%package_name%，语言类型：%lan_name%，工程文件夹：%dir_name%  
@cocos new %project_name% -p %package_name% -l %lan_name% -d %dir_name% 
@if not exist "%dir_name%" echo.创建失败！！&goto :end  
  
  
@start ""  "%dir_name%"  
@echo 创建完成!  
:end  
pause  