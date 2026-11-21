# GreyboxTown.gd
# Logica de nivel greybox, orquestacion espacial y oclusion estanca (/disenador_de_niveles)
# Arquitectura topologica: Centro del Pueblo (Sur) <-> Pasillo Distribuidor <-> Taller (Oeste) / Mina (Norte) / Dormitorio (Este)
# Nomenclatura de nodos 100% en español conforme a docs/idea.txt §8.2
extends Node2D

enum Zone {
	EXTERIOR,
	PASILLO,
	DORMITORIO,
	MINA,
	CAVERNAS_MINA
}

var current_zone: Zone = Zone.EXTERIOR

# Nodos principales en Español
@onready var pueblo_exterior: Node2D = $PuebloExterior
@onready var interior_casa: Node2D = $InteriorCasa
@onready var jugador: CharacterBody2D = $Jugador
@onready var hud_principal: CanvasLayer = $HUDPrincipal
@onready var vista_estaciones_taller: CanvasLayer = $VistaEstacionesTaller
@onready var carta_prologo: CanvasLayer = $CartaPrologo
@onready var mina_subterranea: Node2D = $MinaSubterranea
@onready var guia_tutorial: CanvasLayer = $GuiaTutorial
@onready var pantalla_resumen_dia: CanvasLayer = $PantallaResumenDia
@onready var telon_negro_inicial: CanvasLayer = $TelonNegroInicial
@onready var carruaje_llegada: Node2D = $PuebloExterior/CarruajeLlegada
@onready var flechas_guia_taller: Node2D = $PuebloExterior/FlechasGuiaTaller

# Triggers de puertas y umbrales en Español
@onready var trigger_puerta_taller: Area2D = $InteriorCasa/Pasillo/TriggerPuertaTaller
@onready var trigger_salida_casa: Area2D = $InteriorCasa/Pasillo/TriggerPuertaSur
@onready var trigger_entrada_casa: Area2D = $PuebloExterior/FachadaCasaTio/PuertaCasa/TriggerEntradaCasa
@onready var area_puerta_casa: Area2D = $PuebloExterior/FachadaCasaTio/PuertaCasa/AreaInteractiva

# Detectores de zona para oclusión estanca en Español
@onready var detector_zona_exterior: Area2D = $DetectoresZona/DetectorZonaExterior
@onready var detector_zona_pasillo: Area2D = $DetectoresZona/DetectorZonaPasillo
@onready var detector_zona_dormitorio: Area2D = $DetectoresZona/DetectorZonaDormitorio
@onready var detector_zona_mina: Area2D = $DetectoresZona/DetectorZonaMina

# Máscaras oscurecedoras de oclusión (Nieblas) en Español
@onready var nieblas_oclusion: Node2D = $NieblasOclusion
@onready var niebla_exterior: ColorRect = $NieblasOclusion/NieblaExterior
@onready var niebla_pasillo: ColorRect = $NieblasOclusion/NieblaPasillo
@onready var niebla_dormitorio: ColorRect = $NieblasOclusion/NieblaDormitorio
@onready var niebla_mina: ColorRect = $NieblasOclusion/NieblaMina

# Interactables de habitaciones interiores en Español
@onready var area_cama: Area2D = $InteriorCasa/Dormitorio/Cama/AreaInteractiva
@onready var area_armario: Area2D = $InteriorCasa/Dormitorio/Armario/AreaInteractiva
@onready var area_mostrador: Area2D = $InteriorCasa/Pasillo/Mostrador/AreaInteractiva
@onready var area_mina: Area2D = $InteriorCasa/AccesoMina/EntradaMina/AreaInteractiva
@onready var area_herramientas_mina: Area2D = $InteriorCasa/AccesoMina/EstanteriaHerramientas/AreaInteractiva
@onready var barriles_acopio_mina: StaticBody2D = $InteriorCasa/AccesoMina/BarrilesAcopioMina
@onready var area_barriles_acopio_mina: Area2D = $InteriorCasa/AccesoMina/BarrilesAcopioMina/AreaInteractiva

# Interactables del exterior (Centro del pueblo y alrededores según boceto)
@onready var area_farol: Area2D = $PuebloExterior/FarolCentral/AreaInteractiva
@onready var area_cartel_guia: Area2D = $PuebloExterior/CartelGuia/AreaInteractiva
@onready var area_fuente_plaza: Area2D = $PuebloExterior/FuenteCentralPlaza/AreaInteractiva
@onready var area_kiosco_movil: Area2D = $PuebloExterior/KioscoMovil/AreaInteractiva
@onready var area_taberna: Area2D = $PuebloExterior/TabernaDelValle/AreaInteractiva
@onready var area_fermin_muebles: Area2D = $PuebloExterior/FerminMuebles/AreaInteractiva
@onready var area_corral_ganado: Area2D = $PuebloExterior/CorralesGanado/CorralOeste/AreaInteractiva
@onready var area_camino_gobierno: Area2D = $PuebloExterior/CaminoCasaGobierno/PortonFeudal/AreaInteractiva
@onready var area_cantero: Area2D = $PuebloExterior/TallerCantero/AreaInteractiva
@onready var area_granero: Area2D = $PuebloExterior/GraneroComunal/AreaInteractiva
@onready var area_huerta: Area2D = $PuebloExterior/HuertaComunal/AreaInteractiva
@onready var area_alfareria: Area2D = $PuebloExterior/AlfareriaValle/AreaInteractiva

# Alias de compatibilidad hacia atrás para QA y tests existentes
var exterior_town: Node2D:
	get: return pueblo_exterior
var house_interior: Node2D:
	get: return interior_casa
