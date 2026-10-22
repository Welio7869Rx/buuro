#include <algorithm>
#include <chrono>
#include <iostream>
#include <random>
#include <string>
#include <thread>
#include <vector>

struct Question {
    std::string category;
    std::string text;
    std::vector<std::string> options;
    int answer;
    std::string explanation;
};

struct Lifelines {
    bool fiftyFifty = true;
    bool audience = true;
    bool skip = true;
};

class QuizBilhao {
public:
    QuizBilhao()
        : engine(static_cast<unsigned int>(std::chrono::system_clock::now().time_since_epoch().count())),
          currentIndex(0),
          score(0),
          completed(false)
    {
        initializeQuestions();
        initializePrizes();
        shuffleQuestions();
    }

    void run() {
        printHeader();
        while (currentIndex < static_cast<int>(questions.size()) && !completed) {
            askQuestion();
        }

        if (score == static_cast<int>(questions.size())) {
            printVictory();
        } else {
            printSummary();
        }
    }

private:
    std::mt19937 engine;
    std::vector<Question> questions;
    std::vector<std::string> prizes;
    Lifelines lifelines;
    int currentIndex;
    int score;
    bool completed;

    void initializeQuestions() {
        questions = {
            {"Tecnologia", "Qual destes é o nome de uma linguagem de programação usada tanto no backend quanto no frontend?",
                {"Python", "C++", "JavaScript", "Swift"}, 2,
                "JavaScript é usada tanto no browser quanto em servidores via Node.js."},
            {"História", "Qual monumento histórico é conhecido como o símbolo de Paris?",
                {"Coliseu", "Torre Eiffel", "Big Ben", "Taj Mahal"}, 1,
                "A Torre Eiffel é um dos símbolos mais famosos de Paris."},
            {"Ciência", "Qual planeta é conhecido como o Planeta Vermelho?",
                {"Júpiter", "Saturno", "Marte", "Vênus"}, 2,
                "Marte é chamado de Planeta Vermelho pela sua aparência avermelhada."},
            {"Cultura", "Em qual país nasceu o samba?",
                {"Argentina", "Brasil", "Portugal", "Cuba"}, 1,
                "O samba nasceu no Brasil, com raízes africanas e brasileiras."},
            {"Geografia", "Qual é o maior oceano do mundo?",
                {"Atlântico", "Índico", "Ártico", "Pacífico"}, 3,
                "O Oceano Pacífico é o maior e mais profundo do planeta."},
            {"Cinema", "Qual desses filmes foi dirigido por Steven Spielberg?",
                {"E.T. - O Extraterrestre", "Pulp Fiction", "Gladiador", "Matrix"}, 0,
                "E.T. foi dirigido por Steven Spielberg e lançado em 1982."},
            {"Música", "Qual artista é conhecido como 'Rei do Pop'?",
                {"Elvis Presley", "Michael Jackson", "Freddie Mercury", "Bob Dylan"}, 1,
                "Michael Jackson é frequentemente chamado de Rei do Pop."},
            {"Esportes", "Em qual esporte se usa uma raquete e uma bola que quica na quadra?",
                {"Tênis", "Natação", "Voleibol", "Futebol"}, 0,
                "Tênis é um esporte de raquete e bola jogado em quadras."},
            {"Literatura", "Quem escreveu 'Dom Quixote'?",
                {"Miguel de Cervantes", "William Shakespeare", "Jorge Amado", "Gabriel García Márquez"}, 0,
                "Miguel de Cervantes escreveu o clássico 'Dom Quixote'."},
            {"Ciência", "Qual é a fórmula química da água?",
                {"H2O", "CO2", "O2", "NaCl"}, 0,
                "A água possui a fórmula H2O, dois átomos de hidrogênio e um de oxigênio."}
        };
    }

    void initializePrizes() {
        prizes = {
            "R$ 500",
            "R$ 1.000",
            "R$ 5.000",
            "R$ 10.000",
            "R$ 25.000",
            "R$ 50.000",
            "R$ 100.000",
            "R$ 200.000",
            "R$ 500.000",
            "R$ 1.000.000"
        };
    }

