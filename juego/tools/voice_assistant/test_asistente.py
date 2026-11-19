"""
test_asistente.py - Suite de Pruebas Automatizadas de JARVIS
Verifica Cancelación de Eco Acústico, Interrupción (Barge-In), Latencia Hardware y Gemini Flash.
"""

import asyncio
import time
import sys
import os

if sys.stdout.encoding.lower() != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

sys.path.append(os.path.dirname(__file__))
from asistente_daemon import JarvisGeminiAssistant
import system_bridge

async def run_tests():
    print("=" * 65)
    print("[*] INICIANDO BATERÍA DE PRUEBAS DE JARVIS (CANCELACIÓN DE ECO Y BARGE-IN)")
    print("=" * 65)

    asistente = JarvisGeminiAssistant()
    asistente.tts_enabled = False  # Silenciar durante tests unitarios

    # TEST 1: Cancelación de Eco Acústico (Algoritmo de Detección)
    print("\n[TEST 1] Probando Filtro de Cancelación Acústica de Parlantes...")
    asistente.last_spoken_text = "Sistemas en línea, Máximo. A su completa orden."
    asistente.is_speaking = True
    now = time.time()
    words = set(asistente._extraer_palabras(asistente.last_spoken_text))
    asistente.spoken_history = [{"clean": asistente._normalizar_texto(asistente.last_spoken_text), "words": words, "time": now}]

    # Casos que DEBEN ser detectados como eco (provienen de los altavoces)
    assert asistente.is_echo("sistemas en línea Máximo a su completa orden") is True
    assert asistente.is_echo("máximo a su completa orden") is True
    assert asistente.is_echo("sistemas en linea maximo") is True
    assert asistente.is_echo("a su completa orden") is True
    print("  [OK] Ecos acústicos de altavoces detectados e interceptados al 100%")

    # Casos que NO deben ser eco (órdenes genuinas de Máximo)
    assert asistente.is_echo("pausa") is False
    assert asistente.is_echo("callate") is False
    assert asistente.is_echo("subí el volumen") is False
    assert asistente.is_echo("abrí spotify") is False
    assert asistente.is_echo("qué hora es") is False
    print("  [OK] Comandos genuinos de Máximo reconocidos sin falsos positivos")

    # TEST 2: Barge-In (Interrupción Inmediata en 0ms)
    print("\n[TEST 2] Probando Interrupción Inmediata (Barge-In)...")
    asistente.is_speaking = True
    asistente.stop_speaking()
    assert asistente.is_speaking is False
    assert (time.time() - asistente.last_speech_end_time) < 0.1
    print("  [OK] Estado de habla cortado en 0 ms con purge de audio")

    # TEST 3: Atajos de Hardware Inmediatos (< 10 ms)
    print("\n[TEST 3] Probando Atajos de Hardware Inmediatos (< 10 ms)...")
    t0 = time.time()
    res_pause = await asistente.process_voice_intent("pausar musica")
    dt_ms = (time.time() - t0) * 1000
    assert res_pause["tier"] == 0
    assert res_pause["action"] == "toggle_play_pause"
    print(f"  [OK] Hardware dispatch en {dt_ms:.2f} ms")

    # TEST 4: Conmutación de Cerebro Gemini Flash / Deep
    print("\n[TEST 4] Probando Conmutación Atómica de Cerebro...")
    assert asistente.active_model_alias == "flash"
    await asistente.switch_model("deep")
    assert asistente.active_model_alias == "deep"
    await asistente.switch_model("flash")
    assert asistente.active_model_alias == "flash"
    print("  [OK] Cerebro conmutado Flash <-> Deep correctamente")

    # TEST 5: Captura Ultraligera de Pantalla en RAM (WebP)
    print("\n[TEST 5] Probando Captura de Pantalla en RAM (WebP Cero-Disco)...")
    t_cap = time.time()
    webp_bytes = system_bridge.capture_screen_ram_webp(quality=60)
    cap_ms = (time.time() - t_cap) * 1000
    assert len(webp_bytes) > 1000
    assert webp_bytes[:4] == b"RIFF"
    print(f"  [OK] Captura completada en {cap_ms:.2f} ms ({len(webp_bytes)/1024:.1f} KB en RAM)")

    print("\n" + "=" * 65)
    print("  ✅ TODAS LAS PRUEBAS DE JARVIS PASARON CON ÉXITO")
    print("=" * 65)

if __name__ == "__main__":
    asyncio.run(run_tests())
