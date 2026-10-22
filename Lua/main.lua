#!/usr/bin/env lua
-- -*- coding: utf-8 -*-
--[[
    🎮 JOGO DA FORCA COM NPC - VERSÃO LUA
    Jogo completo utilizando o sistema de NPC
]]

local NPC = require("script")
math.randomseed(os.time())
math.random(); math.random(); math.random()

local function pausar()
    if package.config:sub(1,1) == "\\" then
        os.execute("pause")
    else
        io.write("\nPressione ENTER para continuar...")
        io.read()
    end
end

local function limpar_tela()
    os.execute("clear") or os.execute("cls")
end

-- ============================================
-- CLASSE DO JOGO
-- ============================================

local JogoForca = {}
JogoForca.__index = JogoForca

function JogoForca:new(npc)
    local self = setmetatable({}, JogoForca)
    self.npc = npc
    self.palavras = {
        "PYTHON", "JAVASCRIPT", "PROGRAMACAO", "ALGORITMO", "VARIAVEL",
        "FUNCAO", "BIBLIOTECA", "FRAMEWORK", "DATABASE", "SERVIDOR",
        "INTERFACE", "SOFTWARE", "HARDWARE", "SISTEMA", "COMPUTADOR",
        "INTERNET", "NAVEGADOR", "FRONTEND", "BACKEND", "DESENVOLVEDOR",
        "LUA", "TABELA", "FUNCOES", "METATABLES", "COROUTINES",
        "COMPILADOR", "SEGURANCA", "LOGICA", "GITHUB", "CLOUD",
        "SCRIPT", "APLICACAO", "EXPERIENCIA", "DADOS", "AUTOMACAO",
        "DESIGN", "COMPONENTE", "TEMPLATES", "REUTILIZAVEL"
    }
    self:inicializar_partida()
    return self
end

function JogoForca:inicializar_partida()
    self.palavra_secreta = self.palavras[math.random(1, #self.palavras)]
    self.letras_adivinhadas = {}
    self.letras_erradas = {}
    self.tentativas_restantes = 6
    self.vitoria = false
    self.derrota = false
end

function JogoForca:exibir_palavra()
    local display = ""
    for i = 1, #self.palavra_secreta do
        local letra = self.palavra_secreta:sub(i, i)
        if self.letras_adivinhadas[letra] then
            display = display .. letra .. " "
        else
            display = display .. "_ "
        end
    end
    return display
end

function JogoForca:verificar_vitoria()
    for i = 1, #self.palavra_secreta do
        local letra = self.palavra_secreta:sub(i, i)
        if not self.letras_adivinhadas[letra] then
            return false
        end
    end
    return true
end

function JogoForca:processar_palpite(letra)
    letra = letra:upper()
    
    -- Validação
    if #letra ~= 1 then
        print("❌ Digite apenas UMA letra!")
        return
    end
    
    if not letra:match("[A-Z]") then
        print("❌ Digite apenas letras!")
        return
    end
    
    if self.letras_adivinhadas[letra] or self.letras_erradas[letra] then
        print("⚠️  Você já tentou '" .. letra .. "'!")
        return
    end
    
    -- Processar
    if self.palavra_secreta:find(letra) then
        self.letras_adivinhadas[letra] = true
        print("\n✨ " .. self.npc:reagir_acerto())
        
        if self:verificar_vitoria() then
            self.vitoria = true
        end
    else
        self.letras_erradas[letra] = true
        self.tentativas_restantes = self.tentativas_restantes - 1
        print("\n❌ " .. self.npc:reagir_erro())
        
        if self.tentativas_restantes <= 0 then
            self.derrota = true
        end
    end
end

function JogoForca:exibir_interface()
    limpar_tela()
    
    print("\n" .. "="*60)
    print("  🎮 JOGO DA FORCA COM NPC")
    print("="*60)
    print("\n" .. self.npc:avatar())
    print("\n  " .. self.npc:status())
    print("\n" .. "="*60)
    
    print("\n  Palavra: " .. self:exibir_palavra())
    print(string.format("  Tentativas: %d ❤️", self.tentativas_restantes))
    
    if #self.letras_erradas > 0 then
        local erradas = ""
        for letra in pairs(self.letras_erradas) do
            erradas = erradas .. letra .. " "
        end
        print("  Letras erradas: " .. erradas)
    end
    
    print("\n" .. "="*60)
end

function JogoForca:pedir_palpite()
    io.write("  📝 Digite uma letra (ou 'dica' para dica): ")
    local entrada = io.read()
    
    if entrada:lower() == "dica" then
        print("\n💡 " .. self.npc:dar_dica())
    else
        self:processar_palpite(entrada)
    end
end

function JogoForca:rodar()
    print(self.npc:saudar())
    pausar()
    
    while not self.vitoria and not self.derrota do
        self:exibir_interface()
        self:pedir_palpite()
        
        if self.vitoria then
            self:exibir_interface()
            print("\n🎉 " .. self.npc:reagir_vitoria())
            print("\n   A palavra era: " .. self.palavra_secreta)
        elseif self.derrota then
            self:exibir_interface()
            print("\n👻 " .. self.npc:reagir_derrota())
            print("\n   A palavra era: " .. self.palavra_secreta)
        else
            pausar()
        end
    end
    
    -- Pergunta se quer jogar novamente
    io.write("\n\n  Quer jogar novamente? (s/n): ")
    if io.read():lower() == "s" then
        self:inicializar_partida()
        self.npc:resetar_dicas()
        self:rodar()
    else
        print("\n  👋 " .. self.npc:falar_aleatorio("despedida"))
        print("\n  Até logo!\n")
    end
end

-- ============================================
-- SELETOR DE PERSONALIDADE
-- ============================================

local function selecionar_npc()
    limpar_tela()
    
    print("\n" .. "="*60)
    print("  🎮 JOGO DA FORCA - ESCOLHA SEU ASSISTENTE")
    print("="*60)
    print("\n  [1] Robin (Amigável) - Caloroso e encorajador")
    print("  [2] Shadow (Misterioso) - Enigmático e profundo")
    print("  [3] CORE (Profissional) - Técnico e objetivo")
    print("  [4] Blaze (Entusiasta) - Energético e animado")
    
    print("\n" .. "="*60)
    io.write("  Escolha (1-4): ")
    
    local escolha = io.read()
    local configs = {
        {nome = "Robin", personalidade = "amigavel"},
        {nome = "Shadow", personalidade = "misterioso"},
        {nome = "CORE", personalidade = "profesional"},
        {nome = "Blaze", personalidade = "entusiasta"},
    }
    
    local config = configs[tonumber(escolha)] or configs[1]
    local npc = NPC:new(config.nome, config.personalidade)
    print("\n" .. npc:avatar())
    print("\n  Você escolheu: " .. npc.nome .. " - " .. npc.personalidade)
    pausar()
    return npc
end

-- ============================================
-- PROGRAMA PRINCIPAL
-- ============================================

local function main()
    local npc = selecionar_npc()
    local jogo = JogoForca:new(npc)
    jogo:rodar()
end

-- Executar se for o script principal
if arg == nil or arg[0]:find("main.lua") then
    main()
end
