# scripts/run_playtest_in_window.py
import os
import sys
import time
import subprocess
import ctypes
from ctypes import wintypes

# Asegurar codificacion UTF-8 para stdout en Windows
if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    except Exception:
        pass

user32 = ctypes.windll.user32

def bring_window_to_front():
    hwnds = []
    def enum_cb(h, _):
        if user32.IsWindowVisible(h):
            length = user32.GetWindowTextLengthW(h)
            if length > 0:
                b = ctypes.create_unicode_buffer(length + 1)
                user32.GetWindowTextW(h, b, length + 1)
                title = b.value
                if "Yunque" in title or "Godot" in title:
                    hwnds.append(h)
        return True

    EnumWindowsProc = ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)
    cb = EnumWindowsProc(enum_cb)
    user32.EnumWindows(cb, 0)
    
    for h in hwnds:
        # HWND_TOPMOST = -1, SWP_NOSIZE = 1, SWP_NOMOVE = 2, SWP_SHOWWINDOW = 0x40
        user32.ShowWindow(h, 9) # SW_RESTORE
        user32.SetWindowPos(h, -1, 0, 0, 0, 0, 0x0001 | 0x0002 | 0x0040)
        user32.SetForegroundWindow(h)
        return True
    return False

def main():
    godot_exe = r"C:\Users\admin\Downloads\Godot_v4.7.2-stable_win64.exe"
    project_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    
    env = os.environ.copy()
    env["GODOT_PLAYTEST"] = "1"
    
    print("=" * 60)
    print("[RUNNER] INICIANDO GODOT EN PRIMER PLANO (VENTANA VISIBLE)")
    print("=" * 60)
    
    proc = subprocess.Popen([godot_exe, "--path", project_dir], env=env)
    
    # Intentar traer al frente durante los primeros 12 segundos
    start_t = time.time()
    brought = False
    while time.time() - start_t < 12.0:
        time.sleep(0.4)
        if bring_window_to_front():
            print("[RUNNER] Ventana de Godot detectada y colocada en PRIMER PLANO.")
            brought = True
            break
            
    print("[RUNNER] La prueba se esta ejecutando en pantalla...")
    proc.wait()
    print("[RUNNER] Proceso de Godot finalizado. Retornando a Antigravity.")

if __name__ == "__main__":
    main()
