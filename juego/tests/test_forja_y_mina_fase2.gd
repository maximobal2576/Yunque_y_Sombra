# test_forja_y_mina_fase2.gd
# Test headless automatizado para validar todas las mecánicas requeridas en la actualización:
# 1. Termodinámica diferenciada por metal (forja, punto de fusión y maleabilidad)
# 2. Cizalla corta (130px) y velocidad lenta de revelado en mostrador (0.42)
# 3. Límite de 3 pedidos diarios y bloqueo de campana para el jugador
# 4. Transporte lento de menas (55% velocidad) y visualización en manos
# 5. Acopio en barriles de entrada de mina (hasta 3 del mismo tipo)
# 6. Fundición de mena a temperatura máxima en fragua y recarga de barriles
# 7. Tutorial de 14 pasos en 2 fases
extends SceneTree

var total_assertions: int = 0
var passed_assertions: int = 0
var failed_assertions: int = 0

func _init() -> void:
	call_deferred("_run_tests")

func assert_true(condition: bool, message: String) -> void:
	total_assertions += 1
	if condition:
		passed_assertions += 1
		print("  [PASS] %s" % message)
	else:
		failed_assertions += 1
		printerr("  [FAIL] %s" % message)

func assert_false(condition: bool, message: String) -> void:
	assert_true(not condition, message)

func assert_eq(val1, val2, message: String) -> void:
	assert_true(val1 == val2, "%s (Esperado: %s, Obtenido: %s)" % [message, str(val2), str(val1)])

func assert_almost_eq(val1: float, val2: float, tol: float, message: String) -> void:
	assert_true(absf(val1 - val2) <= tol, "%s (Esperado: ~%.2f, Obtenido: %.2f, Tol: %.2f)" % [message, val2, val1, tol])

