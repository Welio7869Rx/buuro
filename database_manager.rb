# frozen_string_literal: true

require 'sqlite3'
require 'json'

##
# DatabaseManager - Gerenciador de banco de dados SQLite
# Persiste dados de jogos, estatísticas e usuários
#
class DatabaseManager
  DB_PATH = './buuro_games.db'

  def initialize
    @db = SQLite3::Database.new DB_PATH
    @db.results_as_hash = true
    @db.execute 'PRAGMA journal_mode = WAL'
    create_tables
  end

  ##
  # Cria tabelas do banco de dados
  #
  def create_tables
    @db.execute_batch <<-SQL
      CREATE TABLE IF NOT EXISTS players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS game_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_id INTEGER,
        game_type TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        word TEXT NOT NULL,
        word_category TEXT,
        guessed_letters TEXT,
        wrong_letters TEXT,
        final_score INTEGER,
        combo_streak INTEGER,
        accuracy REAL,
        time_taken INTEGER,
        won BOOLEAN,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (player_id) REFERENCES players(id)
      );

      CREATE TABLE IF NOT EXISTS achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_id INTEGER,
        achievement_name TEXT NOT NULL,
        description TEXT,
        earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (player_id) REFERENCES players(id)
      );

      CREATE TABLE IF NOT EXISTS leaderboard (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player_id INTEGER,
        score INTEGER,
        games_played INTEGER,
        win_rate REAL,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (player_id) REFERENCES players(id)
      );

      CREATE TABLE IF NOT EXISTS word_bank (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT UNIQUE NOT NULL,
        category TEXT,
        difficulty TEXT,
        hint TEXT,
        language TEXT DEFAULT 'PT-BR',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    SQL
  end

  ##
  # Cria ou retorna um jogador
  #
  def create_or_get_player(username, email = nil)
    existing = @db.execute(
      'SELECT * FROM players WHERE username = ?',
      [username]
    ).first

    return existing if existing

    @db.execute(
      'INSERT INTO players (username, email) VALUES (?, ?)',
      [username, email]
    )

    @db.execute('SELECT * FROM players WHERE username = ?', [username]).first
  end

  ##
  # Salva uma sessão de jogo
  #
  def save_game_session(player_id, game_data)
    @db.execute(
      <<-SQL,
        INSERT INTO game_sessions (
          player_id, game_type, difficulty, word, word_category,
          guessed_letters, wrong_letters, final_score, combo_streak,
          accuracy, time_taken, won
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      SQL
      [
        player_id,
        game_data[:game_type],
        game_data[:difficulty],
        game_data[:word],
        game_data[:category],
        game_data[:guessed_letters].to_json,
        game_data[:wrong_letters].to_json,
        game_data[:score],
        game_data[:combo],
        game_data[:accuracy],
        game_data[:time_taken],
        game_data[:won]
      ]
    )

    update_leaderboard(player_id)
  end

  ##
  # Carrega histórico de jogos de um jogador
  #
  def get_player_history(player_id, limit: 20)
    @db.execute(
      'SELECT * FROM game_sessions WHERE player_id = ? ORDER BY created_at DESC LIMIT ?',
      [player_id, limit]
    ).map do |session|
      session.merge(
        guessed_letters: JSON.parse(session['guessed_letters']),
        wrong_letters: JSON.parse(session['wrong_letters'])
      )
    end
  end

  ##
  # Obtém estatísticas de um jogador
  #
  def get_player_stats(player_id)
    sessions = @db.execute(
      'SELECT * FROM game_sessions WHERE player_id = ?',
      [player_id]
    )

    return empty_stats if sessions.empty?

    total_games = sessions.length
    wins = sessions.count { |s| s['won'] }
    total_score = sessions.sum { |s| s['final_score'] || 0 }
    avg_accuracy = (sessions.sum { |s| s['accuracy'] || 0 } / total_games).round(2)
    best_score = sessions.max_by { |s| s['final_score'] || 0 }['final_score']
    longest_combo = sessions.max_by { |s| s['combo_streak'] || 0 }['combo_streak']

    {
      total_games:,
      wins:,
      win_rate: ((wins.to_f / total_games) * 100).round(2),
      total_score:,
      average_score: (total_score / total_games).round,
      best_score:,
      longest_combo:,
      average_accuracy: avg_accuracy
    }
  end

  ##
  # Atualiza leaderboard
  #
  def update_leaderboard(player_id)
    stats = get_player_stats(player_id)

    existing = @db.execute(
      'SELECT * FROM leaderboard WHERE player_id = ?',
      [player_id]
    ).first

    if existing
      @db.execute(
        'UPDATE leaderboard SET score = ?, games_played = ?, win_rate = ? WHERE player_id = ?',
        [stats[:total_score], stats[:total_games], stats[:win_rate], player_id]
      )
    else
      @db.execute(
        'INSERT INTO leaderboard (player_id, score, games_played, win_rate) VALUES (?, ?, ?, ?)',
        [player_id, stats[:total_score], stats[:total_games], stats[:win_rate]]
      )
    end
  end

  ##
  # Obtém top players do leaderboard
  #
  def get_leaderboard(limit: 100)
    @db.execute(
      <<-SQL,
        SELECT p.username, l.score, l.games_played, l.win_rate, l.updated_at
        FROM leaderboard l
        JOIN players p ON l.player_id = p.id
        ORDER BY l.score DESC
        LIMIT ?
      SQL
      [limit]
    )
  end

  ##
  # Adiciona achievement
  #
  def add_achievement(player_id, achievement_name, description = '')
    existing = @db.execute(
      'SELECT * FROM achievements WHERE player_id = ? AND achievement_name = ?',
      [player_id, achievement_name]
    ).first

    return if existing

    @db.execute(
      'INSERT INTO achievements (player_id, achievement_name, description) VALUES (?, ?, ?)',
      [player_id, achievement_name, description]
    )
  end

  ##
  # Adiciona palavras ao banco de dados
  #
  def add_word(word, category, difficulty, hint, language = 'PT-BR')
    @db.execute(
      'INSERT OR IGNORE INTO word_bank (word, category, difficulty, hint, language) VALUES (?, ?, ?, ?, ?)',
      [word.upcase, category, difficulty, hint, language]
    )
  end

  ##
  # Busca palavras por dificuldade
  #
  def get_words_by_difficulty(difficulty, limit: 100)
    @db.execute(
      'SELECT * FROM word_bank WHERE difficulty = ? ORDER BY RANDOM() LIMIT ?',
      [difficulty, limit]
    ).map { |row| row.transform_keys(&:to_sym) }
  end

  ##
  # Busca uma palavra aleatória
  #
  def get_random_word(difficulty)
    result = @db.execute(
      'SELECT * FROM word_bank WHERE difficulty = ? ORDER BY RANDOM() LIMIT 1',
      [difficulty]
    ).first

    result&.transform_keys(&:to_sym)
  end

  ##
  # Exporta dados de um jogador (GDPR)
  #
  def export_player_data(player_id)
    player = @db.execute('SELECT * FROM players WHERE id = ?', [player_id]).first
    sessions = get_player_history(player_id, limit: 1000)
    achievements = @db.execute(
      'SELECT * FROM achievements WHERE player_id = ?',
      [player_id]
    )
    stats = get_player_stats(player_id)

    {
      player: player.transform_keys(&:to_sym),
      statistics: stats,
      sessions:,
      achievements:,
      exported_at: Time.now.iso8601
    }
  end

  ##
  # Deleta dados de um jogador (GDPR right to be forgotten)
  #
  def delete_player_data(player_id)
    @db.execute('DELETE FROM achievements WHERE player_id = ?', [player_id])
    @db.execute('DELETE FROM leaderboard WHERE player_id = ?', [player_id])
    @db.execute('DELETE FROM game_sessions WHERE player_id = ?', [player_id])
    @db.execute('DELETE FROM players WHERE id = ?', [player_id])
  end

  ##
  # Obtém estatísticas globais
  #
  def get_global_stats
    {
      total_players: @db.execute('SELECT COUNT(*) as count FROM players').first['count'],
      total_games: @db.execute('SELECT COUNT(*) as count FROM game_sessions').first['count'],
      total_words: @db.execute('SELECT COUNT(*) as count FROM word_bank').first['count'],
      average_score: @db.execute(
        'SELECT AVG(final_score) as avg FROM game_sessions'
      ).first['avg']&.round || 0
    }
  end

  private

  def empty_stats
    {
      total_games: 0,
      wins: 0,
      win_rate: 0,
      total_score: 0,
      average_score: 0,
      best_score: 0,
      longest_combo: 0,
      average_accuracy: 0
    }
  end
end
