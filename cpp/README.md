# Quiz do Bilhão C++

Este diretório contém uma versão em C++ do quiz no estilo "Jogo do Bilhão".

## Como compilar

### Usando g++

No Windows com g++ instalado, execute:

```powershell
cd cpp
g++ -std=c++17 quiz_bilhao.cpp -o quiz_bilhao.exe
```

No Linux/macOS:

```bash
cd cpp
g++ -std=c++17 quiz_bilhao.cpp -o quiz_bilhao
```

### Usando CMake

```bash
cd cpp
mkdir -p build
cd build
cmake ..
cmake --build .
```

### Usando o atalho do Windows

```powershell
cd cpp
build.bat
```

## Como executar

No Windows:

```powershell
cd cpp
run.bat
```

Ou execute diretamente:

```powershell
./quiz_bilhao.exe
```

No Linux/macOS:

```bash
cd cpp
./quiz_bilhao
```

## Limpeza

No Windows:

```powershell
cd cpp
clean.bat
```

## Recursos desta versão

- 10 perguntas com valores progressivos
- 3 lifelines: 50/50, Pular e Ajuda da Plateia
- sistema de perguntas temáticas
- resumo final com prêmio seguro
