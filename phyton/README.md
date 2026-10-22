# 🐍 Versão Python - Jogo da Forca

Implementação completa do Jogo da Forca em Python com áudio, interface terminal moderna e suporte a múltiplas plataformas.

---

## 🎮 Características

✅ **Jogo Completo**
- 20+ palavras relacionadas a programação
- 6 tentativas por partida
- Validação de entrada robusta
- Replay ilimitado

✅ **Áudio Integrado**
- Melodia de fundo em loop assíncrono
- 4 efeitos sonoros diferentes
- Frequências musicais precisas
- Áudio sincronizado com gameplay

✅ **Interface Moderna**
- Terminal limpo e organizado
- Emojis para feedback visual
- Animações de limpeza de tela
- Mensagens claras em português

✅ **Programação Avançada**
- Async/Await com asyncio
- Entrada não-bloqueante
- Tratamento de exceções robusto
- Suporte a múltiplas plataformas

---

## 📋 Requisitos

| Requisito | Versão |
|-----------|--------|
| **Python** | 3.8+ |
| **SO** | Windows 7+, Linux, macOS |
| **RAM** | 256 MB |
| **Disco** | 100 MB |

### Áudio
- **Windows:** ✅ Suportado (winsound)
- **Linux:** ⚠️ Desativado (sem winsound)
- **macOS:** ⚠️ Desativado (sem winsound)

---

## 🚀 Instalação Rápida

### Windows

1. **Instale Python:**
   - Vá para https://www.python.org/downloads/
   - Baixe Python 3.10+
   - ✅ Marque "Add Python to PATH"

2. **Execute o jogo:**
   ```bash
   python script.py
   ```

   Ou dê duplo-clique em `play.bat`

### Linux / macOS

```bash
# Instalar Python (se necessário)
sudo apt install python3  # Ubuntu/Debian
brew install python3      # macOS

# Executar jogo
python3 script.py
```

---

## 🌐 Jogo da Forca Web

Agora você também pode jogar usando o front-end HTML + backend Python:

1. Execute o servidor web:
   ```bash
   python web_forca.py
   ```
2. Abra no navegador:
   ```bash
   http://localhost:8000/html/index.html
   ```

> O arquivo `java/script.js` agora comunica com o backend Python para gerenciar letras, dicas e progresso.

---

## 📖 Como Jogar

1. **Inicie o jogo:** `python script.py`
2. **Pressione ENTER** para começar
3. **Digite uma letra** e pressione ENTER
4. **Acerte as letras** para adivinhar a palavra
5. **Você tem 6 tentativas** para vencer

### Exemplo de Partida

```
==================================================
   🎮 BEM-VINDO AO JOGO DA FORCA 🎮
==================================================

 ℹ️  Áudio: ✅ Ativado
 💻 Plataforma: win32
 🐍 Python: 3.11

==================================================

 Tentativas restantes: 6 ❤️

 Palavra: _ _ _ _ _ _ 

📝 Chute uma letra: a
 ✨ Letra correta! A
```

---

## 🎯 Estrutura de Arquivos

```
phyton/
├── script.py          # 🎮 Código principal do jogo
├── play.bat           # ⚡ Executar jogo (Windows)
├── menu.bat           # 📋 Menu com opções
├── test.py            # 🧪 Testes de sistema
├── INSTALL.md         # 📖 Guia de instalação
├── QUICKSTART.md      # 🚀 Início rápido
└── README.md          # 📚 Este arquivo
```

---

## 🔧 Arquivos Executáveis

### `play.bat` (Windows)
Forma mais fácil de jogar no Windows:
- Verifica Python automaticamente
- Exibe a versão instalada
- Inicia o jogo com um duplo-clique

```bash
# Uso:
play.bat          # Duplo-clique ou:
python play.bat
```

### `menu.bat` (Windows)
Menu interativo com múltiplas opções:

```bash
# Opções disponíveis:
# 1 - Jogar Jogo da Forca
# 2 - Ver Requisitos do Sistema
# 3 - Verificar Instalação Python
# 4 - Abrir Documentação
# 5 - Sair
```

### `test.py`
Verifica se tudo está funcionando:

```bash
python test.py

# Resultado esperado:
# ✓ Versão Python: 3.11.0
# ✓ asyncio disponível
# ✓ random disponível
# ✓ winsound disponível
# ✓ TUDO OK! Pronto para jogar.
```

---

## 🎵 Sistema de Áudio

### Efeitos Disponíveis

| Evento | Notas | Duração |
|--------|-------|---------|
| **Acerto** | E4 → G4 → C5 | 400ms |
| **Erro** | G4 → D4 | 450ms |
| **Vitória** | C4 → E4 → G4 → C5 | 850ms |
| **Derrota** | F4 → E4 → D4 → C4 | 1200ms |

