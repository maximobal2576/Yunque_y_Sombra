"""
system_bridge.py - Capa de Abstracción Total de Windows (Win32 Mouse/Scroll, Teclado Unicode, PowerShell, Telemetría, Archivos & MSS en RAM)
Potenciado para JARVIS MK-III (Control Físico Total sobre Windows).
"""

import ctypes
from ctypes import wintypes
import subprocess
import io
import os
import sys
import time
import urllib.parse
import webbrowser
from typing import Optional, Tuple, Dict, Any, List
from PIL import Image
import mss

# ==============================================================================
# 1. ATADURA DINÁMICA AL ESCRITORIO INTERACTIVO (WinSta0\Default)
# ==============================================================================
user32 = ctypes.windll.user32
kernel32 = ctypes.windll.kernel32

try:
    ctypes.windll.shcore.SetProcessDpiAwareness(2)
except Exception:
    try:
        user32.SetProcessDPIAware()
    except Exception:
        pass

user32.OpenDesktopW.restype = wintypes.HANDLE
user32.OpenDesktopW.argtypes = [wintypes.LPCWSTR, wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
user32.SetThreadDesktop.restype = wintypes.BOOL
user32.SetThreadDesktop.argtypes = [wintypes.HANDLE]
DESKTOP_ALL = 0x01FF

def attach_to_interactive_desktop() -> bool:
    """Acopla el hilo actual de ejecución al escritorio interactivo real de Windows."""
    try:
        h = user32.OpenDesktopW("Default", 0, False, DESKTOP_ALL)
        if h:
            return bool(user32.SetThreadDesktop(h))
    except Exception:
        pass
    return False

# ==============================================================================
# 2. TELEMETRÍA EN VIVO DEL SISTEMA Y VENTANA ACTIVA (< 1 ms vía Win32 API)
# ==============================================================================
class SYSTEM_POWER_STATUS(ctypes.Structure):
    _fields_ = [
        ("ACLineStatus", ctypes.c_byte),
        ("BatteryFlag", ctypes.c_byte),
        ("BatteryLifePercent", ctypes.c_byte),
        ("SystemStatusFlag", ctypes.c_byte),
        ("BatteryLifeTime", wintypes.DWORD),
        ("BatteryFullLifeTime", wintypes.DWORD),
    ]

class MEMORYSTATUSEX(ctypes.Structure):
    _fields_ = [
        ("dwLength", wintypes.DWORD),
        ("dwMemoryLoad", wintypes.DWORD),
        ("ullTotalPhys", ctypes.c_ulonglong),
        ("ullAvailPhys", ctypes.c_ulonglong),
        ("ullTotalPageFile", ctypes.c_ulonglong),
        ("ullAvailPageFile", ctypes.c_ulonglong),
        ("ullTotalVirtual", ctypes.c_ulonglong),
        ("ullAvailVirtual", ctypes.c_ulonglong),
        ("ullAvailExtendedVirtual", ctypes.c_ulonglong),
    ]

def get_active_window_title() -> str:
    try:
        hwnd = user32.GetForegroundWindow()
        if not hwnd:
            return "Escritorio"
        length = user32.GetWindowTextLengthW(hwnd)
        if length <= 0:
            return "Escritorio"
        buf = ctypes.create_unicode_buffer(length + 1)
        user32.GetWindowTextW(hwnd, buf, length + 1)
        return buf.value.strip() or "Escritorio"
    except Exception:
        return "Desconocida"

def get_system_telemetry() -> Dict[str, Any]:
    telemetry: Dict[str, Any] = {
        "hora": time.strftime("%H:%M"),
        "ventana_activa": get_active_window_title(),
        "ram_porcentaje": 0,
        "bateria_porcentaje": 100,
        "conectado_corriente": True
    }
    try:
        mem = MEMORYSTATUSEX()
        mem.dwLength = ctypes.sizeof(MEMORYSTATUSEX)
        if kernel32.GlobalMemoryStatusEx(ctypes.byref(mem)):
            telemetry["ram_porcentaje"] = int(mem.dwMemoryLoad)
            telemetry["ram_libre_gb"] = round(mem.ullAvailPhys / (1024**3), 1)
    except Exception:
        pass

    try:
        pwr = SYSTEM_POWER_STATUS()
        if kernel32.GetSystemPowerStatus(ctypes.byref(pwr)):
            if pwr.BatteryLifePercent <= 100:
                telemetry["bateria_porcentaje"] = int(pwr.BatteryLifePercent)
            telemetry["conectado_corriente"] = (pwr.ACLineStatus == 1)
    except Exception:
        pass

    return telemetry

# ==============================================================================
# 3. ESTRUCTURAS WIN32 SENDINPUT, SCROLL FÍSICO, MOUSE Y TECLADO UNICODE
# ==============================================================================
INPUT_MOUSE = 0
INPUT_KEYBOARD = 1
KEYEVENTF_EXTENDEDKEY = 0x0001
KEYEVENTF_KEYUP = 0x0002
KEYEVENTF_UNICODE = 0x0004

MOUSEEVENTF_LEFTDOWN = 0x0002
MOUSEEVENTF_LEFTUP = 0x0004
MOUSEEVENTF_RIGHTDOWN = 0x0008
MOUSEEVENTF_RIGHTUP = 0x0010
MOUSEEVENTF_WHEEL = 0x0800

VK_BACK = 0x08
VK_TAB = 0x09
VK_RETURN = 0x0D
VK_CONTROL = 0x11
VK_MENU = 0x12              # Alt
VK_ESCAPE = 0x1B
VK_PRIOR = 0x21             # Page Up (RePág)
VK_NEXT = 0x22              # Page Down (AvPág)
VK_UP = 0x26
VK_DOWN = 0x28
VK_LWIN = 0x5B
VK_F4 = 0x73
VK_F5 = 0x74
VK_VOLUME_MUTE = 0xAD
VK_VOLUME_DOWN = 0xAE
VK_VOLUME_UP = 0xAF
VK_MEDIA_NEXT_TRACK = 0xB0
VK_MEDIA_PREV_TRACK = 0xB1
VK_MEDIA_STOP = 0xB2
VK_MEDIA_PLAY_PAUSE = 0xB3

class KEYBDINPUT(ctypes.Structure):
    _fields_ = [
        ("wVk", wintypes.WORD),
        ("wScan", wintypes.WORD),
        ("dwFlags", wintypes.DWORD),
        ("time", wintypes.DWORD),
        ("dwExtraInfo", ctypes.POINTER(wintypes.ULONG)),
    ]

class HARDWAREINPUT(ctypes.Structure):
    _fields_ = [
        ("uMsg", wintypes.DWORD),
        ("wParamL", wintypes.WORD),
        ("wParamH", wintypes.WORD),
    ]

class MOUSEINPUT(ctypes.Structure):
    _fields_ = [
        ("dx", wintypes.LONG),
        ("dy", wintypes.LONG),
        ("mouseData", wintypes.DWORD),
        ("dwFlags", wintypes.DWORD),
        ("time", wintypes.DWORD),
        ("dwExtraInfo", ctypes.POINTER(wintypes.ULONG)),
    ]

class _INPUT_UNION(ctypes.Union):
    _fields_ = [
        ("mi", MOUSEINPUT),
        ("ki", KEYBDINPUT),
        ("hi", HARDWAREINPUT),
    ]

class INPUT(ctypes.Structure):
    _fields_ = [
        ("type", wintypes.DWORD),
        ("union", _INPUT_UNION),
    ]

def send_virtual_key(vk_code: int) -> bool:
    extra = ctypes.c_ulong(0)
    extra_ptr = ctypes.pointer(extra)

    input_down = INPUT()
    input_down.type = INPUT_KEYBOARD
    input_down.union.ki = KEYBDINPUT(wVk=vk_code, wScan=0, dwFlags=KEYEVENTF_EXTENDEDKEY, time=0, dwExtraInfo=extra_ptr)

    input_up = INPUT()
    input_up.type = INPUT_KEYBOARD
    input_up.union.ki = KEYBDINPUT(wVk=vk_code, wScan=0, dwFlags=KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, time=0, dwExtraInfo=extra_ptr)

    inputs = (INPUT * 2)(input_down, input_up)
    res = user32.SendInput(2, inputs, ctypes.sizeof(INPUT))
    return res == 2

def scroll_screen(direction: str = "up", notches: int = 7) -> bool:
    """
    Desplaza físicamente la pantalla arriba o abajo combinando Rueda de Mouse Win32 + PageUp/PageDown
    para garantizar que funcione en navegadores, Word, editores de código y chats.
    """
    attach_to_interactive_desktop()
    try:
        is_up = direction.lower().strip() in ["up", "arriba", "subir", "top"]
        wheel_delta = (120 * notches) if is_up else (-120 * notches)
        # 1. Mover rueda de mouse en la posición actual del cursor
        user32.mouse_event(MOUSEEVENTF_WHEEL, 0, 0, ctypes.c_ulong(wheel_delta & 0xFFFFFFFF).value, 0)
        # 2. Enviar también tecla de desplazamiento a la ventana con foco
        vk = VK_PRIOR if is_up else VK_NEXT
        user32.keybd_event(vk, 0, KEYEVENTF_EXTENDEDKEY, 0)
        user32.keybd_event(vk, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0)
        return True
    except Exception:
        return False

def click_mouse(mode: str = "left") -> bool:
    """Ejecuta clic izquierdo, derecho o doble clic en la posición actual del cursor."""
    attach_to_interactive_desktop()
    try:
        m = mode.lower().strip()
        if m in ["right", "derecho"]:
            user32.mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
            user32.mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
        elif m in ["double", "doble"]:
            for _ in range(2):
                user32.mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
                user32.mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
                time.sleep(0.05)
        else:
            user32.mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
            user32.mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
        return True
    except Exception:
        return False

def type_unicode_text(text: str) -> bool:
    """Escribe texto real (con tildes y eñes) directamente donde esté el cursor del usuario."""
    attach_to_interactive_desktop()
    try:
        extra = ctypes.c_ulong(0)
        extra_ptr = ctypes.pointer(extra)
        for ch in text:
            code = ord(ch)
            inp_down = INPUT()
            inp_down.type = INPUT_KEYBOARD
            inp_down.union.ki = KEYBDINPUT(wVk=0, wScan=code, dwFlags=KEYEVENTF_UNICODE, time=0, dwExtraInfo=extra_ptr)

            inp_up = INPUT()
            inp_up.type = INPUT_KEYBOARD
            inp_up.union.ki = KEYBDINPUT(wVk=0, wScan=code, dwFlags=KEYEVENTF_UNICODE | KEYEVENTF_KEYUP, time=0, dwExtraInfo=extra_ptr)

            inputs = (INPUT * 2)(inp_down, inp_up)
            user32.SendInput(2, inputs, ctypes.sizeof(INPUT))
        return True
    except Exception:
        return False

def press_key_combo(combo_name: str) -> bool:
    """Ejecuta atajos de teclado de Windows: enter, escape, copiar, pegar, deshacer, guardar, cerrar_ventana, etc."""
    attach_to_interactive_desktop()
    c = combo_name.lower().strip()
    try:
        if c in ["enter", "intro"]:
            return send_virtual_key(VK_RETURN)
        if c in ["escape", "esc", "salir"]:
            return send_virtual_key(VK_ESCAPE)
        if c in ["borrar", "backspace"]:
            return send_virtual_key(VK_BACK)
        if c in ["f5", "recargar", "actualizar"]:
            return send_virtual_key(VK_F5)
        if c in ["copiar", "copy", "ctrl+c"]:
            user32.keybd_event(VK_CONTROL, 0, 0, 0)
            user32.keybd_event(ord('C'), 0, 0, 0)
            user32.keybd_event(ord('C'), 0, KEYEVENTF_KEYUP, 0)
            user32.keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0)
            return True
        if c in ["pegar", "paste", "ctrl+v"]:
            user32.keybd_event(VK_CONTROL, 0, 0, 0)
            user32.keybd_event(ord('V'), 0, 0, 0)
            user32.keybd_event(ord('V'), 0, KEYEVENTF_KEYUP, 0)
            user32.keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0)
            return True
        if c in ["deshacer", "undo", "ctrl+z"]:
            user32.keybd_event(VK_CONTROL, 0, 0, 0)
            user32.keybd_event(ord('Z'), 0, 0, 0)
            user32.keybd_event(ord('Z'), 0, KEYEVENTF_KEYUP, 0)
            user32.keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0)
            return True
        if c in ["guardar", "save", "ctrl+s"]:
            user32.keybd_event(VK_CONTROL, 0, 0, 0)
            user32.keybd_event(ord('S'), 0, 0, 0)
            user32.keybd_event(ord('S'), 0, KEYEVENTF_KEYUP, 0)
            user32.keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0)
            return True
        if c in ["cerrar_ventana", "alt+f4"]:
            user32.keybd_event(VK_MENU, 0, 0, 0)
            user32.keybd_event(VK_F4, 0, 0, 0)
            user32.keybd_event(VK_F4, 0, KEYEVENTF_KEYUP, 0)
            user32.keybd_event(VK_MENU, 0, KEYEVENTF_KEYUP, 0)
            return True
    except Exception:
        pass
    return False

