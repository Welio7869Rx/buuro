#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Jogo da Forca com Áudio e Interface Terminal
Compatível com Python 3.8+
"""

import asyncio
import random
import sys
import os
import threading
from enum import Enum

# Suporte a áudio no Windows com winsound
AUDIO_DISPONIVEL = False
PLATAFORMA = sys.platform

try:
    if PLATAFORMA == "win32":
        import winsound
        AUDIO_DISPONIVEL = True
        def beep(freq: int, dur: int):
            winsound.Beep(freq, dur)
    else:
        def beep(freq: int, dur: int):
            # Fallback silencioso em consoles não-Windows
            print("\a", end="", flush=True)
except (ImportError, AttributeError):
    def beep(freq: int, dur: int):
        print("\a", end="", flush=True)

# Constantes de frequências musicais (Hz)
C4, D4, E4, F4, G4, A4, B4, C5 = 261, 294, 329, 349, 392, 440, 493, 523

def debug_audio_state():
    try:
        print("\n[DEBUG AUDIO] PLATAFORMA:", PLATAFORMA)
        print("[DEBUG AUDIO] AUDIO_DISPONIVEL:", AUDIO_DISPONIVEL)
        print("[DEBUG AUDIO] winsound presente:", 'winsound' in globals())
        print("[DEBUG AUDIO] beep callable:", callable(globals().get('beep')))
    except Exception as e:
        print("[DEBUG AUDIO] erro ao coletar status:", e)

class Efeito(Enum):
    """Enumeração de efeitos sonoros"""
    INICIO = 1
    DICA = 2
    ACERTO = 3
    ERRO = 4
    VITORIA = 5
    DERROTA = 6

class AudioEngine:
    """Motor de áudio com suporte multiplataforma"""
    
    def __init__(self):
        # Melodia de fundo: (frequência, duração em ms)
        self._melodia = [
            (E4, 300), (G4, 300), (A4, 600),
            (E4, 300), (G4, 300), (B4, 150), (A4, 450),
            (E4, 300), (G4, 300), (A4, 600),
            (G4, 300), (E4, 900)
        ]
        self._ativa = True

    async def tocar_musica_fundo(self):
        """Loop assíncrono da música de fundo."""
        loop = asyncio.get_running_loop()
        try:
            while self._ativa:
                for freq, dur in self._melodia:
                    if not self._ativa:
                        return
                    # Executa o beep em um thread separado para não bloquear o event loop
                    await loop.run_in_executor(None, beep, freq, dur)
                    await asyncio.sleep(0.05)  # Pausa entre notas (não bloqueante)
                await asyncio.sleep(1.0)  # Pausa antes de reiniciar
        except (asyncio.CancelledError, KeyboardInterrupt):
            pass
        finally:
            self._ativa = False

    def disparar_efeito(self, efeito: Efeito):
        """Executa efeitos sonoros síncronos rapidamente."""
        def _play_effect():
            if efeito == Efeito.INICIO:
                beep(C4, 120)
                beep(E4, 120)
                beep(G4, 250)
            elif efeito == Efeito.DICA:
                beep(D4, 120)
                beep(E4, 120)
                beep(F4, 120)
            elif efeito == Efeito.ACERTO:
                beep(E4, 100)
                beep(G4, 100)
                beep(C5, 200)
            elif efeito == Efeito.ERRO:
                beep(G4, 150)
                beep(D4, 300)
                beep(C4, 150)
            elif efeito == Efeito.VITORIA:
                beep(C4, 150)
                beep(E4, 150)
                beep(G4, 150)
                beep(C5, 400)
                beep(E4, 200)
            elif efeito == Efeito.DERROTA:
                beep(F4, 300)
                beep(E4, 300)
                beep(D4, 300)
                beep(C4, 600)

        # Executa o efeito em thread separado para não bloquear o loop principal
        t = threading.Thread(target=_play_effect, daemon=True)
        t.start()

    def parar(self):
        """Para a reprodução de áudio"""
        self._ativa = False

class JogoForca:
    """Lógica principal do jogo da forca"""
    
    PALAVRAS = [
        "PYTHON", "JAVASCRIPT", "PROGRAMACAO", "ALGORITMO", "VARIAVEL",
        "FUNCAO", "BIBLIOTECA", "FRAMEWORK", "DATABASE", "SERVIDOR",
        "INTERFACE", "SOFTWARE", "HARDWARE", "SISTEMA", "COMPUTADOR",
        "INTERNET", "NAVEGADOR", "FRONTEND", "BACKEND", "DESENVOLVEDOR",
        "COMPILADOR", "SEGURANCA", "LOGICA", "GITHUB", "CLOUD",
        "SCRIPT", "APLICACAO", "EXPERIENCIA", "DADOS", "AUTOMACAO",
        "DESIGN", "COMPONENTE", "TEMPLATES", "REUTILIZAVEL"
    ]

    def __init__(self, audio: AudioEngine):
        self.audio = audio
        self.palavra_secreta = random.choice(self.PALAVRAS).upper()
        self.letras_descobertas = set()
        self.letras_erradas = set()
        self.tentativas_restantes = 6
        self.dicas_usadas = 0
        self.max_dicas = 3

    def exibir_painel(self):
        """Renderiza o estado atual do jogo no terminal."""
        # Limpar console
        self._limpar_console()
        
        print("\n" + "="*50)
        print("         🎮 JOGO DA FORCA 🎮")
        print("="*50)
        print(f"\n Tentativas restantes: {self.tentativas_restantes} ❤️")
        print(f" Dicas disponíveis: {self.max_dicas - self.dicas_usadas}/{self.max_dicas} 💡")
        print("\n (Digite 'dica' para receber uma dica)")
        
        # Exibir palavra com sublinhados
        exibicao = " ".join([
            letra if letra in self.letras_descobertas else "_" 
            for letra in self.palavra_secreta
        ])
        print(f"\n Palavra: {exibicao}")
        
        # Exibir letras erradas
        if self.letras_erradas:
            erradas = ", ".join(sorted(self.letras_erradas))
            print(f"\n ❌ Letras erradas: {erradas}")
        
        print("\n" + "="*50)

    @staticmethod
    def _limpar_console():
        """Limpa a tela do console de forma multiplataforma"""
        if sys.platform == "win32":
            os.system("cls")
        else:
            os.system("clear")

    async def rodar_loop_principal(self):
        """Processa a entrada de dados do usuário."""
        while self.tentativas_restantes > 0:
            self.exibir_painel()
            
            # Entrada de dados assíncrona baseada em thread
            loop = asyncio.get_event_loop()
            try:
                palpite = await loop.run_in_executor(
                    None, 
                    lambda: input(" 📝 Chute uma letra (ou 'dica'): ").strip().upper()
                )
            except (EOFError, KeyboardInterrupt):
                print("\n\n 👋 Jogo encerrado pelo usuário.")
                self.audio.parar()
                return

            # Validação da entrada
            if not palpite:
                print(" ⚠️  Digite algo!")
                await asyncio.sleep(1)
                continue

            if palpite == "DICA":
                if self.dicas_usadas < self.max_dicas:
                    dica = self._dar_dica()
                    print(f" 💡 Dica: {dica}")
                    self.audio.disparar_efeito(Efeito.DICA)
                    await asyncio.sleep(1.2)
                else:
                    print(" ⚠️  Você já usou todas as dicas disponíveis!")
                    await asyncio.sleep(1)
                continue

            if len(palpite) != 1:
                print(" ⚠️  Digite apenas UMA letra!")
                await asyncio.sleep(1)
                continue

            if not palpite.isalpha():
                print(" ⚠️  Digite apenas letras!")
                await asyncio.sleep(1)
                continue

            if palpite in self.letras_descobertas or palpite in self.letras_erradas:
                print(f" ⚠️  Você já tentou '{palpite}'!")
                await asyncio.sleep(1)
                continue

            # Processar palpite
            if palpite in self.palavra_secreta:
                self.letras_descobertas.add(palpite)
                print(f" ✨ Letra correta! {palpite}")
                self.audio.disparar_efeito(Efeito.ACERTO)
                await asyncio.sleep(0.5)
                
                # Verificar vitória
                if self._verificar_vitoria():
                    self.exibir_painel()
                    print("\n 🎉 VOCÊ VENCEU! Parabéns!")
                    print(f"\n 🏆 A palavra era: {self.palavra_secreta}")
                    self.audio.disparar_efeito(Efeito.VITORIA)
                    await asyncio.sleep(2)
                    return
            else:
                self.letras_erradas.add(palpite)
                self.tentativas_restantes -= 1
                print(f" ❌ Letra '{palpite}' não está na palavra!")
                self.audio.disparar_efeito(Efeito.ERRO)
                await asyncio.sleep(0.5)

        # Fim de jogo (Derrota)
        self.exibir_painel()
        print(f"\n 👻 GAME OVER! Você perdeu!")
        print(f"\n 🎯 A palavra era: {self.palavra_secreta}")
        self.audio.disparar_efeito(Efeito.DERROTA)
        await asyncio.sleep(2)

    def _dar_dica(self):
        self.dicas_usadas += 1
        alternativas = [letra for letra in set(self.palavra_secreta) if letra not in self.letras_descobertas]
        dica = random.choice(alternativas) if alternativas else "nenhuma letra restante"
        return f"A palavra contém a letra '{dica}'" if alternativas else "Não há mais letras para sugerir."

    def _verificar_vitoria(self):
        """Verifica se o jogador venceu"""
        return all(letra in self.letras_descobertas for letra in self.palavra_secreta)

async def main():
    """Função principal do jogo"""
    try:
        while True:
            # Criar engine de áudio antes da tela inicial para tocar música de boas-vindas
            debug_audio_state()
            audio = AudioEngine()
            tarefa_audio = None
            if AUDIO_DISPONIVEL:
                tarefa_audio = asyncio.create_task(audio.tocar_musica_fundo())

            # Mensagem inicial
            print("\n" + "="*50)
            print("   🎮 BEM-VINDO AO JOGO DA FORCA 🎮")
            print("="*50)
            print("\n ℹ️  Áudio:", "✅ Ativado" if AUDIO_DISPONIVEL else "❌ Desativado (sem winsound)")
            if AUDIO_DISPONIVEL:
                print(" 🎵 Música de boas-vindas: tocando na tela inicial")
            print(" 💻 Plataforma:", PLATAFORMA)
            print(" 🐍 Python:", f"{sys.version_info.major}.{sys.version_info.minor}")
            print("\n Pressione ENTER para começar...")

            loop = asyncio.get_event_loop()
            await loop.run_in_executor(None, lambda: input())

            # Efeito de início de partida
            if AUDIO_DISPONIVEL:
                audio.disparar_efeito(Efeito.INICIO)

            # Criar jogo
            jogo = JogoForca(audio=audio)

            # Efeito de início de partida
            if AUDIO_DISPONIVEL:
                audio.disparar_efeito(Efeito.INICIO)

            # Executar jogo
            await jogo.rodar_loop_principal()
            
            # Parar áudio
            audio.parar()
            if tarefa_audio and not tarefa_audio.done():
                tarefa_audio.cancel()
                try:
                    await tarefa_audio
                except asyncio.CancelledError:
                    pass
            
            # Pergunta se quer jogar novamente
            print("\n\n Deseja jogar novamente? (s/n): ", end="", flush=True)
            resposta = input().strip().lower()
            if resposta != 's':
                print("\n 👋 Obrigado por jogar! Até logo!")
                break

    except KeyboardInterrupt:
        print("\n\n 👋 Jogo encerrado pelo usuário.")
        sys.exit(0)
    except Exception as e:
        print(f"\n ❌ Erro: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

def main_sync():
    """Wrapper síncrono para executar o jogo"""
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n\n 👋 Jogo encerrado.")
        sys.exit(0)

if __name__ == "__main__":
    main_sync()
