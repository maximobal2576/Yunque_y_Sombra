# QuenchStation.gd
# Estación de templado por inmersión física y choque térmico en agua de pozo (/herrero + /game_feel).
# Incluye shader térmico, resplandor subacuático, ebullición de burbujas, nubes suaves de vapor y sacudida por trauma.
extends Control

signal quenching_completed(score: float, final_color: Color)

const EscalaTermica = preload("res://src/components/EscalaTermicaAcero.gd")

# Nodos en Español
@onready var panel_tina: Panel = $PanelTina
@onready var rectangulo_agua: ColorRect = $PanelTina/RectanguloAgua
@onready var resplandor_inmersion: TextureRect = $PanelTina/RectanguloAgua/ResplandorInmersion
@onready var burbujas_ebullicion: CPUParticles2D = $PanelTina/RectanguloAgua/BurbujasEbullicion
@onready var contenedor_vapor: Control = $PanelTina/ContenedorVapor
@onready var etiqueta_tssss: Label = $PanelTina/EtiquetaTssss

@onready var contenedor_tenazas: Control = $PanelTina/ContenedorTenazas
@onready var pieza_metalica: Polygon2D = $PanelTina/ContenedorTenazas/PiezaMetalica
@onready var visual_tenazas: Node2D = $PanelTina/ContenedorTenazas/VisualTenazas

@onready var sacudida_trauma: Node = $SacudidaTrauma
@onready var etiqueta_estado: Label = $EtiquetaEstado
@onready var etiqueta_temp: Label = $BarraSuperior/EtiquetaIndicadorTemperatura
@onready var boton_ir_a_pulido: Button = $BotonIrAPulido

# Alias de compatibilidad hacia atrás
var tub_panel: Panel:
	get: return panel_tina
var water_rect: ColorRect:
	get: return rectangulo_agua
var steam_container: Control:
	get: return contenedor_vapor
var tssss_label: Label:
	get: return etiqueta_tssss
var tongs_container: Control:
	get: return contenedor_tenazas
var metal_piece: Polygon2D:
	get: return pieza_metalica
var tongs_visual: Node2D:
	get: return visual_tenazas
var status_label: Label:
	get: return etiqueta_estado
var temp_indicator_label: Label:
	get: return etiqueta_temp
var btn_to_polish: Button:
	get: return boton_ir_a_pulido

# Físicas y drag
var is_dragging: bool = false
var is_underwater: bool = false
var has_quenched: bool = false
var quench_time: float = 0.0
var temperatura_temple: float = 880.0

const WATER_SURFACE_Y: float = 140.0
const INITIAL_TONGS_Y: float = 50.0

# Ventana óptima de templado (viraje a martensita / gris acero templado)
const TARGET_TIME_MIN: float = 2.2
const TARGET_TIME_MAX: float = 2.8

var current_metal_color: Color = Color(0.96, 0.62, 0.04) # #f59e0b
var final_score: float = 0.0
var _textura_vapor: GradientTexture2D = null

func _ready() -> void:
	_crear_textura_vapor()
	btn_to_polish.pressed.connect(_on_to_polish_pressed)
	tssss_label.visible = false
	btn_to_polish.disabled = true
	reset_station()

func _crear_textura_vapor() -> void:
	var grad: Gradient = Gradient.new()
	grad.colors = PackedColorArray([
		Color(0.94, 0.92, 0.88, 0.65),
		Color(0.82, 0.86, 0.90, 0.0)
	])
	_textura_vapor = GradientTexture2D.new()
	_textura_vapor.gradient = grad
	_textura_vapor.width = 64
	_textura_vapor.height = 64
	_textura_vapor.fill = GradientTexture2D.FILL_RADIAL
	_textura_vapor.fill_from = Vector2(0.5, 0.5)
	_textura_vapor.fill_to = Vector2(0.5, 0.0)

