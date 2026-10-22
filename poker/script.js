// Configurações e Mapeamentos Globais
const SUITS = { '♠': 'black', '♥': 'red', '♦': 'red', '♣': 'black' };
const VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
const VALUE_MAP = { '2':2, '3':3, '4':4, '5':5, '6':6, '7':7, '8':8, '9':9, '10':10, 'J':11, 'Q':12, 'K':13, 'A':14 };

const HAND_RANKS = {
    ROYAL_FLUSH: 9, STRAIGHT_FLUSH: 8, FOUR_OF_A_KIND: 7, FULL_HOUSE: 6,
    FLUSH: 5, STRAIGHT: 4, THREE_OF_A_KIND: 3, TWO_PAIR: 2, PAIR: 1, HIGH_CARD: 0
};

class Card {
    constructor(value, suit) {
        this.value = value;
        this.suit = suit;
        this.weight = VALUE_MAP[value];
    }
}

class Deck {
    constructor() {
        this.cards = [];
        for (let suit in SUITS) {
            for (let value of VALUES) {
                this.cards.push(new Card(value, suit));
            }
        }
        this.shuffle();
    }

    shuffle() {
        for (let i = this.cards.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [this.cards[i], this.cards[j]] = [this.cards[j], this.cards[i]];
        }
    }

    deal() { return this.cards.pop(); }
}

class PokerGame {
    constructor() {
        this.humanChips = 1000;
        this.botChips = 1000;
        this.initHand();
    }

    initHand() {
        this.deck = new Deck();
        this.pot = 0;
        this.currentBet = 0;
        this.communityCards = [];
        this.humanHand = [this.deck.deal(), this.deck.deal()];
        this.botHand = [this.deck.deal(), this.deck.deal()];
        this.stage = 'PRE-FLOP'; // Stages: PRE-FLOP, FLOP, TURN, RIVER, SHOWDOWN
        
        // Pequeno Blind compulsório para iniciar o pote
        this.collectBet('human', 10);
        this.collectBet('bot', 10);

        this.updateUI(true); // Oculta as cartas do bot inicialmente
        this.setStatus("Nova Rodada! Pre-Flop. Faça sua ação.");
        this.enableControls(true);
    }

    collectBet(player, amount) {
        if(player === 'human') {
            this.humanChips -= amount;
            this.pot += amount;
        } else {
            this.botChips -= amount;
            this.pot += amount;
        }
    }

    // --- CONTROLES DE JOGO ---
    fold() {
        this.setStatus("Você correu (Fold). O Bot venceu esta mão!");
        this.botChips += this.pot;
        this.endHand();
    }

    check() {
        this.setStatus("Você deu Check.");
        setTimeout(() => this.botTurn(), 800);
    }

    call() {
        const callAmount = this.currentBet; // Simplificado para rodadas equivalentes
        this.collectBet('human', callAmount);
        this.setStatus("Você deu Call.");
        setTimeout(() => this.botTurn(), 800);
    }

    raise() {
        const amount = parseInt(document.getElementById('raise-amount').value);
        if (amount > this.humanChips) return alert("Fichas insuficientes!");
        
        this.collectBet('human', amount);
        this.currentBet = amount;
        this.setStatus(`Você deu Raise para $${amount}`);
        setTimeout(() => this.botTurn(), 800);
    }

    // --- INTELIGÊNCIA ARTIFICIAL (BOT) ---
    botTurn() {
        if (this.stage === 'SHOWDOWN') return;

        // Lógica de decisão simples do Bot baseada na força das suas duas cartas
        const botStrength = this.botHand[0].weight + this.botHand[1].weight;

        if (this.currentBet > 0) {
            if (botStrength > 20) { // Mão forte
                this.collectBet('bot', this.currentBet);
                this.setStatus(`Bot pagou $${this.currentBet} e deu Raise de $20!`);
                this.collectBet('bot', 20);
                this.currentBet = 20;
            } else if (botStrength >= 12) { // Mão média
                this.collectBet('bot', this.currentBet);
                this.setStatus("Bot deu Call.");
                this.currentBet = 0;
                this.advanceStage();
            } else { // Mão fraca
                this.setStatus("Bot deu Fold! Você ganhou o pote.");
                this.humanChips += this.pot;
                this.endHand();
                return;
            }
        } else {
            // Se ninguém apostou, bot dá check ou aposta baixo
            if (botStrength > 22) {
                this.collectBet('bot', 30);
                this.currentBet = 30;
                this.setStatus("Bot apostou $30.");
            } else {
                this.setStatus("Bot deu Check.");
                this.advanceStage();
            }
        }
        this.updateUI(true);
    }

