# 🎨 Sprites de Cartas - Demonstração Visual

## 📋 Overview

O sistema agora possui um módulo `CardSprites` que fornece representações visuais melhoradas das cartas, com suporte a cores ANSI e emojis.

---

## 🎴 Características dos Sprites

### 1. **Cartas Individuais Coloridas**
```
┌─────┐         ┌─────┐         ┌─────┐         ┌─────┐
│ A ♠ │         │ K ♥ │         │ Q ♦ │         │ J ♣ │
│     │         │     │         │     │         │     │
│ ♠ A │         │ ♥ K │         │ ♦ Q │         │ ♣ J │
└─────┘         └─────┘         └─────┘         └─────┘
```

### 2. **Cartas em Linha (Inline)**
```
A♠ K♥ Q♦ J♣ 10♠ 9♥ 8♦ 7♣
```

### 3. **Versos de Cartas**
```
Frente:                 Verso:
┌─────┐                ┌─────┐
│ A ♠ │                │ 🂠  │
│     │        →       │  🂠 │
│ ♠ A │                │ 🂠  │
└─────┘                └─────┘
```

### 4. **Cores Suportadas**
- 🔴 Vermelho (♥, ♦)
- ⬛ Preto (♠, ♣)
- 🟡 Amarelo
- 🟦 Azul/Cyan
- 🟩 Verde
- ⚪ Branco

---

## 🖼️ Tela Inicial

```
╔═══════════════════════════════════════╗
║                                       ║
║        🎮 B U U R O 🎮               ║
║      Sistema de Jogos em Ruby        ║
║                                       ║
║   Forca • Solitário • Diversão       ║
║                                       ║
╚═══════════════════════════════════════╝

┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐
│ A ♠ │  │ K ♥ │  │ Q ♦ │  │ J ♣ │
│     │  │     │  │     │  │     │
│ ♠ A │  │ ♥ K │  │ ♦ Q │  │ ♣ J │
└─────┘  └─────┘  └─────┘  └─────┘

Escolha seu Jogo:

  1. 🎯 Jogo da Forca
     └─ Adivinhe palavras e teste suas habilidades

  2. ♠️  Solitário (Klondike)
     └─ O clássico jogo de cartas solitário
```

---

## 🎮 Tableau do Solitário com Sprites

```
══════════════════════════════════════════════════════════════

🃏 SOLITÁRIO (Klondike)

==============================================================

📚 Stock: 24 cartas          📤 Waste: K♥ Q♦ J♣

--------------------------------------------------------------

📍 Foundations:
  ♠: A♠    ♥: K♥    ♦: Q♦    ♣: J♣

--------------------------------------------------------------

🎴 Tableau:

  Col0: K♠ Q♥ J♦ (3c)
  Col1: A♠ 🂠 (2c)
  Col2: 10♥ 9♣ 8♠ (3c)
  Col3: empty
  Col4: 7♦ 6♣ (2c)
  Col5: 5♠ 4♥ (2c)
  Col6: 3♦ 2♣ (2c)

==============================================================
Score: 145 | Moves: 23 | Time: 125s
==============================================================
```

---

## 📚 Métodos Disponíveis em CardSprites

### Renderização de Cartas

```ruby
# Carta individual (sprite 5 linhas)
CardSprites.card_sprite('A', '♠', true)   # Mostra carta
CardSprites.card_sprite('A', '♠', false)  # Mostra verso

# Carta inline (uma linha)
CardSprites.card_inline('A', '♠', true)   # "A♠"
CardSprites.card_inline('A', '♠', false)  # "🂠"

# Verso da carta
CardSprites.card_back
CardSprites.colored_card_back
```

### Exibição de UI

```ruby
# Menu principal
CardSprites.display_game_menu

# Linha decorativa com cartas
CardSprites.display_card_row

# Tableau do solitário
CardSprites.display_tableau(columns)

# Foundation
CardSprites.display_foundation('♠', cards)

# Status do jogo
CardSprites.display_game_status(score, moves, time)

# Animações
CardSprites.victory_animation
CardSprites.defeat_animation
```