func reset_station(initial_color: Color = Color(0.96, 0.62, 0.04), incoming_shape: PackedVector2Array = PackedVector2Array()) -> void:
	is_dragging = false
	is_underwater = false
	has_quenched = false
	quench_time = 0.0
	temperatura_temple = 880.0
	final_score = 0.0
	btn_to_polish.disabled = true
	tssss_label.visible = false
	if burbujas_ebullicion:
		burbujas_ebullicion.emitting = false
	if resplandor_inmersion:
		resplandor_inmersion.modulate.a = 0.0

	if incoming_shape.size() >= 3:
		var escalado: PackedVector2Array = PackedVector2Array()
		for p in incoming_shape:
			escalado.append(p * 0.46)
		metal_piece.polygon = escalado

	current_metal_color = initial_color
	metal_piece.color = current_metal_color
	_actualizar_shader_metal()
	tongs_container.position.y = INITIAL_TONGS_Y

	temp_indicator_label.text = "🌡️ Estado: Acero en Austenita / Rojo Cereza (880°C)"
	temp_indicator_label.modulate = Color(0.98, 0.78, 0.45)
	status_label.text = "Haz clic en las tenazas y arrastra la pieza HACIA ABAJO dentro del agua de pozo."
	status_label.modulate = Color(0.95, 0.9, 0.8)

func _actualizar_shader_metal() -> void:
	if metal_piece and metal_piece.material is ShaderMaterial:
		(metal_piece.material as ShaderMaterial).set_shader_parameter("temperatura", temperatura_temple)

func _process(delta: float) -> void:
	if not visible or not is_visible_in_tree():
		return
	if is_underwater and not has_quenched:
		quench_time += delta
		_process_thermal_transition(delta)
		_spawn_steam_cloud()
		if burbujas_ebullicion and not burbujas_ebullicion.emitting:
			burbujas_ebullicion.emitting = true
	elif burbujas_ebullicion and burbujas_ebullicion.emitting:
		burbujas_ebullicion.emitting = false

func _process_thermal_transition(_delta: float) -> void:
	# Descenso real de temperatura por choque térmico en agua (880°C -> 180°C en ~3.0s)
	temperatura_temple = clampf(lerpf(880.0, 180.0, quench_time / 2.8), 80.0, 880.0)
	_actualizar_shader_metal()

	if resplandor_inmersion:
		var int_brillo: float = clampf(1.0 - (quench_time / 2.3), 0.0, 1.0)
		resplandor_inmersion.modulate.a = 0.75 * int_brillo

	if quench_time < 1.2:
		var t: float = quench_time / 1.2
		current_metal_color = Color(0.96, 0.62, 0.04).lerp(Color(0.75, 0.22, 0.17), t)
		temp_indicator_label.text = "🌡️ Enfriando en agua... %.0f°C Rojo Sombra (%.1fs)" % [temperatura_temple, quench_time]
		temp_indicator_label.modulate = Color(0.95, 0.55, 0.42)
	elif quench_time <= 2.8:
		var t: float = (quench_time - 1.2) / 1.3
		current_metal_color = Color(0.75, 0.22, 0.17).lerp(Color(0.22, 0.26, 0.32), t)
		if quench_time >= TARGET_TIME_MIN:
			temp_indicator_label.text = "✅ ¡TEMPLE MARTENSÍTICO (%.0f°C)! ¡SUELTA PARA RETIRAR AHORA! (%.1fs)" % [temperatura_temple, quench_time]
			temp_indicator_label.modulate = Color(0.45, 0.95, 0.55)
		else:
			temp_indicator_label.text = "🌡️ Pasando a Gris Acero Templado... %.0f°C (%.1fs)" % [temperatura_temple, quench_time]
			temp_indicator_label.modulate = Color(0.92, 0.82, 0.55)
	else:
		current_metal_color = Color(0.12, 0.17, 0.22)
		temp_indicator_label.text = "⚠️ ¡EXCESO DE TEMPLE (%.0f°C)! Tensión interna excesiva y fragilidad (%.1fs)" % [temperatura_temple, quench_time]
		temp_indicator_label.modulate = Color(0.92, 0.42, 0.38)

	metal_piece.color = current_metal_color

