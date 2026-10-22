# 🔧 Solução de Problemas - Python

## ❌ Erro: "Python não foi encontrado"

### Causa
Python não está instalado ou não está no PATH do sistema.

### Solução

**Windows:**
1. Acesse https://www.python.org/downloads/
2. Baixe **Python 3.10+**
3. Execute o instalador
4. ✅ **IMPORTANTE:** Marque "Add Python to PATH"
5. Clique em "Install Now"
6. Reinicie seu computador
7. Tente novamente: `python --version`

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install python3 python3-pip
python3 --version
```

**Linux (Fedora):**
```bash
sudo dnf install python3 python3-pip
python3 --version
```

**macOS:**
```bash
brew install python3
python3 --version
```

---

## ❌ Erro: "ModuleNotFoundError: No module named 'asyncio'"

### Causa
Versão do Python é muito antiga (< 3.4)

### Solução
Atualize para Python 3.8 ou superior:

```bash
# Windows: Desinstale e reinstale a nova versão
# Linux/macOS:
python3 --version  # Verificar versão
sudo apt install python3.10  # Ubuntu/Debian
brew install python@3.10     # macOS
```

---

## ❌ Erro: "SyntaxError" ao executar

### Causa
Versão do Python incompatível (< 3.8)

### Solução
1. Verifique sua versão: `python --version`
2. Se < 3.8, atualize
3. Tente novamente

---

## ❌ Sem som / Áudio não funciona

### Causa 1: Sistema não é Windows
`winsound` é apenas para Windows

### Solução 1:
- Use a versão web em `html/index.html`
- Ou instale Windows
- Ou use `pyaudio` em Linux (complexo)

### Causa 2: Volume mudo
Volume do sistema está mudo

### Solução 2:
1. Aumente o volume do computador
2. Verifique se os alto-falantes estão conectados
3. Tente novamente

### Causa 3: Fone de ouvido não detectado
O fone está desligado ou desconectado

### Solução 3:
1. Conecte fone/alto-falantes
2. Configure dispositivo de áudio padrão
3. Tente novamente

---

## ❌ Erro: "Permission denied"

### Causa
Falta de permissão para executar scripts

### Solução (Windows):
1. Abra **PowerShell como Administrador**
2. Execute:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
3. Responda `S` quando perguntado
4. Tente novamente

### Solução (Linux/macOS):
```bash
chmod +x script.py
python3 script.py
```

---

## ❌ Erro: "Input() bloqueando áudio"

### Causa
Versão antiga do código (já corrigida!)

### Solução
Use a versão atual:
```bash
# Certifique-se de ter a última versão
python script.py
```

O código atual usa `asyncio.run_in_executor()` para entrada não-bloqueante!

---

## ❌ Jogo congela / trava

### Causa 1: Entrada de dados esperando resposta
Pressione ENTER para responder

### Solução 1:
1. Digite uma letra
2. Pressione ENTER
3. Tente novamente

### Causa 2: Processo Python bloqueado
Pressione Ctrl+C para interromper

### Solução 2:
```bash
# No terminal:
Ctrl+C  # Interrompe o jogo
```

---

## ❌ Erro: "UnicodeEncodeError"

### Causa
Terminal não suporta UTF-8 (emojis, acentos)

### Solução (Windows):
1. No PowerShell, execute:
```powershell
[System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
python script.py
```

2. Ou edite `script.py` e remova emojis

### Solução (Linux/macOS):
```bash
export PYTHONIOENCODING=utf-8
python3 script.py
```

---

## ❌ Erro: "Windows defender bloqueou"

### Causa
Windows Defender vê o arquivo como suspeito

### Solução
1. Clique em "Mais informações"
2. Clique em "Executar mesmo assim"
3. O arquivo é seguro (código aberto!)

---

## ❌ Jogo fecha depois de jogar

### Causa
Comportamento esperado após sair

### Solução
Para manter aberto:
1. Execute com `play.bat` em vez de linha de comando
2. Ou edite `script.py` para remover `sys.exit()`

---

## ⚠️ Aviso: "winsound não suportado"

### Causa
Sistema operacional não tem `winsound` (não é Windows)

### Aviso Normal?
Sim! O jogo funciona normalmente, apenas sem som.

### Solução
Se quer som em Linux/macOS:
1. Use a versão web: `html/index.html`
2. Ou instale `pyaudio` (complexo)

---

## ⚠️ Aviso: "asyncio deprecated"

### Causa
Versão muito nova do Python (improvável)

### Solução
Use Python 3.10 ou 3.11 (versões estáveis)

---

## 🧪 Teste de Sistema

Para diagnosticar problemas:

```bash
python test.py
```

Resultado esperado:
```
✓ Versão Python: 3.11.0
✓ asyncio disponível
✓ random disponível
✓ winsound disponível
✓ script.py encontrado
✓ TUDO OK! Pronto para jogar.
```

---

## 🆘 Ainda não funciona?

1. **Verifique:**
   - `python --version` (deve ser 3.8+)
   - `python test.py` (testes passam?)
   - Volume não está mudo?

2. **Tente:**
   - Versão web: `html/index.html`
   - Linha de comando diferente (CMD vs PowerShell)
   - Computador reiniciado?

3. **Consulte:**
   - [INSTALL.md](INSTALL.md) - Guia completo
   - [README.md](README.md) - Documentação
   - [script.py](script.py) - Código fonte

---

## 📞 Checklist Final

- [ ] Python 3.8+ instalado
- [ ] "Add to PATH" marcado
- [ ] Computador reiniciado
- [ ] Volume não está mudo
- [ ] `python test.py` passou
- [ ] Tentou `play.bat` (Windows)
- [ ] Terminal como Admin (se necessário)

Se ainda não funciona, todos os passos acima foram seguidos?

---

**Precisa de ajuda? Veja a [documentação](README.md)!** 📚