    void shuffleQuestions() {
        std::shuffle(questions.begin(), questions.end(), engine);
    }

    void printHeader() const {
        std::cout << "\n============================================\n";
        std::cout << "      QUIZ DO BILHÃO - EDIÇÃO C++\n";
        std::cout << "============================================\n";
        std::cout << "Bora para 10 perguntas com lifelines estratégicas!\n";
        std::cout << "Você terá 3 ajudas: 50/50, Pular e Ajuda da Plateia.\n";
        std::cout << "Acerte todas e conquiste R$ 1.000.000.\n\n";
        std::cout << "Pressione ENTER para começar...";
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
    }

    void askQuestion() {
        const Question& question = questions[currentIndex];
        std::vector<bool> optionVisible(question.options.size(), true);
        bool answered = false;

        while (!answered) {
            printQuestion(question, optionVisible);
            auto choice = promptChoice();

            if (choice == "L" || choice == "l") {
                if (!handleLifeline(question, optionVisible)) {
                    continue;
                }
                continue;
            }

            int answerIndex = parseAnswer(choice, optionVisible);
            if (answerIndex == -2) {
                completed = true;
                answered = true;
                break;
            }
            if (answerIndex < 0) {
                std::cout << "Entrada inválida. Tente novamente.\n";
                continue;
            }

            if (answerIndex == question.answer) {
                score += 1;
                std::cout << "\nResposta correta! Você ganhou " << prizes[currentIndex] << "!\n";
                currentIndex += 1;
                answered = true;
                if (currentIndex >= static_cast<int>(questions.size())) {
                    completed = true;
                }
            } else {
                std::cout << "\nResposta incorreta. A resposta certa era: " << question.options[question.answer] << "\n";
                std::cout << "Explicação: " << question.explanation << "\n";
                completed = true;
                answered = true;
            }
        }
    }

    void printQuestion(const Question& question, const std::vector<bool>& optionVisible) const {
        std::cout << "\n--------------------------------------------------\n";
        std::cout << "Pergunta " << (currentIndex + 1) << " / " << questions.size() << "  |  Valor: " << prizes[currentIndex] << "\n";
        std::cout << "Categoria: " << question.category << "\n";
        std::cout << "\n" << question.text << "\n\n";

        for (std::size_t i = 0; i < question.options.size(); ++i) {
            if (!optionVisible[i]) {
                std::cout << "  " << char('A' + static_cast<int>(i)) << ") -- oculto --\n";
            } else {
                std::cout << "  " << char('A' + static_cast<int>(i)) << ") " << question.options[i] << "\n";
            }
        }

        std::cout << "\n(Use A/B/C/D ou L para lifeline; Q para desistir)\n";
    }

    std::string promptChoice() const {
        std::string input;
        std::cout << "Sua resposta: ";
        std::getline(std::cin, input);
        return input;
    }

    int parseAnswer(const std::string& choice, const std::vector<bool>& optionVisible) const {
        if (choice.empty()) {
            return -1;
        }

        if (choice.size() == 1) {
            char c = std::toupper(choice[0]);
            if (c >= 'A' && c < 'A' + static_cast<int>(optionVisible.size())) {
                int index = c - 'A';
                return optionVisible[index] ? index : -1;
            }
            if (c == 'Q') {
                std::cout << "\nVocê desistiu do quiz. Até a próxima!\n";
                return -2;
            }
        }

        return -1;
    }

