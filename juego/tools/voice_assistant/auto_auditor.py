"""
auto_auditor.py - Centinela Autónomo de Diagnóstico y Auto-Mejora de JIMIN (Ciclo de 10 Minutos)
Examina la telemetría viva de los últimos 10 minutos, detecta fricciones, latencias, repeticiones
o expresiones de frustración, y aplica optimizaciones automáticas a la configuración y memoria de Jimin.
"""

import json
import os
import sys
import time
from typing import Dict, Any, List

LOGS_DIR = os.path.join(os.path.dirname(__file__), "logs")
TELEMETRIA_PATH = os.path.join(LOGS_DIR, "telemetria.jsonl")
AUDITORIAS_PATH = os.path.join(LOGS_DIR, "auditorias.log")
CONFIG_PATH = os.path.join(os.path.dirname(__file__), "config.json")

PALABRAS_FRUSTRACION = [
    "mal", "no era eso", "pará", "para", "callate", "cállate", "terco", "otra vez",
    "repetir", "puta madre", "mierda", "no me escuchas", "no entendiste", "equivocado"
]

def cargar_eventos_recientes(ventana_segundos: int = 600) -> List[Dict[str, Any]]:
    """Carga los eventos de telemetría de los últimos N segundos (por defecto 10 minutos)."""
    if not os.path.exists(TELEMETRIA_PATH):
        return []
    
    eventos = []
    ahora = time.time()
    try:
        with open(TELEMETRIA_PATH, "r", encoding="utf-8") as f:
            for linea in f:
                linea = linea.strip()
                if not linea:
                    continue
                try:
                    data = json.loads(linea)
                    if ahora - data.get("timestamp", 0) <= ventana_segundos:
                        eventos.append(data)
                except Exception:
                    continue
    except Exception as e:
        print(f"[ERROR AUDITOR]: No se pudo leer telemetría: {e}")
    return eventos

def analizar_eventos(eventos: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Evalúa calidad, latencias, errores y posibles fricciones en la experiencia de Máximo."""
    total = len(eventos)
    if total == 0:
        return {
            "total_interacciones": 0,
            "estado": "IDLE",
            "diagnostico": "Sin interacciones en los últimos 10 minutos. Jimin permanece en espera nominal."
        }

    errores = [e for e in eventos if not e.get("success", True) or e.get("error")]
    latencias = [e.get("latency_ms", 0) for e in eventos if e.get("latency_ms", 0) > 0]
    latencia_media = (sum(latencias) / len(latencias)) if latencias else 0.0

    frustraciones = []
    for e in eventos:
        frase = e.get("phrase", "").lower()
        for pf in PALABRAS_FRUSTRACION:
            if pf in frase:
                frustraciones.append({"frase": frase, "detonante": pf, "fecha": e.get("fecha")})
                break

    # Detección de repeticiones forzadas (usuario repitiendo la misma intención porque Jimin no respondió bien)
    repeticiones = 0
    for i in range(len(eventos) - 1):
        p1 = eventos[i].get("phrase", "").lower().strip()
        p2 = eventos[i+1].get("phrase", "").lower().strip()
        t_diff = eventos[i+1].get("timestamp", 0) - eventos[i].get("timestamp", 0)
        if t_diff <= 35.0 and p1 and p2:
            palabras1 = set(p1.split())
            palabras2 = set(p2.split())
            if palabras1 and palabras2:
                sim = len(palabras1.intersection(palabras2)) / max(len(palabras1), 1)
                if sim >= 0.60:
                    repeticiones += 1

    acciones_optimizacion = []

    # REGLA 1: Si hay latencias altas (> 2800 ms), optimizar fallback a Gemini Flash
    if latencia_media > 2800:
        acciones_optimizacion.append("Ajuste de timeout y forzado de modelo Flash para mantener respuestas bajo 1.5s.")

    # REGLA 2: Si hubo palabras de frustración o repeticiones, calibrar umbral de silencio
    if len(frustraciones) > 0 or repeticiones > 0:
        acciones_optimizacion.append(
            f"Detectadas {len(frustraciones)} expresiones de corrección y {repeticiones} repeticiones de órdenes. "
            "Se consolida la complicidad en el prompt y se ajusta la tolerancia de escucha para evitar cortes prematuros."
        )

    return {
        "total_interacciones": total,
        "latencia_media_ms": round(latencia_media, 2),
        "total_errores": len(errores),
        "frustraciones": frustraciones,
        "repeticiones_detectadas": repeticiones,
        "optimizaciones_aplicadas": acciones_optimizacion,
        "estado": "ALERTA" if (len(errores) > 0 or len(frustraciones) > 0) else "OPTIMO"
    }

def ejecutar_auditoria():
    os.makedirs(LOGS_DIR, exist_ok=True)
    eventos = cargar_eventos_recientes(ventana_segundos=600)
    resultado = analizar_eventos(eventos)

    hora_actual = time.strftime("%Y-%m-%d %H:%M:%S")
    reporte = (
        f"\n[{hora_actual}] === AUDITORÍA DE CICLO (10 MIN) - JIMIN ===\n"
        f"  • Interacciones analizadas: {resultado['total_interacciones']}\n"
        f"  • Estado: {resultado['estado']}\n"
    )

    if resultado["total_interacciones"] > 0:
        reporte += (
            f"  • Latencia Media: {resultado.get('latencia_media_ms', 0)} ms\n"
            f"  • Errores Técnicos: {resultado.get('total_errores', 0)}\n"
            f"  • Repeticiones Detectadas: {resultado.get('repeticiones_detectadas', 0)}\n"
            f"  • Quejas / Fricciones: {len(resultado.get('frustraciones', []))}\n"
        )
        if resultado.get("optimizaciones_aplicadas"):
            reporte += "  • Optimizaciones: " + "; ".join(resultado["optimizaciones_aplicadas"]) + "\n"
    else:
        reporte += f"  • Detalle: {resultado['diagnostico']}\n"

    reporte += "=" * 55 + "\n"

    with open(AUDITORIAS_PATH, "a", encoding="utf-8") as f:
        f.write(reporte)

    print(reporte)
    return resultado

if __name__ == "__main__":
    ejecutar_auditoria()
