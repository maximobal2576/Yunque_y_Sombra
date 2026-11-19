"""
asistente_daemon.py - JARVIS MK-III (Voz Neuronal Masculina Natural + Acumulador Inteligente + Control Físico Total)
Voz Neuronal Masculina en RAM (edge-tts + pygame mixer) + OneCore Raúl Fallback + Barge-In 0ms
"""

import asyncio
import json
import os
import sys
import io
import time
import re
import base64
import threading
import urllib.request
import urllib.error
import winreg
import webbrowser
import win32com.client
from typing import Dict, Any, Optional, List

os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"
import pygame
import edge_tts
import speech_recognition as sr
import system_bridge

if sys.stdout.encoding.lower() != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass


class JarvisGeminiAssistant:
    def __init__(self, config_path: Optional[str] = None):
        if config_path is None:
            config_path = os.path.join(os.path.dirname(__file__), "config.json")
        self.config_path = config_path
        self.config = self._cargar_config()
        self.gemini_key = self._obtener_gemini_key()

        # Estado del sistema
        self.active_model_alias: str = self.config.get("active_model", "flash")
        self._model_lock = asyncio.Lock()
        self.is_running: bool = False
        self.is_speaking: bool = False
        self.last_speech_end_time: float = 0.0
        self.last_spoken_text: str = ""
        self.spoken_history: List[Dict[str, Any]] = []
        self.loop: Optional[asyncio.AbstractEventLoop] = None
        self.stop_listening = None

        # Voces Neuronales Masculinas Naturales
        self.voices_catalog = {
            "jarvis": "es-ES-AlvaroNeural",     # Timbre profundo y elegante estilo doblaje de JARVIS
            "argentina": "es-AR-TomasNeural",   # Voz masculina argentina natural (Tomás)
            "latina": "es-MX-JorgeNeural"       # Voz masculina neutra/latina profunda (Jorge)
        }
        self.voice_id: str = self.config.get("audio", {}).get("voice_id", "es-ES-AlvaroNeural")
        self.voice_rate: str = "+12%"
        self.voice_pitch: str = "-3Hz"
        self._tts_task: Optional[asyncio.Task] = None

        # Acumulador de voz anti-corte y control de tarea única en vuelo
        self._speech_buffer: List[str] = []
        self._debounce_task: Optional[asyncio.Task] = None
        self._active_intent_task: Optional[asyncio.Task] = None

        # Historial conversacional (10 turnos)
        self.conversation_history: List[Dict[str, Any]] = []

        # Reconocedor de voz calibrado
        self.recognizer = sr.Recognizer()
        self.recognizer.energy_threshold = self.config.get("audio", {}).get("energy_threshold", 300)
        self.recognizer.dynamic_energy_threshold = True
        self.recognizer.non_speaking_duration = self.config.get("audio", {}).get("non_speaking_duration", 0.35)
        self.recognizer.pause_threshold = self.config.get("audio", {}).get("pause_threshold", 0.65)
        self.language = self.config.get("audio", {}).get("language", "es-AR")

        # Palabra clave obligatoria ("Jimin")
        self.require_wakeword: bool = self.config.get("require_wakeword", True)
        self.wakewords: List[str] = self.config.get("wakewords", ["jimin", "jimín", "yimin", "gimin", "ximin"])

        # Inicializar motor de audio en RAM (Pygame Mixer) + Fallback OneCore Masculino (Microsoft Raúl)
        self.neural_tts_ready = False
        try:
            pygame.mixer.init(frequency=24000, size=-16, channels=1, buffer=512)
            self.neural_tts_ready = True
        except Exception as e:
            print(f"[AVISO MIXER]: {e}")

        self.tts_enabled = True
        self.speaker = None
        try:
            self.speaker = win32com.client.Dispatch("SAPI.SpVoice")
            # Forzar voz masculina Microsoft Raúl de OneCore en lugar de Sabina femenina
            cat = win32com.client.Dispatch("SAPI.SpObjectTokenCategory")
            cat.SetId(r"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech_OneCore\Voices", False)
            for token in cat.EnumerateTokens():
                desc = token.GetDescription()
                if "Raul" in desc or "Raúl" in desc or "Pablo" in desc:
                    self.speaker.Voice = token
                    break
            self.speaker.Rate = 1
            self.speaker.Volume = 100
        except Exception:
            pass

    def _cargar_config(self) -> Dict[str, Any]:
        if os.path.exists(self.config_path):
            with open(self.config_path, "r", encoding="utf-8") as f:
                return json.load(f)
        return {
            "active_provider": "gemini",
            "active_model": "flash",
            "models": {
                "flash": {"model_id": "gemini-flash-lite-latest", "name": "Google Gemini Flash"},
                "deep": {"model_id": "gemini-pro-latest", "name": "Google Gemini Pro"}
            },
            "audio": {
                "energy_threshold": 300,
                "pause_threshold": 0.95,
                "non_speaking_duration": 0.45,
                "language": "es-AR",
                "voice_id": "es-ES-AlvaroNeural"
            }
        }

    def _obtener_gemini_key(self) -> str:
        key = os.environ.get("GEMINI_API_KEY", "").strip()
        if not key:
            try:
                reg_key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Environment")
                val, _ = winreg.QueryValueEx(reg_key, "GEMINI_API_KEY")
                key = str(val).strip()
            except Exception:
                pass
        for ch in ["(", ")", "tu_clave_aca", '"', "'", " "]:
            key = key.replace(ch, "")
        return key

    def _registrar_telemetria(self, user_phrase: str, action: str, reply: str, latency_ms: float, success: bool, error: str = "") -> None:
        """Registra cada interacción atómicamente en telemetria.jsonl para auditoría y mejora continua cada 10 min."""
        try:
            log_dir = os.path.join(os.path.dirname(__file__), "logs")
            os.makedirs(log_dir, exist_ok=True)
            log_file = os.path.join(log_dir, "telemetria.jsonl")
            entry = {
                "timestamp": time.time(),
                "fecha": time.strftime("%Y-%m-%d %H:%M:%S"),
                "assistant": "Jimin",
                "phrase": user_phrase,
                "action": action,
                "reply": reply[:160] if reply else "",
                "latency_ms": round(latency_ms, 2),
                "success": success,
                "error": error
            }
            with open(log_file, "a", encoding="utf-8") as f:
                f.write(json.dumps(entry, ensure_ascii=False) + "\n")
        except Exception:
            pass

    def stop_speaking(self) -> None:
        """Corta la voz de JARVIS en 0 ms (tanto el mixer neuronal como el fallback SAPI)."""
        if self._tts_task and not self._tts_task.done():
            self._tts_task.cancel()
        if self.neural_tts_ready:
            try:
                if pygame.mixer.music.get_busy():
                    pygame.mixer.music.stop()
            except Exception:
                pass
        if self.speaker:
            try:
                self.speaker.Speak("", 2)
            except Exception:
                pass
        if self.is_speaking:
            self.is_speaking = False
            self.last_speech_end_time = time.time()

    @staticmethod
    def _normalizar_texto(text: str) -> str:
        t = text.lower()
        reemplazos = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'}
        for k, v in reemplazos.items():
            t = t.replace(k, v)
        t = re.sub(r'[^\w\s]', '', t)
        return ' '.join(t.split())

    def _extraer_palabras(self, text: str) -> List[str]:
        norm = self._normalizar_texto(text)
        stopwords = {"el", "la", "los", "las", "de", "en", "y", "a", "que", "es", "un", "una", "por", "con", "no", "si", "su", "al", "lo", "como", "mas", "pero", "sus", "le", "ya", "o", "este", "ha", "me", "sin", "sobre", "mi", "tu", "te"}
        return [w for w in norm.split() if len(w) > 2 and w not in stopwords]

    def is_echo(self, heard_phrase: str) -> bool:
        if not self.spoken_history:
            return False

        now = time.time()
        phrase_norm = self._normalizar_texto(heard_phrase)
        if not phrase_norm:
            return True

        phrase_words = set(self._extraer_palabras(heard_phrase))

        if self.is_speaking:
            for item in reversed(self.spoken_history):
                hist_norm = item["clean"]
                if phrase_norm in hist_norm or hist_norm in phrase_norm:
                    return True
                hist_words = item["words"]
                if phrase_words and hist_words:
                    overlap = len(phrase_words.intersection(hist_words)) / max(len(phrase_words), 1)
                    if overlap >= 0.30:
                        return True
            if not phrase_words and len(phrase_norm) < 12:
                return True

        time_since_speech_end = now - self.last_speech_end_time
        if time_since_speech_end < 6.5:
            for item in reversed(self.spoken_history):
                if now - item["time"] > 15.0:
                    continue
                hist_norm = item["clean"]
                if phrase_norm in hist_norm or hist_norm in phrase_norm:
                    return True
                hist_words = item["words"]
                if phrase_words and hist_words:
                    overlap = len(phrase_words.intersection(hist_words)) / max(len(phrase_words), 1)
                    if len(phrase_words) >= 2 and overlap >= 0.35:
                        return True
                    if len(phrase_words) == 1 and overlap >= 0.8 and time_since_speech_end < 2.0:
                        return True

        return False

    async def _synthesize_and_play_neural(self, clean_text: str) -> None:
        """Genera audio neuronal masculino en memoria RAM y lo reproduce sin usar disco."""
        try:
            self.is_speaking = True
            comm = edge_tts.Communicate(
                clean_text,
                voice=self.voice_id,
                rate=self.voice_rate,
                pitch=self.voice_pitch
            )
            mp3_buf = io.BytesIO()
            async for chunk in comm.stream():
                if chunk["type"] == "audio":
                    mp3_buf.write(chunk["data"])

            mp3_buf.seek(0)
            if mp3_buf.getbuffer().nbytes > 0 and self.neural_tts_ready:
                pygame.mixer.music.load(mp3_buf, "mp3")
                pygame.mixer.music.play()
            else:
                raise RuntimeError("Buffer neuronal vacío")
        except asyncio.CancelledError:
            pass
        except Exception:
            # Fallback inmediato a voz masculina OneCore (Microsoft Raúl)
            if self.speaker:
                try:
                    self.is_speaking = True
                    self.speaker.Speak(clean_text, 1)
                except Exception:
                    self.is_speaking = False

    def speak(self, text: str) -> None:
        clean = re.sub(r'\[?ACCION:[^\]]+\]?', '', text, flags=re.IGNORECASE)
        clean = re.sub(r'[*#_`~>\[\]]', '', clean)
        clean = ' '.join(clean.split()).strip()

        if not clean:
            return

        self.last_spoken_text = clean
        now = time.time()
        words = set(self._extraer_palabras(clean))
        self.spoken_history.append({"clean": self._normalizar_texto(clean), "words": words, "time": now})
        self.spoken_history = [item for item in self.spoken_history if now - item["time"] < 15.0][-10:]

        print(f"\n🤖 [JIMIN]: {clean}")
        self.stop_speaking()

        if self.loop and self.loop.is_running():
            self._tts_task = asyncio.run_coroutine_threadsafe(self._synthesize_and_play_neural(clean), self.loop)
        elif self.speaker:
            self.is_speaking = True
            self.speaker.Speak(clean, 1)

    async def switch_model(self, target_model: str) -> str:
        async with self._model_lock:
            target_clean = target_model.lower().strip()
            models_dict = self.config.get("models", {})
            if target_clean in models_dict:
                self.active_model_alias = target_clean
                model_name = models_dict[target_clean]["name"]
                msg = f"Cerebro conmutado a: {model_name}"
                self.speak(msg)
                return msg
            else:
                msg = f"El modo '{target_model}' no está registrado."
                self.speak(msg)
                return msg

    def _consultar_vision(self, prompt_texto: str, webp_bytes: bytes) -> str:
        if not self.gemini_key:
            return "No se ha detectado la clave de Gemini para inspección visual."

        b64_img = base64.b64encode(webp_bytes).decode("utf-8")
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-lite-latest:generateContent?key={self.gemini_key}"
        tel = system_bridge.get_system_telemetry()

        payload = {
            "system_instruction": {
                "parts": [{
                    "text": (
                        "Eres Jimin, el sistema operativo y asistente inteligente de Máximo. "
                        f"Estás viendo en vivo una captura real de su pantalla (Ventana activa: '{tel['ventana_activa']}'). "
                        "Responde SIEMPRE en español fluido, con tono inteligente, leal y resolutivo en 1 a 2 oraciones directas. "
                        "Si además de responder necesitas desplazar la pantalla, adjunta [ACCION:SCROLL_UP] o [ACCION:SCROLL_DOWN] al final."
                    )
                }]
            },
            "contents": [
                {
                    "parts": [
                        {"text": f"Orden o consulta de Máximo: '{prompt_texto}'"},
                        {"inline_data": {"mime_type": "image/webp", "data": b64_img}}
                    ]
                }
            ],
            "generationConfig": {
                "temperature": 0.35,
                "maxOutputTokens": 200
            }
        }

        for attempt in range(2):
            try:
                req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers={"Content-Type": "application/json"}, method="POST")
                with urllib.request.urlopen(req, timeout=11) as resp:
                    data = json.loads(resp.read().decode("utf-8"))
                    reply = data["candidates"][0]["content"]["parts"][0]["text"].strip()
                    self.conversation_history.append({"role": "user", "parts": [{"text": f"[Viendo pantalla] {prompt_texto}"}]})
                    self.conversation_history.append({"role": "model", "parts": [{"text": reply}]})
                    return reply
            except Exception:
                if attempt == 0:
                    time.sleep(0.5)
                    continue
                break
        return "Tengo su pantalla en vista, Máximo, aunque el servidor óptico demoró en responder."

    def _consultar_gemini(self, prompt: str, extra_context: str = "") -> str:
        if not self.gemini_key:
            return "La clave de Gemini no se encuentra configurada en el sistema."

        model_id = self.config.get("models", {}).get(self.active_model_alias, {}).get("model_id", "gemini-flash-lite-latest")
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_id}:generateContent?key={self.gemini_key}"

        tel = system_bridge.get_system_telemetry()
        inv = system_bridge.get_project_files_inventory()
        cargador_str = "Conectado a CA" if tel["conectado_corriente"] else "En batería"

        system_instruction = (
            "Eres Jimin, el asistente personal y ejecutivo con control físico real sobre el Windows de Máximo: "
            "tu nombre es Jimin, eres inteligente, leal, sagaz, resolutivo y tienes una relación cercana y de complicidad con Máximo. Responde SIEMPRE en español en máximo 1 o 2 oraciones breves.\n\n"
            f"TELEMETRÍA EN VIVO DE LA PC DE MÁXIMO:\n"
            f"- Hora: {tel['hora']} | Batería: {tel['bateria_porcentaje']}% ({cargador_str}) | RAM: {tel['ram_porcentaje']}%\n"
            f"- Ventana activa en primer plano: '{tel['ventana_activa']}'\n"
            f"- Archivos reales en sus carpetas: {inv}\n"
            f"{extra_context}\n\n"
            "REGLA DE ORO (PROHIBIDO FINGIR ACCIONES):\n"
            "Cuando Máximo te pida hacer algo en su PC (subir/bajar pantalla, escribir, apretar una tecla, abrir un archivo o programa, ejecutar un comando o mirar la pantalla), "
            "DEBES incluir obligatoriamente la etiqueta [ACCION:...] correspondiente al final de tu respuesta para que el motor físico la ejecute.\n"
            "Etiquetas de hardware y sistema disponibles:\n"
            "- [ACCION:SCROLL_UP] -> Sube / desplaza hacia arriba la pantalla o documento actual.\n"
            "- [ACCION:SCROLL_DOWN] -> Baja / desplaza hacia abajo la pantalla o documento actual.\n"
            "- [ACCION:CLICK:left] | [ACCION:CLICK:right] | [ACCION:CLICK:double] -> Hace clic donde está el mouse.\n"
            "- [ACCION:TYPE:texto exacto] -> Escribe el texto indicado con el teclado directamente en la ventana activa.\n"
            "- [ACCION:KEY:nombre] -> Presiona una tecla o atajo: enter, escape, borrar, copiar, pegar, deshacer, guardar, cerrar_ventana, f5.\n"
            "- [ACCION:POWERSHELL:comando] -> Ejecuta cualquier comando real de PowerShell (ej. crear carpeta, listar procesos, abrir ruta).\n"
            "- [ACCION:READ_SCREEN] -> Captura y lee visualmente la pantalla actual.\n"
            "- [ACCION:OPEN_FILE:nombre] -> Abre en Windows un archivo o carpeta del proyecto (ej. [ACCION:OPEN_FILE:informe] o [ACCION:OPEN_FILE:documentacion]).\n"
            "- [ACCION:READ_FILE:nombre] -> Lee el contenido interno de un archivo Word o código.\n"
            "- [ACCION:OPEN_APP:alias] -> Abre una app: spotify, godot, terminal, word, freecad, arduino, calculadora, explorador, navegador, bloc de notas, administrador de tareas.\n"
            "- [ACCION:CLOSE_APP:alias] -> Cierra una app.\n"
            "- [ACCION:SEARCH_GOOGLE:consulta] | [ACCION:SEARCH_YOUTUBE:consulta] | [ACCION:OPEN_URL:url]\n"
            "- [ACCION:MINIMIZE_ALL] | [ACCION:SWITCH_WINDOW]\n"
            "- [ACCION:TOGGLE_PLAY_PAUSE], [ACCION:NEXT_TRACK], [ACCION:PREV_TRACK], [ACCION:MUTE], [ACCION:VOL_UP], [ACCION:VOL_DOWN], [ACCION:SHUTDOWN]"
        )

        contents = []
        for turn in self.conversation_history[-20:]:
            contents.append(turn)
        contents.append({"role": "user", "parts": [{"text": prompt}]})

        payload = {
            "system_instruction": {"parts": [{"text": system_instruction}]},
            "contents": contents,
            "generationConfig": {
                "temperature": 0.35,
                "maxOutputTokens": 80
            }
        }

        for attempt in range(2):
            try:
                req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers={"Content-Type": "application/json"}, method="POST")
                with urllib.request.urlopen(req, timeout=9) as resp:
                    data = json.loads(resp.read().decode("utf-8"))
                    reply = data["candidates"][0]["content"]["parts"][0]["text"].strip()

                    self.conversation_history.append({"role": "user", "parts": [{"text": prompt}]})
                    self.conversation_history.append({"role": "model", "parts": [{"text": reply}]})
                    return reply
            except urllib.error.HTTPError as e:
                if e.code in [503, 429] and attempt == 0:
                    time.sleep(0.5)
                    continue
                break
            except Exception:
                if attempt == 0:
                    time.sleep(0.4)
                    continue
                break

        return "Comprendo, Máximo. Hubo una breve fluctuación en el enlace, pero sigo completamente a su orden."

    async def _ejecutar_vision_directa(self, user_phrase: str) -> Dict[str, Any]:
        print("  👁️ [VISIÓN JARVIS]: Capturando pantalla en RAM y analizando...")
        webp_bytes = system_bridge.capture_screen_ram_webp()
        loop = asyncio.get_event_loop()
        vision_reply = await loop.run_in_executor(None, self._consultar_vision, user_phrase, webp_bytes)
        if re.search(r'\[?ACCION:SCROLL_?UP\]?', vision_reply, re.IGNORECASE):
            system_bridge.scroll_screen("up", notches=8)
        if re.search(r'\[?ACCION:SCROLL_?DOWN\]?', vision_reply, re.IGNORECASE):
            system_bridge.scroll_screen("down", notches=8)
        self.speak(vision_reply)
        return {"tier": 3, "action": "screen_vision", "reply": vision_reply}

    async def _process_voice_intent_impl(self, user_phrase: str) -> Dict[str, Any]:
        phrase = user_phrase.lower().strip()

        # ----------------------------------------------------------------------
        # FILTRO ESTRICTO DE WAKE WORD ("Jimin"):
        # Si Máximo no pronuncia explícitamente "Jimin", se descarta silenciosamente.
        # ----------------------------------------------------------------------
        has_wakeword = any(w in phrase for w in self.wakewords)
        if self.require_wakeword and not has_wakeword:
            print(f"  🔇 [IGNORADO]: No se llamó a 'Jimin' en: '{user_phrase}'")
            return {"tier": 0, "action": "ignored_no_wakeword", "reply": ""}

        # Limpiar la palabra clave para extraer la orden pura
        phrase_clean = phrase
        for w in self.wakewords:
            phrase_clean = re.sub(rf'\b{w}\b', '', phrase_clean, flags=re.IGNORECASE)
        # Limpiar conectores de saludo previos
        for greet in ["hola", "che", "buenas"]:
            if phrase_clean.startswith(greet + " "):
                phrase_clean = phrase_clean[len(greet)+1:].strip()
            elif phrase_clean.endswith(" " + greet):
                phrase_clean = phrase_clean[:-len(greet)-1].strip()
        phrase_clean = ' '.join(phrase_clean.split()).strip()

        # Saludo y reconocimiento si solo fue llamado por su nombre
        if not phrase_clean or phrase_clean in ["estas ahi", "estás ahí", "estas listo", "estás listo", "que tal", "qué tal", "estas", "estás"]:
            reply = "A tu completa disposición, Máximo. ¿Qué necesitas que hagamos?"
            self.speak(reply)
            return {"tier": 0, "action": "wake_jimin", "reply": reply}

        # La frase a procesar por hardware o Gemini es la orden limpia
        phrase = phrase_clean

        # Cambio de acento de voz masculina a pedido
        if any(w in phrase for w in ["voz argentina", "acento argentino", "voz de tomas"]):
            self.voice_id = self.voices_catalog["argentina"]
            self.speak("Voz neuronal masculina conmutada a Tomás de Argentina, Máximo.")
            return {"tier": 0, "action": "change_voice"}
        if any(w in phrase for w in ["voz española", "voz de jarvis", "voz original"]):
            self.voice_id = self.voices_catalog["jarvis"]
            self.speak("Timbre clásico de Jarvis restablecido, señor.")
            return {"tier": 0, "action": "change_voice"}
        if any(w in phrase for w in ["voz latina", "voz mexicana", "voz de jorge"]):
            self.voice_id = self.voices_catalog["latina"]
            self.speak("Voz neuronal masculina conmutada a Jorge, Máximo.")
            return {"tier": 0, "action": "change_voice"}

        # ======================================================================
        # 1. ATAJOS FÍSICOS INMEDIATOS (< 10 ms: SCROLL, TECLADO, MULTIMEDIA)
        # ======================================================================
        if any(w in phrase for w in [
            "subi la pantalla", "subí la pantalla", "subir la pantalla", "subi un poco la pantalla",
            "subí un poco la pantalla", "subas un poco la pantalla", "scrollea arriba", "scrolleá arriba",
            "desplaza arriba", "desplazá arriba", "mas arriba", "más arriba", "subi un poco", "subí un poco"
        ]):
            system_bridge.scroll_screen("up", notches=8)
            self.speak("Subiendo la vista en pantalla, Máximo.")
            return {"tier": 0, "action": "scroll_up"}

        if any(w in phrase for w in [
            "baja la pantalla", "bajá la pantalla", "bajar la pantalla", "baja un poco la pantalla",
            "bajá un poco la pantalla", "bajes un poco la pantalla", "scrollea abajo", "scrolleá abajo",
            "desplaza abajo", "desplazá abajo", "mas abajo", "más abajo", "baja un poco", "bajá un poco", "segui bajando", "seguí bajando"
        ]):
            system_bridge.scroll_screen("down", notches=8)
            self.speak("Bajando la vista en pantalla, Máximo.")
            return {"tier": 0, "action": "scroll_down"}

        if any(w in phrase for w in ["pausa", "pausar", "pará la musica", "para la musica", "frena la musica", "dale play", "reanudá", "reproducir"]):
            system_bridge.toggle_play_pause()
            self.speak("Pausa conmutada, Máximo.")
            return {"tier": 0, "action": "toggle_play_pause"}

        if any(w in phrase for w in ["siguiente tema", "pasa tema", "pasa cancion", "siguiente canción", "next track"]):
            system_bridge.next_track()
            self.speak("Siguiente pista.")
            return {"tier": 0, "action": "next_track"}

        if any(w in phrase for w in ["cancion anterior", "tema anterior", "pista anterior"]):
            system_bridge.prev_track()
            self.speak("Pista anterior.")
            return {"tier": 0, "action": "prev_track"}

        if any(w in phrase for w in ["subí volumen", "subir volumen", "más volumen", "subile el volumen"]):
            system_bridge.volume_up(5)
            self.speak("Aumentando volumen.")
            return {"tier": 0, "action": "volume_up"}

        if any(w in phrase for w in ["bajá volumen", "bajar volumen", "menos volumen", "bajale el volumen"]):
            system_bridge.volume_down(5)
            self.speak("Disminuyendo volumen.")
            return {"tier": 0, "action": "volume_down"}

        if any(w in phrase for w in ["silencio", "mutea", "desmutea"]):
            system_bridge.toggle_mute()
            self.speak("Audio conmutado.")
            return {"tier": 0, "action": "toggle_mute"}

        if any(w in phrase for w in ["minimiza todo", "minimizá todo", "mostrar escritorio", "mostrame el escritorio", "limpia la pantalla"]):
            system_bridge.minimize_all_windows()
            self.speak("Escritorio despejado, Máximo.")
            return {"tier": 0, "action": "minimize_all"}

        if any(w in phrase for w in ["cambia de ventana", "cambiá de ventana", "otra ventana", "alt tab"]):
            system_bridge.switch_window()
            self.speak("Ventana conmutada.")
            return {"tier": 0, "action": "switch_window"}

        if any(w in phrase for w in ["modo pensar", "modo profundo", "activar pro"]):
            await self.switch_model("deep")
            return {"tier": 2, "action": "switch_model", "model": "deep"}

        if any(w in phrase for w in ["modo rapido", "modo flash", "cambiar a flash"]):
            await self.switch_model("flash")
            return {"tier": 2, "action": "switch_model", "model": "flash"}

        if any(w in phrase for w in ["cerrar llamada", "desactivar asistente", "cortar llamada", "chau jarvis", "apagate jarvis", "descansa jarvis"]):
            self.speak("Desconectando sistemas, Máximo. Siempre a su servicio.")
            await asyncio.sleep(2.5)
            self.is_running = False
            if self.stop_listening:
                try:
                    self.stop_listening(wait_for_stop=False)
                except Exception:
                    pass
            return {"tier": 0, "action": "shutdown"}

        # ======================================================================
        # 2. DETECTOR AUTOMÁTICO DE INTENCIÓN VISUAL
        # ======================================================================
        triggers_visuales = [
            "mira mi pantalla", "mirá mi pantalla", "lee la pantalla", "leé la pantalla",
            "mira esto", "mirá esto", "que ves", "qué ves", "que error", "qué error",
            "fijate aca", "fijate acá", "que esta haciendo", "qué está haciendo", "que esta modificando",
            "qué está modificando", "lee esto", "leé esto", "analiza la pantalla", "analizá la pantalla",
            "que dice ahi", "qué dice ahí", "que hay en la pantalla", "qué hay en la pantalla",
            "que devolucion", "qué devolución", "que respondio", "qué respondió", "que me dijo", "qué me dijo"
        ]
        if any(w in phrase for w in triggers_visuales):
            return await self._ejecutar_vision_directa(user_phrase)

        # ======================================================================
        # 3. CONTEXTO DE ARCHIVOS REALES DEL PROYECTO
        # ======================================================================
        extra_file_context = ""
        if any(w in phrase for w in ["informe", "carpeta de campo", "archivo", "documentacion", "documentación", "word", "componentes", "pinout", "agua", "sellado", "baston", "bastón", "traje"]):
            for kw in ["informe", "carpeta de campo", "configuracion.h", "centinela_v2.ino"]:
                if kw in phrase:
                    extra_file_context = system_bridge.read_project_file_snippet(kw, max_chars=2200)
                    break
            if not extra_file_context:
                extra_file_context = system_bridge.read_project_file_snippet("informe", max_chars=2200)

        # ======================================================================
        # 4. CONSULTA A GEMINI + EJECUCIÓN DE ACCIONES FÍSICAS
        # ======================================================================
        print(f"  ⚡ [GEMINI FLASH]: Procesando oración completa: '{user_phrase}'...")
        loop = asyncio.get_event_loop()
        ai_reply = await loop.run_in_executor(None, self._consultar_gemini, user_phrase, extra_file_context)

        if re.search(r'\[?ACCION:READ_?SCREEN\]?', ai_reply, re.IGNORECASE):
            return await self._ejecutar_vision_directa(user_phrase)

        read_file_match = re.search(r'\[?ACCION:READ_?FILE:([^\]\n]+)\]?', ai_reply, re.IGNORECASE)
        if read_file_match and not extra_file_context:
            target_kw = read_file_match.group(1).strip()
            snippet = system_bridge.read_project_file_snippet(target_kw, max_chars=2200)
            ai_reply = await loop.run_in_executor(None, self._consultar_gemini, user_phrase, snippet)

        ps_match = re.search(r'\[?ACCION:POWERSHELL:([^\]\n]+)\]?', ai_reply, re.IGNORECASE)
        if ps_match:
            ps_cmd = ps_match.group(1).strip()
            print(f"  ⚙️ [POWERSHELL]: Ejecutando '{ps_cmd}'...")
            ps_out = await loop.run_in_executor(None, system_bridge.run_powershell_command, ps_cmd)
            print(f"  ⚙️ [SALIDA PS]: {ps_out[:200]}")

        if re.search(r'\[?ACCION:SCROLL_?UP\]?', ai_reply, re.IGNORECASE):
            system_bridge.scroll_screen("up", notches=8)
        if re.search(r'\[?ACCION:SCROLL_?DOWN\]?', ai_reply, re.IGNORECASE):
            system_bridge.scroll_screen("down", notches=8)

        click_match = re.search(r'\[?ACCION:CLICK:([^\]\n]+)\]?', ai_reply, re.IGNORECASE)
        if click_match:
            system_bridge.click_mouse(click_match.group(1).strip())

        type_match = re.search(r'\[?ACCION:TYPE:([^\]\n]+)\]?', ai_reply, re.IGNORECASE)
        if type_match:
            system_bridge.type_unicode_text(type_match.group(1).strip())

        key_match = re.search(r'\[?ACCION:KEY:([^\]\n]+)\]?', ai_reply, re.IGNORECASE)
        if key_match:
            system_bridge.press_key_combo(key_match.group(1).strip())

        open_file_match = re.search(r'\[?ACCION:OPEN_?FILE:([^\]\n]+)\]?', ai_reply, re.IGNORECASE)
        if open_file_match:
            ok, msg_file = system_bridge.find_and_open_file(open_file_match.group(1).strip())
            print(f"  📂 [ARCHIVO]: {msg_file}")

        open_app_match = re.search(r'\[?ACCION:OPEN_?APP:([^\]\n]+)\]?', ai_reply, re.IGNORECASE)
        if open_app_match:
            system_bridge.launch_application(open_app_match.group(1).strip())
        if re.search(r'\[?ACCION:OPEN_?SPOTIFY\]?', ai_reply, re.IGNORECASE):
            system_bridge.launch_application("spotify")
        if re.search(r'\[?ACCION:OPEN_?GODOT\]?', ai_reply, re.IGNORECASE):
            system_bridge.launch_application("godot")
        if re.search(r'\[?ACCION:OPEN_?TERMINAL\]?', ai_reply, re.IGNORECASE):
            system_bridge.launch_application("terminal")

        close_match = re.search(r'\[?ACCION:CLOSE_?APP:([^\]\n]+)\]?', ai_reply, re.IGNORECASE)
        if close_match:
            system_bridge.close_application(close_match.group(1).strip())

        yt_match = re.search(r'\[?ACCION:SEARCH_?YOUTUBE:([^\]\n]+)\]?', ai_reply, re.IGNORECASE)
        if yt_match:
            system_bridge.open_web_search_or_url(yt_match.group(1).strip(), engine="youtube")

        gg_match = re.search(r'\[?ACCION:SEARCH_?GOOGLE:([^\]\n]+)\]?', ai_reply, re.IGNORECASE)
        if gg_match:
            system_bridge.open_web_search_or_url(gg_match.group(1).strip(), engine="google")

        url_match = re.search(r'\[?ACCION:OPEN_?URL:([^\]\n]+)\]?', ai_reply, re.IGNORECASE)
        if url_match:
            system_bridge.open_web_search_or_url(url_match.group(1).strip(), engine="google")

        if re.search(r'\[?ACCION:MINIMIZE_?ALL\]?', ai_reply, re.IGNORECASE):
            system_bridge.minimize_all_windows()
        if re.search(r'\[?ACCION:SWITCH_?WINDOW\]?', ai_reply, re.IGNORECASE):
            system_bridge.switch_window()
        if re.search(r'\[?ACCION:TOGGLE_?PLAY_?PAUSE\]?', ai_reply, re.IGNORECASE):
            system_bridge.toggle_play_pause()
        if re.search(r'\[?ACCION:NEXT_?TRACK\]?', ai_reply, re.IGNORECASE):
            system_bridge.next_track()
        if re.search(r'\[?ACCION:PREV_?TRACK\]?', ai_reply, re.IGNORECASE):
            system_bridge.prev_track()
        if re.search(r'\[?ACCION:MUTE\]?', ai_reply, re.IGNORECASE):
            system_bridge.toggle_mute()
        if re.search(r'\[?ACCION:VOL_?UP\]?', ai_reply, re.IGNORECASE):
            system_bridge.volume_up(4)
        if re.search(r'\[?ACCION:VOL_?DOWN\]?', ai_reply, re.IGNORECASE):
            system_bridge.volume_down(4)

        if re.search(r'\[?ACCION:SHUTDOWN\]?', ai_reply, re.IGNORECASE):
            self.speak("Desconectando sistemas, Máximo.")
            await asyncio.sleep(2.5)
            self.is_running = False
            return {"tier": 0, "action": "shutdown"}

        self.speak(ai_reply)
        return {"tier": 2, "action": "ai_conversation", "reply": ai_reply}

    async def process_voice_intent(self, user_phrase: str) -> Dict[str, Any]:
        """Wrapper con telemetría atómica para la auto-auditoría continua cada 10 minutos."""
        t0 = time.time()
        try:
            res = await self._process_voice_intent_impl(user_phrase)
            dt_ms = (time.time() - t0) * 1000
            self._registrar_telemetria(
                user_phrase=user_phrase,
                action=res.get("action", "unknown"),
                reply=res.get("reply", ""),
                latency_ms=dt_ms,
                success=True
            )
            return res
        except Exception as e:
            dt_ms = (time.time() - t0) * 1000
            self._registrar_telemetria(
                user_phrase=user_phrase,
                action="error",
                reply="",
                latency_ms=dt_ms,
                success=False,
                error=str(e)
            )
            raise

    async def _flush_speech_buffer(self, wait_seconds: float) -> None:
        try:
            await asyncio.sleep(wait_seconds)
            if not self._speech_buffer:
                return
            full_sentence = " ".join(self._speech_buffer).strip()
            self._speech_buffer.clear()

            if self._active_intent_task and not self._active_intent_task.done():
                self._active_intent_task.cancel()

            self._active_intent_task = asyncio.create_task(self.process_voice_intent(full_sentence))
            await self._active_intent_task
        except asyncio.CancelledError:
            pass
        except Exception as e:
            print(f"[ERROR DISPATCH]: {e}")

    def _enqueue_fragment(self, fragment: str) -> None:
        self._speech_buffer.append(fragment)

        if self._debounce_task and not self._debounce_task.done():
            self._debounce_task.cancel()

        if self._active_intent_task and not self._active_intent_task.done():
            self._active_intent_task.cancel()
            print("  🔄 [CONSOLIDACIÓN]: Uniéndose al fragmento anterior (consulta previa cancelada).")

        words = fragment.lower().strip().split()
        last_word = words[-1] if words else ""
        conectores_incompletos = {
            "eh", "este", "em", "para", "por", "que", "de", "con", "en", "el", "la",
            "los", "las", "un", "una", "tengo", "mira", "mirá", "podes", "podés",
            "como", "pero", "si", "porque", "cuando", "donde", "es"
        }

        combined_now = " ".join(self._speech_buffer).lower()
        fast_cmds = ["pausa", "dale play", "subi la pantalla", "subí la pantalla", "baja la pantalla", "bajá la pantalla", "subi volumen", "baja volumen", "silencio", "minimiza todo"]
        if any(c in combined_now for c in fast_cmds):
            wait_t = 0.05
        elif len(words) <= 2 or last_word in conectores_incompletos:
            wait_t = 0.60
            print(f"  ⏳ [ESPERANDO IDEA COMPLETA]: Fragmento abierto '{fragment}' (esperando {wait_t}s)...")
        else:
            wait_t = 0.25

        self._debounce_task = asyncio.create_task(self._flush_speech_buffer(wait_t))

    def _audio_callback(self, recognizer, audio):
        try:
            phrase = recognizer.recognize_google(audio, language=self.language)
            phrase_clean = phrase.strip()
            if not phrase_clean:
                return

            if self.is_echo(phrase_clean):
                print(f"  🔇 [ECHO FILTRADO]: Se ignoró audio de altavoces ('{phrase_clean}')")
                return

            if self.is_speaking:
                self.stop_speaking()
                print("  🔇 [BARGE-IN]: Locución cortada inmediatamente por voz de Máximo.")

            print(f"\n🎙️ [FRAGMENTO CAPTADO]: '{phrase_clean}'")
            if self.loop and self.loop.is_running():
                self.loop.call_soon_threadsafe(self._enqueue_fragment, phrase_clean)
        except sr.UnknownValueError:
            pass
        except Exception:
            pass

    async def run_loop(self) -> None:
        self.is_running = True
        self.loop = asyncio.get_running_loop()

        tel = system_bridge.get_system_telemetry()
        print("\n" + "="*75)
        print("  🌟 JIMIN ONLINE (VOZ NEURONAL MASCULINA + CONTROL FÍSICO TOTAL + AUTO-AUDITORÍA)")
        print(f"  • Usuario: Máximo | Hora: {tel['hora']} | Batería: {tel['bateria_porcentaje']}% | RAM: {tel['ram_porcentaje']}%")
        print(f"  • Asistente: Jimin | Voz Activa: {self.voice_id} (Timbre Masculino Natural en RAM)")
        print("  • Centinela Continuo: Telemetría atómica y ciclo de auto-mejora cada 10 minutos")
        print("  • Manos Físicas: Scroll arriba/abajo, Clics, Escritura Unicode, Atajos y PowerShell")
        print("="*75 + "\n")

        mic_connected = False
        for _ in range(4):
            try:
                mic = sr.Microphone()
                with mic as source:
                    self.recognizer.adjust_for_ambient_noise(source, duration=0.4)
                self.stop_listening = self.recognizer.listen_in_background(mic, self._audio_callback)
                mic_connected = True
                print("[INFO] Micrófono acoplado. Jimin listo y en línea.")
                self.speak("Sistemas en línea, Máximo. Soy Jimin, a tu completa disposición.")
                break
            except Exception:
                time.sleep(0.5)

        if not mic_connected:
            print("[ALERTA] No se pudo abrir el micrófono tras varios intentos.")

        while self.is_running:
            try:
                neural_busy = self.neural_tts_ready and pygame.mixer.music.get_busy()
                sapi_busy = (self.speaker is not None) and (self.speaker.Status.RunningState == 2)
                currently_speaking = bool(neural_busy or sapi_busy)
                if self.is_speaking and not currently_speaking:
                    self.is_speaking = False
                    self.last_speech_end_time = time.time()
                elif not self.is_speaking and currently_speaking:
                    self.is_speaking = True
            except Exception:
                pass
            await asyncio.sleep(0.06)

        print("[INFO] JARVIS desactivado limpiamente.")


if __name__ == "__main__":
    asistente = JarvisGeminiAssistant()
    if len(sys.argv) > 1:
        test_phrase = " ".join(sys.argv[1:])
        asyncio.run(asistente.process_voice_intent(test_phrase))
    else:
        asyncio.run(asistente.run_loop())