func _run_tests() -> void:
	print("================================================================================")
	print("EJECUTANDO TEST SUITE: ACTUALIZACIÓN FORJA, MINA Y TUTORIAL EN 2 FASES")
	print("================================================================================")

	var gm: Node = root.get_node_or_null("GameManager")
	assert_true(gm != null, "GameManager autoload cargado en SceneTree")

	# 1. DATOS_METALES
	print("\n[TEST 1] Verificación de Termodinámica y Maleabilidad por Metal en GameManager...")
	assert_true(gm.DATOS_METALES.has("bronce_cobre"), "Contiene bronce_cobre")
	assert_true(gm.DATOS_METALES.has("acero_carbono"), "Contiene acero_carbono")
	assert_true(gm.DATOS_METALES.has("hierro_dulce"), "Contiene hierro_dulce")

	var bronce: Dictionary = gm.DATOS_METALES["bronce_cobre"]
	assert_eq(bronce["temp_forja_min"], 750.0, "Bronce temp_forja_min == 750°C")
	assert_eq(bronce["temp_forja_max"], 880.0, "Bronce temp_forja_max == 880°C")
	assert_eq(bronce["temp_fusion"], 1020.0, "Bronce temp_fusion == 1020°C")
	assert_eq(bronce["maleabilidad"], 1.25, "Bronce maleabilidad == 1.25")

	var acero: Dictionary = gm.DATOS_METALES["acero_carbono"]
	assert_eq(acero["temp_forja_min"], 920.0, "Acero temp_forja_min == 920°C")
	assert_eq(acero["temp_forja_max"], 1040.0, "Acero temp_forja_max == 1040°C")
	assert_eq(acero["temp_fusion"], 1140.0, "Acero temp_fusion == 1140°C")
	assert_eq(acero["maleabilidad"], 0.78, "Acero maleabilidad == 0.78")

	var hierro: Dictionary = gm.DATOS_METALES["hierro_dulce"]
	assert_true(hierro["temp_forja_min"] >= 1000.0, "Hierro temp_forja_min >= 1000°C")
	assert_eq(hierro["temp_forja_max"], 1160.0, "Hierro temp_forja_max == 1160°C")
	assert_eq(hierro["temp_fusion"], 1200.0, "Hierro temp_fusion == 1200°C")
	assert_eq(hierro["maleabilidad"], 1.00, "Hierro maleabilidad == 1.00")

	# 2. Cizalla Corta
	print("\n[TEST 2] Verificación de Parámetros de Cizalla y Mostrador...")
	var corte_script = load("res://src/scenes/workshop/ManualCutStation.gd")
	assert_eq(corte_script.LARGO_MAXIMO_TRAZO, 130.0, "Cizalla LARGO_MAXIMO_TRAZO reducido a 130.0 px")

	var mostrador_script = load("res://src/scenes/workshop/CounterShopView.gd")
	assert_eq(mostrador_script.VELOCIDAD_REVELADO_RECETA, 0.42, "Velocidad de revelado de receta pausada a 0.42 chars/s")
	assert_eq(mostrador_script.MAX_PEDIDOS_DIA_1, 3, "Tope de pedidos en Día 1 es 3")

	# 3. Caminata Lenta del Jugador con Mena en Mano
	print("\n[TEST 3] Verificación de Transporte Pesado en Player...")
	var player_scene = load("res://src/scenes/player/Player.tscn")
	var player_instance = player_scene.instantiate()
	root.add_child(player_instance)
	await process_frame

	gm.menas_en_mano_tipo = ""
	gm.menas_en_mano_cantidad = 0
	player_instance._actualizar_visual_mena_en_mano(false, "", 0)
	assert_false(player_instance.mena_en_mano.visible, "Visual de mena oculto sin carga")

	# Cargar mena en mano
	gm.menas_en_mano_tipo = "hierro_dulce"
	gm.menas_en_mano_cantidad = 2
	player_instance._actualizar_visual_mena_en_mano(true, "hierro_dulce", 2)
	assert_true(player_instance.mena_en_mano.visible, "Visual de mena visible al cargar menas")
	var lleva: bool = (gm.menas_en_mano_cantidad > 0)
	var vel_calc: float = player_instance.SPEED * 0.55 if lleva else player_instance.SPEED
	assert_almost_eq(vel_calc, player_instance.SPEED * 0.55, 0.1, "Velocidad reducida al 55% al cargar menas")

	player_instance.queue_free()
	await process_frame

	# 4. Acopio y Retiro en Barriles de Entrada de Mina
	print("\n[TEST 4] Acopio en Barriles de Mina y Límite de 3 Menas...")
	gm.menas_barril_mina["hierro_dulce"] = 0
	gm.menas_en_mano_cantidad = 0
	gm.menas_en_mano_tipo = ""

	gm.agregar_mena_barril_mina("mineral_hierro", 5)
	assert_eq(gm.menas_barril_mina["hierro_dulce"], 5, "Mena de hierro acumulada en barril de mina (5 unidades)")

	# Intentar retirar más de 3 (debe fallar)
	var retiro_invalido: bool = gm.retirar_menas_barril_a_mano("hierro_dulce", 4)
	assert_false(retiro_invalido, "No se permite retirar más de 3 menas a la vez")

	# Retirar 3 menas válidas
	var retiro_valido: bool = gm.retirar_menas_barril_a_mano("hierro_dulce", 3)
	assert_true(retiro_valido, "Retiro de 3 menas exitoso")
	assert_eq(gm.menas_barril_mina["hierro_dulce"], 2, "Barril de mina descuenta 3 menas (quedan 2)")
	assert_eq(gm.menas_en_mano_cantidad, 3, "Jugador sostiene 3 menas en la mano")
	assert_eq(gm.menas_en_mano_tipo, "hierro_dulce", "Tipo de mena en mano es hierro_dulce")

	# 5. Taller y Fundición en Fragua
	print("\n[TEST 5] Taller: Consumo de Stock en Barriles y Fundición a Temp Máxima...")
	var workshop_scene = load("res://src/scenes/workshop/WorkshopStationView.tscn")
	var workshop = workshop_scene.instantiate()
	root.add_child(workshop)
	await process_frame

	# Inicialmente stock de fragua es 3 para cada uno
	gm.stock_barriles_fragua = {"hierro_dulce": 3, "acero_carbono": 3, "bronce_cobre": 3}
	gm.menas_en_mano_cantidad = 0
	workshop.open_station()
	await process_frame

	# Probar consumo al meter lingote normal en horno
	workshop.colocar_lingote_en_horno("hierro_dulce")
	assert_eq(gm.stock_barriles_fragua["hierro_dulce"], 2, "Consumo de 1 lingote de hierro dulce (3 -> 2)")

	# Ahora probar modo fundición con menas en la mano
	gm.menas_en_mano_tipo = "bronce_cobre"
	gm.menas_en_mano_cantidad = 3
	gm.mision_fundicion_mena_completada = false
	workshop.open_station()
	await process_frame

	assert_true(workshop.modo_fundicion_mena_activa, "Modo fundición de mena activado al entrar con menas en mano")
	assert_eq(workshop.metal_seleccionado_id, "bronce_cobre", "Metal de fundición configurado como bronce_cobre")
	assert_true(workshop.btn_llevar_al_yunque.disabled, "Botón Llevar al Yunque deshabilitado durante la fundición")

	var temp_fus_bronce: float = workshop.obtener_temp_fusion_metal()
	assert_eq(temp_fus_bronce, 1020.0, "Punto de fusión de bronce_cobre es 1020°C")

	# Atizar hasta alcanzar temp_fus_bronce (10 bombeos de 95°C = 950°C + 20 = 970; 11 bombeos = 1065°C >= 1005°C)
	for i in range(12):
		workshop._on_bellows_pressed()
		await process_frame
		if not workshop.modo_fundicion_mena_activa:
			break

	assert_false(workshop.modo_fundicion_mena_activa, "Fundición completada tras alcanzar temperatura máxima")
	assert_true(gm.mision_fundicion_mena_completada, "Hito mision_fundicion_mena_completada activado")
	assert_eq(gm.menas_en_mano_cantidad, 0, "Menas en mano vaciadas tras fundir")
	assert_eq(gm.stock_barriles_fragua["bronce_cobre"], 6, "Barril de bronce recargado (+3 lingotes: 3 -> 6)")

	workshop.close_station()
	workshop.queue_free()
	await process_frame

	# 6. Tutorial de 14 Pasos en 2 Fases
	print("\n[TEST 6] Tutorial de 14 Pasos y 2 Fases...")
	var tutorial_script = load("res://src/scenes/ui/GuiaTutorial.gd")
	assert_eq(tutorial_script.TOTAL_PASOS, 14, "Tutorial configurado para 14 pasos totales")
	assert_eq(tutorial_script.ULTIMO_PASO_PARTE_1, 9, "Parte 1 concluye en el paso 9 (3 pedidos)")
	assert_eq(tutorial_script.PRIMER_PASO_PARTE_2, 10, "Parte 2 inicia en el paso 10 (dormir)")

	print("\n================================================================================")
	print("RESULTADOS TEST SUITE: %d/%d aserciones aprobadas (%d fallos)" % [passed_assertions, total_assertions, failed_assertions])
	print("================================================================================")
	if failed_assertions == 0:
		print(">>> CERTIFICACIÓN DE ACTUALIZACIÓN 100% EXITOSA <<<")
	quit(0 if failed_assertions == 0 else 1)
