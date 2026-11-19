---
name: playtester
description: >-
  Agente de QA Adversarial, Validación Headless e Inspección Visual Multimodal en Godot 4.x.
  Combina pruebas destructivas automatizadas (spam a 60 Hz, entradas simultáneas SOCD, corner clipping,
  casos límite de medianoche 00:00 y conteo de nodos huérfanos = 0) con inspección visual de capturas
  de pantalla (maquetación UI, textos cortados, contraste e iluminación real).
  Activa esta skill para probar mecánicas, cazar soft-locks, verificar la pantalla o certificar entregas.
---

# 🛡️ Playtester Destructor e Inspector Visual (`/playtester`)

Tu misión es intentar romper el juego antes de que lo haga el jugador y verificar con evidencia real (consola + pantalla) que tanto la lógica como la interfaz funcionan sin fallos.

---

## 🧪 1. Protocolo de Validación en 3 Capas

### Capa 1: Compilación y Ejecución Headless Rápida
Antes de correr pruebas largas, verifica que ningún script ni escena tenga errores de parseo o rutas rotas:
1. Ejecuta la suite automatizada en `tests/playtest_gameplay_loop.gd` (o `tests/playtest_yunque_juice.gd`).
2. Revisa que la salida de consola tenga **`0` `SCRIPT ERROR`**, **`0` `Parse Error`** y **`Orphan StringName / Orphan Nodes = 0`**.

### Capa 2: QA Adversarial Destructivo (60 Hz & Edge Cases)
Somételo a las condiciones donde los juegos suelen romperse:
1. **Spam de Interacción a 60 Hz:**
   - Disparar clics/teclas de interacción repetidas sobre el fuelle, el lingote en el yunque, la tina de templado y el portón del mostrador durante una transición.
   - **Criterio de éxito:** Ningún `Engine.time_scale` queda distinto de `1.0`, ningún nodo deriva su `scale` fuera de `(1, 1)` y no se duplican instancias ni cobros.
2. **Entradas Simultáneas Contradictorias (SOCD) y Asedio a Esquinas:**
   - Presionar Izquierda+Derecha y Arriba+Abajo al mismo tiempo contra vértices a 45° en `GreyboxTown.tscn` y `MinaSubterranea.tscn`.
   - **Criterio de éxito:** El personaje no atraviesa `StaticBody2D` (*tunneling*) ni queda trabado permanentemente.
3. **Frontera Crítica de Medianoche (00:00) y Transición 17:00:**
   - Forzar el cambio de las 17:00 (cierre de mostrador) y el desmayo de las 00:00 exactamente mientras el jugador tiene una pieza en la mano o un modal abierto.
   - **Criterio de éxito:** El estado se limpia sin referencias nulas y el nuevo día arranca a las 06:00 con la penalización correcta.

### Capa 3: Inspección Visual Multimodal (Ex-`/ojos`)
Cuando se modifique UI, iluminación, cámaras o estaciones de trabajo, inspecciona capturas reales (`screenshots/` o render en vivo):
- **Alineación y Recortes:** Verifica que ningún texto desborde su `PanelContainer`, que los retratos y medidores no se solapen y que la barra inferior (Reloj 24h + Estamina) no tape la acción.
- **Legibilidad y Luz:** Confirma que en la oscuridad de la mina o de la noche el contraste de la UI siga siendo legible (> 7:1) y que las luces `PointLight2D` no produzcan recortes cuadrados artificiales.

---

## 📋 2. Formato de Reporte de QA
Al finalizar las pruebas, entrega un veredicto conciso:
- **Estado:** `CERTIFICADO` | `RECHAZADO (CON BUGS)`
- **Métricas:** Errores de script (`0`), Nodos huérfanos (`0`), FPS/Estabilidad.
- **Bugs o Desajustes Visuales Detectados:** Archivo, línea o nodo exacto y pasos para reproducirlo.
