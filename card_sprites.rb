# frozen_string_literal: true

##
# CardSprites - Biblioteca de sprites visuais para cartas
# Fornece representações visuais melhoradas das cartas de jogo
#
class CardSprites
  # Naipes e seus símbolos
  SUIT_SYMBOLS = {
    '♠' => '♠',
    '♥' => '♥',
    '♦' => '♦',
    '♣' => '♣'
  }.freeze

  # Cores ANSI
  COLORS = {
    red: "\e[31m",
    black: "\e[30m",
    reset: "\e[0m",
    bold: "\e[1m",
    yellow: "\e[33m",
    cyan: "\e[36m",
    green: "\e[32m",
    white: "\e[37m"
  }.freeze

  # Sprites pequeninhas de cartas (3 linhas)
  CARD_SPRITES_SMALL = {
    spades: "    ♠\n   ♠ ♠\n  ♠ ♠ ♠",
    hearts: "    ♥\n   ♥ ♥\n  ♥ ♥ ♥",
    diamonds: "    ♦\n   ♦ ♦\n  ♦ ♦ ♦",
    clubs: "    ♣\n   ♣ ♣\n  ♣ ♣ ♣"
  }.freeze

  # Sprites de cartas individuais (5 linhas x 7 colunas)
  CARD_SPRITES = {
    back: "┌─────┐\n│ ■■■ │\n│■■■■■│\n│ ■■■ │\n└─────┘",
    hidden: "┌─────┐\n│ 🂠  │\n│  🂠 │\n│ 🂠  │\n└─────┘"
  }.freeze

  # Padrões de valores
  VALUE_PATTERNS = {
    'A' => '🔝', '2' => '②', '3' => '③', '4' => '④', '5' => '⑤',
    '6' => '⑥', '7' => '⑦', '8' => '⑧', '9' => '⑨', '10' => '⑩',
    'J' => '🅙', 'Q' => '🅠', 'K' => '🅚'
  }.freeze

  # Sprite de título para tela inicial
  TITLE_SPRITE = """
  ╔═══════════════════════════════════════╗
  ║                                       ║
  ║        🎮 B U U R O 🎮               ║
  ║      Sistema de Jogos em Ruby        ║
  ║                                       ║
  ║   Forca • Solitário • Diversão       ║
  ║                                       ║
  ╚═══════════════════════════════════════╝
  """.freeze

  # Sprites de cartas decorativas
  CARD_DISPLAY = {
    spades: "┌─────┐\n│ ♠   │\n│     │\n│   ♠ │\n└─────┘",
    hearts: "┌─────┐\n│ ♥   │\n│     │\n│   ♥ │\n└─────┘",
    diamonds: "┌─────┐\n│ ♦   │\n│     │\n│   ♦ │\n└─────┘",
    clubs: "┌─────┐\n│ ♣   │\n│     │\n│   ♣ │\n└─────┘"
  }.freeze

  class << self
    ##
    # Retorna sprite colorido de carta
    #
    def card_sprite(value, suit, show = true)
      return colored_card_back if !show

      color = suit_color(suit)
      suit_symbol = SUIT_SYMBOLS[suit] || suit

      "#{COLORS[:bold]}#{color}┌─────┐\n│#{format_value(value, 2)} #{suit_symbol}│\n│     │\n│ #{suit_symbol} #{format_value(value, 2)}│\n└─────┘#{COLORS[:reset]}"
    end

    ##
    # Carta de verso (costas)
    #
    def card_back
      "#{COLORS[:bold]}┌─────┐\n│ ■■■ │\n│■■■■■│\n│ ■■■ │\n└─────┘#{COLORS[:reset]}"
    end

    def colored_card_back
      "#{COLORS[:bold]}#{COLORS[:cyan]}┌─────┐\n│ 🂠  │\n│  🂠 │\n│ 🂠  │\n└─────┘#{COLORS[:reset]}"
    end

    ##
    # Representação inline de carta
    #
    def card_inline(value, suit, show = true)
      return '🂠' if !show

      color = suit_color(suit)
      suit_symbol = SUIT_SYMBOLS[suit] || suit
      
      "#{COLORS[:bold]}#{color}#{value}#{suit_symbol}#{COLORS[:reset]}"
    end

    ##
    # Cartas em sequência visual (row)
    #
    def cards_row(cards, show_all = true)
      cards.map.with_index do |card, idx|
        visible = show_all || idx == cards.length - 1
        card_inline(card[:value], card[:suit], visible)
      end.join(' ')
    end

    ##
    # Sprite de naipe colorido
    #
    def suit_sprite(suit)
      color = suit_color(suit)
      symbol = SUIT_SYMBOLS[suit] || suit
      "#{COLORS[:bold]}#{color}#{symbol}#{COLORS[:reset]}"
    end

    ##
    # Menu visual com cartas
    #
    def display_game_menu
      puts TITLE_SPRITE
      puts "\n"
      puts "#{COLORS[:bold]}#{COLORS[:yellow]}Escolha seu Jogo:#{COLORS[:reset]}"
      puts
      
      # Linha de cartas decorativas
      puts display_card_row
      puts
      
      puts "  1. #{COLORS[:bold]}🎯 Jogo da Forca#{COLORS[:reset]}"
      puts "     └─ Adivinhe palavras e teste suas habilidades"
      puts
      puts "  2. #{COLORS[:bold]}♠️  Solitário (Klondike)#{COLORS[:reset]}"
      puts "     └─ O clássico jogo de cartas solitário"
      puts
      puts display_card_row
      puts
    end

    ##
    # Linha decorativa com cartas
    #
    def display_card_row
      cards = [
        { value: 'A', suit: '♠' },
        { value: 'K', suit: '♥' },
        { value: 'Q', suit: '♦' },
        { value: 'J', suit: '♣' }
      ]

      row1 = cards.map { |c| card_sprite(c[:value], c[:suit]) }
      rows = row1[0].split("\n").map.with_index do |_, line_idx|
        row1.map { |card| card.split("\n")[line_idx] }.join("  ")
      end

      rows.join("\n")
    end

    ##
    # Tableau visual com múltiplas colunas
    #
    def display_tableau(columns)
      max_height = columns.map { |c| c.length }.max || 0
      return "Tableau vazio" if max_height.zero?

      # Limita a altura para display (máximo 10 cartas visíveis)
      display_height = [max_height, 10].min

      output = []
      display_height.times do |row|
        line = columns.map.with_index do |col, col_idx|
          if row < col.length
            card = col[row]
            visible = row == col.length - 1 || card[:visible]
            card_inline(card[:card].value, card[:card].suit, visible)
          else
            "  "
          end
        end.join("  ")
        output << line
      end

      output.join("\n")
    end

    ##
    # Foundation display
    #
    def display_foundation(suit, cards)
      top_card = cards.last
      if top_card.nil?
        "Empty #{suit}"
      else
        "#{suit}: #{top_card.value}#{suit}"
      end
    end

    ##
    # Status do jogo visual
    #
    def display_game_status(score, moves, time_elapsed)
      status = "#{COLORS[:green]}Score: #{score}#{COLORS[:reset]} | " \
               "#{COLORS[:cyan]}Moves: #{moves}#{COLORS[:reset]} | " \
               "#{COLORS[:yellow]}Time: #{time_elapsed}s#{COLORS[:reset]}"
      
      "┌─ #{status} ─┐"
    end

    ##
    # Animação de vitória
    #
    def victory_animation
      puts "\n#{COLORS[:green]}#{COLORS[:bold]}"
      puts "    🏆 ✨ VITÓRIA! ✨ 🏆"
      puts "\n"
      puts "    " + ["♠", "♥", "♦", "♣"].map { |s| "#{COLORS[:bold]}#{s}#{COLORS[:reset]}" }.join("  ")
      puts "\n"
      puts "#{COLORS[:reset]}"
    end

    ##
    # Animação de derrota
    #
    def defeat_animation
      puts "\n#{COLORS[:red]}#{COLORS[:bold]}"
      puts "    💀 Game Over 💀"
      puts "\n"
      puts "    Nenhum movimento disponível"
      puts "\n"
      puts "#{COLORS[:reset]}"
    end

    private

    def suit_color(suit)
      case suit
      when '♠', '♣'
        COLORS[:black]
      when '♥', '♦'
        COLORS[:red]
      else
        COLORS[:white]
      end
    end

    def format_value(value, width)
      value.to_s.center(width)
    end
  end
end
