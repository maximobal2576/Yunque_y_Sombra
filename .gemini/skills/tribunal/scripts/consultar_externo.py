"""Consulta modelos externos gratuitos (DeepSeek vía OpenRouter, DeepSeek API, Groq u Ollama local)
como segunda opinión para la skill /tribunal. No requiere librerías externas.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path


SYSTEM_PROMPTS = {
    "auditor": (
        "Eres un auditor técnico independiente de un Tribunal de Software. "
        "Analiza el resumen, estructura o código recibido con rigor objetivo. "
        "Señala desorden de archivos, inconsistencias, riesgos, deuda técnica y mejoras concretas en español."
    ),
    "orden": (
        "Eres un especialista en organización de repositorios y arquitectura de carpetas. "
        "Evalúa si la estructura está limpia, sin archivos temporales ni duplicados, y propón mejoras puntuales en español."
    ),
}


def post_json(url: str, payload: dict, headers: dict[str, str], timeout: int = 60) -> dict:
    """Envía una petición POST JSON y devuelve la respuesta decodificada."""
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json", **headers}, method="POST")
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def check_ollama(host: str = "http://localhost:11434") -> list[str]:
    """Devuelve los modelos instalados en Ollama si el servicio local está activo."""
    try:
        with urllib.request.urlopen(f"{host}/api/tags", timeout=3) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return [m.get("name", "") for m in data.get("models", []) if m.get("name")]
    except Exception:
        return []


def query_openai_compatible(url: str, api_key: str, model: str, system_prompt: str, user_prompt: str, extra_headers: dict[str, str] | None = None) -> str:
    """Consulta cualquier endpoint compatible con OpenAI Chat Completions."""
    headers = {"Authorization": f"Bearer {api_key}"}
    if extra_headers:
        headers.update(extra_headers)
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        "temperature": 0.2,
    }
    resp = post_json(url, payload, headers=headers)
    return resp["choices"][0]["message"]["content"]


def query_ollama(host: str, model: str, system_prompt: str, user_prompt: str) -> str:
    """Consulta un modelo local servido por Ollama."""
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        "stream": False,
    }
    resp = post_json(f"{host}/api/chat", payload, headers={})
    return resp["message"]["content"]


def load_local_env() -> None:
    """Carga variables desde .env local de la skill si no están en el entorno."""
    candidates = [
        Path(__file__).resolve().parent.parent / ".env",
        Path.home() / ".gemini" / "antigravity" / "skills" / "tribunal" / ".env",
    ]
    for env_file in candidates:
        if not env_file.exists():
            continue
        for raw_line in env_file.read_text(encoding="utf-8-sig", errors="ignore").splitlines():
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, val = line.split("=", 1)
            key = key.strip()
            val = val.strip().strip('"').strip("'")
            if key and key not in os.environ:
                os.environ[key] = val


def resolve_provider_and_query(system_prompt: str, user_prompt: str, preferred_model: str | None) -> tuple[str, str]:
    """Selecciona el primer proveedor disponible y devuelve (proveedor_usado, respuesta)."""
    load_local_env()
    openrouter_key = os.environ.get("OPENROUTER_API_KEY", "").strip()
    if openrouter_key:
        candidates = [preferred_model] if preferred_model else [
            "openrouter/free",
            "nvidia/nemotron-3-ultra-550b-a55b:free",
            "google/gemma-4-31b-it:free",
        ]
        last_err: Exception | None = None
        for model in candidates:
            try:
                text = query_openai_compatible(
                    "https://openrouter.ai/api/v1/chat/completions",
                    openrouter_key,
                    model,
                    system_prompt,
                    user_prompt,
                    extra_headers={"HTTP-Referer": "https://localhost", "X-Title": "Tribunal-Skill"},
                )
                return f"OpenRouter ({model})", text
            except urllib.error.HTTPError as err:
                last_err = err
                if preferred_model or err.code not in (400, 404, 429, 502, 503):
                    raise
        if last_err:
            raise last_err

    deepseek_key = os.environ.get("DEEPSEEK_API_KEY", "").strip()
    if deepseek_key:
        model = preferred_model or "deepseek-chat"
        text = query_openai_compatible(
            "https://api.deepseek.com/chat/completions",
            deepseek_key,
            model,
            system_prompt,
            user_prompt,
        )
        return f"DeepSeek API ({model})", text

    groq_key = os.environ.get("GROQ_API_KEY", "").strip()
    if groq_key:
        model = preferred_model or "llama-3.3-70b-versatile"
        text = query_openai_compatible(
            "https://api.groq.com/openai/v1/chat/completions",
            groq_key,
            model,
            system_prompt,
            user_prompt,
        )
        return f"Groq ({model})", text

    ollama_host = os.environ.get("OLLAMA_HOST", "http://localhost:11434").rstrip("/")
    ollama_models = check_ollama(ollama_host)
    if ollama_models:
        model = preferred_model or next((m for m in ollama_models if "deepseek" in m.lower()), ollama_models[0])
        text = query_ollama(ollama_host, model, system_prompt, user_prompt)
        return f"Ollama Local ({model})", text

    raise RuntimeError(
        "No se encontró ningún proveedor externo configurado. "
        "Configura OPENROUTER_API_KEY (gratis para DeepSeek), DEEPSEEK_API_KEY, GROQ_API_KEY "
        "o inicia Ollama localmente con un modelo como deepseek-r1."
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Segunda opinión externa para /tribunal.")
    parser.add_argument("--archivo", type=str, help="Ruta a un archivo o reporte a evaluar.")
    parser.add_argument("--prompt", type=str, help="Texto o resumen directo a evaluar.")
    parser.add_argument("--rol", choices=list(SYSTEM_PROMPTS.keys()), default="auditor", help="Perfil del auditor.")
    parser.add_argument("--modelo", type=str, default=None, help="Modelo específico opcional.")
    args = parser.parse_args()

    content_parts: list[str] = []
    if args.archivo:
        file_path = Path(args.archivo)
        if not file_path.exists():
            print(f"Error: no existe el archivo '{args.archivo}'.", file=sys.stderr)
            return 2
        content_parts.append(f"### Archivo: {file_path.name}\n{file_path.read_text(encoding='utf-8', errors='replace')[:24000]}")
    if args.prompt:
        content_parts.append(args.prompt)
    if not content_parts and not sys.stdin.isatty():
        content_parts.append(sys.stdin.read()[:24000])

    if not content_parts:
        print("Error: debes indicar --archivo, --prompt o entrada estándar.", file=sys.stderr)
        return 2

    user_prompt = "\n\n".join(content_parts)
    try:
        provider, answer = resolve_provider_and_query(SYSTEM_PROMPTS[args.rol], user_prompt, args.modelo)
    except Exception as exc:
        print(f"[TRIBUNAL-EXTERNO NO DISPONIBLE] {exc}", file=sys.stderr)
        return 1

    print(f"=== Segunda Opinión Externa: {provider} ===\n")
    print(answer.strip())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
