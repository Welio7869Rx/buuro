# 🎮 Buuro - Jogo da Forca com Ruby Backend

## 🚀 Mega Atualização - Versão 2.0

Bem-vindo à versão 2.0 do Buuro! Agora com suporte completo a Ruby, API REST profissional, banco de dados SQLite e muito mais!

---

## 📦 Novos Arquivos Ruby

### 1. **Gemfile** 📚
Dependências do projeto Ruby

```bash
bundle install
```

**Dependências Principais:**
- Sinatra - Framework Web leve
- SQLite3 - Banco de dados
- ActiveRecord - ORM
- RSpec - Testes

---

### 2. **game_engine.rb** 🎮
Motor de lógica dos jogos - Classe GameEngine

**Recursos:**
- ✅ Gerenciamento completo de partidas
- ✅ Sistema de dificuldade
- ✅ Tracking de combo
- ✅ Cálculo de acurácia
- ✅ Validação de palpites

**Uso:**
```ruby
game = GameEngine.new(
  word: "JAVASCRIPT",
  difficulty: :normal,
  word_data: { category: "Programação", hint: "Linguagem web" }
)

result = game.guess("A")
puts game.display_word          # J A _ _ _ _ _ _ _ _
puts game.game_progress         # Hash com estado completo
```

---

### 3. **score_calculator.rb** 💰
Sistema avançado de cálculo de pontuação

**Recursos:**
- ✅ Pontuação dinâmica
- ✅ Multiplicador de combo
- ✅ Bônus de tempo
- ✅ Bônus de acurácia
- ✅ Marcos de combo
- ✅ Histórico de pontos

**Uso:**
```ruby
score = ScoreCalculator.new(
  difficulty: :dificil,
  difficulty_config: { score_multiplier: 2.5 }
)

result = score.add_correct(is_word_complete: false)
puts result[:points]           # Pontos ganhos
puts result[:total]            # Pontos totais
puts result[:combo]            # Número do combo
puts result[:milestone]        # Marco alcançado
```

**Cálculo de Pontos:**
```
Pontos = BASE_POINTS × MULTIPLIER × DIFICULDADE + BÔNUS
BASE_POINTS = 100
MULTIPLIER = 1.0 + (combo_level × 0.25)
```

---

### 4. **database_manager.rb** 💾
Gerenciador de banco de dados SQLite

**Recursos:**
- ✅ 5 tabelas principais (Players, Sessions, Achievements, Leaderboard, WordBank)
- ✅ Persistência de dados
- ✅ Leaderboard
- ✅ Achievements
- ✅ Banco de palavras customizável
- ✅ Exportação de dados (GDPR)
- ✅ Exclusão de dados (Right to be forgotten)

**Tabelas:**
1. **players** - Usuários do sistema
2. **game_sessions** - Histórico de partidas
3. **achievements** - Conquistas desbloqueadas
4. **leaderboard** - Ranking dos melhores
5. **word_bank** - Banco de palavras

**Uso:**
```ruby
db = DatabaseManager.new

# Criar/buscar jogador
player = db.create_or_get_player("username", "email@example.com")

# Salvar partida
db.save_game_session(player['id'], {
  game_type: 'forca',
  difficulty: 'normal',
  word: 'JAVASCRIPT',
  final_score: 850,
  won: true,
  accuracy: 92.5
})

# Obter estatísticas
stats = db.get_player_stats(player['id'])
puts stats[:total_games]       # 25
puts stats[:win_rate]          # 84.0%

# Obter leaderboard
leaderboard = db.get_leaderboard(limit: 100)

# Adicionar palavra
db.add_word("PROGRAMACAO", "Desenvolvimento", "normal", "Atividade de código")

# Adicionar achievement
db.add_achievement(player['id'], "Primeiro Acerto", "Sua primeira vitória!")
```

---

### 5. **app.rb** 🌐
API REST Sinatra - Backend principal

**Endpoints Disponíveis:**

