echo - cleanup
set DIR=%~dp0
if exist "%DIR%src" rmdir /s /q "%DIR%src"

mkdir "%DIR%src"

xcopy /s /q "%DIR%..\..\src\*.*" "%DIR%src"

call python %DIR%lib\generateVersion.py

if exist "%DIR%src\ResPath.json" copy "%DIR%src\ResPath.json" "%DIR%..\..\src\Lobby\res\ResPath.json"

pause