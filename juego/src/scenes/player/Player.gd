# Player.gd
# Controlador de personaje con cinemática táctil, animación articulada de extremidades y juice (/game_feel)
# Nomenclatura de nodos 100% en español conforme a docs/idea.txt §8.2
extends CharacterBody2D

signal interact_focus_changed(target_text: String)

@export var max_speed: float = 190.0
@export var acceleration: float = 2400.0
@export var friction: float = 2600.0
@export var turn_boost: float = 4000.0

const SPEED: float = 190.0
const COLOR_MENA_HIERRO_DULCE: Color = Color(0.72, 0.76, 0.82, 1.0)
const COLOR_MENA_ACERO_CARBONO: Color = Color(0.28, 0.30, 0.34, 1.0)
const COLOR_MENA_BRONCE_COBRE: Color = Color(0.84, 0.56, 0.28, 1.0)

@onready var detector_interaccion: Area2D = get_node_or_null("DetectorInteraccion") if has_node("DetectorInteraccion") else get_node_or_null("InteractDetector")
@onready var raiz_visual: Node2D = get_node_or_null("RaizVisual") if has_node("RaizVisual") else get_node_or_null("VisualRoot")
@onready var camara_jugador: Camera2D = get_node_or_null("CamaraJugador") if has_node("CamaraJugador") else get_node_or_null("Camera2D")
@onready var bota_izquierda: Node2D = raiz_visual.get_node_or_null("BotaIzquierda") if raiz_visual else null
@onready var bota_derecha: Node2D = raiz_visual.get_node_or_null("BotaDerecha") if raiz_visual else null
@onready var brazo_izquierdo: Node2D = raiz_visual.get_node_or_null("BrazoIzquierdo") if raiz_visual else null
@onready var brazo_derecho: Node2D = raiz_visual.get_node_or_null("BrazoDerecho") if raiz_visual else null
@onready var rostro_mirada: Node2D = raiz_visual.get_node_or_null("CabezaArtesano/RostroMirada") if raiz_visual else null
@onready var mena_en_mano: Node2D = raiz_visual.get_node_or_null("MenaEnMano") if raiz_visual else null
@onready var cuerpo_mineral_mano: Polygon2D = mena_en_mano.get_node_or_null("CuerpoMineral") as Polygon2D if mena_en_mano else null
@onready var etiqueta_mena_mano: Label = mena_en_mano.get_node_or_null("EtiquetaMenaMano") as Label if mena_en_mano else null

# Alias de compatibilidad hacia atrás
var interact_detector: Area2D:
	get: return detector_interaccion
var visual_root: Node2D:
	get: return raiz_visual
var camera: Camera2D:
	get: return camara_jugador

var current_interactable: Area2D = null
var facing_direction: Vector2 = Vector2.DOWN
var _ciclo_paso: float = 0.0

func _ready() -> void:
	if detector_interaccion:
		detector_interaccion.area_entered.connect(_on_interact_area_entered)
		detector_interaccion.area_exited.connect(_on_interact_area_exited)

