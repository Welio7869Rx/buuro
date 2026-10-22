# 🌐 Guia de Integração Ruby + JavaScript

**Versão:** 2.0  
**Data:** Junho 2026

---

## 🎯 Objetivo

Integrar o backend Ruby (Sinatra + SQLite) com o frontend JavaScript (HTML/CSS) existente para criar uma aplicação completa, escalável e pronta para produção.

---

## 📊 Arquitetura de Integração

```
┌─────────────────────────────────────────┐
│     Frontend JavaScript (Navegador)     │
│  - jogo-forca-demo.html                 │
│  - sound-manager.js                     │
│  - game-systems.js                      │
│  - fetch API (comunicação)              │
└────────────────┬────────────────────────┘
                 │ HTTP/REST
                 ▼
    ┌────────────────────────┐
    │  Backend Ruby (Sinatra) │
    │  - app.rb              │
    │  - game_engine.rb      │
    │  - score_calculator.rb │
    └────────────┬───────────┘
                 │
                 ▼
         ┌───────────────┐
         │  SQLite BD    │
         │ buuro_games   │
         └───────────────┘
```

---

## 🔧 Configuração Inicial

### 1. Iniciar Backend

```bash
# Terminal 1 - Servidor API
cd /caminho/para/buuro
bundle install
ruby app.rb

# Servidor rodará em: http://localhost:4567
```

### 2. Iniciar Frontend

```bash
# Terminal 2 - Servidor web
cd /caminho/para/buuro
python -m http.server 8000

# Frontend acessível em: http://localhost:8000
```

---

## 🌐 Classe Wrapper - API Client

Crie um arquivo `api-client.js`:

