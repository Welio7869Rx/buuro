#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Servidor web simples para rodar o Jogo da Forca HTML com lógica Python."""

import http.server
import json
import os
import random
import socketserver
import sys
import uuid
from urllib.parse import urlparse, parse_qs

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PORT = 8000
SESSIONS = {}

class GameSession:
    WORDS = [
        "PYTHON", "JAVASCRIPT", "PROGRAMACAO", "ALGORITMO", "VARIAVEL",
        "FUNCAO", "BIBLIOTECA", "FRAMEWORK", "DATABASE", "SERVIDOR",
        "INTERFACE", "SOFTWARE", "HARDWARE", "SISTEMA", "COMPUTADOR",
        "INTERNET", "NAVEGADOR", "FRONTEND", "BACKEND", "DESENVOLVEDOR",
        "COMPILADOR", "SEGURANCA", "LOGICA", "GITHUB", "CLOUD",
        "SCRIPT", "APLICACAO", "EXPERIENCIA", "DADOS", "AUTOMACAO",
        "DESIGN", "COMPONENTE", "TEMPLATES", "REUTILIZAVEL"
    ]

    def __init__(self):
        self.word = random.choice(self.WORDS)
        self.guessed_letters = set()
        self.wrong_letters = set()
        self.lives = 6
        self.hint_used = False
        self.message = "Bem-vindo ao Jogo da Forca!"

    def display_word(self):
        return " ".join(
            letter if letter in self.guessed_letters else "_"
            for letter in self.word
        )

    def has_won(self):
        return all(letter in self.guessed_letters for letter in self.word)

    def is_over(self):
        return self.lives <= 0 or self.has_won()

    def guess(self, letter: str):
        letter = letter.strip().upper()
        if self.is_over():
            self.message = "O jogo já terminou. Reinicie para jogar outra vez."
            return

        if len(letter) != 1 or not letter.isalpha():
            self.message = "Digite apenas uma letra válida."
            return

        if letter in self.guessed_letters or letter in self.wrong_letters:
            self.message = f"Você já tentou '{letter}'."
            return

        if letter in self.word:
            self.guessed_letters.add(letter)
            self.message = f"Boa! A letra '{letter}' está na palavra."
            if self.has_won():
                self.message = f"🎉 Você venceu! A palavra era {self.word}."
        else:
            self.wrong_letters.add(letter)
            self.lives -= 1
            self.message = f"Ops! A letra '{letter}' não está na palavra."
            if self.lives <= 0:
                self.message = f"👻 Game Over! A palavra era {self.word}."

    def hint(self):
        if self.hint_used:
            self.message = "A dica já foi usada nesta partida."
            return

        remaining = [l for l in set(self.word) if l not in self.guessed_letters]
        if not remaining:
            self.message = "Não há mais letras para sugerir."
            return

        self.hint_used = True
        hint_letter = random.choice(remaining)
        self.guessed_letters.add(hint_letter)
        self.message = f"💡 Dica: a letra '{hint_letter}' foi revelada."

    def state(self):
        return {
            "word_display": self.display_word(),
            "lives": self.lives,
            "wrong_letters": sorted(list(self.wrong_letters)),
            "hint_used": self.hint_used,
            "message": self.message,
            "game_over": self.is_over(),
            "victory": self.has_won(),
        }

class RequestHandler(http.server.SimpleHTTPRequestHandler):

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_POST(self):
        parsed = urlparse(self.path)
        if parsed.path.startswith("/api/"):
            self.handle_api(parsed.path)
        else:
            super().do_POST()

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path.startswith("/api/"):
            self.handle_api(parsed.path)
        else:
            super().do_GET()

    def handle_api(self, path):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8") if length else ""
        data = {}
        if body:
            try:
                data = json.loads(body)
            except json.JSONDecodeError:
                pass

        if path == "/api/new_game":
            session_id = str(uuid.uuid4())
            SESSIONS[session_id] = GameSession()
            response = {"session_id": session_id}
            response.update(SESSIONS[session_id].state())
            self.send_json(response)
            return

        session_id = data.get("session_id") or self.get_session_id_from_query()
        session = SESSIONS.get(session_id)
        if not session:
            self.send_error(400, "Sessão inválida. Inicie um novo jogo.")
            return

        if path == "/api/guess":
            letter = (data.get("letter") or "").strip().upper()
            session.guess(letter)
            self.send_json(session.state())
            return

        if path == "/api/hint":
            session.hint()
            self.send_json(session.state())
            return

        if path == "/api/state":
            self.send_json(session.state())
            return

        self.send_error(404, "API não encontrada")

    def get_session_id_from_query(self):
        query = parse_qs(urlparse(self.path).query)
        values = query.get("session_id")
        return values[0] if values else None

    def send_json(self, obj):
        payload = json.dumps(obj, ensure_ascii=False).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

if __name__ == "__main__":
    os.chdir(ROOT_DIR)
    with socketserver.TCPServer(("", PORT), RequestHandler) as httpd:
        print(f"Servidor iniciado em http://localhost:{PORT}")
        print("Abra http://localhost:8000/html/index.html no navegador")
        httpd.serve_forever()