### Utility

```ruby
# Naipe colorido
CardSprites.suit_sprite('♠')  # "♠" em preto

# Múltiplas cartas em linha
CardSprites.cards_row(cards, show_all: true)
```

---

## 🎨 Cores ANSI Disponíveis

```ruby
CardSprites::COLORS = {
  red:    "\e[31m",
  black:  "\e[30m",
  reset:  "\e[0m",
  bold:   "\e[1m",
  yellow: "\e[33m",
  cyan:   "\e[36m",
  green:  "\e[32m",
  white:  "\e[37m"
}
```

---

## 🔧 Integração no CLI

O arquivo `buuro_cli.rb` agora usa:

1. **Tela Splash:**
   - Exibe o título com sprites de cartas
   - Mostra as 4 cartas decorativas (A♠, K♥, Q♦, J♣)
   - Aguarda ENTER do usuário

2. **Menu Principal:**
   - Usa `CardSprites.display_game_menu()`
   - Exibe opções com cores
   - Mostra cartas decorativas

3. **Jogo de Solitário:**
   - Tableau com sprites inline das cartas
   - Status colorido com score, moves, tempo
   - Feedback colorido para ações (verde=sucesso, vermelho=erro)
   - Animação visual na vitória

---

## 🎯 Exemplo de Uso

```ruby
require_relative 'card_sprites'

# Exibir sprite de carta
puts CardSprites.card_sprite('K', '♥')

# Exibir menu
CardSprites.display_game_menu

# Exibir tela inicial
puts CardSprites::TITLE_SPRITE
puts CardSprites.display_card_row

# Cores
puts "#{CardSprites::COLORS[:green]}Sucesso!#{CardSprites::COLORS[:reset]}"
puts "#{CardSprites::COLORS[:red]}Erro!#{CardSprites::COLORS[:reset]}"

# Animação
CardSprites.victory_animation
```

---

## 🎮 Como Jogar com os Novos Sprites

1. **Inicie o CLI:**
   ```bash
   ruby buuro_cli.rb
   ```

2. **Veja a tela splash com sprites:**
   - Título "BUURO" em ASCII art
   - Linha de cartas decorativas (A♠, K♥, Q♦, J♣)
   - Pressione ENTER

3. **Menu com opções visuais:**
   - Opções coloridas
   - Sprites de cartas decorativas

4. **Escolha Solitário (opção 2):**
   - Tableau visual com cartas em cores
   - Stock e Waste com indicadores
   - Foundations com naipes coloridos
   - Status em cores (verde=score, cyan=moves, amarelo=tempo)

5. **Comandos coloridos:**
   - Sucesso em verde ✓
   - Erro em vermelho ✗
   - Comandos em cyan
   - Status em amarelo

---

## 🚀 Características Futuras

- [ ] Sprites 3D ASCII para cartas
- [ ] Animações de movimento de cartas
- [ ] Temas visuais customizáveis
- [ ] Suporte a diferentes conjuntos de emojis
- [ ] Renderização em HTML com CSS
- [ ] Sprites para outros naipes (Baralho francês, tarot, etc.)

---

## 📦 Arquivos

- `card_sprites.rb` - Classe com métodos estáticos para sprites
- `buuro_cli.rb` - CLI integrada com sprites
- `solitaire_engine.rb` - Motor de solitário (sem mudanças)
- `game_engine.rb` - Motor de forca (sem mudanças)

---

## ✨ Conclusão

O novo sistema de sprites torna a experiência visual muito mais atrativa, com:
- ✅ Cartas coloridas e bem formatadas
- ✅ Tela inicial com sprites artísticos
- ✅ Menu principal visual
- ✅ Feedback em cores no gameplay
- ✅ Animações especiais para vitória/derrota
- ✅ Fácil extensão para novos visuais

Divirta-se jogando! 🎮🎴✨