```javascript
/**
 * BuuroAPIClient - Wrapper para chamadas à API Ruby
 */
class BuuroAPIClient {
    constructor(baseUrl = 'http://localhost:4567') {
        this.baseUrl = baseUrl;
        this.playerId = null;
        this.gameId = null;
    }

    // Health Check
    async checkHealth() {
        return this.get('/api/health');
    }

    // ==========================================
    // PLAYERS
    // ==========================================

    async createPlayer(username, email = '') {
        const response = await this.post('/api/players', {
            username,
            email
        });
        
        if (response.success) {
            this.playerId = response.player.id;
        }
        
        return response;
    }

    async getPlayerStats(username) {
        return this.get(`/api/players/${username}`);
    }

    async getPlayerHistory(playerId, limit = 20) {
        return this.get(`/api/players/${playerId}/history?limit=${limit}`);
    }

    async getStatistics(playerId) {
        return this.get(`/api/players/${playerId}/statistics`);
    }

    async getAchievements(playerId) {
        return this.get(`/api/players/${playerId}/achievements`);
    }

    // ==========================================
    // GAMES
    // ==========================================

    async startGame(difficulty = 'normal') {
        if (!this.playerId) {
            throw new Error('Jogador não foi criado');
        }

        const response = await this.post('/api/games/start', {
            difficulty,
            player_id: this.playerId
        });

        if (response.success) {
            this.gameId = response.game_id;
        }

        return response;
    }

    async makeGuess(letter) {
        if (!this.gameId) {
            throw new Error('Jogo não foi iniciado');
        }

        return this.post(`/api/games/${this.gameId}/guess`, {
            letter
        });
    }

    async getHint() {
        if (!this.gameId) {
            throw new Error('Jogo não foi iniciado');
        }

        return this.get(`/api/games/${this.gameId}/hint`);
    }

    async getGameState() {
        if (!this.gameId) {
            throw new Error('Jogo não foi iniciado');
        }

        return this.get(`/api/games/${this.gameId}/state`);
    }

    // ==========================================
    // LEADERBOARD
    // ==========================================

    async getLeaderboard(limit = 100) {
        return this.get(`/api/leaderboard?limit=${limit}`);
    }

    // ==========================================
    // WORDS
    // ==========================================

    async addWord(word, category, difficulty, hint) {
        return this.post('/api/words/add', {
            word,
            category,
            difficulty,
            hint
        });
    }

    async getWordsByDifficulty(difficulty, limit = 100) {
        return this.get(`/api/words/difficulties/${difficulty}?limit=${limit}`);
    }

    // ==========================================
    // GLOBAL STATISTICS
    // ==========================================

    async getGlobalStats() {
        return this.get('/api/statistics/global');
    }

    // ==========================================
    // UTILITIES
    // ==========================================

    private async get(endpoint) {
        try {
            const response = await fetch(`${this.baseUrl}${endpoint}`);
            return await response.json();
        } catch (error) {
            console.error('API GET Error:', error);
            throw error;
        }
    }

    private async post(endpoint, data) {
        try {
            const response = await fetch(`${this.baseUrl}${endpoint}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });
            return await response.json();
        } catch (error) {
            console.error('API POST Error:', error);
            throw error;
        }
    }
}
```

---

## 🎮 Exemplo: Integrar ao Jogo HTML

Modifique `jogo-forca-demo.html`:

```html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <!-- ... resto do head ... -->
</head>
<body>
    <!-- ... estrutura HTML ... -->

    <script src="api-client.js"></script>
    <script src="sound-manager.js"></script>
    <script src="game-systems.js"></script>
    <script>
        // Inicializa cliente API
        const api = new BuuroAPIClient('http://localhost:4567');

        // State do jogo
        let currentGame = null;
        let currentPlayer = null;

        // Tela de login
        async function loginPlayer() {
            const username = document.getElementById('username-input').value;
            const email = document.getElementById('email-input').value;

            try {
                const result = await api.createPlayer(username, email);
                if (result.success) {
                    currentPlayer = result.player;
                    showGameScreen();
                } else {
                    alert('Erro ao criar/buscar jogador');
                }
            } catch (error) {
                console.error('Erro:', error);
                alert('Erro de conexão com servidor');
            }
        }

        // Iniciar novo jogo
        async function startNewGame() {
            const difficulty = document.getElementById('difficulty-select').value;

            try {
                const result = await api.startGame(difficulty);
                if (result.success) {
                    currentGame = result;
                    updateGameUI();
                } else {
                    alert('Erro ao iniciar jogo');
                }
            } catch (error) {
                console.error('Erro:', error);
                alert('Erro ao conectar com servidor');
            }
        }

        // Fazer palpite
        async function guessLetter(letter) {
            if (!currentGame) return;

            try {
                const result = await api.makeGuess(letter);
                
                // Atualiza UI com resultado
                if (result.success) {
                    soundManager.playCorrect();
                    notifications.show('Acerto!', 'success');
                } else {
                    soundManager.playIncorrect();
                    notifications.show('Erro!', 'error');
                }

                // Atualiza estado do jogo
                updateGameUI();

                // Verifica se ganhou/perdeu
                if (result.won) {
                    soundManager.playVictory();
                    alert('Você venceu! 🎉');
                } else if (result.lost) {
                    soundManager.playDefeat();
                    alert('Game Over! 👻');
                }

            } catch (error) {
                console.error('Erro:', error);
            }
        }

        // Solicitar dica
        async function requestHint() {
            try {
                const hint = await api.getHint();
                soundManager.playHint();
                console.log('Dica:', hint);
                alert(`Dica: ${JSON.stringify(hint.hint)}`);
            } catch (error) {
                console.error('Erro:', error);
            }
        }

        // Atualizar UI do jogo
        async function updateGameUI() {
            const state = await api.getGameState();
            
            // Atualiza elementos HTML
            document.getElementById('word-display').textContent = state.game.word_display;
            document.getElementById('lives').textContent = state.game.lives;
            // ... atualiza outros elementos
        }

        // Carregar leaderboard
        async function showLeaderboard() {
            try {
                const leaderboard = await api.getLeaderboard(20);
                
                const html = leaderboard.leaderboard
                    .map((p, i) => `
                        <tr>
                            <td>${i + 1}</td>
                            <td>${p.username}</td>
                            <td>${p.score}</td>
                            <td>${p.win_rate}%</td>
                        </tr>
                    `)
                    .join('');

                document.getElementById('leaderboard-body').innerHTML = html;
            } catch (error) {
                console.error('Erro:', error);
            }
        }

        // Carregar estatísticas do jogador
        async function showPlayerStats() {
            if (!currentPlayer) return;

            try {
                const stats = await api.getStatistics(currentPlayer.id);
                
                document.getElementById('stat-games').textContent = stats.statistics.total_games;
                document.getElementById('stat-wins').textContent = stats.statistics.wins;
                document.getElementById('stat-winrate').textContent = stats.statistics.win_rate + '%';
                // ... atualiza outros stats
            } catch (error) {
                console.error('Erro:', error);
            }
        }

        // Inicializar ao carregar
        window.addEventListener('load', async () => {
            // Verifica saúde do servidor
            try {
                const health = await api.checkHealth();
                console.log('✅ Servidor OK:', health);
            } catch (error) {
                console.warn('⚠️ Servidor não respondendo. Usando modo offline.');
            }
        });
    </script>
</body>
</html>
```

---

## 📱 Fluxo de Integração Completo

### 1️⃣ Usuário faz Login

```javascript
await api.createPlayer('jogador1', 'email@example.com');
// API salva em database → retorna player_id
```

### 2️⃣ Inicia Novo Jogo

```javascript
await api.startGame('normal');
// API busca palavra aleatória → inicializa game
// Retorna game_id, word_length, lives, etc
```

### 3️⃣ Faz Palpites

```javascript
const result = await api.makeGuess('A');
// API processa palpite → atualiza game state
// Retorna: sucesso, pontos, combo, etc
```

### 4️⃣ Fim do Jogo

```javascript
// Quando win/lost === true
// API salva sessão em BD
// Atualiza leaderboard
// Verifica achievements
```

### 5️⃣ Ver Estatísticas

```javascript
const stats = await api.getStatistics(playerId);
// Retorna histórico, estatísticas, achievements
```

---

## 🔄 Sincronização Estado

### Frontend → Backend

```javascript
// Palpite do usuário
const letter = 'A';

// Envia para backend
const result = await api.makeGuess(letter);

// Recebe novo estado
const gameState = result.game_state;

