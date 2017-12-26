@echo off

set DIR=%~dp0

echo - cleanup
if exist "%DIR%resources_src" rmdir /s /q "%DIR%resources_src"
if exist "%DIR%resources_res" rmdir /s /q "%DIR%resources_res"
if exist "%DIR%srcTmp" rmdir /s /q "%DIR%srcTmp"
if exist "%DIR%resTmp" rmdir /s /q "%DIR%resTmp"

mkdir "%DIR%resources_src"
mkdir "%DIR%resources_res"
::mkdir "%DIR%srcTmp"
mkdir "%DIR%resTmp"

::xcopy /s /q "%DIR%..\..\src\*.*" "%DIR%srcTmp"
xcopy /s /q "%DIR%..\..\src\*.*" "%DIR%resTmp"

::echo - encrypt scripts
::%DIR%win32\php.exe "%DIR%lib\compile_scripts.php" %* -i %DIR%srcTmp -o %DIR%resources_src\src -m files -ek YangeIt -es HsGame


echo - encrypt res
%DIR%win32\php.exe "%DIR%lib\encrypt_res.php" %* -i %DIR%resTmp -o %DIR%resources_res\src -ek YangeIt -es HsGame


if exist "%DIR%srcTmp" rmdir /s /q "%DIR%srcTmp"
if exist "%DIR%resTmp" rmdir /s /q "%DIR%resTmp"

::if exist "%DIR%src" rmdir /s /q "%DIR%src"
::mkdir "%DIR%src"

::xcopy /s /q "%DIR%resources_res\src\*.*" "%DIR%src"
::xcopy /s /q "%DIR%resources_src\src\*.*" "%DIR%src"

::if exist "%DIR%resources_res" rmdir /s /q "%DIR%resources_res"
if exist "%DIR%resources_src" rmdir /s /q "%DIR%resources_src"

pause