@echo off
setlocal
if exist "quiz_bilhao.exe" (
    quiz_bilhao.exe
    exit /b %ERRORLEVEL%
)

echo Executavel nao encontrado. Execute build.bat primeiro.
exit /b 1