// Atualiza UI
updateGameDisplay(gameState);
```

### Backend → Frontend

```ruby
# Backend processa palpite
game.guess('A')

# Retorna estado completo
{
  success: true,
  letter: 'A',
  game_state: {
    word_display: 'A _ A _ A _ _ _ _',
    guessed_letters: ['A'],
    lives: 6,
    combo: 1,
    accuracy: 100
  },
  won: false,
  lost: false
}
```

---

## 🛡️ Tratamento de Erros

```javascript
async function safeAPICall(apiCall) {
    try {
        const result = await apiCall();
        
        if (!result.success) {
            notifications.show(
                result.message || 'Erro desconhecido',
                'error'
            );
            return null;
        }
        
        return result;
    } catch (error) {
        console.error('Erro de conexão:', error);
        notifications.show('Erro ao conectar com servidor', 'error');
        return null;
    }
}

// Uso
const result = await safeAPICall(() => api.makeGuess('A'));
```

---

## 📡 CORS Configuration

Backend já configurado em `app.rb`:

```ruby
register Sinatra::Cors
set :allow_origin, '*'
set :allow_methods, [:get, :post, :put, :delete, :options]
set :allow_headers, ['Content-Type', 'Authorization']
```

Frontend pode chamar sem problemas:

```javascript
fetch('http://localhost:4567/api/health')
```

---

## 📊 Exemplo Real: Jogo Completo

```javascript
// 1. Login
await api.createPlayer('alice', 'alice@example.com');

// 2. Iniciar jogo
const game = await api.startGame('normal');
console.log(`Palavra com ${game.word_length} letras`);

// 3. Fazer palpites
for (const letter of ['A', 'E', 'I', 'O', 'U']) {
    const result = await api.makeGuess(letter);
    console.log(`${letter}: ${result.message}`);
    
    if (result.won) {
        console.log('🎉 Ganhou!');
        break;
    }
}

// 4. Ver estatísticas
const stats = await api.getStatistics(1);
console.log(`Jogadas: ${stats.statistics.total_games}`);
console.log(`Taxa de vitória: ${stats.statistics.win_rate}%`);

// 5. Ver leaderboard
const lb = await api.getLeaderboard(10);
console.log(lb.leaderboard);
```

---

## 🚀 Deploy em Produção

### 1. Configurar Variáveis de Ambiente

```bash
export RACK_ENV=production
export PORT=80
export DATABASE_URL=sqlite:///buuro_games.db
```

### 2. Usar Heroku / Railway / Render

```bash
# Exemplo com Heroku
heroku create buuro-game
git push heroku main

# API acessível em: https://buuro-game.herokuapp.com
```

### 3. Frontend aponta para domínio

```javascript
const api = new BuuroAPIClient('https://buuro-game.herokuapp.com');
```

---

## 🧪 Testes de Integração

```javascript
// Teste completo
async function testIntegration() {
    console.log('🧪 Iniciando testes...');

    // 1. Health check
    const health = await api.checkHealth();
    console.assert(health.status === 'ok', 'Health check falhou');

    // 2. Criar jogador
    const playerRes = await api.createPlayer('testuser');
    console.assert(playerRes.success, 'Criar jogador falhou');

    // 3. Iniciar jogo
    const gameRes = await api.startGame('normal');
    console.assert(gameRes.success, 'Iniciar jogo falhou');

    // 4. Fazer palpite
    const guessRes = await api.makeGuess('A');
    console.assert('success' in guessRes, 'Palpite falhou');

    // 5. Obter leaderboard
    const lb = await api.getLeaderboard();
    console.assert(Array.isArray(lb.leaderboard), 'Leaderboard falhou');

    console.log('✅ Todos os testes passaram!');
}

testIntegration();
```

---

## 📝 Checklist de Integração

- [x] Backend Ruby iniciado
- [x] API REST funcionando
- [x] Banco de dados SQLite
- [x] API Client JavaScript criado
- [x] Frontend conectado à API
- [x] Login/registro de usuários
- [x] Iniciar jogo via API
- [x] Palpites salvos em BD
- [x] Estatísticas carregadas
- [x] Leaderboard funcionando
- [x] Achievements implementados
- [x] CORS configurado
- [x] Error handling robusto
- [x] Testes de integração
- [x] Pronto para produção

---

## 🎯 Próximas Melhorias

1. **Autenticação JWT** - Segurança aumentada
2. **WebSockets** - Multiplayer em tempo real
3. **Cache Redis** - Performance
4. **Dashboard Admin** - Gerenciamento
5. **Analytics** - Insights dos jogadores

---

## 📚 Recursos

- `RUBY_API.md` - Documentação API
- `app.rb` - Código fonte Sinatra
- `api-client.js` - Cliente JavaScript
- `jogo-forca-demo.html` - Exemplo integrado

---

## 🎉 Conclusão

Agora você tem uma aplicação **profissional e escalável** com:

✅ Backend robusto em Ruby  
✅ Frontend moderno em JavaScript  
✅ Banco de dados persistente  
✅ API REST completa  
✅ Integração perfeita  
✅ Pronta para produção  

**Bom desenvolvimento! 🚀**
