# frozen_string_literal: true

##
# ScoreCalculator - Sistema avançado de cálculo de pontuação
# Implementa combos, multiplicadores, bônus e cálculo de score final
#
class ScoreCalculator
  # Configuração de pontuação
  BASE_POINTS = 100
  COMBO_MULTIPLIER = 1.25
  COMBO_THRESHOLD = 3
  PERFECT_WORD_BONUS = 500
  TIME_BONUS_INTERVAL = 10

  attr_accessor :total_points, :combo, :multiplier, :difficulty
  attr_reader :score_history, :milestones_reached

  def initialize(difficulty: :normal, difficulty_config: {})
    @difficulty = difficulty
    @difficulty_config = difficulty_config
    @total_points = 0
    @combo = 0
    @multiplier = 1.0
    @base_multiplier = difficulty_config[:score_multiplier] || 1.5
    @score_history = []
    @milestones_reached = []
    @correct_letters = 0
    @total_letters = 0
  end

  ##
  # Adiciona pontos por acerto de letra
  #
  def add_correct(is_word_complete: false)
    @combo += 1
    @correct_letters += 1

    # Calcula multiplicador de combo
    if @combo >= COMBO_THRESHOLD
      milestone = (@combo / COMBO_THRESHOLD)
      @multiplier = 1.0 + (milestone * (COMBO_MULTIPLIER - 1.0))
    end

    # Calcula pontos
    points = calculate_points(is_word_complete)
    @total_points += points

    # Registra no histórico
    @score_history << {
      action: :correct,
      points:,
      combo: @combo,
      multiplier: @multiplier,
      timestamp: Time.now
    }

    # Verifica marcos
    check_milestones

    {
      points:,
      total: @total_points,
      combo: @combo,
      multiplier: @multiplier.round(2),
      milestone: @milestones_reached.last
    }
  end

  ##
  # Adiciona pontos por erro (reseta combo)
  #
  def add_error
    @combo = 0
    @multiplier = 1.0

    @score_history << {
      action: :error,
      points: 0,
      combo: 0,
      multiplier: 1.0,
      timestamp: Time.now
    }

    { combo: 0, multiplier: 1.0, total: @total_points }
  end

  ##
  # Calcula bônus de tempo
  #
  def add_time_bonus(seconds)
    bonus = (seconds / TIME_BONUS_INTERVAL) * 50
    @total_points += bonus

    @score_history << {
      action: :time_bonus,
      points: bonus,
      timestamp: Time.now
    }

    bonus
  end

  ##
  # Calcula pontuação final com todos os bônus
  #
  def calculate_final_score(game_progress, time_taken)
    final = @total_points
    bonuses = {}

    # Bônus de tempo
    time_bonus = add_time_bonus(time_taken)
    bonuses[:time] = time_bonus

    # Bônus de acurácia
    if game_progress[:accuracy] > 90
      accuracy_bonus = (game_progress[:accuracy] / 100.0) * 200
      final += accuracy_bonus.round
      bonuses[:accuracy] = accuracy_bonus.round
    end

    # Bônus de combo máximo
    if @combo >= 10
      combo_bonus = @combo * 50
      final += combo_bonus
      bonuses[:combo] = combo_bonus
    end

    # Multiplicador de dificuldade final
    final = (final * @base_multiplier).round

    {
      base_score: @total_points,
      bonuses:,
      final_score: final,
      difficulty_multiplier: @base_multiplier,
      combo_streak: @combo
    }
  end

  ##
  # Retorna estatísticas de score
  #
  def statistics
    {
      total_points: @total_points,
      highest_combo: @score_history.map { |s| s[:combo] }.max || 0,
      accuracy: calculate_accuracy,
      milestones: @milestones_reached,
      score_breakdown: breakdown_by_action
    }
  end

  ##
  # Reseta o score
  #
  def reset
    @total_points = 0
    @combo = 0
    @multiplier = 1.0
    @score_history.clear
    @milestones_reached.clear
    @correct_letters = 0
  end

  private

  def calculate_points(is_word_complete)
    points = BASE_POINTS * @multiplier * @base_multiplier
    points = points.round

    # Bônus por palavra completa
    points += PERFECT_WORD_BONUS if is_word_complete

    points
  end

  def check_milestones
    milestones = {
      2 => '🎯 Combo x2!',
      3 => '🔥 Combo x3!',
      5 => '🚀 Combo x5!',
      10 => '⭐ Combo x10!',
      20 => '👑 Combo x20! LENDÁRIO!'
    }

    milestones.each do |threshold, message|
      if @combo == threshold && !@milestones_reached.include?(message)
        @milestones_reached << message
      end
    end
  end

  def calculate_accuracy
    return 0 if @score_history.empty?

    correct = @score_history.count { |s| s[:action] == :correct }
    total = @score_history.count { |s| s[:action].in?([:correct, :error]) }

    return 0 if total.zero?
    ((correct.to_f / total) * 100).round(2)
  end

  def breakdown_by_action
    result = { correct: 0, error: 0, bonus: 0 }
    @score_history.each do |record|
      case record[:action]
      when :correct
        result[:correct] += record[:points]
      when :error
        result[:error] += 1
      when :time_bonus
        result[:bonus] += record[:points]
      end
    end
    result
  end
end
