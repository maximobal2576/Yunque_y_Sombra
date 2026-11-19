# WorkshopStationView.gd
# Orquestador maestro de la experiencia del Taller y Forja en primera persona
# Integra: [1. Mostrador] -> [2. Fragua con 3 Barriles de Metales y Lingote Dentro del Hogar]
# -> [3. Yunque Cenital] -> [4. Corte Manual] -> [5. Tina de Inmersión] -> [6. Pulido] -> [Entrega Arrastrable & Ticket]
# Nomenclatura del SceneTree 100% en Español conforme a docs/idea.txt §8.2
extends CanvasLayer

signal workshop_closed()

enum StationTab {
	COUNTER = 0,
	FORGE = 1,
	ANVIL = 2,
	CUTTING = 3,
	QUENCHING = 4,
	POLISHING = 5
}

var current_station: StationTab = StationTab.COUNTER

# Métricas estrictas de calidad por etapa (0.0 a 1.0)
var score_forge: float = 0.0
var score_anvil: float = 0.0
var score_cut: float = 0.0
var score_quench: float = 0.0
var score_polish: float = 0.0
var final_quality: float = 0.0
var reward_coins: int = 0

# --- ESTACIÓN 2: FRAGUA (Sistema físico térmico realista en °C y 3 Barriles de Lingotes — /herrero) ---
const EscalaTermica = preload("res://src/components/EscalaTermicaAcero.gd")

const TEMP_AMBIENTE_FRAGUA: float = EscalaTermica.TEMP_AMBIENTE
const TEMP_OPTIMAL_MIN: float = EscalaTermica.TEMP_FORJA_OPTIMA_MIN # 1000.0°C
const TEMP_OPTIMAL_MAX: float = EscalaTermica.TEMP_FORJA_OPTIMA_MAX # 1150.0°C
const TEMP_QUEMADO: float = EscalaTermica.TEMP_QUEMADO # 1250.0°C
const TEMP_MANOMETRO_MAX: float = EscalaTermica.TEMP_MANOMETRO_MAX # 1400.0°C
const AUMENTO_POR_FUELLE: float = 95.0 # 11 bombeos desde 20°C alcanzan ~1065°C con inercia realista
const DECAIMIENTO_FRAGUA_POR_SEGUNDO: float = 28.0 # Inercia térmica del lecho de carbón (/herrero)

const CATALOGO_METALES: Dictionary = {
	"hierro_dulce": {
		"nombre": "Hierro Dulce",
		"color_frio": Color(0.58, 0.64, 0.70),
		"color_pulido": Color(0.74, 0.79, 0.84)
	},
	"acero_carbono": {
		"nombre": "Acero al Carbono",
		"color_frio": Color(0.38, 0.42, 0.48),
		"color_pulido": Color(0.68, 0.72, 0.78)
	},
	"bronce_cobre": {
		"nombre": "Bronce / Cobre",
		"color_frio": Color(0.78, 0.48, 0.28),
		"color_pulido": Color(0.88, 0.64, 0.40)
	}
}

var temperature: float = TEMP_AMBIENTE_FRAGUA
var _temperatura_visual: float = TEMP_AMBIENTE_FRAGUA
var is_forge_settled: bool = false
var _estaba_en_zona_optima: bool = false
var _estaba_sobrecalentado: bool = false
var _recalentando_en_fragua: bool = false
var _ultima_forma_cortada: PackedVector2Array = PackedVector2Array()
var _chispas_horno: CPUParticles2D = null

var tiene_lingote_en_horno: bool = false
var metal_seleccionado_id: String = "hierro_dulce"
var _arrastrando_lingote_barril: bool = false
var _metal_en_arrastre: String = ""

# Subestaciones instanciadas en Español
@onready var vista_mostrador: Control = $PanelPrincipal/AreaContenido/VistaMostrador
@onready var estacion_fragua: Control = $PanelPrincipal/AreaContenido/EstacionFragua
@onready var estacion_yunque: Control = $PanelPrincipal/AreaContenido/EstacionYunqueCenital
@onready var estacion_corte: Control = $PanelPrincipal/AreaContenido/EstacionCorteManual
@onready var estacion_tina: Control = $PanelPrincipal/AreaContenido/EstacionTinaTemplado
@onready var estacion_pulido: Control = $PanelPrincipal/AreaContenido/EstacionPulido

