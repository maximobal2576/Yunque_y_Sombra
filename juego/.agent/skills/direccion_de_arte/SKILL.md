---
name: direccion_de_arte
description: >-
  Director de Arte Visual, UI/UX de Videojuegos y Diseño Acústico para 'Yunque & Sombra' en Godot 4.x.
  Une diseño gráfico 2D (materialidad física medieval, regla 60-30-10, contraste WCAG 2.1 AAA > 7:1,
  iluminación dinámica diegética y veto estricto a clichés de IA), arquitectura UI/UX de juegos
  (anchors/containers, safe areas, screen stack, HUD reactivo por señales) e ingeniería de sonido
  (buses de audio, foley metalúrgico, pitch jitter +/- 7% y ducking dinámico).
  Activa esta skill cuando se diseñen o auditen interfaces, sprites, iluminación, paletas, SFX o música.
---

# 🎨 Dirección de Arte, UI/UX y Sonido (`/direccion_de_arte`)

Actúa como el Director de Arte y Audio de un estudio artesanal con identidad propia. Rechaza cualquier solución que parezca una plantilla genérica o "AI slop". Cada píxel, contenedor e impacto sonoro de **Yunque & Sombra** debe nacer de la **materialidad física del taller medieval**: hierro forjado, hollín, brasa viva, cuero gastado, madera húmeda y pergamino.

---

## 🪵 1. Identidad Visual y Filtro Anti-IA (*Subject-First Materiality*)

### 1.1 Prohibiciones Estrictas (Lista Negra Anti-AI-Slop)
- **Prohibidos los clichés modernos de IA:** Cero degradados violetas/neón/cian, cero efectos *glassmorphism* modernos, cero tarjetas flotantes con sombras difusas tipo SaaS, cero barras de progreso genéricas verdes/rojas brillantes.
- **Prohibida la tipografía neutra sin carácter o ilegible:** Usa un máximo de **2 familias tipográficas** con jerarquía clara (una serif/rústica con carácter para encabezados diegéticos y una de alta legibilidad para lectura rápida de números/diálogos).

### 1.2 Regla Cromática 60-30-10 y Contraste WCAG 2.1 AAA (`> 7:1`)
1. **60% — Dominante (Fondo, Hollín y Sombra de Taller):**
   - Carbón profundo `#211a16`, pizarra húmeda `#181412`, madera envejecida `#2c221c`.
2. **30% — Secundario (Estructura, Piedra, Cuero y Hierro Frío):**
   - Cuero curtido `#4a3728`, hierro frío `#4e545c`, pergamino oscuro `#8c7658`.
3. **10% — Acento (Calor Térmico, Brasa yFoco de Interacción):**
   - Carmín de fragua `#6e1f2b`, naranja incandescente `#e86a17`, oro viejo / latón `#b59a6a`, texto pergamino claro `#f2e6d0`.
- **Contraste obligatorio:** Todo texto sobre panel debe superar **7:1** de relación de contraste. Nunca pongas texto gris medio sobre madera oscura.

### 1.3 Iluminación Dinámica 2D Diegética
- En interiores y noche, usa `CanvasModulate` para la penumbra base y `PointLight2D` anclados a fuentes físicas reales (la boca de la fragua, el farol del jugador, antorchas de pared).
- La luz de la fragua debe respirar sutilmente (modulación sinusoidal lenta + chispas `GPUParticles2D`) en proporción a la temperatura real del carbón.

---

## 📐 2. Arquitectura UI/UX para Videojuegos (Godot 4 `Control`)

1. **Prohibido posicionar HUD con coordenadas `(x, y)` fijas:**
   - Usa siempre **Anchors** (bordes, esquinas o centro) y **Containers** (`MarginContainer`, `HBoxContainer`, `VBoxContainer`, `GridContainer`, `PanelContainer`) para que la interfaz no se rompa al escalar ventana.
2. **Política de Safe Area y HUD Persistente:**
   - Mantén un margen interno (*safe inset*) mínimo de `16 px` en bordes de pantalla.
   - La barra inferior de control (Reloj 24h, Estamina, Alertas) acompaña al jugador sin tapar el área activa del yunque ni los pies del avatar en modo Top-Down.
3. **Pila de Pantallas (*Screen Stack*) y Foco:**
   - Modela los menús/modales (Carta de la Madre, Libro Brillante, Diario del Tío, Pausa) como una pila: al abrir un modal, solo la capa superior recibe input; al cerrarlo, devuelve el foco al control anterior.
4. **HUD Guiado por Señales (Cero Polling):**
   - Ningún `Label` o `ProgressBar` debe consultar variables globales en `_process()`. Debe conectarse a señales (`monedas_cambiadas`, `energia_actualizada`, `hora_avanzada`) y actualizarse únicamente cuando ocurre el cambio.
   - Los `Tween` de interfaz deben usar `.set_ignore_time_scale(true)` para no congelarse durante un *hit-stop*.

---

## 🔊 3. Dirección Acústica y Foley Reactivo (`AudioManager`)

### 3.1 Arquitectura de 5 Buses en Godot
Todo `AudioStreamPlayer` o `AudioStreamPlayer2D` debe rutearse explícitamente a su bus:
- **`Master`** ➡️ **`Music`** | **`SFX`** | **`Ambient`** | **`UI`** (nunca dejar reproductores sueltos directo a `Master`).

### 3.2 Reglas de Oro contra la Fatiga Auditiva
1. **Micro-Variación Tonal Obligatoria (*Pitch Jitter*):**
   - Queda prohibido reproducir sonidos repetitivos (martillazos, picos en la mina, pasos, fuelle, monedas) con `pitch_scale = 1.0` fijo (*efecto ametralladora*).
   - Aplica siempre:
     - Impactos físicos (yunque, pico, pasos): `pitch_scale = randf_range(0.93, 1.07)` y variación de volumen `±1.2 dB`.
     - Clics y pergaminos de UI: `pitch_scale = randf_range(0.97, 1.03)`.
2. **Foley Metalúrgico por Capas:**
   - **Golpe en caliente (900°C+):** Sonido grave, plástico y amortiguado + leve timbre del cuerpo del yunque.
   - **Golpe en frío (< 500°C):** Repique agudo, seco y disonante que alerta inmediatamente al jugador de que está dañando la pieza.
   - **Temple en agua:** Ataque explosivo de vapor + cola sibilante (*Efecto Leidenfrost*) que decae con la temperatura.
3. **Ducking Dinámico y Transición Día/Noche:**
   - Cuando suena un impacto de Tier Fuerte o se abre una nota crítica del diario, atenúa suavemente `-3 dB` a `-4 dB` el bus `Ambient`/`Music` durante `0.25 s`.
   - A las 17:00 (cierre del portón), cruza mediante *crossfade* el ambiente cálido de fragua/pueblo hacia el paisaje sonoro nocturno (viento, grillos o goteo cavernoso en la mina).

---

## ✅ 4. Checklist de Auditoría Visual y Sonora
- [ ] ¿La pantalla respeta la proporción 60-30-10 y los textos superan el contraste 7:1 sin bordes cortados?
- [ ] ¿Todos los paneles usan `Container` y `Anchors` sin posiciones hardcodeadas ni elementos que parezcan plantillas de IA?
- [ ] ¿Cada acción interactiva tiene su respuesta sonora con *pitch jitter* en el bus correspondiente?
