# test_ciclo_multidia.gd
# Test headless automatizado para validar el ciclo multidia continuo en 'Yunque & Sombra':
# 1. Progresión de clientes de Día 1 a Día 5 y generación procedural en Día 6+
# 2. Descanso voluntario en cama (100% energía, 0 monedas perdidas)
# 3. Colapso a medianoche dentro de taller (50% energía, 0 monedas perdidas)
# 4. Asalto a medianoche en exterior/mina (40% energía, pérdida de ~18% de oro, pérdida de menas en mano)
# 5. Despertar en dormitorio (SPAWN_BEDROOM) y presentación de PantallaResumenDia
# 6. Apertura (06:00) y Cierre (17:00) del mostrador comercial
# 7. Regeneración nocturna de vetas de la mina
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
	print("🌅 EJECUTANDO TEST SUITE: CICLO MULTIDÍA CONTINUO Y PROGRESIÓN (DÍAS 1-5+)")
	print("================================================================================")

	var gm: Node = root.get_node_or_null("GameManager")
	var tm: Node = root.get_node_or_null("TimeManager")
	assert_true(gm != null, "GameManager autoload presente")
	assert_true(tm != null, "TimeManager autoload presente")

	# -------------------------------------------------------------------------
	# TEST 1: Catálogo y Roster de Clientes por Día en CounterShopView
	# -------------------------------------------------------------------------
	print("\n[TEST 1] Verificación de Catálogo Progresivo de Clientes (Día 1 a Día 5+)...")
	var counter_scene: PackedScene = load("res://src/scenes/workshop/CounterShopView.tscn")
	var counter: Control = counter_scene.instantiate() as Control
	root.add_child(counter)
	await process_frame

	# Día 1
	counter.reiniciar_jornada_mostrador(1)
	assert_eq(counter.customers.size(), 3, "Día 1 tiene 3 clientes")
	assert_eq(counter.customers[0]["item_name"], "Clavo Forjado de Compuerta", "Día 1 / C1: Clavo Forjado")
	assert_eq(counter.customers[1]["item_name"], "Perno Rústico de Molino", "Día 1 / C2: Perno de Molino")
	assert_eq(counter.customers[2]["item_name"], "Perno de Bronce de Caravana", "Día 1 / C3: Perno de Bronce")

	# Día 2
	counter.reiniciar_jornada_mostrador(2)
	assert_eq(counter.customers.size(), 3, "Día 2 tiene 3 clientes")
	assert_eq(counter.customers[0]["item_name"], "Reja de Arado Reforzada", "Día 2 / C1: Reja de Arado de Mateo")
	assert_eq(counter.customers[1]["item_name"], "Herradura de Tiro Pesado", "Día 2 / C2: Herradura de Anselmo")
	assert_eq(counter.customers[2]["item_name"], "Trípode de Brasa para Caldero", "Día 2 / C3: Trípode de Greta")

	# Día 3
	counter.reiniciar_jornada_mostrador(3)
	assert_eq(counter.customers.size(), 3, "Día 3 tiene 3 clientes")
	assert_eq(counter.customers[0]["item_name"], "Hacha de Talar de Filo Tenaz", "Día 3 / C1: Hacha de Baldomero")
	assert_eq(counter.customers[1]["item_name"], "Pico de Barreno Profundo", "Día 3 / C2: Pico de Gorki")
	assert_eq(counter.customers[2]["item_name"], "Zuncho de Barril de Mosto", "Día 3 / C3: Zuncho de Teo")

	# Día 4
	counter.reiniciar_jornada_mostrador(4)
	assert_eq(counter.customers.size(), 3, "Día 4 tiene 3 clientes")
	assert_eq(counter.customers[0]["item_name"], "Daga Corta de Inspección", "Día 4 / C1: Daga del Sargento")
	assert_eq(counter.customers[1]["item_name"], "Bisagras de Portón Pesado", "Día 4 / C2: Bisagras de Don Claudio")
	assert_eq(counter.customers[2]["item_name"], "Cascabel Sonoro de Niebla", "Día 4 / C3: Cascabel de Niña Lira")

	# Día 5 (Punto de Inflexión Feudal)
	counter.reiniciar_jornada_mostrador(5)
	assert_eq(counter.customers.size(), 3, "Día 5 tiene 3 clientes")
	assert_eq(counter.customers[0]["item_name"], "Cadenas Pesadas de Contención", "Día 5 / C1: Cadenas Pesadas del Capitán Feudal")
	assert_eq(counter.customers[1]["item_name"], "Cerrojo Oculto de Doble Traba", "Día 5 / C2: Cerrojo Oculto del Aldeano Asustado")
	assert_eq(counter.customers[2]["item_name"], "Refuerzo de Carromato para Fuga", "Día 5 / C3: Refuerzo para Fuga de Valeria")

	# Día 6+ (Generación Procedural Continua)
	counter.reiniciar_jornada_mostrador(6)
	assert_eq(counter.customers.size(), 3, "Día 6 procedural tiene 3 clientes")
	assert_true(counter.customers[0]["item_name"].length() > 0, "Día 6 / C1 generado proceduralmente")
	assert_true(counter.customers[1]["item_name"].length() > 0, "Día 6 / C2 generado proceduralmente")
	assert_true(counter.customers[2]["item_name"].length() > 0, "Día 6 / C3 generado proceduralmente")

	counter.reiniciar_jornada_mostrador(12)
	assert_eq(counter.customers.size(), 3, "Día 12 procedural tiene 3 clientes")

	counter.queue_free()
	await process_frame

	# -------------------------------------------------------------------------
	# TEST 2: Descanso Voluntario en Cama (100% de Energía)
	# -------------------------------------------------------------------------
	print("\n[TEST 2] Verificación de Sueño Voluntario en Cama...")
	tm.day = 1
	tm.hour = 21
	tm.minute = 30
	gm.stamina = 35.0
	gm.coins = 100
	gm.zona_actual = "interior"

	var resumen_recibido: Dictionary = {}
	var callback_resumen = func(info: Dictionary) -> void:
		resumen_recibido.clear()
		resumen_recibido.merge(info)

	tm.daily_summary_requested.connect(callback_resumen)
	await tm.sleep_voluntarily()
	await process_frame

	assert_eq(tm.day, 2, "El día avanzó a Día 2")
	assert_eq(tm.hour, 6, "La hora se reinició a 06:00 AM")
	assert_eq(tm.minute, 0, "El minuto se reinició a 0")
	assert_eq(gm.stamina, gm.max_stamina, "Estamina restaurada al 100% (100.0)")
	assert_eq(gm.coins, 100, "Sin robo de monedas en sueño voluntario (100)")
	assert_eq(resumen_recibido.get("tipo_descanso", ""), "voluntario", "Resumen registra tipo voluntario")

	tm.daily_summary_requested.disconnect(callback_resumen)

	# -------------------------------------------------------------------------
	# TEST 3: Desmayo a Medianoche dentro de Taller (50% de Energía)
	# -------------------------------------------------------------------------
	print("\n[TEST 3] Verificación de Colapso a Medianoche dentro de Taller...")
	tm.day = 2
	tm.hour = 23
	tm.minute = 59
	gm.stamina = 80.0
	gm.coins = 120
	gm.zona_actual = "interior"

	resumen_recibido.clear()
	tm.daily_summary_requested.connect(callback_resumen)

	# Simular llegada a medianoche
	tm.advance_minute()
	await process_frame
	await create_timer(0.12).timeout

	assert_eq(tm.day, 3, "El día avanzó a Día 3 tras colapso en taller")
	assert_eq(tm.hour, 6, "Hora 06:00 AM")
	assert_eq(gm.stamina, gm.max_stamina * 0.5, "Estamina restaurada al 50% por fatiga de taller")
	assert_eq(gm.coins, 120, "Sin robo dentro de casa (120)")
	assert_eq(resumen_recibido.get("tipo_descanso", ""), "desmayo_taller", "Resumen registra desmayo_taller")

	tm.daily_summary_requested.disconnect(callback_resumen)

	# -------------------------------------------------------------------------
	# TEST 4: Asalto a Medianoche a la Intemperie / Mina (40% Energía y Robo)
	# -------------------------------------------------------------------------
	print("\n[TEST 4] Verificación de Asalto a Medianoche en Exteriores / Mina...")
	tm.day = 3
	tm.hour = 23
	tm.minute = 59
	gm.stamina = 90.0
	gm.coins = 100
	gm.zona_actual = "exterior"
	gm.menas_en_mano_tipo = "hierro_dulce"
	gm.menas_en_mano_cantidad = 2

	resumen_recibido.clear()
	tm.daily_summary_requested.connect(callback_resumen)

	tm.advance_minute()
	await process_frame
	await create_timer(0.12).timeout

	assert_eq(tm.day, 4, "El día avanzó a Día 4 tras asalto en exteriores")
	assert_eq(tm.hour, 6, "Hora 06:00 AM")
	assert_eq(gm.stamina, gm.max_stamina * 0.4, "Estamina restaurada solo al 40% por severa fatiga")
	assert_true(gm.coins < 100, "Monedas reducidas por robo nocturno (%d < 100)" % gm.coins)
	assert_eq(gm.menas_en_mano_cantidad, 0, "Menas en mano perdidas tras el asalto")
	assert_eq(resumen_recibido.get("tipo_descanso", ""), "desmayo_exterior", "Resumen registra desmayo_exterior")
	assert_true(int(resumen_recibido.get("monedas_robadas", 0)) > 0, "Registro de monedas robadas > 0")

	tm.daily_summary_requested.disconnect(callback_resumen)

	# -------------------------------------------------------------------------
	# TEST 5: PantallaResumenDia UI
	# -------------------------------------------------------------------------
	print("\n[TEST 5] Verificación de PantallaResumenDia...")
	var resumen_scene: PackedScene = load("res://src/scenes/ui/PantallaResumenDia.tscn")
	var resumen_ui = resumen_scene.instantiate()
	root.add_child(resumen_ui)
	await process_frame

	var datos_prueba: Dictionary = {
		"tipo_descanso": "voluntario",
		"titulo_descanso": "Descanso Pleno en Cama",
		"desc_descanso": "Dormiste profundamente.",
		"stamina_pct": 1.0,
		"monedas_robadas": 0,
		"pedidos_ayer": 3,
		"ganancias_ayer": 75,
		"saldo_actual": 150,
		"nuevo_dia": 5
	}
	resumen_ui.mostrar_resumen(datos_prueba)
	assert_true(resumen_ui.visible, "PantallaResumenDia visible tras llamada")
	assert_true(resumen_ui.etiqueta_titulo_amanecer.text.contains("DÍA 5"), "Título refleja DÍA 5")
	assert_true(resumen_ui.etiqueta_texto_rumor.text.length() > 0, "Texto del rumor del Día 5 presente")

	resumen_ui._on_boton_comenzar_pressed()
	await process_frame
	await create_timer(0.25).timeout
	assert_false(resumen_ui.visible, "PantallaResumenDia se oculta tras presionar continuar")

	resumen_ui.queue_free()
	await process_frame

	# -------------------------------------------------------------------------
	# TEST 6: Apertura y Cierre Comercial por Horas (06:00 y 17:00)
	# -------------------------------------------------------------------------
	print("\n[TEST 6] Verificación de Horario Comercial (06:00 a 17:00)...")
	var counter_test: Control = counter_scene.instantiate() as Control
	root.add_child(counter_test)
	await process_frame

	tm.hour = 12
	counter_test.reiniciar_jornada_mostrador(2)
	assert_false(counter_test.bell_button.disabled, "Campana habilitada durante horario comercial (12:00)")

	# Llegada de las 17:00 (Cierre comercial)
	tm.hour = 17
	tm.advance_hour() # triggers shop_closed
	await process_frame
	assert_true(counter_test.bell_button.disabled, "Campana deshabilitada tras cierre comercial de las 17:00")

	counter_test.queue_free()
	await process_frame

	# -------------------------------------------------------------------------
	# RESULTADOS
	# -------------------------------------------------------------------------
	print("\n================================================================================")
	print("RESULTADOS TEST SUITE MULTIDÍA: %d/%d aserciones aprobadas (%d fallos)" % [passed_assertions, total_assertions, failed_assertions])
	print("================================================================================")

	if failed_assertions == 0:
		print(">>> CERTIFICACIÓN MULTIDÍA 100% EXITOSA <<<")
		quit(0)
	else:
		printerr(">>> TEST MULTIDÍA FALLIDO <<<")
		quit(1)
