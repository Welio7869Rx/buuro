// Estado do Jogo (Configurado conforme o dicionário Python)
let tabuleiro = {'7': ' ', '8': ' ', '9': ' ', '4': ' ', '5': ' ', '6': ' ', '1': ' ', '2': ' ', '3': ' '};
let turno = "X";
let jogoAtivo = true;

// Estado das Pontuações
let vitoriasX = 0;
let vitoriasO = 0;
let empates = 0;

// Elementos da Interface DOM
const statusTexto = document.getElementById('status');
const celulas = document.querySelectorAll('.celula');
const elTabuleiro = document.getElementById('tabuleiro');
const modal = document.getElementById('tutorialModal');
const btnReiniciar = document.getElementById('btnReiniciar');
const btnResetPlacar = document.getElementById('btnResetPlacar');
const btnAbrirTutorial = document.getElementById('btnAbrirTutorial');
const btnFecharTutorial = document.getElementById('btnFecharTutorial');
const seletorModo = document.getElementById('modoJogo');
const btnMusica = document.getElementById('btnMusica');
const musicaFundo = document.getElementById('musicaFundo');

musicaFundo.volume = 0.35;

function atualizarBotaoMusica() {
    const tocando = !musicaFundo.paused;
    btnMusica.textContent = tocando ? 'Pausar música' : 'Ativar música';
    btnMusica.setAttribute('aria-pressed', String(tocando));
}

btnMusica.addEventListener('click', () => {
    if (musicaFundo.paused) {
        musicaFundo.play().then(atualizarBotaoMusica).catch(() => {
            if (musicaFundo.error) {
                btnMusica.textContent = 'Música indisponível';
                btnMusica.setAttribute('aria-pressed', 'false');
            } else {
                atualizarBotaoMusica();
            }
        });
    } else {
        musicaFundo.pause();
        atualizarBotaoMusica();
    }
});

musicaFundo.addEventListener('play', atualizarBotaoMusica);
musicaFundo.addEventListener('pause', atualizarBotaoMusica);

const elPlacarX = document.getElementById('placarX');
const elPlacarO = document.getElementById('placarO');
const elPlacarEmpates = document.getElementById('placarEmpates');

// Combinações de linhas vencedoras
const condicoesVitoria = [
    ['7', '4', '1'], ['8', '5', '2'], ['9', '6', '3'], // Verticais
    ['7', '8', '9'], ['4', '5', '6'], ['1', '2', '3'], // Horizontais
    ['7', '5', '3'], ['1', '5', '9']                  // Diagonais
];

// Sintetizador de Áudio Nativo via Web Audio API
function tocarSom(tipo) {
    const ctx = new (window.AudioContext || window.webkitAudioContext)();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);

    if (tipo === 'clique') {
        osc.frequency.setValueAtTime(turno === 'X' ? 440 : 520, ctx.currentTime);
        gain.gain.setValueAtTime(0.08, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.1);
        osc.start(); osc.stop(ctx.currentTime + 0.1);
    } else if (tipo === 'vitoria') {
        osc.frequency.setValueAtTime(300, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(600, ctx.currentTime + 0.3);
        gain.gain.setValueAtTime(0.08, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.4);
        osc.start(); osc.stop(ctx.currentTime + 0.4);
    } else if (tipo === 'empate') {
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(150, ctx.currentTime);
        gain.gain.setValueAtTime(0.08, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.3);
        osc.start(); osc.stop(ctx.currentTime + 0.3);
    }
}

// Eventos Relacionados ao Modal do Tutorial
btnAbrirTutorial.addEventListener('click', () => modal.classList.add('ativo'));
btnFecharTutorial.addEventListener('click', () => modal.classList.remove('ativo'));

// Mudar de modo redefine a partida em andamento
seletorModo.addEventListener('change', reiniciarRodada);

// Escuta cliques nas divisões do tabuleiro
celulas.forEach(celula => {
    celula.addEventListener('click', () => {
        const id = celula.getAttribute('data-celula');
        
        // Proteções contra cliques inválidos ou rodadas do Bot
        if (tabuleiro[id] !== " " || !jogoAtivo || (seletorModo.value === 'bot' && turno === 'O')) return;

        processarJogada(id);
    });
});

function processarJogada(id) {
    tocarSom('clique');
    tabuleiro[id] = turno;

    const celula = document.querySelector(`[data-celula="${id}"]`);
    celula.textContent = turno;
    celula.classList.add(turno);
    
    if (verificarResultado()) return;

    // Troca de Turno
    turno = turno === "X" ? "O" : "X";
    statusTexto.textContent = `Turno do ${turno}`;

    // Aciona a IA caso esteja no modo Bot
    if (seletorModo.value === 'bot' && turno === 'O' && jogoAtivo) {
        setTimeout(jogadaDoBot, 500); // Latência artificial p/ emular pensamento
    }
}