#### Health & Status
```
GET /api/health
```

#### Players (Usuários)
```
POST /api/players
├─ body: { username: string, email: string }

GET /api/players/:username

GET /api/players/:player_id/history?limit=20

GET /api/players/:player_id/statistics

GET /api/players/:player_id/achievements
```

#### Games (Jogos)
```
POST /api/games/start
├─ body: { difficulty: string, player_id: int }

POST /api/games/:game_id/guess
├─ body: { letter: string }

GET /api/games/:game_id/hint

GET /api/games/:game_id/state
```

#### Leaderboard
```
GET /api/leaderboard?limit=100
```

#### Words (Palavras)
```
POST /api/words/add
├─ body: { word: string, category: string, difficulty: string, hint: string }

GET /api/words/difficulties/:difficulty?limit=100
```

#### Statistics (Estatísticas)
```
GET /api/statistics/global
```

#### GDPR Compliance
```
GET /api/players/:player_id/export

DELETE /api/players/:player_id
```

---

### 6. **buuro_cli.rb** 💻
Interface de Linha de Comando

Menu Principal:
1. 👤 Selecionar/Criar Jogador
2. 🎮 Iniciar Jogo
3. 📊 Ver Estatísticas
4. 🏆 Ver Leaderboard
5. 📚 Gerenciar Palavras
6. 🚪 Sair

**Uso:**
```bash
ruby buuro_cli.rb
```

**Recursos:**
- ✅ Jogo completo no terminal
- ✅ Gerenciamento de jogadores
- ✅ Visualização de estatísticas
- ✅ Leaderboard interativo
- ✅ Gerenciamento de palavras

---

## 🚀 Como Começar

### 1. Instalar Dependências
```bash
bundle install
```

### 2. Iniciar o Servidor
```bash
ruby app.rb
```

O servidor rodará em `http://localhost:4567`

### 3. Usar a CLI
```bash
ruby buuro_cli.rb
```

---

## 📊 Arquitetura

```
┌─────────────────────────────────────┐
│    Clientes (HTML/JavaScript)       │
└────────────────┬────────────────────┘
                 │
                 ▼
         ┌───────────────┐
         │  API REST     │
         │  (Sinatra)    │
         └───────┬───────┘
                 │
      ┌──────────┼──────────┐
      ▼          ▼          ▼
   ┌─────────┬──────────┬──────────┐
   │ Game    │  Score   │ Database │
   │ Engine  │Calculator│ Manager  │
   └─────────┴──────────┴──────────┘
      │                    │
      └────────┬───────────┘
               ▼
         ┌──────────────┐
         │  SQLite DB   │
         │ (buuro_games │
         │     .db)     │
         └──────────────┘
```

---

## 🔗 Integração Frontend

### Exemplo: Conectar HTML/JavaScript à API

```javascript
// Iniciar jogo
fetch('http://localhost:4567/api/games/start', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    difficulty: 'normal',
    player_id: 1
  })
})
.then(r => r.json())
.then(data => console.log(data))

// Fazer palpite
fetch('http://localhost:4567/api/games/game-id/guess', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ letter: 'A' })
})
.then(r => r.json())
.then(data => console.log(data))

// Obter estatísticas
fetch('http://localhost:4567/api/players/1/statistics')
  .then(r => r.json())
  .then(data => console.log(data))
```

---

## 📈 Melhorias Implementadas

| Aspecto | Antes | Depois |
|---------|-------|--------|
| Backend | ❌ | ✅ Sinatra/Ruby |
| Database | ❌ | ✅ SQLite |
| API REST | ❌ | ✅ 15+ endpoints |
| CLI | ❌ | ✅ Completa |
| Players | ❌ | ✅ Sistema completo |
| Leaderboard | ❌ | ✅ Ranking |
| Achievements | ❌ | ✅ Sistema |
| Word Bank | Hardcoded | ✅ Dinâmico |
| GDPR | ❌ | ✅ Compliance |
| Persistência | LocalStorage | ✅ BD SQLite |