    // --- MÁQUINA DE ESTADOS DAS RODADAS ---
    advanceStage() {
        this.currentBet = 0;
        if (this.stage === 'PRE-FLOP') {
            this.stage = 'FLOP';
            this.communityCards.push(this.deck.deal(), this.deck.deal(), this.deck.deal());
            this.setStatus("Flop distribuído na mesa.");
        } else if (this.stage === 'TURN') {
            this.stage = 'RIVER';
            this.communityCards.push(this.deck.deal());
            this.setStatus("River na mesa! Última rodada de apostas.");
        } else if (this.stage === 'FLOP') {
            this.stage = 'TURN';
            this.communityCards.push(this.deck.deal());
            this.setStatus("Turn na mesa.");
        } else if (this.stage === 'RIVER') {
            this.stage = 'SHOWDOWN';
            this.evaluateWinner();
        }
        this.updateUI(this.stage !== 'SHOWDOWN');
    }

    endHand() {
        this.enableControls(false);
        setTimeout(() => this.initHand(), 4000);
    }

    // --- MOTOR AVALIADOR DE MÃOS (ALGORITMO AVANÇADO) ---
    evaluateWinner() {
        const humanScore = this.getBestHandScore(this.humanHand.concat(this.communityCards));
        const botScore = this.getBestHandScore(this.botHand.concat(this.communityCards));

        this.updateUI(false); // Mostra as cartas do bot no Showdown

        let resultText = `Showdown! Sua mão: ${humanScore.handName} vs Bot: ${botScore.handName}. `;

        if (humanScore.value > botScore.value) {
            resultText += "Você venceu o Pote!";
            this.humanChips += this.pot;
        } else if (botScore.value > humanScore.value) {
            resultText += "O Bot venceu o Pote.";
            this.botChips += this.pot;
        } else {
            resultText += "Empate! Pote dividido.";
            this.humanChips += this.pot / 2;
            this.botChips += this.pot / 2;
        }

        this.setStatus(resultText);
        this.endHand();
    }

    // Helper matemático para obter as combinações possíveis C(n, k)
    getCombinations(array, k) {
        let result = [];
        const combine = (current, start) => {
            if (current.length === k) {
                result.push([...current]);
                return;
            }
            for (let i = start; i < array.length; i++) {
                current.push(array[i]);
                combine(current, i + 1);
                current.pop();
            }
        };
        combine([], 0);
        return result;
    }

    // Retorna a melhor pontuação numérica de 5 cartas dentre as 7 disponíveis
    getBestHandScore(sevenCards) {
        const all5CardCombos = this.getCombinations(sevenCards, 5);
        let maxScore = -1;
        let bestHandName = "";

        for (let combo of all5CardCombos) {
            const score = this.rate5CardHand(combo);
            if (score.value > maxScore) {
                maxScore = score.value;
                bestHandName = score.handName;
            }
        }
        return { value: maxScore, handName: bestHandName };
    }