// Inteligência Artificial do Robô (O)
function jogadaDoBot() {
    let jogada = encontrarMelhorMovimento('O'); // 1ª Opção: Tentar ganhar
    
    if (!jogada) {
        jogada = encontrarMelhorMovimento('X'); // 2ª Opção: Bloquear sua linha
    }
    if (!jogada && tabuleiro['5'] === ' ') {
        jogada = '5'; // 3ª Opção: Tomar o centro se estiver vazio
    }
    if (!jogada) {
        // 4ª Opção: Pegar um espaço aleatório restante
        const vazias = Object.keys(tabuleiro).filter(chave => tabuleiro[chave] === ' ');
        jogada = vazias[Math.floor(Math.random() * vazias.length)];
    }

    if (jogada) {
        processarJogada(jogada);
    }
}

// Analisador preditivo para os movimentos da I.A.
function encontrarMelhorMovimento(jogador) {
    for (let condicao of condicoesVitoria) {
        const valores = condicao.map(pos => tabuleiro[pos]);
        const contagemJogador = valores.filter(v => v === jogador).length;
        const contagemEspaco = valores.filter(v => v === ' ').length;

        // Se houver dois preenchidos e uma lacuna, identifica o gatilho
        if (contagemJogador === 2 && contagemEspaco === 1) {
            return condicao.find(pos => tabuleiro[pos] === ' ');
        }
    }
    return null;
}

// Validador de Resultados das Rodadas
function verificarResultado() {
    let vencedor = null;
    let combinacaoVencedora = [];

    for (let condicao of condicoesVitoria) {
        const [a, b, c] = condicao;
        if (tabuleiro[a] === tabuleiro[b] && tabuleiro[b] === tabuleiro[c] && tabuleiro[a] !== ' ') {
            vencedor = tabuleiro[a];
            combinacaoVencedora = condicao;
            break;
        }
    }

    const espacosVazios = Object.values(tabuleiro).filter(v => v === ' ').length;

    if (vencedor) {
        tocarSom('vitoria');
        statusTexto.textContent = `${vencedor} é o vencedor!!!`;
        statusTexto.style.color = vencedor === 'X' ? '#00adb5' : '#ff5722';
        jogoAtivo = false;

        if (vencedor === 'X') {
            vitoriasX++;
            elPlacarX.textContent = vitoriasX;
            GameScoreCounter.add('velha', 100);
        } else {
            vitoriasO++;
            elPlacarO.textContent = vitoriasO;
            if (seletorModo.value === 'humano') GameScoreCounter.add('velha', 100);
        }

        celulas.forEach(celula => {
            if (combinacaoVencedora.includes(celula.getAttribute('data-celula'))) {
                celula.classList.add('animar-vitoria');
            }
        });
        return true;
    } 
    
    if (espacosVazios === 0) {
        tocarSom('empate');
        statusTexto.textContent = "EMPATE!!!";
        statusTexto.style.color = "#ffffff";
        jogoAtivo = false;
        
        empates++;
        elPlacarEmpates.textContent = empates;
        GameScoreCounter.add('velha', 25);
        elTabuleiro.classList.add('animar-empate');
        return true;
    }
    return false;
}

// Reseta o painel de jogo para uma nova partida mantendo pontuações
function reiniciarRodada() {
    tabuleiro = {'7': ' ', '8': ' ', '9': ' ', '4': ' ', '5': ' ', '6': ' ', '1': ' ', '2': ' ', '3': ' '};
    turno = "X";
    jogoAtivo = true;
    statusTexto.textContent = "Turno do X";
    statusTexto.style.color = "#ffffff";
    elTabuleiro.classList.remove('animar-empate');
    
    celulas.forEach(celula => {
        celula.textContent = "";
        celula.classList.remove('X', 'O', 'animar-vitoria');
    });
}

// Zera completamente o histórico do painel de pontos
function zerarPlacar() {
    vitoriasX = 0;
    vitoriasO = 0;
    empates = 0;
    elPlacarX.textContent = "0";
    elPlacarO.textContent = "0";
    elPlacarEmpates.textContent = "0";
    GameScoreCounter.reset('velha');
    reiniciarRodada();
}

btnReiniciar.addEventListener('click', reiniciarRodada);
btnResetPlacar.addEventListener('click', zerarPlacar);