# Botones de navegación de la barra superior
@onready var btn_tab_mostrador: Button = $PanelPrincipal/Cabecera/ContenedorPestanas/BotonPestanaMostrador
@onready var btn_tab_fragua: Button = $PanelPrincipal/Cabecera/ContenedorPestanas/BotonPestanaFragua
@onready var btn_tab_yunque: Button = $PanelPrincipal/Cabecera/ContenedorPestanas/BotonPestanaYunque
@onready var btn_tab_corte: Button = $PanelPrincipal/Cabecera/ContenedorPestanas/BotonPestanaCorte
@onready var btn_tab_tina: Button = $PanelPrincipal/Cabecera/ContenedorPestanas/BotonPestanaTina
@onready var btn_tab_pulido: Button = $PanelPrincipal/Cabecera/ContenedorPestanas/BotonPestanaPulido
@onready var btn_salir_pasillo: Button = $PanelPrincipal/Cabecera/BotonSalirPasillo

# Nodos de Fragua y Barriles en Español
@onready var barril_hierro_dulce: Panel = $PanelPrincipal/AreaContenido/EstacionFragua/ContenedorBarrilesMetales/BarrilHierroDulce
@onready var barril_acero_carbono: Panel = $PanelPrincipal/AreaContenido/EstacionFragua/ContenedorBarrilesMetales/BarrilAceroCarbono
@onready var barril_bronce_cobre: Panel = $PanelPrincipal/AreaContenido/EstacionFragua/ContenedorBarrilesMetales/BarrilBronceCobre
@onready var horno_fragua: TextureRect = $PanelPrincipal/AreaContenido/EstacionFragua/HornoFragua
@onready var interior_boca_horno: Node2D = $PanelPrincipal/AreaContenido/EstacionFragua/HornoFragua/InteriorBocaHorno
@onready var lecho_brasas_fondo: Polygon2D = $PanelPrincipal/AreaContenido/EstacionFragua/HornoFragua/InteriorBocaHorno/LechoBrasasFondo
@onready var lingote_en_brasas: Polygon2D = $PanelPrincipal/AreaContenido/EstacionFragua/HornoFragua/InteriorBocaHorno/LingoteEnBrasas
@onready var cara_superior_lingote: Polygon2D = $PanelPrincipal/AreaContenido/EstacionFragua/HornoFragua/InteriorBocaHorno/LingoteEnBrasas/CaraSuperiorLingote
@onready var llamas_internas_hogar: Polygon2D = $PanelPrincipal/AreaContenido/EstacionFragua/HornoFragua/InteriorBocaHorno/LlamasInternasHogar
@onready var ascuas_vivas_delanteras: Polygon2D = $PanelPrincipal/AreaContenido/EstacionFragua/HornoFragua/InteriorBocaHorno/AscuasVivasDelanteras
@onready var indicador_boca_horno: Label = $PanelPrincipal/AreaContenido/EstacionFragua/HornoFragua/InteriorBocaHorno/IndicadorBocaHorno
@onready var lingote_arrastrado: Polygon2D = $PanelPrincipal/AreaContenido/EstacionFragua/LingoteArrastrado

@onready var pivote_aguja: Control = $PanelPrincipal/AreaContenido/EstacionFragua/ManometroTemperatura/PivoteAguja
@onready var etiqueta_temperatura: Label = $PanelPrincipal/AreaContenido/EstacionFragua/ManometroTemperatura/EtiquetaTemperatura
@onready var lingote_fragua: ColorRect = $PanelPrincipal/AreaContenido/EstacionFragua/HornoFragua/LingoteFragua
@onready var resplandor_fuego: ColorRect = $PanelPrincipal/AreaContenido/EstacionFragua/HornoFragua/ResplandorFuego
@onready var icono_fuelle: TextureRect = $PanelPrincipal/AreaContenido/EstacionFragua/BotonAtizarFuelle/IconoFuelle
@onready var btn_atizar_fuelle: Button = $PanelPrincipal/AreaContenido/EstacionFragua/BotonAtizarFuelle
@onready var btn_llevar_al_yunque: Button = $PanelPrincipal/AreaContenido/EstacionFragua/BotonLlevarAlYunque
@onready var etiqueta_estado_fragua: Label = $PanelPrincipal/AreaContenido/EstacionFragua/EtiquetaEstadoFragua

