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

# Interactables del exterior (Centro del pueblo) en Español
@onready var area_farol: Area2D = $PuebloExterior/FarolCentral/AreaInteractiva
@onready var area_cartel_guia: Area2D = $PuebloExterior/CartelGuia/AreaInteractiva

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
const SPAWN_FRONT_OF_HOUSE: Vector2 = Vector2(640, 740)
const SPAWN_WORKSHOP_THRESHOLD: Vector2 = Vector2(510, 410)
const SPAWN_MINE_ACCESS_RETURN: Vector2 = Vector2(640, 210)

var _is_transitioning: bool = false
var _active_tween: Tween = null

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
	if is_instance_valid(mina_subterranea) and mina_subterranea.has_signal("salida_mina_solicitada"):
		mina_subterranea.salida_mina_solicitada.connect(_on_mine_exit_requested)

	# Conectar estaciones y objetos interactivos
	area_cama.interacted.connect(_on_bed_interacted)
	area_armario.interacted.connect(_on_wardrobe_interacted)
	area_mostrador.interacted.connect(_on_counter_interacted)
	area_mina.interacted.connect(_on_mine_interacted)
	area_herramientas_mina.interacted.connect(_on_mine_tools_interacted)
	area_farol.interacted.connect(_on_lamp_interacted)
	area_cartel_guia.interacted.connect(_on_signpost_interacted)

	# Mensaje de bienvenida inicial si ya no estamos en prologo
	if GameManager.current_state != GameManager.State.PROLOGUE:
		GameManager.post_notification("Centro del Pueblo: Sigue el camino hacia la casa de tu tío al norte.")

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

	# Delimitar la cámara al espacio activo para que jamás muestre el vacío negro exterior
	if jugador and jugador.has_method("set_camera_bounds"):
		match new_zone:
			Zone.EXTERIOR:
				jugador.set_camera_bounds(120, 590, 1160, 1150)
			Zone.PASILLO:
				jugador.set_camera_bounds(440, 280, 830, 550)
				_notificar_tutorial("pasillo_entrado")
			Zone.DORMITORIO:
				jugador.set_camera_bounds(790, 270, 1180, 550)
			Zone.MINA:
				jugador.set_camera_bounds(440, 50, 830, 320)
			Zone.CAVERNAS_MINA:
				jugador.set_camera_bounds(1780, 280, 2620, 920)
				_notificar_tutorial("mina_explorada")

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
	TimeManager.sleep_voluntarily()

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
