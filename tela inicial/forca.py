import streamlit as st
# Importa a lógica de palavras do arquivo que você acabou de criar
from palavras import sortear_palavra

# Configuração da página e estilo CSS avançado
st.set_page_config(
    page_title="Super Jogo da Forca", page_icon="🍇", layout="centered"
)

st.markdown(
    """
    <style>
    .titulo { text-align: center; color: #E63946; font-weight: bold; font-size: 38px; margin-bottom: 0px; text-shadow: 2px 2px 4px rgba(0,0,0,0.1); }
    .subtitulo { text-align: center; color: #457B9D; font-size: 20px; margin-bottom: 30px; }
    .palavra-secreta { text-align: center; font-size: 42px; font-family: 'Courier New', monospace; font-weight: bold; letter-spacing: 12px; color: #1D3557; margin: 30px 0; background-color: #F1FAEE; padding: 15px; border-radius: 10px; box-shadow: inset 0 0 10px rgba(0,0,0,0.05); }
    
    @keyframes piscar { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
    @keyframes vitoria { 0% { transform: scale(0.5); } 70% { transform: scale(1.1); } 100% { transform: scale(1); } }
    
    .tela-vitoria { text-align: center; background: linear-gradient(135deg, #4BB543, #2E7D32); color: white; padding: 30px; border-radius: 15px; animation: vitoria 0.6s ease-out; box-shadow: 0 10px 20px rgba(0,0,0,0.2); }
    .tela-derrota { text-align: center; background: linear-gradient(135deg, #D32F2F, #B71C1C); color: white; padding: 30px; border-radius: 15px; animation: piscar 2s infinite; box-shadow: 0 10px 20px rgba(0,0,0,0.2); }
    
    .resultado-titulo { font-size: 32px; font-weight: bold; margin-bottom: 10px; }
    .resultado-sub { font-size: 20px; }
    </style>
    """,
    unsafe_allow_html=True,
)

st.markdown(
    "<h1 class='titulo'>🎮 SUPER JOGO DA FORCA 🎮</h1>", unsafe_allow_html=True
)
st.markdown(
    "<h3 class='subtitulo'>----- TENTE ADIVINHAR A PALAVRA SECRETA -----</h3>",
    unsafe_allow_html=True,
)

# Inicialização das variáveis de estado do Streamlit
if "palavra" not in st.session_state:
    nova_palavra, total_banco = sortear_palavra()
    st.session_state.palavra = nova_palavra
    st.session_state.total_palavras = total_banco
    st.session_state.pal_secreta = ["_"] * len(st.session_state.palavra)
    st.session_state.chances = 0
    st.session_state.letras_tentadas = set()
    st.session_state.jogo_finalizado = False
    st.session_state.mensagem = ""

# Atalhos para legibilidade
palavra = st.session_state.palavra
pal_secreta = st.session_state.pal_secreta


# Função de reinício do jogo
def reiniciar_jogo():
    palavra_sorteada, quantidade_palavras = sortear_palavra()
    st.session_state.palavra = palavra_sorteada
    st.session_state.total_palavras = quantidade_palavras
    st.session_state.pal_secreta = ["_"] * len(st.session_state.palavra)
    st.session_state.chances = 0
    st.session_state.letras_tentadas = set()
    st.session_state.jogo_finalizado = False
    st.session_state.mensagem = ""
    st.rerun()


# Exibição do progresso da palavra estilizado
palavra_formatada = " ".join(pal_secreta)
st.markdown(
    f"<div class='palavra-secreta'>{palavra_formatada}</div>",
    unsafe_allow_html=True,
)

# Painel lateral de status com métricas limpas
with st.sidebar:
    st.header("📊 Status da Partida")
    st.metric(label="Letras na Palavra", value=len(palavra))
    st.metric(label="Chances Restantes", value=10 - st.session_state.chances)
    st.write("🔤 **Letras já tentadas:**")
    if st.session_state.letras_tentadas:
        st.info(", ".join(sorted(st.session_state.letras_tentadas)))
    else:
        st.caption("Nenhuma letra digitada ainda.")

    st.markdown("---")
    st.caption(
        f"Banco de dados ativo: {st.session_state.total_palavras:,} palavras carregadas."
    )

# Interface ativa de jogabilidade
if not st.session_state.jogo_finalizado:
    col1, col2 = st.columns()

    with col1:
        with st.form("tentar_letra", clear_on_submit=True):
            letra = st.text_input("Digite apenas uma letra:", max_chars=1).upper()
            enviar_letra = st.form_submit_button("Confirmar Letra 🔠")

            if enviar_letra and letra:
                if not letra.isalpha():
                    st.warning("Por favor, digite apenas letras!")
                elif letra in st.session_state.letras_tentadas:
                    st.info(f"Você já tentou a letra {letra}!")
                else:
                    st.session_state.letras_tentadas.add(letra)
                    if letra in palavra:
                        for i in range(len(palavra)):
                            if palavra[i] == letra:
                                pal_secreta[i] = letra
                        if "_" not in pal_secreta:
                            st.session_state.jogo_finalizado = True
                            st.session_state.mensagem = "ganhou"
                    else:
                        st.session_state.chances += 1
                        if st.session_state.chances >= 10:
                            st.session_state.jogo_finalizado = True
                            st.session_state.mensagem = "perdeu"
                    st.rerun()

    with col2:
        st.write("💡 **Tem certeza?**")
        with st.popover("Chutar Palavra 🎯"):
            chute = st.text_input("Digite a palavra completa:").upper()
            enviar_chute = st.button("Arriscar Tudo!")

            if enviar_chute and chute:
                if chute == palavra:
                    st.session_state.jogo_finalizado = True
                    st.session_state.mensagem = "ganhou"
                else:
                    st.session_state.jogo_finalizado = True
                    st.session_state.mensagem = "perdeu"
                st.rerun()

# Telas de finalização com animações CSS customizadas
if st.session_state.jogo_finalizado:
    if st.session_state.mensagem == "ganhou":
        st.balloons()
        st.snow()
        st.markdown(
            f"""
            <div class='tela-vitoria'>
                <div class='resultado-titulo'>🏆 VITÓRIA PARABÉNS! 🏆</div>
                <div class='resultado-sub'>Você descobriu a palavra a tempo!</div>
                <hr style='border-color: rgba(255,255,255,0.3);'>
                <p style='font-size: 24px; margin: 0;'>A palavra correta era: <b>{palavra}</b></p>
            </div>
            """,
            unsafe_allow_html=True,
        )
    else:
        st.markdown(
            f"""
            <div class='tela-derrota'>
                <div class='resultado-titulo'>💥 GAME OVER 💥</div>
                <div class='resultado-sub'>Suas chances acabaram ou você errou o chute fatídico.</div>
                <hr style='border-color: rgba(255,255,255,0.3);'>
                <p style='font-size: 24px; margin: 0;'>A palavra correta era: <b>{palavra}</b></p>
            </div>
            """,
            unsafe_allow_html=True,
        )

    st.markdown("<br>", unsafe_allow_html=True)
    if st.button(
        "Jogar Novamente 🔄", use_container_width=True, type="primary"
    ):
        reiniciar_jogo()
