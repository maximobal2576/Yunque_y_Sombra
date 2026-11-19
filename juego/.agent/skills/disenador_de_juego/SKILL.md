---
name: disenador_de_juego
description: >-
  Diseñador de Juego, Economía, Niveles y Retroalimentación Táctil (Game Feel / Juice) para 'Yunque & Sombra'
  en Godot 4.x. Gobierna el bucle dual Día/Noche (forja comercial 06:00-17:00 y exploración/mina 17:00-00:00),
  el balanceo de estamina, precios y árbol del Libro Brillante, la topología espacial 2D libre de soft-locks
  y la respuesta visceral a cada acción del jugador (Tiers de feedback, Trauma Shake en tiempo real, Hit-stop
  resistente a impactos solapados, Squash & Stretch con conservación de área y cinética exponencial).
  Activa esta skill cuando se diseñen o calibren mecánicas, economía, niveles, progresión o feedback al jugador.
---

# 🎮 Diseñador de Juego, Niveles y Retroalimentación (`/disenador_de_juego`)

Eres el responsable de que **Yunque & Sombra** se sienta satisfactorio en los primeros 30 segundos, mantenga tensión y flujo durante las 24 horas del reloj del juego, y responda con peso físico real a cada clic o tecla del jugador.

---

## 🔄 1. Diseño del Bucle Jugable, Economía y Progresión

### 1.1 Regla de los 30 Segundos y el Bucle Dual
Todo cambio de diseño debe fortalecer la conexión entre las dos mitades del día:
1. **Fase Día (06:00 a 17:00) — Mostrador y Forja:**
   - **Acción:** Abrir portón ➡️ recibir cliente ➡️ calentar en fragua ➡️ moldear en yunque ➡️ templar en agua ➡️ afilar ➡️ cobrar monedas.
   - **Tensión:** Gestión de temperatura, precisión de golpe y paciencia del cliente sin caer en frenesí arcade artificial.
2. **Fase Tarde/Noche (17:00 a 00:00) — Exploración y Mina Top-Down:**
   - **Acción:** Bajar portón ➡️ encender farol ➡️ explorar pueblo o mina trasera ➡️ picar carbón/hierro y hallar hojas del diario ➡️ dormir antes de las 00:00.
   - **Tensión:** Oscuridad, consumo de estamina por golpe de pico y el límite estricto de medianoche (desmayo a las 00:00 con penalización de energía).

### 1.2 Balanceo de Recursos y Progresión ("El Libro Brillante")
- **Economía cerrada:** Toda moneda ganada en el mostrador debe tener un destino deseado:
  1. **Desbloqueos del Libro Brillante** (muela de afilar, tenazas dobles, tobera reforzada).
  2. **Mueblería de Juan (Confort):** Aumenta la recuperación de estamina nocturna.
  3. **Reparación del taller:** Exige forjar clavos propios + madera para destapar narrativa ambiental.
- **Curva emocional (Efecto *Good Pizza, Great Pizza*):**
  - *Días 1 a 4 (Cozy / Calidez):* Pedidos nobles (clavos, herraduras, azadas), vecinos agradecidos, aprendizaje sin castigo severo.
  - *Días 5+ (Conspiración Feudal):* Emisarios exigentes, pedidos de armas o cadenas, presión tributaria y dilemas morales rumbo al clímax del destierro.

---

## 🗺️ 2. Diseño Espacial y de Niveles 2D (`GreyboxTown` / `MinaSubterranea`)

1. **Mide desde el código, nunca de memoria:**
   - Lee `SPEED`, `ACCEL` y el radio del `CollisionShape2D` del jugador antes de dimensionar pasillos o puertas.
   - **Holgura mínima de paso:** Todo corredor o puerta debe medir al menos **`2.2x` el ancho del colisionador del jugador** para evitar atascos en esquinas (*corner snagging*).
2. **Blockout y Grafo de Salas:**
   - Define primero el **camino crítico** (Taller ↔ Maderera ↔ Entrada de Mina) y el **golden path** (la ruta natural iluminada por faroles).
   - **Pacing en diente de sierra:** En la mina, alterna cámaras estrechas de trabajo/tensión con descansos seguros antes de cada veta profunda o nota del tío.
3. **Verificación anti-Softlock:**
   - Ninguna llave, mineral requerido o salida puede quedar detrás de su propia condición o de un estrechamiento sin retorno.
   - Usa cápsulas o círculos (`CapsuleShape2D` / `CircleShape2D`) en los pies del avatar para deslizar suavemente sobre vértices de paredes (`StaticBody2D`).

---

## ⚡ 3. Retroalimentación según Acciones del Jugador (*Game Feel & Juice*)

> **Principio fundamental:** La retroalimentación vende la acción disparando **2 a 4 respuestas breves y coordinadas en el mismo frame** (movimiento visual, deformación, sonido, partículas), pero **nunca altera la simulación física** (el *shake* solo mueve `Camera2D.offset`; el *hit-stop* solo escala `Engine.time_scale`).

### 3.1 Arquitectura por Señales y Niveles de Impacto (Tiers)
- Engancha siempre el feedback a señales discretas (`golpe_yunque`, `fuelle_accionado`, `pieza_templada`, `veta_rota`), jamás haciendo *polling* en `_process`.
- Mantén la proporcionalidad en todo el juego respetando esta tabla:

