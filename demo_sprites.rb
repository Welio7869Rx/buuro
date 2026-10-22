#!/usr/bin/env ruby
# frozen_string_literal: true

##
# Demo dos Sprites de Cartas
# Execute este arquivo para ver uma demonstração dos sprites
#
# Uso: ruby demo_sprites.rb
#

require_relative 'card_sprites'

def clear_screen
  system('clear') || system('cls')
end

def demo_menu
  clear_screen
  puts "\n" + "="*70
  puts "🎨 DEMONSTRAÇÃO DE SPRITES DE CARTAS".center(70)
  puts "="*70 + "\n"

  puts "1. 🏠 Tela Inicial (Splash Screen)"
  puts "2. 🎴 Cartas Individuais"
  puts "3. 📚 Cartas em Sequência"
  puts "4. 🎮 Menu Principal"
  puts "5. 📊 Status do Jogo"
  puts "6. 🏆 Animação de Vitória"
  puts "7. 💀 Animação de Derrota"
  puts "8. 🌈 Teste de Cores"
  puts "9. 🚪 Sair"

  print "\nEscolha (1-9): "
  gets.chomp
end

def demo_splash_screen
  clear_screen
  puts CardSprites::TITLE_SPRITE
  puts "\n"
  puts CardSprites.display_card_row
  puts "\n\nPressione ENTER para continuar..."
  gets
end

def demo_individual_cards
  clear_screen
  puts "🎴 CARTAS INDIVIDUAIS\n\n"

  # Mostra 12 cartas (3 de cada naipe)
  cards = [
    { value: 'A', suit: '♠' },
    { value: 'K', suit: '♠' },
    { value: '5', suit: '♠' },
    { value: 'A', suit: '♥' },
    { value: 'K', suit: '♥' },
    { value: '5', suit: '♥' },
    { value: 'A', suit: '♦' },
    { value: 'K', suit: '♦' },
    { value: '5', suit: '♦' },
    { value: 'A', suit: '♣' },
    { value: 'K', suit: '♣' },
    { value: '5', suit: '♣' }
  ]

  # Organiza em grupos de 4 (uma linha com 4 cartas)
  cards.each_slice(4) do |group|
    sprites = group.map { |card| CardSprites.card_sprite(card[:value], card[:suit]) }
    
    # Combina os sprites lado a lado
    lines = sprites[0].split("\n").length
    (0...lines).each do |line_idx|
      puts group.map.with_index do |_, card_idx|
        sprites[card_idx].split("\n")[line_idx]
      end.join("  ")
    end
    puts "\n"
  end

  puts "\nPressione ENTER para continuar..."
  gets
end

def demo_card_sequence
  clear_screen
  puts "📚 CARTAS EM SEQUÊNCIA\n\n"

  sequences = [
    { title: "Naipe Espadas", cards: ['A', '2', '3', '4', '5', 'K'], suit: '♠' },
    { title: "Naipe Corações", cards: ['A', '2', '3', '4', '5', 'K'], suit: '♥' },
    { title: "Naipe Ouros", cards: ['A', '2', '3', '4', '5', 'K'], suit: '♦' },
    { title: "Naipe Paus", cards: ['A', '2', '3', '4', '5', 'K'], suit: '♣' }
  ]

  sequences.each do |seq|
    puts "#{seq[:title]}:"
    inline = seq[:cards].map { |val| CardSprites.card_inline(val, seq[:suit]) }.join(" → ")
    puts inline
    puts "\n"
  end

  puts "\nPressione ENTER para continuar..."
  gets
end

def demo_main_menu
  clear_screen
  CardSprites.display_game_menu
  puts "\nPressione ENTER para continuar..."
  gets
end

def demo_game_status
  clear_screen
  puts "📊 STATUS DO JOGO\n\n"

  # Diferentes scores
  statuses = [
    { score: 0, moves: 0, time: 0 },
    { score: 50, moves: 15, time: 45 },
    { score: 150, moves: 45, time: 180 },
    { score: 300, moves: 100, time: 600 }
  ]

  statuses.each do |status|
    puts CardSprites.display_game_status(status[:score], status[:moves], status[:time])
    puts "\n"
  end

  puts "\nPressione ENTER para continuar..."
  gets
end

def demo_victory
  clear_screen
  puts "\n" * 3
  CardSprites.victory_animation
  puts "\nPressione ENTER para continuar..."
  gets
end

def demo_defeat
  clear_screen
  puts "\n" * 3
  CardSprites.defeat_animation
  puts "\nPressione ENTER para continuar..."
  gets
end

def demo_colors
  clear_screen
  puts "🌈 TESTE DE CORES\n\n"

  colors_demo = {
    'Red (Vermelho)' => CardSprites::COLORS[:red],
    'Black (Preto)' => CardSprites::COLORS[:black],
    'Yellow (Amarelo)' => CardSprites::COLORS[:yellow],
    'Cyan (Azul)' => CardSprites::COLORS[:cyan],
    'Green (Verde)' => CardSprites::COLORS[:green],
    'White (Branco)' => CardSprites::COLORS[:white],
    'Bold (Negrito)' => CardSprites::COLORS[:bold]
  }

  colors_demo.each do |name, color|
    puts "  #{color}■ #{name}#{CardSprites::COLORS[:reset]}"
  end

  puts "\n\nExemplos de Uso:\n\n"

  puts "#{CardSprites::COLORS[:green]}✓ Sucesso - Operação realizada#{CardSprites::COLORS[:reset]}"
  puts "#{CardSprites::COLORS[:red]}✗ Erro - Movimento inválido#{CardSprites::COLORS[:reset]}"
  puts "#{CardSprites::COLORS[:yellow]}⚠ Aviso - Verifique suas opções#{CardSprites::COLORS[:reset]}"
  puts "#{CardSprites::COLORS[:cyan]}ℹ Info - Digite 'ajuda' para mais informações#{CardSprites::COLORS[:reset]}"

  puts "\n\nPressione ENTER para continuar..."
  gets
end

# Programa principal
loop do
  choice = demo_menu

  case choice
  when '1'
    demo_splash_screen
  when '2'
    demo_individual_cards
  when '3'
    demo_card_sequence
  when '4'
    demo_main_menu
  when '5'
    demo_game_status
  when '6'
    demo_victory
  when '7'
    demo_defeat
  when '8'
    demo_colors
  when '9'
    clear_screen
    puts "\n👋 Até logo!\n\n"
    break
  else
    puts "\n❌ Opção inválida!"
    sleep 1
  end
end
