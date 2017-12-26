@echo off

set DIR=%~dp0

echo - cleanup
if exist "%DIR%src" rmdir /s /q "%DIR%src"

mkdir "%DIR%src"

xcopy /s /q "%DIR%..\..\..\src\*.*" "%DIR%src"

echo - encrypt lua file

cocos luacompile -e -k YangeIt -b HsGame -s "%DIR%src" -d "%DIR%src" --disable-compile

echo finish

pause