var player: CharacterBody2D:
	get: return jugador
var main_hud: CanvasLayer:
	get: return hud_principal
var hud: CanvasLayer:
	get: return hud_principal
var workshop_station_view: CanvasLayer:
	get: return vista_estaciones_taller
var workshop_view: CanvasLayer:
	get: return vista_estaciones_taller
var prologue_letter: CanvasLayer:
	get: return carta_prologo
var underground_mine: Node2D:
	get: return mina_subterranea
var tutorial_guide: CanvasLayer:
	get: return guia_tutorial
var telon_negro: CanvasLayer:
	get: return telon_negro_inicial
var workshop_door_trigger: Area2D:
	get: return trigger_puerta_taller
var house_exit_trigger: Area2D:
	get: return trigger_salida_casa
var house_entrance_trigger: Area2D:
	get: return trigger_entrada_casa
var house_door_interactable: Area2D:
	get: return area_puerta_casa
var zone_detector_exterior: Area2D:
	get: return detector_zona_exterior
var zone_detector_pasillo: Area2D:
	get: return detector_zona_pasillo
var zone_detector_dormitorio: Area2D:
	get: return detector_zona_dormitorio
var zone_detector_mina: Area2D:
	get: return detector_zona_mina
var shroud_exterior: ColorRect:
	get: return niebla_exterior
var shroud_pasillo: ColorRect:
	get: return niebla_pasillo
var shroud_dormitorio: ColorRect:
	get: return niebla_dormitorio
var shroud_mina: ColorRect:
	get: return niebla_mina
var bed_area: Area2D:
	get: return area_cama
var wardrobe_area: Area2D:
	get: return area_armario
var counter_area: Area2D:
	get: return area_mostrador
var mine_area: Area2D:
	get: return area_mina
var mine_tools_area: Area2D:
	get: return area_herramientas_mina
var lamp_area: Area2D:
	get: return area_farol
var signpost_area: Area2D:
	get: return area_cartel_guia

# Coordenadas exactas de spawn y teletransporte
const SPAWN_EXTERIOR_TOWN: Vector2 = Vector2(640, 900)
const SPAWN_HOUSE_HALLWAY: Vector2 = Vector2(640, 480)
const SPAWN_FRONT_OF_HOUSE: Vector2 = Vector2(1040, 360)
const SPAWN_WORKSHOP_THRESHOLD: Vector2 = Vector2(510, 410)
const SPAWN_MINE_ACCESS_RETURN: Vector2 = Vector2(640, 210)
const SPAWN_BEDROOM: Vector2 = Vector2(1010, 380)

var _is_transitioning: bool = false
var _active_tween: Tween = null

# Panel de Inventario del Barril de Menas en Bruto (Layer 22, nodos 100% en español, cero emojis)
var capa_inventario_barril_mina: CanvasLayer = null
var panel_inventario_barril: PanelContainer = null
var etiqueta_manos_actuales: Label = null
var etiquetas_cantidad_barril: Dictionary = {}
var botones_retiro_barril: Dictionary = {}

const CATALOGO_MENAS_BARRIL: Array[Dictionary] = [
	{
		"id": "hierro_dulce",
		"nombre": "Hierro Dulce",
		"color": Color(0.72, 0.76, 0.82, 1.0)
	},
	{
		"id": "acero_carbono",
		"nombre": "Acero al Carbono",
		"color": Color(0.36, 0.38, 0.42, 1.0)
	},
	{
		"id": "bronce_cobre",
		"nombre": "Bronce de Forja",
		"color": Color(0.84, 0.56, 0.28, 1.0)
	}
]

