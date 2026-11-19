# Directivas Globales para Agentes de IA — Yunque & Sombra (Godot 4.x)

Este archivo define las reglas permanentes para todos los agentes y subagentes que trabajen en el repositorio. Las skills especializadas se cargan únicamente cuando la tarea lo requiere desde `.agent/skills/`.

---

## 🏛️ 1. Reglas Permanentes de Trabajo (Obligatorias en cada cambio)

1. **Fuente Canónica de Verdad (`docs/idea.txt`):**
   - Antes de diseñar, modificar o refactorizar mecánicas, escenas o narrativa, consulta `docs/idea.txt`. Queda prohibido inventar subsistemas que se desvíen del bucle dual Día (Mostrador/Forja 06:00–17:00) / Noche (Exploración/Mina 17:00–00:00).
2. **Nomenclatura 100% en Español en Escenas (`.tscn`):**
   - Todos los nodos del SceneTree de Godot deben nombrarse en español claro y descriptivo (`EstacionFragua`, `BotonAtizarFuelle`, `ManometroTemperatura`, `ColisionParedes`).
3. **Estándar GDScript 2.0 (Godot 4.x Estricto):**
   - Tipado estático obligatorio en variables, parámetros y retornos (`:=` o tipo explícito; nunca `:=` sobre `Variant`).
   - Prohibida cualquier sintaxis de Godot 3 (`yield`, `onready var`, `export var`, `KinematicBody2D`, `connect("string")`).
   - Desacoplamiento por señales (*Call Down, Signal Up*) y **cero nodos huérfanos** (`queue_free()`).
4. **Registro Histórico (`CRONICA_DE_CAMPO.md`):**
   - Al cerrar un hito, fase o cambio arquitectónico importante, agrega una entrada concisa al final de `CRONICA_DE_CAMPO.md` (reemplaza a la antigua skill `/secretario`).

---

## 🧠 2. Equipo Consolidado de Skills (`.agent/skills/`)

| Skill | Cuándo activarla y qué resuelve |
| :--- | :--- |
| **[`administrador`](.agent/skills/administrador/SKILL.md)** | Jefe Orquestador Asíncrono: divide pedidos complejos y despliega subagentes en paralelo sin bloquear el chat ni cancelar frentes previos. |
| **[`disenador_de_juego`](.agent/skills/disenador_de_juego/SKILL.md)** | Bucle dual Día/Noche, economía, progresión del Libro Brillante, métricas espaciales de niveles 2D y **retroalimentación táctil (*Game Feel*: Tiers de impacto, Trauma Shake en tiempo real, Hit-stop anti-solapamiento, Squash & Stretch)**. |
| **[`direccion_de_arte`](.agent/skills/direccion_de_arte/SKILL.md)** | Identidad visual medieval rústica (*Subject-First Materiality*, veto a clichés de IA, regla 60-30-10, contraste WCAG AAA > 7:1), arquitectura UI/UX (`Anchors`/`Containers`, *Screen Stack*, HUD por señales) y dirección de sonido (5 buses, *pitch jitter* `±7%`, *foley* y *ducking*). |
| **[`programador_godot`](.agent/skills/programador_godot/SKILL.md)** | Arquitectura en Godot 4, GDScript tipado estricto, corrutinas defensivas tras `await`, configuración de capas de física/cámara en `.tscn` y prevención de fugas de memoria. |
| **[`herrero`](.agent/skills/herrero/SKILL.md)** | Árbitro de realismo metalúrgico: inercia térmica en fragua, radiación de cuerpo negro, conservación de volumen en yunque, temple martensítico en agua y afilado en arenisca. |
| **[`playtester`](.agent/skills/playtester/SKILL.md)** | Validación headless de compilación, pruebas destructivas a 60 Hz (SOCD, *corner clipping*, frontera de las 00:00, `orphan nodes = 0`) e inspección visual multimodal de capturas de pantalla. |
| **[`tribunal`](.agent/skills/tribunal/SKILL.md)** | Auditoría profunda bajo demanda: despliega subagentes internos por frentes y cruza el diagnóstico con una segunda opinión externa gratuita vía OpenRouter (`scripts/consultar_externo.py`). |