func _gui_input(event: InputEvent) -> void:
	if has_quenched:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local_y: float = tub_panel.get_local_mouse_position().y
			if absf(local_y - tongs_container.position.y) < 110.0 or local_y < WATER_SURFACE_Y:
				is_dragging = true
		else:
			if is_dragging:
				_handle_release()

	elif event is InputEventMouseMotion and is_dragging:
		var local_y: float = tub_panel.get_local_mouse_position().y
		var clamped_y: float = clampf(local_y, INITIAL_TONGS_Y, WATER_SURFACE_Y + 70.0)
		tongs_container.position.y = clamped_y

		var now_underwater: bool = clamped_y >= WATER_SURFACE_Y
		if now_underwater != is_underwater:
			is_underwater = now_underwater
			tssss_label.visible = is_underwater
			if is_underwater:
				AudioManager.start_quench_steam()
				if sacudida_trauma and sacudida_trauma.has_method("agregar_trauma"):
					sacudida_trauma.agregar_trauma(0.45)
				status_label.text = "¡Choque térmico en curso! Mantén sumergido y suelta justo entre 2.2s y 2.8s."
				status_label.modulate = Color(0.96, 0.78, 0.2)
			else:
				AudioManager.stop_quench_steam()
				tssss_label.visible = false

func _handle_release() -> void:
	is_dragging = false
	AudioManager.stop_quench_steam()
	if burbujas_ebullicion:
		burbujas_ebullicion.emitting = false
	if resplandor_inmersion:
		resplandor_inmersion.modulate.a = 0.0

	if quench_time > 0.4:
		has_quenched = true
		is_underwater = false
		tssss_label.visible = false

		var tween: Tween = create_tween()
		tween.tween_property(tongs_container, "position:y", INITIAL_TONGS_Y, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		_evaluate_quench_quality()
	else:
		is_underwater = false
		tssss_label.visible = false
		var tween: Tween = create_tween()
		tween.tween_property(tongs_container, "position:y", INITIAL_TONGS_Y, 0.2)
		status_label.text = "Inmersión insuficiente. Mantén la pieza sumergida hasta el viraje a gris templado."
		status_label.modulate = Color(0.9, 0.4, 0.3)

func _evaluate_quench_quality() -> void:
	btn_to_polish.disabled = false

	if quench_time >= TARGET_TIME_MIN and quench_time <= TARGET_TIME_MAX:
		final_score = 1.0
		status_label.text = "¡TEMPLADO MAESTRO (100%%)! Martensita uniforme: dureza óptima sin fisuras."
		status_label.modulate = Color(0.4, 0.9, 0.5)
	elif quench_time < TARGET_TIME_MIN:
		final_score = clampf(quench_time / TARGET_TIME_MIN, 0.25, 0.75)
		status_label.text = "Templado prematuro (%.1fs). Retuvo calor residual y el acero quedó blando (Score: %.0f%%)." % [quench_time, final_score * 100.0]
		status_label.modulate = Color(0.9, 0.5, 0.2)
	else:
		final_score = clampf(1.0 - ((quench_time - TARGET_TIME_MAX) * 0.45), 0.20, 0.70)
		status_label.text = "Exceso de inmersión (%.1fs). El choque térmico volvió el acero quebradizo (Score: %.0f%%)." % [quench_time, final_score * 100.0]
		status_label.modulate = Color(0.85, 0.3, 0.3)

func _spawn_steam_cloud() -> void:
	var puff: TextureRect = TextureRect.new()
	var sz: float = randf_range(36.0, 68.0)
	puff.size = Vector2(sz, sz)
	puff.texture = _textura_vapor
	puff.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	puff.mouse_filter = Control.MOUSE_FILTER_IGNORE
	puff.position = Vector2(randf_range(120.0, 340.0), WATER_SURFACE_Y - 24.0)
	steam_container.add_child(puff)

	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(puff, "position:y", puff.position.y - randf_range(65.0, 120.0), 0.65)
	tw.tween_property(puff, "position:x", puff.position.x + randf_range(-28.0, 28.0), 0.65)
	tw.tween_property(puff, "scale", Vector2(1.85, 1.85), 0.65)
	tw.tween_property(puff, "modulate:a", 0.0, 0.65)
	tw.chain().tween_callback(puff.queue_free)

func _on_to_polish_pressed() -> void:
	emit_signal("quenching_completed", final_score, current_metal_color)

func simulate_quench(duration: float = 2.5) -> void:
	quench_time = duration
	temperatura_temple = 220.0
	current_metal_color = Color(0.65, 0.65, 0.68)
	metal_piece.color = current_metal_color
	_actualizar_shader_metal()
	has_quenched = true
	_evaluate_quench_quality()

func _on_quench_pressed() -> void:
	simulate_quench(2.5)

func _on_extract_pressed() -> void:
	_on_to_polish_pressed()