func _ready() -> void:
	if pueblo_exterior:
		pueblo_exterior.visible = true
	if interior_casa:
		interior_casa.visible = true
	jugador.z_index = 6
	jugador.global_position = SPAWN_EXTERIOR_TOWN
	_reset_camera()

	# Configurar oclusion inicial inmediata (solo exterior visible)
	set_active_zone(Zone.EXTERIOR, true)

	# Conectar prompt visual del jugador al HUD
	jugador.interact_focus_changed.connect(hud_principal.set_prompt)

	# Conectar transiciones de puertas y umbrales
	trigger_puerta_taller.body_entered.connect(_on_workshop_door_entered)
	trigger_salida_casa.body_entered.connect(_on_house_exit_entered)
	trigger_entrada_casa.body_entered.connect(_on_house_entrance_entered)
	area_puerta_casa.interacted.connect(_enter_house_from_exterior)

	# Conectar detectores de zona para oclusion estanca
	detector_zona_exterior.body_entered.connect(func(body: Node2D) -> void: if body == jugador: set_active_zone(Zone.EXTERIOR))
	detector_zona_pasillo.body_entered.connect(func(body: Node2D) -> void: if body == jugador: set_active_zone(Zone.PASILLO))
	detector_zona_dormitorio.body_entered.connect(func(body: Node2D) -> void: if body == jugador: set_active_zone(Zone.DORMITORIO))
	detector_zona_mina.body_entered.connect(func(body: Node2D) -> void: if body == jugador: set_active_zone(Zone.MINA))

	if OS.get_environment("GODOT_PLAYTEST") == "1":
		print("[GREYBOX] Activando PlaytestDriver por variable de entorno GODOT_PLAYTEST=1...")
		var driver_script: Script = load("res://tests/PlaytestDriver.gd") as Script
		if driver_script:
			var driver := CanvasLayer.new()
			driver.name = "ConductorPlaytest"
			driver.set_script(driver_script)
			add_child(driver)

	# Conectar cierre del taller para retomar control en el pasillo
	vista_estaciones_taller.workshop_closed.connect(_on_workshop_closed)
	_conectar_eventos_taller_a_tutorial()

	# Conectar señales de la mina subterránea
	if is_instance_valid(mina_subterranea):
		if mina_subterranea.has_signal("salida_mina_solicitada"):
			mina_subterranea.salida_mina_solicitada.connect(_on_mine_exit_requested)
		if mina_subterranea.has_signal("inspeccion_barril_mina_solicitada"):
			mina_subterranea.inspeccion_barril_mina_solicitada.connect(_on_barriles_acopio_mina_interacted)

	# Conectar estaciones y objetos interactivos
	area_cama.interacted.connect(_on_bed_interacted)
	area_armario.interacted.connect(_on_wardrobe_interacted)
	area_mostrador.interacted.connect(_on_counter_interacted)
	area_mina.interacted.connect(_on_mine_interacted)
	area_herramientas_mina.interacted.connect(_on_mine_tools_interacted)
	if is_instance_valid(area_barriles_acopio_mina):
		area_barriles_acopio_mina.interacted.connect(_on_barriles_acopio_mina_interacted)
	area_farol.interacted.connect(_on_lamp_interacted)
	area_cartel_guia.interacted.connect(_on_signpost_interacted)
	if is_instance_valid(area_fuente_plaza):
		area_fuente_plaza.interacted.connect(_on_fuente_plaza_interacted)
	if is_instance_valid(area_kiosco_movil):
		area_kiosco_movil.interacted.connect(_on_kiosco_movil_interacted)
	if is_instance_valid(area_taberna):
		area_taberna.interacted.connect(_on_taberna_interacted)
	if is_instance_valid(area_fermin_muebles):
		area_fermin_muebles.interacted.connect(_on_fermin_muebles_interacted)
	if is_instance_valid(area_corral_ganado):
		area_corral_ganado.interacted.connect(_on_corral_ganado_interacted)
	if is_instance_valid(area_camino_gobierno):
		area_camino_gobierno.interacted.connect(_on_camino_gobierno_interacted)
	if is_instance_valid(area_cantero):
		area_cantero.interacted.connect(func() -> void:
			GameManager.post_notification("Taller del Cantero: Bloques de arenisca y granito tallados con cinceles para las defensas del feudo.")
		)
	if is_instance_valid(area_granero):
		area_granero.interacted.connect(func() -> void:
			GameManager.post_notification("Granero Comunal: Graneros repletos de trigo, avena y paja seca para abastecer el valle.")
		)
	if is_instance_valid(area_huerta):
		area_huerta.interacted.connect(func() -> void:
			GameManager.post_notification("Huerta Comunal: Hortalizas frescas, coles y calabazas protegidas por el espantapájaros.")
		)
	if is_instance_valid(area_alfareria):
		area_alfareria.interacted.connect(func() -> void:
			GameManager.post_notification("Alfarería del Valle: Tinajas de barro cocido y tejas rojizas secándose al sol del desierto.")
		)

	_construir_capa_inventario_barril_mina()

	# Conectar eventos de medianoche y amanecer multidia
	if TimeManager.has_signal("player_passed_out"):
		TimeManager.player_passed_out.connect(_on_player_passed_out)
	if TimeManager.has_signal("day_started"):
		TimeManager.day_started.connect(_on_day_started)

	# Superposiciones y z-index estrictos
	if flechas_guia_taller:
		flechas_guia_taller.z_index = 4
	if carruaje_llegada:
		carruaje_llegada.z_index = 4
	jugador.z_index = 6

	# Gestión del Prólogo y Cinemática de Llegada en Carruaje
	if GameManager.current_state == GameManager.State.PROLOGUE:
		if is_instance_valid(telon_negro_inicial):
			telon_negro_inicial.visible = true
			var fondo: ColorRect = telon_negro_inicial.get_node_or_null("FondoNegro")
			if is_instance_valid(fondo):
				fondo.color = Color(0.02, 0.015, 0.01, 1.0)
				fondo.modulate.a = 1.0
		if is_instance_valid(jugador):
			jugador.visible = false
			jugador.set_physics_process(false)
		if is_instance_valid(carruaje_llegada):
			carruaje_llegada.position = Vector2(640, 1080)
			carruaje_llegada.visible = true
			carruaje_llegada.modulate.a = 1.0
		if is_instance_valid(carta_prologo):
			carta_prologo.letter_closed.connect(_on_prologue_letter_closed)
	else:
		if is_instance_valid(telon_negro_inicial):
			telon_negro_inicial.visible = false
		if is_instance_valid(carruaje_llegada):
			carruaje_llegada.visible = false
		if is_instance_valid(jugador):
			jugador.visible = true
			jugador.set_physics_process(true)
		GameManager.post_notification("Plaza Central: Sigue las flechas doradas al norte hacia la Herrería en la ladera.")
func _notificar_tutorial(evento_id: String) -> void:
	if is_instance_valid(guia_tutorial) and guia_tutorial.has_method("notificar_evento"):
		guia_tutorial.notificar_evento(evento_id)

