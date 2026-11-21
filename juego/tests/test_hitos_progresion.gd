# test_hitos_progresion.gd
# Test unitario y de integración para el Sistema de Progresión y Narrativa por Hitos (Event-Driven)
extends SceneTree

var total_assertions: int = 0
var passed_assertions: int = 0
var failed_assertions: int = 0

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("\n" + "=".repeat(80))
	print("🏆 EJECUTANDO TEST SUITE: HITOS DE PROGRESIÓN Y DESBLOQUEO POR OBJETOS")
	print("=".repeat(80))
	
	test_sistema_hitos_y_objetos()
	
	print("\n" + "=".repeat(80))
	print("RESULTADOS TEST SUITE HITOS: %d/%d aserciones aprobadas (%d fallos)" % [passed_assertions, total_assertions, failed_assertions])
	print("=".repeat(80))
	
	if failed_assertions == 0:
		print(">>> CERTIFICACIÓN DE PROGRESIÓN POR HITOS 100% EXITOSA <<<\n")
		quit(0)
	else:
		printerr(">>> TEST SUITE CON ERRORES: %d FALLOS <<<\n" % failed_assertions)
		quit(1)

func test_sistema_hitos_y_objetos() -> void:
	var gm: Node = root.get_node_or_null("GameManager")
	print("\n[TEST 1] Verificación de estado inicial de hitos y objetos...")
	assert_true(gm != null, "GameManager singleton disponible en root")
	assert_false(gm.tiene_objeto("crisol_bronce"), "Crisol de bronce no poseído al inicio")
	assert_false(gm.tiene_hito("hito_1_crisol_bronce"), "Hito 1 no desbloqueado al inicio")
	assert_false(gm.tiene_objeto("pico_reforzado"), "Pico reforzado no poseído al inicio")
	assert_false(gm.tiene_hito("hito_2_pico_reforzado"), "Hito 2 no desbloqueado al inicio")
	
	print("\n[TEST 2] Verificación de compra de objeto y disparo automático de hito...")
	var hito_recibido: Dictionary = {}
	var objeto_recibido: Array[String] = []
	
	gm.hito_desbloqueado.connect(func(clave: String, tit: String, _desc: String) -> void:
		hito_recibido["clave"] = clave
		hito_recibido["titulo"] = tit
	)
	gm.objeto_comprado.connect(func(clave: String) -> void:
		objeto_recibido.append(clave)
	)
	
	# Comprar el crisol de bronce
	gm.registrar_compra_objeto("crisol_bronce", "Crisol de Arcilla Refractaria")
	assert_true(gm.tiene_objeto("crisol_bronce"), "Objeto crisol_bronce registrado en GameManager")
	assert_true(objeto_recibido.has("crisol_bronce"), "Señal objeto_comprado emitida con crisol_bronce")
	assert_true(gm.tiene_hito("hito_1_crisol_bronce"), "Hito 'hito_1_crisol_bronce' desbloqueado automáticamente por compra")
	assert_eq(str(hito_recibido.get("clave", "")), "hito_1_crisol_bronce", "Clave de hito emitida correctamente")
	
	print("\n[TEST 3] Verificación de avance a Nivel 2 de Mina y Derrumbe...")
	gm.registrar_compra_objeto("pico_reforzado", "Pico de Bronce Reforzado")
	assert_true(gm.tiene_objeto("pico_reforzado"), "Pico reforzado registrado")
	assert_true(gm.tiene_hito("hito_2_pico_reforzado"), "Hito 2 pico reforzado desbloqueado")
	
	# Desbloqueo de evento de mina directo
	var exito_derrumbe: bool = gm.desbloquear_hito("hito_2_derrumbe_mina_roto", "Derrumbe Roto", "Galería inferior abierta")
	assert_true(exito_derrumbe, "Desbloqueo de derrumbe retorna true en primer disparo")
	assert_true(gm.tiene_hito("hito_2_derrumbe_mina_roto"), "Hito de derrumbe registrado")
	
	# Segundo intento no debe duplicar ni fallar
	var reintento: bool = gm.desbloquear_hito("hito_2_derrumbe_mina_roto", "Derrumbe Roto", "Galería inferior abierta")
	assert_false(reintento, "Desbloqueo duplicado retorna false sin romper el estado")
	
	print("\n[TEST 4] Verificación de Hito 4 (Fuelle Doble y Pre-Clímax)...")
	gm.registrar_compra_objeto("fuelle_doble", "Fuelle de Doble Cámara")
	assert_true(gm.tiene_objeto("fuelle_doble"), "Fuelle doble registrado")
	assert_true(gm.tiene_hito("hito_4_fuelle_doble"), "Hito 4 fuelle doble desbloqueado")

func assert_true(condition: bool, message: String) -> void:
	total_assertions += 1
	if condition:
		passed_assertions += 1
		print("  [PASS] %s" % message)
	else:
		failed_assertions += 1
		printerr("  [FAIL] %s" % message)

func assert_false(condition: bool, message: String) -> void:
	total_assertions += 1
	if not condition:
		passed_assertions += 1
		print("  [PASS] %s" % message)
	else:
		failed_assertions += 1
		printerr("  [FAIL] %s" % message)

func assert_eq(got: Variant, expected: Variant, message: String) -> void:
	total_assertions += 1
	if got == expected:
		passed_assertions += 1
		print("  [PASS] %s (Obtenido: %s)" % [message, str(got)])
	else:
		failed_assertions += 1
		printerr("  [FAIL] %s (Esperado: %s, Obtenido: %s)" % [message, str(expected), str(got)])