def minimize_all_windows() -> bool:
    try:
        user32.keybd_event(VK_LWIN, 0, 0, 0)
        user32.keybd_event(0x44, 0, 0, 0)  # D
        user32.keybd_event(0x44, 0, KEYEVENTF_KEYUP, 0)
        user32.keybd_event(VK_LWIN, 0, KEYEVENTF_KEYUP, 0)
        return True
    except Exception:
        return False

def switch_window() -> bool:
    try:
        user32.keybd_event(VK_MENU, 0, 0, 0)
        user32.keybd_event(VK_TAB, 0, 0, 0)
        user32.keybd_event(VK_TAB, 0, KEYEVENTF_KEYUP, 0)
        user32.keybd_event(VK_MENU, 0, KEYEVENTF_KEYUP, 0)
        return True
    except Exception:
        return False

# ==============================================================================
# 4. CONTROLES MULTIMEDIA INMEDIATOS (Tier 0: < 5ms)
# ==============================================================================
def toggle_play_pause() -> bool:
    return send_virtual_key(VK_MEDIA_PLAY_PAUSE)

def next_track() -> bool:
    return send_virtual_key(VK_MEDIA_NEXT_TRACK)

def prev_track() -> bool:
    return send_virtual_key(VK_MEDIA_PREV_TRACK)

