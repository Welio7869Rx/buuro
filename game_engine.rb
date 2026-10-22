# frozen_string_literal: true

##
# GameEngine - Motor de lógica dos jogos
# Gerencia regras, palavras, tentativas e estados do jogo
#
class GameEngine
  # Dificuldades disponíveis
  DIFFICULTIES = {
    facil: { lives: 8, score_multiplier: 1.0, hint_multiplier: 1.5 },
    normal: { lives: 6, score_multiplier: 1.5, hint_multiplier: 1.0 },
    dificil: { lives: 4, score_multiplier: 2.5, hint_multiplier: 0.5 }
  }.freeze

  attr_accessor :word, :guessed_letters, :wrong_letters, :lives, :difficulty
  attr_reader :difficulty_config, :game_state, :word_length

  def initialize(word:, difficulty: :normal, word_data: {})
    @word = word.upcase
    @word_data = word_data
    @guessed_letters = Set.new
    @wrong_letters = Set.new
    @difficulty = difficulty.to_sym
    @difficulty_config = DIFFICULTIES[@difficulty]
    @lives = @difficulty_config[:lives]
    @game_state = :playing
    @start_time = Time.now
    @combo = 0
    @streak = 0
    @word_length = @word.length
  end

  ##
  # Processa um palpite de letra
  # Retorna hash com resultado da ação
  #
  def guess(letter)
    letter = letter.upcase
    
    # Validações
    return error_response('Letra já foi tentada!') if @guessed_letters.include?(letter)
    return error_response('Jogo já terminou!') if finished?
    
    @guessed_letters.add(letter)

    if @word.include?(letter)
      @combo += 1
      @streak += 1
      success_response(letter)
    else
      @wrong_letters.add(letter)
      @combo = 0
      @lives -= 1
      
      if @lives <= 0
        @game_state = :lost
      end
      
      error_response_guess(letter)
    end
  end

  ##
  # Fornece uma dica sobre a palavra
  #
  def get_hint
    return { error: 'Jogo não iniciado' } unless playing?

    {
      category: @word_data[:category] || 'Geral',
      length: @word_length,
      vowels: get_vowels,
      repeated_letters: get_repeated_letters,
      definition: @word_data[:hint] || 'Sem dica disponível'
    }
  end

  ##
  # Revela uma letra aleatória
  #
  def reveal_letter
    return { error: 'Nenhuma letra para revelar' } if remaining_letters.empty?

    letter = remaining_letters.sample
    @guessed_letters.add(letter)
    { revealed: letter, remaining: remaining_letters.size }
  end

  ##
  # Verifica status do jogo
  #
  def display_word
    @word.each_char.map { |char| @guessed_letters.include?(char) ? char : '_' }.join(' ')
  end

  def unique_letters_count
    @word.chars.uniq.size
  end

  def guessed_unique_count
    @guessed_letters.count { |l| @word.include?(l) }
  end

  def won?
    if guessed_unique_count == unique_letters_count && @game_state == :playing
      @game_state = :won
      true
    else
      @game_state == :won
    end
  end

  def lost?
    if @lives <= 0 && @game_state == :playing
      @game_state = :lost
      true
    else
      @game_state == :lost
    end
  end

  def finished?
    won? || lost?
  end

  def playing?
    @game_state == :playing && !finished?
  end

  def remaining_letters
    @word.chars.uniq.reject { |letter| @guessed_letters.include?(letter) }.to_set
  end

  def game_progress
    {
      word_display: display_word,
      guessed_letters: @guessed_letters.to_a.sort,
      wrong_letters: @wrong_letters.to_a.sort,
      lives: @lives,
      difficulty: @difficulty,
      combo: @combo,
      streak: @streak,
      letters_correct: guessed_unique_count,
      letters_total: unique_letters_count,
      accuracy: accuracy_percent,
      game_state: @game_state.to_s,
      time_elapsed: (Time.now - @start_time).round
    }
  end

  def accuracy_percent
    return 0 if @guessed_letters.empty?
    correct = @guessed_letters.count { |l| @word.include?(l) }
    ((correct.to_f / @guessed_letters.size) * 100).round(2)
  end

  private

  def success_response(letter)
    if won?
      @game_state = :won
      { success: true, letter:, message: '✓ Acerto!', won: true }
    else
      { success: true, letter:, message: '✓ Acerto!' }
    end
  end

  def error_response(message)
    { success: false, message: }
  end

  def error_response_guess(letter)
    if @lives <= 0
      @game_state = :lost
      { success: false, letter:, message: '✗ Erro! Game Over!', lost: true }
    else
      { success: false, letter:, message: '✗ Erro!' }
    end
  end

  def get_vowels
    vowels = @word.chars.select { |c| 'AEIOUÁÉÍÓÚ'.include?(c) }.uniq
    vowels.empty? ? 'Nenhuma' : vowels.join(', ')
  end

  def get_repeated_letters
    repeated = @word.chars.group_by { |c| c }.select { |_, v| v.size > 1 }.keys
    repeated.empty? ? 'Nenhuma' : repeated.join(', ')
  end
end