func _conectar_eventos_taller_a_tutorial() -> void:
	if not is_instance_valid(vista_estaciones_taller):
		return
	if "vista_mostrador" in vista_estaciones_taller and is_instance_valid(vista_estaciones_taller.vista_mostrador):
		var mostrador: Node = vista_estaciones_taller.vista_mostrador
		if "boton_campana" in mostrador and is_instance_valid(mostrador.boton_campana):
			mostrador.boton_campana.pressed.connect(func() -> void: _notificar_tutorial("campana_tocada"))
		if mostrador.has_signal("order_accepted"):
			mostrador.order_accepted.connect(func(_info: Variant) -> void: _notificar_tutorial("comanda_aceptada"))
		if mostrador.has_signal("go_to_workbench_requested"):
			mostrador.go_to_workbench_requested.connect(func() -> void: _notificar_tutorial("estacion_fragua"))
		if mostrador.has_signal("item_delivered"):
			mostrador.item_delivered.connect(func(_cal: Variant, _rec: Variant) -> void: _notificar_tutorial("pedido_entregado"))
	if "btn_llevar_al_yunque" in vista_estaciones_taller and is_instance_valid(vista_estaciones_taller.btn_llevar_al_yunque):
		vista_estaciones_taller.btn_llevar_al_yunque.pressed.connect(func() -> void: _notificar_tutorial("estacion_yunque"))
	if "estacion_yunque" in vista_estaciones_taller and is_instance_valid(vista_estaciones_taller.estacion_yunque):
		if vista_estaciones_taller.estacion_yunque.has_signal("anvil_shaping_completed"):
			vista_estaciones_taller.estacion_yunque.anvil_shaping_completed.connect(func(_s: Variant, _p: Variant) -> void: _notificar_tutorial("estacion_corte"))
	if "estacion_corte" in vista_estaciones_taller and is_instance_valid(vista_estaciones_taller.estacion_corte):
		if vista_estaciones_taller.estacion_corte.has_signal("cutting_completed"):
			vista_estaciones_taller.estacion_corte.cutting_completed.connect(func(_s: Variant, _p: Variant) -> void: _notificar_tutorial("estacion_tina"))
	if "estacion_tina" in vista_estaciones_taller and is_instance_valid(vista_estaciones_taller.estacion_tina):
		if vista_estaciones_taller.estacion_tina.has_signal("quenching_completed"):
			vista_estaciones_taller.estacion_tina.quenching_completed.connect(func(_s: Variant, _c: Variant) -> void: _notificar_tutorial("estacion_pulido"))
	if "estacion_pulido" in vista_estaciones_taller and is_instance_valid(vista_estaciones_taller.estacion_pulido):
		if vista_estaciones_taller.estacion_pulido.has_signal("polishing_completed"):
			vista_estaciones_taller.estacion_pulido.polishing_completed.connect(func(_s: Variant) -> void: _notificar_tutorial("ticket_mostrado"))

func set_active_zone(new_zone: Zone, immediate: bool = false) -> void:
	current_zone = new_zone
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()

	var dur: float = 0.0 if immediate else 0.2
	_active_tween = create_tween().set_parallel(true)
	_active_tween.tween_property(niebla_exterior, "modulate:a", 0.0 if new_zone == Zone.EXTERIOR else 1.0, dur)
	_active_tween.tween_property(niebla_pasillo, "modulate:a", 0.0 if new_zone == Zone.PASILLO else 1.0, dur)
	_active_tween.tween_property(niebla_dormitorio, "modulate:a", 0.0 if new_zone == Zone.DORMITORIO else 1.0, dur)
	_active_tween.tween_property(niebla_mina, "modulate:a", 0.0 if new_zone == Zone.MINA else 1.0, dur)
	if is_instance_valid(nieblas_oclusion):
		nieblas_oclusion.visible = (new_zone != Zone.EXTERIOR)

	if is_instance_valid(detector_zona_pasillo):
		detector_zona_pasillo.monitoring = (new_zone != Zone.EXTERIOR)
	if is_instance_valid(detector_zona_dormitorio):
		detector_zona_dormitorio.monitoring = (new_zone != Zone.EXTERIOR)
	if is_instance_valid(detector_zona_mina):
		detector_zona_mina.monitoring = (new_zone != Zone.EXTERIOR)
	if is_instance_valid(detector_zona_exterior):
		detector_zona_exterior.monitoring = (new_zone == Zone.EXTERIOR)

	if new_zone == Zone.EXTERIOR:
		if is_instance_valid(pueblo_exterior):
			pueblo_exterior.visible = true
			pueblo_exterior.process_mode = Node.PROCESS_MODE_INHERIT
		if is_instance_valid(interior_casa):
			interior_casa.visible = false
			interior_casa.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		if is_instance_valid(pueblo_exterior):
			pueblo_exterior.visible = false
			pueblo_exterior.process_mode = Node.PROCESS_MODE_DISABLED
		if is_instance_valid(interior_casa):
			interior_casa.visible = true
			interior_casa.process_mode = Node.PROCESS_MODE_INHERIT

	# Delimitar la cámara al espacio activo para que jamás muestre el vacío negro exterior
	if jugador and jugador.has_method("set_camera_bounds"):
		match new_zone:
			Zone.EXTERIOR:
				if "zona_actual" in GameManager:
					GameManager.zona_actual = "exterior"
				jugador.set_camera_bounds(0, 0, 1400, 1500)
			Zone.PASILLO:
				if "zona_actual" in GameManager:
					GameManager.zona_actual = "interior"
				jugador.set_camera_bounds(440, 280, 830, 550)
				_notificar_tutorial("pasillo_entrado")
			Zone.DORMITORIO:
				if "zona_actual" in GameManager:
					GameManager.zona_actual = "interior"
				jugador.set_camera_bounds(790, 270, 1180, 550)
			Zone.MINA:
				if "zona_actual" in GameManager:
					GameManager.zona_actual = "mina"
				jugador.set_camera_bounds(440, 50, 830, 320)
			Zone.CAVERNAS_MINA:
				if "zona_actual" in GameManager:
					GameManager.zona_actual = "mina"
				jugador.set_camera_bounds(1780, 280, 2620, 920)
				_notificar_tutorial("mina_explorada")

