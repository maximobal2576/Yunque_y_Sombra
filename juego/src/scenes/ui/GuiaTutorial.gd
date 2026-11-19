# GuiaTutorial.gd
# Sistema de Tutorial Interactivo, Contextual y Diegético en 2 Partes para 'Yunque & Sombra'
# Especialidades combinadas: /programador_godot + /disenador_grafico + /sonidista + /game_feel
# Nomenclatura de nodos 100% en español, cero emojis y tipado estricto (:=) conforme a docs/idea.txt §8.2
extends CanvasLayer

signal paso_cambiado(nuevo_paso: int)
signal parte_1_completada()
signal parte_2_reanudada()
signal tutorial_completado()
signal tutorial_saltado()

const TOTAL_PASOS: int = 14
const ULTIMO_PASO_PARTE_1: int = 9
const PRIMER_PASO_PARTE_2: int = 10
const PEDIDOS_OBJETIVO_DIA_1: int = 3
const INTERVALO_OBSERVACION: float = 0.25

# Paleta de herrería auténtica (/disenador_grafico — WCAG 2.1 AAA > 10:1)
const COLOR_FONDO_CARBON: Color = Color(0.117647, 0.090196, 0.074510, 0.88) # #1e1713 (88% opacidad)
const COLOR_BORDE_BRONCE: Color = Color(0.709804, 0.603922, 0.415686, 1.0) # #b59a6a
const COLOR_TEXTO_MARFIL: Color = Color(0.949020, 0.901961, 0.800000, 1.0) # #f2e6cc
const COLOR_SUBTITULO_AMBAR: Color = Color(0.960784, 0.760784, 0.258824, 1.0) # #f5c242
const COLOR_VERDE_EXITO: Color = Color(0.45, 0.88, 0.52, 1.0)

