# Teste simples de áudio para validar winsound/beep no sistema
import sys
import time
import threading

print("Teste de áudio - iniciando")
print("Plataforma:", sys.platform)

try:
    import winsound
    print("winsound disponível: Sim")
except Exception as e:
    print("winsound disponível: Não (erro ao importar)", e)
    winsound = None


def sync_beep(freq, dur):
    if winsound:
        print(f"Beep síncrono: {freq}Hz por {dur}ms")
        winsound.Beep(freq, dur)
    else:
        print("Beep síncrono: fallback - não há winsound")


def thread_beep(freq, dur):
    def _b():
        sync_beep(freq, dur)
    t = threading.Thread(target=_b)
    t.start()
    return t

print("Executando beep síncrono...")
sync_beep(440, 300)
print("Executando beep em thread (não bloqueante)...")
t = thread_beep(523, 300)
print("Esperando thread terminar...")
if t:
    t.join()
print("Teste finalizado")