def toggle_mute() -> bool:
    return send_virtual_key(VK_VOLUME_MUTE)

def volume_up(steps: int = 2) -> None:
    for _ in range(steps):
        send_virtual_key(VK_VOLUME_UP)

def volume_down(steps: int = 2) -> None:
    for _ in range(steps):
        send_virtual_key(VK_VOLUME_DOWN)

# ==============================================================================
# 5. EJECUTOR POWERSHELL SEGURO, LANZADOR DE APPS Y ARCHIVOS DE PROYECTO
# ==============================================================================
def run_powershell_command(command_str: str) -> str:
    """
    Ejecuta un comando real de PowerShell pedido por JARVIS (crear carpetas, ver procesos,
    abrir programas instalados, consultar espacio, etc.) con timeout de 6 segundos.
    """
    forbidden = ["format-volume", "remove-item -recurse -force c:\\", "stop-computer", "restart-computer"]
    cmd_low = command_str.lower()
    if any(f in cmd_low for f in forbidden):
        return "Comando bloqueado por protocolo de seguridad."

    try:
        res = subprocess.run(
            ["powershell", "-NoProfile", "-Command", command_str],
            capture_output=True,
            text=True,
            timeout=6,
            cwd=r"C:\Users\admin\Documents"
        )
        out = (res.stdout or "").strip()
        err = (res.stderr or "").strip()
        if out:
            return out[:800]
        if err:
            return f"Aviso: {err[:300]}"
        return "Orden ejecutada exitosamente en el sistema."
    except Exception as e:
        return f"No se pudo completar el comando: {e}"

