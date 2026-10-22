# 📚 Guia de Desenvolvimento - NPC Lua

Tutorial completo para entender e estender o sistema de NPC em Lua.

---

## 🎯 Arquitetura

### Visão Geral

```text
┌─────────────────────────────────┐
│       main.lua                  │
│  (Jogo completo com interface)  │
│  - JogoForca class              │
│  - Loop principal               │
│  - Entrada de usuário           │
└──────────────┬──────────────────┘
               │
               │ require()
               ▼
┌─────────────────────────────────┐
│       script.lua                │
│  (Sistema de NPC - módulo)      │
│  - NPC class                    │
│  - Diálogos                     │
│  - Dicas                        │
└─────────────────────────────────┘
```

---

## 🤖 Estrutura da Classe NPC

### Inicialização

```lua
local npc = NPC:new(nome, personalidade)
```

**Parâmetros:**

- `nome` (string): Nome do NPC (Robin, Shadow, etc)
- `personalidade` (string): amigavel, misterioso, profesional, entusiasta

**Atributos Criados:**

- `nome`: Nome do NPC
- `personalidade`: Tipo de personalidade
- `dicas_usadas`: Contador de dicas (0 inicialmente)
- `max_dicas`: Máximo de dicas (3)
- `estado`: Estado emocional (idle, feliz, triste, pensando)
- `contador_interacoes`: Para randomização

---

## 💬 Sistema de Diálogos

### Estrutura de Dicas

```lua
NPC.dialogos = {
    [situacao] = {
        [personalidade] = {
            "diálogo 1",
            "diálogo 2",
            ...
        }
    }
}
```

### Situações de Diálogo

1. **saudacao** - Boas-vindas iniciais
2. **encoraja** - Encorajamento durante jogo
3. **acerto** - Quando acerta uma letra
4. **erro** - Quando erra uma letra
5. **vitoria** - Ao vencer a partida
6. **derrota** - Ao perder a partida

### Adicionar Novo Diálogo

```lua
-- Em script.lua, dentro de NPC.dialogos
NPC.dialogos.meu_evento = {
    amigavel = {
        "Meu diálogo amigável",
        "Outro amigável",
    },
    misterioso = {
        "Meu diálogo misterioso",
        "Outro misterioso",
    },
    -- ... outras personalidades
}
```

---

## 💡 Sistema de Dicas

### Estrutura

```lua
NPC.dicas = {
    [personalidade] = {
        "dica 1",
        "dica 2",
        ...
    }
}
```

### Estratégia

Cada personalidade dá dicas no seu estilo:

**Amigável:**

- Prático e estratégico
- Foco em padrões comuns
- Dicas óbvias

**Misterioso:**

- Poético e enigmático
- Sugestões metafóricas
- Apelos ao instinto

**Profissional:**

- Técnico e analítico
- Base em frequência
- Termos computacionais

**Entusiasta:**

- Energético e motivador
- Empowering
- Celebra cada passo

### Adicionar Dica

```lua
-- Em script.lua, em NPC.dicas[personalidade]
table.insert(NPC.dicas.amigavel, "Sua dica aqui")
```

---

## 🎮 Classe JogoForca

### Configuração Inicial

```lua
local jogo = JogoForca:new(npc)
```

**Atributos:**

- `npc`: Referência ao NPC
- `palavras`: Lista de palavras
- `palavra_secreta`: Palavra atual
- `letras_adivinhadas`: Table de letras corretas
- `letras_erradas`: Table de letras erradas
- `tentativas_restantes`: 6 inicialmente
- `vitoria`: Flag de vitória
- `derrota`: Flag de derrota

### Loop Principal

```lua
function JogoForca:rodar()
    -- 1. NPC cumprimenta
    -- 2. Loop enquanto não vencer/perder:
    --    a. Exibir interface
    --    b. Pedir palpite
    --    c. Processar palpite
    --    d. Reagir com NPC
    -- 3. Reagir ao fim (vitória/derrota)
    -- 4. Oferecer replay
end
```

---

## 📝 Personalizações Comuns

### 1. Adicionar Nova Personalidade

**Passo 1:** Em `script.lua`, estenda os diálogos

```lua
NPC.dialogos.saudacao.suave = {
    "Bem-vindo ao reino das palavras...",
    "Que jornada interessante nos aguarda...",
}

NPC.dialogos.encoraja.suave = {
    "Continue sua busca...",
    "Há esperança nesta tentativa...",
}

-- Repita para: acerto, erro, vitoria, derrota
```

**Passo 2:** Adicione dicas

```lua
NPC.dicas.suave = {
    "A sabedoria vem da paciência...",
    "Observe os padrões sutis...",
    "O silêncio revela os segredos...",
}
```

**Passo 3:** Atualize o seletor em `main.lua`

```lua
local configs = {
    {nome = "Serenity", personalidade = "suave"},
    -- ... outros ...
}
```

### 2. Adicionar Mais Palavras

```lua
-- Em main.lua, na função JogoForca:new()
self.palavras = {
    -- ... existentes ...
    "MINHA_PALAVRA",
    "OUTRA_PALAVRA",
}
```

### 3. Mudar Dificuldade

```lua
-- Em main.lua, em JogoForca:new()
self.tentativas_restantes = 4  -- Mais difícil
self.tentativas_restantes = 10 -- Mais fácil

-- Em main.lua, na classe NPC
self.npc.max_dicas = 5  -- Mais dicas
```

### 4. Adicionar Evento Novo

Exemplo: Quando resta 1 tentativa

