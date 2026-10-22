# 🎮 Guia de Novos Recursos e Efeitos Sonoros

## 📋 Resumo das Adições

Este documento descreve os novos recursos adicionados ao projeto **Buuro** para melhorar a experiência dos jogos.

---

## 🎵 1. Sistema de Efeitos Sonoros Expandido

### Arquivo: `config.json`

Foram adicionados **20+ efeitos sonoros** sintetizados, incluindo:

#### Efeitos de Gameplay
- ✅ **acerto** - Som de acerto correto
- ✅ **acertoRapido** - Som mais rápido e agudo para acertos sucessivos
- ❌ **erro** - Som de erro
- ❌ **erroGrave** - Som mais profundo para erros críticos
- 💡 **dica** - Som de dica solicitada
- 💡 **dicaExtra** - Som de dica bonus

#### Efeitos de Combo
- 🔥 **combo** - Som básico de combo
- 🔥 **comboX2** - Som para combo x2
- 🔥 **comboX3** - Som para combo x3+

#### Efeitos Especiais
- ⭐ **bonus** - Som de bônus conquistado
- 📈 **levelUp** - Som de avanço de nível
- ⚠️ **aviso** - Som de aviso/alerta
- 🎉 **vitoria** - Som de vitória
- 🎊 **vitoriaGrande** - Som épico de vitória perfeita
- 👻 **derrota** - Som de derrota
- ↩️ **volta** - Som de voltar
- 🎮 **menuAbrir** - Som de abertura de menu
- 🖱️ **click** - Som de clique

### Notas Musicais Adicionadas
Foram expandidas de 10 para 16 notas, incluindo notas graves (A3) e agudas (E6, A5, B5, C6)

---

## 🎮 2. Sistema de Pontuação (GameScore)

**Arquivo:** `game-systems.js`

### Recursos Principais

#### Pontuação Dinâmica
```javascript
const score = new GameScore({
    basePoints: 100,
    comboMultiplier: 1.25,
    comboThreshold: 3,
    timeBonusSeconds: 10,
    perfectWordBonus: 500,
    difficultyMultiplier: 1.0
});
```

#### Cálculo de Pontos
- **Pontuação Base:** 100 pontos por letra correta
- **Multiplicador de Combo:** Aumenta em 25% a cada 3 acertos consecutivos
- **Bônus por Dificuldade:**
  - Fácil: 1.0x
  - Normal: 1.5x
  - Difícil: 2.5x
- **Bônus Perfeito:** 500 pontos extras por adivinhar palavra perfeita

#### Métodos Disponíveis
```javascript
score.addCorrect(isWord)      // Registra acerto
score.addError()              // Registra erro (quebra combo)
score.addTimeBonus(seconds)   // Adiciona bônus de tempo
score.getComboMilestone()     // Verifica marco de combo
score.getSummary()            // Retorna resumo
```

---

## 🎯 3. Sistema de Dificuldade (DifficultyManager)

**Arquivo:** `game-systems.js`

### Três Níveis de Dificuldade

