#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Servidor Web Dual (HTTPS + HTTP) en Red Local (LAN) para
'Yunque & Sombra: La Herencia del Artesano'.

- Levanta HTTPS en https://<TU_IP_LOCAL>:8443 con certificado autofirmado automático
  (sin Certbot, sin dominio pago y sin licencias) para que cualquier otra PC o celular
  en la red Wi-Fi/LAN tenga Contexto Seguro (HTTPS) requerido por Godot 4 Web.
- Levanta HTTP en http://localhost:8080 para jugar directo en esta misma PC.
"""

import http.server
import os
import socket
import socketserver
import ssl
import subprocess
import sys
import threading

HTTP_PORT = 8080
HTTPS_PORT = 8443
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
WEB_DIR = os.path.join(ROOT_DIR, "build", "web")
CERT_FILE = os.path.join(WEB_DIR, "cert_lan.pem")
KEY_FILE = os.path.join(WEB_DIR, "key_lan.pem")


def obtener_ips_locales() -> list[str]:
    ips: list[str] = []
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.connect(("8.8.8.8", 80))
            ip_principal = s.getsockname()[0]
            if ip_principal and not ip_principal.startswith("127."):
                ips.append(ip_principal)
    except Exception:
        pass

    try:
        hostname = socket.gethostname()
        for info in socket.getaddrinfo(hostname, None, socket.AF_INET):
            ip = str(info[4][0])
            if not ip.startswith("127.") and ip not in ips:
                ips.append(ip)
    except Exception:
        pass

    return ips if ips else ["127.0.0.1"]


def asegurar_certificado_https_local(ips: list[str]) -> bool:
    """Genera automáticamente un certificado SSL autofirmado para la red local (sin licencia)."""
    if os.path.isfile(CERT_FILE) and os.path.isfile(KEY_FILE):
        return True

    candidatos_openssl = [
        r"C:\Program Files\Git\usr\bin\openssl.exe",
        r"C:\Program Files (x86)\Git\usr\bin\openssl.exe",
        "openssl",
    ]
    openssl_bin = None
    for ruta in candidatos_openssl:
        if os.path.isfile(ruta):
            openssl_bin = ruta
            break

    if not openssl_bin:
        return False

    san_entries = ["DNS:localhost", "IP:127.0.0.1"]
    for ip in ips:
        if ip != "127.0.0.1":
            san_entries.append(f"IP:{ip}")
    san_str = ",".join(san_entries)

    cmd = [
        openssl_bin,
        "req",
        "-x509",
        "-newkey",
        "rsa:2048",
        "-nodes",
        "-keyout",
        KEY_FILE,
        "-out",
        CERT_FILE,
        "-days",
        "3650",
        "-subj",
        "/CN=YunqueYSombraLAN",
        "-addext",
        f"subjectAltName={san_str}",
    ]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return os.path.isfile(CERT_FILE) and os.path.isfile(KEY_FILE)
    except Exception:
        # Fallback sin -addext por si la versión de OpenSSL es antigua
        cmd_simple = cmd[:-2]
        try:
            subprocess.run(cmd_simple, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return os.path.isfile(CERT_FILE) and os.path.isfile(KEY_FILE)
        except Exception:
            return False


class GodotLANRequestHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def end_headers(self) -> None:
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cross-Origin-Resource-Policy", "cross-origin")
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        super().end_headers()

    def guess_type(self, path: str) -> str:
        if path.endswith(".wasm"):
            return "application/wasm"
        if path.endswith(".pck"):
            return "application/octet-stream"
        if path.endswith(".js"):
            return "application/javascript"
        return super().guess_type(path)

    def log_message(self, format: str, *args) -> None:
        # Evita saturar la consola salvo errores
        pass


class ThreadedHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True


def elegir_puerto_libre(puerto_inicial: int) -> int:
    for p in range(puerto_inicial, puerto_inicial + 15):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.bind(("0.0.0.0", p))
                return p
            except OSError:
                continue
    return puerto_inicial


def main() -> None:
    if not os.path.isfile(os.path.join(WEB_DIR, "index.html")):
        print("==========================================================================")
        print(" [ERROR] No se encontró 'build/web/index.html'.")
        print(" Ejecuta primero la exportación Web de Godot 4:")
        print('   Godot_v4.7.2-stable_win64_console.exe --headless --export-release "Web" "build/web/index.html"')
        print("==========================================================================")
        sys.exit(1)

    ips = obtener_ips_locales()
    tiene_https = asegurar_certificado_https_local(ips)

    puerto_http = elegir_puerto_libre(HTTP_PORT)
    puerto_https = elegir_puerto_libre(HTTPS_PORT)

    servidor_http = ThreadedHTTPServer(("0.0.0.0", puerto_http), GodotLANRequestHandler)
    hilo_http = threading.Thread(target=servidor_http.serve_forever, daemon=True)
    hilo_http.start()

    servidor_https = None
    if tiene_https:
        servidor_https = ThreadedHTTPServer(("0.0.0.0", puerto_https), GodotLANRequestHandler)
        contexto_ssl = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        contexto_ssl.load_cert_chain(certfile=CERT_FILE, keyfile=KEY_FILE)
        servidor_https.socket = contexto_ssl.wrap_socket(servidor_https.socket, server_side=True)
        hilo_https = threading.Thread(target=servidor_https.serve_forever, daemon=True)
        hilo_https.start()

    print("\n" + "=" * 78)
    print(" ⚒️  YUNQUE & SOMBRA — SERVIDOR WEB HTTPS + HTTP EN RED LOCAL ACTIVO")
    print("=" * 78)
    print(f" 💻 Para jugar en ESTA misma PC : http://localhost:{puerto_http}")
    print("-" * 78)
    if tiene_https:
        print(" 🔒 PARA JUGAR DESDE OTRA COMPU O CELULAR EN LA MISMA RED (CON HTTPS):")
        for ip in ips:
            print(f"\n      👉  https://{ip}:{puerto_https}  👈")
        print("\n    Nota: Al abrir ese link en la otra compu, si el navegador muestra")
        print("    'La conexión no es privada', haz clic en 'Configuración avanzada'")
        print("    -> 'Continuar al sitio' y el juego cargará con HTTPS activo.")
    else:
        print(" 📱 Enlace HTTP en red local:")
        for ip in ips:
            print(f"      👉  http://{ip}:{puerto_http}")
    print("-" * 78)
    print(" (Presiona Ctrl + C en esta ventana cuando quieras apagar el servidor)")
    print("=" * 78 + "\n")

    try:
        while True:
            hilo_http.join(1.0)
    except KeyboardInterrupt:
        print("\n[SERVIDOR] Cerrando servidores HTTP/HTTPS...")
        servidor_http.shutdown()
        if servidor_https:
            servidor_https.shutdown()


if __name__ == "__main__":
    main()