# Ticket Papa's en Español
@onready var capa_ticket_final: Control = $CapaTicketFinal
@onready var ticket_score_forge: Label = $CapaTicketFinal/PanelTicket/ContenidoTicket/GrillaPuntajes/PuntajeFragua
@onready var ticket_score_anvil: Label = $CapaTicketFinal/PanelTicket/ContenidoTicket/GrillaPuntajes/PuntajeYunque
@onready var ticket_score_cut: Label = $CapaTicketFinal/PanelTicket/ContenidoTicket/GrillaPuntajes/PuntajeCorte
@onready var ticket_score_quench: Label = $CapaTicketFinal/PanelTicket/ContenidoTicket/GrillaPuntajes/PuntajeTina
@onready var ticket_score_polish: Label = $CapaTicketFinal/PanelTicket/ContenidoTicket/GrillaPuntajes/PuntajePulido
@onready var ticket_score_total: Label = $CapaTicketFinal/PanelTicket/ContenidoTicket/EtiquetaCalidadTotal
@onready var ticket_rank_label: Label = $CapaTicketFinal/PanelTicket/ContenidoTicket/EtiquetaRango
@onready var ticket_reward_label: Label = $CapaTicketFinal/PanelTicket/ContenidoTicket/EtiquetaRecompensa
@onready var btn_deliver_to_counter: Button = $CapaTicketFinal/PanelTicket/ContenidoTicket/AccionesTicket/BotonEntregarMostrador
@onready var btn_craft_again: Button = $CapaTicketFinal/PanelTicket/ContenidoTicket/AccionesTicket/ContenedorSecundario/BotonForjarDeNuevo
@onready var btn_ticket_exit: Button = $CapaTicketFinal/PanelTicket/ContenidoTicket/AccionesTicket/ContenedorSecundario/BotonSalirTicket

# Compatibilidad para QA y scripts previos
var counter_view: Control:
	get: return vista_mostrador
var station_forge: Control:
	get: return estacion_fragua
var anvil_station: Control:
	get: return estacion_yunque
var cut_station: Control:
	get: return estacion_corte
var quench_station: Control:
	get: return estacion_tina
var polish_station: Control:
	get: return estacion_pulido
var btn_tab_counter: Button:
	get: return btn_tab_mostrador
var btn_tab_forge: Button:
	get: return btn_tab_fragua
var btn_tab_anvil: Button:
	get: return btn_tab_yunque
var btn_tab_cutting: Button:
	get: return btn_tab_corte
var btn_tab_quench: Button:
	get: return btn_tab_tina
var btn_tab_polish: Button:
	get: return btn_tab_pulido
var btn_exit: Button:
	get: return btn_salir_pasillo
var btn_bellows: Button:
	get: return btn_atizar_fuelle
var btn_to_anvil: Button:
	get: return btn_llevar_al_yunque
var ticket_overlay: Control:
	get: return capa_ticket_final

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 12
	_configurar_atmosfera_fragua()
	_connect_signals()

func _configurar_atmosfera_fragua() -> void:
	if horno_fragua:
		_chispas_horno = CPUParticles2D.new()
		_chispas_horno.name = "ChispasHorno"
		_chispas_horno.position = Vector2(270, 225)
		_chispas_horno.amount = 22
		_chispas_horno.lifetime = 0.85
		_chispas_horno.direction = Vector2(0, -1)
		_chispas_horno.spread = 55.0
		_chispas_horno.gravity = Vector2(0, -110)
		_chispas_horno.initial_velocity_min = 35.0
		_chispas_horno.initial_velocity_max = 95.0
		_chispas_horno.scale_amount_min = 2.0
		_chispas_horno.scale_amount_max = 4.0
		_chispas_horno.color = Color(1.0, 0.72, 0.22, 0.88)
		horno_fragua.add_child(_chispas_horno)

	var shader_metal: Shader = load("res://assets/shaders/metal_incandescente.gdshader")
	if shader_metal and lingote_en_brasas:
		var mat_m: ShaderMaterial = ShaderMaterial.new()
		mat_m.shader = shader_metal
		mat_m.set_shader_parameter("temperatura", TEMP_AMBIENTE_FRAGUA)
		mat_m.set_shader_parameter("semi_grosor_max", 12.0)
		mat_m.set_shader_parameter("semi_largo", 60.0)
		lingote_en_brasas.material = mat_m

	var shader_vineta: Shader = load("res://assets/shaders/vineta_fragua.gdshader")
	if shader_vineta and estacion_fragua:
		var vineta: ColorRect = ColorRect.new()
		vineta.name = "VinetaFragua"
		vineta.set_anchors_preset(Control.PRESET_FULL_RECT)
		vineta.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var mat_v: ShaderMaterial = ShaderMaterial.new()
		mat_v.shader = shader_vineta
		vineta.material = mat_v
		estacion_fragua.add_child(vineta)
		estacion_fragua.move_child(vineta, 0)

