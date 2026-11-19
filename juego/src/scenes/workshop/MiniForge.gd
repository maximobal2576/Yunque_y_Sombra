# MiniForge.gd
# Minijuego interactivo rítmico de forja en el yunque (/game_feel)
# Nomenclatura de nodos 100% en español conforme a docs/idea.txt §8.2
extends CanvasLayer

signal forge_closed()

@onready var panel_principal: Panel = $PanelPrincipal
@onready var barra_golpe: ProgressBar = $PanelPrincipal/ContenedorBarraGolpe/BarraGolpe
@onready var zona_optima: ColorRect = $PanelPrincipal/ContenedorBarraGolpe/ZonaOptima
@onready var cursor_golpe: ColorRect = $PanelPrincipal/ContenedorBarraGolpe/CursorGolpe
@onready var etiqueta_indicacion: Label = $PanelPrincipal/EtiquetaIndicacion
@onready var etiqueta_estado: Label = $PanelPrincipal/EtiquetaEstado
@onready var visual_yunque: ColorRect = $PanelPrincipal/VisualYunque

# Alias de compatibilidad hacia atrás
var panel_root: Panel:
	get: return panel_principal
var strike_bar: ProgressBar:
	get: return barra_golpe
var sweet_spot: ColorRect:
	get: return zona_optima
var cursor: ColorRect:
	get: return cursor_golpe
var feedback_label: Label:
	get: return etiqueta_indicacion
var status_label: Label:
	get: return etiqueta_estado
var anvil_rect: ColorRect:
	get: return visual_yunque

var cursor_position: float = 0.0
var cursor_direction: float = 1.0
var cursor_speed: float = 240.0 # pixeles por segundo
var bar_width: float = 300.0

var current_strikes: int = 0
var max_strikes: int = 3
var strike_scores: Array[float] = []
var is_active: bool = false
var is_finished: bool = false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	bar_width = barra_golpe.size.x

func _process(delta: float) -> void:
	if not is_active or is_finished:
		return

	# Movimiento oscilante del cursor (vaivén rítmico)
	cursor_position += cursor_direction * cursor_speed * delta
	if cursor_position >= bar_width - cursor_golpe.size.x:
		cursor_position = bar_width - cursor_golpe.size.x
		cursor_direction = -1.0
	elif cursor_position <= 0.0:
		cursor_position = 0.0
		cursor_direction = 1.0

	cursor_golpe.position.x = cursor_position

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if event.is_action_pressed("cancel_escape"):
		close_forge()
	elif event.is_action_pressed("interact") or event.is_action_pressed("action"):
		if is_finished:
			reset_forge()
		else:
			execute_hammer_strike()

func open_forge() -> void:
	visible = true
	is_active = true
	is_finished = false
	GameManager.change_state(GameManager.State.FORGING)
	reset_forge()

func close_forge() -> void:
	is_active = false
	visible = false
	GameManager.change_state(GameManager.State.OVERWORLD)
	emit_signal("forge_closed")

func reset_forge() -> void:
	current_strikes = 0
	strike_scores.clear()
	is_finished = false
	cursor_position = 0.0
	cursor_direction = 1.0
	etiqueta_indicacion.text = "Presiona [ESPACIO / E] cuando la aguja cruce la zona dorada."
	etiqueta_indicacion.modulate = Color(0.95, 0.9, 0.8)
	etiqueta_estado.text = "Golpe 0 / %d — Forjando: Clavo de Hierro Rústico" % max_strikes

func execute_hammer_strike() -> void:
	if not GameManager.consume_stamina(4.0):
		etiqueta_indicacion.text = "¡Estás sin energía! Descansa en la cama para reponerte."
		etiqueta_indicacion.modulate = Color(0.8, 0.2, 0.2)
		return

	# Calcular precision segun la posicion respecto al SweetSpot central
	var sweet_center: float = zona_optima.position.x + zona_optima.size.x / 2.0
	var cursor_center: float = cursor_golpe.position.x + cursor_golpe.size.x / 2.0
	var distance: float = abs(sweet_center - cursor_center)
	var max_tolerance: float = zona_optima.size.x / 2.0 + 30.0

	var accuracy: float = clamp(1.0 - (distance / max_tolerance), 0.2, 1.0)
	strike_scores.append(accuracy)
	current_strikes += 1

	# Juice: Deformacion elastica del yunque por el impacto
	_apply_hammer_juice(accuracy)

	if accuracy > 0.85:
		etiqueta_indicacion.text = "¡GOLPE MAESTRO! Impacto en el punto dulce (+%.0f%%)" % (accuracy * 100.0)
		etiqueta_indicacion.modulate = Color(0.9, 0.8, 0.3)
	elif accuracy > 0.55:
		etiqueta_indicacion.text = "¡Buen golpe! Deformando el lingote caliente (+%.0f%%)" % (accuracy * 100.0)
		etiqueta_indicacion.modulate = Color(0.8, 0.8, 0.8)
	else:
		etiqueta_indicacion.text = "Golpe descentrado. El metal pierde temperatura (+%.0f%%)" % (accuracy * 100.0)
		etiqueta_indicacion.modulate = Color(0.7, 0.4, 0.3)

	etiqueta_estado.text = "Golpe %d / %d" % [current_strikes, max_strikes]

	if current_strikes >= max_strikes:
		finish_item()

func finish_item() -> void:
	is_finished = true
	var total_score: float = 0.0
	for score in strike_scores:
		total_score += score
	var final_quality: float = total_score / float(strike_scores.size())

	var reward: int = int(5.0 * final_quality) + 2
	GameManager.record_crafted_item("Clavo de Hierro", final_quality, reward)

	etiqueta_indicacion.text = "¡PIEZA TERMINADA! Calidad: %.0f%% | Recompensa: +%d monedas.\n[ESPACIO para forjar otra | ESC para salir]" % [final_quality * 100.0, reward]
	etiqueta_indicacion.modulate = Color(0.4, 0.9, 0.5)

func _apply_hammer_juice(quality: float) -> void:
	var tween: Tween = create_tween()
	var squash_x: float = 1.0 + (0.25 * quality)
	var squash_y: float = 1.0 - (0.25 * quality)
	tween.tween_property(visual_yunque, "scale", Vector2(squash_x, squash_y), 0.05)
	tween.tween_property(visual_yunque, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
