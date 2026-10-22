@echo off
:: Script de execução melhorado com menu
setlocal enabledelayedexpansion

:menu
cls
echo.
echo ============================================
echo     JOGO DA FORCA - MENU PRINCIPAL
echo ============================================
echo.
echo [1] Jogar Jogo da Forca
echo [2] Ver Requisitos do Sistema
echo [3] Verificar Instalacao Python
echo [4] Abrir Documentacao
echo [5] Sair
echo.
set /p choice="Escolha uma opcao [1-5]: "

if "%choice%"=="1" goto play
if "%choice%"=="2" goto requirements
if "%choice%"=="3" goto check_python
if "%choice%"=="4" goto docs
if "%choice%"=="5" exit /b 0
goto menu

:play
cls
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERRO: Python nao encontrado!
    echo.
    echo Instale Python em: https://www.python.org/downloads/
    echo Lembre-se de marcar "Add Python to PATH"
    echo.
    pause
    goto menu
)
echo.
python "%~dp0script.py"
pause
goto menu

:requirements
cls
echo.
echo ============================================
echo       REQUISITOS DO SISTEMA
echo ============================================
echo.
echo   Python:   3.8 ou superior
echo   SO:       Windows 7 ou superior
echo   RAM:      256 MB minimo
echo   Disco:    100 MB minimo
echo.
echo   Recomendado:
echo   - Python 3.10+
echo   - Windows 10 ou superior
echo   - 512 MB+ RAM
echo.
pause
goto menu

:check_python
cls
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo PYTHON NAO ENCONTRADO!
    echo.
    echo Execute: python --version
    echo em um terminal para verificar
    echo.
) else (
    for /f "tokens=*" %%A in ('python --version') do set "VERSION=%%A"
    echo.
    echo ✓ Python instalado: %VERSION%
    echo.
)
pause
goto menu

:docs
cls
echo.
echo ============================================
echo          DOCUMENTACAO
echo ============================================
echo.
echo Arquivos:
echo  - INSTALL.md      (Guia de instalacao)
echo  - README.md       (Guia principal)
echo  - script.py       (Codigo fonte)
echo  - play.bat        (Execucao rapida)
echo.
pause
goto menu