func _physics_process(delta: float) -> void:
	var cantidad_mena: int = int(GameManager.menas_en_mano_cantidad) if "menas_en_mano_cantidad" in GameManager else 0
	var lleva_mena: bool = ("menas_en_mano_cantidad" in GameManager and cantidad_mena > 0)
	var tipo_mena: String = String(GameManager.menas_en_mano_tipo) if "menas_en_mano_tipo" in GameManager else "hierro_dulce"
	_actualizar_visual_mena_en_mano(lleva_mena, tipo_mena, cantidad_mena)

	# Si estamos forjando o descansando, congelar movimiento
	if GameManager.current_state != GameManager.State.OVERWORLD:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

	var velocidad_efectiva: float = SPEED * 0.55 if lleva_mena else SPEED

	# Game Feel: Aceleración y Turn-Around Boost
	if input_vector != Vector2.ZERO:
		facing_direction = input_vector
		if detector_interaccion:
			detector_interaccion.rotation = facing_direction.angle() - PI / 2.0

		var dot_prod: float = velocity.normalized().dot(input_vector)
		var applied_accel: float = acceleration
		if dot_prod < -0.2:
			applied_accel = turn_boost

		velocity = velocity.move_toward(input_vector * velocidad_efectiva, applied_accel * delta)
		_apply_walk_juice(delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		_reset_walk_juice(delta)

	move_and_slide()

func _actualizar_visual_mena_en_mano(lleva_mena: bool, tipo_mena: String, cantidad_mena: int) -> void:
	if not is_instance_valid(mena_en_mano):
		return
	if not lleva_mena:
		mena_en_mano.visible = false
		return

	mena_en_mano.visible = true
	if is_instance_valid(cuerpo_mineral_mano):
		match tipo_mena:
			"acero_carbono", "carbon":
				cuerpo_mineral_mano.color = COLOR_MENA_ACERO_CARBONO
			"bronce_cobre", "mineral_cobre":
				cuerpo_mineral_mano.color = COLOR_MENA_BRONCE_COBRE
			"hierro_dulce", "mineral_hierro", _:
				cuerpo_mineral_mano.color = COLOR_MENA_HIERRO_DULCE
	if is_instance_valid(etiqueta_mena_mano):
		etiqueta_mena_mano.text = "Mena x%d" % cantidad_mena

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.current_state != GameManager.State.OVERWORLD:
		return

	if event.is_action_pressed("interact") and current_interactable != null:
		_trigger_interaction()

func _trigger_interaction() -> void:
	if raiz_visual:
		var tween: Tween = create_tween()
		tween.tween_property(raiz_visual, "scale", Vector2(1.2, 0.8), 0.08)
		tween.tween_property(raiz_visual, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	if current_interactable.has_method("interact"):
		current_interactable.interact()

func _on_interact_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactables"):
		current_interactable = area
		var prompt: String = area.get("prompt_text") if "prompt_text" in area else "Interactuar"
		emit_signal("interact_focus_changed", prompt)

func _on_interact_area_exited(area: Area2D) -> void:
	if current_interactable == area:
		current_interactable = null
		emit_signal("interact_focus_changed", "")

func _apply_walk_juice(delta: float) -> void:
	_ciclo_paso += delta * 14.0
	var bob: float = sin(_ciclo_paso) * 0.045
	if raiz_visual:
		raiz_visual.scale = Vector2(1.0 + bob, 1.0 - bob)

	var zancada: float = sin(_ciclo_paso) * 3.5
	if bota_izquierda and bota_derecha:
		bota_izquierda.position.y = 9.0 + zancada
		bota_derecha.position.y = 9.0 - zancada
	if brazo_izquierdo and brazo_derecho:
		brazo_izquierdo.position.y = -5.0 - zancada * 0.8
		brazo_derecho.position.y = -5.0 + zancada * 0.8
	if rostro_mirada:
		rostro_mirada.visible = facing_direction.y >= -0.35
		rostro_mirada.position = Vector2(facing_direction.x * 2.2, clampf(facing_direction.y * 1.5, -1.5, 2.0))

func _reset_walk_juice(delta: float) -> void:
	if raiz_visual:
		raiz_visual.scale = raiz_visual.scale.move_toward(Vector2.ONE, 6.0 * delta)
	if bota_izquierda and bota_derecha:
		bota_izquierda.position.y = move_toward(bota_izquierda.position.y, 9.0, 24.0 * delta)
		bota_derecha.position.y = move_toward(bota_derecha.position.y, 9.0, 24.0 * delta)
	if brazo_izquierdo and brazo_derecho:
		brazo_izquierdo.position.y = move_toward(brazo_izquierdo.position.y, -5.0, 24.0 * delta)
		brazo_derecho.position.y = move_toward(brazo_derecho.position.y, -5.0, 24.0 * delta)

func set_camera_bounds(left: int, top: int, right: int, bottom: int) -> void:
	if camara_jugador:
		camara_jugador.limit_left = left
		camara_jugador.limit_top = top
		camara_jugador.limit_right = right
		camara_jugador.limit_bottom = bottom
