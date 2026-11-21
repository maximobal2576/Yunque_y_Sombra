# capture_game_views.gd
# Capturador visual de escenas para auditoría ocular (/ojos)
extends SceneTree

func _init() -> void:
	print("[CAPTURADOR] Iniciando captura visual de pantallas...")
	DirAccess.make_dir_absolute("res://screenshots")
	call_deferred("_run_capture_sequence")

func _run_capture_sequence() -> void:
	var root_node = root
	
	# Cargar escena principal GreyboxTown
	var town_scene: PackedScene = load("res://src/scenes/levels/GreyboxTown.tscn")
	var town_instance = town_scene.instantiate()
	root_node.add_child(town_instance)
	
	# Frame 1: Esperar 2 frames para renderizado
	await process_frame
	await process_frame
	_save_screen("screenshots/01_prologo_carta.png")
	
	# Cerrar carta y ver el pueblo
	var prologue = town_instance.prologue_letter if "prologue_letter" in town_instance else town_instance.get_node_or_null("CartaPrologo")
	if prologue and prologue.has_method("close_letter"):
		prologue.close_letter()
	elif prologue:
		prologue.visible = false
	
	if "telon_negro_inicial" in town_instance and is_instance_valid(town_instance.telon_negro_inicial):
		town_instance.telon_negro_inicial.visible = false
	
	var gm = root_node.get_node_or_null("/root/GameManager")
	if gm:
		gm.change_state(gm.State.OVERWORLD)
	
	if "jugador" in town_instance and is_instance_valid(town_instance.jugador):
		town_instance.jugador.visible = true
		town_instance.jugador.modulate.a = 1.0
		town_instance.jugador.global_position = town_instance.SPAWN_EXTERIOR_TOWN
	
	await create_timer(0.2).timeout
	await process_frame
	await process_frame
	_save_screen("screenshots/02_pueblo_exterior.png")
	
	# Abrir estación de trabajo (VistaEstacionesTaller)
	var workshop = town_instance.workshop_station_view if "workshop_station_view" in town_instance else town_instance.get_node_or_null("VistaEstacionesTaller")
	if workshop:
		workshop.open_station()
		await process_frame
		await process_frame
		_save_screen("screenshots/03_mostrador_vacio.png")
		
		# Activar cliente en el mostrador
		var counter = workshop.get_node_or_null("PanelPrincipal/AreaContenido/VistaMostrador")
		if counter:
			counter._summon_customer()
			await create_timer(0.6).timeout
			_save_screen("screenshots/04_mostrador_cliente_comanda.png")
		
		# Cambiar a Fragua (StationForge)
		workshop._switch_tab(workshop.StationTab.FORGE)
		workshop.temperature = 78.0
		workshop._update_forge_ui()
		await process_frame
		await process_frame
		_save_screen("screenshots/05_estacion_fragua.png")
		
		# Cambiar a Yunque (AnvilTopDownStation)
		workshop._switch_tab(workshop.StationTab.ANVIL)
		await process_frame
		await process_frame
		_save_screen("screenshots/06_estacion_yunque.png")
		
		# Cambiar a Corte (ManualCutStation)
		workshop._switch_tab(workshop.StationTab.CUTTING)
		await process_frame
		await process_frame
		_save_screen("screenshots/07_estacion_corte.png")
		
		# Cambiar a Templado (QuenchStation)
		workshop._switch_tab(workshop.StationTab.QUENCHING)
		await process_frame
		await process_frame
		_save_screen("screenshots/08_estacion_templado.png")
		
		# Cambiar a Pulido (PolishStation)
		workshop._switch_tab(workshop.StationTab.POLISHING)
		await process_frame
		await process_frame
		_save_screen("screenshots/09_estacion_pulido.png")

	print("[CAPTURADOR] ¡Todas las capturas guardadas en res://screenshots/ con éxito!")
	quit(0)

func _save_screen(rel_path: String) -> void:
	var img: Image = root.get_viewport().get_texture().get_image()
	if img:
		var full_path = ProjectSettings.globalize_path("res://" + rel_path)
		img.save_png(full_path)
		print("[CAPTURA OK] " + full_path)