ALLOWED_APPLICATIONS = {
    "spotify": ["spotify"],
    "calculadora": ["calc.exe"],
    "bloc de notas": ["notepad.exe"],
    "explorador": ["explorer.exe"],
    "terminal": ["wt.exe", "powershell.exe"],
    "navegador": ["msedge.exe", "chrome.exe"],
    "chrome": ["chrome.exe", "msedge.exe"],
    "godot": ["godot"],
    "word": ["winword.exe"],
    "freecad": ["freecad.exe"],
    "arduino": ["arduino.exe"],
    "administrador de tareas": ["taskmgr.exe"]
}

PROCESS_NAMES = {
    "calculadora": ["calc.exe", "CalculatorApp.exe"],
    "spotify": ["Spotify.exe"],
    "godot": ["godot.exe", "Godot_v4.7.2-stable_win64.exe"],
    "terminal": ["wt.exe", "powershell.exe"],
    "bloc de notas": ["notepad.exe"],
    "word": ["WINWORD.EXE"],
    "freecad": ["FreeCAD.exe"],
    "navegador": ["chrome.exe", "msedge.exe"]
}

PROJECT_ROOTS = [
    r"C:\Users\admin\Documents\02_Proyectos_Dev\proyecto innovador\documentacion",
    r"C:\Users\admin\Documents\02_Proyectos_Dev\proyecto innovador\versiones\Centinela_v2",
    r"C:\Users\admin\Documents\02_Proyectos_Dev\proyecto innovador\diseno_3d",
    r"C:\Users\admin\Documents\02_Proyectos_Dev\Centinela",
    r"C:\Users\admin\Documents\01_Academico_IITA\iita\juego"
]

