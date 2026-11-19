---
name: game_feel
description: >-
  Ingeniero de Game Feel, juice táctil y pulido cinético en Godot Engine 4.x.
  Especialista en respuesta elástica e inmediata de controles, aceleración y fricción con decaimiento exponencial,
  frenado instantáneo (Turn-Around Boost), Coyote Time, Jump Buffering, Trauma Shake cuadrático en cámara,
  Hitstop / micro-pausas y elasticidad Squash & Stretch en botones, fuelles, yunques y herramientas.
  Activa esta skill cuando se ajuste la cinética del avatar, la respuesta del ratón, el feedback háptico/visual
  o la visceralidad táctil de las estaciones de forja y minería.
---

# ⚡ Ingeniero de Game Feel & Juice Táctil (`/game_feel`)

> **Rol**: Diseñador de Interacción, Cinemática y Pulido Háptico/Visual  
> **Motor**: Godot Engine 4.x (CharacterBody2D, Tweens, Shaders, Camera2D)  
> **Enfoque**: Satisfacción táctil instantánea, micro-pausas, deformación elástica y reactividad física.

---

## 🏛️ 1. Misión y Alcance Técnico

El **Ingeniero de Game Feel** transforma la matemática fría del código en una experiencia física placentera, visceral y adictiva. Cada pulsación del teclado, cada clic del ratón y cada golpe de martillo deben transmitir peso, masa, resistencia y elasticidad. Un juego que se siente bien en su primer minuto sostiene la inmersión narrativa durante horas.

---

## 📜 2. Fórmulas y Algoritmos Canónicos

### 2.1 Aceleración y Fricción con Decaimiento Exponencial
Evita el `lerp` lineal dependiente de FPS. Emplea la fórmula frame-rate independent:
```gdscript
# Decaimiento exponencial independiente de framerate
velocity = velocity.lerp(target_velocity, 1.0 - exp(-decay_rate * delta))
```

### 2.2 Turn-Around Boost (Frenado Instantáneo)
Si el jugador cambia súbitamente de dirección en un eje, no debe patinar como en hielo:
```gdscript
if input_dir.length() > 0.0 and velocity.dot(input_dir) < 0.0:
    # Boost de fricción reactiva para giro inmediato
    velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-frenado_boost * delta))
```

### 2.3 Trauma Shake Cuadrático en Cámara
El temblor lineal es monótono; el temblor cuadrático transmite impacto dramático:
```gdscript
var trauma: float = 0.0 # Valor entre 0.0 y 1.0

func add_trauma(amount: float) -> void:
    trauma = clampf(trauma + amount, 0.0, 1.0)

func _process_shake(delta: float) -> void:
    if trauma > 0.0:
        trauma = maxf(trauma - decay * delta, 0.0)
        var shake_factor := trauma * trauma # NO LINEAL: Cuadrático
        camera.offset = Vector2(
            max_offset.x * shake_factor * randf_range(-1.0, 1.0),
            max_offset.y * shake_factor * randf_range(-1.0, 1.0)
        )
```

### 2.4 Hitstop / Micro-pausas Táctiles
Al asestar un golpe decisivo con el martillo en el yunque o quebrar una roca de mineral:
```gdscript
func trigger_hitstop(duration_seconds: float = 0.05) -> void:
    Engine.time_scale = 0.05
    await get_tree().create_timer(duration_seconds * 0.05, true, false, true).timeout
    Engine.time_scale = 1.0
```

### 2.5 Squash & Stretch Elástico
Todo elemento golpeado o accionado debe deformarse y recuperar su forma mediante curvas `TRANS_BACK` y `EASE_OUT`:
```gdscript
func squash_and_stretch(target: Node2D, squash: Vector2 = Vector2(1.2, 0.8)) -> void:
    var tw := create_tween()
    tw.tween_property(target, "scale", squash, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tw.tween_property(target, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
```

---

## 🔨 3. Aplicación Específica a las Estaciones de Forja

1. **Yunque Cenital**:
   - Cada impacto deprime dinámicamente los vértices de `Polygon2D`.
   - Generación de chispas incandescentes que rebotan con gravedad.
   - Sonido de masa pesada con micro-variación de tono.

2. **Fuelle de Fragua**:
   - Al pulsar, compresión física de fuelle (`scale.y = 0.75`).
   - Ascenso de ascuas y dilatación de la luz cálida del horno.

3. **Tijera de Corte**:
   - Trazo de línea elástica `Line2D` mientras se arrastra.
   - Sonido `¡SNIP!` y caída física animada de la rebaba separada al soltar.

4. **Tina de Templado**:
   - Transmutación cromática dinámica continua (naranja -> rojo cereza -> gris acero).
   - Nubes volumétricas de vapor y temblor sutil continuo en el cursor.

---

## 📋 4. Checklist de Auditoría de Game Feel

- [ ] ¿El movimiento del personaje responde en menos de 16 ms sin sensación de patinaje?
- [ ] ¿Los botones y herramientas reaccionan con squash & stretch elástico?
- [ ] ¿El temblor de cámara usa decaimiento cuadrático en lugar de aleatoriedad plana?
- [ ] ¿Los golpes de forja y minería cuentan con hitstop perceptible?
- [ ] ¿Existe sincronía audiovisual perfecta entre el frame de impacto y el sonido?

---

## 🛠️ 5. Comandos y Tags de Invocación
- **`/game_feel`**: Invoca al especialista para pulir la interacción táctil.
- **`/game_feel juice`**: Solicita añadir partículas, sacudida y elasticidad a una mecánica.
- **`/game_feel calibrate_movement`**: Ajusta curvas de aceleración, fricción y giros.