func _on_player_passed_out() -> void:
	_teleport_player(SPAWN_BEDROOM)
	set_active_zone(Zone.DORMITORIO, true)

func _on_day_started(_nuevo_dia: int) -> void:
	if current_zone != Zone.DORMITORIO:
		_teleport_player(SPAWN_BEDROOM)
		set_active_zone(Zone.DORMITORIO, true)

func _reset_camera() -> void:
	if jugador.has_node("CamaraJugador"):
		jugador.get_node("CamaraJugador").reset_smoothing()
	elif jugador.has_node("Camera2D"):
		jugador.get_node("Camera2D").reset_smoothing()

# ==============================================================================
# TRANSICIONES ESPACIALES Y UMBRALES
# ==============================================================================

func _on_workshop_door_entered(body: Node2D) -> void:
	if body == jugador and not _is_transitioning:
		# Posicionar al jugador en el pasillo justo frente al umbral oeste
		jugador.global_position = SPAWN_WORKSHOP_THRESHOLD
		_reset_camera()
		set_active_zone(Zone.PASILLO, true)
		_notificar_tutorial("taller_abierto")
		# Transicion automatica inmediata a pantalla completa dedicada de estaciones
		vista_estaciones_taller.open_station()

func _on_workshop_closed() -> void:
	jugador.global_position = SPAWN_WORKSHOP_THRESHOLD
	_reset_camera()
	set_active_zone(Zone.PASILLO)
	GameManager.post_notification("De vuelta en el pasillo de la casa.")

func _on_house_exit_entered(body: Node2D) -> void:
	if body == jugador and not _is_transitioning:
		_teleport_player(SPAWN_FRONT_OF_HOUSE)
		set_active_zone(Zone.EXTERIOR)
		GameManager.post_notification("Sales a la calle del pueblo.")

func _on_house_entrance_entered(body: Node2D) -> void:
	if body == jugador and not _is_transitioning:
		_enter_house_from_exterior()

func _enter_house_from_exterior() -> void:
	_teleport_player(SPAWN_HOUSE_HALLWAY)
	set_active_zone(Zone.PASILLO)
	_notificar_tutorial("pasillo_entrado")
	GameManager.post_notification("Entras a la casa de tu tío. Oeste: Taller | Norte: Mina | Este: Dormitorio.")

func _teleport_player(target_pos: Vector2) -> void:
	_is_transitioning = true
	jugador.velocity = Vector2.ZERO
	jugador.global_position = target_pos
	_reset_camera()
	get_tree().create_timer(0.25).timeout.connect(func() -> void: _is_transitioning = false)

# ==============================================================================
# INTERACCIONES NARRATIVAS Y OBJETOS
# ==============================================================================

func _on_bed_interacted() -> void:
	if GameManager.has_method("registrar_sueno_completado"):
		GameManager.registrar_sueno_completado()
	TimeManager.sleep_voluntarily()

func _on_barriles_acopio_mina_interacted() -> void:
	abrir_inventario_barril_mina()

