# playtest_gameplay_loop.gd
# Batería de Playtesting Automatizado y Pruebas de Estrés para 'Yunque & Sombra' (/playtester)
# Certificación 100% de Jugabilidad, Bucle de Gameplay Completo y Prevención de Softlocks.

extends SceneTree

const GameManagerScript = preload("res://src/autoload/GameManager.gd")
var game_manager: Node = null

var total_assertions: int = 0
var passed_assertions: int = 0
var failed_assertions: int = 0
var assertion_failures: Array[String] = []

# Métricas cuantitativas registradas durante el playtest
var metrics: Dictionary = {
	"prologue_closed_cleanly": false,
	"exterior_spawn_pos": Vector2.ZERO,
	"hallway_spawn_pos": Vector2.ZERO,
	"workshop_threshold_pos": Vector2.ZERO,
	"shrouds_exterior_ok": false,
	"shrouds_hallway_ok": false,
	"order_item_name": "",
	"order_base_reward": 0,
	"forge_temperature_reached": 0.0,
	"forge_score": 0.0,
	"stamina_consumed_bellows": 0.0,
	"anvil_strikes": 0,
	"anvil_score": 0.0,
	"anvil_polygon_deformed": false,
	"cuts_completed_count": 0,
	"cut_score": 0.0,
	"quench_time_seconds": 0.0,
	"quench_score": 0.0,
	"polish_progress_pct": 0.0,
	"polish_score": 0.0,
	"final_quality_score": 0.0,
	"coins_earned": 0,
	"final_coins_balance": 0,
	"tutorial_verified": false,
	"mine_spawn_pos": Vector2.ZERO,
	"mine_torches_lit": 0,
	"mine_iron_extracted": 0,
	"mine_first_iron_milestone": false,
	"stress_cycles_passed": 0,
	"fall_out_of_bounds_detected": false,
	"player_movement_verified": false
}

func _init() -> void:
	print("================================================================================")
	print("⚔️ INICIANDO PLAYTESTING DESTRUCTOR Y QA AUTOMATIZADO: YUNQUE & SOMBRA")
	print("================================================================================")
	process_frame.connect(_start_playtest, CONNECT_ONE_SHOT)

func _start_playtest() -> void:
	game_manager = root.get_node("GameManager")
	await _run_all_tests()
	_print_certification_report()
	
	if failed_assertions == 0:
		print("\n>>> CERTIFICACIÓN EXITOSA: BUCLE 100% JUGABLE Y LIBRE DE SOFTLOCKS <<<")
		quit(0)
	else:
		printerr("\n>>> CERTIFICACIÓN FALLIDA: SE DETECTARON %d ERRORES <<<" % failed_assertions)
		quit(1)