    bool handleLifeline(const Question& question, std::vector<bool>& optionVisible) {
        if (!lifelines.fiftyFifty && !lifelines.audience && !lifelines.skip) {
            std::cout << "\nVocê já usou todas as lifelines.\n";
            return false;
        }

        std::cout << "\nEscolha sua lifeline:\n";
        std::cout << "  1) 50/50 " << (lifelines.fiftyFifty ? "(disponível)" : "(usada)") << "\n";
        std::cout << "  2) Ajuda da Plateia " << (lifelines.audience ? "(disponível)" : "(usada)") << "\n";
        std::cout << "  3) Pular " << (lifelines.skip ? "(disponível)" : "(usada)") << "\n";
        std::cout << "  4) Voltar\n";
        std::cout << "Sua escolha: ";

        std::string choice;
        std::getline(std::cin, choice);

        if (choice == "1" && lifelines.fiftyFifty) {
            applyFiftyFifty(question, optionVisible);
            lifelines.fiftyFifty = false;
            return true;
        }
        if (choice == "2" && lifelines.audience) {
            applyAudienceHelp(question, optionVisible);
            lifelines.audience = false;
            return false;
        }
        if (choice == "3" && lifelines.skip) {
            applySkip(question);
            lifelines.skip = false;
            currentIndex += 1;
            if (currentIndex >= static_cast<int>(questions.size())) {
                completed = true;
            }
            return true;
        }

        if (choice == "4") {
            return false;
        }

        std::cout << "Escolha inválida ou lifeline já usada. Tente novamente.\n";
        return false;
    }

    void applyFiftyFifty(const Question& question, std::vector<bool>& optionVisible) const {
        std::vector<int> wrong;
        for (int i = 0; i < static_cast<int>(question.options.size()); ++i) {
            if (i != question.answer) {
                wrong.push_back(i);
            }
        }
        std::shuffle(wrong.begin(), wrong.end(), engine);
        optionVisible[wrong[0]] = false;
        optionVisible[wrong[1]] = false;

        std::cout << "\n50/50 ativado: duas opções incorretas foram removidas.\n";
    }

    void applyAudienceHelp(const Question& question, const std::vector<bool>& optionVisible) {
        std::vector<int> weights(question.options.size(), 0);
        int correctWeight = 40 + static_cast<int>(engine() % 31); // 40-70%
        weights[question.answer] = correctWeight;
        int remaining = 100 - correctWeight;

        std::vector<int> wrongIndices;
        for (int i = 0; i < static_cast<int>(question.options.size()); ++i) {
            if (i != question.answer) {
                wrongIndices.push_back(i);
            }
        }

        for (int i = 0; i < static_cast<int>(wrongIndices.size()); ++i) {
            int index = wrongIndices[i];
            if (i == static_cast<int>(wrongIndices.size()) - 1) {
                weights[index] = remaining;
            } else {
                std::uniform_int_distribution<int> dist(0, remaining);
                weights[index] = dist(engine);
                remaining -= weights[index];
            }
        }

        std::cout << "\nResultado da plateia:\n";
        for (int i = 0; i < static_cast<int>(question.options.size()); ++i) {
            if (!optionVisible[i]) {
                std::cout << "  " << char('A' + i) << ") -- oculto --\n";
                continue;
            }
            std::cout << "  " << char('A' + i) << ") " << weights[i] << "%\n";
        }
        std::cout << "\nA plateia sugere a opção com maior porcentagem.\n";
    }

    void applySkip(const Question& question) const {
        std::cout << "\nPular ativado: esta pergunta foi descartada sem penalidade.\n";
    }

    void printSummary() const {
        std::cout << "\n============================================\n";
        std::cout << "Fim do quiz! Você acertou " << score << " de " << questions.size() << " perguntas.\n";
        if (score > 0) {
            std::cout << "Seu último prêmio seguro foi: " << safePrize() << "\n";
        }
        std::cout << "Obrigado por jogar o Quiz do Bilhão C++.\n";
        std::cout << "============================================\n";
    }

    void printVictory() const {
        std::cout << "\n============================================\n";
        std::cout << "PARABÉNS! VOCÊ VENCEU O QUIZ DO BILHÃO!\n";
        std::cout << "Você conquistou R$ 1.000.000 com estratégia e conhecimento.\n";
        std::cout << "============================================\n";
    }

    std::string safePrize() const {
        if (currentIndex >= 7) {
            return "R$ 100.000";
        }
        if (currentIndex >= 4) {
            return "R$ 10.000";
        }
        return "R$ 0";
    }
};

int main() {
    QuizBilhao quiz;
    quiz.run();
    return 0;
}