func _construir_capa_inventario_barril_mina() -> void:
	if is_instance_valid(capa_inventario_barril_mina):
		return

	capa_inventario_barril_mina = CanvasLayer.new()
	capa_inventario_barril_mina.name = "CapaInventarioBarrilMina"
	capa_inventario_barril_mina.layer = 22
	capa_inventario_barril_mina.visible = false
	add_child(capa_inventario_barril_mina)

	var fondo_oscuro: ColorRect = ColorRect.new()
	fondo_oscuro.name = "FondoOscuroBarril"
	fondo_oscuro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo_oscuro.color = Color(0.06, 0.05, 0.04, 0.82)
	capa_inventario_barril_mina.add_child(fondo_oscuro)

	var contenedor_centrado: CenterContainer = CenterContainer.new()
	contenedor_centrado.name = "ContenedorCentradoBarril"
	contenedor_centrado.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa_inventario_barril_mina.add_child(contenedor_centrado)

	panel_inventario_barril = PanelContainer.new()
	panel_inventario_barril.name = "PanelInventarioBarril"
	panel_inventario_barril.custom_minimum_size = Vector2(640.0, 410.0)
	var estilo_panel: StyleBoxFlat = StyleBoxFlat.new()
	estilo_panel.bg_color = Color(0.13, 0.10, 0.09, 0.98)
	estilo_panel.border_width_left = 3
	estilo_panel.border_width_top = 3
	estilo_panel.border_width_right = 3
	estilo_panel.border_width_bottom = 3
	estilo_panel.border_color = Color(0.71, 0.60, 0.42, 1.0)
	estilo_panel.corner_radius_top_left = 6
	estilo_panel.corner_radius_top_right = 6
	estilo_panel.corner_radius_bottom_right = 6
	estilo_panel.corner_radius_bottom_left = 6
	panel_inventario_barril.add_theme_stylebox_override("panel", estilo_panel)
	contenedor_centrado.add_child(panel_inventario_barril)

	var margen_interno: MarginContainer = MarginContainer.new()
	margen_interno.name = "MargenInternoBarril"
	margen_interno.add_theme_constant_override("margin_left", 24)
	margen_interno.add_theme_constant_override("margin_top", 20)
	margen_interno.add_theme_constant_override("margin_right", 24)
	margen_interno.add_theme_constant_override("margin_bottom", 20)
	panel_inventario_barril.add_child(margen_interno)

	var columna_principal: VBoxContainer = VBoxContainer.new()
	columna_principal.name = "ColumnaPrincipalBarril"
	columna_principal.add_theme_constant_override("separation", 14)
	margen_interno.add_child(columna_principal)

	var etiqueta_titulo: Label = Label.new()
	etiqueta_titulo.name = "EtiquetaTituloBarril"
	etiqueta_titulo.text = "BARRILES DE ACOPIO: MENAS EN BRUTO"
	etiqueta_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta_titulo.add_theme_font_size_override("font_size", 18)
	etiqueta_titulo.add_theme_color_override("font_color", Color(0.95, 0.90, 0.82, 1.0))
	columna_principal.add_child(etiqueta_titulo)

	var etiqueta_subtitulo: Label = Label.new()
	etiqueta_subtitulo.name = "EtiquetaSubtituloBarril"
	etiqueta_subtitulo.text = "Elige de 1 a 3 menas del mismo tipo para cargar en tus manos hacia la Fragua del taller."
	etiqueta_subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta_subtitulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	etiqueta_subtitulo.add_theme_font_size_override("font_size", 12)
	etiqueta_subtitulo.add_theme_color_override("font_color", Color(0.86, 0.78, 0.66, 1.0))
	columna_principal.add_child(etiqueta_subtitulo)

	etiqueta_manos_actuales = Label.new()
	etiqueta_manos_actuales.name = "EtiquetaManosActuales"
	etiqueta_manos_actuales.text = "En tus manos: Ninguna mena cargada"
	etiqueta_manos_actuales.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta_manos_actuales.add_theme_font_size_override("font_size", 13)
	etiqueta_manos_actuales.add_theme_color_override("font_color", Color(0.91, 0.56, 0.22, 1.0))
	columna_principal.add_child(etiqueta_manos_actuales)

	var separador_superior: HSeparator = HSeparator.new()
	separador_superior.name = "SeparadorSuperiorBarril"
	columna_principal.add_child(separador_superior)

	var lista_tipos: VBoxContainer = VBoxContainer.new()
	lista_tipos.name = "ListaTiposMenas"
	lista_tipos.add_theme_constant_override("separation", 12)
	columna_principal.add_child(lista_tipos)

	for info_mena: Dictionary in CATALOGO_MENAS_BARRIL:
		var tipo_id: String = String(info_mena["id"])
		var nombre_mena: String = String(info_mena["nombre"])
		var color_mena: Color = info_mena["color"] as Color

		var fila_mena: HBoxContainer = HBoxContainer.new()
		fila_mena.name = "FilaMena_" + tipo_id
		fila_mena.add_theme_constant_override("separation", 10)
		lista_tipos.add_child(fila_mena)

		var muestra_color: ColorRect = ColorRect.new()
		muestra_color.name = "MuestraColorMena"
		muestra_color.custom_minimum_size = Vector2(20.0, 28.0)
		muestra_color.color = color_mena
		fila_mena.add_child(muestra_color)

		var etiqueta_nombre: Label = Label.new()
		etiqueta_nombre.name = "EtiquetaNombreMena"
		etiqueta_nombre.custom_minimum_size = Vector2(150.0, 0.0)
		etiqueta_nombre.text = nombre_mena
		etiqueta_nombre.add_theme_font_size_override("font_size", 14)
		etiqueta_nombre.add_theme_color_override("font_color", Color(0.95, 0.90, 0.82, 1.0))
		fila_mena.add_child(etiqueta_nombre)

		var etiqueta_stock: Label = Label.new()
		etiqueta_stock.name = "EtiquetaStockMena"
		etiqueta_stock.custom_minimum_size = Vector2(120.0, 0.0)
		etiqueta_stock.text = "En barril: 0"
		etiqueta_stock.add_theme_font_size_override("font_size", 13)
		etiqueta_stock.add_theme_color_override("font_color", Color(0.88, 0.82, 0.70, 1.0))
		fila_mena.add_child(etiqueta_stock)
		etiquetas_cantidad_barril[tipo_id] = etiqueta_stock

		var botones_tipo: Array[Button] = []
		for cantidad_retiro: int in [1, 2, 3]:
			var boton_tomar: Button = Button.new()
			boton_tomar.name = "BotonTomar%d_%s" % [cantidad_retiro, tipo_id]
			boton_tomar.custom_minimum_size = Vector2(96.0, 34.0)
			boton_tomar.text = "Tomar %d" % cantidad_retiro if cantidad_retiro < 3 else "Tomar 3 (Máx)"
			boton_tomar.add_theme_font_size_override("font_size", 12)
			boton_tomar.pressed.connect(func() -> void: _retirar_menas_desde_panel(tipo_id, cantidad_retiro))
			fila_mena.add_child(boton_tomar)
			botones_tipo.append(boton_tomar)

		botones_retiro_barril[tipo_id] = botones_tipo

	var separador_inferior: HSeparator = HSeparator.new()
	separador_inferior.name = "SeparadorInferiorBarril"
	columna_principal.add_child(separador_inferior)

	var boton_cerrar: Button = Button.new()
	boton_cerrar.name = "BotonCerrarInventarioBarril"
	boton_cerrar.custom_minimum_size = Vector2(220.0, 38.0)
	boton_cerrar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	boton_cerrar.text = "Cerrar Barril"
	boton_cerrar.pressed.connect(cerrar_inventario_barril_mina)
	columna_principal.add_child(boton_cerrar)

func abrir_inventario_barril_mina() -> void:
	if not is_instance_valid(capa_inventario_barril_mina):
		_construir_capa_inventario_barril_mina()
	_actualizar_panel_inventario_barril_mina()
	capa_inventario_barril_mina.visible = true
	AudioManager.play_sfx("place_item", 0.0, 0.05)

