# tests/playtest_interactive_runner.gd
# Runner interactivo continuo de simulación de ojos y dedos (/playtester + /ojos + /herrero)
# Ejecuta el bucle completo paso a paso en pantalla, pulsando botones y registrando capturas constantes.

extends SceneTree

var town_scene: PackedScene = null
var town_instance: Node2D = null
var gm: Node = null
var workshop: CanvasLayer = null

func _init() -> void:
	print("================================================================================")
	print("👁️ INICIANDO PLAYTESTING INTERACTIVO CONTINUO: SIMULACIÓN DE OJOS Y BOTONES")
	print("================================================================================")
	process_frame.connect(_start_interactive_run, CONNECT_ONE_SHOT)

func _start_interactive_run() -> void:
	gm = root.get_node_or_null("GameManager")
	DirAccess.make_dir_absolute("res://screenshots")
	
	# Cargar e instanciar GreyboxTown
	town_scene = load("res://src/scenes/levels/GreyboxTown.tscn")
	if not town_scene:
		printerr("ERROR: No se pudo cargar GreyboxTown.tscn")
		quit(1)
		return
		
	town_instance = town_scene.instantiate()
	root.add_child(town_instance)
	
	await _wait_frames(3)
	
	# ==========================================================================
	# 👁️ CAPTURA 1: CARTA DEL PRÓLOGO INICIAL
	# ==========================================================================
	print("\n[OJO 1] Capturando carta del prólogo...")
	_save_capture("playtest_01_prologo_carta.png")
	await _wait_sec(0.3)
	
	# Simular clic en el botón de cerrar carta
	print("[DEDO 1] Pulsando botón para cerrar la carta del prólogo...")
	var prologue = town_instance.prologue_letter if "prologue_letter" in town_instance else town_instance.get_node_or_null("CartaPrologo")
	if prologue:
		if prologue.has_method("close_letter"):
			prologue.close_letter()
		else:
			prologue.visible = false
			if gm:
				gm.change_state(gm.State.OVERWORLD)
	await _wait_frames(3)
	
	# ==========================================================================
	# 👁️ CAPTURA 2: ALDEA EXTERIOR Y AVATAR
	# ==========================================================================
	print("[OJO 2] Capturando vista exterior de la aldea tras cerrar carta...")
	_save_capture("playtest_02_aldea_exterior.png")
	await _wait_sec(0.3)
	
	# Simular aproximación del personaje hacia el taller
	print("[DEDO 2] Moviendo al personaje hacia el umbral del taller...")
	var player = town_instance.player if "player" in town_instance else town_instance.get_node_or_null("Jugador")
	if player:
		player.global_position = Vector2(380.0, 360.0)
	await _wait_frames(3)
	
	# ==========================================================================
	# 👁️ CAPTURA 3: JUGADOR EN EL UMBRAL DEL TALLER
	# ==========================================================================
	print("[OJO 3] Capturando al personaje en el umbral del taller...")
	_save_capture("playtest_03_aproximacion_taller.png")
	await _wait_sec(0.3)
	
	# Abrir estación de trabajo
	print("[DEDO 3] Ingresando al taller e interactuando con la estación...")
	workshop = town_instance.workshop_station_view if "workshop_station_view" in town_instance else town_instance.get_node_or_null("VistaEstacionesTaller")
	if workshop:
		workshop.open_station()
	await _wait_frames(4)
	
	# ==========================================================================
	# 👁️ CAPTURA 4: MOSTRADOR VACÍO Y CAMPANA
	# ==========================================================================
	print("[OJO 4] Capturando mostrador vacío con campana...")
	_save_capture("playtest_04_mostrador_vacio.png")
	await _wait_sec(0.3)
	
	# Simular toque de campana
	print("[DEDO 4] Tocando la campana de atención en el mostrador...")
	var counter = workshop.get_node_or_null("PanelPrincipal/AreaContenido/VistaMostrador")
	if counter:
		var btn_bell = counter.get_node_or_null("MesaMostrador/ContenedorCampana/BotonCampana")
		if btn_bell:
			btn_bell.emit_signal("pressed")
		else:
			counter._summon_customer()
	await _wait_sec(1.0) # Esperar a que el cliente se acerque y el pergamino se desvanezca al 100% de opacidad
	await _wait_frames(3)
	
	# ==========================================================================
	# 👁️ CAPTURA 5: CLIENTE EN VENTANILLA Y PERGAMINO DE COMANDA
	# ==========================================================================
	print("[OJO 5] Capturando cliente con comanda desplegada...")
	_save_capture("playtest_05_comanda_visible_con_boton.png")
	await _wait_sec(0.3)
	
	# Simular clic en "Aceptar Comanda e Ir a Forja"
	print("[DEDO 5] Pulsando 'Aceptar Comanda e Ir a Forja'...")
	if counter:
		var btn_accept = counter.get_node_or_null("MesaMostrador/PergaminoComanda/ContenedorComanda/BotonAceptarComanda")
		if btn_accept:
			btn_accept.emit_signal("pressed")
		else:
			counter._on_accept_order_pressed()
	await _wait_frames(4)
	
	# ==========================================================================
	# 👁️ CAPTURA 6: ESTACIÓN DE FRAGUA INICIAL (DIAL Y AGUJA EN FRÍO)
	# ==========================================================================
	print("[OJO 6] Capturando Fragua en estado inicial (Verificación de aguja única)...")
	_save_capture("playtest_06_fragua_inicial_aguja_unica.png")
	await _wait_sec(0.3)
	
	# Simular atizado del fuelle (4 golpes de fuelle para alcanzar zona óptima)
	print("[DEDO 6] Atizando el fuelle con bombeos rítmicos...")
	var btn_bellows = workshop.get_node_or_null("PanelPrincipal/AreaContenido/EstacionFragua/BotonAtizarFuelle")
	for i in range(4):
		if btn_bellows:
			btn_bellows.emit_signal("pressed")
		else:
			workshop._on_bellows_pressed()
		await _wait_sec(0.15)
	
	await _wait_frames(3)
	
	# ==========================================================================
	# 👁️ CAPTURA 7: FRAGUA EN TEMPERATURA ÓPTIMA (ZONA DORADA)
	# ==========================================================================
	print("[OJO 7] Capturando Fragua al rojo vivo con temperatura óptima...")
	_save_capture("playtest_07_fragua_temperatura_optima.png")
	await _wait_sec(0.3)
	
	# Simular pulsación de "Llevar al Yunque Cenital"
	print("[DEDO 7] Pulsando botón 'Llevar al Yunque Cenital'...")
	var btn_to_anvil = workshop.get_node_or_null("PanelPrincipal/AreaContenido/EstacionFragua/BotonLlevarAlYunque")
	if btn_to_anvil:
		btn_to_anvil.emit_signal("pressed")
	else:
		workshop._on_to_anvil_pressed()
	await _wait_frames(4)
	
	# ==========================================================================
	# 👁️ CAPTURA 8: ESTACIÓN DE YUNQUE CENITAL
	# ==========================================================================
	print("[OJO 8] Capturando Estación de Yunque Cenital...")
	_save_capture("playtest_08_estacion_yunque_cenital.png")
	await _wait_sec(0.3)
	
	# Simular martillado en el yunque
	print("[DEDO 8] Aplicando golpes rítmicos de martillo en el yunque...")
	var anvil_station = workshop.get_node_or_null("PanelPrincipal/AreaContenido/EstacionYunqueCenital")
	if anvil_station:
		anvil_station._strike_at_local(Vector2(50.0, 0.0))
		await _wait_sec(0.1)
		anvil_station._strike_at_local(Vector2(-40.0, 0.0))
		await _wait_sec(0.1)
		anvil_station._strike_at_local(Vector2(0.0, 0.0))
	await _wait_frames(3)
	
	# ==========================================================================
	# 👁️ CAPTURA 9: YUNQUE CON METAL MOLDEADO
	# ==========================================================================
	print("[OJO 9] Capturando Yunque tras golpes de martillo...")
	_save_capture("playtest_09_yunque_moldeado.png")
	await _wait_sec(0.3)
	
	# Pasar a Estación de Corte
	print("[DEDO 9] Avanzando a la Estación de Corte Manual...")
	if anvil_station:
		anvil_station._on_finish_pressed()
	else:
		workshop._switch_tab(workshop.StationTab.CUTTING)
	await _wait_frames(4)
	
	# ==========================================================================
	# 👁️ CAPTURA 10: ESTACIÓN DE CORTE MANUAL
	# ==========================================================================
	print("[OJO 10] Capturando Estación de Corte Manual...")
	_save_capture("playtest_10_estacion_corte.png")
	await _wait_sec(0.3)
	
	# Simular corte y avanzar a Tina
	var cut_station = workshop.get_node_or_null("PanelPrincipal/AreaContenido/EstacionCorteManual")
	if cut_station:
		cut_station.simulate_cut_all()
		cut_station._on_finish_cutting_pressed()
	else:
		workshop._switch_tab(workshop.StationTab.QUENCHING)
	await _wait_frames(4)
	
	# ==========================================================================
	# 👁️ CAPTURA 11: ESTACIÓN DE TINA DE TEMPLADO
	# ==========================================================================
	print("[OJO 11] Capturando Tina de Templado...")
	_save_capture("playtest_11_estacion_tina_templado.png")
	await _wait_sec(0.3)
	
	# Simular inmersión y avanzar a Pulido
	var quench_station = workshop.get_node_or_null("PanelPrincipal/AreaContenido/EstacionTinaTemplado")
	if quench_station:
		quench_station._on_quench_pressed()
		await _wait_sec(0.3)
		quench_station._on_extract_pressed()
	else:
		workshop._switch_tab(workshop.StationTab.POLISHING)
	await _wait_frames(4)
	
	# ==========================================================================
	# 👁️ CAPTURA 12: ESTACIÓN DE PULIDO
	# ==========================================================================
	print("[OJO 12] Capturando Estación de Pulido...")
	_save_capture("playtest_12_estacion_pulido.png")
	await _wait_sec(0.3)
	
	# Simular pulido y finalizar pieza
	var polish_station = workshop.get_node_or_null("PanelPrincipal/AreaContenido/EstacionPulido")
	if polish_station:
		polish_station.simulate_polish()
		polish_station._on_finish_polish_pressed()
	await _wait_frames(4)
	
	# ==========================================================================
	# 👁️ CAPTURA 13: TICKET DE INSPECCIÓN ARTESANAL FINAL
	# ==========================================================================
	print("[OJO 13] Capturando Ticket de Inspección Artesanal...")
	_save_capture("playtest_13_ticket_final.png")
	await _wait_sec(0.4)
	
	print("\n================================================================================")
	print("✅ SESIÓN DE PLAYTESTING Y CAPTURAS OCULARES COMPLETADA EXITOSAMENTE (13 CAPTURAS)")
	print("================================================================================")
	quit(0)

func _save_capture(rel_filename: String) -> void:
	var viewport = root.get_viewport()
	if not viewport:
		return
	var img: Image = viewport.get_texture().get_image()
	if img:
		var target_path = ProjectSettings.globalize_path("res://screenshots/" + rel_filename)
		img.save_png(target_path)
		print("  📸 [CAPTURA REGISTRADA] %s" % target_path)

func _wait_frames(n: int) -> void:
	for i in range(n):
		await process_frame

func _wait_sec(sec: float) -> void:
	await create_timer(sec).timeout