def close_application(app_alias: str) -> Tuple[bool, str]:
    app_alias_clean = app_alias.lower().strip()
    procs = PROCESS_NAMES.get(app_alias_clean)
    if not procs:
        subprocess.run(["taskkill", "/F", "/IM", f"{app_alias_clean}.exe"], capture_output=True)
        return True, f"Cerrando '{app_alias}'."
    for proc in procs:
        subprocess.run(["taskkill", "/F", "/IM", proc], capture_output=True)
    return True, f"Proceso '{app_alias}' finalizado."

def launch_application(app_alias: str) -> Tuple[bool, str]:
    app_alias_clean = app_alias.lower().strip()
    target_cmd = ALLOWED_APPLICATIONS.get(app_alias_clean, [app_alias_clean])

    for cmd in target_cmd:
        try:
            subprocess.Popen([cmd], shell=False)
            return True, f"Aplicación '{app_alias}' ejecutada."
        except Exception:
            try:
                os.startfile(cmd)
                return True, f"Aplicación '{app_alias}' abierta."
            except Exception:
                continue
    return False, f"No se pudo iniciar '{app_alias}'."

def open_web_search_or_url(query_or_url: str, engine: str = "google") -> bool:
    try:
        clean = query_or_url.strip()
        if clean.startswith("http://") or clean.startswith("https://"):
            webbrowser.open(clean)
            return True
        if "." in clean and " " not in clean:
            webbrowser.open("https://" + clean)
            return True
        encoded = urllib.parse.quote_plus(clean)
        if engine.lower() == "youtube":
            webbrowser.open(f"https://www.youtube.com/results?search_query={encoded}")
        else:
            webbrowser.open(f"https://www.google.com/search?q={encoded}")
        return True
    except Exception:
        return False

def get_project_files_inventory() -> str:
    summary_lines = []
    doc_dir = r"C:\Users\admin\Documents\02_Proyectos_Dev\proyecto innovador\documentacion"
    if os.path.exists(doc_dir):
        files = [f for f in os.listdir(doc_dir) if not f.startswith("~$")]
        summary_lines.append(f"Carpeta documentacion Centinela: {', '.join(files[:12])}")

    v2_dir = r"C:\Users\admin\Documents\02_Proyectos_Dev\proyecto innovador\versiones\Centinela_v2"
    if os.path.exists(v2_dir):
        files = [f for f in os.listdir(v2_dir) if f.endswith(('.ino', '.cpp', '.h', '.md'))]
        summary_lines.append(f"Carpeta firmware Centinela_v2: {', '.join(files[:15])}")

    return " | ".join(summary_lines)