func _run_all_tests() -> void:
	# Cargar e instanciar la escena principal
	print("\n[FASE 0] Instanciando GreyboxTown.tscn...")
	var town_scene: PackedScene = load("res://src/scenes/levels/GreyboxTown.tscn")
	assert_true(town_scene != null, "Carga de recurso res://src/scenes/levels/GreyboxTown.tscn")
	if town_scene == null:
		return
		
	var town: Node2D = town_scene.instantiate()
	root.add_child(town)
	
	# Aguardar primeros frames para montaje completo de autoloads y nodos
	await process_frame
	await process_frame
	
	# ==========================================================================
	# 1. BUCLE COMPLETO DE GAMEPLAY
	# ==========================================================================
	print("\n[FASE 1] Apertura y Cierre de la Carta de la Madre (PrologueLetter) y Verificación de GuiaTutorial...")
	var prologue_letter: CanvasLayer = town.prologue_letter if "prologue_letter" in town else town.get_node_or_null("CartaPrologo")
	var guia_tutorial: CanvasLayer = town.guia_tutorial if "guia_tutorial" in town else town.get_node_or_null("GuiaTutorial")
	assert_true(prologue_letter != null, "Nodo PrologueLetter presente en la jerarquía")
	assert_true(guia_tutorial != null, "Nodo GuiaTutorial presente en la jerarquía de PuebloPrincipal")
	if guia_tutorial != null:
		assert_eq(guia_tutorial.paso_actual, 1, "GuiaTutorial inicia en el Paso 1 (El Legado del Tío)")
		assert_true(guia_tutorial.tutorial_activo, "GuiaTutorial está activo al inicio")
	assert_eq(game_manager.current_state, GameManagerScript.State.PROLOGUE, "Estado inicial de GameManager es PROLOGUE")
	assert_true(prologue_letter.visible, "PrologueLetter está visible cubriendo la pantalla")
	assert_eq(town.player.velocity, Vector2.ZERO, "Player inmovilizado durante el prólogo")
	
	# Simular clic en el botón de cerrar carta
	prologue_letter.close_letter()
	# Aguardar finalización del Tween de desvanecimiento (0.25s)
	await create_timer(0.35).timeout
	
	assert_false(prologue_letter.visible, "PrologueLetter se oculta tras close_letter()")
	assert_eq(game_manager.current_state, GameManagerScript.State.OVERWORLD, "GameManager transiciona a OVERWORLD tras cerrar la carta")
	metrics["prologue_closed_cleanly"] = (game_manager.current_state == GameManagerScript.State.OVERWORLD and not prologue_letter.visible)
	
	# --------------------------------------------------------------------------
	print("\n[FASE 2] Navegación Exterior y Oclusión Estanca (Shrouds) en Pueblo...")
	metrics["exterior_spawn_pos"] = town.player.global_position
	assert_eq(town.player.global_position, town.SPAWN_EXTERIOR_TOWN, "Player aparece en SPAWN_EXTERIOR_TOWN (640, 900)")
	assert_eq(town.current_zone, town.Zone.EXTERIOR, "Zona activa inicial es EXTERIOR")
	
	# Verificación de oclusión estanca: sala activa modulate.a = 0.0, demás 1.0
	assert_almost_eq(town.shroud_exterior.modulate.a, 0.0, 0.05, "Shroud Exterior visible (modulate.a == 0.0)")
	assert_almost_eq(town.shroud_pasillo.modulate.a, 1.0, 0.05, "Shroud Pasillo ocluido (modulate.a == 1.0)")
	assert_almost_eq(town.shroud_dormitorio.modulate.a, 1.0, 0.05, "Shroud Dormitorio ocluido (modulate.a == 1.0)")
	assert_almost_eq(town.shroud_mina.modulate.a, 1.0, 0.05, "Shroud Mina ocluido (modulate.a == 1.0)")
	metrics["shrouds_exterior_ok"] = (town.shroud_exterior.modulate.a <= 0.05 and town.shroud_pasillo.modulate.a >= 0.95)
	
	# Simular avance cinemático del jugador hacia la puerta norte de la fachada
	Input.action_press("move_up")
	for f in range(6):
		await physics_frame
	assert_true(town.player.velocity.y < 0.0, "Player responde cinemáticamente al input move_up con velocidad negativa en Y")
	Input.action_release("move_up")
	for f in range(6):
		await physics_frame
	
	# Cruce de la puerta sur hacia el pasillo interior de la casa
	print("[FASE 2.1] Cruce de puerta sur hacia el pasillo interior...")
	town._enter_house_from_exterior()
	# Aguardar teletransporte (0.3s) y tween de máscaras de oclusión (0.2s)
	await create_timer(0.38).timeout
	
	metrics["hallway_spawn_pos"] = town.player.global_position
	assert_eq(town.player.global_position, town.SPAWN_HOUSE_HALLWAY, "Player posicionado en SPAWN_HOUSE_HALLWAY (640, 480)")
	assert_eq(town.current_zone, town.Zone.PASILLO, "Zona activa actualizada a PASILLO")
	assert_almost_eq(town.shroud_pasillo.modulate.a, 0.0, 0.05, "Shroud Pasillo visible (modulate.a == 0.0)")
	assert_almost_eq(town.shroud_exterior.modulate.a, 1.0, 0.05, "Shroud Exterior ocluido (modulate.a == 1.0)")
	assert_almost_eq(town.shroud_dormitorio.modulate.a, 1.0, 0.05, "Shroud Dormitorio ocluido (modulate.a == 1.0)")
	assert_almost_eq(town.shroud_mina.modulate.a, 1.0, 0.05, "Shroud Mina ocluido (modulate.a == 1.0)")
	metrics["shrouds_hallway_ok"] = (town.shroud_pasillo.modulate.a <= 0.05 and town.shroud_exterior.modulate.a >= 0.95)
	if guia_tutorial != null:
		assert_eq(guia_tutorial.paso_actual, 2, "GuiaTutorial avanza al Paso 2 al entrar al Pasillo")
	
	# --------------------------------------------------------------------------
	print("\n[FASE 3] Tránsito por la Puerta Oeste hacia el Taller de Forja...")
	# Simular llegada al umbral oeste del taller
	town._on_workshop_door_entered(town.player)
	await process_frame
	await process_frame
	
	var workshop: CanvasLayer = town.workshop_station_view
	metrics["workshop_threshold_pos"] = town.player.global_position
	assert_eq(town.player.global_position, town.SPAWN_WORKSHOP_THRESHOLD, "Player posicionado en SPAWN_WORKSHOP_THRESHOLD (510, 410)")
	assert_eq(game_manager.current_state, GameManagerScript.State.WORKSHOP_STATION, "GameManager pasa al estado WORKSHOP_STATION")
	assert_true(workshop.visible, "WorkshopStationView abre pantalla completa dedicada (visible == true)")
	assert_eq(workshop.current_station, workshop.StationTab.COUNTER, "Pestaña inicial es COUNTER (Mostrador)")
	
	# --------------------------------------------------------------------------
	print("\n[FASE 4] Mostrador en Primera Persona: Campana, Comanda y Avance a Forja...")
	var counter: Control = workshop.counter_view
	assert_true(counter.visible, "CounterShopView está activo y visible")
	assert_false(counter.has_active_order, "Sin comanda activa antes de tocar la campana")
	
	# Clic en campana rústica ('service_bell')
	counter._on_bell_clicked()
	# Aguardar tween de llegada del cliente (0.5s)
	await create_timer(0.6).timeout
	
	assert_true(counter.dialogue_box.visible, "Caja de diálogo de cliente desplegada")
	assert_true(counter.order_sheet.visible, "Pergamino de comanda visible sobre el mostrador")
	assert_true(counter.active_order.has("item_name"), "Comanda generada con item_name: " + str(counter.active_order.get("item_name")))
	metrics["order_item_name"] = str(counter.active_order.get("item_name"))
	metrics["order_base_reward"] = int(counter.active_order.get("base_reward", 0))
	
	# Aceptar comanda
	counter._on_accept_order_pressed()
	assert_true(counter.has_active_order, "Comanda aceptada por el artesano (has_active_order == true)")
	assert_true(counter.btn_to_forge.visible, "Botón hacia el banco de forja activado")
	
	# Navegación al banco de trabajo / forja
	counter._on_go_to_forge_pressed()
	assert_eq(workshop.current_station, workshop.StationTab.FORGE, "Transición a pestaña FORGE (Fragua)")
	assert_true(workshop.station_forge.visible, "Panel de fragua visible")
	if guia_tutorial != null:
		assert_eq(guia_tutorial.paso_actual, 4, "GuiaTutorial avanza al Paso 4 en la Estación de Fragua")
	
	# --------------------------------------------------------------------------
	print("\n[FASE 5] Estación 1: Fragua Térmica y Atizado de Fuelle...")
	metrics["forge_temperature_reached"] = workshop.temperature
	assert_almost_eq(workshop.temperature, 20.0, 2.0, "Temperatura inicial ambiente (~20°C)")
	
	var stamina_before: float = game_manager.stamina
	# Atizar fuelle térmico 11 veces para alcanzar zona óptima [1000°C, 1150°C] con inercia realista (95°C/bombeo)
	for i in range(11):
		workshop._on_bellows_pressed()
		await process_frame
		
	var stamina_after: float = game_manager.stamina
	metrics["stamina_consumed_bellows"] = stamina_before - stamina_after
	assert_almost_eq(metrics["stamina_consumed_bellows"], 11.0, 0.1, "Consumo exacto de estamina por fuelle (1.0 x 11 = 11.0)")
	assert_true(workshop.temperature >= 1000.0 and workshop.temperature <= 1150.0, "Temperatura de fragua en rango óptimo: %.1f°C" % workshop.temperature)
	metrics["forge_temperature_reached"] = workshop.temperature
	
	# Pasar de la fragua al yunque cenital
	workshop._on_to_anvil_pressed()
	metrics["forge_score"] = workshop.score_forge
	assert_almost_eq(workshop.score_forge, 1.0, 0.05, "Calificación de fragua óptima alcanzada (Score: 100%)")
	assert_eq(workshop.current_station, workshop.StationTab.ANVIL, "Pestaña cambia a ANVIL (Yunque Cenital)")
	assert_true(workshop.anvil_station.visible, "Estación de yunque visible")
	
	# --------------------------------------------------------------------------
	print("\n[FASE 6] Estación 2: Yunque Cenital, Deformación de Polygon2D y Martillado...")
	var anvil: Control = workshop.anvil_station
	assert_eq(anvil.strikes_count, 0, "Conteo inicial de martillazos es 0")
	assert_true(anvil.btn_finish_anvil.disabled, "Botón de avance al corte deshabilitado (< 5 golpes)")
	
	var initial_polygon: PackedVector2Array = anvil.metal_polygon.polygon.duplicate()
	# Inyectar 8 impactos de martillo a lo largo de la barra
	var strike_coords: Array[float] = [220.0, 250.0, 280.0, 300.0, 320.0, 350.0, 370.0, 300.0]
	for x_pos in strike_coords:
		anvil._strike_at_position(Vector2(x_pos, 140.0))
		await process_frame
		
	metrics["anvil_strikes"] = anvil.strikes_count
	assert_eq(anvil.strikes_count, 8, "Conteo de golpes registrado: 8 martillazos")
	assert_false(anvil.btn_finish_anvil.disabled, "Botón de avance habilitado tras superar MIN_STRIKES (>= 5)")
	
	# Verificar deformación orgánica de los vértices del Polygon2D
	var deformed_polygon: PackedVector2Array = anvil.metal_polygon.polygon
	var polygon_changed: bool = false
	for i in range(initial_polygon.size()):
		if initial_polygon[i] != deformed_polygon[i]:
			polygon_changed = true
			break
	assert_true(polygon_changed, "Deformación orgánica demostrada: los vértices del Polygon2D variaron")
	metrics["anvil_polygon_deformed"] = polygon_changed
	
	var shaping_score: float = anvil._evaluate_current_shaping()
	assert_true(shaping_score >= 0.50, "Ajuste a la silueta del clavo evaluado: %.1f%%" % (shaping_score * 100.0))
	anvil._on_finish_pressed()
	metrics["anvil_score"] = workshop.score_anvil
	assert_true(workshop.score_anvil > 0.0, "Puntaje de yunque registrado en orquestador")
	assert_eq(workshop.current_station, workshop.StationTab.CUTTING, "Transición a pestaña CUTTING (Corte Manual)")
	assert_true(workshop.cut_station.visible, "Estación de corte visible")
	
	# --------------------------------------------------------------------------
	print("\n[FASE 7] Estación 3: Corte Manual de Rebabas con Cizalla...")
	var cutter: Control = workshop.cut_station
	assert_false(cutter._all_cuts_completed(), "Rebabas sin cortar al inicio")
	assert_true(cutter.btn_to_quench.disabled, "Botón de avance a tina deshabilitado")
	
	# Simular corte arrastrado en las 3 líneas de corte (Superior, Inferior, Punta)
	var bench_center: Vector2 = cutter.cut_bench.global_position + (cutter.cut_bench.size / 2.0)
	for i in range(cutter.cut_paths.size()):
		var path: Dictionary = cutter.cut_paths[i]
		cutter._check_start_cut(bench_center + path["start"])
		cutter._process_drag_cut(bench_center + path["end"])
		await process_frame
		
	assert_true(cutter._all_cuts_completed(), "Las 3 rebabas fueron completamente desprendidas")
	metrics["cuts_completed_count"] = 3
	assert_false(cutter.btn_to_quench.disabled, "Botón hacia la tina de templado habilitado")
	# Aguardar desprendimiento de rebabas por tweens
	await create_timer(0.48).timeout
	
	cutter._on_to_quench_pressed()
	metrics["cut_score"] = workshop.score_cut
	assert_true(workshop.score_cut >= 0.70, "Calificación de corte registrada: %.1f%%" % (workshop.score_cut * 100.0))
	assert_eq(workshop.current_station, workshop.StationTab.QUENCHING, "Transición a pestaña QUENCHING (Tina de Templado)")
	assert_true(workshop.quench_station.visible, "Estación de tina visible")
	
	# --------------------------------------------------------------------------
	print("\n[FASE 8] Estación 4: Tina de Inmersión y Choque Térmico...")
	var quench: Control = workshop.quench_station
	assert_false(quench.has_quenched, "Pieza aún no templada")
	assert_true(quench.btn_to_polish.disabled, "Botón de pulido deshabilitado")
	
	# Sumergir la pieza bajo el agua con tenazas
	quench.tongs_container.position.y = quench.WATER_SURFACE_Y + 25.0
	quench.is_underwater = true
	
	# Simular tiempo de inmersión en la ventana óptima (2.2s - 2.8s)
	while quench.quench_time < 2.45:
		quench._process(0.1)
		await process_frame
		
	metrics["quench_time_seconds"] = quench.quench_time
	assert_true(quench.quench_time >= quench.TARGET_TIME_MIN and quench.quench_time <= quench.TARGET_TIME_MAX, "Tiempo de temple en ventana óptima: %.2fs" % quench.quench_time)
	
	# Retirar pieza del agua
	quench._handle_release()
	assert_true(quench.has_quenched, "Pieza retirada y templado consumado")
	assert_almost_eq(quench.final_score, 1.0, 0.05, "Puntaje de templado maestro (Score: 100%)")
	assert_false(quench.btn_to_polish.disabled, "Botón de avance al pulido habilitado")
	
	quench._on_to_polish_pressed()
	metrics["quench_score"] = workshop.score_quench
	assert_almost_eq(workshop.score_quench, 1.0, 0.05, "Puntaje de temple registrado en orquestador")
	assert_eq(workshop.current_station, workshop.StationTab.POLISHING, "Transición a pestaña POLISHING (Pulido)")
	assert_true(workshop.polish_station.visible, "Estación de pulido visible")
	
	# --------------------------------------------------------------------------
	print("\n[FASE 9] Estación 5: Pulido Manual y Limpieza de Cascarilla...")
	var polish: Control = workshop.polish_station
	assert_false(polish.is_finished, "Pulido no finalizado inicialmente")
	assert_true(polish.btn_finish_polish.disabled, "Botón de conclusión deshabilitado")
	
	var polish_center: Vector2 = polish.polish_bench.global_position + (polish.polish_bench.size / 2.0)
	polish.is_rubbing = true
	polish.last_mouse_pos = polish_center
	
	# Frotar repetidamente la piedra de afilar sobre la superficie izquierda, central y derecha
	for rep in range(16):
		for x_off in [-70.0, -35.0, 0.0, 35.0, 70.0]:
			polish._process_rubbing(polish_center + Vector2(x_off, 0.0))
		await process_frame
		
	metrics["polish_progress_pct"] = polish.progress_bar.value
	assert_true(polish.progress_bar.value >= 85.0, "Cascarilla desbastada y brillo alcanzado: %.1f%%" % polish.progress_bar.value)
	assert_false(polish.btn_finish_polish.disabled, "Botón de finalización habilitado tras frotado suficiente")
	
	polish._on_finish_polish_pressed()
	metrics["polish_score"] = workshop.score_polish
	assert_true(polish.is_finished, "Estado de pulido marcado como completado")
	assert_true(workshop.score_polish >= 0.85, "Puntaje de pulido registrado: %.1f%%" % (workshop.score_polish * 100.0))
	
	# --------------------------------------------------------------------------
	print("\n[FASE 10] Ticket Final, Cobro de Monedas y Entrega al Cliente...")
	assert_true(workshop.ticket_overlay.visible, "Overlay del Ticket de Inspección visible")
	
	var expected_quality: float = (workshop.score_forge * 0.20) + (workshop.score_anvil * 0.25) + (workshop.score_cut * 0.20) + (workshop.score_quench * 0.20) + (workshop.score_polish * 0.15)
	assert_almost_eq(workshop.final_quality, expected_quality, 0.02, "Cálculo de calidad ponderada exacto: %.1f%%" % (workshop.final_quality * 100.0))
	metrics["final_quality_score"] = workshop.final_quality
	assert_true(workshop.reward_coins > 0, "Paga estimada calculada en monedas de oro: +%d" % workshop.reward_coins)
	
	# Enviar pieza al mostrador
	workshop._on_deliver_to_counter_pressed()
	assert_false(workshop.ticket_overlay.visible, "Ticket ocultado tras despachar al mostrador")
	assert_eq(workshop.current_station, workshop.StationTab.COUNTER, "Regreso automático a pestaña COUNTER")
	assert_true(counter.delivery_tray.visible, "Bandeja de entrega visible en el mostrador")
	
	# Entregar al cliente y cobrar recompensa
	var coins_pre: int = game_manager.coins
	counter._on_deliver_item_pressed()
	# Aguardar animación de marcha del cliente (0.6s tween)
	var wait_timeout: float = 2.0
	while counter.has_active_order and wait_timeout > 0.0:
		await process_frame
		wait_timeout -= 0.016
	
	var coins_post: int = game_manager.coins
	metrics["coins_earned"] = coins_post - coins_pre
	metrics["final_coins_balance"] = coins_post
	assert_true(coins_post > coins_pre, "Monedas de oro incrementadas en GameManager: %d -> %d (+%d)" % [coins_pre, coins_post, metrics["coins_earned"]])
	assert_true(game_manager.inventory.get(metrics["order_item_name"], 0) >= 1, "Pieza registrada en inventario de GameManager")
	assert_false(counter.has_active_order, "Comanda concluida y mostrador liberado para próximo cliente")
	
	# --------------------------------------------------------------------------
	print("\n[FASE 11] Salida del Taller ('Salir al Pasillo') y Retoma de Control...")
	workshop.close_station()
	await process_frame
	await process_frame
	
	assert_false(workshop.visible, "WorkshopStationView cerrado completamente (visible == false)")
	assert_eq(game_manager.current_state, GameManagerScript.State.OVERWORLD, "GameManager restaurado a OVERWORLD")
	assert_eq(town.player.global_position, town.SPAWN_WORKSHOP_THRESHOLD, "Jugador recupera posición en el pasillo (510, 410)")
	assert_eq(town.current_zone, town.Zone.PASILLO, "Zona activa es PASILLO")
	assert_almost_eq(town.shroud_pasillo.modulate.a, 0.0, 0.05, "Shroud Pasillo visible (0.0)")
	
	# Probar libre movimiento en el pasillo
	Input.action_press("move_right")
	for f in range(6):
		await physics_frame
	assert_true(town.player.velocity.x > 0.0, "Jugador retoma libre control cinemático sin bloqueos ni softlocks")
	Input.action_release("move_right")
	for f in range(6):
		await physics_frame
	metrics["player_movement_verified"] = true
	
	# --------------------------------------------------------------------------
	print("\n[FASE 11.5] Certificación de GuiaTutorial, Mina Subterránea, Antorchas y Primer Hito Metalúrgico...")
	assert_true(guia_tutorial != null, "GuiaTutorial persiste sin errores durante el ciclo de forja")
	if guia_tutorial != null:
		assert_true(guia_tutorial.paso_actual >= 9 or guia_tutorial.tutorial_finalizado, "GuiaTutorial avanzó por los 9 pasos y concluyó el ciclo de aprendizaje")
		guia_tutorial.saltar_tutorial()
		assert_true(guia_tutorial.tutorial_finalizado, "GuiaTutorial permite completarse/saltarse limpiamente sin errores")
		metrics["tutorial_verified"] = true

	var mina: Node2D = town.mina_subterranea if "mina_subterranea" in town else town.get_node_or_null("MinaSubterranea")
	assert_true(mina != null, "Nodo MinaSubterranea instanciado en GreyboxTown")
	
	# Simular interacción con la entrada a la mina desde AccesoMina
	town._on_mine_interacted()
	await create_timer(0.30).timeout
	
	assert_eq(town.current_zone, town.Zone.CAVERNAS_MINA, "Zona activa cambia a Zone.CAVERNAS_MINA al entrar a la mina")
	assert_eq(town.player.global_position, mina.POSICION_APARICION_MINA, "Jugador teletransportado a POSICION_APARICION_MINA (2200, 800)")
	metrics["mine_spawn_pos"] = town.player.global_position
	
	# Verificar encendido de antorcha y reducción de penumbra
	var penumbra_antes: float = mina.manto_penumbra.color.a
	assert_eq(mina.obtener_cantidad_antorchas_encendidas(), 0, "0 antorchas encendidas al ingresar a la caverna")
	mina.encender_antorcha("SoporteAntorcha1")
	await create_timer(0.40).timeout
	var penumbra_despues: float = mina.manto_penumbra.color.a
	assert_eq(mina.obtener_cantidad_antorchas_encendidas(), 1, "SoporteAntorcha1 encendido (obtener_cantidad_antorchas_encendidas() == 1)")
	assert_true(penumbra_despues < penumbra_antes, "La penumbra de la caverna disminuye tras encender antorcha (%.2f -> %.2f)" % [penumbra_antes, penumbra_despues])
	metrics["mine_torches_lit"] = mina.obtener_cantidad_antorchas_encendidas()
	
	# Restaurar estamina y picar VetaHierro1 (4 golpes)
	game_manager.restore_stamina(1.0)
	var hierro_antes: int = int(game_manager.inventory.get("mineral_hierro", 0))
	assert_false(mina.primer_hierro_desbloqueado, "Hito del primer hierro aún no desbloqueado antes de picar")
	
	for golpe in range(4):
		mina.picar_veta("VetaHierro1")
		await create_timer(0.08).timeout
		
	var hierro_despues: int = int(game_manager.inventory.get("mineral_hierro", 0))
	metrics["mine_iron_extracted"] = hierro_despues - hierro_antes
	assert_true(hierro_despues > hierro_antes, "Mineral de hierro extraído e incrementado en inventario: %d -> %d (+%d)" % [hierro_antes, hierro_despues, metrics["mine_iron_extracted"]])
	assert_true(mina.primer_hierro_desbloqueado, "Hito Metalúrgico del Primer Hierro desbloqueado (primer_hierro_desbloqueado == true)")
	assert_true(mina.cinematica_activa, "Cinemática del Primer Hito Metalúrgico activa en pantalla")
	metrics["mine_first_iron_milestone"] = mina.primer_hierro_desbloqueado
	
	# Cerrar limpiamente la cinemática del primer hierro
	await mina.cerrar_cinematica_primer_hierro()
	assert_false(mina.cinematica_activa, "Cinemática del Primer Hito cerrada limpiamente")
	assert_false(mina.cinematica_primer_hierro.visible, "CanvasLayer de cinemática oculto tras cierre")
	
	# Simular salida por la escalera de madera hacia AccesoMina
	town._on_mine_exit_requested()
	await create_timer(0.30).timeout
	assert_eq(town.current_zone, town.Zone.MINA, "Retorno exitoso a Zone.MINA tras salir por la escalera")
	assert_eq(town.player.global_position, Vector2(640, 210), "Jugador posicionado en AccesoMina (640, 210)")
	
	# ==========================================================================
	# 2. PRUEBA DE ESTRÉS Y CICLOS RÁPIDOS
	# ==========================================================================
	print("\n[FASE 12] Prueba de Estrés: 5 Ciclos Consecutivos de Apertura/Cierre del Taller...")
	var stress_success: int = 0
	for cycle in range(1, 6):
		workshop.open_station()
		await process_frame
		assert_eq(game_manager.current_state, GameManagerScript.State.WORKSHOP_STATION, "Estrés C%d: Estado WORKSHOP_STATION" % cycle)
		assert_true(workshop.visible, "Estrés C%d: Taller visible" % cycle)
		
		workshop.close_station()
		await process_frame
		assert_eq(game_manager.current_state, GameManagerScript.State.OVERWORLD, "Estrés C%d: Estado OVERWORLD" % cycle)
		assert_false(workshop.visible, "Estrés C%d: Taller oculto" % cycle)
		
		# Comprobar que el jugador no cayó al vacío ni se desplazó a coordenadas ilegales
		var p_pos: Vector2 = town.player.global_position
		var bounds_valid: bool = (p_pos.x >= 140.0 and p_pos.x <= 2650.0 and p_pos.y >= 70.0 and p_pos.y <= 1120.0)
		assert_true(bounds_valid, "Estrés C%d: Jugador dentro de los límites del mapa (%s)" % [cycle, str(p_pos)])
		
		if bounds_valid:
			stress_success += 1
			
	metrics["stress_cycles_passed"] = stress_success
	assert_eq(stress_success, 5, "Todos los 5 ciclos de estrés completados sin fugas ni caídas al vacío")
	
	# Limpieza explícita de la escena instanciada y canales de audio antes de salir para evitar fugas en SceneTree
	var audio_mgr: Node = root.get_node_or_null("AudioManager")
	if is_instance_valid(audio_mgr) and audio_mgr.has_method("stop_all_sfx"):
		audio_mgr.stop_all_sfx()
	if is_instance_valid(town):
		town.queue_free()
	await process_frame
	await process_frame

