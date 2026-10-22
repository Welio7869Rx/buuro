// Configuração de Áudio com Web Audio API
class AudioEngine {
    constructor() {
        this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
    }

    static NOTAS = {
        C4: 261.63, D4: 293.66, E4: 329.63, F4: 349.23,
        G4: 391.99, A4: 440.00, B4: 493.88, C5: 523.25,
        D5: 587.33, E5: 659.25
    };

    async resume() {
        if (!this.audioContext) return false;
        if (this.audioContext.state === 'suspended') {
            try {
                await this.audioContext.resume();
            } catch (e) {
                console.warn('AudioContext resume rejeitado:', e);
                return false;
            }
        }
        return true;
    }

    tocar(frequencia, duracao) {
        const oscillator = this.audioContext.createOscillator();
        const gainNode = this.audioContext.createGain();

        oscillator.connect(gainNode);
        gainNode.connect(this.audioContext.destination);

        oscillator.frequency.value = frequencia;
        oscillator.type = 'sine';

        gainNode.gain.setValueAtTime(0.35, this.audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + duracao / 1000);

        oscillator.start(this.audioContext.currentTime);
        oscillator.stop(this.audioContext.currentTime + duracao / 1000);
    }

    async tocarSequencia(notas) {
        try {
            const ok = await this.resume();
            if (!ok) return; // não conseguiu ativar áudio
        } catch (e) {
            console.warn('Erro ao ativar áudio:', e);
            return;
        }
        for (const [freq, dur] of notas) {
            try {
                this.tocar(freq, dur);
            } catch (e) {
                console.warn('Erro ao tocar nota:', e);
            }
            await new Promise(r => setTimeout(r, dur + 60));
        }
    }

    efeitoInicio() {
        this.tocarSequencia([
            [AudioEngine.NOTAS.C4, 150],
            [AudioEngine.NOTAS.E4, 150],
            [AudioEngine.NOTAS.G4, 250]
        ]);
    }

    efeitoAcerto() {
        this.tocarSequencia([
            [AudioEngine.NOTAS.E4, 100],
            [AudioEngine.NOTAS.G4, 100],
            [AudioEngine.NOTAS.C5, 200]
        ]);
    }

    efeitoErro() {
        this.tocarSequencia([
            [AudioEngine.NOTAS.G4, 120],
            [AudioEngine.NOTAS.D4, 250],
            [AudioEngine.NOTAS.C4, 180]
        ]);
    }

    efeitoDica() {
        this.tocarSequencia([
            [AudioEngine.NOTAS.D4, 120],
            [AudioEngine.NOTAS.E4, 120],
            [AudioEngine.NOTAS.F4, 120]
        ]);
    }

    efeitoVitoria() {
        this.tocarSequencia([
            [AudioEngine.NOTAS.C4, 120],
            [AudioEngine.NOTAS.E4, 120],
            [AudioEngine.NOTAS.G4, 120],
            [AudioEngine.NOTAS.C5, 350],
            [AudioEngine.NOTAS.E5, 200]
        ]);
    }

    efeitoDerrota() {
        this.tocarSequencia([
            [AudioEngine.NOTAS.F4, 250],
            [AudioEngine.NOTAS.E4, 250],
            [AudioEngine.NOTAS.D4, 250],
            [AudioEngine.NOTAS.C4, 600]
        ]);
    }
}

let selectedWord = "";
let selectedHint = "";
let guessedLetters = [];
let wrongLetters = [];
let lives = 6;
let hintUsed = false;
let gameOver = false;

const words = [
    { word: 'JAVASCRIPT', hint: 'Linguagem de programação usada para criar sites interativos.' },
    { word: 'PYTHON', hint: 'Linguagem muito usada em ciência de dados e IA.' },
    { word: 'ALGORITMO', hint: 'Sequência de passos para resolver um problema.' },
    { word: 'PROGRAMA', hint: 'Conjunto de instruções executadas pelo computador.' },
    { word: 'VARIAVEL', hint: 'Espaço que guarda um valor no código.' },
    { word: 'FUNCAO', hint: 'Bloco de código que executa uma tarefa.' },
    { word: 'BIBLIOTECA', hint: 'Conjunto de código reutilizável.' },
    { word: 'FRAMEWORK', hint: 'Estrutura usada para facilitar o desenvolvimento.' },
    { word: 'HTML', hint: 'Linguagem de marcação de páginas da web.' },
    { word: 'CSS', hint: 'Linguagem para estilizar páginas web.' },
    { word: 'NAVEGADOR', hint: 'Programa para acessar sites.' },
    { word: 'COMPUTADOR', hint: 'Máquina eletrônica que processa dados.' },
    { word: 'TECLADO', hint: 'Dispositivo para digitar letras.' },
    { word: 'MONITOR', hint: 'Tela onde você vê o conteúdo do computador.' },
    { word: 'INTERNET', hint: 'Rede global que conecta computadores.' },
    { word: 'SERVIDOR', hint: 'Computador que fornece dados para outros.' },
    { word: 'DATABASE', hint: 'Local onde informações são armazenadas.' },
    { word: 'SEGURANCA', hint: 'Prática para proteger dados e usuários.' },
    { word: 'SOFTWARE', hint: 'Programa que roda no computador.' },
    { word: 'PROGRAMACAO', hint: 'A arte de escrever código.' }
];

