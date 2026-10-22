/**
 * Sound Manager - Gerenciador centralizado de efeitos sonoros
 * Integra com config.json para reproduzir efeitos sonoros sintetizados
 */
class SoundManager {
    constructor(configUrl = 'config.json') {
        this.config = null;
        this.audioContext = null;
        this.backgroundInterval = null;
        this.soundEnabled = true;
        this.volume = 0.3;
        this.loadConfig(configUrl);
    }

    async loadConfig(url) {
        try {
            const response = await fetch(url);
            this.config = await response.json();
            this.volume = this.config.audio?.volume || 0.3;
            this.soundEnabled = this.config.audio?.enabled !== false;
        } catch (error) {
            console.warn('Falha ao carregar config:', error);
            this.config = { audio: { effects: {}, notes: {} } };
        }
    }

    async ensureAudioContext() {
        if (!this.audioContext) {
            try {
                this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
            } catch (e) {
                console.warn('AudioContext não suportado');
                return false;
            }
        }

        if (this.audioContext.state === 'suspended') {
            try {
                await this.audioContext.resume();
            } catch (e) {
                return false;
            }
        }
        return true;
    }

    /**
     * Toca uma nota individual com fade-out
     */
    playNote(frequency, duration) {
        if (!this.soundEnabled || !this.audioContext) return;

        const oscillator = this.audioContext.createOscillator();
        const gainNode = this.audioContext.createGain();

        oscillator.connect(gainNode);
        gainNode.connect(this.audioContext.destination);

        oscillator.frequency.value = frequency;
        oscillator.type = 'sine';

        const now = this.audioContext.currentTime;
        gainNode.gain.setValueAtTime(this.volume, now);
        gainNode.gain.exponentialRampToValueAtTime(0.01, now + duration / 1000);

        oscillator.start(now);
        oscillator.stop(now + duration / 1000);
    }

    /**
     * Toca uma sequência de notas a partir de um efeito definido em config.json
     */
    async playEffect(effectName) {
        if (!this.soundEnabled || !this.config) return;

        await this.ensureAudioContext();

        const effect = this.config.audio?.effects?.[effectName];
        if (!effect) return;

        for (const note of effect) {
            const frequency = this.getFrequency(note.frequency);
            if (frequency) {
                this.playNote(frequency, note.duration);
                await new Promise(r => setTimeout(r, note.duration + 30));
            }
        }
    }

    /**
     * Resolve uma frequência (pode ser número ou nome da nota)
     */
    getFrequency(freq) {
        if (typeof freq === 'number') {
            return freq;
        }
        return this.config.audio?.notes?.[freq] || 440;
    }

    /**
     * Métodos de conveniência para efeitos comuns
     */
    playStart() { this.playEffect('inicio'); }
    playCorrect() { this.playEffect('acerto'); }
    playIncorrect() { this.playEffect('erro'); }
    playHint() { this.playEffect('dica'); }
    playCombo() { this.playEffect('combo'); }
    playComboX2() { this.playEffect('comboX2'); }
    playComboX3() { this.playEffect('comboX3'); }
    playBonus() { this.playEffect('bonus'); }
    playLevelUp() { this.playEffect('levelUp'); }
    playWarning() { this.playEffect('aviso'); }
    playClick() { this.playEffect('click'); }
    playVictory() { this.playEffect('vitoria'); }
    playVictoryBig() { this.playEffect('vitoriaGrande'); }
    playDefeat() { this.playEffect('derrota'); }
    playBack() { this.playEffect('volta'); }
    playMenuOpen() { this.playEffect('menuAbrir'); }

    stopBackground() {
        if (this.backgroundInterval) {
            clearInterval(this.backgroundInterval);
            this.backgroundInterval = null;
        }
    }

    async playBackgroundMusic(difficulty = 'normal') {
        if (!this.soundEnabled) return;

        await this.ensureAudioContext();
        this.stopBackground();

        const themes = {
            facil: ['C4', 'E4', 'G4'],
            normal: ['D4', 'F4', 'A4'],
            dificil: ['E4', 'G4', 'B4']
        };

        const pattern = themes[difficulty] || themes.normal;
        let index = 0;

        this.backgroundInterval = setInterval(() => {
            const noteName = pattern[index % pattern.length];
            const frequency = this.getFrequency(noteName);
            this.playNote(frequency, 300);
            index++;
        }, 400);
    }

    toggleSound() {
        this.soundEnabled = !this.soundEnabled;
        return this.soundEnabled;
    }

    setVolume(vol) {
        this.volume = Math.max(0, Math.min(1, vol));
        if (this.audioContext) {
            const master = this.audioContext.createGain();
            master.gain.value = this.volume;
        }
    }
}

// Exportar para uso global
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SoundManager;
}
