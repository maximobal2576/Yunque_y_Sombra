---
name: programador_godot
description: >-
  Arquitecto de Software y Programador de Gameplay en Godot Engine 4.x (GDScript 2.0 estricto).
  Diseña y mantiene Autoloads, máquinas de estados (FSM), señales tipadas, escenas (.tscn),
  capas de física/colisiones 2D y gestión de memoria sin nodos huérfanos. Incluye reglas estrictas
  anti-Godot 3, corrutinas defensivas y validación headless de compilación.
  Activa esta skill cuando se creen, modifiquen o depuren scripts (.gd), escenas (.tscn) o project.godot.
---

# 💻 Programador de Gameplay y Arquitectura Godot 4 (`/programador_godot`)

Escribe GDScript 2.0 fuertemente tipado que compile sin advertencias en la versión de Godot del proyecto (`project.godot`), mantenga las escenas `.tscn` limpias con nodos 100% en español y garantice `0` nodos huérfanos.

---

## 🚫 1. Reglas Duras Anti-Godot 3 (GDScript 2.0 Exclusivo)

1. **Sintaxis Godot 4 obligatoria:**
   - Usa `@export`, `@onready`, `@tool`, `await señal`, `señal.emit()`, `señal.connect(callable)`, `escena.instantiate()`.
   - En `CharacterBody2D`, asigna `velocity` y llama a `move_and_slide()` **sin argumentos**.
   - **Prohibido usar APIs de Godot 3:** `yield()`, `export var`, `onready var`, `connect(" string ")`, `instance()`, `KinematicBody2D`, ` Tween` como nodo del árbol (usa `create_tween()`).
2. **Tipado Estático Estricto (`:=` y tipos explícitos):**
   - Tipa cada variable miembro, constante, parámetro y valor de retorno (`-> void`, `-> int`, `-> bool`).
   - **Cuidado con `:=` sobre `Variant`:** No uses `:=` cuando el lado derecho devuelve `Variant` (ej. un diccionario sin tipar, `JSON.parse_string()` o `Array` genérico), porque Godot 4 lanza error de parseo (`Cannot infer the type`). En esos casos declara el tipo explícito (`var datos: Dictionary = ...`).
3. **Ciclo de Vida Correcto:**
   - `_init()`: El nodo aún no está en el árbol ni tiene hijos.
   - `_ready()`: Los hijos ya están listos; usa `@onready` para cachear referencias.
   - `_physics_process(delta: float)`: Movimiento, física y colisiones (`move_and_slide`).
   - `_process(delta: float)`: Efectos visuales e interpolaciones no físicas.

---

## 🏗️ 2. Arquitectura de Escenas (`.tscn`), Física 2D y Señales

1. **Nomenclatura 100% en Español en el SceneTree:**
   - Todos los nodos dentro de archivos `.tscn` deben llamarse en español claro y descriptivo (`EstacionFragua`, `BotonAtizarFuelle`, `ColisionParedes`, `LuzFragua`, `DetectorInteraccion`).
2. **Composición y Desacoplamiento ("Call Down, Signal Up"):**
   - Un nodo padre puede llamar métodos directos de sus hijos, pero un nodo hijo **nunca** debe acoplarse a su padre con `get_parent().metodo()`: debe emitir una `signal` tipada hacia arriba.
   - Usa Autoloads (`GameManager`, `TimeManager`, `AudioManager`, `EventBus`) solo para estado transversal del juego, nunca como bolsas de variables temporales de una escena.
3. **Corrutinas Defensivas (`await`):**
   - Todo código después de un `await` puede ejecutarse varios frames más tarde, cuando el nodo ya fue liberado o cambió de escena. Verifica `if not is_inside_tree(): return` o `is_instance_valid(self)` después de cualquier `await` si el nodo puede destruirse.
4. **Física 2D, Colisiones y Límites de Cámara:**
   - Separa claramente las capas de física (*Physics Layers*): Entorno estático (`StaticBody2D`), Jugador (`CharacterBody2D`), Áreas interactivas (`Area2D`) y Zonas de peligro/abismo.
   - Configura siempre los `limit_left`, `limit_top`, `limit_right`, `limit_bottom` de la `Camera2D` para no mostrar vacío fuera del mapa, y usa oclusión/niebla en salas cerradas de la mina.
5. **Cero Nodos Huérfanos (*Zero Orphan Nodes*):**
   - Todo nodo instanciado dinámicamente (`instantiate()`) que no se agregue al árbol con `add_child()` o que se retire con `remove_child()` debe liberarse explícitamente con `queue_free()`.

---

## 🔍 3. Verificación Obligatoria Antes de Terminar

- **No dejes archivos a medias (`# ...`):** Escribe siempre la implementación completa y funcional.
- **No edites `.tscn` a ciegas:** Si modificas un `.tscn` por texto, verifica que cada `ext_resource` y `sub_resource` conserve su `id` intacto y que no queden rutas `res://` rotas.
- **Validación por consola (cuando el binario de Godot esté disponible):**
  - Verifica que no existan errores de compilación ni `SCRIPT ERROR` ejecutando una corrida corta headless o la suite en `tests/playtest_gameplay_loop.gd`.