func cerrar_inventario_barril_mina() -> void:
	if is_instance_valid(capa_inventario_barril_mina):
		capa_inventario_barril_mina.visible = false

func _obtener_stock_barril_mina(tipo_id: String) -> int:
	if "menas_barril_mina" in GameManager and GameManager.menas_barril_mina is Dictionary:
		return int(GameManager.menas_barril_mina.get(tipo_id, 0))
	match tipo_id:
		"acero_carbono":
			return int(GameManager.inventory.get("carbon", 0))
		"bronce_cobre":
			return int(GameManager.inventory.get("mineral_cobre", 0))
		"hierro_dulce", _:
			return int(GameManager.inventory.get("mineral_hierro", 0))

func _actualizar_panel_inventario_barril_mina() -> void:
	if is_instance_valid(etiqueta_manos_actuales):
		var cant_mano: int = int(GameManager.menas_en_mano_cantidad) if "menas_en_mano_cantidad" in GameManager else 0
		var tipo_mano: String = String(GameManager.menas_en_mano_tipo) if "menas_en_mano_tipo" in GameManager else ""
		if cant_mano > 0:
			var nombre_legible: String = "Hierro Dulce"
			for item: Dictionary in CATALOGO_MENAS_BARRIL:
				if String(item["id"]) == tipo_mano:
					nombre_legible = String(item["nombre"])
					break
			etiqueta_manos_actuales.text = "En tus manos: %d x %s (Máx. 3)" % [cant_mano, nombre_legible]
		else:
			etiqueta_manos_actuales.text = "En tus manos: Ninguna mena cargada (Máx. 3)"

	for info_mena: Dictionary in CATALOGO_MENAS_BARRIL:
		var tipo_id: String = String(info_mena["id"])
		var disponible: int = _obtener_stock_barril_mina(tipo_id)
		if etiquetas_cantidad_barril.has(tipo_id):
			var etq: Label = etiquetas_cantidad_barril[tipo_id] as Label
			if is_instance_valid(etq):
				etq.text = "En barril: %d" % disponible
		if botones_retiro_barril.has(tipo_id):
			var lista_btn: Array = botones_retiro_barril[tipo_id] as Array
			for idx: int in range(lista_btn.size()):
				var cant_req: int = idx + 1
				var btn: Button = lista_btn[idx] as Button
				if is_instance_valid(btn):
					btn.disabled = (disponible < cant_req)

func _retirar_menas_desde_panel(tipo: String, cantidad: int) -> void:
	var cantidad_acotada: int = clampi(cantidad, 1, 3)
	var retiradas: int = cantidad_acotada

	if GameManager.has_method("retirar_menas_barril_a_mano"):
		var resultado: Variant = GameManager.call("retirar_menas_barril_a_mano", tipo, cantidad_acotada)
		if typeof(resultado) == TYPE_INT and int(resultado) > 0:
			retiradas = int(resultado)
		elif "menas_en_mano_cantidad" in GameManager and int(GameManager.menas_en_mano_cantidad) > 0:
			retiradas = int(GameManager.menas_en_mano_cantidad)
	else:
		var disponible: int = _obtener_stock_barril_mina(tipo)
		retiradas = clampi(min(cantidad_acotada, disponible), 1, 3)
		if "menas_barril_mina" in GameManager and GameManager.menas_barril_mina is Dictionary:
			GameManager.menas_barril_mina[tipo] = maxi(0, int(GameManager.menas_barril_mina.get(tipo, 0)) - retiradas)
		if "menas_en_mano_tipo" in GameManager:
			GameManager.set("menas_en_mano_tipo", tipo)
		if "menas_en_mano_cantidad" in GameManager:
			GameManager.set("menas_en_mano_cantidad", retiradas)

	cerrar_inventario_barril_mina()
	AudioManager.play_sfx("place_item", 0.5, 0.05)
	GameManager.post_notification("Cargaste %d mena(s) en tus manos. Camina hacia la Fragua del taller para fundirlas." % retiradas)

func _on_wardrobe_interacted() -> void:
	GameManager.post_notification("Armario de roble carcomido: Ropas raídas de trabajo y delantales con olor a hollín de tu tío.")

func _on_counter_interacted() -> void:
	if TimeManager.hour >= 6 and TimeManager.hour < 17:
		GameManager.post_notification("Mostrador comercial: El portón está abierto esperando pedidos de los aldeanos.")
	else:
		GameManager.post_notification("Mostrador comercial: Portón cerrado por la noche. Los clientes volverán al amanecer.")

func _on_mine_interacted() -> void:
	var target_spawn: Vector2 = Vector2(2200, 800)
	if is_instance_valid(mina_subterranea) and "POSICION_APARICION_MINA" in mina_subterranea:
		target_spawn = mina_subterranea.POSICION_APARICION_MINA
	_teleport_player(target_spawn)
	set_active_zone(Zone.CAVERNAS_MINA)
	if jugador and jugador.has_method("set_camera_bounds"):
		jugador.set_camera_bounds(1780, 280, 2620, 920)
	AudioManager.play_place_item()
	_notificar_tutorial("mina_explorada")
	GameManager.post_notification("Desciendes a la Mina Subterránea: Enciende las antorchas y pica las vetas de mineral.")

func _on_mine_exit_requested() -> void:
	_teleport_player(SPAWN_MINE_ACCESS_RETURN)
	set_active_zone(Zone.MINA)
	AudioManager.play_place_item()
	GameManager.post_notification("Regresas al Acceso a la Mina en la parte trasera de la casa.")

func _on_mine_tools_interacted() -> void:
	GameManager.post_notification("Estantería minera: Picos gastados, cuerdas resecas y restos de carbón antiguo.")