    rate5CardHand(fiveCards) {
        // Ordena por peso decrescente
        fiveCards.sort((a, b) => b.weight - a.weight);

        const weights = fiveCards.map(c => c.weight);
        const suits = fiveCards.map(c => c.suit);

        // Contadores de ocorrência
        const weightCounts = {};
        weights.forEach(w => weightCounts[w] = (weightCounts[w] || 0) + 1);
        const counts = Object.values(weightCounts).sort((a,b) => b - a);

        // Verificações estruturais
        const isFlush = suits.every(s => s === suits[0]);
        let isStraight = false;
        
        // Verifica sequência (Detecta também o Wheel Straight: A,2,3,4,5)
        const uniqueWeights = [...new Set(weights)];
        if (uniqueWeights.length === 5 && (weights[0] - weights[4] === 4)) {
            isStraight = true;
        } else if (uniqueWeights.length === 5 && weights[0] === 14 && weights[1] === 5 && weights[4] === 2) {
            isStraight = true; // Wheel straight (A vira peso 1)
        }

        // Sistema de desempate por pesos secundários (Tie-breaker base hexadecimal simbólico)
        const kickerScore = weights.reduce((acc, w, i) => acc + w * Math.pow(15, 4 - i), 0) / 100000;

        // Categorização baseada nas regras oficiais do Poker
        if (isFlush && isStraight && weights[0] === 14 && weights[1] === 13) 
            return { value: HAND_RANKS.ROYAL_FLUSH + kickerScore, handName: "Royal Flush" };
        if (isFlush && isStraight) 
            return { value: HAND_RANKS.STRAIGHT_FLUSH + kickerScore, handName: "Straight Flush" };
        if (counts[0] === 4) 
            return { value: HAND_RANKS.FOUR_OF_A_KIND + kickerScore, handName: "Quadra" };
        if (counts[0] === 3 && counts[1] === 2) 
            return { value: HAND_RANKS.FULL_HOUSE + kickerScore, handName: "Full House" };
        if (isFlush) 
            return { value: HAND_RANKS.FLUSH + kickerScore, handName: "Flush" };
        if (isStraight) 
            return { value: HAND_RANKS.STRAIGHT + kickerScore, handName: "Sequência" };
        if (counts[0] === 3) 
            return { value: HAND_RANKS.THREE_OF_A_KIND + kickerScore, handName: "Trinca" };
        if (counts[0] === 2 && counts[1] === 2) 
            return { value: HAND_RANKS.TWO_PAIR + kickerScore, handName: "Dois Pares" };
        if (counts[0] === 2) 
            return { value: HAND_RANKS.PAIR + kickerScore, handName: "Um Par" };

        return { value: HAND_RANKS.HIGH_CARD + kickerScore, handName: `Carta Alta (${fiveCards[0].value})` };
    }

    // --- INTERFACE DE RENDERIZAÇÃO (UI) ---
    renderCardDOM(card, hide) {
        if (hide) return `<div class="card back"></div>`;
        const colorClass = SUITS[card.suit];
        return `
            <div class="card ${colorClass}">
                <div>${card.value}</div>
                <div class="suit-center">${card.suit}</div>
                <div style="align-self: flex-end; transform: rotate(180deg);">${card.value}</div>
            </div>
        `;
    }

    updateUI(hideBot) {
        document.getElementById('human-chips').innerText = this.humanChips;
        document.getElementById('bot-chips').innerText = this.botChips;
        document.getElementById('pot-amount').innerText = this.pot;

        // Renderiza mão humana
        document.getElementById('human-cards').innerHTML = this.humanHand.map(c => this.renderCardDOM(c, false)).join('');

        // Renderiza mão do bot
        document.getElementById('bot-cards').innerHTML = this.botHand.map(c => this.renderCardDOM(c, hideBot)).join('');

        // Renderiza cartas comunitárias na mesa
        const slots = document.querySelectorAll('.card-slot');
        slots.forEach((slot, index) => {
            if (this.communityCards[index]) {
                slot.outerHTML = this.renderCardDOM(this.communityCards[index], false);
            }
        });
    }

    setStatus(text) { document.getElementById('game-status').innerText = text; }

    enableControls(enable) {
        document.getElementById('btn-fold').disabled = !enable;
        document.getElementById('btn-check').disabled = !enable;
        document.getElementById('btn-call').disabled = !enable;
        document.getElementById('btn-raise').disabled = !enable;
    }
}

// Inicialização Global do Jogo
const game = new PokerGame();