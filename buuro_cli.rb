#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'game_engine'
require_relative 'solitaire_engine'
require_relative 'card_sprites'
require_relative 'score_calculator'
require_relative 'database_manager'
require 'colorize' rescue nil

##
# Buuro CLI - Interface de linha de comando para jogos
# Permite jogar via terminal com suporte a múltiplos jogadores
#
class BuuroCLI
  def initialize
    @db = DatabaseManager.new
    @current_player = nil
    @game = nil
    @score_calc = nil
  end

  def run
    show_splash_screen
    
    loop do
      show_main_menu
      choice = gets.chomp

      case choice
      when '1' then select_or_create_player
      when '2' then choose_game
      when '3' then show_statistics
      when '4' then show_leaderboard
      when '5' then manage_words
      when '6' then exit_game
      else
        puts "❌ Opção inválida!"
      end
    end
  end

  private

  def show_splash_screen
    system('clear') || system('cls')
    puts CardSprites::TITLE_SPRITE
    puts "\n#{CardSprites.display_card_row}\n\n"
    puts "Bem-vindo ao BUURO - Sistema de Jogos em Ruby!".center(60)
    puts "Pressione ENTER para continuar..."
    gets
    system('clear') || system('cls')
  end

  def show_main_menu
    system('clear') || system('cls')
    CardSprites.display_game_menu
    print "Escolha uma opção: "
  end

  def select_or_create_player
    puts "\n👤 Gerenciar Jogador:"
    print "Digite o nome do jogador: "
    username = gets.chomp.strip

    if username.empty?
      puts "❌ Nome não pode estar vazio!"
      return
    end

    print "Email (opcional): "
    email = gets.chomp.strip

    @current_player = @db.create_or_get_player(username, email.empty? ? nil : email)
    puts "✅ Jogador selecionado: #{@current_player['username']}"
  end

  def choose_game
    if !@current_player
      puts "❌ Selecione um jogador primeiro!"
      return
    end

    puts "\n🎮 Escolha um jogo:"
    puts "1. 🎯 Jogo da Forca"
    puts "2. ♠️  Solitário (Klondike)"
    print "Escolha: "

    choice = gets.chomp

    case choice
    when '1'
      start_game
    when '2'
      play_solitaire
    else
      puts "❌ Opção inválida!"
    end
  end

  def play_solitaire
    puts "\n🎮 Iniciando Solitário (Klondike)!"
    puts "\n💡 Dica: Digite 'ajuda' para ver os comandos disponíveis"
    puts "="*70

    solitaire = SolitaireEngine.new
    start_time = Time.now

    loop do
      display_solitaire_board(solitaire)
      
      puts "📋 Comandos:"
      puts "  #{CardSprites::COLORS[:cyan]}comprar#{CardSprites::COLORS[:reset]}     - Compra uma carta do stock"
      puts "  #{CardSprites::COLORS[:cyan]}w->f#{CardSprites::COLORS[:reset]}         - Move waste para foundation"
      puts "  #{CardSprites::COLORS[:cyan]}t->f (col)#{CardSprites::COLORS[:reset]}    - Move tableau col para foundation"
      puts "  #{CardSprites::COLORS[:cyan]}t (c1) (c2)#{CardSprites::COLORS[:reset]}   - Move de coluna c1 para c2"
      puts "  #{CardSprites::COLORS[:cyan]}auto#{CardSprites::COLORS[:reset]}        - Auto-completa foundations"
      puts "  #{CardSprites::COLORS[:cyan]}status#{CardSprites::COLORS[:reset]}      - Mostra status do jogo"
      puts "  #{CardSprites::COLORS[:cyan]}ajuda#{CardSprites::COLORS[:reset]}       - Mostra regras"
      puts "  #{CardSprites::COLORS[:cyan]}sair#{CardSprites::COLORS[:reset]}        - Sair do jogo"
      print "\n#{CardSprites::COLORS[:yellow]}Comando:#{CardSprites::COLORS[:reset]} "

      command = gets.chomp.downcase.strip

      case command
      when 'comprar'
        result = solitaire.draw_card
        puts result[:success] ? "#{CardSprites::COLORS[:green]}✓ #{result[:message]}#{CardSprites::COLORS[:reset]}" : "#{CardSprites::COLORS[:red]}✗ #{result[:message]}#{CardSprites::COLORS[:reset]}"

      when /^w->f/
        result = solitaire.auto_to_foundation
        puts result[:success] ? "#{CardSprites::COLORS[:green]}✓ #{result[:message]}#{CardSprites::COLORS[:reset]}" : "#{CardSprites::COLORS[:red]}✗ #{result[:message]}#{CardSprites::COLORS[:reset]}"

      when /^t->f\s+(\d)$/
        col = $1.to_i
        result = solitaire.tableau_to_foundation(col)
        puts result[:success] ? "#{CardSprites::COLORS[:green]}✓ #{result[:message]}#{CardSprites::COLORS[:reset]}" : "#{CardSprites::COLORS[:red]}✗ #{result[:message]}#{CardSprites::COLORS[:reset]}"

      when /^t\s+(\d)\s+(\d)$/
        from = $1.to_i
        to = $2.to_i
        result = solitaire.tableau_move(from, to)
        puts result[:success] ? "#{CardSprites::COLORS[:green]}✓ #{result[:message]}#{CardSprites::COLORS[:reset]}" : "#{CardSprites::COLORS[:red]}✗ #{result[:message]}#{CardSprites::COLORS[:reset]}"

      when 'auto'
        result = solitaire.auto_complete_foundations
        puts "✨ Auto-moveu #{result[:auto_moved]} cartas"
        if result[:success]
          CardSprites.victory_animation
          save_solitaire_score(solitaire, start_time)
          return
        end

      when 'status'
        status = solitaire.game_status
        puts "\n📊 Status do Jogo:"
        puts "  #{CardSprites::COLORS[:green]}Score: #{status[:score]}#{CardSprites::COLORS[:reset]}"
        puts "  #{CardSprites::COLORS[:cyan]}Movimentos: #{status[:moves]}#{CardSprites::COLORS[:reset]}"
        puts "  #{CardSprites::COLORS[:yellow]}Tempo: #{status[:time_elapsed]}s#{CardSprites::COLORS[:reset]}"
        puts "  Foundations: #{status[:foundations].map { |f| "#{f[:suit]}:#{f[:total]}" }.join(' ')}"

      when 'ajuda'
        puts "\n#{CardSprites::COLORS[:bold]}#{CardSprites::COLORS[:cyan]}📖 Ajuda do Solitário:#{CardSprites::COLORS[:reset]}"
        puts "\n#{CardSprites::COLORS[:green]}Objetivo:#{CardSprites::COLORS[:reset]} Mova todas as 52 cartas para as foundations"
        puts "\n#{CardSprites::COLORS[:yellow]}Regras:#{CardSprites::COLORS[:reset]}"
        puts "  ♠ Foundations: começam com A e vão até K do mesmo naipe"
        puts "  ♥ Tableau: cartas alternadas (vermelho/preto) em ordem decrescente"
        puts "  ♦ Rei pode iniciar uma coluna vazia"
        puts "  ♣ Máximo 3 cartas viáveis por vez do stock"

      when 'sair', 'quit', 'exit'
        puts "#{CardSprites::COLORS[:red]}Jogo cancelado!#{CardSprites::COLORS[:reset]}"
        return

      else
        puts "#{CardSprites::COLORS[:red]}❌ Comando inválido! Digite 'ajuda' para ver os comandos.#{CardSprites::COLORS[:reset]}"
      end

      # Verifica vitória
      if solitaire.check_win
        display_solitaire_board(solitaire)
        CardSprites.victory_animation
        puts "#{CardSprites::COLORS[:green]}🏆 VITÓRIA! Você ganhou em #{solitaire.moves} movimentos!#{CardSprites::COLORS[:reset]}"
        save_solitaire_score(solitaire, start_time)
        return
      end
    end
  end

  def display_solitaire_board(solitaire)
    system('clear') || system('cls')
    puts "\n" + "="*70
    puts "🃏 SOLITÁRIO (Klondike)".center(70)
    puts "="*70 + "\n"

    status = solitaire.game_status

    # Stock e Waste com sprites
    puts "📚 Stock: #{status[:stock][:total]} cartas".ljust(35) + "📤 Waste: #{status[:waste][:visible_cards].map { |c| CardSprites.card_inline(c.split(/[♠♥♦♣]/)[0], c.split(/[♠♥♦♣]/)[1]) }.join(' ')}"

    puts "\n" + "-" * 70

    # Foundations (4 naipes)
    puts "\n📍 Foundations:"
    puts "  " + status[:foundations].map { |f| "#{CardSprites.suit_sprite(f[:suit])}: #{f[:top_card]}" }.join("    ")

    puts "\n" + "-" * 70

    # Tableau (7 colunas)
    puts "\n🎴 Tableau:\n"
    tableau_display = status[:tableau].map do |col|
      cards_str = col[:cards].map.with_index do |card, idx|
        if card == '🂠'
          card
        else
          # Extrai valor e naipe
          value = card.gsub(/[♠♥♦♣]/, '')
          suit = card.gsub(/[A-K0-9]/, '')
          CardSprites.card_inline(value, suit)
        end
      end.join(' ')

      "Col#{col[:column]}: #{cards_str.ljust(25)} (#{col[:card_count]}c)"
    end

    tableau_display.each { |col| puts "  " + col }

    puts "\n" + "="*70
    puts CardSprites.display_game_status(status[:score], status[:moves], status[:time_elapsed])
    puts "="*70 + "\n"
  end

  def save_solitaire_score(solitaire, start_time)
    elapsed_time = (Time.now - start_time).round
    final_score = solitaire.score

    result = @db.save_game_score(
      player_id: @current_player['id'],
      game_type: 'solitaire',
      score: final_score,
      moves: solitaire.moves,
      time_elapsed: elapsed_time,
      won: true
    )

    if result
      puts "✅ Pontuação salva! Total: #{final_score} pontos"
    else
      puts "⚠️  Erro ao salvar pontuação"
    end
  end

  def start_game
    if !@current_player
      puts "❌ Selecione um jogador primeiro!"
      return
    end

    puts "\n🎮 Iniciando Jogo da Forca!"
    puts "\n📊 Escolha a dificuldade:"
    puts "1. ✅ Fácil (8 vidas)"
    puts "2. 🟡 Normal (6 vidas)"
    puts "3. 🔴 Difícil (4 vidas)"
    print "Escolha: "

    difficulty_choice = gets.chomp
    difficulty = case difficulty_choice
                 when '1' then :facil
                 when '2' then :normal
                 when '3' then :dificil
                 else :normal
                 end

    # Busca uma palavra
    word_data = @db.get_random_word(difficulty.to_s)

    if !word_data
      puts "❌ Nenhuma palavra disponível para essa dificuldade!"
      return
    end

    @game = GameEngine.new(
      word: word_data[:word],
      difficulty:,
      word_data:
    )

    @score_calc = ScoreCalculator.new(
      difficulty:,
      difficulty_config: GameEngine::DIFFICULTIES[difficulty]
    )

    start_time = Time.now
    play_game(start_time)
  end

  def play_game(start_time)
    puts "\n" + "="*60
    puts "🎮 JOGO INICIADO!".center(60)
    puts "="*60
    puts "\n📝 Categoria: #{@game.word_data[:category] || 'Geral'}"
    puts "💡 Dica: #{@game.word_data[:hint] || 'Sem dica disponível'}"
    puts "❤️  Vidas: #{@game.lives}"
    puts "Word: #{@game.display_word}\n\n"

    loop do
      puts "Palavra: #{@game.display_word}"
      puts "Letras usadas: #{@game.guessed_letters.to_a.sort.join(', ')}"
      puts "Letras erradas: #{@game.wrong_letters.to_a.sort.join(', ')}" if !@game.wrong_letters.empty?
      puts "❤️  Vidas: #{@game.lives} | 🔥 Combo: #{@score_calc.combo} | 💰 Pontos: #{@score_calc.total_points}"

      print "\nDigite uma letra: "
      letter = gets.chomp.strip.upcase

      if letter.length != 1 || !letter.match?(/[A-ZÁÉÍÓÚ]/)
        puts "❌ Digite apenas uma letra!"
        next
      end

      result = @game.guess(letter)

      if result[:success]
        puts "✅ #{result[:message]}"
        @score_calc.add_correct(is_word_complete: result[:won])
      else
        puts "❌ #{result[:message]}"
        @score_calc.add_error
      end

      if @game.won?
        end_game(start_time, true)
        break
      elsif @game.lost?
        end_game(start_time, false)
        break
      end

      puts "\n" + "-"*60 + "\n"
    end
  end

  def end_game(start_time, won)
    time_taken = (Time.now - start_time).round

    puts "\n" + "="*60

    if won
      puts "🎉 PARABÉNS! VOCÊ VENCEU! 🎉".center(60)
      bonus = @score_calc.add_time_bonus(time_taken)
      final_score = @score_calc.total_points + bonus
    else
      puts "👻 GAME OVER! VOCÊ PERDEU! 👻".center(60)
      puts "A palavra era: #{@game.word}"
      final_score = @score_calc.total_points
    end

    puts "="*60

    stats = @score_calc.statistics
    puts "\n📊 Estatísticas da Partida:"
    puts "├─ Pontos: #{final_score}"
    puts "├─ Combo Máximo: #{stats[:highest_combo]}"
    puts "├─ Acurácia: #{stats[:accuracy]}%"
    puts "├─ Tempo: #{time_taken}s"
    puts "├─ Letras Usadas: #{@game.guessed_letters.size}"
    puts "└─ Taxa de Acerto: #{@game.accuracy_percent}%"

    # Salva no banco de dados
    @db.save_game_session(@current_player['id'], {
      game_type: 'forca',
      difficulty: @game.difficulty.to_s,
      word: @game.word,
      category: @game.word_data[:category],
      guessed_letters: @game.guessed_letters.to_a,
      wrong_letters: @game.wrong_letters.to_a,
      score: final_score,
      combo: stats[:highest_combo],
      accuracy: @game.accuracy_percent,
      time_taken:,
      won:
    })

    puts "\n✅ Partida salva com sucesso!"
  end

  def show_statistics
    if !@current_player
      puts "❌ Selecione um jogador primeiro!"
      return
    end

    stats = @db.get_player_stats(@current_player['id'])

    puts "\n📊 Estatísticas de #{@current_player['username']}:"
    puts "├─ Total de Partidas: #{stats[:total_games]}"
    puts "├─ Vitórias: #{stats[:wins]}"
    puts "├─ Taxa de Vitória: #{stats[:win_rate]}%"
    puts "├─ Pontuação Total: #{stats[:total_score]}"
    puts "├─ Pontuação Média: #{stats[:average_score]}"
    puts "├─ Melhor Pontuação: #{stats[:best_score]}"
    puts "├─ Maior Combo: #{stats[:longest_combo]}"
    puts "└─ Acurácia Média: #{stats[:average_accuracy]}%"

    # Mostra últimas 5 partidas
    history = @db.get_player_history(@current_player['id'], limit: 5)
    if history.any?
      puts "\n📜 Últimas Partidas:"
      history.each_with_index do |game, idx|
        status = game['won'] ? '✅' : '❌'
        puts "  #{idx + 1}. #{status} Pontos: #{game['final_score']} | #{game['created_at']}"
      end
    end
  end

  def show_leaderboard
    leaderboard = @db.get_leaderboard(limit: 10)

    puts "\n🏆 Top 10 Jogadores:"
    puts "-" * 60
    puts "Rank | Jogador              | Pontos      | Taxa de Vitória"
    puts "-" * 60

    leaderboard.each_with_index do |player, idx|
      rank = (idx + 1).to_s.ljust(4)
      name = player['username'].ljust(20)
      score = player['score'].to_s.ljust(11)
      win_rate = "#{player['win_rate']}%"

      puts "#{rank} | #{name} | #{score} | #{win_rate}"
    end

    puts "-" * 60
  end

  def manage_words
    puts "\n📚 Gerenciar Palavras:"
    puts "1. ➕ Adicionar Palavra"
    puts "2. 📋 Listar Palavras por Dificuldade"
    puts "3. 📊 Estatísticas do Banco de Dados"
    print "Escolha: "

    choice = gets.chomp

    case choice
    when '1' then add_word
    when '2' then list_words
    when '3' then show_word_stats
    else
      puts "❌ Opção inválida!"
    end
  end

  def add_word
    print "Palavra: "
    word = gets.chomp.strip.upcase

    print "Categoria: "
    category = gets.chomp.strip

    puts "Dificuldade: 1.Fácil  2.Normal  3.Difícil"
    print "Escolha: "
    difficulty = case gets.chomp
                 when '1' then 'facil'
                 when '2' then 'normal'
                 when '3' then 'dificil'
                 else 'normal'
                 end

    print "Dica: "
    hint = gets.chomp.strip

    @db.add_word(word, category, difficulty, hint)
    puts "✅ Palavra adicionada com sucesso!"
  end

  def list_words
    puts "Dificuldade: 1.Fácil  2.Normal  3.Difícil"
    print "Escolha: "
    difficulty = case gets.chomp
                 when '1' then 'facil'
                 when '2' then 'normal'
                 when '3' then 'dificil'
                 else 'normal'
                 end

    words = @db.get_words_by_difficulty(difficulty, limit: 20)

    puts "\n📚 Palavras (#{difficulty}):"
    words.each_with_index do |word, idx|
      puts "#{idx + 1}. #{word[:word]} - #{word[:category]} (#{word[:hint]})"
    end
  end

  def show_word_stats
    stats = @db.get_global_stats
    puts "\n📊 Estatísticas Globais:"
    puts "├─ Total de Jogadores: #{stats[:total_players]}"
    puts "├─ Total de Partidas: #{stats[:total_games]}"
    puts "├─ Total de Palavras: #{stats[:total_words]}"
    puts "└─ Pontuação Média Global: #{stats[:average_score]}"
  end

  def exit_game
    puts "\n👋 Obrigado por jogar! Até logo!\n"
    exit
  end
end

# Inicia a CLI
cli = BuuroCLI.new
cli.run if __FILE__ == $0
