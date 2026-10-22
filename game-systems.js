/**
 * GameScore - Sistema de pontuação com combo e multiplicadores
 */
class GameScore {
    constructor(config = {}) {
        this.points = 0;
        this.combo = 0;
        this.maxCombo = 0;
        this.correctLetters = 0;
        this.totalLetters = 0;
        this.gameTime = 0;
        
        // Configuração
        this.basePoints = config.basePoints || 100;
        this.comboMultiplier = config.comboMultiplier || 1.25;
        this.comboThreshold = config.comboThreshold || 3;
        this.timeBonusSeconds = config.timeBonusSeconds || 10;
        this.perfectWordBonus = config.perfectWordBonus || 500;
        this.difficultyMultiplier = config.difficultyMultiplier || 1.0;
    }

    /**
     * Registra um acerto
     */
    addCorrect(isWord = false) {
        this.correctLetters++;
        this.combo++;
        
        // Calcula pontos com multiplicador de combo
        let points = this.basePoints;
        if (this.combo >= this.comboThreshold) {
            points *= Math.pow(this.comboMultiplier, Math.floor(this.combo / this.comboThreshold));
        }
        
        points *= this.difficultyMultiplier;
        
        if (isWord) {
            points += this.perfectWordBonus;
        }
        
        this.points += Math.round(points);
        this.updateMaxCombo();
        
        return {
            points: Math.round(points),
            combo: this.combo,
            totalPoints: this.points,
            comboMilestone: this.getComboMilestone()
        };
    }

    /**
     * Registra um erro (quebra combo)
     */
    addError() {
        this.combo = 0;
        return {
            combo: 0,
            totalPoints: this.points
        };
    }

    /**
     * Atualiza combo máximo
     */
    updateMaxCombo() {
        this.maxCombo = Math.max(this.maxCombo, this.combo);
    }

    /**
     * Retorna se houve um marco de combo (x2, x3, x5, etc)
     */
    getComboMilestone() {
        if (this.combo % 10 === 0 && this.combo > 0) return 'milestone_x10';
        if (this.combo % 5 === 0 && this.combo > 0) return 'milestone_x5';
        if (this.combo === 3) return 'milestone_x3';
        if (this.combo === 2) return 'milestone_x2';
        return null;
    }

    /**
     * Adiciona bônus de tempo
     */
    addTimeBonus(seconds) {
        const bonus = Math.max(0, Math.floor(seconds / this.timeBonusSeconds) * 50);
        this.points += bonus;
        return bonus;
    }

    /**
     * Reseta o score
     */
    reset() {
        this.points = 0;
        this.combo = 0;
        this.maxCombo = 0;
        this.correctLetters = 0;
        this.gameTime = 0;
    }

    /**
     * Retorna resumo do score
     */
    getSummary() {
        return {
            totalPoints: this.points,
            combo: this.combo,
            maxCombo: this.maxCombo,
            correctLetters: this.correctLetters,
            gameTime: this.gameTime
        };
    }

    /**
     * Define multiplicador de dificuldade
     */
    setDifficultyMultiplier(difficulty) {
        const multipliers = {
            facil: 1.0,
            normal: 1.5,
            dificil: 2.5
        };
        this.difficultyMultiplier = multipliers[difficulty] || 1.0;
    }
}

/**
 * DifficultyManager - Gerencia níveis de dificuldade
 */
class DifficultyManager {
    constructor(config = {}) {
        this.levels = {
            facil: {
                name: 'Fácil',
                lives: config.facil?.lives || 8,
                scoreMultiplier: config.facil?.scoreMultiplier || 1.0,
                hintMultiplier: config.facil?.hintMultiplier || 1.5,
                color: '#2ecc71'
            },
            normal: {
                name: 'Normal',
                lives: config.normal?.lives || 6,
                scoreMultiplier: config.normal?.scoreMultiplier || 1.5,
                hintMultiplier: config.normal?.hintMultiplier || 1.0,
                color: '#f39c12'
            },
            dificil: {
                name: 'Difícil',
                lives: config.dificil?.lives || 4,
                scoreMultiplier: config.dificil?.scoreMultiplier || 2.5,
                hintMultiplier: config.dificil?.hintMultiplier || 0.5,
                color: '#e74c3c'
            }
        };
        this.current = 'normal';
    }

