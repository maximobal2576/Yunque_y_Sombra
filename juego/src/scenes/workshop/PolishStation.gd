# PolishStation.gd
# Estación de pulido manual por frotación táctil con piedra de afilar / esmeril (/herrero + /game_feel).
# El jugador arrastra la piedra sobre la pieza templada para desbastar la cascarilla de óxido y sacar brillo de acero.
extends Control

signal polishing_completed(score: float)

@onready var banco_pulido: Panel = $BancoPulido
@onready var base_metalica: Polygon2D = $BancoPulido/BaseMetalica
@onready var cascarilla_izquierda: ColorRect = $BancoPulido/ContenedorCascarilla/CascarillaIzquierda
@onready var cascarilla_centro: ColorRect = $BancoPulido/ContenedorCascarilla/CascarillaCentro
@onready var cascarilla_derecha: ColorRect = $BancoPulido/ContenedorCascarilla/CascarillaDerecha
@onready var brillo_metalico: Line2D = $BancoPulido/BrilloMetalico
@onready var chispas_esmeril: CPUParticles2D = $BancoPulido/ChispasEsmeril

@onready var herramienta_piedra_afilar: Node2D = $BancoPulido/HerramientaPiedraAfilar
@onready var efecto_sonido_raspado: Label = $BancoPulido/EfectoSonidoRaspado
@onready var sacudida_trauma: Node = $SacudidaTrauma

@onready var barra_progreso: ProgressBar = $BarraSuperior/BarraProgreso
@onready var etiqueta_estado: Label = $EtiquetaEstado
@onready var boton_finalizar_pulido: Button = $BotonFinalizarPulido

# Aliases de compatibilidad hacia atrás
var polish_bench: Panel:
	get: return banco_pulido
var metal_base: Polygon2D:
	get: return base_metalica
var slag_overlay_left: ColorRect:
	get: return cascarilla_izquierda
var slag_overlay_center: ColorRect:
	get: return cascarilla_centro
var slag_overlay_right: ColorRect:
	get: return cascarilla_derecha
var shine_highlight: Line2D:
	get: return brillo_metalico
var whetstone_tool: Node2D:
	get: return herramienta_piedra_afilar
var rub_sound_fx: Label:
	get: return efecto_sonido_raspado
var progress_bar: ProgressBar:
	get: return barra_progreso
var status_label: Label:
	get: return etiqueta_estado
var btn_finish_polish: Button:
	get: return boton_finalizar_pulido

# Estado de pulido
var is_rubbing: bool = false
var total_rub_distance: float = 0.0
const REQUIRED_RUB_DISTANCE: float = 1950.0 # Píxeles de frotado efectivo (piedra arenisca inicial)
const DISTANCIA_ZONA_PULIDO: float = 520.0 # ~38% más gradual por pasada

var slag_cleaned: Array[float] = [0.0, 0.0, 0.0] # 0 a 1.0 por zona
var last_bench_pos: Vector2 = Vector2.ZERO
var last_mouse_pos: Vector2 = Vector2.ZERO
var is_finished: bool = false
var final_score: float = 0.0
var polish_progress: float = 0.0
var sound_cooldown: float = 0.0
var _sonido_pulido_optimo_emitido: bool = false

func _ready() -> void:
	btn_finish_polish.pressed.connect(_on_finish_polish_pressed)
	whetstone_tool.visible = false
	rub_sound_fx.visible = false
	shine_highlight.visible = false
	btn_finish_polish.disabled = true
	reset_station()

func reset_station(incoming_shape: PackedVector2Array = PackedVector2Array()) -> void:
	is_rubbing = false
	is_finished = false
	total_rub_distance = 0.0
	slag_cleaned = [0.0, 0.0, 0.0]
	final_score = 0.0
	polish_progress = 0.0
	_sonido_pulido_optimo_emitido = false
	progress_bar.value = 0.0
	btn_finish_polish.disabled = true
	shine_highlight.visible = false
	sound_cooldown = 0.0

	if incoming_shape.size() >= 3:
		metal_base.polygon = incoming_shape

	metal_base.color = Color(0.24, 0.27, 0.33) # Acero templado con cascarilla
	slag_overlay_left.modulate.a = 0.92
	slag_overlay_center.modulate.a = 0.92
	slag_overlay_right.modulate.a = 0.92

	status_label.text = "Haz clic sostenido y frota la piedra de afilar sobre la pieza para desbastar la cascarilla."
	status_label.modulate = Color(0.95, 0.9, 0.8)

func _process(delta: float) -> void:
	if not visible or not is_visible_in_tree():
		return
	if sound_cooldown > 0.0:
		sound_cooldown -= delta

func _gui_input(event: InputEvent) -> void:
	if is_finished:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_rubbing = true
			last_bench_pos = polish_bench.get_local_mouse_position()
			last_mouse_pos = event.position
			whetstone_tool.visible = true
			whetstone_tool.position = last_bench_pos
		else:
			is_rubbing = false
			whetstone_tool.visible = false
			rub_sound_fx.visible = false

	elif event is InputEventMouseMotion and is_rubbing:
		_process_rubbing()