---

## 💾 Banco de Dados

### Schema

```sql
-- Players
CREATE TABLE players (
  id INTEGER PRIMARY KEY,
  username TEXT UNIQUE,
  email TEXT,
  created_at TIMESTAMP
);

-- Game Sessions
CREATE TABLE game_sessions (
  id INTEGER PRIMARY KEY,
  player_id INTEGER,
  game_type TEXT,
  difficulty TEXT,
  word TEXT,
  final_score INTEGER,
  combo_streak INTEGER,
  accuracy REAL,
  time_taken INTEGER,
  won BOOLEAN,
  FOREIGN KEY (player_id) REFERENCES players(id)
);

-- Achievements
CREATE TABLE achievements (
  id INTEGER PRIMARY KEY,
  player_id INTEGER,
  achievement_name TEXT,
  earned_at TIMESTAMP,
  FOREIGN KEY (player_id) REFERENCES players(id)
);

-- Leaderboard
CREATE TABLE leaderboard (
  id INTEGER PRIMARY KEY,
  player_id INTEGER,
  score INTEGER,
  games_played INTEGER,
  win_rate REAL,
  FOREIGN KEY (player_id) REFERENCES players(id)
);

-- Word Bank
CREATE TABLE word_bank (
  id INTEGER PRIMARY KEY,
  word TEXT UNIQUE,
  category TEXT,
  difficulty TEXT,
  hint TEXT,
  language TEXT DEFAULT 'PT-BR'
);
```

---

## 🎯 Próximas Melhorias

- [ ] WebSockets para multiplayer em tempo real
- [ ] Cache Redis para performance
- [ ] Sistema de badges
- [ ] Daily quests
- [ ] Modo story/campanha
- [ ] Integração com redes sociais
- [ ] Mobile app nativa
- [ ] Análise de performance

---

## 🧪 Testes

```bash
# Instalar gems de teste
bundle install --with development test

# Rodar testes
rspec
```

---

## 🔒 Segurança

- ✅ CORS configurado
- ✅ Input validation
- ✅ SQL injection protection
- ✅ GDPR compliance
- ✅ Error handling robusto

---

## 📝 Configuração

### Variáveis de Ambiente

```bash
export PORT=4567
export RACK_ENV=production
```

---

## 🎨 Melhorias Visuais

A integração Ruby + JavaScript oferece:
- ✨ Backend robusto
- 📊 Estatísticas completas
- 🏆 Leaderboard dinâmico
- 💾 Persistência de dados
- 🔄 Sincronização automática

---

## 📚 Documentação

Arquivos de documentação:
- `RECURSOS.md` - Features dos sistemas
- `GUIA_TESTES.md` - Guia de testes
- `INTEGRACAO.md` - Integração frontend
- `RUBY_API.md` - Documentação da API Ruby

---

## 🚀 Performance

- ✅ Queries otimizadas
- ✅ Índices no banco de dados
- ✅ Cache de sessões
- ✅ Compressão de responses
- ✅ Connection pooling

---

## 📱 Compatibilidade

- ✅ Sinatra 4.0+
- ✅ Ruby 3.0+
- ✅ SQLite 3.x
- ✅ Cross-platform

---

## 🙏 Resumo

A versão 2.0 do Buuro agora oferece:

1. **Backend Ruby profissional** com Sinatra
2. **API REST completa** com 15+ endpoints
3. **Banco de dados SQLite** para persistência
4. **CLI interativa** para jogar no terminal
5. **Sistema de jogadores** completo
6. **Leaderboard** dinâmico
7. **Achievements** desbloqueáveis
8. **GDPR compliance** para privacidade
9. **Integração** com frontend JavaScript
10. **Testes** com RSpec

**Versão:** 2.0  
**Data:** Junho 2026  
**Linguagem:** Ruby + JavaScript

---

**Divirta-se jogando! 🎮✨**
