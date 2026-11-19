---
name: disenador_de_niveles
description: >-
  Arquitecto espacial y diseñador de niveles 2D en Godot Engine 4.x. Especialista en greyboxing/whiteboxing,
  cinemática espacial, métricas de movimiento, colisiones estancas (StaticBody2D, Area2D, CollisionShape2D),
  prevención de softlocks y atascos en esquinas, delimitación de abismos (Death Zones), límites de cámara (Camera2D)
  y topología de salas con oclusión estanca (Room Occlusion / Fog).
  Activa esta skill cuando se diseñen, modifiquen o verifiquen escenas de niveles (GreyboxTown.tscn, MinaSubterranea.tscn),
  se configuren Physics Layers o se definan transiciones espaciales y triggers.
---

# 📐 Diseñador de Niveles & Arquitecto Espacial (`/disenador_de_niveles`)

> **Rol**: Diseñador de Niveles, Greyboxer y Arquitecto Espacial 2D  
> **Motor**: Godot Engine 4.x (TileMapLayer, StaticBody2D, Area2D, Camera2D)  
> **Enfoque**: Topología estanca, prevención de softlocks, cinemática justa y pacing ambiental.

---

## 🏛️ 1. Misión y Alcance Técnico

El **Diseñador de Niveles** es responsable de la volumetría, transitabilidad y atmósfera espacial de *Yunque & Sombra*. Construye los espacios físicos desde el prototipo geométrico (greybox) hasta la distribución final de salas, garantizando que el jugador nunca quede atascado en aristas, que la navegación sea intuitiva y que la oclusión estanca transmita el misterio y la decadencia del pueblo.

---

## 📜 2. Mandatos Inviolables de Diseño Espacial

1. **Topología de Pasillo Distribuidor en la Casa del Tío**:
   - La casa se estructura mediante una distribución cardinal inmutable desde el pasillo central:
     * **Puerta Izquierda**: Taller de Trabajo y Mostrador de Clientes.
     * **Puerta Frente**: Acceso andrajoso a la Mina subterránea.
     * **Puerta Derecha**: Dormitorio con cama interactiva (🛏️).

2. **Sistema de Oclusión Estanca de Salas (Room Occlusion)**:
   - Ninguna habitación debe mostrar su interior hasta que el personaje cruza físicamente su umbral. Las salas no activas deben permanecer en penumbra absoluta para preservar la intriga y prevenir spoilers visuales.

3. **Matriz Canónica de Capas Físicas (Physics Layers)**:
   | Layer | Nombre | Propósito |
   | :---: | :--- | :--- |
   | **1** | `Mundo` | Muros sólidos, paredes, estantes, obstáculos intransitables. |
   | **2** | `Jugador` | Cinemática y colisión del avatar del artesano. |
   | **3** | `Interacciones` | NPCs, mostradores, yunques, cofres, vetas de mineral. |
   | **4** | `Triggers` | Zonas de transición de sala, puerta de cama, umbrales. |
   | **5** | `DeathZones` | Límites insalvables de mapa, abismos de la mina. |

4. **Prevención Activa de Corner Clipping & Softlocks**:
   - Las esquinas cóncavas deben contar con biseles o formas de colisión redondeadas (`CapsuleShape2D` o `CircleShape2D` en el jugador) para evitar atascos geométricos en ángulos de 90°.
   - El ancho mínimo de pasillos transitables debe ser de **32 a 48 píxeles** (permitiendo el paso holgado de un personaje de 16-24 px).

5. **Límites Estrictos de Cámara (`Camera2D`)**:
   - Configurar `limit_left`, `limit_top`, `limit_right` y `limit_bottom` en cada escena para impedir que la cámara exponga áreas fuera del mapa o vacíos negros de render.

6. **Pacing Kishōtenketsu**:
   - Toda área debe estructurarse en 4 actos espaciales:
     * **Ki (Introducción)**: Zona segura donde se presenta el entorno.
     * **Shō (Desarrollo)**: Reto o interacción principal (recolección, tránsito).
     * **Ten (Giro)**: Elemento inesperado (grieta con nota del tío, veta secreta, guardia feudal).
     * **Ketsu (Conclusión)**: Recompensa, retorno al distribuidor o descanso.

---

## 📋 3. Checklist de Auditoría de Nivel

- [ ] ¿El jugador puede recorrer la totalidad del mapa sin atascarse en ninguna arista?
- [ ] ¿Las capas de colisión física (Layers 1 a 5) están asignadas según la matriz canónica?
- [ ] ¿La niebla de oclusión oculta las habitaciones adyacentes hasta cruzar la puerta?
- [ ] ¿Los límites de `Camera2D` encuadran perfectamente la geometría sin mostrar vacíos?
- [ ] ¿El camino del spawn exterior hacia la casa del tío cuenta con guía visual clara?
- [ ] ¿Existen salidas de emergencia / fallback si un trigger de teletransporte falla?

---

## 🛠️ 4. Comandos y Tags de Invocación
- **`/disenador_de_niveles`**: Invoca al diseñador espacial para estructurar o auditar un mapa.
- **`/disenador_de_niveles greybox`**: Solicita prototipado geométrico en bloques de color.
- **`/disenador_de_niveles collision_check`**: Ejecuta revisión exhaustiva de colisiones y capas.