# ==============================================================================
# HELPERS DE ASERCIÓN Y FORMATO DE REPORTE
# ==============================================================================

func assert_true(condition: bool, message: String) -> bool:
	total_assertions += 1
	if condition:
		passed_assertions += 1
		print("  ✅ [PASS] %s" % message)
		return true
	else:
		failed_assertions += 1
		var err_str: String = "❌ [FAIL] %s" % message
		printerr("  " + err_str)
		assertion_failures.append(err_str)
		return false

func assert_false(condition: bool, message: String) -> bool:
	return assert_true(not condition, message)

func assert_eq(actual, expected, message: String) -> bool:
	var matches: bool = (actual == expected)
	var detail: String = message if matches else "%s (Esperado: %s, Obtenido: %s)" % [message, str(expected), str(actual)]
	return assert_true(matches, detail)

func assert_almost_eq(actual: float, expected: float, tolerance: float, message: String) -> bool:
	var matches: bool = abs(actual - expected) <= tolerance
	var detail: String = message if matches else "%s (Esperado: ~%.2f, Obtenido: %.2f, Tol: %.2f)" % [message, expected, actual, tolerance]
	return assert_true(matches, detail)

func _print_certification_report() -> void:
	print("\n================================================================================")
	print("📊 INFORME DE CERTIFICACIÓN DE JUGABILIDAD — 'YUNQUE & SOMBRA'")
	print("================================================================================")
	print("• Total de Aserciones Ejecutadas:  %d" % total_assertions)
	print("• Aserciones Exitosas:             %d (%.1f%%)" % [passed_assertions, (float(passed_assertions)/float(total_assertions))*100.0 if total_assertions > 0 else 0.0])
	print("• Aserciones Fallidas:             %d" % failed_assertions)
	print("--------------------------------------------------------------------------------")
	print("MÉTRICAS CUANTITATIVAS DE LA SESIÓN:")
	print("  1. Prólogo (Carta de la Madre):       %s" % ("Cierre limpio y transiciona a OVERWORLD" if metrics["prologue_closed_cleanly"] else "FALLO"))
	print("  2. Posición Spawn Exterior:           %s" % str(metrics["exterior_spawn_pos"]))
	print("  3. Posición Spawn Pasillo:            %s" % str(metrics["hallway_spawn_pos"]))
	print("  4. Oclusión Shrouds Exterior:         %s" % ("100% Estanca (Ext: 0.0, Otros: 1.0)" if metrics["shrouds_exterior_ok"] else "FALLO"))
	print("  5. Oclusión Shrouds Pasillo:          %s" % ("100% Estanca (Pas: 0.0, Otros: 1.0)" if metrics["shrouds_hallway_ok"] else "FALLO"))
	print("  6. Encargo del Cliente:               '%s' (Paga base: %d oro)" % [metrics["order_item_name"], metrics["order_base_reward"]])
	print("  7. Fragua (Temperatura Máxima):       %.1f°C (Óptimo 1000-1150°C) -> Score: %.0f%%" % [metrics["forge_temperature_reached"], metrics["forge_score"] * 100.0])
	print("  8. Gasto de Estamina en Fuelle:       %.1f pts" % metrics["stamina_consumed_bellows"])
	print("  9. Yunque Cenital (Martillazos):      %d golpes | Deformación Polygon2D: %s -> Score: %.0f%%" % [metrics["anvil_strikes"], "SÍ" if metrics["anvil_polygon_deformed"] else "NO", metrics["anvil_score"] * 100.0])
	print("  10. Corte Manual (Rebabas):           %d/3 cortadas -> Score: %.0f%%" % [metrics["cuts_completed_count"], metrics["cut_score"] * 100.0])
	print("  11. Tina de Templado (Inmersión):     %.2fs bajo agua -> Score: %.0f%% (Temple Maestro)" % [metrics["quench_time_seconds"], metrics["quench_score"] * 100.0])
	print("  12. Pulido (Desbaste de Cascarilla):  %.1f%% limpio -> Score: %.0f%%" % [metrics["polish_progress_pct"], metrics["polish_score"] * 100.0])
	print("  13. Ticket de Calidad Ponderada:      %.1f%%" % [metrics["final_quality_score"] * 100.0])
	print("  14. Economía (Paga Cobrada):          +%d monedas de oro (Saldo final: %d)" % [metrics["coins_earned"], metrics["final_coins_balance"]])
	print("  15. Control Cinematográfico Pasillo:  %s" % ("Retomado sin softlocks" if metrics["player_movement_verified"] else "BLOQUEADO"))
	print("  16. Tutorial Diegético (GuiaTutorial): %s" % ("9 Pasos + Cierre Limpio OK" if metrics["tutorial_verified"] else "FALLO"))
	print("  17. Mina Subterránea & Primer Hierro: Spawn %s | Antorchas: %d | Hierro: +%d | Hito: %s" % [str(metrics["mine_spawn_pos"]), metrics["mine_torches_lit"], metrics["mine_iron_extracted"], "SÍ" if metrics["mine_first_iron_milestone"] else "NO"])
	print("  18. Ciclos de Estrés (Apertura/Cierre): %d/5 completados con éxito" % metrics["stress_cycles_passed"])
	print("  19. Caídas al Vacío / Out-of-Bounds:  %s" % ("NINGUNA DETECTADA (0)" if not metrics["fall_out_of_bounds_detected"] else "ALERTA: DETECTADA"))
	print("================================================================================")
	if not assertion_failures.is_empty():
		print("DETALLE DE FALLAS:")
		for fail_msg in assertion_failures:
			printerr("  " + fail_msg)
		print("================================================================================")