```lua
-- Em script.lua, adicione novo método
function NPC:aviso_critico()
    self.estado = "pensando"
    local lista = self.dialogos.critico[self.personalidade]
    return self:_selecionar_aleatorio(lista)
end

-- E adicione diálogos
NPC.dialogos.critico = {
    amigavel = {
        "Cuidado! Reste apenas 1 tentativa!",
    },
    -- ... etc
}

-- Em main.lua, chame quando tentativas == 1
if jogo.tentativas_restantes == 1 then
    print(jogo.npc:aviso_critico())
end
```

---

## 🔧 Padrões Lua Usado

### 1. Metatables para OOP

```lua
local NPC = {}
NPC.__index = NPC

function NPC:new(nome)
    local self = setmetatable({}, NPC)
    self.nome = nome
    return self
end

function NPC:metodo()
    -- self é automaticamente passado
end

local npc = NPC:new("Robin")
npc:metodo()  -- Chama com self = npc
```

### 2. Variadic Returns

```lua
function _selecionar_aleatorio(lista)
    if not lista or #lista == 0 then
        return nil  -- Retorna nil se vazio
    end
    return lista[math.random(1, #lista)]
end

local resultado = npc:_selecionar_aleatorio(lista)
-- resultado pode ser string ou nil
```

### 3. Tables como Dicionários

```lua
local mapa = {
    A = 1,
    B = 2,
}

if mapa["A"] then
    print(mapa["A"])  -- Acesso seguro
end
```

### 4. String Formatting

```lua
local msg = string.format("Dica %d/%d", 1, 3)
-- Resultado: "Dica 1/3"
```

---

## 📊 Fluxo de Dados

### Exemplo de Interação

```text
1. Usuário escolhe NPC
   └─> npc = NPC:new("Robin", "amigavel")

2. Jogo inicia
   └─> jogo = JogoForca:new(npc)
   └─> print(npc:saudar())
       "Olá! Bem-vindo ao Jogo da Forca! 👋"

3. Usuário adivinha letra
   └─> jogo:processar_palpite("A")
   └─> Se acerto: 
       print(npc:reagir_acerto())
       "Boa! Você acertou! 🎉"

4. Usuário pede dica
   └─> print(npc:dar_dica())
       "[DICA 1/3] 💡 Tente as vogais!"

5. Jogo encerra
   └─> Se vitória:
       print(npc:reagir_vitoria())
       "PARABÉNS! Você venceu! 🏆"
```

---

## 🧪 Testando Mudanças

### Teste de Demo

```bash
lua script.lua demo
```

Mostra cada personalidade em ação.

### Teste Manual

```bash
lua main.lua
```

Joga o jogo completo.

### Debug

Adicione prints em pontos críticos:

```lua
print("[DEBUG] Tentativas restantes: " .. jogo.tentativas_restantes)
print("[DEBUG] Palavra: " .. jogo.palavra_secreta)
print("[DEBUG] Dicas usadas: " .. jogo.npc.dicas_usadas)
```

---

## 🚀 Extensões Futuras

### 1. Persistência

```lua
function salvar_progresso(npc, jogo)
    local arquivo = io.open("progresso.txt", "w")
    arquivo:write(jogo.palavra_secreta)
    arquivo:close()
end

function carregar_progresso()
    local arquivo = io.open("progresso.txt", "r")
    local dados = arquivo:read("*a")
    arquivo:close()
    return dados
end
```

### 2. Leaderboard

```lua
function registrar_vitoria(npc, tempo)
    -- Salvar em arquivo JSON
    -- Mostrar top 10
end
```

### 3. Achievements

```lua
local achievements = {
    primeira_vitoria = {
        descricao = "Vencer primeira partida",
        desbloqueado = false,
    }
}
```

### 4. Multilíngue

```lua
local idiomas = {
    pt = { saudacao = "Olá!" },
    en = { saudacao = "Hello!" },
}
```

---

## 📖 Recursos Lua

- [Lua.org](https://www.lua.org/) - Site oficial
- [Lua Book](https://www.lua.org/pil/) - Programming in Lua
- [Lua 5.1 Manual](https://www.lua.org/manual/5.1/)
- [Lua 5.3 Manual](https://www.lua.org/manual/5.3/)

---

## 🎓 Conceitos Avançados

### Closures

```lua
function criar_contador()
    local count = 0
    return function()
        count = count + 1
        return count
    end
end

local contador = criar_contador()
print(contador())  -- 1
print(contador())  -- 2
```

### Variadic Functions

```lua
function soma(...)
    local total = 0
    for _, v in ipairs({...}) do
        total = total + v
    end
    return total
end

print(soma(1, 2, 3, 4))  -- 10
```

### Metamethods

```lua
local mt = {}
function mt:__tostring()
    return "NPC: " .. self.nome
end

setmetatable(npc, mt)
print(npc)  -- NPC: Robin
```

---

## 🤝 Contribuindo

Para estender o projeto:

1. Crie nova personalidade
2. Adicione diálogos completos
3. Implemente em ambas as funções
4. Teste com `lua script.lua demo`
5. Documente mudanças

---

## 📝 Checklist de Personalidade

Ao adicionar nova personalidade, verifique:

- [ ] Diálogos de saudação (3-4)
- [ ] Encorajamentos (3-4)
- [ ] Reações a acerto (3-4)
- [ ] Reações a erro (3-4)
- [ ] Reações a vitória (3-4)
- [ ] Reações a derrota (3-4)
- [ ] Dicas estratégicas (5-7)
- [ ] Testado em demo
- [ ] Testado em jogo

---

Desenvolvido com ❤️ em Lua 5.1+

Divirta-se programando! 🎮
