# GuiaTutorial.gd
# Sistema de Tutorial Interactivo, Contextual y Diegético para 'Yunque & Sombra'
# Especialidades combinadas: /programador_godot + /disenador_grafico + /game_feel
# Nomenclatura de nodos 100% en español y tipado estricto (:=) conforme a docs/idea.txt §8.2
extends CanvasLayer

signal paso_cambiado(nuevo_paso: int)
signal tutorial_completado()
signal tutorial_saltado()

const TOTAL_PASOS: int = 9
const INTERVALO_OBSERVACION: float = 0.25

# Paleta de herrería auténtica (/disenador_grafico — WCAG 2.1 AAA > 10:1)
const COLOR_FONDO_CARBON: Color = Color(0.117647, 0.090196, 0.074510, 0.95) # #1e1713 (95% opacidad)
const COLOR_BORDE_BRONCE: Color = Color(0.709804, 0.603922, 0.415686, 1.0) # #b59a6a
const COLOR_TEXTO_MARFIL: Color = Color(0.949020, 0.901961, 0.800000, 1.0) # #f2e6cc
const COLOR_SUBTITULO_AMBAR: Color = Color(0.960784, 0.760784, 0.258824, 1.0) # #f5c242
const COLOR_VERDE_EXITO: Color = Color(0.45, 0.88, 0.52, 1.0)

const PASOS_TUTORIAL: Array[Dictionary] = [
	{
		"numero": 1,
		"subtitulo": "Paso 1 de 9 — El Legado del Tío",
		"descripcion": "Lee la carta de tu madre y camina siguiendo las flechas doradas hacia el norte hasta la Herrería de tu tío Rodrik."
	},
	{
		"numero": 2,
		"subtitulo": "Paso 2 de 9 — El Taller y la Campana",
		"descripcion": "Cruza la puerta oeste hacia el Taller de Forja o toca la campana de bronce en el mostrador para recibir a tu primer cliente."
	},
	{
		"numero": 3,
		"subtitulo": "Paso 3 de 9 — El Encargo Artesanal",
		"descripcion": "Revisa el pergamino de pedido sobre la mesa y pulsa 'Aceptar Comanda e Ir a Forja'."
	},
	{
		"numero": 4,
		"subtitulo": "Paso 4 de 9 — La Fragua y los Barriles",
		"descripcion": "Arrastra un lingote desde los barriles de la izquierda hacia las brasas del horno. Luego atiza el fuelle [ESPACIO o Clic] con paciencia hasta alcanzar el Caldeo Óptimo (1000°C - 1150°C) y llévalo al yunque. El horno tiene inercia térmica real y sube gradualmente."
	},
	{
		"numero": 5,
		"subtitulo": "Paso 5 de 9 — El Yunque Cenital",
		"descripcion": "Golpea el metal incandescente con el martillo (mínimo 5 impactos bien distribuidos) para moldearlo según la silueta guía."
	},
	{
		"numero": 6,
		"subtitulo": "Paso 6 de 9 — Corte de Rebabas",
		"descripcion": "Arrastra la cizalla a lo largo de las 3 líneas punteadas para recortar el material sobrante."
	},
	{
		"numero": 7,
		"subtitulo": "Paso 7 de 9 — Choque Térmico (Templado)",
		"descripcion": "Arrastra las tenazas hacia el agua fría y mantén sumergida la pieza entre 2.2 y 2.8 segundos hasta que cese el vapor."
	},
	{
		"numero": 8,
		"subtitulo": "Paso 8 de 9 — Pulido en Piedra Arenisca",
		"descripcion": "Frota la piedra de afilar de izquierda a derecha sobre el metal hasta quitar la cascarilla de óxido (85%+) y concluir la pieza."
	},
	{
		"numero": 9,
		"subtitulo": "Paso 9 de 9 — Entrega y Exploración de la Mina",
		"descripcion": "¡Pieza terminada! Entrégala en la bandeja del mostrador para cobrar tus monedas, o sal al pasillo y explora la puerta norte hacia la Mina Subterránea para extraer minerales con tu pico."
	}
]

