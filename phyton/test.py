#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Teste Rápido do Jogo da Forca
Verifica se tudo está funcionando corretamente
"""

import sys
import os

def teste_python_version():
    """Verifica versão do Python"""
    print(f"✓ Versão Python: {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}")
    if sys.version_info < (3, 8):
        print("✗ ERRO: Python 3.8+ é necessário!")
        return False
    return True

def teste_imports():
    """Testa importação de módulos"""
    try:
        import asyncio
        print("✓ asyncio disponível")
    except ImportError:
        print("✗ asyncio não disponível")
        return False
    
    try:
        import random
        print("✓ random disponível")
    except ImportError:
        print("✗ random não disponível")
        return False
    
    return True

def teste_audio():
    """Testa disponibilidade de áudio"""
    if sys.platform == "win32":
        try:
            import winsound
            print("✓ winsound disponível (áudio ativado)")
            return True
        except ImportError:
            print("⚠ winsound não disponível (áudio desativado)")
            return False
    else:
        print("⚠ winsound não disponível em " + sys.platform)
        return False

def teste_arquivo_script():
    """Verifica se o script.py existe"""
    caminho = os.path.join(os.path.dirname(__file__), "script.py")
    if os.path.exists(caminho):
        print(f"✓ script.py encontrado")
        return True
    else:
        print("✗ script.py não encontrado!")
        return False

def main():
    print("\n" + "="*50)
    print("  🧪 TESTE DE FUNCIONALIDADE")
    print("="*50 + "\n")
    
    testes = [
        ("Python Version", teste_python_version),
        ("Módulos Necessários", teste_imports),
        ("Áudio", teste_audio),
        ("Arquivo Script", teste_arquivo_script),
    ]
    
    resultados = []
    for nome, teste in testes:
        print(f"\n{nome}:")
        try:
            resultado = teste()
            resultados.append(resultado)
        except Exception as e:
            print(f"✗ Erro: {e}")
            resultados.append(False)
    
    # Resumo
    print("\n" + "="*50)
    if all(resultados):
        print("  ✓ TUDO OK! Pronto para jogar.")
        print("="*50 + "\n")
        return 0
    else:
        print("  ✗ ALGUNS PROBLEMAS ENCONTRADOS")
        print("="*50 + "\n")
        print("Veja INSTALL.md para ajuda")
        return 1

if __name__ == "__main__":
    sys.exit(main())