func _connect_signals() -> void:
	# Pestañas
	btn_tab_mostrador.pressed.connect(func(): _switch_tab(StationTab.COUNTER))
	btn_tab_fragua.pressed.connect(func(): _switch_tab(StationTab.FORGE))
	btn_tab_yunque.pressed.connect(func(): _switch_tab(StationTab.ANVIL))
	btn_tab_corte.pressed.connect(func(): _switch_tab(StationTab.CUTTING))
	btn_tab_tina.pressed.connect(func(): _switch_tab(StationTab.QUENCHING))
	btn_tab_pulido.pressed.connect(func(): _switch_tab(StationTab.POLISHING))
	btn_salir_pasillo.pressed.connect(close_station)

	# 1. Mostrador
	vista_mostrador.order_accepted.connect(_on_order_accepted)
	vista_mostrador.go_to_workbench_requested.connect(func(): _switch_tab(StationTab.FORGE))
	vista_mostrador.item_delivered.connect(_on_customer_item_delivered)

	# 2. Fragua y 3 Barriles de Metales
	btn_atizar_fuelle.pressed.connect(_on_bellows_pressed)
	btn_llevar_al_yunque.pressed.connect(_on_to_anvil_pressed)
	if barril_hierro_dulce:
		barril_hierro_dulce.gui_input.connect(func(ev: InputEvent): _on_barril_gui_input(ev, "hierro_dulce"))
	if barril_acero_carbono:
		barril_acero_carbono.gui_input.connect(func(ev: InputEvent): _on_barril_gui_input(ev, "acero_carbono"))
	if barril_bronce_cobre:
		barril_bronce_cobre.gui_input.connect(func(ev: InputEvent): _on_barril_gui_input(ev, "bronce_cobre"))

	# 3. Yunque Cenital
	estacion_yunque.anvil_shaping_completed.connect(_on_anvil_completed)
	if estacion_yunque.has_signal("recalentar_solicitado"):
		estacion_yunque.recalentar_solicitado.connect(_on_anvil_reheat_requested)

	# 4. Corte Manual
	estacion_corte.cutting_completed.connect(_on_cutting_completed)

	# 5. Tina de Inmersión
	estacion_tina.quenching_completed.connect(_on_quenching_completed)

	# 6. Pulido
	estacion_pulido.polishing_completed.connect(_on_polishing_completed)

	# Ticket
	btn_deliver_to_counter.pressed.connect(_on_deliver_to_counter_pressed)
	btn_craft_again.pressed.connect(reset_recipe)
	btn_ticket_exit.pressed.connect(close_station)