# Referencias a nodos 100% en español
@onready var contenedor_raiz_tutorial: Control = $ContenedorRaizTutorial
@onready var panel_pergamino_tutorial: PanelContainer = $ContenedorRaizTutorial/PanelPergaminoTutorial
@onready var contenedor_vertical_tutorial: VBoxContainer = $ContenedorRaizTutorial/PanelPergaminoTutorial/ContenedorVerticalTutorial
@onready var cabecera_tutorial: HBoxContainer = $ContenedorRaizTutorial/PanelPergaminoTutorial/ContenedorVerticalTutorial/CabeceraTutorial
@onready var etiqueta_subtitulo_paso: Label = $ContenedorRaizTutorial/PanelPergaminoTutorial/ContenedorVerticalTutorial/CabeceraTutorial/EtiquetaSubtituloPaso
@onready var boton_saltar_tutorial: Button = $ContenedorRaizTutorial/PanelPergaminoTutorial/ContenedorVerticalTutorial/CabeceraTutorial/BotonSaltarTutorial
@onready var barra_progreso_tutorial: ProgressBar = $ContenedorRaizTutorial/PanelPergaminoTutorial/ContenedorVerticalTutorial/BarraProgresoTutorial
@onready var etiqueta_instruccion_tutorial: Label = $ContenedorRaizTutorial/PanelPergaminoTutorial/ContenedorVerticalTutorial/EtiquetaInstruccionTutorial
@onready var temporizador_observacion: Timer = $TemporizadorObservacion

# Alias de compatibilidad
var step_subtitle_label: Label:
	get: return etiqueta_subtitulo_paso
var instruction_label: Label:
	get: return etiqueta_instruccion_tutorial
var progress_bar: ProgressBar:
	get: return barra_progreso_tutorial
var skip_button: Button:
	get: return boton_saltar_tutorial

var paso_actual: int = 1
var tutorial_activo: bool = true
var tutorial_finalizado: bool = false

var _tween_activo: Tween = null
var _ref_pueblo: Node = null
var _ref_taller: Node = null
var _monedas_previas: int = -1

func _ready() -> void:
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configurar_filtros_raton_seguros()

	if is_instance_valid(boton_saltar_tutorial):
		boton_saltar_tutorial.pressed.connect(saltar_tutorial)

	if is_instance_valid(temporizador_observacion):
		temporizador_observacion.wait_time = INTERVALO_OBSERVACION
		temporizador_observacion.one_shot = false
		temporizador_observacion.timeout.connect(_verificar_estado_juego)
		temporizador_observacion.start()

	if is_instance_valid(GameManager):
		_monedas_previas = GameManager.coins
		if not GameManager.item_crafted.is_connected(_on_item_crafted):
			GameManager.item_crafted.connect(_on_item_crafted)
		if not GameManager.coins_changed.is_connected(_on_coins_changed):
			GameManager.coins_changed.connect(_on_coins_changed)

	_actualizar_vista_paso(paso_actual, false)
	_resolver_referencias_escena()

func _configurar_filtros_raton_seguros() -> void:
	# Garantiza que el contenedor y etiquetas jamás bloqueen clics en estaciones (MOUSE_FILTER_PASS / IGNORE)
	if is_instance_valid(contenedor_raiz_tutorial):
		contenedor_raiz_tutorial.mouse_filter = Control.MOUSE_FILTER_PASS
	if is_instance_valid(panel_pergamino_tutorial):
		panel_pergamino_tutorial.mouse_filter = Control.MOUSE_FILTER_PASS
	if is_instance_valid(contenedor_vertical_tutorial):
		contenedor_vertical_tutorial.mouse_filter = Control.MOUSE_FILTER_PASS
	if is_instance_valid(cabecera_tutorial):
		cabecera_tutorial.mouse_filter = Control.MOUSE_FILTER_PASS
	if is_instance_valid(etiqueta_subtitulo_paso):
		etiqueta_subtitulo_paso.mouse_filter = Control.MOUSE_FILTER_PASS
	if is_instance_valid(barra_progreso_tutorial):
		barra_progreso_tutorial.mouse_filter = Control.MOUSE_FILTER_PASS
	if is_instance_valid(etiqueta_instruccion_tutorial):
		etiqueta_instruccion_tutorial.mouse_filter = Control.MOUSE_FILTER_PASS
	if is_instance_valid(boton_saltar_tutorial):
		boton_saltar_tutorial.mouse_filter = Control.MOUSE_FILTER_PASS