    /**
     * Define a dificuldade atual
     */
    setDifficulty(level) {
        if (this.levels[level]) {
            this.current = level;
            return true;
        }
        return false;
    }

    /**
     * Retorna configuração da dificuldade atual
     */
    getCurrentSettings() {
        return this.levels[this.current];
    }

    /**
     * Retorna todas as dificuldades
     */
    getAllLevels() {
        return Object.entries(this.levels).map(([key, value]) => ({
            id: key,
            ...value
        }));
    }

    /**
     * Obtém cor associada a uma dificuldade
     */
    getColor(difficulty = null) {
        const level = difficulty || this.current;
        return this.levels[level]?.color || '#ffffff';
    }
}

/**
 * FloatingTextManager - Gerencia efeitos de texto flutuante
 */
class FloatingTextManager {
    constructor(container) {
        this.container = container;
        this.texts = [];
    }

    /**
     * Cria um texto flutuante
     */
    create(text, x = 0, y = 0, options = {}) {
        const defaultOptions = {
            duration: 1500,
            fontSize: '1.5rem',
            color: '#fff',
            distance: 60,
            fontWeight: 'bold',
            className: 'floating-text'
        };

        const opts = { ...defaultOptions, ...options };

        const element = document.createElement('div');
        element.className = opts.className;
        element.innerText = text;
        element.style.cssText = `
            position: fixed;
            left: ${x}px;
            top: ${y}px;
            font-size: ${opts.fontSize};
            color: ${opts.color};
            font-weight: ${opts.fontWeight};
            pointer-events: none;
            z-index: 1000;
            opacity: 1;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        `;

        this.container?.appendChild(element);

        // Animação de flutuação
        const startTime = Date.now();
        const animate = () => {
            const elapsed = Date.now() - startTime;
            const progress = elapsed / opts.duration;

            if (progress >= 1) {
                element.remove();
                return;
            }

            element.style.transform = `translateY(-${opts.distance * progress}px)`;
            element.style.opacity = 1 - progress;

            requestAnimationFrame(animate);
        };

        animate();

        this.texts.push({ element, timestamp: Date.now() });
    }

    /**
     * Cria texto de pontuação
     */
    showPoints(points, x, y) {
        this.create(`+${points}`, x, y, {
            fontSize: '1.8rem',
            color: '#2ecc71',
            duration: 1200,
            className: 'floating-points'
        });
    }

    /**
     * Cria texto de combo
     */
    showCombo(combo, x, y) {
        const text = combo >= 10 ? `🔥 ${combo}x COMBO!` : `COMBO x${combo}`;
        this.create(text, x, y, {
            fontSize: `${1.2 + combo * 0.05}rem`,
            color: '#ff6b6b',
            duration: 800,
            className: 'floating-combo'
        });
    }

    /**
     * Cria texto de milestone
     */
    showMilestone(text, x, y) {
        this.create(text, x, y, {
            fontSize: '2rem',
            color: '#ffd700',
            duration: 1500,
            className: 'floating-milestone'
        });
    }

    clear() {
        this.texts.forEach(({ element }) => element.remove());
        this.texts = [];
    }
}

/**
 * NotificationManager - Gerencia notificações na tela
 */
class NotificationManager {
    constructor(container) {
        this.container = container;
        this.queue = [];
        this.isShowing = false;
    }