func _on_lamp_interacted() -> void:
	GameManager.post_notification("Farol público oxidado: Apagado y sin combustible. Desde que tu tío desapareció, nadie cuida la luz del pueblo.")

func _on_signpost_interacted() -> void:
	GameManager.post_notification("Cartel de madera desgastado: Norte - Herrería y Taller de Rodrik (cubierto de hiedra y telarañas).")

func _on_fuente_plaza_interacted() -> void:
	GameManager.post_notification("Fuente del Pueblo: El agua fresca de manantial calma la sed del valle.")

func _on_kiosco_movil_interacted() -> void:
	GameManager.post_notification("Buhonero Ambulante: «¡Traigo especias, ungüentos y baratijas sobre ruedas! Vuelve cuando tengas más oro.»")

func _on_taberna_interacted() -> void:
	GameManager.post_notification("Taberna de Greta: Se escuchan risas campesinas y aroma a estofado de carnero e hidromiel.")

func _on_fermin_muebles_interacted() -> void:
	GameManager.post_notification("Fermín Muebles: «¡Si necesitas mangos de fresno o tablones secos para tu taller, aquí tienes lo mejor!»")

func _on_corral_ganado_interacted() -> void:
	GameManager.post_notification("Corral Comunal: Los bueyes y ovejas descansan rumiando paja seca al abrigo de la tarde.")

func _on_camino_gobierno_interacted() -> void:
	GameManager.post_notification("Guardia Feudal: «¡Alto, herrero! El paso a la Casa de Gobierno está cerrado a los campesinos.»")

func _on_prologue_letter_closed() -> void:
	var es_test: bool = (DisplayServer.get_name() == "headless" or OS.get_environment("GODOT_PLAYTEST") == "1")
	if es_test:
		if is_instance_valid(telon_negro_inicial):
			telon_negro_inicial.visible = false
		if is_instance_valid(carruaje_llegada):
			carruaje_llegada.position = Vector2(640, 915)
			carruaje_llegada.visible = false
		if is_instance_valid(jugador):
			jugador.visible = true
			jugador.global_position = SPAWN_EXTERIOR_TOWN
			jugador.set_physics_process(true)
		return

	_reproducir_cinematica_llegada()

func _reproducir_cinematica_llegada() -> void:
	if not is_instance_valid(carruaje_llegada) or not is_instance_valid(jugador):
		if is_instance_valid(telon_negro_inicial):
			telon_negro_inicial.visible = false
		if is_instance_valid(jugador):
			jugador.visible = true
			jugador.global_position = SPAWN_EXTERIOR_TOWN
			jugador.set_physics_process(true)
		return

	carruaje_llegada.position = Vector2(640, 1080)
	carruaje_llegada.visible = true
	carruaje_llegada.modulate.a = 1.0

	# 1. Desvanecer el telón negro inicial (0.8s) para desvelar el mapa
	if is_instance_valid(telon_negro_inicial):
		var fondo: ColorRect = telon_negro_inicial.get_node_or_null("FondoNegro")
		if is_instance_valid(fondo):
			var tw_telon := create_tween()
			tw_telon.tween_property(fondo, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE)
			tw_telon.finished.connect(func() -> void: telon_negro_inicial.visible = false)
		else:
			telon_negro_inicial.visible = false

	# 2. Rodar carruaje por el sendero sur hacia la plaza central (Vector2(640, 915))
	var tw_carruaje := create_tween()
	tw_carruaje.tween_property(carruaje_llegada, "position", Vector2(640, 915), 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Bamboleo artesanal de la caja del carruaje durante el trayecto
	var tw_bamboleo := create_tween()
	tw_bamboleo.set_loops(4)
	tw_bamboleo.tween_property(carruaje_llegada, "rotation_degrees", 1.8, 0.18).set_trans(Tween.TRANS_SINE)
	tw_bamboleo.tween_property(carruaje_llegada, "rotation_degrees", -1.8, 0.18).set_trans(Tween.TRANS_SINE)
	tw_bamboleo.finished.connect(func() -> void: carruaje_llegada.rotation_degrees = 0.0)

	AudioManager.play_sfx("place_item", 0.0, 0.08)

	await tw_carruaje.finished

	# 3. Frenada y resoplido del animal
	AudioManager.play_sfx("bellows_air", -6.0, 0.1)
	await get_tree().create_timer(0.3).timeout

	# 4. El jugador desciende del carruaje en la plaza central
	jugador.global_position = Vector2(620, 915)
	jugador.visible = true
	jugador.modulate.a = 0.0

	var tw_bajada := create_tween().set_parallel(true)
	tw_bajada.tween_property(jugador, "modulate:a", 1.0, 0.3)
	tw_bajada.tween_property(jugador, "global_position", SPAWN_EXTERIOR_TOWN, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	AudioManager.play_sfx("place_item", 0.4, 0.05)
	await tw_bajada.finished

	jugador.set_physics_process(true)

	# 5. Despedida del cochero y partida del carruaje
	GameManager.post_notification("Cochero: «Hemos llegado a Decroveil. ¡Buena suerte levantando la herrería de tu tío!»")

	await get_tree().create_timer(0.5).timeout

	var tw_partida := create_tween().set_parallel(true)
	tw_partida.tween_property(carruaje_llegada, "position:y", 1080.0, 1.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw_partida.tween_property(carruaje_llegada, "modulate:a", 0.0, 1.8)
	tw_partida.finished.connect(func() -> void:
		carruaje_llegada.visible = false
		GameManager.post_notification("Plaza Central: Sigue las flechas doradas al norte hacia la Herrería en la ladera.")
	)