const PASOS_TUTORIAL: Array[Dictionary] = [
	# Parte 1 (Pasos 1 a 9 — Los 3 Encargos del Día 1)
	{
		"numero": 1,
		"subtitulo": "El Legado del Tío",
		"descripcion": "Lee la carta de tu madre y sigue las flechas hacia el norte hasta la Herrería de Rodrik."
	},
	{
		"numero": 2,
		"subtitulo": "El Taller y el Ciudadano",
		"descripcion": "Entra al Taller por la puerta oeste. El ciudadano tocará la campana al llegar a la ventanilla."
	},
	{
		"numero": 3,
		"subtitulo": "El Encargo Artesanal",
		"descripcion": "Escucha al vecino, espera a que se escriba la receta del pedido y pulsa 'Aceptar Encargo y Forjar'."
	},
	{
		"numero": 4,
		"subtitulo": "La Fragua y los Metales",
		"descripcion": "Toma un lingote del barril (stock 3/3) y caliéntalo según la temperatura propia de ese metal."
	},
	{
		"numero": 5,
		"subtitulo": "El Yunque Cenital",
		"descripcion": "Martilla el metal según su maleabilidad hasta ajustarlo a la silueta guía (95%+)."
	},
	{
		"numero": 6,
		"subtitulo": "Corte con Cizalla",
		"descripcion": "Dibuja la línea de corte sobre las 3 guías respetando el largo máximo de la cizalla."
	},
	{
		"numero": 7,
		"subtitulo": "Templado en Agua",
		"descripcion": "Toma cualquier parte de la pinza, sumerge la pieza en el agua y retírala al sonar el aviso óptimo."
	},
	{
		"numero": 8,
		"subtitulo": "Pulido en Arenisca",
		"descripcion": "Frota la piedra de afilar con calma sobre el metal hasta alcanzar el 95% de brillo."
	},
	{
		"numero": 9,
		"subtitulo": "Los Tres Encargos del Día",
		"descripcion": "Entrega la pieza al cliente y completa los 3 pedidos del primer día (Encargos: %d/3)."
	},
	# Parte 2 (Pasos 10 a 14 — Dormir, Mina, Barril de Entrada, Carga Pesada y Fundición)
	{
		"numero": 10,
		"subtitulo": "Fin de Jornada: A Dormir",
		"descripcion": "Completaste los 3 pedidos del día. Ve al Dormitorio (ala este) y descansa en la cama [E]."
	},
	{
		"numero": 11,
		"subtitulo": "Extracción en la Mina",
		"descripcion": "Entra a la Mina Subterránea por el norte, enciende antorchas y pica vetas para extraer mena en bruto."
	},
	{
		"numero": 12,
		"subtitulo": "Barriles de la Entrada",
		"descripcion": "Inspecciona los barriles a la entrada de la mina [E] y selecciona hasta 3 menas iguales."
	},
	{
		"numero": 13,
		"subtitulo": "Carga Pesada al Taller",
		"descripcion": "Camina lento con el mineral en las manos de regreso hacia el Taller de Forja."
	},
	{
		"numero": 14,
		"subtitulo": "Fundición a Temperatura Máxima",
		"descripcion": "Coloca las menas en la Fragua y atiza el fuelle hasta su punto de fusión máximo para recargar los barriles."
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
var parte_1_ocultada_temporalmente: bool = false

var _tween_activo: Tween = null
var _tween_transicion_partes: Tween = null
var _parte_2_iniciada: bool = false
var _ref_pueblo: Node = null
var _ref_taller: Node = null
var _monedas_previas: int = -1
var _pedidos_entregados_locales: int = 0
var _ultimo_frame_entrega: int = -1
var _ultimo_conteo_mostrado_paso_9: int = -1

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
		if GameManager.has_signal("pedido_diario_completado") and not GameManager.is_connected("pedido_diario_completado", _on_pedido_diario_completado):
			GameManager.connect("pedido_diario_completado", _on_pedido_diario_completado)
		if GameManager.has_signal("sueno_completado") and not GameManager.is_connected("sueno_completado", _on_sueno_completado):
			GameManager.connect("sueno_completado", _on_sueno_completado)
		if GameManager.has_signal("menas_barril_mina_cambiado") and not GameManager.is_connected("menas_barril_mina_cambiado", _on_menas_barril_mina_cambiado):
			GameManager.connect("menas_barril_mina_cambiado", _on_menas_barril_mina_cambiado)
		if GameManager.has_signal("menas_en_mano_cambiado") and not GameManager.is_connected("menas_en_mano_cambiado", _on_menas_en_mano_cambiado):
			GameManager.connect("menas_en_mano_cambiado", _on_menas_en_mano_cambiado)
		if GameManager.has_signal("mena_fundida_en_fragua") and not GameManager.is_connected("mena_fundida_en_fragua", _on_mena_fundida_en_fragua):
			GameManager.connect("mena_fundida_en_fragua", _on_mena_fundida_en_fragua)

	_actualizar_vista_paso(paso_actual, false)
	_resolver_referencias_escena()

func _configurar_filtros_raton_seguros() -> void:
	# Garantiza que el contenedor y etiquetas jamás bloqueen clics en campana ni estaciones (MOUSE_FILTER_IGNORE)
	if is_instance_valid(contenedor_raiz_tutorial):
		contenedor_raiz_tutorial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(panel_pergamino_tutorial):
		panel_pergamino_tutorial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(contenedor_vertical_tutorial):
		contenedor_vertical_tutorial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(cabecera_tutorial):
		cabecera_tutorial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(etiqueta_subtitulo_paso):
		etiqueta_subtitulo_paso.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(barra_progreso_tutorial):
		barra_progreso_tutorial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(etiqueta_instruccion_tutorial):
		etiqueta_instruccion_tutorial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(boton_saltar_tutorial):
		boton_saltar_tutorial.mouse_filter = Control.MOUSE_FILTER_STOP

func _unhandled_input(event: InputEvent) -> void:
	if not tutorial_activo or tutorial_finalizado or not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_T:
			saltar_tutorial()

## Avanza directamente a un paso específico (1 a 14) o completa el tutorial si supera TOTAL_PASOS
func avanzar_a_paso(nuevo_paso: int) -> void:
	if not tutorial_activo or tutorial_finalizado:
		return
	if nuevo_paso <= paso_actual:
		if paso_actual == ULTIMO_PASO_PARTE_1:
			_refrescar_contador_paso_9()
		return
	if nuevo_paso > TOTAL_PASOS:
		_completar_tutorial_con_exito()
		return

	# Si había una transición entre Parte 1 y Parte 2 en curso y se avanza más allá del Paso 10, restaurar visibilidad
	if _tween_transicion_partes and _tween_transicion_partes.is_valid() and nuevo_paso > PRIMER_PASO_PARTE_2:
		_tween_transicion_partes.kill()
		parte_1_ocultada_temporalmente = false
		visible = true
		if is_instance_valid(panel_pergamino_tutorial):
			panel_pergamino_tutorial.modulate.a = 1.0
			panel_pergamino_tutorial.scale = Vector2.ONE

	if nuevo_paso == PRIMER_PASO_PARTE_2 and not _parte_2_iniciada:
		_iniciar_transicion_parte_2()
		return

	paso_actual = nuevo_paso
	if paso_actual >= PRIMER_PASO_PARTE_2:
		_parte_2_iniciada = true
	_actualizar_vista_paso(paso_actual, true)
	paso_cambiado.emit(paso_actual)

## Notifica un hito externo desde GameManager, estaciones, cama, mina o barriles
func notificar_hito_externo(hito_id: String) -> void:
	notificar_evento(hito_id)

## Notifica un evento semántico desde cualquier estación o nivel para avanzar de forma desacoplada
func notificar_evento(evento_id: String) -> void:
	if not tutorial_activo or tutorial_finalizado:
		return
	var clave := evento_id.strip_edges().to_lower()
	match clave:
		"pasillo_entrado", "taller_abierto", "paso_1_completado":
			if paso_actual == 1:
				avanzar_a_paso(2)
			elif paso_actual == 13:
				avanzar_a_paso(14)
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
		"pedido_entregado", "paso_9_progreso":
			_registrar_entrega_pedido()
		"tercer_pedido_completado", "tres_pedidos_completados", "parte_1_completada", "paso_9_completado":
			if _pedidos_entregados_locales < PEDIDOS_OBJETIVO_DIA_1:
				_pedidos_entregados_locales = PEDIDOS_OBJETIVO_DIA_1
			_iniciar_transicion_parte_2()
		"ha_dormido", "dormir_completado", "cama_usada", "mina_explorada", "zona_mina", "paso_10_completado":
			if paso_actual == 9 or paso_actual == 10:
				avanzar_a_paso(11)
		"mena_extraida", "mineral_extraido", "veta_picada", "paso_11_completado":
			if paso_actual <= 11 and paso_actual >= 9:
				avanzar_a_paso(12)
		"menas_seleccionadas", "barril_mina_recogido", "carga_pesada_iniciada", "paso_12_completado":
			if paso_actual <= 12 and paso_actual >= 9:
				avanzar_a_paso(13)
		"taller_con_menas", "modo_fundicion_iniciado", "paso_13_completado":
			if paso_actual <= 13 and paso_actual >= 9:
				avanzar_a_paso(14)
		"fundicion_mena_completada", "mision_fundicion_completada", "paso_14_completado", "tutorial_completado":
			_completar_tutorial_con_exito()

## Ejecuta el ocultamiento breve de la Parte 1 (0.4s fade-out) y la reanudación en el Paso 10 tras 0.8s
func _iniciar_transicion_parte_2() -> void:
	if not tutorial_activo or tutorial_finalizado:
		return
	if _parte_2_iniciada and paso_actual >= PRIMER_PASO_PARTE_2:
		return

	_parte_2_iniciada = true
	paso_actual = PRIMER_PASO_PARTE_2
	parte_1_ocultada_temporalmente = true
	_actualizar_vista_paso(paso_actual, false)
	parte_1_completada.emit()
	paso_cambiado.emit(paso_actual)

	if not is_instance_valid(panel_pergamino_tutorial):
		parte_1_ocultada_temporalmente = false
		parte_2_reanudada.emit()
		return

	if _tween_activo and _tween_activo.is_valid():
		_tween_activo.kill()
	if _tween_transicion_partes and _tween_transicion_partes.is_valid():
		_tween_transicion_partes.kill()

	panel_pergamino_tutorial.pivot_offset = panel_pergamino_tutorial.size * 0.5
	_tween_transicion_partes = create_tween()
	_tween_transicion_partes.tween_property(panel_pergamino_tutorial, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween_transicion_partes.tween_interval(0.8)
	_tween_transicion_partes.tween_callback(_reanudar_visualmente_parte_2)
	_tween_transicion_partes.tween_property(panel_pergamino_tutorial, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _reanudar_visualmente_parte_2() -> void:
	if not tutorial_activo or tutorial_finalizado:
		return
	parte_1_ocultada_temporalmente = false
	visible = true
	_actualizar_vista_paso(paso_actual, false)
	_reproducir_sonido_paso()
	_aplicar_pulso_elastico()
	parte_2_reanudada.emit()

## Oculta inmediatamente el tutorial a petición del jugador veterano
func saltar_tutorial() -> void:
	if not tutorial_activo and tutorial_finalizado:
		return
	tutorial_activo = false
	tutorial_finalizado = true
	parte_1_ocultada_temporalmente = false
	if is_instance_valid(temporizador_observacion):
		temporizador_observacion.stop()
	if _tween_transicion_partes and _tween_transicion_partes.is_valid():
		_tween_transicion_partes.kill()
	_reproducir_sonido_paso()
	tutorial_saltado.emit()
	_animar_ocultamiento_panel()

func _obtener_pedidos_completados_hoy() -> int:
	var conteo: int = _pedidos_entregados_locales
	if is_instance_valid(GameManager) and "pedidos_completados_hoy" in GameManager:
		conteo = maxi(conteo, int(GameManager.pedidos_completados_hoy))
	if is_instance_valid(_ref_taller) and "vista_mostrador" in _ref_taller and is_instance_valid(_ref_taller.vista_mostrador):
		var mostrador: Node = _ref_taller.vista_mostrador
		if "pedidos_completados_hoy" in mostrador:
			conteo = maxi(conteo, int(mostrador.pedidos_completados_hoy))
		elif "orders_completed_today" in mostrador:
			conteo = maxi(conteo, int(mostrador.orders_completed_today))
	return conteo

func _formatear_descripcion_paso(num_paso: int, plantilla: String) -> String:
	if num_paso == ULTIMO_PASO_PARTE_1 and plantilla.contains("%d"):
		var encargos_actuales: int = clampi(_obtener_pedidos_completados_hoy(), 0, PEDIDOS_OBJETIVO_DIA_1)
		_ultimo_conteo_mostrado_paso_9 = encargos_actuales
		return plantilla % encargos_actuales
	return plantilla

func _refrescar_contador_paso_9() -> void:
	if paso_actual != ULTIMO_PASO_PARTE_1:
		return
	var encargos_actuales: int = clampi(_obtener_pedidos_completados_hoy(), 0, PEDIDOS_OBJETIVO_DIA_1)
	if encargos_actuales != _ultimo_conteo_mostrado_paso_9:
		var datos: Dictionary = PASOS_TUTORIAL[ULTIMO_PASO_PARTE_1 - 1]
		var plantilla := str(datos.get("descripcion", ""))
		if is_instance_valid(etiqueta_instruccion_tutorial):
			etiqueta_instruccion_tutorial.text = _formatear_descripcion_paso(ULTIMO_PASO_PARTE_1, plantilla)

func _actualizar_vista_paso(num_paso: int, con_feedback: bool) -> void:
	var idx := clampi(num_paso - 1, 0, PASOS_TUTORIAL.size() - 1)
	var datos: Dictionary = PASOS_TUTORIAL[idx]

	if is_instance_valid(etiqueta_subtitulo_paso):
		etiqueta_subtitulo_paso.text = str(datos.get("subtitulo", ""))
		etiqueta_subtitulo_paso.add_theme_color_override("font_color", COLOR_SUBTITULO_AMBAR)

	if is_instance_valid(etiqueta_instruccion_tutorial):
		var desc_base := str(datos.get("descripcion", ""))
		etiqueta_instruccion_tutorial.text = _formatear_descripcion_paso(num_paso, desc_base)
		etiqueta_instruccion_tutorial.add_theme_color_override("font_color", COLOR_TEXTO_MARFIL)

	if is_instance_valid(barra_progreso_tutorial):
		barra_progreso_tutorial.max_value = float(TOTAL_PASOS)
		if con_feedback:
			var tw_barra := create_tween()
			tw_barra.tween_property(barra_progreso_tutorial, "value", float(num_paso), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			barra_progreso_tutorial.value = float(num_paso)

	if con_feedback:
		_reproducir_sonido_paso()
		_aplicar_pulso_elastico()

func _reproducir_sonido_paso() -> void:
	if is_instance_valid(AudioManager) and AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx("step_complete", 2.0, 0.04)
		AudioManager.play_sfx("bell", -6.0, 0.05)

func _aplicar_pulso_elastico() -> void:
	if not is_instance_valid(panel_pergamino_tutorial):
		return
	if _tween_activo and _tween_activo.is_valid():
		_tween_activo.kill()

	panel_pergamino_tutorial.pivot_offset = panel_pergamino_tutorial.size * 0.5
	panel_pergamino_tutorial.scale = Vector2(1.05, 0.95)
	_tween_activo = create_tween()
	_tween_activo.tween_property(panel_pergamino_tutorial, "scale", Vector2(0.98, 1.02), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_activo.tween_property(panel_pergamino_tutorial, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _completar_tutorial_con_exito() -> void:
	if tutorial_finalizado:
		return
	tutorial_finalizado = true
	tutorial_activo = false
	parte_1_ocultada_temporalmente = false
	if is_instance_valid(temporizador_observacion):
		temporizador_observacion.stop()
	if _tween_transicion_partes and _tween_transicion_partes.is_valid():
		_tween_transicion_partes.kill()

	visible = true
	if is_instance_valid(panel_pergamino_tutorial):
		panel_pergamino_tutorial.modulate.a = 1.0
		panel_pergamino_tutorial.scale = Vector2.ONE

	if is_instance_valid(etiqueta_subtitulo_paso):
		etiqueta_subtitulo_paso.text = "Oficio de Herrero Completado"
		etiqueta_subtitulo_paso.add_theme_color_override("font_color", COLOR_VERDE_EXITO)

	if is_instance_valid(etiqueta_instruccion_tutorial):
		etiqueta_instruccion_tutorial.text = "Dominas el ciclo del taller y la fundición. Forja de día, extrae mena de noche y descubre la verdad del pueblo."

	if is_instance_valid(barra_progreso_tutorial):
		barra_progreso_tutorial.max_value = float(TOTAL_PASOS)
		barra_progreso_tutorial.value = float(TOTAL_PASOS)

	if is_instance_valid(boton_saltar_tutorial):
		boton_saltar_tutorial.visible = false

	_reproducir_sonido_paso()
	_aplicar_pulso_elastico()
	tutorial_completado.emit()

	var tw_cierre := create_tween()
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
	_tween_activo.chain().tween_callback(func() -> void: visible = false)

func _registrar_entrega_pedido() -> void:
	if not tutorial_activo or tutorial_finalizado:
		return
	var frame_actual: int = Engine.get_process_frames()
	if frame_actual != _ultimo_frame_entrega:
		_ultimo_frame_entrega = frame_actual
		_pedidos_entregados_locales += 1

	if paso_actual < ULTIMO_PASO_PARTE_1:
		avanzar_a_paso(ULTIMO_PASO_PARTE_1)
	else:
		_refrescar_contador_paso_9()

	var total_pedidos: int = _obtener_pedidos_completados_hoy()
	if total_pedidos >= PEDIDOS_OBJETIVO_DIA_1 and paso_actual <= ULTIMO_PASO_PARTE_1:
		_iniciar_transicion_parte_2()

func _on_item_crafted(_item_name: String, _quality: float) -> void:
	if tutorial_activo and not tutorial_finalizado and paso_actual <= ULTIMO_PASO_PARTE_1:
		_registrar_entrega_pedido()

func _on_coins_changed(nuevas_monedas: int) -> void:
	if _monedas_previas >= 0 and nuevas_monedas > _monedas_previas:
		if tutorial_activo and not tutorial_finalizado and paso_actual >= 8 and paso_actual <= ULTIMO_PASO_PARTE_1:
			_registrar_entrega_pedido()
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
		_registrar_entrega_pedido()

func _verificar_estado_juego() -> void:
	if not tutorial_activo or tutorial_finalizado:
		return

	_resolver_referencias_escena()

	var zona_pueblo := -1
	if is_instance_valid(_ref_pueblo) and "current_zone" in _ref_pueblo:
		zona_pueblo = int(_ref_pueblo.current_zone)

	var taller_abierto := false
	var pestana_actual := -1
	var mostrador: Node = null
	var ticket_visible := false
	var modo_fundicion := false

	if is_instance_valid(_ref_taller) and _ref_taller is CanvasLayer:
		taller_abierto = (_ref_taller as CanvasLayer).visible
		if "current_station" in _ref_taller:
			pestana_actual = int(_ref_taller.current_station)
		if "vista_mostrador" in _ref_taller:
			mostrador = _ref_taller.vista_mostrador
		if "capa_ticket_final" in _ref_taller and is_instance_valid(_ref_taller.capa_ticket_final):
			ticket_visible = (_ref_taller.capa_ticket_final as Control).visible
		if "modo_fundicion_mena" in _ref_taller:
			modo_fundicion = bool(_ref_taller.modo_fundicion_mena)

	var pedidos_hoy: int = _obtener_pedidos_completados_hoy()
	var ha_dormido := false
	var menas_en_barril := 0
	var menas_en_mano := 0
	var fundicion_completada := false

	if is_instance_valid(GameManager):
		if "ha_dormido_tras_jornada" in GameManager:
			ha_dormido = bool(GameManager.ha_dormido_tras_jornada)
		if GameManager.current_state == GameManager.State.SLEEPING:
			ha_dormido = true
		if "menas_barril_mina" in GameManager and GameManager.menas_barril_mina is Dictionary:
			var dict_barril: Dictionary = GameManager.menas_barril_mina
			menas_en_barril = int(dict_barril.get("hierro_dulce", 0)) + int(dict_barril.get("acero_carbono", 0)) + int(dict_barril.get("bronce_cobre", 0))
		if "menas_en_mano_cantidad" in GameManager:
			menas_en_mano = int(GameManager.menas_en_mano_cantidad)
		if "mision_fundicion_mena_completada" in GameManager:
			fundicion_completada = bool(GameManager.mision_fundicion_mena_completada)

	# Si la misión final de fundición de mena ya se completó, cerrar tutorial con éxito
	if fundicion_completada:
		_completar_tutorial_con_exito()
		return

	# Paso 1 -> 2: El jugador entra al PASILLO (Zone.PASILLO == 1) o abre directamente el taller
	if paso_actual == 1:
		if zona_pueblo == 1 or taller_abierto:
			avanzar_a_paso(2)
			return

	# Paso 2 -> 3: Se abre WorkshopStationView y el ciudadano toca la campana / aparece el pergamino de comanda
	if paso_actual == 2:
		if taller_abierto and is_instance_valid(mostrador):
			var comanda_visible := false
			if "pergamino_comanda" in mostrador and is_instance_valid(mostrador.pergamino_comanda):
				comanda_visible = (mostrador.pergamino_comanda as Control).visible
			elif "has_active_order" in mostrador and bool(mostrador.has_active_order):
				comanda_visible = true
			if comanda_visible or pestana_actual >= 1:
				avanzar_a_paso(3)
				return

	# Paso 3 -> 4: El jugador acepta el encargo y pasa a la Fragua (StationTab.FORGE == 1)
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
		var pieza_lista_en_mostrador := false
		if is_instance_valid(mostrador) and "has_finished_piece" in mostrador:
			pieza_lista_en_mostrador = bool(mostrador.has_finished_piece)
		if (taller_abierto and ticket_visible) or pieza_lista_en_mostrador or pedidos_hoy >= 1:
			avanzar_a_paso(9)
			return

	# Paso 9 -> 10: Completar los 3 encargos del Día 1 (o transición directa si ya durmió / entró a la mina)
	if paso_actual == 9:
		_refrescar_contador_paso_9()
		if pedidos_hoy >= PEDIDOS_OBJETIVO_DIA_1:
			_iniciar_transicion_parte_2()
			return
		if ha_dormido or zona_pueblo == 3 or zona_pueblo == 4:
			avanzar_a_paso(11)
			return

	# Paso 10 -> 11: Dormir en la cama tras la jornada o entrar a Zone.MINA (3) / Zone.CAVERNAS_MINA (4)
	if paso_actual == 10:
		if ha_dormido or zona_pueblo == 3 or zona_pueblo == 4:
			avanzar_a_paso(11)
			return

	# Paso 11 -> 12: Extraer mineral en bruto en la mina (almacenado en barriles de la entrada)
	if paso_actual == 11:
		if menas_en_barril > 0:
			avanzar_a_paso(12)
			return
		if menas_en_mano > 0:
			avanzar_a_paso(13)
			return

	# Paso 12 -> 13: Seleccionar hasta 3 menas del barril y llevarlas en la mano (caminata lenta)
	if paso_actual == 12:
		if menas_en_mano > 0:
			avanzar_a_paso(13)
			return

	# Paso 13 -> 14: Abrir el Taller llevando las menas en la mano o en modo fundición
	if paso_actual == 13:
		if taller_abierto and (menas_en_mano > 0 or modo_fundicion or pestana_actual == 1):
			avanzar_a_paso(14)
			return

# --- Manejadores de señales de GameManager (Parte 2 del tutorial) ---

func _on_pedido_diario_completado(total_hoy: int) -> void:
	_pedidos_entregados_locales = maxi(_pedidos_entregados_locales, total_hoy)
	if total_hoy >= PEDIDOS_OBJETIVO_DIA_1:
		_iniciar_transicion_parte_2()
	else:
		_refrescar_contador_paso_9()

func _on_sueno_completado() -> void:
	notificar_evento("ha_dormido")

func _on_menas_barril_mina_cambiado() -> void:
	if paso_actual >= PRIMER_PASO_PARTE_2 and paso_actual <= 11:
		notificar_evento("mena_extraida")

func _on_menas_en_mano_cambiado(_tipo: String, cantidad: int) -> void:
	if cantidad > 0:
		notificar_evento("menas_seleccionadas")

func _on_mena_fundida_en_fragua(_tipo: String, _cantidad: int) -> void:
	notificar_evento("fundicion_mena_completada")