func _on_barril_gui_input(event: InputEvent, metal_id: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_arrastrando_lingote_barril = true
		_metal_en_arrastre = metal_id
		AudioManager.play_sfx("place_item", -3.0, 0.08)
		if lingote_arrastrado:
			lingote_arrastrado.visible = true
			lingote_arrastrado.color = CATALOGO_METALES[metal_id]["color_frio"]
			lingote_arrastrado.global_position = estacion_fragua.get_global_mouse_position()
		etiqueta_estado_fragua.text = "Arrastra el lingote de %s hasta la boca del horno y suéltalo entre las brasas." % CATALOGO_METALES[metal_id]["nombre"]
		etiqueta_estado_fragua.modulate = Color(0.96, 0.82, 0.35)

func _input(event: InputEvent) -> void:
	if not visible or current_station != StationTab.FORGE or not _arrastrando_lingote_barril:
		return
	if event is InputEventMouseMotion:
		if lingote_arrastrado:
			lingote_arrastrado.global_position = estacion_fragua.get_global_mouse_position()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_arrastrando_lingote_barril = false
		if lingote_arrastrado:
			lingote_arrastrado.visible = false
		# Si soltó sobre el horno o hizo clic en el barril, introducir el lingote dentro del hogar
		var pos_mouse: Vector2 = estacion_fragua.get_global_mouse_position()
		if horno_fragua == null or horno_fragua.get_global_rect().grow(80.0).has_point(pos_mouse) or pos_mouse.x > 250.0 or not tiene_lingote_en_horno:
			colocar_lingote_en_horno(_metal_en_arrastre)

## Introduce físicamente el lingote seleccionado dentro de la cavidad de brasas del horno
func colocar_lingote_en_horno(metal_id: String = "hierro_dulce") -> void:
	if not CATALOGO_METALES.has(metal_id):
		metal_id = "hierro_dulce"
	metal_seleccionado_id = metal_id
	tiene_lingote_en_horno = true
	AudioManager.play_sfx("place_item", 0.5, 0.06)

	if indicador_boca_horno:
		indicador_boca_horno.visible = false
	if lingote_en_brasas:
		lingote_en_brasas.visible = true
		lingote_en_brasas.position = Vector2(-42.0, -14.0)
		lingote_en_brasas.scale = Vector2(1.12, 1.12)
		var tw: Tween = create_tween().set_parallel(true)
		tw.tween_property(lingote_en_brasas, "position", Vector2(0.0, 2.0), 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(lingote_en_brasas, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_resaltar_barril_activo(metal_id)
	_update_forge_ui()

func _resaltar_barril_activo(metal_id: String) -> void:
	var mapa: Dictionary = {
		"hierro_dulce": barril_hierro_dulce,
		"acero_carbono": barril_acero_carbono,
		"bronce_cobre": barril_bronce_cobre
	}
	for k in mapa.keys():
		var nodo_b: Panel = mapa[k]
		if nodo_b:
			nodo_b.modulate = Color(1.22, 1.15, 0.92, 1.0) if k == metal_id else Color(0.88, 0.85, 0.82, 0.95)

func _process(delta: float) -> void:
	if not visible:
		return

	if current_station == StationTab.FORGE and not is_forge_settled:
		temperature = maxf(TEMP_AMBIENTE_FRAGUA, temperature - DECAIMIENTO_FRAGUA_POR_SEGUNDO * delta)
		_temperatura_visual = lerpf(_temperatura_visual, temperature, clampf(11.0 * delta, 0.0, 1.0))
		_update_forge_ui()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("cancel_escape"):
		close_station()
	elif current_station == StationTab.FORGE and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			_on_bellows_pressed()

func open_station() -> void:
	visible = true
	GameManager.change_state(GameManager.State.WORKSHOP_STATION)
	AudioManager.start_forge_ambience()
	reset_recipe()

func close_station() -> void:
	visible = false
	capa_ticket_final.visible = false
	AudioManager.stop_forge_ambience()
	GameManager.exit_workshop()
	emit_signal("workshop_closed")

func reset_recipe() -> void:
	capa_ticket_final.visible = false
	score_forge = 0.0
	score_anvil = 0.0
	score_cut = 0.0
	score_quench = 0.0
	score_polish = 0.0
	final_quality = 0.0
	reward_coins = 0

	# Reset Fragua: empieza con el horno vacío esperando que el jugador tome un lingote de uno de los 3 barriles
	temperature = TEMP_AMBIENTE_FRAGUA
	_temperatura_visual = TEMP_AMBIENTE_FRAGUA
	is_forge_settled = false
	_estaba_en_zona_optima = false
	_estaba_sobrecalentado = false
	_recalentando_en_fragua = false
	tiene_lingote_en_horno = false
	_arrastrando_lingote_barril = false
	if lingote_arrastrado:
		lingote_arrastrado.visible = false
	if lingote_en_brasas:
		lingote_en_brasas.visible = false
	if indicador_boca_horno:
		indicador_boca_horno.visible = true
	_resaltar_barril_activo("")

	btn_llevar_al_yunque.disabled = false
	etiqueta_estado_fragua.text = "1° Arrastra un lingote de los 3 barriles hacia el interior del horno. 2° Atiza el fuelle hasta 1000°C - 1150°C."
	etiqueta_estado_fragua.modulate = Color(0.95, 0.9, 0.8)
	_update_forge_ui()

	estacion_yunque.reset_station()
	estacion_corte.reset_station()
	estacion_tina.reset_station()
	estacion_pulido.reset_station()

	_switch_tab(StationTab.COUNTER)

func _switch_tab(tab: StationTab) -> void:
	current_station = tab
	vista_mostrador.visible = (tab == StationTab.COUNTER)
	estacion_fragua.visible = (tab == StationTab.FORGE)
	estacion_yunque.visible = (tab == StationTab.ANVIL)
	estacion_corte.visible = (tab == StationTab.CUTTING)
	estacion_tina.visible = (tab == StationTab.QUENCHING)
	estacion_pulido.visible = (tab == StationTab.POLISHING)

	var tabs: Array[Button] = [btn_tab_mostrador, btn_tab_fragua, btn_tab_yunque, btn_tab_corte, btn_tab_tina, btn_tab_pulido]
	for i in range(tabs.size()):
		tabs[i].modulate = Color(1.3, 1.2, 0.8) if i == tab else Color(1.0, 1.0, 1.0)

# --- FLUJO DE EVENTOS ENTRE ESTACIONES ---

func _on_order_accepted(order_info: Dictionary) -> void:
	var nombre_item: String = str(order_info.get("item_name", "Clavo Forjado de Compuerta"))
	if estacion_yunque and estacion_yunque.has_method("configurar_molde_encargo"):
		estacion_yunque.configurar_molde_encargo(nombre_item)
	_switch_tab(StationTab.FORGE)

func _on_bellows_pressed() -> void:
	if is_forge_settled:
		return
	# Si aún no había lingote en el horno (ej. ejecución rápida o test), introducir el lingote del encargo activo
	if not tiene_lingote_en_horno:
		var metal_pedido: String = "hierro_dulce"
		if vista_mostrador and not vista_mostrador.active_order.is_empty():
			metal_pedido = str(vista_mostrador.active_order.get("required_metal", "hierro_dulce"))
		colocar_lingote_en_horno(metal_pedido)
		temperature = TEMP_AMBIENTE_FRAGUA

	GameManager.consume_stamina(1.0)
	AudioManager.play_bellows()

	temperature = minf(TEMP_MANOMETRO_MAX, temperature + AUMENTO_POR_FUELLE)
	_temperatura_visual = lerpf(_temperatura_visual, temperature, 0.65)
	_update_forge_ui()

	if icono_fuelle:
		var tween: Tween = create_tween()
		tween.tween_property(icono_fuelle, "scale", Vector2(1.3, 0.65), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(icono_fuelle, "scale", Vector2(0.85, 1.25), 0.12)
		tween.tween_property(icono_fuelle, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	if resplandor_fuego:
		var fire_tween: Tween = create_tween()
		fire_tween.tween_property(resplandor_fuego, "modulate:a", 2.2, 0.08)
		fire_tween.tween_property(resplandor_fuego, "modulate:a", 1.0, 0.3)

func _update_forge_ui() -> void:
	var ahora_en_optima: bool = tiene_lingote_en_horno and temperature >= TEMP_OPTIMAL_MIN and temperature <= TEMP_OPTIMAL_MAX
	var ahora_sobrecalentado: bool = tiene_lingote_en_horno and temperature > TEMP_OPTIMAL_MAX

	if ahora_en_optima and not _estaba_en_zona_optima:
		AudioManager.play_sfx("temp_ready", 1.5, 0.03)
		if btn_llevar_al_yunque:
			btn_llevar_al_yunque.pivot_offset = btn_llevar_al_yunque.size * 0.5
			var tw_ready: Tween = create_tween()
			tw_ready.tween_property(btn_llevar_al_yunque, "scale", Vector2(1.14, 0.90), 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw_ready.tween_property(btn_llevar_al_yunque, "scale", Vector2(0.95, 1.08), 0.09)
			tw_ready.tween_property(btn_llevar_al_yunque, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		if _chispas_horno:
			_chispas_horno.amount = 38
			_chispas_horno.restart()
			_chispas_horno.emitting = true

	if ahora_sobrecalentado and not _estaba_sobrecalentado:
		AudioManager.play_sfx("temp_overheat", 1.0, 0.04)

	_estaba_en_zona_optima = ahora_en_optima
	_estaba_sobrecalentado = ahora_sobrecalentado

	if etiqueta_temperatura:
		etiqueta_temperatura.text = "%.0f°C (%s)" % [temperature, EscalaTermica.nombre_tramo(temperature)]
		etiqueta_temperatura.add_theme_color_override("font_color", EscalaTermica.color_texto(temperature))

	if pivote_aguja:
		var t_gauge: float = clampf(
			(_temperatura_visual - EscalaTermica.TEMP_MANOMETRO_MIN) / (TEMP_MANOMETRO_MAX - EscalaTermica.TEMP_MANOMETRO_MIN),
			0.0,
			1.0
		)
		pivote_aguja.rotation_degrees = lerpf(-120.0, 120.0, t_gauge)

	var color_frio_metal: Color = CATALOGO_METALES.get(metal_seleccionado_id, CATALOGO_METALES["hierro_dulce"])["color_frio"]
	var t_calor: float = clampf((temperature - 420.0) / 700.0, 0.0, 1.0)
	var ingot_color: Color = color_frio_metal.lerp(EscalaTermica.color_calor(temperature), t_calor)
	if lingote_fragua:
		lingote_fragua.color = ingot_color

	if lingote_en_brasas:
		lingote_en_brasas.color = ingot_color
		if lingote_en_brasas.material is ShaderMaterial:
			(lingote_en_brasas.material as ShaderMaterial).set_shader_parameter("temperatura", temperature)
	if cara_superior_lingote:
		cara_superior_lingote.color = ingot_color.lightened(0.18)
		cara_superior_lingote.color.a = 0.55

	# Intensificar las brasas y llamas que envuelven al lingote dentro del horno según la temperatura
	var factor_fuego: float = clampf((temperature - 20.0) / 1150.0, 0.0, 1.0)
	if lecho_brasas_fondo:
		lecho_brasas_fondo.color = Color(0.55, 0.14, 0.04, 0.85).lerp(Color(1.0, 0.48, 0.08, 0.98), factor_fuego)
	if ascuas_vivas_delanteras:
		ascuas_vivas_delanteras.color = Color(0.75, 0.22, 0.06, 0.78).lerp(Color(1.0, 0.75, 0.22, 0.95), factor_fuego)
	if llamas_internas_hogar:
		llamas_internas_hogar.color = Color(1.0, 0.45, 0.08, lerpf(0.18, 0.68, factor_fuego))
		llamas_internas_hogar.scale = Vector2(1.0, lerpf(0.65, 1.28, factor_fuego))

	if not etiqueta_estado_fragua:
		return
	var nombre_metal: String = CATALOGO_METALES.get(metal_seleccionado_id, CATALOGO_METALES["hierro_dulce"])["nombre"]
	if not tiene_lingote_en_horno:
		etiqueta_estado_fragua.text = "Elige uno de los 3 barriles de metal a la izquierda y arrastra un lingote dentro del horno."
		etiqueta_estado_fragua.modulate = Color(0.95, 0.86, 0.55)
	elif temperature >= TEMP_OPTIMAL_MIN and temperature <= TEMP_OPTIMAL_MAX:
		etiqueta_estado_fragua.text = "¡CALDEO ÓPTIMO DE %s (%.0f°C)! Lingote incandescente entre las brasas. ¡Llévalo al yunque!" % [
			nombre_metal.to_upper(),
			temperature
		]
		etiqueta_estado_fragua.modulate = Color(0.96, 0.78, 0.2)
	elif temperature > TEMP_QUEMADO:
		etiqueta_estado_fragua.text = "¡METAL QUEMADO (%.0f°C)! Chispas blancas: el carbono arde. Deja enfriar de inmediato." % temperature
		etiqueta_estado_fragua.modulate = Color(0.95, 0.42, 0.35)
	elif temperature > TEMP_OPTIMAL_MAX:
		etiqueta_estado_fragua.text = "¡SOBRECALENTADO (%.0f°C)! Blanco de soldadura; deja que baje a 1150°C." % temperature
		etiqueta_estado_fragua.modulate = Color(0.95, 0.55, 0.32)
	else:
		etiqueta_estado_fragua.text = "%s dentro del horno (%.0f°C - %s). Atiza el fuelle [ESPACIO] hasta 1000°C - 1150°C." % [
			nombre_metal,
			temperature,
			EscalaTermica.nombre_tramo(temperature)
		]
		etiqueta_estado_fragua.modulate = Color(0.85, 0.80, 0.72)

func _on_anvil_reheat_requested(temp_actual: float) -> void:
	_recalentando_en_fragua = true
	tiene_lingote_en_horno = true
	AudioManager.play_sfx("place_item", 0.0, 0.05)
	if lingote_en_brasas:
		lingote_en_brasas.visible = true
	if indicador_boca_horno:
		indicador_boca_horno.visible = false
	is_forge_settled = false
	temperature = clampf(temp_actual, TEMP_AMBIENTE_FRAGUA, TEMP_MANOMETRO_MAX)
	_temperatura_visual = temperature
	_estaba_en_zona_optima = (temperature >= TEMP_OPTIMAL_MIN and temperature <= TEMP_OPTIMAL_MAX)
	_estaba_sobrecalentado = (temperature > TEMP_OPTIMAL_MAX)
	_update_forge_ui()
	etiqueta_estado_fragua.text = "Recalentando pieza en las brasas (%.0f°C): atiza el fuelle hasta 1000°C - 1150°C." % temperature
	_switch_tab(StationTab.FORGE)

func _on_to_anvil_pressed() -> void:
	if not tiene_lingote_en_horno:
		colocar_lingote_en_horno(metal_seleccionado_id)
	is_forge_settled = true
	if temperature >= TEMP_OPTIMAL_MIN and temperature <= TEMP_OPTIMAL_MAX:
		score_forge = 1.0
	elif temperature < TEMP_OPTIMAL_MIN:
		score_forge = clampf(
			(temperature - TEMP_AMBIENTE_FRAGUA) / (TEMP_OPTIMAL_MIN - TEMP_AMBIENTE_FRAGUA),
			0.15,
			0.80
		)
	else:
		score_forge = clampf(1.0 - ((temperature - TEMP_OPTIMAL_MAX) / 220.0), 0.25, 0.75)

	AudioManager.play_sfx("step_complete", 0.5, 0.03)
	AudioManager.play_sfx("place_item", 0.0, 0.05)

	if _recalentando_en_fragua and estacion_yunque.has_method("recalentar_pieza"):
		_recalentando_en_fragua = false
		estacion_yunque.recalentar_pieza(temperature, lingote_fragua.color)
	else:
		estacion_yunque.reset_station(lingote_fragua.color, temperature)
	_switch_tab(StationTab.ANVIL)

func _on_anvil_completed(score: float, shape: PackedVector2Array) -> void:
	score_anvil = score
	AudioManager.play_sfx("step_complete", 0.5, 0.03)
	AudioManager.play_sfx("place_item", 0.0, 0.05)
	var temp_yunque: float = estacion_yunque.temperatura_pieza if "temperatura_pieza" in estacion_yunque else temperature
	estacion_corte.reset_station(lingote_fragua.color, shape, temp_yunque)
	_switch_tab(StationTab.CUTTING)

func _on_cutting_completed(score: float, shape: PackedVector2Array) -> void:
	score_cut = score
	_ultima_forma_cortada = shape
	AudioManager.play_sfx("step_complete", 0.5, 0.03)
	AudioManager.play_sfx("place_item", 0.0, 0.05)
	estacion_tina.reset_station(lingote_fragua.color, shape)
	_switch_tab(StationTab.QUENCHING)

func _on_quenching_completed(score: float, _final_color: Color) -> void:
	score_quench = score
	AudioManager.play_sfx("step_complete", 0.5, 0.03)
	AudioManager.play_sfx("place_item", 0.0, 0.05)
	estacion_pulido.reset_station(_ultima_forma_cortada)
	_switch_tab(StationTab.POLISHING)

func _on_polishing_completed(score: float) -> void:
	score_polish = score
	AudioManager.play_sfx("step_complete", 0.5, 0.03)
	_calculate_and_display_ticket()

func _calculate_and_display_ticket() -> void:
	final_quality = (score_forge * 0.20) + (score_anvil * 0.25) + (score_cut * 0.20) + (score_quench * 0.20) + (score_polish * 0.15)
	reward_coins = 10 + int(15.0 * final_quality)

	ticket_score_forge.text = "🔥 1. Temperatura Fragua: %.0f%%" % (score_forge * 100.0)
	ticket_score_anvil.text = "🔨 2. Moldeado Yunque Cenital: %.0f%%" % (score_anvil * 100.0)
	ticket_score_cut.text = "✂️ 3. Corte Manual de Rebabas: %.0f%%" % (score_cut * 100.0)
	ticket_score_quench.text = "🌊 4. Inmersión en Tina Fría: %.0f%%" % (score_quench * 100.0)
	ticket_score_polish.text = "✨ 5. Pulido & Desbaste: %.0f%%" % (score_polish * 100.0)

	ticket_score_total.text = "CALIDAD GENERAL: %.0f%%" % (final_quality * 100.0)

	if final_quality >= 0.90:
		ticket_rank_label.text = "⭐⭐⭐ ¡OBRA MAESTRA DEL ARTESANO! ⭐⭐⭐"
		ticket_rank_label.modulate = Color(0.96, 0.78, 0.2)
	elif final_quality >= 0.75:
		ticket_rank_label.text = "⭐⭐ HERRERO COMPETENTE ⭐⭐"
		ticket_rank_label.modulate = Color(0.85, 0.77, 0.65)
	elif final_quality >= 0.50:
		ticket_rank_label.text = "⭐ TRABAJO RÚSTICO DE APRENDIZ ⭐"
		ticket_rank_label.modulate = Color(0.7, 0.5, 0.4)
	else:
		ticket_rank_label.text = "PIEZA DEFECTUOSA / RECHAZO"
		ticket_rank_label.modulate = Color(0.85, 0.3, 0.3)

	ticket_reward_label.text = "💰 Paga Estimada: +%d Monedas de Oro" % reward_coins

	capa_ticket_final.visible = true
	capa_ticket_final.modulate.a = 0.0
	capa_ticket_final.scale = Vector2(0.94, 0.94)
	capa_ticket_final.pivot_offset = capa_ticket_final.size / 2.0

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(capa_ticket_final, "modulate:a", 1.0, 0.35)
	tween.tween_property(capa_ticket_final, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_deliver_to_counter_pressed() -> void:
	capa_ticket_final.visible = false
	var color_pulido: Color = CATALOGO_METALES.get(metal_seleccionado_id, CATALOGO_METALES["hierro_dulce"])["color_pulido"]
	vista_mostrador.set_piece_ready_for_delivery(final_quality, _ultima_forma_cortada, color_pulido)
	_switch_tab(StationTab.COUNTER)

func _on_customer_item_delivered(_quality: float, _reward: int) -> void:
	pass
