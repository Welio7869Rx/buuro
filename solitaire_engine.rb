# frozen_string_literal: true

##
# SolitaireEngine - Motor para o jogo de Solitário (Klondike)
# Implementação do jogo de cartas clássico com regras completas
#
class SolitaireEngine
  # Tipos de naipes
  SUITS = %w[♠ ♥ ♦ ♣].freeze
  # Valores das cartas
  VALUES = %w[A 2 3 4 5 6 7 8 9 10 J Q K].freeze
  # Cores dos naipes
  COLORS = { '♠' => :black, '♣' => :black, '♥' => :red, '♦' => :red }.freeze

  attr_accessor :foundations, :tableau, :stock, :waste, :score, :moves, :game_state
  attr_reader :start_time, :auto_complete

  class Card
    attr_reader :suit, :value, :color

    def initialize(suit, value)
      @suit = suit
      @value = value
      @color = COLORS[suit]
    end

    def to_s
      "#{@value}#{@suit}"
    end

    def rank
      VALUES.index(@value)
    end

    def ==(other)
      return false if other.nil?
      suit == other.suit && value == other.value
    end
  end

  def initialize
    @foundations = { '♠' => [], '♥' => [], '♦' => [], '♣' => [] }
    @tableau = Array.new(7) { [] }
    @stock = []
    @waste = []
    @score = 0
    @moves = 0
    @game_state = :playing
    @start_time = Time.now
    @auto_complete = false
    @move_history = []

    initialize_deck
    setup_game
  end

  ##
  # Inicializa o baralho completo
  #
  def initialize_deck
    deck = []
    SUITS.each do |suit|
      VALUES.each do |value|
        deck << Card.new(suit, value)
      end
    end
    @stock = deck.shuffle
  end

  ##
  # Configura o jogo: distribui cartas nas colunas e stock
  #
  def setup_game
    # Distribui 28 cartas no tableau (7 colunas com 1 a 7 cartas cada)
    7.times do |col|
      (col + 1).times do |row|
        card = @stock.pop
        @tableau[col] << card
        # Última carta de cada coluna fica virada
        @tableau[col][row][:visible] = (row == col)
      end
    end

    # Marca cartas no tableau como estrutura de hash
    @tableau.each do |column|
      column.map! { |card| { card:, visible: card == column.last } }
    end
  end

  ##
  # Compra uma carta do stock
  #
  def draw_card
    return { success: false, message: 'Stock vazio!' } if @stock.empty?

    if @waste.empty? && !@stock.empty?
      # Virá o resto do stock para o waste
      loop do
        break if @stock.empty?
        card = @stock.pop
        @waste.unshift(card)
      end
    elsif !@waste.empty?
      # Recicla o waste para o stock
      @stock = @waste.reverse
      @waste = []
    end

    card = @waste.shift if @waste.any?
    @score += 1
    @moves += 1

    { success: true, message: 'Carta comprada!', card: card&.to_s }
  end

  ##
  # Move uma carta do waste para uma foundation
  #
  def auto_to_foundation
    waste_card = @waste.first
    return { success: false, message: 'Nenhuma carta no waste' } if waste_card.nil?

    foundation_suit = waste_card.suit
    foundation_cards = @foundations[foundation_suit]

    if can_place_on_foundation?(waste_card, foundation_cards)
      @waste.shift
      @foundations[foundation_suit] << waste_card
      @score += 10
      @moves += 1
      return { success: true, message: "✓ Carta movida para foundation #{foundation_suit}" }
    end

    { success: false, message: 'Movimento inválido' }
  end

  ##
  # Move uma carta do tableau para foundation
  #
  def tableau_to_foundation(col)
    return { success: false, message: 'Coluna inválida!' } unless valid_column?(col)
    return { success: false, message: 'Coluna vazia!' } if @tableau[col].empty?

    card_entry = @tableau[col].last
    return { success: false, message: 'Carta virada!' } unless card_entry[:visible]

    card = card_entry[:card]
    foundation_suit = card.suit
    foundation_cards = @foundations[foundation_suit]

    if can_place_on_foundation?(card, foundation_cards)
      @tableau[col].pop
      @foundations[foundation_suit] << card
      @score += 10
      @moves += 1
      reveal_tableau_card(col)
      return { success: true, message: "✓ Carta movida para foundation #{foundation_suit}" }
    end

    { success: false, message: 'Movimento inválido' }
  end

  ##
  # Move uma carta entre colunas do tableau
  #
  def tableau_move(from_col, to_col)
    return { success: false, message: 'Colunas inválidas!' } unless valid_column?(from_col) && valid_column?(to_col)
    return { success: false, message: 'Coluna origem vazia!' } if @tableau[from_col].empty?

    # Encontra a primeira carta virada na coluna
    card_index = @tableau[from_col].rindex { |e| e[:visible] }
    return { success: false, message: 'Nenhuma carta virada!' } if card_index.nil?

    card = @tableau[from_col][card_index][:card]

    # Verifica se pode colocar na coluna destino
    if @tableau[to_col].empty?
      # Só Rei pode ir para coluna vazia
      if card.value != 'K'
        return { success: false, message: 'Apenas Rei pode ir para coluna vazia!' }
      end
    else
      dest_card = @tableau[to_col].last[:card]
      unless can_place_on_tableau?(card, dest_card)
        return { success: false, message: 'Movimento inválido! Cores/Valores incompatíveis.' }
      end
    end

    # Realiza o movimento
    cards_to_move = @tableau[from_col].slice!(card_index..-1)
    @tableau[to_col].concat(cards_to_move)
    @score += 5
    @moves += 1
    reveal_tableau_card(from_col)

    { success: true, message: '✓ Cartas movidas!' }
  end

  ##
  # Gira uma carta de face para cima (revela)
  #
  def reveal_tableau_card(col)
    return unless @tableau[col].any?
    @tableau[col].last[:visible] = true
  end

  ##
  # Verifica se o jogo foi vencido
  #
  def check_win
    if @foundations.values.all? { |f| f.size == 13 }
      @game_state = :won
      @score += (600 - (Time.now - @start_time).to_i) # Bônus por tempo
      return true
    end
    false
  end

  ##
  # Tenta auto-completar (move automaticamente cartas para foundations)
  #
  def auto_complete_foundations
    moved = true
    moves_count = 0

    while moved && moves_count < 20
      moved = false

      # Tenta mover do waste
      if @waste.any?
        card = @waste.first
        if can_place_on_foundation?(card, @foundations[card.suit])
          @waste.shift
          @foundations[card.suit] << card
          moved = true
          moves_count += 1
          next
        end
      end

      # Tenta mover do tableau
      @tableau.each_with_index do |column, col|
        next if column.empty?

        card_entry = column.last
        next unless card_entry[:visible]

        card = card_entry[:card]
        if can_place_on_foundation?(card, @foundations[card.suit])
          column.pop
          @foundations[card.suit] << card
          reveal_tableau_card(col)
          moved = true
          moves_count += 1
          break
        end
      end
    end

    { auto_moved: moves_count, success: check_win }
  end

  ##
  # Desfaz o último movimento
  #
  def undo
    return { success: false, message: 'Nenhum movimento para desfazer' } if @move_history.empty?

    @move_history.pop
    @score = [@score - 5, 0].max
    @moves -= 1

    { success: true, message: 'Último movimento desfeito!' }
  end

  ##
  # Retorna o estado atual do jogo
  #
  def game_status
    {
      tableau: format_tableau,
      foundations: format_foundations,
      stock: { total: @stock.size },
      waste: format_waste,
      score: @score,
      moves: @moves,
      game_state: @game_state.to_s,
      time_elapsed: (Time.now - @start_time).round,
      won: @game_state == :won
    }
  end

  ##
  # Formata o tableau para exibição
  #
  def format_tableau
    @tableau.map.with_index do |column, index|
      {
        column: index,
        cards: column.map { |e| e[:visible] ? e[:card].to_s : '🂠' },
        empty: column.empty?,
        card_count: column.size
      }
    end
  end

  ##
  # Formata as foundations para exibição
  #
  def format_foundations
    @foundations.map do |suit, cards|
      {
        suit:,
        top_card: cards.last&.to_s || 'vazio',
        total: cards.size
      }
    end
  end

  ##
  # Formata o waste para exibição
  #
  def format_waste
    {
      total: @waste.size,
      top_card: @waste.first&.to_s || 'vazio',
      visible_cards: @waste.first(3).map(&:to_s)
    }
  end

  ##
  # Retorna as opções de movimento possíveis
  #
  def get_possible_moves
    moves = []

    # Movimentos do waste
    if @waste.any?
      @tableau.each_with_index do |_, col|
        moves << { from: 'waste', to: "tableau_#{col}", description: "Mover de waste para coluna #{col}" }
      end
      moves << { from: 'waste', to: 'foundation', description: 'Mover de waste para foundation' }
    end

    # Movimentos do tableau
    @tableau.each_with_index do |column, from_col|
      next if column.empty?

      # Para outras colunas
      @tableau.each_with_index do |_, to_col|
        next if from_col == to_col
        moves << { from: "tableau_#{from_col}", to: "tableau_#{to_col}", description: "Mover de coluna #{from_col} para #{to_col}" }
      end

      # Para foundations
      moves << { from: "tableau_#{from_col}", to: 'foundation', description: "Mover de coluna #{from_col} para foundation" }
    end

    moves
  end

  private

  def valid_column?(col)
    col.is_a?(Integer) && col >= 0 && col < 7
  end

  def can_place_on_foundation?(card, foundation_cards)
    if foundation_cards.empty?
      card.value == 'A'
    else
      last_card = foundation_cards.last
      card.suit == last_card.suit && card.rank == last_card.rank + 1
    end
  end

  def can_place_on_tableau?(card, dest_card)
    # Cores opostas e valor decrescente
    card.color != dest_card.color && card.rank == dest_card.rank - 1
  end
end
