# capture_world_tour.gd
# Captura de pantalla de las diferentes zonas del mundo abierto, casas estructuradas, nuevos lugares y fauna
extends SceneTree

func _init() -> void:
	print("[TOUR] Iniciando tour visual completo del pueblo, arquitectura y fauna...")
	DirAccess.make_dir_absolute("res://screenshots")
	call_deferred("_run_tour")

func _run_tour() -> void:
	var root_node = root
	var town_scene: PackedScene = load("res://src/scenes/levels/GreyboxTown.tscn")
	var town = town_scene.instantiate()
	root_node.add_child(town)

	# 1. Quitar prólogo y telón
	if "prologue_letter" in town and is_instance_valid(town.prologue_letter):
		town.prologue_letter.visible = false
	if "telon_negro_inicial" in town and is_instance_valid(town.telon_negro_inicial):
		town.telon_negro_inicial.visible = false
	var gm = root_node.get_node_or_null("/root/GameManager")
	if gm:
		gm.change_state(gm.State.OVERWORLD)

	town.jugador.visible = true
	town.jugador.modulate.a = 1.0

	# Foto 1: Plaza Central con Gallina y Kiosco
	town.jugador.global_position = Vector2(640, 900)
	town._reset_camera()
	await process_frame
	await process_frame
	await create_timer(0.2).timeout
	_save_screen("screenshots/tour_01_plaza_central.png")

	# Foto 2: Calle Central con Casas Campesinas Estructuradas
	town.jugador.global_position = Vector2(640, 600)
	town._reset_camera()
	await process_frame
	await process_frame
	await create_timer(0.2).timeout
	_save_screen("screenshots/tour_02_calle_central.png")

	# Foto 3: La Herrería en la ladera SIN valla al frente (porche abierto con escalones y yunque)
	town.jugador.global_position = Vector2(1040, 335)
	Input.action_press("move_up")
	for f in range(4):
		await physics_frame
	Input.action_release("move_up")
	for f in range(2):
		await physics_frame
	town._reset_camera()
	await process_frame
	await process_frame
	_save_screen("screenshots/tour_03_herreria_ladera.png")

	# Foto 4: Granero Comunal y Senda Feudal
	town.jugador.global_position = Vector2(360, 480)
	town._reset_camera()
	await process_frame
	await process_frame
	await create_timer(0.2).timeout
	_save_screen("screenshots/tour_04_granero_comunal.png")

	# Foto 5: Corrales de Ganado con Buey y Ovejas animadas
	town.jugador.global_position = Vector2(360, 1030)
	town._reset_camera()
	await process_frame
	await process_frame
	await create_timer(0.2).timeout
	_save_screen("screenshots/tour_05_corral_fauna.png")

	# Foto 6: Taller del Cantero (bloques de piedra y mazas)
	town.jugador.global_position = Vector2(1030, 710)
	town._reset_camera()
	await process_frame
	await process_frame
	await create_timer(0.2).timeout
	_save_screen("screenshots/tour_06_cantero_taller.png")

	# Foto 7: Huerta Comunal con Espantapájaros y Perro en la Taberna
	town.jugador.global_position = Vector2(340, 750)
	town._reset_camera()
	await process_frame
	await process_frame
	await create_timer(0.2).timeout
	_save_screen("screenshots/tour_07_huerta_comunal.png")

	print("[TOUR] ¡Todas las capturas del nuevo tour guardadas con éxito!")
	quit(0)

func _save_screen(rel_path: String) -> void:
	var img: Image = root.get_viewport().get_texture().get_image()
	if img:
		var full_path = ProjectSettings.globalize_path("res://" + rel_path)
		img.save_png(full_path)
		print("[CAPTURA OK] " + full_path)
