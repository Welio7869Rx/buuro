# 📌 Instruções de Integração - Jogo da Forca

## Estrutura de Integração

Este projeto integra três plataformas diferentes com a mesma lógica de jogo:

### 🌐 **Camada Web (JavaScript)**
- **Localização:** `java/script.js` e `html/index.html`
- **Responsável por:** Interface visual e interação do usuário no navegador
- **Audio:** Web Audio API (síntese de som em tempo real)
- **Estado:** Gerenciado no escopo global

### 🐍 **Camada Python**
- **Localização:** `phyton/script.py`
- **Responsável por:** Jogo de linha de comando com áudio background
- **Audio:** `winsound` (Windows) com programação assíncrona
- **Estado:** Classes dataclass (JogoForca, AudioEngine)

### 🔷 **Camada C#**
- **Localização:** `audios/program.cs`
- **Responsável por:** Aplicação .NET com Console.Beep
- **Audio:** `Console.Beep` com cancelamento de tarefa
- **Estado:** Métodos estáticos

---

## Padrões Compartilhados

### 1️⃣ Palavras do Jogo
Todas as versões usam palavras relacionadas a programação. A lista em `config.json` é a fonte de verdade.

```json
{
  "game": {
    "initialLives": 6,
    "words": ["PALAVRA1", "PALAVRA2", ...]
  }
}
```

### 2️⃣ Sistema de Áudio Unificado
Todos os efeitos sonoros seguem a mesma estrutura:

- **Acerto:** E4 (100ms) → G4 (100ms) → C5 (200ms)
- **Erro:** G4 (150ms) → D4 (300ms)
- **Vitória:** C4 → E4 → G4 → C5 (Fanfarra)
- **Derrota:** F4 → E4 → D4 → C4 (Decrescente)

### 3️⃣ Fluxo do Jogo
```
1. Inicializar jogo
2. Escolher palavra aleatória
3. Loop principal:
   - Exibir estado do jogo
   - Receber entrada do usuário
   - Processar palpite
   - Tocar efeito sonoro apropriado
   - Verificar vitória/derrota
4. Fim do jogo
```

---

## Como Adicionar Novas Funcionalidades

### 📝 Adicionar Nova Palavra

**Em `config.json`:**
```json
{
  "game": {
    "words": [
      ... palavras existentes ...,
      "NOVA_PALAVRA"
    ]
  }
}
```

**Depois atualizar em cada versão:**

- **JavaScript:** `wordList` em `java/script.js`
- **Python:** `palavras` em `phyton/script.py`
- **C#:** Método em `audios/program.cs`

### 🎵 Adicionar Novo Efeito Sonoro

1. Definir a sequência em `config.json`:
```json
{
  "audio": {
    "effects": {
      "meuEfeito": [
        { "frequency": "C4", "duration": 200 }
      ]
    }
  }
}
```

2. Implementar em cada versão:

**JavaScript:**
```javascript
efeitoMeu() {
    this.tocarSequencia([
        [AudioEngine.NOTAS.C4, 200]
    ]);
}
```

**Python:**
```python
case Efeito.MEU_EFEITO:
    beep(C4, 200)
```

**C#:**
```csharp
public static void EfeitoMeu()
{
    Console.Beep(C4, 200);
}
```

### 🎮 Adicionar Novo Nível de Dificuldade

Criar nova variável em `config.json`:
```json
{
  "difficulty": {
    "easy": { "initialLives": 10 },
    "medium": { "initialLives": 6 },
    "hard": { "initialLives": 3 }
  }
}
```

---

## Sincronização Entre Versões

### ✅ Verificação de Consistência

Após qualquer mudança, verificar:

1. **Palavras do jogo:** Mesma lista em todas as versões
2. **Lógica de pontuação:** Mesmos critérios de vitória/derrota
3. **Efeitos sonoros:** Mesmas frequências e durações
4. **Mensagens:** Tradução consistente em português

### 🔄 Fluxo de Sincronização

```
Modificação → config.json → Atualizar cada versão → Testar
```

---

## Testes de Integração

### 1. Teste Web
```bash
# Abrir html/index.html no navegador
# Verificar: áudio funciona, interface responsiva
```

### 2. Teste Python
```bash
cd phyton/
python script.py
# Verificar: áudio background contínuo, entrada funciona
```

### 3. Teste C#
```bash
cd audios/
dotnet run
# Verificar: áudio via Console.Beep funciona
```

---

## Áreas de Expansão Futura

1. **API REST:** Backend em Node.js para sincronizar estado
2. **WebSocket:** Multiplayer em tempo real
3. **Database:** Salvar rankings e histórico
4. **PWA:** Versão web offline
5. **Mobile:** Versão React Native

---

## Problemas Comuns

### 📍 Problema: Áudio não funciona na web
**Solução:** Web Audio API requer interação do usuário. Primeiro clique ativa o AudioContext.

### 📍 Problema: Python não toca som no Linux
**Solução:** `winsound` é Windows-only. Usar `ossaudiodev` ou `pyaudio`.

### 📍 Problema: C# não executa
**Solução:** Verificar `dotnet --version`. Requer .NET 6.0+

---

**Última atualização:** 14 de maio de 2026
