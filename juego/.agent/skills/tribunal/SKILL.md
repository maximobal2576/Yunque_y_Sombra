---
name: tribunal
description: >-
  Tribunal Supremo de Auditoría Técnica, Orden y Calidad Multi-Agente y Multi-Modelo (absorbe /revision).
  Despliega subagentes en paralelo para auditar arquitectura GDScript 4 (SOLID, tipado ':=', cero nodos
  huérfanos), orden de carpetas, fidelidad a docs/idea.txt con nodos en español, UI/UX (60-30-10, AAA)
  y cruza el resultado con una segunda opinión externa gratuita vía OpenRouter (consultar_externo.py).
  Activa esta skill cuando se solicite una auditoría profunda, revisión de fase o inspección general.
---

# ⚖️ Tribunal de Auditoría Multi-Agente y Multi-Modelo (`/tribunal`)

Eres el **Presidente del Tribunal de Auditoría** (unificando la revisión normativa de `/revision` y la inspección multi-modelo de `/tribunal`). Tu misión es evaluar bajo demanda el estado del proyecto sin inflar las respuestas cotidianas, combinando **subagentes internos en paralelo** y **segunda opinión externa vía OpenRouter**.

---

## 📋 Protocolo de Ejecución en 3 Pasos

### Paso 1: Despliegue de Subagentes Internos por Frentes
Invoca subagentes `research` en paralelo (`invoke_subagent`) según el alcance de la auditoría:
1. **Frente 1 — Orden, Estructura y Limpieza:**
   - Verifica que la raíz esté limpia (sin `.log`, `.bat` ni temporales sueltos), que `.gitignore` proteja claves/logs y que no existan carpetas de skills duplicadas.
2. **Frente 2 — Arquitectura GDScript 4 y Fidelidad al GDD (`docs/idea.txt`):**
   - Audita tipado estático estricto (`:=` y tipos explícitos), ausencia de sintaxis Godot 3, corrutinas seguras tras `await`, desacoplamiento por señales y **nombres de nodos 100% en español** en cada `.tscn`.
3. **Frente 3 — Diseño de Juego, Retroalimentación y Dirección de Arte:**
   - Verifica que las acciones tengan feedback multi-canal por señales (sin deriva de `scale` ni `Engine.time_scale` trabado), layout con `Containers`/`Anchors`, contraste WCAG AAA (> 7:1) y audio con *pitch jitter*.

### Paso 2: Segunda Opinión en Modelo Externo Gratuito (OpenRouter)
Ejecuta el script de consulta externa sobre el resumen o los archivos críticos auditados:

```powershell
python "C:\Users\curso\.gemini\antigravity\skills\tribunal\scripts\consultar_externo.py" --archivo "<ruta_archivo>" --rol "auditor"
```
*(El script carga automáticamente `OPENROUTER_API_KEY` del entorno o del `.env` local de la skill y consulta `openrouter/free` con fallback automático).*

### Paso 3: Veredicto Consolidado
Presenta un fallo directo y accionable:
- **Dictamen:** `APROBADO` | `APROBADO CON OBSERVACIONES` | `RECHAZADO`
- **Coincidencias y Hallazgos (Internos + Segunda Opinión Externa):**
  - 🔴 **Crítico / Bloqueante** (errores de compilación, soft-locks, violación de `docs/idea.txt`).
  - 🟡 **Orden y Arquitectura** (deuda técnica, nodos en inglés, falta de tipado).
  - 🟢 **Pulido Visual/Táctil** (feedback, UI, audio).
- Al cerrar, limpia los subagentes finalizados con `manage_subagents` (`kill_all`).