func _process_rubbing(opt_pos = null) -> void:
	var cur_bench_pos: Vector2
	if opt_pos != null:
		cur_bench_pos = (opt_pos - polish_bench.global_position) if polish_bench.is_inside_tree() else opt_pos
	else:
		cur_bench_pos = polish_bench.get_local_mouse_position()

	whetstone_tool.position = cur_bench_pos

	var bench_center: Vector2 = polish_bench.size / 2.0
	var local_m: Vector2 = cur_bench_pos - bench_center

	# Verificar si está frotando sobre la superficie del metal
	if absf(local_m.x) < 150.0 and absf(local_m.y) < 48.0:
		var delta_dist: float = cur_bench_pos.distance_to(last_bench_pos)
		last_bench_pos = cur_bench_pos

		if delta_dist > 1.5:
			var paso_efectivo: float = minf(delta_dist, 26.0) if opt_pos == null else delta_dist
			total_rub_distance += paso_efectivo
			_spawn_polish_dust(cur_bench_pos)
			_show_rub_fx()

			if sound_cooldown <= 0.0:
				AudioManager.play_whetstone()
				sound_cooldown = 0.16

			# Limpiar cascarilla según la zona del frotado con ritmo gradual de herramienta inicial
			var avance_limpieza: float = paso_efectivo / DISTANCIA_ZONA_PULIDO
			if local_m.x < -25.0:
				slag_cleaned[0] = minf(1.0, slag_cleaned[0] + avance_limpieza)
				slag_cleaned[1] = minf(1.0, slag_cleaned[1] + avance_limpieza * 0.25)
			elif local_m.x > 25.0:
				slag_cleaned[2] = minf(1.0, slag_cleaned[2] + avance_limpieza)
				slag_cleaned[1] = minf(1.0, slag_cleaned[1] + avance_limpieza * 0.25)
			else:
				slag_cleaned[1] = minf(1.0, slag_cleaned[1] + avance_limpieza)
				slag_cleaned[0] = minf(1.0, slag_cleaned[0] + avance_limpieza * 0.20)
				slag_cleaned[2] = minf(1.0, slag_cleaned[2] + avance_limpieza * 0.20)
			slag_overlay_left.modulate.a = 1.0 - slag_cleaned[0]
			slag_overlay_center.modulate.a = 1.0 - slag_cleaned[1]
			slag_overlay_right.modulate.a = 1.0 - slag_cleaned[2]

			var avg_clean: float = (slag_cleaned[0] + slag_cleaned[1] + slag_cleaned[2]) / 3.0
			metal_base.color = Color(0.24, 0.27, 0.33).lerp(Color(0.68, 0.72, 0.76), avg_clean)

			polish_progress = avg_clean * 100.0
			progress_bar.value = polish_progress

			if polish_progress >= 95.0 and not _sonido_pulido_optimo_emitido:
				_sonido_pulido_optimo_emitido = true
				AudioManager.play_sfx("step_complete", 2.5, 0.02)
				AudioManager.play_sfx("temp_ready", 1.5, 0.02)

			if avg_clean >= 0.85:
				btn_finish_polish.disabled = false
				shine_highlight.visible = true
				status_label.text = "¡Cascarilla eliminada! El acero brilla con lustre de armero. Puedes concluir."
				status_label.modulate = Color(0.4, 0.9, 0.5)
			else:
				status_label.text = "Desbastando cascarilla (%.0f%%)... Frota la piedra por las zonas oscuras restantes." % (avg_clean * 100.0)
				status_label.modulate = Color(0.96, 0.78, 0.2)

func _spawn_polish_dust(local_bench_pos: Vector2) -> void:
	if chispas_esmeril:
		chispas_esmeril.position = local_bench_pos
		chispas_esmeril.restart()
		chispas_esmeril.emitting = true
	if sacudida_trauma and sacudida_trauma.has_method("agregar_trauma") and randf() < 0.25:
		sacudida_trauma.agregar_trauma(0.18)

func _show_rub_fx() -> void:
	rub_sound_fx.visible = true
	rub_sound_fx.position = whetstone_tool.position + Vector2(-34, -36)
	rub_sound_fx.modulate.a = 0.9

func _on_finish_polish_pressed() -> void:
	is_finished = true
	var avg_clean: float = (slag_cleaned[0] + slag_cleaned[1] + slag_cleaned[2]) / 3.0
	final_score = clampf(avg_clean, 0.2, 1.0)
	emit_signal("polishing_completed", final_score)

func _on_finish_polishing_pressed() -> void:
	_on_finish_polish_pressed()

func simulate_polish() -> void:
	slag_cleaned = [1.0, 1.0, 1.0]
	slag_overlay_left.modulate.a = 0.0
	slag_overlay_center.modulate.a = 0.0
	slag_overlay_right.modulate.a = 0.0
	polish_progress = 100.0
	progress_bar.value = 100.0
	if not _sonido_pulido_optimo_emitido:
		_sonido_pulido_optimo_emitido = true
		AudioManager.play_sfx("step_complete", 2.5, 0.02)
		AudioManager.play_sfx("temp_ready", 1.5, 0.02)
	btn_finish_polish.disabled = false
	shine_highlight.visible = true
	status_label.text = "¡Cascarilla eliminada! El acero brilla con lustre de armero. Puedes concluir."
	status_label.modulate = Color(0.4, 0.9, 0.5)