const audio = new AudioEngine();
const wordDisplay = document.getElementById('word-display');
const keyboard = document.getElementById('keyboard');
const livesDisplay = document.getElementById('lives');
const message = document.getElementById('message');
const resetBtn = document.getElementById('reset-btn');
const hintBtn = document.getElementById('hint-btn');
const musicToggleBtn = document.getElementById('music-toggle');
const backgroundMusic = document.getElementById('background-music');

backgroundMusic.volume = 0.35;

function updateMusicToggle() {
    const isPlaying = !backgroundMusic.paused;
    musicToggleBtn.textContent = isPlaying ? 'Pausar música' : 'Ativar música';
    musicToggleBtn.setAttribute('aria-pressed', String(isPlaying));
}

musicToggleBtn.addEventListener('click', () => {
    if (backgroundMusic.paused) {
        backgroundMusic.play().then(updateMusicToggle).catch(() => {
            message.innerText = 'Não foi possível carregar a música.';
        });
    } else {
        backgroundMusic.pause();
        updateMusicToggle();
    }
});

backgroundMusic.addEventListener('play', updateMusicToggle);
backgroundMusic.addEventListener('pause', updateMusicToggle);

function chooseWord() {
    const choice = words[Math.floor(Math.random() * words.length)];
    selectedWord = choice.word.toUpperCase();
    selectedHint = choice.hint;
}

function createKeyboard() {
    keyboard.innerHTML = '';
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').forEach(letter => {
        const button = document.createElement('button');
        button.type = 'button';
        button.innerText = letter;
        button.addEventListener('click', () => handleGuess(letter, button));
        keyboard.appendChild(button);
    });
}

function getDisplayWord() {
    return selectedWord
        .split('')
        .map(letter => (guessedLetters.includes(letter) ? letter : '_'))
        .join(' ');
}

function updateUI() {
    wordDisplay.innerText = getDisplayWord();
    livesDisplay.innerText = lives;
    hintBtn.disabled = hintUsed || gameOver;

    if (gameOver) {
        disableButtons();
    }
}

function disableButtons() {
    keyboard.querySelectorAll('button').forEach(btn => btn.disabled = true);
}

function setButtonStyle(letter, correct) {
    const button = [...keyboard.children].find(btn => btn.innerText === letter);
    if (!button) return;
    button.disabled = true;
    button.classList.add(correct ? 'correct' : 'wrong');
}

function initGame() {
    guessedLetters = [];
    wrongLetters = [];
    lives = 6;
    hintUsed = false;
    gameOver = false;
    message.innerText = 'Adivinhe a palavra antes de ficar sem tentativas.';
    chooseWord();
    createKeyboard();
    updateUI();
    try { audio.efeitoInicio(); } catch (e) { console.warn('falha ao tocar início:', e); }
}

function completeWin() {
    if (gameOver) return;
    message.innerText = `🎉 Parabéns! Você venceu! A palavra era ${selectedWord}.`;
    gameOver = true;
    GameScoreCounter.add('forca', 100 + lives * 25);
    try { audio.efeitoVitoria(); } catch (e) { console.warn('efeitoVitoria falhou:', e); }
    updateUI();
}

function handleGuess(letter, button) {
    if (gameOver || button.disabled) return;

    if (selectedWord.includes(letter)) {
        guessedLetters.push(letter);
        setButtonStyle(letter, true);
        message.innerText = `Boa! A letra ${letter} está na palavra.`;
        try { audio.efeitoAcerto(); } catch (e) { console.warn('efeitoAcerto falhou:', e); }
    } else {
        wrongLetters.push(letter);
        lives -= 1;
        setButtonStyle(letter, false);
        message.innerText = `Ops! A letra ${letter} não faz parte da palavra.`;
        try { audio.efeitoErro(); } catch (e) { console.warn('efeitoErro falhou:', e); }
    }

    updateUI();

    if (!getDisplayWord().includes('_')) {
        completeWin();
    } else if (lives <= 0) {
        message.innerText = `👻 Game Over! A palavra era ${selectedWord}.`;
        gameOver = true;
        try { audio.efeitoDerrota(); } catch (e) { console.warn('efeitoDerrota falhou:', e); }
        disableButtons();
    }
}

function mostrarDica() {
    if (hintUsed || gameOver) return;
    const remaining = selectedWord.split('').filter(letter => !guessedLetters.includes(letter));
    if (remaining.length === 0) {
        message.innerText = 'Nenhuma letra restante para revelar.';
        return;
    }
    const letra = remaining[Math.floor(Math.random() * remaining.length)];
    guessedLetters.push(letra);
    hintUsed = true;
    message.innerText = `💡 Dica: a letra ${letra} foi revelada. ${selectedHint}`;
    try { audio.efeitoDica(); } catch (e) { console.warn('efeitoDica falhou:', e); }
    setButtonStyle(letra, true);
    updateUI();
    if (!getDisplayWord().includes('_')) {
        completeWin();
    }
}

resetBtn.addEventListener('click', initGame);
hintBtn.addEventListener('click', mostrarDica);

createKeyboard();
initGame();
