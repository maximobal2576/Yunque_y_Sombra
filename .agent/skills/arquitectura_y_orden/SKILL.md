---
name: arquitectura_y_orden
description: >-
  Estándar Canónico de Arquitectura, Estructura de Directorios y Criterios de "Orden" para Godot 4.x.
  Define formalmente qué significa que un proyecto esté "ordenado": raíz limpia (cero scripts sueltos o logs),
  árbol de carpetas por dominios estrictos (src, assets, docs, tests, logs), separación física entre código y arte,
  acoplamiento de escenas .tscn con su .gd correspondiente, y protección de secretos en .gitignore.
  Activa esta skill cuando se reorganice el proyecto, se creen nuevos módulos o se audite el orden del workspace.
---

# 📐 Estándar Canónico de Arquitectura y Orden (`/arquitectura_y_orden`)

Esta skill es la **Constitución Espacial del Proyecto**. Define con precisión matemática qué significa que algo esté *"ordenado"* para que ningún agente ni desarrollador improvise estructuras arbitrarias.

---

## 🏛️ 1. Definición Formal de "Orden"

Un proyecto está **ordenado** si y solo si cumple estos **4 axiomas**:

1. **Axioma de la Raíz Inmaculada:** La raíz solo contiene archivos de configuración del motor y documentación fundacional (`project.godot`, `export_presets.cfg`, `.gitignore`, `README.md`, `AGENTS.md`, `GEMINI.md`, `CLAUDE.md`, `CRONICA_DE_CAMPO.md`). **Queda prohibido cualquier `.bat`, `.py`, `.gd`, `.log`, `.txt` o script ejecutable en la raíz.**
2. **Axioma de Separación de Dominios:** El código y las escenas lógicas viven en `src/`; el arte, fuentes y audio viven en `assets/`; la documentación vive en `docs/`; las herramientas externas viven en `tools/`; y la telemetría en `logs/`. Nunca se mezclan archivos `.gd`/`.tscn` dentro de `assets/` ni texturas sueltas dentro de `src/`.
3. **Axioma de Co-localización de Escenas:** Cada escena `.tscn` vive exactamente al lado de su script controlador `.gd` con el mismo nombre base (ej. `CounterShopView.tscn` y `CounterShopView.gd`).
4. **Axioma de Higiene en Git:** Todo archivo efímero (`*.log`, `.tmp`, cachés, claves en `.env`) debe estar registrado en `.gitignore` antes de crearse.

---

## 🗂️ 2. El Árbol Canónico de Directorios

```plaintext
juego/
├── .agent/skills/          # Skills portables del proyecto (7 oficiales)
├── assets/                 # RECURSOS VISUALES Y ACÚSTICOS (Solo multimedia cruda)
│   ├── audio/              # Música, SFX organizados por foley y ambiente
│   ├── fonts/              # Tipografías (.ttf, .otf)
│   ├── shaders/            # Shaders reutilizables (.gdshader)
│   └── sprites/            # Texturas y hojas de sprites (.png, .svg)
├── docs/                   # DISEÑO Y DOCTRINA (idea.txt, guías, manuales)
├── logs/                   # TELEMETRÍA Y DIAGNÓSTICO (godot_*.log, excluidos de git)
├── screenshots/            # CAPTURAS DE PANTALLA Y AUDITORÍA VISUAL (QA)
├── src/                    # CÓDIGO Y ESCENAS DEL JUEGO (Arquitectura GDScript 4)
│   ├── autoload/           # Singletons globales (GameManager, TimeManager, EventBus)
│   ├── common/             # Clases base, recursos .tres y utilidades compartidas
│   └── scenes/             # Escenas estructuradas por contexto jugable:
│       ├── levels/         # Mapas y escenarios Top-Down (GreyboxTown, Mina)
│       ├── ui/             # Interfaces, modales y HUD persistente (MainHUD)
│       └── workshop/       # Estaciones de trabajo e interacción en primer plano
├── tests/                  # SUITES DE QA Y PLAYTESTING (playtest_*.gd)
└── tools/                  # SUBSISTEMAS AUXILIARES EXTERNOS (voice_assistant, daemons)
```

---

## 🏷️ 3. Reglas de Nomenclatura Estricta

| Tipo de Elemento | Convención | Ejemplo Válido | Prohibido |
| :--- | :--- | :--- | :--- |
| **Carpetas** | `snake_case` (inglés o español neutro) | `scenes/levels/`, `assets/sprites/` | `Mi Carpeta/`, `SCENES/` |
| **Archivos de Escena** | `PascalCase.tscn` | `CounterShopView.tscn` | `counter_shop.tscn`, `Shop.tscn` |
| **Archivos de Script** | `PascalCase.gd` (igual a su `.tscn`) o `snake_case.gd` (utilidades/autoloads) | `CounterShopView.gd`, `game_manager.gd` | `script1.gd`, `test.gd` |
| **Nodos del SceneTree** | **100% Español Descriptivo** | `EstacionFragua`, `BotonAtizarFuelle` | `ForgeNode`, `Button1`, `Node2D` |
| **Señales y Variables** | `snake_case` tipado | `pieza_templada`, `temperatura: float` | `PiezaTemplada`, `temp` |

---

## 🚫 4. Matriz de Errores Comunes de "Desorden"

1. **"El basurero de la raíz":** Crear archivos `.py`, `.bat`, `.log` de prueba directamente donde está `project.godot`.  
   *Solución:* Van a `tools/`, `scripts/` o `logs/`.
2. **"El asset huérfano":** Dejar imágenes `.png` dentro de `src/scenes/workshop/`.  
   *Solución:* Van a `assets/sprites/workshop/`.
3. **"El script descolgado":** Guardar un script en `scripts/` y su escena en `src/scenes/`.  
   *Solución:* Escena y script viven juntos en la misma carpeta dentro de `src/scenes/`.
4. **"Rutas absolutas o rotas":** Mover archivos a mano y romper los `ExtResource` de un `.tscn`.  
   *Solución:* Nunca renombres carpetas sin verificar que los UIDs y `res://` se actualicen.

---

## ✅ 5. Checklist de Verificación de Orden
- [ ] ¿La raíz contiene únicamente `project.godot`, `.gitignore`, `export_presets.cfg` y documentos `.md`?
- [ ] ¿Cada `.tscn` tiene su `.gd` en la misma carpeta?
- [ ] ¿No hay archivos de log (`.log`) ni temporales en git status?
- [ ] ¿Los nombres de nodos en las escenas están 100% en español?
