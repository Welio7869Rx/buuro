@echo off
setlocal enabledelayedexpansion

REM Build script para o Quiz do Bilhão em C++
if exist "quiz_bilhao.exe" del /f /q "quiz_bilhao.exe"

where g++ >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo Compilando com g++...
    g++ -std=c++17 quiz_bilhao.cpp -o quiz_bilhao.exe
    if %ERRORLEVEL% neq 0 (
        echo Erro na compilação com g++.
        exit /b %ERRORLEVEL%
    )
    echo Compilação concluída: quiz_bilhao.exe
    exit /b 0
)

echo g++ nao encontrado no PATH. Tentando CMake...
where cmake >nul 2>&1
if %ERRORLEVEL% == 0 (
    if not exist build mkdir build
    pushd build
    cmake ..
    if %ERRORLEVEL% neq 0 (
        echo Erro ao gerar o projeto CMake.
        popd
        exit /b %ERRORLEVEL%
    )
    cmake --build .
    if %ERRORLEVEL% neq 0 (
        echo Erro ao compilar com CMake.
        popd
        exit /b %ERRORLEVEL%
    )
    popd
    echo Compilação concluída via CMake.
    exit /b 0
)

echo Nenhum compilador apropriado encontrado. Instale g++ ou CMake.
exit /b 1
