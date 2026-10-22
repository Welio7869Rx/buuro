#!/usr/bin/env lua
-- -*- coding: utf-8 -*-
--[[
    🎮 JOGO DA FORCA - NPC INTELIGENTE EM LUA
    Sistema completo de NPC com diálogos e dicas contextuais
    Compatível com Lua 5.1+
]]

-- ============================================
-- CLASSE NPC
-- ============================================

local NPC = {}
NPC.__index = NPC

-- Criador do NPC
function NPC:new(nome, personalidade)
    local self = setmetatable({}, NPC)
    self.nome = nome or "Assistente"
    self.personalidade = personalidade or "amigavel"
    self.dicas_usadas = 0
    self.max_dicas = 3
    self.estado = "idle" -- idle, feliz, triste, pensando
    self.contador_interacoes = 0
    return self
end

-- ============================================
-- BANCO DE DIÁLOGOS
-- ============================================

NPC.dialogos = {
    -- Saudações iniciais
    saudacao = {
        amigavel = {
            "Olá! Bem-vindo ao Jogo da Forca! 👋",
            "Oi aí! Que tal um jogo de adivinhar palavras? 🎮",
            "Bom dia! Vou te ajudar a vencer esse desafio!",
            "Olá, adventureiro! Preparado para o desafio? ⚔️",
        },
        misterioso = {
            "Uma sombra se aproxima... Você ousa entrar nesse jogo? 🌑",
            "Bem-vindo ao reino das palavras esquecidas...",
            "Hmmm, mais um desafiante... Vamos ver seu potencial.",
            "A sorte está ao seu lado, espero...",
        },
        profesional = {
            "Bem-vindo ao sistema de Jogo da Forca v1.0",
            "Estou aqui para assistência técnica e dicas estratégicas.",
            "Vamos começar a sessão de jogo.",
            "Sistema pronto. Aguardando próxima ação.",
        },
        entusiasta = {
            "UHAU! Você chegou! Isso vai ser INCRÍVEL! 🎉",
            "Que animação! Vamos começar já!",
            "Eba! Mais um jogador! Preparado para vencer? 💪",
            "VAAAAMO! Você vai arrasar nesse jogo!",
        }
    },
    
    -- Encorajamentos
    encoraja = {
        amigavel = {
            "Você consegue! Vamos lá! 💪",
            "Não desista agora, você está indo bem!",
            "Acredito em você! Continue tentando!",
            "Vamos! Mais um acerto e você vence!",
        },
        misterioso = {
            "A escuridão não te vence... nem a palavra.",
            "Teu destino não está selado... ainda.",
            "Continue. Há esperança nesta jornada.",
            "O final ainda não foi escrito...",
        },
        profesional = {
            "Continuando... Análise em progresso.",
            "Desempenho dentro do esperado. Prossiga.",
            "Estatísticas favoráveis. Continue.",
            "Sistema mantém esperança em seu êxito.",
        },
        entusiasta = {
            "VÁ! VÁ! VÁ! Você tá indo bem demais! 🚀",
            "QUE LETRA BOA! Que atitude feroz! 🔥",
            "YAAAS! Continue assim, você é uma máquina!",
            "Que épico! Que maravilha! Continue! 🌟",
        }
    },
    
    -- Quando acerta
    acerto = {
        amigavel = {
            "Boa! Você acertou! 🎉",
            "Excelente escolha de letra!",
            "Isso! Você está no caminho certo!",
            "Perfeito! Você tem bom palpite! ✨",
        },
        misterioso = {
            "Hmmm, uma escolha sábia...",
            "A sorte te favorece neste momento.",
            "Interessante... você parece saber algo.",
            "Teu instinto não te falha.",
        },
        profesional = {
            "Acerto registrado. +1 ponto.",
            "Seleção correta. Parabéns.",
            "Letra válida identificada.",
            "Desempenho esperado. Prossiga.",
        },
        entusiasta = {
            "EEEE! ACERTOU MESMO! 🎊",
            "QUE ACERTO INCRÍVEL! Você é um gênio!",
            "UAUUUU! Que instinto perfeito! 💯",
            "ALELUIA! Você arrasou nessa! 🌟",
        }
    },
    
    -- Quando erra
    erro = {
        amigavel = {
            "Ops! Não dessa vez, mas você consegue! 😊",
            "Essa não era, mas tem mais chances!",
            "Errou dessa vez, mas não desista!",
            "Nem sempre acertamos, tente denovo!",
        },
        misterioso = {
            "A escuridão nublou teu julgamento...",
            "Nem todos os caminhos levam à vitória.",
            "Um pequeno tropeço nessa jornada.",
            "A letra não estava no destino.",
        },
        profesional = {
            "Letra não encontrada. -1 tentativa.",
            "Seleção incorreta. Prossiga com cautela.",
            "Erro registrado. Mantenha estratégia.",
            "Tente uma abordagem diferente.",
        },
        entusiasta = {
            "Opa! Dessa vez não! Mas você volta! 💪",
            "Errou! Mas todo herói cai para se levantar! 🦸",
            "Que pena! Mas o jogo não acabou ainda! 🔥",
            "Uh oh! Mas você tem mais chances! Vamos!",
        }
    },
    
    -- Victoria
    vitoria = {
        amigavel = {
            "PARABÉNS! Você venceu! 🏆",
            "Incrível! Você é um campeão!",
            "Você conquistou a vitória! Muito bem!",
            "Que jogada magnífica! Vitória com honra!",
        },
        misterioso = {
            "A luz vence a escuridão... e você é essa luz.",
            "Teu destino era vencer. Está cumprido.",
            "Sábio escolheste bem. A vitória é tua.",
            "A jornada chegou ao fim... gloriosamente.",
        },
        profesional = {
            "VITÓRIA CONFIRMADA. Parabéns.",
            "Sistema reporta: Objetivo cumprido com sucesso.",
            "Avaliação final: EXCELENTE.",
            "Desempenho: 100% bem-sucedido.",
        },
        entusiasta = {
            "YAAAAAAAS! VOCÊ VENCEU! 🎊🎊🎊",
            "QUE VITÓRIA ÉPICA! CAMPEÃO! 👑",
            "UAUUUUUUU! VOCÊ É INSANO! 🚀🚀",
            "ALELUIA! VITÓRIA GLORIOSA! 🌟💫🏆",
        }
    },
    
    -- Derrota
    derrota = {
        amigavel = {
            "Que pena! Você perdeu dessa vez, mas tente novamente!",
            "Nem sempre ganhamos, mas podemos tentar de novo!",
            "Foi por pouco! Quer jogar outra rodada?",
            "A vitória para na próxima, tenho certeza!",
        },
        misterioso = {
            "A escuridão prevaleceu... desta vez.",
            "Teu destino não era vencer nesta ocasião.",
            "A jornada terminou antes do esperado.",
            "As sombras reclamam sua vitória.",
        },
        profesional = {
            "DERROTA REGISTRADA. Objetivo não cumprido.",
            "Análise: Estratégia precisava otimização.",
            "Sistema reporta: Falha na execução.",
            "Recomendação: Tente novamente com nova tática.",
        },
        entusiasta = {
            "Aw, que pena! Mas você foi demais! 🔥",
            "Que jogo épico! Revanche? REVANCHE? 💪",
            "Que batalha! A derrota é apenas uma... pausa! 🎮",
            "Que combate feroz! Vamos tentar dinovo? 💥",
        }
    },
    despedida = {
        amigavel = {
            "Foi um prazer jogar com você. Até a próxima! 😊",
            "Volte quando quiser, estarei aqui para ajudar sempre!",
            "Obrigada por jogar! Seu próximo acerto será ainda melhor!",
            "Vou esperar sua volta com um sorriso!",
        },
        misterioso = {
            "A noite aguarda seu retorno... até breve.",
            "As sombras não esquecem seu nome. Volte em breve.",
            "O destino sempre reserva outra partida.",
            "Siga seu caminho, e nos veremos novamente.",
        },
        profesional = {
            "Sessão finalizada com sucesso. Até a próxima.",
            "Registro salvo. Aguarde nova execução.",
            "Encerrando sistema. Retorne quando desejar.",
            "Operação concluída. Obrigado por jogar.",
        },
        entusiasta = {
            "QUE AVENTURA INCRÍVEL! Volte logo! 🌟",
            "AMEI jogar com você! Até a próxima, campeão! 🎉",
            "Você arrasou! Quero revanche em breve!",
            "UHUL! Até a próxima rodada épica!",
        }
    }
}

