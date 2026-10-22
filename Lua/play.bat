@echo off
REM Jogo da Forca com NPC - Script de Execução (Lua)

setlocal enabledelayedexpansion

title Jogo da Forca - Lua - Carregando...

REM Verificar se Lua está instalado
lua -v >nul 2>&1
if errorlevel 1 (
    lua5.1 -v >nul 2>&1
    if errorlevel 1 (
        lua5.3 -v >nul 2>&1
        if errorlevel 1 (
            echo.
            echo ============================================
            echo   ERRO: Lua nao foi encontrado!
            echo ============================================
            echo.
            echo Por favor, instale Lua:
            echo https://www.lua.org/download.html
            echo.
            echo Opcoes:
            echo 1. Download direto (Windows)
            echo 2. Chocolatey: choco install lua
            echo 3. WSL: sudo apt install lua5.1
            echo.
            pause
            exit /b 1
        ) else (
            set LUA_CMD=lua5.3
        )
    ) else (
        set LUA_CMD=lua5.1
    )
) else (
    set LUA_CMD=lua
)

REM Exibir versão
echo.
echo ============================================
echo   🎮 JOGO DA FORCA COM NPC - LUA
echo ============================================
echo.

for /f "tokens=*" %%A in ('%LUA_CMD% -v') do set "VERSION=%%A"
echo   %VERSION%
echo   Iniciando jogo...
echo.
echo ============================================
echo.

REM Executar o jogo
%LUA_CMD% "%~dp0main.lua"

if errorlevel 1 (
    echo.
    echo ============================================
    echo   ERRO ao executar o jogo!
    echo ============================================
    echo.
    pause
    exit /b 1
)

exit /b 0
