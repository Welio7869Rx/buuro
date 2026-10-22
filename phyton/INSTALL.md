# 🐍 Guia de Instalação - Python

## ⚙️ Pré-requisitos

### Windows
- Python 3.8 ou superior
- Permissão para instalar programas

---

## 📥 Instalação do Python

### Opção 1: Microsoft Store (Recomendado ✅)
1. Abra o **Microsoft Store**
2. Procure por **"Python"**
3. Selecione a versão mais recente (3.11+)
4. Clique em **"Instalar"**
5. Aguarde a conclusão

### Opção 2: python.org
1. Acesse https://www.python.org/downloads/
2. Baixe **Python 3.11+**
3. Execute o instalador
4. ✅ **IMPORTANTE:** Marque "Add Python to PATH"
5. Clique em **"Install Now"**

### Opção 3: Chocolatey (Windows)
Se você tem Chocolatey instalado:
```powershell
choco install python
```

### Opção 4: Winget (Windows 10+)
```powershell
winget install Python.Python.3.11
```

---

## ✅ Verificar Instalação

Abra o **PowerShell** ou **CMD** e execute:

```bash
python --version
```

Você deve ver algo como:
```
Python 3.11.5
```

Se receber um erro, reinicie seu computador e tente novamente.

---

## 🎮 Executar o Jogo

### Método 1: Duplo-clique (Mais Fácil)
1. Na pasta `phyton/`, encontre **`play.bat`** (será criado)
2. Dê duplo-clique nele
3. O jogo começará automaticamente

### Método 2: PowerShell/CMD
```bash
cd "c:\Users\Aluno\Desktop\Nova pasta\phyton"
python script.py
```

### Método 3: VS Code
1. Abra a pasta do projeto
2. Clique direito em `script.py`
3. Selecione "Run Python File in Terminal"

---

## 🔧 Solução de Problemas

### ❌ "Python não foi encontrado"
**Solução:** Python não está instalado ou não está no PATH.
- Reinstale Python com a opção "Add Python to PATH" marcada
- Reinicie o computador

### ❌ "ModuleNotFoundError: No module named 'asyncio'"
**Solução:** Sua versão de Python é muito antiga (precisa 3.8+)
- Atualize para Python 3.10 ou superior

### ❌ Som não funciona
**Solução:** Seu sistema não suporta `winsound` (provavelmente Linux)
- Use a versão JavaScript web em vez disso
- O jogo ainda funcionará sem som

### ❌ "Permission denied"
**Solução:** Falta de permissões para executar
```bash
# No PowerShell como Admin:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📊 Requisitos do Sistema

| Requisito | Mínimo | Recomendado |
|-----------|---------|------------|
| Python | 3.8 | 3.10+ |
| RAM | 256 MB | 512 MB |
| Disco | 100 MB | 500 MB |
| SO | Windows 7+ | Windows 10+ |

---

## 🎯 Próximos Passos

Após instalar Python com sucesso:

1. ✅ Execute o jogo: `python script.py`
2. 📖 Leia o [README.md](../README.md) principal
3. 🌐 Teste também a versão web em `html/index.html`
4. 🔷 Se tiver .NET 6+, teste a versão C# também

---

## 💡 Dicas

- **Primeiro uso:** O jogo pode demorar um pouco para carregar a primeira vez
- **Som:** Certifique-se que seu volume não está mudo
- **Interface:** O jogo limpa a tela a cada turno (comportamento normal)
- **Sair:** Pressione `Ctrl+C` para interromper a qualquer momento

---

**Desenvolvido com ❤️ - Jogo da Forca**
