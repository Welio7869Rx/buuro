# frozen_string_literal: true

require 'sinatra'
require 'sinatra/cors'
require 'json'
require_relative 'game_engine'
require_relative 'score_calculator'
require_relative 'database_manager'

##
# Buuro Game Server - API REST em Sinatra
# Gerencia jogos, scores, usuários e estatísticas
#
class BuuroGameServer < Sinatra::Base
  register Sinatra::Cors
  set :allow_origin, '*'
  set :allow_methods, [:get, :post, :put, :delete, :options]
  set :allow_headers, ['Content-Type', 'Authorization']
  set :sessions, true

  # Inicializa gerenciadores
  before do
    @db = DatabaseManager.new
    content_type :json
  end

  # Health Check
  get '/api/health' do
    {
      status: 'ok',
      timestamp: Time.now.iso8601,
      version: '2.0'
    }.to_json
  end

  # ==========================================
  # PLAYERS - Gerenciamento de Usuários
  # ==========================================

  post '/api/players' do
    data = JSON.parse(request.body.read)
    player = @db.create_or_get_player(data['username'], data['email'])
    
    {
      success: true,
      player: player.transform_keys(&:to_sym)
    }.to_json
  end

  get '/api/players/:username' do
    username = params[:username]
    player = @db.instance_variable_get(:@db).execute(
      'SELECT * FROM players WHERE username = ?',
      [username]
    ).first

    if player
      stats = @db.get_player_stats(player['id'])
      {
        success: true,
        player: player.transform_keys(&:to_sym),
        statistics: stats
      }.to_json
    else
      status 404
      { success: false, message: 'Jogador não encontrado' }.to_json
    end
  end

  get '/api/players/:player_id/history' do
    player_id = params[:player_id]
    limit = params[:limit] || 20

    history = @db.get_player_history(player_id, limit: limit.to_i)
    {
      success: true,
      games: history
    }.to_json
  end

  get '/api/players/:player_id/statistics' do
    player_id = params[:player_id]
    stats = @db.get_player_stats(player_id)

    {
      success: true,
      statistics: stats
    }.to_json
  end

  get '/api/players/:player_id/achievements' do
    player_id = params[:player_id]
    achievements = @db.instance_variable_get(:@db).execute(
      'SELECT * FROM achievements WHERE player_id = ? ORDER BY earned_at DESC',
      [player_id]
    )

    {
      success: true,
      achievements: achievements
    }.to_json
  end

  # ==========================================
  # GAMES - Gerenciamento de Jogos
  # ==========================================

  post '/api/games/start' do
    data = JSON.parse(request.body.read)
    difficulty = data['difficulty'] || 'normal'
    player_id = data['player_id']

    # Busca uma palavra
    word_data = @db.get_random_word(difficulty)
    
    if !word_data
      status 400
      return { success: false, message: 'Nenhuma palavra disponível' }.to_json
    end

    # Inicializa o jogo
    game = GameEngine.new(
      word: word_data[:word],
      difficulty: difficulty.to_sym,
      word_data: word_data
    )

    # Armazena na sessão
    session[:game] = {
      word: game.word,
      difficulty: difficulty,
      player_id: player_id,
      started_at: Time.now.iso8601
    }

    {
      success: true,
      game_id: session[:game_id] || SecureRandom.uuid,
      difficulty:,
      lives: game.lives,
      word_length: game.word_length
    }.to_json
  end

  post '/api/games/:game_id/guess' do
    data = JSON.parse(request.body.read)
    letter = data['letter']

    if !session[:game]
      status 400
      return { success: false, message: 'Jogo não iniciado' }.to_json
    end

    # Reconstrói o jogo
    game = GameEngine.new(
      word: session[:game][:word],
      difficulty: session[:game][:difficulty].to_sym
    )

    # Processa palpite
    result = game.guess(letter)

    # Atualiza sessão
    session[:game].merge!(game.game_progress)

    response = result.merge(
      game_state: game.game_progress,
      won: game.won?,
      lost: game.lost?
    )

    if game.finished?
      # Salva sessão
      save_game_session(session[:game], game)
    end

    response.to_json
  end

  get '/api/games/:game_id/hint' do
    if !session[:game]
      status 400
      return { success: false, message: 'Jogo não iniciado' }.to_json
    end

    game = GameEngine.new(
      word: session[:game][:word],
      difficulty: session[:game][:difficulty].to_sym
    )

    hint = game.get_hint
    { success: true, hint: }.to_json
  end

  get '/api/games/:game_id/state' do
    if !session[:game]
      status 400
      return { success: false, message: 'Jogo não iniciado' }.to_json
    end

    { success: true, game: session[:game] }.to_json
  end

  # ==========================================
  # LEADERBOARD
  # ==========================================

  get '/api/leaderboard' do
    limit = params[:limit] || 100
    leaderboard = @db.get_leaderboard(limit: limit.to_i)

    {
      success: true,
      leaderboard:,
      total: leaderboard.count
    }.to_json
  end

  # ==========================================
  # WORDS - Banco de Palavras
  # ==========================================

  post '/api/words/add' do
    data = JSON.parse(request.body.read)

    @db.add_word(
      data['word'],
      data['category'],
      data['difficulty'],
      data['hint'],
      data['language'] || 'PT-BR'
    )

    { success: true, message: 'Palavra adicionada' }.to_json
  end

  get '/api/words/difficulties/:difficulty' do
    difficulty = params[:difficulty]
    limit = params[:limit] || 100

    words = @db.get_words_by_difficulty(difficulty, limit: limit.to_i)
    {
      success: true,
      count: words.count,
      words:
    }.to_json
  end

  # ==========================================
  # STATISTICS - Estatísticas Globais
  # ==========================================

  get '/api/statistics/global' do
    stats = @db.get_global_stats
    { success: true, statistics: stats }.to_json
  end

  # ==========================================
  # ACHIEVEMENTS
  # ==========================================

  post '/api/achievements/add' do
    data = JSON.parse(request.body.read)

    @db.add_achievement(
      data['player_id'],
      data['achievement_name'],
      data['description']
    )

    { success: true, message: 'Achievement adicionado' }.to_json
  end

  # ==========================================
  # GDPR - Compliance
  # ==========================================

  get '/api/players/:player_id/export' do
    player_id = params[:player_id]
    data = @db.export_player_data(player_id)

    {
      success: true,
      data:
    }.to_json
  end

  delete '/api/players/:player_id' do
    player_id = params[:player_id]
    @db.delete_player_data(player_id)

    { success: true, message: 'Dados do jogador removidos' }.to_json
  end

  # ==========================================
  # ERROR HANDLING
  # ==========================================

  not_found do
    status 404
    { success: false, message: 'Endpoint não encontrado' }.to_json
  end

  error do
    status 500
    { success: false, message: 'Erro interno do servidor' }.to_json
  end

  private

  def save_game_session(game_data, game)
    player_id = game_data[:player_id]
    return unless player_id

    @db.save_game_session(player_id, {
      game_type: 'forca',
      difficulty: game_data[:difficulty],
      word: game_data[:word],
      guessed_letters: game.guessed_letters,
      wrong_letters: game.wrong_letters,
      score: game.game_progress[:combo] * 100,
      combo: game.game_progress[:combo],
      accuracy: game.game_progress[:accuracy],
      time_taken: (Time.now - Time.parse(game_data[:started_at])).round,
      won: game.won?
    })
  end
end

# Inicia o servidor
if __FILE__ == $0
  BuuroGameServer.run!(
    host: '0.0.0.0',
    port: ENV['PORT'] || 4567,
    environment: ENV['RACK_ENV'] || :development
  )
end