| Nivel (Tier) | Trauma (`add_trauma`) | Hit-Stop (`duración`) | Partículas | Escala (Squash/Stretch) | Eventos de ejemplo en *Yunque & Sombra* |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Leve (`small`)** | `0.08 – 0.15` | `0.0 s` (ninguno) | `2 – 5` | `1.12 x 0.88` (0.12 s) | Paso, hover/clic UI, soplar fuelle, moneda |
| **Medio (`medium`)** | `0.28 – 0.45` | `0.03 – 0.05 s` | `8 – 15` | `1.25 x 0.78` (0.16 s) | Martillazo normal en yunque, picar roca, cortar |
| **Fuerte (`large`)** | `0.65 – 0.90` | `0.07 – 0.11 s` | `20 – 35` | `1.38 x 0.68` (0.22 s) | Golpe crítico en naranja óptimo, romper veta, desmayo |

### 3.2 Patrones Técnicos Verificados para Godot 4.x

#### A. Screen Shake por Trauma Cuadrático en Tiempo Real
Usa `trauma * trauma` (los golpes leves apenas vibran; los pesados sacuden con fuerza), decae en **tiempo real** (para que la cámara no quede congelada descentrada durante un *hit-stop*) y usa senos sumados a frecuencias primas (nunca `randf()` por frame, que vibra como estática):

```gdscript
# En la Camera2D. Escribe solo en offset/rotation visuales.
@export var decaimiento: float = 1.4
@export var desplazamiento_max: Vector2 = Vector2(10.0, 7.0)
@export var rotacion_max: float = 0.06
@export var intensidad_usuario: float = 1.0 # Opción de accesibilidad 0.0..1.0

var trauma: float = 0.0
var _reloj_shake: float = 0.0

func agregar_trauma(cantidad: float) -> void:
	trauma = clampf(trauma + cantidad, 0.0, 1.0)

func _process(delta: float) -> void:
	if trauma <= 0.0:
		return
	var delta_real: float = delta / maxf(Engine.time_scale, 0.0001)
	trauma = maxf(trauma - decaimiento * delta_real, 0.0)
	var sacudida: float = trauma * trauma * intensidad_usuario
	_reloj_shake += delta_real * 30.0
	offset = Vector2(
		desplazamiento_max.x * sacudida * sin(_reloj_shake * 1.7),
		desplazamiento_max.y * sacudida * sin(_reloj_shake * 2.3)
	)
	rotation = rotacion_max * sacudida * sin(_reloj_shake * 1.1)
	if trauma == 0.0:
		offset = Vector2.ZERO
		rotation = 0.0
```

#### B. Hit-Stop que Sobrevive a Impactos Solapados
Si el jugador da dos martillazos a 30 ms de distancia, el primer timer no debe restaurar `Engine.time_scale = 1.0` a mitad del segundo impacto, y el timer debe correr con `ignore_time_scale = true`:

```gdscript
var _id_hit_stop: int = 0

func aplicar_hit_stop(duracion: float = 0.045, escala_lenta: float = 0.05) -> void:
	_id_hit_stop += 1
	var mi_id: int = _id_hit_stop
	Engine.time_scale = escala_lenta
	# 4to argumento ignore_time_scale = true (imprescindible para que no se congele el timer)
	await get_tree().create_timer(duracion, true, false, true).timeout
	if mi_id == _id_hit_stop:
		Engine.time_scale = 1.0
```

#### C. Squash, Stretch y Overshoot sin Deriva de Escala
Mata siempre el Tween anterior antes de disparar uno nuevo sobre el mismo nodo (ej. spam de clics en el fuelle o lingote) y usa `set_ignore_time_scale(true)` en UI:

```gdscript
var _tween_escala: Tween

func pulso_elastico(nodo: CanvasItem, deformacion: Vector2 = Vector2(1.25, 0.78), duracion: float = 0.16) -> void:
	if _tween_escala and _tween_escala.is_valid():
		_tween_escala.kill()
	nodo.scale = deformacion
	_tween_escala = nodo.create_tween().set_ignore_time_scale(true)
	_tween_escala.tween_property(nodo, "scale", Vector2.ONE, duracion) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
```

#### D. Cinética de Movimiento Top-Down Independiente de FPS
- Usa interpolación exponencial: `velocity = velocity.lerp(direccion * SPEED, 1.0 - exp(-aceleracion * delta))`.
- **Turn-Around Boost:** Si `direccion.dot(velocity.normalized()) < 0.0`, multiplica la aceleración por `2.5` para que cambiar de dirección en callejones o en la mina sea instantáneo y sin sensación de "patinar sobre hielo".

---

## ✅ 4. Checklist de Verificación antes de dar por cerrada una mecánica
- [ ] ¿La acción dispara al menos 2 canales de feedback simultáneos (visual + sonoro) conectados por señal?
- [ ] ¿Si se dispara el evento 10 veces seguidas en 0.3 s, `Engine.time_scale` vuelve exactamente a `1.0` y `scale` vuelve a `Vector2.ONE`?
- [ ] ¿El costo de tiempo/estamina/monedas de la acción encaja en el reloj de 06:00 a 00:00 sin romper la economía?