#### Fácil
- ❤️ Vidas: 8
- 💰 Multiplicador de Score: 1.0x
- 💡 Multiplicador de Dicas: 1.5x (mais dicas disponíveis)
- 🎨 Cor: Verde (#2ecc71)

#### Normal (Padrão)
- ❤️ Vidas: 6
- 💰 Multiplicador de Score: 1.5x
- 💡 Multiplicador de Dicas: 1.0x
- 🎨 Cor: Laranja (#f39c12)

#### Difícil
- ❤️ Vidas: 4
- 💰 Multiplicador de Score: 2.5x (maior recompensa!)
- 💡 Multiplicador de Dicas: 0.5x (menos dicas)
- 🎨 Cor: Vermelho (#e74c3c)

### Uso
```javascript
const difficulty = new DifficultyManager(config.game.difficulty);
difficulty.setDifficulty('dificil');
const settings = difficulty.getCurrentSettings();
```

---

## 🔥 4. Sistema de Combo

Implementado em `GameScore`

### Como Funciona
1. **Cada acerto** incrementa o combo
2. **Cada erro** reseta o combo para 0
3. **Marcos especiais** a cada 2, 3, 5, e 10 acertos

### Feedback
- Visual: Número do combo exibido na tela
- Sonoro: Som diferente para cada marco (combo, comboX2, comboX3)
- Textual: Mensagem flutuante "+50 pontos" com cor diferente

---

## ✨ 5. Gerenciador de Texto Flutuante (FloatingTextManager)

**Arquivo:** `game-systems.js`

Cria efeitos visuais de texto flutuante na tela

### Tipos de Textos
```javascript
floatingText.showPoints(points, x, y)      // "+150" em verde
floatingText.showCombo(combo, x, y)        // "COMBO x5!" em vermelho
floatingText.showMilestone(text, x, y)     // "⭐ Parabéns!" em dourado
```

### Customização
```javascript
floatingText.create(text, x, y, {
    duration: 1500,
    fontSize: '1.5rem',
    color: '#fff',
    distance: 60,
    fontWeight: 'bold'
});
```

---

## 📢 6. Gerenciador de Notificações (NotificationManager)

**Arquivo:** `game-systems.js`

Mostra notificações no canto inferior direito da tela

### Tipos de Notificação
- 🟢 **success** - Verde (vitórias, marcos)
- 🔴 **error** - Vermelho (erros críticos)
- 🟡 **warning** - Amarelo (avisos)
- 🔵 **info** - Azul (informações)
- 🔥 **combo** - Vermelho vibrante (combos)

### Uso
```javascript
notifications.show('Parabéns!', 'success', 2000);
notifications.showCombo(10);
notifications.showMilestone('Combo Perfeito!');
```

---

## 📊 7. Rastreador de Estatísticas (StatsTracker)

**Arquivo:** `game-systems.js`

Rastreia desempenho geral e histórico de partidas

### Estatísticas Rastreadas
- Número de partidas jogadas
- Número de vitórias
- Pontuação total
- Melhor pontuação
- Combo mais longo
- Taxa de acerto (%)
- Taxa de vitória (%)

### Persistência
Salva dados em `localStorage` para recuperação entre sessões

```javascript
stats.recordGame(won, score, combo, lettersCorrect, totalLetters);
stats.save();      // Salva em localStorage
stats.load();      // Carrega de localStorage
console.log(stats.getSummary());
```

---

## 🔊 8. Gerenciador de Som (SoundManager)

**Arquivo:** `sound-manager.js`

Gerenciador centralizado para todos os efeitos sonoros

### Recursos
- ✅ Carrega configuração de `config.json` automaticamente
- ✅ Converte nomes de notas em frequências
- ✅ Suporta efeitos em sequência
- ✅ Controle de volume e ativação/desativação

### Métodos de Conveniência
```javascript
soundManager.playCorrect()       // Efeito de acerto
soundManager.playCombo()         // Efeito de combo
soundManager.playVictory()       // Efeito de vitória
soundManager.playBackgroundMusic('dificil');
soundManager.setVolume(0.5)      // 50% de volume
soundManager.toggleSound()       // Ativa/desativa
```

---

## 📝 Como Integrar aos Jogos Existentes

### 1. Adicionar Scripts HTML
```html
<script src="sound-manager.js"></script>
<script src="game-systems.js"></script>
```

### 2. Inicializar Gerenciadores
```javascript
const soundManager = new SoundManager();
const gameScore = new GameScore();
const difficulty = new DifficultyManager();
const floatingText = new FloatingTextManager(document.body);
const notifications = new NotificationManager(document.body);
const stats = new StatsTracker();
stats.load(); // Carregar estatísticas salvas
```

### 3. Usar em Eventos de Jogo

**Quando acertar uma letra:**
```javascript
const result = gameScore.addCorrect();
soundManager.playCorrect();
if (result.comboMilestone === 'milestone_x5') {
    soundManager.playCombo();
    notifications.showMilestone('Combo x5!');
}
floatingText.showPoints(result.points, mouseX, mouseY);
```

**Quando errar:**
```javascript
gameScore.addError();
soundManager.playIncorrect();
notifications.show('Letra não encontrada!', 'error');
```

**Ao vencer:**
```javascript
const summary = gameScore.getSummary();
soundManager.playVictory();
stats.recordGame(true, summary.totalPoints, summary.combo, 
                 summary.correctLetters, 26);
stats.save();
```

---

## 🎨 CSS para Animações

Adicione ao seu CSS para animações de texto flutuante:

```css
@keyframes slideIn {
    from {
        transform: translateX(200px);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

@keyframes slideOut {
    from {
        transform: translateX(0);
        opacity: 1;
    }
    to {
        transform: translateX(200px);
        opacity: 0;
    }
}

.floating-text {
    font-family: 'Segoe UI', sans-serif;
}

.floating-points {
    color: #2ecc71;
    font-size: 1.8rem;
}

.floating-combo {
    color: #ff6b6b;
    font-weight: bold;
}

.floating-milestone {
    color: #ffd700;
    font-size: 2rem;
    font-weight: bold;
}
```

---

## 🚀 Próximos Passos Recomendados

1. **Integrar aos jogos HTML existentes** - Adicionar scripts aos jogos
2. **Criar tela de estatísticas** - Dashboard com histórico de partidas
3. **Implementar leaderboard** - Top 10 de melhores pontuações
4. **Adicionar achievements** - Sistema de conquistas
5. **Criar temas de dificuldade** - Backgrounds diferentes por dificuldade
6. **Implementar campanha** - Progressão de fases com histórias
7. **Modo multiplayer** - Partidas de 2 jogadores

---

## 📁 Arquivos Adicionados

- ✅ `sound-manager.js` - Gerenciador de sons (256 linhas)
- ✅ `game-systems.js` - Sistemas de jogo (450+ linhas)
- ✅ `config.json` - Configuração expandida (150+ linhas)
- ✅ `RECURSOS.md` - Este arquivo

---

## 🎯 Resumo de Melhorias

| Recurso | Antes | Depois |
|---------|-------|--------|
| Efeitos Sonoros | 6 | 20+ |
| Notas Musicais | 10 | 16 |
| Sistema de Score | ❌ | ✅ |
| Sistema de Combo | ❌ | ✅ |
| Níveis Dificuldade | 3 (básico) | 3 (completo) |
| Texto Flutuante | ❌ | ✅ |
| Notificações | ❌ | ✅ |
| Rastreamento Estatísticas | ❌ | ✅ |
| Persistência de Dados | ❌ | ✅ |

---

## 💡 Exemplos de Uso

Veja os exemplos de integração completa na pasta `exemplos/` (em breve)

---

**Versão:** 1.0  
**Data:** Junho 2026  
**Autor:** Sistema de Jogos Buuro  
**Licença:** MIT