### Melodia de Fundo

Toca continuamente em loop:
```
E4(300ms) → G4(300ms) → A4(600ms) →
E4(300ms) → G4(300ms) → B4(150ms) → A4(450ms) →
E4(300ms) → G4(300ms) → A4(600ms) →
G4(300ms) → E4(900ms)
```

---

## 💻 Arquitetura

### Classes Principais

**`AudioEngine`**
- Gerencia reprodução de sons
- Suporte multiplataforma
- Métodos: `tocar()`, `disparar_efeito()`, `parar()`

**`JogoForca`**
- Lógica principal do jogo
- Gerencia estado da partida
- Validação de entrada
- Verificação de vitória/derrota

### Fluxo de Execução

```
main() 
  ↓
AudioEngine() - cria engine de áudio
  ↓
JogoForca() - inicializa jogo
  ↓
asyncio.run() - executa loop assíncrono
  ↓
rodar_loop_principal() - loop do jogo
  ↓
Fin
```

---

## ⚙️ Personalização

### Adicionar Novas Palavras

Edite a lista `PALAVRAS` em `script.py`:

```python
class JogoForca:
    PALAVRAS = [
        "PYTHON", "JAVASCRIPT",  # palavras existentes...
        "MINHA_PALAVRA",         # adicione aqui
    ]
```

### Mudar Dificuldade

Edite `tentativas_restantes` em `JogoForca.__init__()`:

```python
def __init__(self, audio: AudioEngine):
    # ...
    self.tentativas_restantes = 3  # Mais difícil
    self.tentativas_restantes = 10 # Mais fácil
```

### Desabilitar Áudio

No início de `main()`:

```python
# Comentar linha:
# tarefa_audio = asyncio.create_task(audio.tocar_musica_fundo())
```

---

## 🐛 Solução de Problemas

### ❌ "Python não foi encontrado"
**Causa:** Python não está instalado ou não está no PATH

**Solução:**
1. Instale Python de https://www.python.org/downloads/
2. ✅ Marque "Add Python to PATH"
3. Reinicie seu computador
4. Tente novamente: `python --version`

### ❌ "ModuleNotFoundError"
**Causa:** Python muito antigo (< 3.8)

**Solução:**
1. Atualize para Python 3.10+
2. Remova versão antiga
3. Reinstale nova versão

### ❌ Sem som
**Causa:** `winsound` não disponível

**Solução:**
- Use Windows (winsound é Windows-only)
- Ou use a versão web em `html/index.html`
- O jogo funciona sem som!

### ❌ Teclado travado
**Causa:** Entrada de dados bloqueando loop assíncrono

**Solução:**
- Já corrigido no código atual!
- Usa `run_in_executor()` para entrada não-bloqueante

---

## 🔒 Compatibilidade

### Sistemas Operacionais

| SO | Python | Áudio | Status |
|----|--------|-------|--------|
| Windows | 3.8+ | ✅ | ✓ Total |
| Linux | 3.8+ | ❌ | ✓ Funciona (sem áudio) |
| macOS | 3.8+ | ❌ | ✓ Funciona (sem áudio) |

### Versões Python

| Versão | Status | Notas |
|--------|--------|-------|
| 3.7 | ❌ | Muito antigo |
| 3.8 | ✅ | Mínimo suportado |
| 3.9 | ✅ | Recomendado |
| 3.10 | ✅ | Recomendado |
| 3.11+ | ✅ | Melhor performance |

---

## 📊 Performance

- **Tempo de Inicialização:** < 1 segundo
- **Tempo de Resposta:** < 100ms
- **Uso de Memória:** ~20 MB
- **CPU:** < 5% (idle)

---

## 🎓 Conceitos Aprendidos

Este projeto implementa:

- ✅ **Asyncio** - Programação assíncrona em Python
- ✅ **Enums** - Enumerações para tipos de dados
- ✅ **Entrada/Saída** - Interação com usuário
- ✅ **Validação** - Processamento seguro de entrada
- ✅ **APIs de Áudio** - Integração com winsound
- ✅ **Tratamento de Exceções** - Robustez
- ✅ **Multiplataforma** - Suporte a vários SOs

---

## 📞 Suporte

Problemas? Verifique:

1. [INSTALL.md](INSTALL.md) - Guia de instalação
2. [QUICKSTART.md](QUICKSTART.md) - Início rápido
3. [test.py](test.py) - Execute testes
4. [../README.md](../README.md) - Documentação geral

---

## 📝 Changelog

### v1.0 (14/05/2026)
- ✅ Jogo completo funcional
- ✅ Áudio integrado
- ✅ Interface terminal moderna
- ✅ Suporte multiplataforma
- ✅ Documentação completa

---

**Desenvolvido com ❤️ - Jogo da Forca em Python**

Divirta-se jogando! 🎮
