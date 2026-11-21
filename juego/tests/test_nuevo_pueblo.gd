# test_nuevo_pueblo.gd
# Test headless para validar la nueva arquitectura espacial del pueblo exterior basada en el boceto:
# - Plaza Central con Fuente de piedra labrada
# - Kiosco Móvil (Comercio sobre ruedas del buhonero)
# - Taberna de Greta (porche, barriles, letrero)
# - Fermín Muebles (taller de maderas y carretas)
# - Corrales comunales de ganado y huerta
# - Camino a Casa de Gobierno (sendero noroeste con cactus y portón feudal)
# - La Herrería en la ladera (fachada, horno abovedado exterior y cerca)
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

func assert_eq(val1, val2, message: String) -> void:
	assert_true(val1 == val2, "%s (Esperado: %s, Obtenido: %s)" % [message, str(val2), str(val1)])

func _run_tests() -> void:
	print("================================================================================")
	print("🏘️ EJECUTANDO TEST SUITE: NUEVO PUEBLO SEGÚN BOCETO (PLAZA, TABERNA, KIOSCO)")
	print("================================================================================")

	var town_scene: PackedScene = load("res://src/scenes/levels/GreyboxTown.tscn")
	assert_true(town_scene != null, "Escena GreyboxTown.tscn cargada exitosamente")

	var town: Node2D = town_scene.instantiate() as Node2D
	root.add_child(town)
	await process_frame

	print("\n[TEST 1] Verificación de la Plaza Central y Fuente de Piedra...")
	var fuente: Node2D = town.get_node_or_null("PuebloExterior/FuenteCentralPlaza")
	assert_true(fuente != null, "Nodo FuenteCentralPlaza presente")
	assert_true(fuente.has_node("AreaInteractiva"), "Fuente tiene AreaInteractiva")
	assert_eq(fuente.get_node("AreaInteractiva").prompt_text, "Inspeccionar Fuente de la Plaza [E]", "Prompt de fuente correcto")

	print("\n[TEST 2] Verificación del Kiosco Móvil (Comercio sobre Ruedas)...")
	var kiosco: Node2D = town.get_node_or_null("PuebloExterior/KioscoMovil")
	assert_true(kiosco != null, "Nodo KioscoMovil presente")
	assert_true(kiosco.has_node("AreaInteractiva"), "Kiosco tiene AreaInteractiva")
	assert_eq(kiosco.get_node("AreaInteractiva").prompt_text, "Comerciar con el Buhonero Ambulante [E]", "Prompt de kiosco correcto")

	print("\n[TEST 3] Verificación de la Taberna de Greta...")
	var taberna: Node2D = town.get_node_or_null("PuebloExterior/TabernaDelValle")
	assert_true(taberna != null, "Nodo TabernaDelValle presente")
	assert_true(taberna.has_node("AreaInteractiva"), "Taberna tiene AreaInteractiva")
	assert_eq(taberna.get_node("AreaInteractiva").prompt_text, "Inspeccionar Taberna de Greta [E]", "Prompt de taberna correcto")

	print("\n[TEST 4] Verificación de Fermín Muebles...")
	var fermin: Node2D = town.get_node_or_null("PuebloExterior/FerminMuebles")
	assert_true(fermin != null, "Nodo FerminMuebles presente")
	assert_true(fermin.has_node("AreaInteractiva"), "Fermín Muebles tiene AreaInteractiva")
	assert_eq(fermin.get_node("AreaInteractiva").prompt_text, "Inspeccionar Taller de Fermín Muebles [E]", "Prompt de Fermín Muebles correcto")

	print("\n[TEST 5] Verificación del Camino a Casa de Gobierno (Feudo)...")
	var camino_gob: Node2D = town.get_node_or_null("PuebloExterior/CaminoCasaGobierno")
	assert_true(camino_gob != null, "Nodo CaminoCasaGobierno presente")
	assert_true(camino_gob.has_node("CactusSaguaro1"), "Cactus saguaro presente en el camino desértico")
	assert_true(camino_gob.has_node("PortonFeudal/AreaInteractiva"), "Portón feudal tiene AreaInteractiva")

	print("\n[TEST 6] Verificación de Corrales de Ganado...")
	var corral: Node2D = town.get_node_or_null("PuebloExterior/CorralesGanado/CorralOeste")
	assert_true(corral != null, "Nodo CorralOeste presente")
	assert_true(corral.has_node("AreaInteractiva"), "Corral tiene AreaInteractiva")

	print("\n[TEST 7] Verificación de Horno Abovedado Exterior de la Herrería...")
	var horno: Node2D = town.get_node_or_null("PuebloExterior/FachadaCasaTio/HornoAbovedadoExterior")
	assert_true(horno != null, "HornoAbovedadoExterior presente en la fachada del taller")
	var cerca: Node2D = town.get_node_or_null("PuebloExterior/FachadaCasaTio/CercaLaderaMadera")
	assert_true(cerca != null, "CercaLaderaMadera presente en la ladera de la herrería")

	print("\n[TEST 8] Disparo de Interacciones Diegéticas...")
	var gm: Node = root.get_node_or_null("GameManager")
	assert_true(gm != null, "GameManager presente en root")
	var notificacion_recibida: Dictionary = {"msg": ""}
	gm.notification_posted.connect(func(msg: String) -> void:
		notificacion_recibida["msg"] = msg
	)

	# Probar interactuar con Kiosco Móvil
	town.area_kiosco_movil.interact()
	assert_true(str(notificacion_recibida.get("msg", "")).contains("Buhonero"), "Notificación de Buhonero emitida")

	# Probar interactuar con Taberna
	town.area_taberna.interact()
	assert_true(str(notificacion_recibida.get("msg", "")).contains("Taberna de Greta"), "Notificación de Taberna emitida")

	# Probar interactuar con Fermín Muebles
	town.area_fermin_muebles.interact()
	assert_true(str(notificacion_recibida.get("msg", "")).contains("Fermín Muebles"), "Notificación de Fermín Muebles emitida")

	# Probar interactuar con Camino a Casa de Gobierno
	town.area_camino_gobierno.interact()
	assert_true(str(notificacion_recibida.get("msg", "")).contains("Guardia Feudal"), "Notificación de Guardia Feudal emitida")

	print("\n" + "=".repeat(80))
	print("RESULTADOS TEST SUITE NUEVO PUEBLO: %d/%d aserciones aprobadas (%d fallos)" % [passed_assertions, total_assertions, failed_assertions])
	print("=".repeat(80))

	if failed_assertions == 0:
		print(">>> CERTIFICACIÓN DEL NUEVO PUEBLO 100% EXITOSA <<<\n")
		quit(0)
	else:
		printerr(">>> TEST SUITE CON ERRORES: %d FALLOS <<<\n" % failed_assertions)
		quit(1)
