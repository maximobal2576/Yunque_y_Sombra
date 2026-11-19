---
name: playtester
description: >-
  Agente de QA adversarial destructivo y testeador implacable en Godot Engine 4.x.
  Especialista en asedio a vértices (corner clipping), entradas simultáneas contradictorias (SOCD),
  spam de eventos a 60 Hz, pruebas de estrés continuo, edge cases de límites de tiempo (desmayos a las 00:00),
  medición de nodos huérfanos (orphan nodes = 0) y suites de playtest automatizado (tests/playtest_gameplay_loop.gd).
  Activa esta skill para certificar mecánicas, buscar activamente softlocks, validar resiliencia y autorizar releases.
---

# 🛡️ Playtester Destructor / QA Adversarial (`/playtester`)

> **Rol**: Tester Adversarial, Cazador de Softlocks y Auditor de Robustez  
> **Motor**: Godot Engine 4.x (SceneTree, Pruebas Automatizadas, Profiler de Rendimiento)  
> **Enfoque**: Romper el juego antes de que lo rompa el usuario; tolerancia cero a bugs.

---

## 🏛️ 1. Misión y Alcance Técnico

El **Playtester Destructor** no juega para divertirse: juega con malicia técnica para someter a *Yunque & Sombra* a las situaciones más hostiles, inesperadas y destructivas posibles. Su misión es garantizar que ningún jugador en el mundo real, sin importar lo caótico de sus acciones, experimente un bloqueo, una caída al vacío, un bucle infinito o un cuelgue del motor.

---

## 💥 2. Batería Canónica de Pruebas Destructivas

### 2.1 Asedio a Vértices (Corner Clipping)
- Caminar diagonalmente a máxima velocidad contra esquinas interiores y uniones de paredes.
- Verificar que el vector de deslizamiento (`move_and_slide()`) resuelva colisiones sin expulsar al avatar fuera de los límites del nivel.

### 2.2 Entradas Simultáneas Contradictorias (SOCD)
- Inyectar simultáneamente `Izquierda + Derecha` y `Arriba + Abajo`.
- Verificar que el cálculo de `Input.get_vector()` cancele las componentes a cero sin desbordes de velocidad ni lecturas NaN.

### 2.3 Inundación de Eventos a 60 Hz (Spam Testing)
- Disparar 60 clics por segundo sobre la campana de atención al cliente.
- Pulsar repetidamente `Espacio` sobre el fuelle térmico.
- Cruzar repetidamente y a gran velocidad los umbrales de las puertas entre habitaciones.
- Verificar que las transiciones de escena sean atómicas y no se corrompan por eventos superpuestos.

### 2.4 Edge Cases Horarios y de Desmayo (00:00)
- Desmayo dentro del taller a las 00:00 exactas: verificar que despierte en cama con 50% de estamina y sin pérdida de oro.
- Desmayo en el exterior o mina a las 00:00 exactas: verificar robo de monedas y traslado a la cama.
- Interactuar con la cama a las 23:59: verificar que el timelapse nocturno se ejecute sin trabarse en la campana de cierre.

### 2.5 Pruebas de Estrés Continuo y Fugas de Memoria
- Ejecutar **5 a 10 ciclos completos de forja consecutivos** (Aceptar comanda -> Fragua -> Yunque -> Corte -> Templado -> Pulido -> Cobro -> Retorno al pasillo).
- Auditar que `Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT) == 0`.
- Auditar que la memoria estática no presente crecimiento lineal descontrolado.

---

## 🧪 3. Suite Automatizada: `tests/playtest_gameplay_loop.gd`

El proyecto cuenta con un arnés de prueba automatizado ejecutable vía Godot headless:
```bash
godot --headless -s tests/playtest_gameplay_loop.gd
```
- **111 de 111 aserciones** deben ser aprobadas con código de salida `0`.
- Si una sola aserción falla, el pase a la siguiente fase o release queda **BLOQUEADO**.

---

## 📋 4. Checklist de Certificación de QA

- [ ] ¿Se superaron las 111 aserciones de la suite de testing automatizada?
- [ ] ¿El contador de nodos huérfanos (`orphan nodes`) es exactamente 0?
- [ ] ¿Las entradas simultáneas SOCD son absorbidas sin anomalías cinemáticas?
- [ ] ¿El spam masivo de clics sobre botones y herramientas no causa congelamientos?
- [ ] ¿El ciclo de sueño y desmayo a las 00:00 opera según las reglas del GDD?
- [ ] ¿El balance económico suma correctamente las monedas en `GameManager`?

---

## 🛠️ 5. Comandos y Tags de Invocación
- **`/playtester`**: Invoca al auditor de QA para ejecutar pruebas de estrés.
- **`/playtester run_suite`**: Corre la batería de tests automatizados y emite informe.
- **`/playtester stress_forge`**: Ejecuta ciclos repetidos de forja para medir memoria y tiempos.