func _unhandled_input(event: InputEvent) -> void:
	if not tutorial_activo or tutorial_finalizado or not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_T:
			saltar_tutorial()

## Avanza directamente a un paso específico (1 a 9) o completa el tutorial si supera TOTAL_PASOS
func avanzar_a_paso(nuevo_paso: int) -> void:
	if not tutorial_activo or tutorial_finalizado:
		return
	if nuevo_paso <= paso_actual:
		return
	if nuevo_paso > TOTAL_PASOS:
		_completar_tutorial_con_exito()
		return

	paso_actual = nuevo_paso
	_actualizar_vista_paso(paso_actual, true)
	paso_cambiado.emit(paso_actual)

## Notifica un evento semántico desde cualquier estación o nivel para avanzar de forma desacoplada
func notificar_evento(evento_id: String) -> void:
	if not tutorial_activo or tutorial_finalizado:
		return
	var clave: String = evento_id.strip_edges().to_lower()
	match clave:
		"pasillo_entrado", "taller_abierto", "paso_1_completado":
			if paso_actual == 1:
				avanzar_a_paso(2)
		"campana_tocada", "comanda_visible", "cliente_recibido", "paso_2_completado":
			if paso_actual <= 2:
				avanzar_a_paso(3)
		"comanda_aceptada", "estacion_fragua", "paso_3_completado":
			if paso_actual <= 3:
				avanzar_a_paso(4)
		"estacion_yunque", "lingote_en_yunque", "paso_4_completado":
			if paso_actual <= 4:
				avanzar_a_paso(5)
		"estacion_corte", "yunque_completado", "paso_5_completado":
			if paso_actual <= 5:
				avanzar_a_paso(6)
		"estacion_tina", "corte_completado", "paso_6_completado":
			if paso_actual <= 6:
				avanzar_a_paso(7)
		"estacion_pulido", "templado_completado", "paso_7_completado":
			if paso_actual <= 7:
				avanzar_a_paso(8)
		"ticket_mostrado", "pulido_completado", "pieza_terminada", "paso_8_completado":
			if paso_actual <= 8:
				avanzar_a_paso(9)
		"pedido_entregado", "mina_explorada", "zona_mina", "paso_9_completado", "tutorial_completado":
			if paso_actual <= 9:
				_completar_tutorial_con_exito()

## Oculta inmediatamente el tutorial a petición del jugador veterano
func saltar_tutorial() -> void:
	if not tutorial_activo:
		return
	tutorial_activo = false
	tutorial_finalizado = true
	if is_instance_valid(temporizador_observacion):
		temporizador_observacion.stop()
	_reproducir_sonido_paso()
	tutorial_saltado.emit()
	_animar_ocultamiento_panel()

