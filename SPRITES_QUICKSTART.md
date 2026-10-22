# 🎨 Sprites de Cartas - Quick Start

## 🚀 Como Usar

### Opção 1: Ver Demonstração dos Sprites

Para ver uma demonstração visual de todos os sprites disponíveis:

```bash
ruby demo_sprites.rb
```

Você verá:
- 🏠 Tela inicial com cartas
- 🎴 Cartas individuais coloridas
- 📚 Sequências de cartas
- 🎮 Menu principal visual
- 📊 Status colorido do jogo
- 🏆 Animação de vitória
- 💀 Animação de derrota
- 🌈 Teste de todas as cores

### Opção 2: Jogar com os Novos Sprites

```bash
ruby buuro_cli.rb
```

Agora a experiência é muito melhor:
1. ✨ **Tela Inicial Animada** - Vê sprites de cartas artísticas
2. 🎮 **Menu Colorido** - Com opções em cores diferentes
3. ♠️ **Solitário Visual** - Tableau com cartas em cores
4. 📊 **Status Colorido** - Score em verde, tempo em amarelo
5. ✓/✗ **Feedback Claro** - Verde para sucesso, vermelho para erro

---

## 📋 Exemplos de Sprites

### Carta Individual
```
┌─────┐
│ K ♥ │
│     │
│ ♥ K │
└─────┘
```

### Verso da Carta
```
┌─────┐
│ 🂠  │
│  🂠 │
│ 🂠  │
└─────┘
```

### Cartas em Linha
```
A♠ K♥ Q♦ J♣ 10♠ 9♥
```

### Tela Inicial
```
╔═══════════════════════════════════════╗
║                                       ║
║        🎮 B U U R O 🎮               ║
║      Sistema de Jogos em Ruby        ║
║                                       ║
║   Forca • Solitário • Diversão       ║
║                                       ║
╚═══════════════════════════════════════╝
```

---

## 🎨 Cores Disponíveis

| Cor | Uso | Exemplo |
|-----|-----|---------|
| 🔴 Vermelho | Cartas ♥♦, erros | `✗ Erro!` |
| ⬛ Preto | Cartas ♠♣ | `A♠` |
| 🟡 Amarelo | Info, tempo | `Time: 125s` |
| 🟦 Cyan | Comandos | `Comando: comprar` |
| 🟩 Verde | Sucesso | `✓ Acerto!` |

---

## 📝 Arquivos Novos

| Arquivo | Descrição |
|---------|-----------|
| `card_sprites.rb` | 📦 Biblioteca de sprites (estateless) |
| `demo_sprites.rb` | 🎮 Demonstração interativa dos sprites |
| `SPRITES_GUIDE.md` | 📖 Guia completo e detalhado |

---

## 🔧 Para Programadores

### Usar na sua classe

```ruby
require_relative 'card_sprites'

# Sprite de carta individual
puts CardSprites.card_sprite('K', '♥')

# Carta inline
puts CardSprites.card_inline('A', '♠')  # "A♠"

# Verso
puts CardSprites.card_back

# Menu
CardSprites.display_game_menu

# Status
puts CardSprites.display_game_status(score, moves, time)

# Cores
puts "#{CardSprites::COLORS[:green]}✓ Sucesso#{CardSprites::COLORS[:reset]}"
```

### Métodos Disponíveis

```ruby
CardSprites.card_sprite(value, suit, show)       # Sprite 5 linhas
CardSprites.card_inline(value, suit, show)       # Inline 1 linha
CardSprites.card_back                            # Verso preto
CardSprites.colored_card_back                    # Verso colorido
CardSprites.suit_sprite(suit)                    # Naipe colorido
CardSprites.display_card_row                     # Linha decorativa
CardSprites.display_game_menu                    # Menu principal
CardSprites.display_tableau(columns)             # Tableau do solitário
CardSprites.display_foundation(suit, cards)      # Foundation
CardSprites.display_game_status(score, moves, time) # Status
CardSprites.victory_animation                    # Animação vitória
CardSprites.defeat_animation                     # Animação derrota
```

---

## 🎯 Alterações Integradas

### Na tela inicial (`buuro_cli.rb`):
- ✅ Splash screen com sprites artísticos
- ✅ Menu visual com cores
- ✅ Cartas decorativas (A♠, K♥, Q♦, J♣)

### No Solitário (`buuro_cli.rb`):
- ✅ Tableau visual com cartas coloridas
- ✅ Stock e Waste com ícones
- ✅ Foundations com naipes
- ✅ Status em cores (verde/cyan/amarelo)
- ✅ Feedback colorido (✓ verde, ✗ vermelho)
- ✅ Animações na vitória/derrota

---

## 🎮 Gameplay Visual

### Antes
```
Stock: 24 | Waste: K♥, Q♦, J♣
Foundations: ♠:A♠ ♥:K♥ ♦:Q♦ ♣:J♣
Tableau:
  Col0: K♠ Q♥ J♦
  Col1: A♠ (verso)
```

### Depois (com Sprites!)
```
📚 Stock: 24 cartas        📤 Waste: K♥ Q♦ J♣

📍 Foundations:
  ♠: A♠    ♥: K♥    ♦: Q♦    ♣: J♣

🎴 Tableau:
  Col0: K♠ Q♥ J♦ (3c)
  Col1: A♠ 🂠 (2c)
```

---

## ✨ Próximas Melhorias

- [ ] Sprites 3D em ASCII
- [ ] Animações de movimento
- [ ] Temas customizáveis
- [ ] Suporte a emojis diferentes
- [ ] Renderização em HTML

---

## 📞 Suporte

Para mais informações, veja:
- `SPRITES_GUIDE.md` - Guia completo com exemplos
- `demo_sprites.rb` - Demonstração interativa
- `buuro_cli.rb` - Integração no código

---

Divirta-se com os novos visuais! 🎮✨
