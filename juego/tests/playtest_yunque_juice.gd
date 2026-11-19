# tests/playtest_yunque_juice.gd
# Batería de pruebas automatizada para el pulido visual, shaders, termodinámica real (/herrero)
# y prueba de estrés de 50 impactos sin fugas de memoria (/game_feel + /playtester).
extends SceneTree

var total_assertions: int = 0
var passed_assertions: int = 0
var failed_assertions: int = 0

func _init() -> void:
	print("================================================================================")
	print("🔨 INICIANDO CERTIFICACIÓN DE JUICE, TERMODINÁMICA Y ESTRÉS EN YUNQUE CENITAL")
	print("================================================================================")
	process_frame.connect(_run_suite, CONNECT_ONE_SHOT)

func assert_true(cond: bool, msg: String) -> void:
	total_assertions += 1
	if cond:
		passed_assertions += 1
		print("  ✅ [PASS] " + msg)
	else:
		failed_assertions += 1
		printerr("  ❌ [FAIL] " + msg)

func _run_suite() -> void:
	var workshop_scene: PackedScene = load("res://src/scenes/workshop/WorkshopStationView.tscn")
	assert_true(workshop_scene != null, "WorkshopStationView.tscn carga sin errores")
	var workshop: CanvasLayer = workshop_scene.instantiate()
	root.add_child(workshop)
	await process_frame
	await process_frame

	workshop.open_station()
	await process_frame

	var anvil: Control = workshop.anvil_station
	assert_true(anvil != null, "Instancia de AnvilTopDownStation presente")

	# 1. Verificación de nodos en español y shaders de autor
	print("\n[1] Nodos de Atmósfera, Shaders y Componentes de Juice...")
	assert_true(anvil.has_node("FondoTaller"), "Nodo 'FondoTaller' presente")
	assert_true(anvil.has_node("LuzBrasas"), "Nodo 'LuzBrasas' presente")
	assert_true(anvil.has_node("VinetaFragua"), "Nodo 'VinetaFragua' presente")
	assert_true(anvil.has_node("SacudidaTrauma"), "Componente 'SacudidaTrauma' presente")
	assert_true(anvil.has_node("SuperficieYunque/ResplandorCalor"), "Nodo 'ResplandorCalor' presente")
	assert_true(anvil.has_node("SuperficieYunque/DestelloImpacto"), "Nodo 'DestelloImpacto' presente")
	assert_true(anvil.has_node("SuperficieYunque/ChispasForja"), "Nodo 'ChispasForja' presente")
	assert_true(anvil.has_node("BarraSuperior/EtiquetaTemperaturaPieza"), "Nodo 'EtiquetaTemperaturaPieza' presente")
	assert_true(anvil.has_node("BotonVolverAFragua"), "Nodo 'BotonVolverAFragua' presente")
	assert_true(anvil.metal_polygon.material is ShaderMaterial, "LingoteDeformable tiene ShaderMaterial (metal_incandescente.gdshader)")

	# 2. Escala térmica realista en la fragua (20°C -> 1000..1150°C)
	print("\n[2] Escala Térmica Realista en Fragua (20°C a 1400°C)...")
	workshop._switch_tab(workshop.StationTab.FORGE)
	assert_true(abs(workshop.temperature - 20.0) <= 2.0, "Fragua inicia en temperatura ambiente (~20°C): %.1f°C" % workshop.temperature)
	for i in range(5):
		workshop._on_bellows_pressed()
	assert_true(workshop.temperature >= 1000.0 and workshop.temperature <= 1150.0, "5 bombeos de fuelle llevan a caldeo óptimo [1000-1150°C]: %.1f°C" % workshop.temperature)
	workshop._on_to_anvil_pressed()
	assert_true(abs(anvil.temperatura_pieza - workshop.temperature) < 1.0, "El yunque recibe la temperatura real de la fragua: %.1f°C" % anvil.temperatura_pieza)

	# 3. Enfriamiento en tiempo real en el yunque
	print("\n[3] Enfriamiento Continuo en el Yunque...")
	var temp_antes: float = anvil.temperatura_pieza
	await create_timer(0.35).timeout
	var temp_despues: float = anvil.temperatura_pieza
	assert_true(temp_despues < temp_antes - 4.0, "La pieza se enfría en tiempo real (%.1f°C -> %.1f°C)" % [temp_antes, temp_despues])

	# 4. Deformación en caliente vs penalización en frío
	print("\n[4] Plasticidad Térmica y Penalización por Golpear en Frío...")
	anvil._strike_at_position(Vector2(240.0, 140.0))
	anvil._strike_at_position(Vector2(280.0, 140.0))
	assert_true(anvil.penalizacion_frio == 0.0, "Golpear por encima de 800°C no genera penalización en frío")
	var forma_caliente: PackedVector2Array = anvil.metal_polygon.polygon.duplicate()

	# Enfriar forzosamente a 550°C (< 650°C umbral de acero frío)
	anvil.temperatura_pieza = 550.0
	anvil._strike_at_position(Vector2(320.0, 140.0))
	assert_true(anvil.penalizacion_frio > 0.05, "Golpear en frío (<650°C) aplica penalización de precisión: %.2f" % anvil.penalizacion_frio)
	assert_true(anvil.golpes_en_frio == 1, "Se registra golpe en frío (golpes_en_frio == 1)")

	# 5. Flujo de recalentado en la fragua conservando la forma
	print("\n[5] Recalentado en Fragua sin Perder la Forma Martillada...")
	var golpes_previos: int = anvil.strikes_count
	var offsets_previos: Array[float] = anvil.upper_offsets.duplicate()
	anvil.boton_volver_a_fragua.emit_signal("pressed")
	await process_frame
	assert_true(workshop.current_station == workshop.StationTab.FORGE, "BotonVolverAFragua regresa a la pestaña FORGE")
	assert_true(not workshop.is_forge_settled, "La fragua se desbloquea para permitir bombear el fuelle")

	# Atizar 3 veces para volver a >1000°C y regresar al yunque
	for i in range(3):
		workshop._on_bellows_pressed()
	workshop._on_to_anvil_pressed()
	await process_frame
	assert_true(workshop.current_station == workshop.StationTab.ANVIL, "Regreso al yunque tras recalentar")
	assert_true(anvil.temperatura_pieza >= 1000.0, "La pieza regresa recalentada (>=1000°C): %.1f°C" % anvil.temperatura_pieza)
	assert_true(anvil.strikes_count == golpes_previos, "Se conserva el conteo de golpes (%d)" % anvil.strikes_count)
	assert_true(anvil.upper_offsets[4] == offsets_previos[4], "Se conserva la geometría deformada del lingote")

	# 6. Prueba de estrés: 50 golpes consecutivos y verificación de 0 fugas de nodos
	print("\n[6] Prueba de Estrés: 50 Impactos de Martillo y Limpieza de Memoria...")
	for i in range(50):
		var x_pos: float = lerpf(180.0, 420.0, float(i % 10) / 9.0)
		anvil._strike_at_position(Vector2(x_pos, 140.0))
	assert_true(anvil.hit_area.get_child_count() >= 50, "Efectos de martillo instanciados durante la ráfaga (%d activos)" % anvil.hit_area.get_child_count())
	# Esperar a que todos los HammerEffect concluyan su tween (~0.5s) y ejecuten queue_free()
	await create_timer(0.65).timeout
	await process_frame
	var hijos_final: int = anvil.hit_area.get_child_count()
	assert_true(hijos_final == 0, "Cero fugas de nodos tras 50 impactos (hijos restantes=%d)" % hijos_final)

	# 7. Estiramiento longitudinal real en X y flujo plástico sin tope plano en Y
	print("\n[7] Estiramiento Longitudinal (X) y Deformación Orgánica sin Límite Plano...")
	anvil.reset_station(Color(1.0, 0.52, 0.15, 1.0), 1100.0)
	var largo_inicial_x: float = anvil.slice_x[anvil.NUM_SLICES - 1] - anvil.slice_x[0]
	for i in range(12):
		anvil._strike_at_position(Vector2(240.0 + float(i * 15), 140.0))
	var largo_final_x: float = anvil.slice_x[anvil.NUM_SLICES - 1] - anvil.slice_x[0]
	assert_true(largo_final_x > largo_inicial_x + 40.0, "El metal se estira longitudinalmente en X al martillar (%.1fpx -> %.1fpx)" % [largo_inicial_x, largo_final_x])

	# 8. Corte geométrico real por bisección de polígonos y atmósfera en todas las estaciones
	print("\n[8] Corte Geométrico Real (Geometry2D) y Atmósfera en Corte, Tina y Pulido...")
	var cut_station: Control = workshop.cut_station
	var quench_station: Control = workshop.quench_station
	var polish_station: Control = workshop.polish_station
	assert_true(cut_station.has_node("FondoTaller") and cut_station.has_node("VinetaFragua") and cut_station.has_node("SacudidaTrauma"), "Estación de Corte tiene FondoTaller, VinetaFragua y SacudidaTrauma")
	assert_true(quench_station.has_node("FondoTaller") and quench_station.has_node("VinetaFragua") and quench_station.has_node("SacudidaTrauma"), "Estación de Templado tiene FondoTaller, VinetaFragua y SacudidaTrauma")
	assert_true(polish_station.has_node("FondoTaller") and polish_station.has_node("VinetaFragua") and polish_station.has_node("SacudidaTrauma"), "Estación de Pulido tiene FondoTaller, VinetaFragua y SacudidaTrauma")

	cut_station.reset_station()
	var vertices_antes: int = cut_station.main_workpiece.polygon.size()
	# Trazar un corte diagonal libre en espacio de BancoCorte (centro ~300,150) que cruce la rebaba superior y la esquina del lingote
	cut_station._ejecutar_corte_geometrico_libre(Vector2(214.0, 137.0), Vector2(395.0, 141.0))
	assert_true(cut_station.cuts_completed.count(true) >= 1, "El trazo diagonal libre ejecuta un corte geométrico real en el metal")
	assert_true(cut_station.contenedor_fragmentos.get_child_count() >= 1 or cut_station.contenedor_cicatrices.get_child_count() >= 1, "Se genera el fragmento geométrico cortado y la cicatriz incandescente sobre la línea trazada (vertices: %d -> %d)" % [vertices_antes, cut_station.main_workpiece.polygon.size()])

	# 9. Martillo Físico con Hitbox por Velocidad, 3 Barriles en Fragua, Entrega Arrastrable y Exterior Visible
	print("\n[9] Martillo Móvil por Velocidad, 3 Barriles en Fragua, Pieza en Mesada y Exterior...")
	assert_true(anvil.has_node("SuperficieYunque/MartilloForjador/AreaHitboxMartillo"), "MartilloForjador con AreaHitboxMartillo presente")
	assert_true(anvil.has_node("SuperficieYunque/AreaColisionMetal/PoligonoColisionMetal"), "AreaColisionMetal con PoligonoColisionMetal presente")

	# Comparar golpe lento (140 px/s) vs golpe rápido (900 px/s)
	anvil.reset_station(Color(1.0, 0.52, 0.15, 1.0), 1100.0)
	var ancho_base: float = anvil.lower_offsets[3] - anvil.upper_offsets[3]
	anvil.simular_golpe_martillo_con_velocidad(Vector2(220.0, 140.0), 140.0)
	var delta_lento: float = (anvil.lower_offsets[3] - anvil.upper_offsets[3]) - ancho_base

	anvil.reset_station(Color(1.0, 0.52, 0.15, 1.0), 1100.0)
	anvil.simular_golpe_martillo_con_velocidad(Vector2(220.0, 140.0), 900.0)
	var delta_rapido: float = (anvil.lower_offsets[3] - anvil.upper_offsets[3]) - ancho_base
	assert_true(delta_rapido > delta_lento * 2.2, "Golpe rápido (900px/s) expande mucho más el metal que golpe lento (140px/s): %.2fpx vs %.2fpx" % [delta_rapido, delta_lento])

	# Verificar los 3 barriles y el lingote dentro de la boca del horno con oclusión de brasas
	assert_true(workshop.station_forge.has_node("ContenedorBarrilesMetales/BarrilHierroDulce"), "BarrilHierroDulce presente en Fragua")
	assert_true(workshop.station_forge.has_node("ContenedorBarrilesMetales/BarrilAceroCarbono"), "BarrilAceroCarbono presente en Fragua")
	assert_true(workshop.station_forge.has_node("ContenedorBarrilesMetales/BarrilBronceCobre"), "BarrilBronceCobre presente en Fragua")
	assert_true(workshop.station_forge.has_node("HornoFragua/InteriorBocaHorno/BrasasDelanterasOclusion"), "Oclusión de brasas delanteras presente dentro de la boca del horno")
	workshop.colocar_lingote_en_horno("acero_carbono")
	assert_true(workshop.tiene_lingote_en_horno and workshop.lingote_en_brasas.visible, "El lingote se introduce y visualiza dentro de las brasas del horno")

	# Verificar que la pieza forjada real se muestra como polígono arrastrable sobre la mesada del mostrador
	var mostrador: Control = workshop.counter_view
	mostrador.set_piece_ready_for_delivery(0.92, cut_station.main_workpiece.polygon)
	assert_true(mostrador.poligono_pieza_terminada.polygon.size() >= 10, "La mesada del mostrador exhibe el polígono real de la pieza forjada (%d vértices)" % mostrador.poligono_pieza_terminada.polygon.size())

	# 10. Martillo único (solo golpe por arrastre) y Clientes Articulados en Ventanilla
	print("\n[10] Martillo Único por Arrastre (Sin Clic Directo) y Clientes Articulados...")
	anvil.reset_station(Color(1.0, 0.52, 0.15, 1.0), 1100.0)
	var clic_directo := InputEventMouseButton.new()
	clic_directo.button_index = MOUSE_BUTTON_LEFT
	clic_directo.pressed = true
	clic_directo.position = Vector2(300.0, 140.0) # Clic sobre el lingote lejos del martillo
	anvil._on_hit_area_gui_input(clic_directo)
	assert_true(anvil.strikes_count == 0, "Hacer clic directo sobre el metal NO golpea ni teletransporta el martillo (strikes_count == 0)")

	# Agarrar el martillo en su posición de reposo y arrastrarlo hacia el lingote
	var clic_agarre := InputEventMouseButton.new()
	clic_agarre.button_index = MOUSE_BUTTON_LEFT
	clic_agarre.pressed = true
	clic_agarre.position = anvil.POSICION_REPOSO_MARTILLO
	anvil._on_hit_area_gui_input(clic_agarre)
	assert_true(anvil._arrastrando_martillo, "El jugador toma el MartilloForjador al hacer clic sobre él")

	var arrastre_golpe := InputEventMouseMotion.new()
	arrastre_golpe.position = Vector2(300.0, 140.0)
	anvil._on_hit_area_gui_input(arrastre_golpe)
	assert_true(anvil.strikes_count == 1, "Arrastrar el MartilloForjador hacia el metal produce exactamente 1 golpe único (strikes_count == %d)" % anvil.strikes_count)

	# Verificar que HammerEffect tiene MartilloVisual oculto (un solo martillo en escena)
	var fx_inst: Node2D = anvil.HAMMER_EFFECT_SCENE.instantiate()
	anvil.hit_area.add_child(fx_inst)
	assert_true(not fx_inst.martillo_visual.visible, "HammerEffect no renderiza un segundo martillo duplicado (MartilloVisual.visible == false)")
	fx_inst.queue_free()

	# Verificar los nuevos bustos articulados de clientes en el mostrador
	assert_true(mostrador.has_node("MarcoVentana/ContenedorCliente/PersonajeClienteArticulado/BustoSargentoGodofredo"), "Cliente articulado 'BustoSargentoGodofredo' presente en el mostrador")
	assert_true(mostrador.has_node("MarcoVentana/ContenedorCliente/PersonajeClienteArticulado/BustoMolineroEustaquio"), "Cliente articulado 'BustoMolineroEustaquio' presente en el mostrador")
	assert_true(mostrador.has_node("MarcoVentana/ContenedorCliente/PersonajeClienteArticulado/BustoMercaderValeria"), "Cliente articulado 'BustoMercaderValeria' presente en el mostrador")

	workshop.queue_free()
	await process_frame

	print("================================================================================")
	print("📊 RESULTADO YUNQUE JUICE: %d / %d aserciones superadas" % [passed_assertions, total_assertions])
	print("================================================================================")
	quit(0 if failed_assertions == 0 else 1)
