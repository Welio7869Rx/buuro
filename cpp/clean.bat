@echo off
setlocal
if exist "quiz_bilhao.exe" del /f /q "quiz_bilhao.exe"
if exist "build" (
    rd /s /q "build"
)
echo Limpeza concluida.
exit /b 0