    /**
     * Mostra uma notificação
     */
    show(message, type = 'info', duration = 2000) {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.innerText = message;
        notification.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            padding: 15px 20px;
            background: ${this.getColor(type)};
            color: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            font-weight: bold;
            z-index: 2000;
            animation: slideIn 0.3s ease-out;
        `;

        this.container?.appendChild(notification);

        setTimeout(() => {
            notification.style.animation = 'slideOut 0.3s ease-in';
            setTimeout(() => notification.remove(), 300);
        }, duration);
    }

    getColor(type) {
        const colors = {
            success: '#2ecc71',
            error: '#e74c3c',
            warning: '#f39c12',
            info: '#3498db',
            combo: '#ff6b6b'
        };
        return colors[type] || colors.info;
    }

    showCombo(combo) {
        if (combo % 5 === 0 && combo > 0) {
            this.show(`🔥 Combo x${combo}!`, 'combo', 1500);
        }
    }

    showMilestone(text) {
        this.show(`⭐ ${text}`, 'success', 2500);
    }
}

/**
 * StatsTracker - Rastreia estatísticas do jogo
 */
class StatsTracker {
    constructor() {
        this.gamesPlayed = 0;
        this.gamesWon = 0;
        this.totalScore = 0;
        this.bestScore = 0;
        this.longestCombo = 0;
        this.totalLettersGuessed = 0;
        this.totalLettersCorrect = 0;
    }

    /**
     * Registra uma partida
     */
    recordGame(won, score, combo, lettersCorrect, totalLetters) {
        this.gamesPlayed++;
        if (won) this.gamesWon++;
        
        this.totalScore += score;
        this.bestScore = Math.max(this.bestScore, score);
        this.longestCombo = Math.max(this.longestCombo, combo);
        this.totalLettersCorrect += lettersCorrect;
        this.totalLettersGuessed += totalLetters;
    }

    /**
     * Retorna taxa de acerto
     */
    getAccuracy() {
        if (this.totalLettersGuessed === 0) return 0;
        return Math.round((this.totalLettersCorrect / this.totalLettersGuessed) * 100);
    }

    /**
     * Retorna taxa de vitória
     */
    getWinRate() {
        if (this.gamesPlayed === 0) return 0;
        return Math.round((this.gamesWon / this.gamesPlayed) * 100);
    }

    /**
     * Retorna resumo de estatísticas
     */
    getSummary() {
        return {
            gamesPlayed: this.gamesPlayed,
            gamesWon: this.gamesWon,
            totalScore: this.totalScore,
            averageScore: this.gamesPlayed > 0 ? Math.round(this.totalScore / this.gamesPlayed) : 0,
            bestScore: this.bestScore,
            longestCombo: this.longestCombo,
            accuracy: this.getAccuracy(),
            winRate: this.getWinRate()
        };
    }

    /**
     * Salva estatísticas em localStorage
     */
    save() {
        localStorage.setItem('gameStats', JSON.stringify({
            gamesPlayed: this.gamesPlayed,
            gamesWon: this.gamesWon,
            totalScore: this.totalScore,
            bestScore: this.bestScore,
            longestCombo: this.longestCombo,
            totalLettersGuessed: this.totalLettersGuessed,
            totalLettersCorrect: this.totalLettersCorrect
        }));
    }

    /**
     * Carrega estatísticas de localStorage
     */
    load() {
        try {
            const data = JSON.parse(localStorage.getItem('gameStats'));
            if (data) {
                this.gamesPlayed = data.gamesPlayed;
                this.gamesWon = data.gamesWon;
                this.totalScore = data.totalScore;
                this.bestScore = data.bestScore;
                this.longestCombo = data.longestCombo;
                this.totalLettersGuessed = data.totalLettersGuessed;
                this.totalLettersCorrect = data.totalLettersCorrect;
            }
        } catch (e) {
            console.warn('Erro ao carregar estatísticas:', e);
        }
    }
}

// Exportar classes
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        GameScore,
        DifficultyManager,
        FloatingTextManager,
        NotificationManager,
        StatsTracker
    };
}
