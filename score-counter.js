(() => {
    const storageKey = 'buuro-game-scores-v1';
    const fallbackScores = {};
    let useFallbackStorage = false;

    function readScores() {
        if (useFallbackStorage) return fallbackScores;
        try {
            const saved = JSON.parse(localStorage.getItem(storageKey) || '{}');
            return saved && typeof saved === 'object' ? saved : {};
        } catch (error) {
            useFallbackStorage = true;
            return fallbackScores;
        }
    }

    function render() {
        const scores = readScores();
        document.querySelectorAll('[data-score-total]').forEach((element) => {
            const game = element.dataset.scoreTotal;
            element.textContent = (Number(scores[game]) || 0).toLocaleString('pt-BR');
        });
        const grandTotal = Object.values(scores).reduce((total, points) => total + (Number(points) || 0), 0);
        document.querySelectorAll('[data-score-grand-total]').forEach((element) => {
            element.textContent = grandTotal.toLocaleString('pt-BR');
        });
    }

    window.GameScoreCounter = {
        add(game, points) {
            const amount = Math.max(0, Math.round(Number(points) || 0));
            if (!amount) return 0;

            const scores = readScores();
            scores[game] = (Number(scores[game]) || 0) + amount;
            try {
                localStorage.setItem(storageKey, JSON.stringify(scores));
            } catch (error) {
                Object.assign(fallbackScores, scores);
                useFallbackStorage = true;
            }
            render();
            return scores[game];
        },
        reset(game) {
            const scores = readScores();
            delete scores[game];
            try {
                localStorage.setItem(storageKey, JSON.stringify(scores));
            } catch (error) {
                Object.assign(fallbackScores, scores);
                delete fallbackScores[game];
                useFallbackStorage = true;
            }
            render();
        },
        render
    };

    window.addEventListener('storage', (event) => {
        if (event.key === storageKey || event.key === null) render();
    });

    render();
})();