func _actualizar_vista_paso(num_paso: int, con_feedback: bool) -> void:
	var idx: int = clampi(num_paso - 1, 0, PASOS_TUTORIAL.size() - 1)
	var datos: Dictionary = PASOS_TUTORIAL[idx]

	if is_instance_valid(etiqueta_subtitulo_paso):
		etiqueta_subtitulo_paso.text = "📜 " + str(datos.get("subtitulo", ""))
		etiqueta_subtitulo_paso.add_theme_color_override("font_color", COLOR_SUBTITULO_AMBAR)

	if is_instance_valid(etiqueta_instruccion_tutorial):
		etiqueta_instruccion_tutorial.text = str(datos.get("descripcion", ""))
		etiqueta_instruccion_tutorial.add_theme_color_override("font_color", COLOR_TEXTO_MARFIL)

	if is_instance_valid(barra_progreso_tutorial):
		barra_progreso_tutorial.max_value = float(TOTAL_PASOS)
		if con_feedback:
			var tw_barra: Tween = create_tween()
			tw_barra.tween_property(barra_progreso_tutorial, "value", float(num_paso), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			barra_progreso_tutorial.value = float(num_paso)

	if con_feedback:
		_reproducir_sonido_paso()
		_aplicar_pulso_elastico()

func _reproducir_sonido_paso() -> void:
	if is_instance_valid(AudioManager) and AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("step_complete", 0.5, 0.03)
		# Si la muestra "step_complete" no está registrada en AudioManager.audio_streams, usar campana sutil de respaldo
		if "audio_streams" in AudioManager and not AudioManager.audio_streams.has("step_complete"):
			AudioManager.play_sfx("bell", -5.0, 0.05)

func _aplicar_pulso_elastico() -> void:
	if not is_instance_valid(panel_pergamino_tutorial):
		return
	if _tween_activo and _tween_activo.is_valid():
		_tween_activo.kill()

	panel_pergamino_tutorial.pivot_offset = panel_pergamino_tutorial.size * 0.5
	panel_pergamino_tutorial.scale = Vector2(1.06, 0.94)
	_tween_activo = create_tween()
	_tween_activo.tween_property(panel_pergamino_tutorial, "scale", Vector2(0.98, 1.03), 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_activo.tween_property(panel_pergamino_tutorial, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _completar_tutorial_con_exito() -> void:
	if tutorial_finalizado:
		return
	tutorial_finalizado = true
	tutorial_activo = false
	if is_instance_valid(temporizador_observacion):
		temporizador_observacion.stop()

	if is_instance_valid(etiqueta_subtitulo_paso):
		etiqueta_subtitulo_paso.text = "⚒️ ¡Aprendizaje de Forja Completado!"
		etiqueta_subtitulo_paso.add_theme_color_override("font_color", COLOR_VERDE_EXITO)

	if is_instance_valid(etiqueta_instruccion_tutorial):
		etiqueta_instruccion_tutorial.text = "¡Felicitaciones, herrero! Ya dominas el ciclo artesanal del taller de tu tío Rodrik. Forja de día, explora la mina de noche y descubre la verdad del pueblo."

	if is_instance_valid(barra_progreso_tutorial):
		barra_progreso_tutorial.value = float(TOTAL_PASOS)

	if is_instance_valid(boton_saltar_tutorial):
		boton_saltar_tutorial.visible = false

	_reproducir_sonido_paso()
	_aplicar_pulso_elastico()
	tutorial_completado.emit()

	var tw_cierre: Tween = create_tween()
	tw_cierre.tween_interval(3.8)
	tw_cierre.tween_callback(_animar_ocultamiento_panel)

func _animar_ocultamiento_panel() -> void:
	if not is_instance_valid(panel_pergamino_tutorial):
		visible = false
		return
	if _tween_activo and _tween_activo.is_valid():
		_tween_activo.kill()

	panel_pergamino_tutorial.pivot_offset = panel_pergamino_tutorial.size * 0.5
	_tween_activo = create_tween().set_parallel(true)
	_tween_activo.tween_property(panel_pergamino_tutorial, "scale", Vector2(0.88, 0.88), 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_tween_activo.tween_property(panel_pergamino_tutorial, "modulate:a", 0.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween_activo.chain().tween_callback(func(): visible = false)

func _on_item_crafted(_item_name: String, _quality: float) -> void:
	if tutorial_activo and not tutorial_finalizado and paso_actual == 9:
		_completar_tutorial_con_exito()

func _on_coins_changed(nuevas_monedas: int) -> void:
	if _monedas_previas >= 0 and nuevas_monedas > _monedas_previas:
		if tutorial_activo and not tutorial_finalizado and paso_actual >= 8:
			_completar_tutorial_con_exito()
	_monedas_previas = nuevas_monedas

func _resolver_referencias_escena() -> void:
	var raiz: Viewport = get_tree().root if get_tree() else null
	if not is_instance_valid(raiz):
		return

	if not is_instance_valid(_ref_pueblo):
		var escena_actual: Node = get_tree().current_scene
		if is_instance_valid(escena_actual) and ("current_zone" in escena_actual or escena_actual.name == "GreyboxTown"):
			_ref_pueblo = escena_actual
		else:
			_ref_pueblo = raiz.find_child("GreyboxTown", true, false)

	if not is_instance_valid(_ref_taller):
		if is_instance_valid(_ref_pueblo) and "vista_estaciones_taller" in _ref_pueblo and is_instance_valid(_ref_pueblo.vista_estaciones_taller):
			_ref_taller = _ref_pueblo.vista_estaciones_taller
		else:
			_ref_taller = raiz.find_child("VistaEstacionesTaller", true, false)

	# Conectar señal de entrega del mostrador si existe y aún no está conectada
	if is_instance_valid(_ref_taller) and "vista_mostrador" in _ref_taller:
		var mostrador: Node = _ref_taller.vista_mostrador
		if is_instance_valid(mostrador) and mostrador.has_signal("item_delivered"):
			if not mostrador.item_delivered.is_connected(_on_mostrador_item_delivered):
				mostrador.item_delivered.connect(_on_mostrador_item_delivered)

func _on_mostrador_item_delivered(_calidad: float, _recompensa: int) -> void:
	if tutorial_activo and not tutorial_finalizado:
		_completar_tutorial_con_exito()

func _verificar_estado_juego() -> void:
	if not tutorial_activo or tutorial_finalizado:
		return

	_resolver_referencias_escena()

	var zona_pueblo: int = -1
	if is_instance_valid(_ref_pueblo) and "current_zone" in _ref_pueblo:
		zona_pueblo = int(_ref_pueblo.current_zone)

	var taller_abierto: bool = false
	var pestana_actual: int = -1
	var mostrador: Node = null
	var ticket_visible: bool = false

	if is_instance_valid(_ref_taller) and _ref_taller is CanvasLayer:
		taller_abierto = (_ref_taller as CanvasLayer).visible
		if "current_station" in _ref_taller:
			pestana_actual = int(_ref_taller.current_station)
		if "vista_mostrador" in _ref_taller:
			mostrador = _ref_taller.vista_mostrador
		if "capa_ticket_final" in _ref_taller and is_instance_valid(_ref_taller.capa_ticket_final):
			ticket_visible = (_ref_taller.capa_ticket_final as Control).visible

	# Paso 1 -> 2: El jugador entra al PASILLO (Zone.PASILLO == 1) o abre directamente el taller
	if paso_actual == 1:
		if zona_pueblo == 1 or taller_abierto:
			avanzar_a_paso(2)
			return

	# Paso 2 -> 3: Se abre WorkshopStationView y se toca la campana / aparece el pergamino de comanda
	if paso_actual == 2:
		if taller_abierto and is_instance_valid(mostrador):
			var comanda_visible: bool = false
			if "pergamino_comanda" in mostrador and is_instance_valid(mostrador.pergamino_comanda):
				comanda_visible = (mostrador.pergamino_comanda as Control).visible
			elif "has_active_order" in mostrador and bool(mostrador.has_active_order):
				comanda_visible = true
			if comanda_visible or pestana_actual >= 1:
				avanzar_a_paso(3)
				return

	# Paso 3 -> 4: El jugador acepta la comanda y pasa a la Fragua (StationTab.FORGE == 1)
	if paso_actual <= 3:
		if taller_abierto and pestana_actual == 1:
			avanzar_a_paso(4)
			return

	# Paso 4 -> 5: El jugador lleva el lingote caldeado al Yunque Cenital (StationTab.ANVIL == 2)
	if paso_actual <= 4:
		if taller_abierto and pestana_actual == 2:
			avanzar_a_paso(5)
			return

	# Paso 5 -> 6: Pasa a Corte Manual de Rebabas (StationTab.CUTTING == 3)
	if paso_actual <= 5:
		if taller_abierto and pestana_actual == 3:
			avanzar_a_paso(6)
			return

	# Paso 6 -> 7: Pasa a la Tina de Templado (StationTab.QUENCHING == 4)
	if paso_actual <= 6:
		if taller_abierto and pestana_actual == 4:
			avanzar_a_paso(7)
			return

	# Paso 7 -> 8: Pasa a Pulido en Piedra Arenisca (StationTab.POLISHING == 5)
	if paso_actual <= 7:
		if taller_abierto and pestana_actual == 5:
			avanzar_a_paso(8)
			return

	# Paso 8 -> 9: Se muestra el Ticket Final o la pieza queda lista en la bandeja del mostrador
	if paso_actual <= 8:
		var pieza_lista_en_mostrador: bool = false
		if is_instance_valid(mostrador) and "has_finished_piece" in mostrador:
			pieza_lista_en_mostrador = bool(mostrador.has_finished_piece)
		if (taller_abierto and ticket_visible) or pieza_lista_en_mostrador:
			avanzar_a_paso(9)
			return

	# Paso 9 -> Completado: Entrega el pedido en el mostrador o entra a la Mina Subterránea (Zone.MINA == 3 o Zone.CAVERNAS_MINA == 4)
	if paso_actual == 9:
		if zona_pueblo == 3 or zona_pueblo == 4:
			_completar_tutorial_con_exito()
			return
