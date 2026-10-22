#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Setup do Jogo da Forca
Executa configurações iniciais e verificações
"""

import sys
import os
import subprocess

def verificar_python():
    """Verifica versão do Python"""
    print("=" * 50)
    print("  VERIFICAÇÃO DO SISTEMA")
    print("=" * 50)
    print()
    
    version = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    print(f"Versão Python: {version}")
    
    if sys.version_info < (3, 8):
        print("❌ ERRO: Python 3.8+ é necessário!")
        return False
    
    print("✓ Python válido")
    return True

def verificar_modulos():
    """Verifica módulos necessários"""
    print("\nMódulos necessários:")
    
    modulos = {
        'asyncio': 'Asyncio (programação assíncrona)',
        'random': 'Random (números aleatórios)',
        'enum': 'Enum (enumerações)',
    }
    
    ok = True
    for modulo, descricao in modulos.items():
        try:
            __import__(modulo)
            print(f"  ✓ {descricao}")
        except ImportError:
            print(f"  ❌ {descricao}")
            ok = False
    
    return ok

def verificar_audio():
    """Verifica suporte a áudio"""
    print("\nSuporte a áudio:")
    
    if sys.platform == "win32":
        try:
            import winsound
            print("  ✓ Winsound (Windows) - Áudio ATIVADO")
            return True
        except ImportError:
            print("  ⚠️  Winsound não disponível - Áudio DESATIVADO")
            return False
    else:
        print(f"  ⚠️  Plataforma {sys.platform} - Áudio DESATIVADO")
        return False

def criar_atalhos():
    """Cria atalhos úteis"""
    print("\nCriando atalhos...")
    
    if sys.platform == "win32":
        # Criar run.bat
        run_bat = """@echo off
python "%~dp0script.py"
pause
"""
        with open("run.bat", "w", encoding="utf-8") as f:
            f.write(run_bat)
        print("  ✓ run.bat criado")

def main():
    """Função principal"""
    print("\n" + "=" * 50)
    print("  SETUP - JOGO DA FORCA")
    print("=" * 50 + "\n")
    
    # Verificações
    python_ok = verificar_python()
    modulos_ok = verificar_modulos()
    audio_ok = verificar_audio()
    
    # Resultado
    print("\n" + "=" * 50)
    if python_ok and modulos_ok:
        print("  ✓ SETUP CONCLUÍDO COM SUCESSO")
        print("=" * 50)
        print("\nVocê pode agora executar:")
        print("  python script.py")
        print("\nOu pressione ENTER para jogar agora...")
        input()
        
        # Executar jogo
        try:
            subprocess.run([sys.executable, "script.py"], check=True)
        except subprocess.CalledProcessError:
            print("Erro ao executar o jogo.")
            sys.exit(1)
    else:
        print("  ❌ SETUP FALHOU")
        print("=" * 50)
        print("\nVeja INSTALL.md para instruções de instalação.")
        sys.exit(1)

if __name__ == "__main__":
    main()