-- ============================================
-- AVATARES HUMANOS DOS NPCs
-- ============================================

NPC.rostos = {
    amigavel = [[
      .-""""-.
     /  o  o  \
    |    ^    |
    |  \___/  |
     \      /
      `----'
    ]],
    misterioso = [[
      .-""""-.
     /  -  -  \
    |   > <   |
    |   ---   |
     \  --- /
      `----'
    ]],
    profissional = [[
      .-""""-.
     /  o  o  \
    |    ^    |
    |  _____  |
     \ \___/ /
      `----'
    ]],
    entusiasta = [[
      .-""""-.
     /  ^  ^  \
    |  \___/  |
    |  \___/  |
     \  --- /
      `----'
    ]],
}

-- ============================================
-- SISTEMA DE DICAS
-- ============================================

NPC.dicas = {
    amigavel = {
        "Tente as vogais primeiramente! (A, E, I, O, U)",
        "Procure por letras comuns como R, S, T, N...",
        "Pense em palavras relacionadas a programação!",
        "Letras frequentes em português: R, S, A, O, D...",
        "Tente uma letra que aparece muitas vezes!",
        "Teste consoantes duplas como RR, SS...",
        "Procure por padrões na palavra!",
    },
    misterioso = {
        "O caminho da sabedoria começa nas vogais...",
        "Os antigos conhecem bem: R, S, T... teste-as.",
        "A palavra sussurra seus segredos... ouça com cuidado.",
        "Em cada língua há letras que reinam... testa-as.",
        "O padrão se revela apenas aos observadores atentos.",
        "Há magia nas letras que mais aparecem...",
        "Teu intuição é teu melhor guia nesta escuridão.",
    },
    profesional = {
        "Algoritmo recomenda: Comece com vogais.",
        "Análise estatística: R, S, T, N, O têm alta frequência.",
        "Tática sugerida: Teste letras de alta probabilidade.",
        "Matriz de frequência: Consulte português comum.",
        "Sistema recomenda revisão de padrões.",
        "Dados indicam: Consoantes duplas são estratégia válida.",
        "Otimize sua seleção baseado em frequência.",
    },
    entusiasta = {
        "VÁ! Teste as vogais! A, E, I, O, U! 🚀",
        "FORÇA! As letras comuns te ajudam! R, S, T! 💪",
        "QUE IDEA BRILHANTE! Pense em PROGRAMAÇÃO! 🧠",
        "SENSACIONAL! Padrões visuais te ajudam! 👀",
        "ÉPICO! Tente duplas de consoantes! 🎯",
        "QUERIDOOO! Sua intuição é o SEGREDO! ✨",
        "ARRASAAA! Análise é sua melhor ARMA! 💎",
    }
}

-- ============================================
-- MÉTODOS DO NPC
-- ============================================

-- Obter saudação
function NPC:saudar()
    self.estado = "feliz"
    local lista = self.dialogos.saudacao[self.personalidade]
    return self:_selecionar_aleatorio(lista)
end

-- Dar dica
function NPC:dar_dica()
    if self.dicas_usadas >= self.max_dicas then
        return "Desculpe, você já usou todas as dicas! Você consegue sem mim! 💪"
    end
    
    self.dicas_usadas = self.dicas_usadas + 1
    local lista = self.dicas[self.personalidade]
    local dica = self:_selecionar_aleatorio(lista)
    
    return string.format(
        "[DICA %d/%d] 💡 %s",
        self.dicas_usadas,
        self.max_dicas,
        dica
    )
end

-- Encorajamento
function NPC:encorajar()
    self.estado = "feliz"
    local lista = self.dialogos.encoraja[self.personalidade]
    return self:_selecionar_aleatorio(lista)
end

-- Reação a acerto
function NPC:reagir_acerto()
    self.estado = "feliz"
    local lista = self.dialogos.acerto[self.personalidade]
    return self:_selecionar_aleatorio(lista)
end

-- Reação a erro
function NPC:reagir_erro()
    self.estado = "triste"
    local lista = self.dialogos.erro[self.personalidade]
    return self:_selecionar_aleatorio(lista)
end

-- Reação a vitória
function NPC:reagir_vitoria()
    self.estado = "feliz"
    local lista = self.dialogos.vitoria[self.personalidade]
    return self:_selecionar_aleatorio(lista)
end

-- Reação a derrota
function NPC:reagir_derrota()
    self.estado = "triste"
    local lista = self.dialogos.derrota[self.personalidade]
    return self:_selecionar_aleatorio(lista)
end

-- Diálogo randômico
function NPC:falar_aleatorio(situacao)
    local lista = self.dialogos[situacao] or {}
    local opcoes = lista[self.personalidade] or {}
    return self:_selecionar_aleatorio(opcoes) or "..."
end

-- ============================================
-- MÉTODOS UTILITÁRIOS
-- ============================================

-- Selecionar elemento aleatório
function NPC:_selecionar_aleatorio(lista)
    if not lista or #lista == 0 then
        return nil
    end
    self.contador_interacoes = self.contador_interacoes + 1
    return lista[math.random(1, #lista)]
end

-- Obter emoji do estado
function NPC:emoji_estado()
    local emojis = {
        idle = "😐",
        feliz = "😊",
        triste = "😢",
        pensando = "🤔"
    }
    return emojis[self.estado] or "😐"
end

-- Retorna avatar humano do NPC
function NPC:avatar()
    local rosto = self.rostos[self.personalidade] or self.rostos.amigavel
    return rosto .. "\n" .. string.format("  %s %s", self.nome, self:emoji_estado())
end

-- Resetar contador de dicas
function NPC:resetar_dicas()
    self.dicas_usadas = 0
end

-- Obter status
function NPC:status()
    return string.format(
        "%s %s | Personalidade: %s | Dicas: %d/%d",
        self.nome,
        self:emoji_estado(),
        self.personalidade,
        self.dicas_usadas,
        self.max_dicas
    )
end

-- ============================================
-- EXEMPLOS DE USO E TESTES
-- ============================================

local function exemplo_uso()
    print("\n" .. "="*50)
    print("  🎮 JOGO DA FORCA - NPC LUA DEMO")
    print("="*50 .. "\n")
    
    -- Criar NPCs com diferentes personalidades
    local npc_amigavel = NPC:new("Robin", "amigavel")
    local npc_misterioso = NPC:new("Shadow", "misterioso")
    local npc_profesional = NPC:new("CORE", "profesional")
    local npc_entusiasta = NPC:new("Blaze", "entusiasta")
    
    local npcs = {npc_amigavel, npc_misterioso, npc_profesional, npc_entusiasta}
    
    for _, npc in ipairs(npcs) do
        print("\n" .. "-"*50)
        print(npc:status())
        print("-"*50)
        
        print("\n[SAUDAÇÃO]")
        print("🤖: " .. npc:saudar())
        
        print("\n[ENCORAJAMENTO]")
        print("🤖: " .. npc:encorajar())
        
        print("\n[ACERTO]")
        print("🤖: " .. npc:reagir_acerto())
        
        print("\n[ERRO]")
        print("🤖: " .. npc:reagir_erro())
        
        print("\n[DICAS]")
        for i = 1, 3 do
            print("🤖: " .. npc:dar_dica())
        end
        print("🤖: " .. npc:dar_dica()) -- 4ª dica (limite atingido)
        
        print("\n[VITÓRIA]")
        print("🤖: " .. npc:reagir_vitoria())
        
        npc:resetar_dicas()
        
        print("\n[DERROTA]")
        print("🤖: " .. npc:reagir_derrota())
    end
    
    print("\n" .. "="*50)
    print("  ✅ DEMO CONCLUÍDA")
    print("="*50 .. "\n")
end

-- Executar exemplos se rodado diretamente
if arg and arg[1] == "demo" then
    exemplo_uso()
end

-- ============================================
-- EXPORTAÇÃO
-- ============================================

return NPC
