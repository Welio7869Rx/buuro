@echo off
:: Jogo da Forca - Script de Execução
:: Windows Batch Script

setlocal enabledelayedexpansion

title Jogo da Forca - Carregando...

:: Verificar se Python está instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ============================================
    echo   ERRO: Python nao foi encontrado!
    echo ============================================
    echo.
    echo Por favor, instale Python 3.8 ou superior:
    echo https://www.python.org/downloads/
    echo.
    echo IMPORTANTE: Durante a instalacao, marque
    echo "Add Python to PATH"
    echo.
    pause
    exit /b 1
)

:: Exibir versão do Python
for /f "tokens=*" %%A in ('python --version') do set "VERSION=%%A"
echo.
echo ============================================
echo   🎮 JOGO DA FORCA 🎮
echo ============================================
echo.
echo   %VERSION%
echo   Iniciando jogo...
echo.
echo ============================================
echo.

:: Executar o jogo
python "%~dp0script.py"

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