def find_and_open_file(keyword: str) -> Tuple[bool, str]:
    kw = keyword.lower().strip()
    if "documentacion" in kw or "documentación" in kw:
        doc_dir = r"C:\Users\admin\Documents\02_Proyectos_Dev\proyecto innovador\documentacion"
        if "informe" not in kw and "carpeta de campo" not in kw and "word" not in kw:
            os.startfile(doc_dir)
            return True, "Carpeta de documentación abierta en el Explorador."

    best_match = None
    for root_dir in PROJECT_ROOTS:
        if not os.path.exists(root_dir):
            continue
        entries = [os.path.join(root_dir, f) for f in os.listdir(root_dir) if not f.startswith("~$")]
        files = [p for p in entries if os.path.isfile(p)]
        files.sort(key=lambda p: os.path.getmtime(p), reverse=True)
        for full_p in files:
            fn_low = os.path.basename(full_p).lower()
            if kw in fn_low or (
                ("informe" in kw or "estudio" in kw) and "informe_estudio" in fn_low
            ) or (
                ("carpeta de campo" in kw) and "carpeta de campo" in fn_low
            ):
                best_match = full_p
                break
        if best_match:
            break

    if best_match:
        try:
            os.startfile(best_match)
            return True, os.path.basename(best_match)
        except Exception as e:
            return False, str(e)
    return False, "No se encontró un archivo con ese nombre."

def read_project_file_snippet(keyword: str, max_chars: int = 2500) -> str:
    kw = keyword.lower().strip()
    target_path = None

    for root_dir in PROJECT_ROOTS:
        if not os.path.exists(root_dir):
            continue
        entries = [os.path.join(root_dir, f) for f in os.listdir(root_dir) if not f.startswith("~$")]
        files = [p for p in entries if os.path.isfile(p)]
        files.sort(key=lambda p: os.path.getmtime(p), reverse=True)
        for full_p in files:
            fn_low = os.path.basename(full_p).lower()
            if kw in fn_low or (
                ("informe" in kw or "estudio" in kw or "word" in kw) and "informe_estudio" in fn_low
            ) or (
                ("carpeta de campo" in kw) and "carpeta de campo" in fn_low
            ):
                target_path = full_p
                break
        if target_path:
            break

    if not target_path:
        return f"Archivos disponibles: {get_project_files_inventory()}"

    try:
        if target_path.lower().endswith(".docx"):
            import docx
            doc = docx.Document(target_path)
            paras = [p.text.strip() for p in doc.paragraphs if p.text.strip()]
            text = "\n".join(paras)
            return f"[Contenido de {os.path.basename(target_path)}]:\n{text[:max_chars]}"
        else:
            with open(target_path, "r", encoding="utf-8", errors="ignore") as f:
                return f"[Contenido de {os.path.basename(target_path)}]:\n{f.read(max_chars)}"
    except Exception as e:
        return f"No se pudo leer {os.path.basename(target_path)}: {e}"

# ==============================================================================
# 6. CAPTURA DE PANTALLA EN MEMORIA (Tier 2: Zero Disk I/O vía MSS)
# ==============================================================================
def capture_screen_ram_webp(max_width: int = 1280, quality: int = 75) -> bytes:
    attach_to_interactive_desktop()

    try:
        with mss.MSS() as sct:
            monitor = sct.monitors[1] if len(sct.monitors) > 1 else sct.monitors[0]
            sct_img = sct.grab(monitor)
            img = Image.frombytes("RGB", sct_img.size, sct_img.bgra, "raw", "BGRX")
    except Exception as e:
        ojos_script = r"C:\Users\admin\.gemini\config\skills\ojos\scripts\capturar_pantalla.py"
        if os.path.exists(ojos_script):
            res = subprocess.run([sys.executable, ojos_script], capture_output=True, text=True)
            output = res.stdout.strip()
            if output.startswith("OK:"):
                img_path = output.split("OK:")[1].strip()
                with Image.open(img_path) as disk_img:
                    img = disk_img.convert("RGB")
                try:
                    os.remove(img_path)
                except Exception:
                    pass
            else:
                raise RuntimeError(f"Fallo en captura: {e}")
        else:
            raise e

    if img.width > max_width:
        ratio = max_width / float(img.width)
        new_height = int(float(img.height) * ratio)
        img = img.resize((max_width, new_height))

    buffer = io.BytesIO()
    img.save(buffer, format="WEBP", quality=quality)
    return buffer.getvalue()
