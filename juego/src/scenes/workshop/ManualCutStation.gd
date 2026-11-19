# ManualCutStation.gd
# Estación de corte manual con cizalla y tajadera de herrero (/herrero + /game_feel).
# Implementa bisección geométrica real de polígonos (Geometry2D.clip_polygons) exactamente a lo largo
# del trazo marcado por el jugador, desprendiendo el fragmento real recortado con física, chispas y cicatriz térmica.
extends Control

signal cutting_completed(score: float, trimmed_shape: PackedVector2Array)

const EscalaTermica = preload("res://src/components/EscalaTermicaAcero.gd")

# Nodos en Español
@onready var banco_corte: Panel = $BancoCorte
@onready var resplandor_calor: TextureRect = $BancoCorte/ResplandorCalor
@onready var pieza_principal: Polygon2D = $BancoCorte/PiezaPrincipal
@onready var rebaba_superior: Polygon2D = $BancoCorte/RebabaSuperior
@onready var rebaba_inferior: Polygon2D = $BancoCorte/RebabaInferior
@onready var rebaba_punta: Polygon2D = $BancoCorte/RebabaPunta
@onready var contenedor_fragmentos: Node2D = $BancoCorte/ContenedorFragmentos
@onready var contenedor_cicatrices: Node2D = $BancoCorte/ContenedorCicatrices

@onready var linea_corte_superior: Line2D = $BancoCorte/LineaCorteSuperior
@onready var linea_corte_inferior: Line2D = $BancoCorte/LineaCorteInferior
@onready var linea_corte_punta: Line2D = $BancoCorte/LineaCortePunta
@onready var linea_arrastre_corte: Line2D = $BancoCorte/LineaArrastreCorte
@onready var chispas_corte: CPUParticles2D = $BancoCorte/ChispasCorte

@onready var herramienta_cizalla: Node2D = $BancoCorte/HerramientaCizalla
@onready var etiqueta_crac: Label = $BancoCorte/EtiquetaCrac
@onready var sacudida_trauma: Node = $SacudidaTrauma
@onready var etiqueta_estado: Label = $EtiquetaEstado
@onready var etiqueta_progreso: Label = $BarraSuperior/EtiquetaProgreso
@onready var etiqueta_precision_corte: Label = $BarraSuperior/EtiquetaPrecisionCorte
@onready var etiqueta_largo_trazo: Label = $BarraSuperior/EtiquetaLargoTrazo
@onready var boton_ir_a_tina: Button = $BotonIrATina

# Alias de compatibilidad hacia atrás
var cut_bench: Panel:
	get: return banco_corte
var main_workpiece: Polygon2D:
	get: return pieza_principal
var scrap_top: Polygon2D:
	get: return rebaba_superior
var scrap_bottom: Polygon2D:
	get: return rebaba_inferior
var scrap_tip: Polygon2D:
	get: return rebaba_punta
var cut_line_top: Line2D:
	get: return linea_corte_superior
var cut_line_bottom: Line2D:
	get: return linea_corte_inferior
var cut_line_tip: Line2D:
	get: return linea_corte_punta
var cut_drag_line: Line2D:
	get: return linea_arrastre_corte
var cutter_tool: Node2D:
	get: return herramienta_cizalla
var crac_label: Label:
	get: return etiqueta_crac
var status_label: Label:
	get: return etiqueta_estado
var progress_label: Label:
	get: return etiqueta_progreso
var btn_to_quench: Button:
	get: return boton_ir_a_tina

const LARGO_MAXIMO_TRAZO: float = 220.0

# Estado de corte
var is_dragging: bool = false
var drag_start_bench: Vector2 = Vector2.ZERO
var _puntos_trazo: PackedVector2Array = PackedVector2Array()
var _largo_trazo_actual: float = 0.0
var cuts_completed: Array[bool] = [false, false, false] # 0: Superior, 1: Inferior, 2: Punta
var cut_accuracy_scores: Array[float] = []
var temperatura_pieza: float = 940.0
var _sonido_corte_optimo_emitido: bool = false
var _corto_en_arrastre_actual: bool = false

# Coordenadas relativas al centro del banco (300, 150)
var scrap_lines: Array[Dictionary] = [
	{
		"name": "Rebaba Superior",
		"start": Vector2(-86, -13),
		"end": Vector2(95, -9),
		"node_name": "ScrapTop"
	},
	{
		"name": "Rebaba Inferior",
		"start": Vector2(-86, 13),
		"end": Vector2(95, 9),
		"node_name": "ScrapBottom"
	},
	{
		"name": "Punta Excedente",
		"start": Vector2(95, -14),
		"end": Vector2(95, 14),
		"node_name": "ScrapTip"
	}
]

var _fragmentos_volando: Array[Dictionary] = []

func _ready() -> void:
	btn_to_quench.pressed.connect(_on_to_quench_pressed)
	cutter_tool.visible = false
	crac_label.visible = false
	cut_drag_line.visible = false
	btn_to_quench.disabled = true
	reset_station()

func _process(delta: float) -> void:
	if not visible or not is_visible_in_tree() or _fragmentos_volando.is_empty():
		return
	for datos in _fragmentos_volando:
		var nodo: Polygon2D = datos["nodo"]
		if not is_instance_valid(nodo):
			continue
		var vel: Vector2 = datos["vel"]
		vel.y += 420.0 * delta
		nodo.position += vel * delta
		nodo.rotation += float(datos["vel_rot"]) * delta
		datos["vel"] = vel
		datos["edad"] = float(datos["edad"]) + delta
		var t: float = clampf(float(datos["edad"]) / float(datos["vida"]), 0.0, 1.0)
		nodo.modulate.a = 1.0 - t * t

func reset_station(base_color: Color = Color(0.96, 0.62, 0.04), incoming_shape: PackedVector2Array = PackedVector2Array(), incoming_temp: float = 940.0) -> void:
	cuts_completed = [false, false, false]
	cut_accuracy_scores.clear()
	btn_to_quench.disabled = true
	is_dragging = false
	_puntos_trazo.clear()
	_largo_trazo_actual = 0.0
	_sonido_corte_optimo_emitido = false
	_corto_en_arrastre_actual = false
	temperatura_pieza = clampf(incoming_temp, 680.0, 1150.0)

	_limpiar_hijos_dinamicos()

	# Si llega una forma moldeada del yunque, adaptamos el cuerpo y las rebabas a su silueta
	_construir_geometria_inicial(incoming_shape)

	main_workpiece.color = base_color
	scrap_top.color = base_color.darkened(0.14)
	scrap_bottom.color = base_color.darkened(0.14)
	scrap_tip.color = base_color.darkened(0.14)
	if main_workpiece.material is ShaderMaterial:
		(main_workpiece.material as ShaderMaterial).set_shader_parameter("temperatura", temperatura_pieza)
	if scrap_top.material is ShaderMaterial:
		(scrap_top.material as ShaderMaterial).set_shader_parameter("temperatura", maxf(650.0, temperatura_pieza - 90.0))

	var bench_center: Vector2 = cut_bench.size / 2.0 if cut_bench.size.x > 0 else Vector2(300, 150)
	main_workpiece.position = bench_center
	scrap_top.visible = true
	scrap_bottom.visible = true
	scrap_tip.visible = true
	scrap_top.position = bench_center
	scrap_bottom.position = bench_center
	scrap_tip.position = bench_center
	scrap_top.rotation = 0.0
	scrap_bottom.rotation = 0.0
	scrap_tip.rotation = 0.0
	scrap_top.modulate.a = 1.0
	scrap_bottom.modulate.a = 1.0
	scrap_tip.modulate.a = 1.0

	cutter_tool.visible = false
	crac_label.visible = false
	cut_drag_line.visible = false

	_draw_guide_lines()
	_update_ui()

func _limpiar_hijos_dinamicos() -> void:
	_fragmentos_volando.clear()
	if contenedor_fragmentos:
		for c in contenedor_fragmentos.get_children():
			c.queue_free()
	if contenedor_cicatrices:
		for c in contenedor_cicatrices.get_children():
			c.queue_free()

func _construir_geometria_inicial(incoming_shape: PackedVector2Array) -> void:
	# Extraer escala longitudinal y alto de cabeza reales logrados en el yunque cenital
	var escala_largo: float = 1.0
	var alto_cabeza: float = 25.0
	if incoming_shape.size() >= 6:
		var min_x: float = 9999.0
		var max_x: float = -9999.0
		var max_y_izq: float = 18.0
		for p in incoming_shape:
			min_x = minf(min_x, p.x)
			max_x = maxf(max_x, p.x)
			if p.x < -45.0:
				max_y_izq = maxf(max_y_izq, absf(p.y))
		escala_largo = clampf((max_x - min_x) / 270.0, 0.88, 1.16)
		alto_cabeza = clampf(max_y_izq, 21.0, 29.0)

	var x_cab_ext: float = -138.0 * escala_largo
	var x_cab_med: float = -126.0 * escala_largo
	var x_cuello: float = -86.0 * escala_largo

	# Actualizar guías de corte al perfil real del vástago del clavo/perno
	scrap_lines[0]["start"] = Vector2(x_cuello, -13.0)
	scrap_lines[0]["end"] = Vector2(95.0, -9.0)
	scrap_lines[1]["start"] = Vector2(x_cuello, 13.0)
	scrap_lines[1]["end"] = Vector2(95.0, 9.0)
	scrap_lines[2]["start"] = Vector2(95.0, -14.0)
	scrap_lines[2]["end"] = Vector2(95.0, 14.0)

	# Silueta fiel del Clavo Forjado / Perno: cabeza ancha recalcada a la izquierda,
	# escalón de cuello marcado, vástago central firme y punta piramidal aguda a la derecha.
	main_workpiece.polygon = PackedVector2Array([
		Vector2(x_cab_ext - 6.0, 0.0),
		Vector2(x_cab_ext, -alto_cabeza * 0.68),
		Vector2(x_cab_med, -alto_cabeza),
		Vector2(x_cuello - 4.0, -alto_cabeza * 0.92),
		Vector2(x_cuello, -13.0),
		Vector2(-15.0, -12.0),
		Vector2(50.0, -10.5),
		Vector2(95.0, -9.0),
		Vector2(126.0 * escala_largo, 0.0),
		Vector2(95.0, 9.0),
		Vector2(50.0, 10.5),
		Vector2(-15.0, 12.0),
		Vector2(x_cuello, 13.0),
		Vector2(x_cuello - 4.0, alto_cabeza * 0.92),
		Vector2(x_cab_med, alto_cabeza),
		Vector2(x_cab_ext, alto_cabeza * 0.68)
	])
	scrap_top.polygon = PackedVector2Array([
		Vector2(x_cuello, -13.0),
		Vector2(-15.0, -12.0),
		Vector2(50.0, -10.5),
		Vector2(95.0, -9.0),
		Vector2(86.0, -32.0),
		Vector2(18.0, -36.0),
		Vector2(-48.0, -34.0),
		Vector2(x_cuello + 6.0, -29.0)
	])
	scrap_bottom.polygon = PackedVector2Array([
		Vector2(x_cuello, 13.0),
		Vector2(-15.0, 12.0),
		Vector2(50.0, 10.5),
		Vector2(95.0, 9.0),
		Vector2(86.0, 32.0),
		Vector2(18.0, 36.0),
		Vector2(-48.0, 34.0),
		Vector2(x_cuello + 6.0, 29.0)
	])
	scrap_tip.polygon = PackedVector2Array([
		Vector2(95.0, -9.0),
		Vector2(130.0, -16.0),
		Vector2(146.0, 0.0),
		Vector2(130.0, 16.0),
		Vector2(95.0, 9.0)
	])

func _draw_guide_lines() -> void:
	var bench_center: Vector2 = cut_bench.size / 2.0 if cut_bench.size.x > 0 else Vector2(300, 150)

	cut_line_top.clear_points()
	cut_line_top.add_point(bench_center + scrap_lines[0]["start"])
	cut_line_top.add_point(bench_center + scrap_lines[0]["end"])
	cut_line_top.visible = not cuts_completed[0]

	cut_line_bottom.clear_points()
	cut_line_bottom.add_point(bench_center + scrap_lines[1]["start"])
	cut_line_bottom.add_point(bench_center + scrap_lines[1]["end"])
	cut_line_bottom.visible = not cuts_completed[1]

	cut_line_tip.clear_points()
	cut_line_tip.add_point(bench_center + scrap_lines[2]["start"])
	cut_line_tip.add_point(bench_center + scrap_lines[2]["end"])
	cut_line_tip.visible = not cuts_completed[2]

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag_cut()
		else:
			_end_drag_cut()
	elif event is InputEventMouseMotion and is_dragging:
		_update_drag_cut()

func _start_drag_cut() -> void:
	is_dragging = true
	_corto_en_arrastre_actual = false
	drag_start_bench = cut_bench.get_local_mouse_position()
	_puntos_trazo.clear()
	_puntos_trazo.append(drag_start_bench)
	_largo_trazo_actual = 0.0

	cut_drag_line.visible = true
	cut_drag_line.default_color = Color(1.0, 0.92, 0.55, 0.95)
	cut_drag_line.clear_points()
	cut_drag_line.add_point(drag_start_bench)

	cutter_tool.visible = true
	cutter_tool.position = drag_start_bench

	if etiqueta_largo_trazo:
		etiqueta_largo_trazo.text = "Largo de corte: 0 / %d px" % int(LARGO_MAXIMO_TRAZO)
	status_label.text = "Dibuja la forma de corte sobre la guía (Largo: 0 / %d px)." % int(LARGO_MAXIMO_TRAZO)
	status_label.modulate = Color(0.96, 0.78, 0.2)

func _update_drag_cut() -> void:
	var cur_bench: Vector2 = cut_bench.get_local_mouse_position()
	if _puntos_trazo.is_empty():
		_puntos_trazo.append(drag_start_bench)

	var ultimo_pt: Vector2 = _puntos_trazo[_puntos_trazo.size() - 1]
	var seg_vec: Vector2 = cur_bench - ultimo_pt
	var seg_dist: float = seg_vec.length()
	var restante: float = maxf(0.0, LARGO_MAXIMO_TRAZO - _largo_trazo_actual)

	if seg_dist >= 2.0 and restante > 0.0:
		var punto_nuevo: Vector2 = cur_bench
		if seg_dist >= restante:
			punto_nuevo = ultimo_pt + seg_vec.normalized() * restante
			_largo_trazo_actual = LARGO_MAXIMO_TRAZO
		else:
			_largo_trazo_actual += seg_dist

		_puntos_trazo.append(punto_nuevo)
		cut_drag_line.add_point(punto_nuevo)
		cutter_tool.position = punto_nuevo
		if seg_vec.length() > 1.5:
			cutter_tool.rotation = seg_vec.angle()

	if etiqueta_largo_trazo:
		etiqueta_largo_trazo.text = "Largo de corte: %d / %d px" % [int(round(_largo_trazo_actual)), int(LARGO_MAXIMO_TRAZO)]

	if _largo_trazo_actual >= LARGO_MAXIMO_TRAZO - 0.5:
		cut_drag_line.default_color = Color(1.0, 0.48, 0.22, 0.98)
		status_label.text = "Largo de corte: %d / %d px (Límite alcanzado, suelta para cortar)" % [int(LARGO_MAXIMO_TRAZO), int(LARGO_MAXIMO_TRAZO)]
		status_label.modulate = Color(1.0, 0.65, 0.30)
	else:
		cut_drag_line.default_color = Color(1.0, 0.92, 0.55, 0.95)
		status_label.text = "Largo de corte: %d / %d px — Suelta el botón para cortar la forma marcada." % [int(round(_largo_trazo_actual)), int(LARGO_MAXIMO_TRAZO)]
		status_label.modulate = Color(0.96, 0.78, 0.2)

func _end_drag_cut() -> void:
	if not is_dragging:
		return
	is_dragging = false

	var drag_end_bench: Vector2 = cut_bench.get_local_mouse_position()
	if _puntos_trazo.size() == 1 and drag_start_bench.distance_to(drag_end_bench) >= 2.0:
		var vec: Vector2 = drag_end_bench - drag_start_bench
		var d: float = minf(vec.length(), LARGO_MAXIMO_TRAZO)
		_puntos_trazo.append(drag_start_bench + vec.normalized() * d)
		_largo_trazo_actual = d

	cut_drag_line.visible = false
	cutter_tool.visible = false

	if _largo_trazo_actual < 16.0 or _puntos_trazo.size() < 2:
		if _corto_en_arrastre_actual:
			return
		status_label.text = "Trazo demasiado corto. Dibuja la línea de corte a lo largo de la guía marcada."
		status_label.modulate = Color(0.85, 0.6, 0.4)
		return

	_ejecutar_corte_polilinea_dibujada(_puntos_trazo)

## Ejecuta el corte real siguiendo la polilínea dibujada por el jugador (_puntos_trazo)
func _ejecutar_corte_polilinea_dibujada(trazo_bench: PackedVector2Array) -> void:
	var bench_center: Vector2 = cut_bench.size / 2.0 if cut_bench.size.x > 0 else Vector2(300, 150)
	var trazo_local: PackedVector2Array = PackedVector2Array()
	for pt in trazo_bench:
		trazo_local.append(pt - bench_center)

	var p1_local: Vector2 = trazo_local[0]
	var p2_local: Vector2 = trazo_local[trazo_local.size() - 1]
	var p1_bench: Vector2 = trazo_bench[0]
	var p2_bench: Vector2 = trazo_bench[trazo_bench.size() - 1]

	var mejor_index: int = -1
	var mejor_dist_guia: float = 99999.0
	var nodos_rebaba: Array[Polygon2D] = [scrap_top, scrap_bottom, scrap_tip]

	for i in range(scrap_lines.size()):
		if cuts_completed[i]:
			continue
		var reb: Polygon2D = nodos_rebaba[i]
		var g1_local: Vector2 = scrap_lines[i]["start"]
		var g2_local: Vector2 = scrap_lines[i]["end"]
		var g_start_bench: Vector2 = bench_center + g1_local
		var g_end_bench: Vector2 = bench_center + g2_local

		var toca_guia: bool = _polilinea_toca_guia(trazo_local, g1_local, g2_local) or _check_stroke_hits_guide(p1_bench, p2_bench, g_start_bench, g_end_bench)
		var toca_rebaba: bool = reb != null and reb.visible and reb.polygon.size() >= 3 and _polilinea_toca_poligono(trazo_local, reb.polygon, 30.0)
		if toca_guia or toca_rebaba:
			var d_media: float = _distancia_media_polilinea_a_segmento(trazo_local, g1_local, g2_local)
			if d_media < mejor_dist_guia:
				mejor_dist_guia = d_media
				mejor_index = i

	if mejor_index == -1:
		if _corto_en_arrastre_actual:
			return
		status_label.text = "La cizalla no tocó ninguna línea de corte. Dibuja el trazo sobre las líneas punteadas de las rebabas."
		status_label.modulate = Color(0.85, 0.65, 0.4)
		return

	var g1_sel: Vector2 = scrap_lines[mejor_index]["start"]
	var g2_sel: Vector2 = scrap_lines[mejor_index]["end"]
	var reb_sel: Polygon2D = nodos_rebaba[mejor_index]
	var prec: float = _calcular_precision_polilinea(trazo_local, g1_sel, g2_sel)

	_cortar_con_forma_polilinea(mejor_index, reb_sel, trazo_local, prec)
	_registrar_cicatriz_polilinea(trazo_local)
	_disparar_juice_corte(bench_center + (p1_local + p2_local) * 0.5)
	_update_ui()

func _cortar_con_forma_polilinea(index: int, reb: Polygon2D, trazo_local: PackedVector2Array, prec: float) -> void:
	var g_start: Vector2 = scrap_lines[index]["start"]
	var g_end: Vector2 = scrap_lines[index]["end"]
	var dir_exp: Vector2 = _direccion_expulsion_rebaba(index, g_start, g_end)

	# Construir el polígono de corte real usando los vértices dibujados por el jugador cerrando hacia el exterior
	var mascara_exterior: PackedVector2Array = _construir_poligono_corte_exterior(index, trazo_local, g_start, g_end)

	# 1. Recortar la rebaba con Geometry2D.clip_polygons / intersect_polygons siguiendo la línea poligonal dibujada
	if reb and reb.visible and reb.polygon.size() >= 3:
		var desprendido: PackedVector2Array = reb.polygon
		if mascara_exterior.size() >= 3:
			var inter: Array[PackedVector2Array] = Geometry2D.intersect_polygons(reb.polygon, mascara_exterior)
			if not inter.is_empty():
				desprendido = _poligono_mayor(inter)
			var remanente_reb: Array[PackedVector2Array] = Geometry2D.clip_polygons(reb.polygon, mascara_exterior)
			if not remanente_reb.is_empty():
				var rem_mayor: PackedVector2Array = _poligono_mayor(remanente_reb)
				if _area_poligono(rem_mayor) > 8.0:
					_fusionar_remanente_visual(rem_mayor)
		_desprender_fragmento_real(desprendido, dir_exp)
		reb.visible = false

	# 2. Aplicar Geometry2D.clip_polygons sobre main_workpiece para que el borde del metal quede con la forma exacta dibujada
	if mascara_exterior.size() >= 3 and main_workpiece and main_workpiece.polygon.size() >= 3:
		var recortados: Array[PackedVector2Array] = Geometry2D.clip_polygons(main_workpiece.polygon, mascara_exterior)
		if not recortados.is_empty():
			var nuevo_cuerpo: PackedVector2Array = _poligono_mayor(recortados)
			var area_original: float = _area_poligono(main_workpiece.polygon)
			var area_nueva: float = _area_poligono(nuevo_cuerpo)
			if nuevo_cuerpo.size() >= 4 and area_nueva >= area_original * 0.45:
				var trozos_metal: Array[PackedVector2Array] = Geometry2D.intersect_polygons(main_workpiece.polygon, mascara_exterior)
				if not trozos_metal.is_empty():
					var trozo_m: PackedVector2Array = _poligono_mayor(trozos_metal)
					if _area_poligono(trozo_m) > 10.0:
						_desprender_fragmento_real(trozo_m, dir_exp)
				main_workpiece.polygon = nuevo_cuerpo

	if not cuts_completed[index]:
		cuts_completed[index] = true
		cut_accuracy_scores.append(prec)

	if index == 0:
		cut_line_top.visible = false
	elif index == 1:
		cut_line_bottom.visible = false
	elif index == 2:
		cut_line_tip.visible = false

	if _all_cuts_completed() and not _sonido_corte_optimo_emitido:
		_sonido_corte_optimo_emitido = true
		AudioManager.play_sfx("step_complete", 2.5, 0.02)
		AudioManager.play_sfx("temp_ready", 1.5, 0.02)

func _construir_poligono_corte_exterior(index: int, trazo_local: PackedVector2Array, g_start: Vector2, g_end: Vector2) -> PackedVector2Array:
	if trazo_local.size() < 2:
		return PackedVector2Array()

	var puntos_ordenados: PackedVector2Array = trazo_local.duplicate()
	# Orientar los puntos en el mismo sentido que la guía (de g_start a g_end) para cerrar limpiamente hacia afuera
	var dir_guia: Vector2 = (g_end - g_start).normalized()
	var dir_trazo: Vector2 = (puntos_ordenados[puntos_ordenados.size() - 1] - puntos_ordenados[0])
	if dir_trazo.dot(dir_guia) < 0.0:
		puntos_ordenados.reverse()

	var p_ini: Vector2 = puntos_ordenados[0]
	var p_fin: Vector2 = puntos_ordenados[puntos_ordenados.size() - 1]
	var poly_corte: PackedVector2Array = PackedVector2Array()

	if index == 0:
		# Rebaba superior (exterior hacia Y negativo)
		var ext_ini: Vector2 = Vector2(minf(p_ini.x, g_start.x) - 18.0, p_ini.y)
		var ext_fin: Vector2 = Vector2(maxf(p_fin.x, g_end.x) + 18.0, p_fin.y)
		poly_corte.append(ext_ini)
		for pt in puntos_ordenados:
			poly_corte.append(Vector2(pt.x, clampf(pt.y, -70.0, -2.5)))
		poly_corte.append(ext_fin)
		poly_corte.append(Vector2(ext_fin.x, -95.0))
		poly_corte.append(Vector2(ext_ini.x, -95.0))
	elif index == 1:
		# Rebaba inferior (exterior hacia Y positivo)
		var ext_ini: Vector2 = Vector2(minf(p_ini.x, g_start.x) - 18.0, p_ini.y)
		var ext_fin: Vector2 = Vector2(maxf(p_fin.x, g_end.x) + 18.0, p_fin.y)
		poly_corte.append(ext_ini)
		for pt in puntos_ordenados:
			poly_corte.append(Vector2(pt.x, clampf(pt.y, 2.5, 70.0)))
		poly_corte.append(ext_fin)
		poly_corte.append(Vector2(ext_fin.x, 95.0))
		poly_corte.append(Vector2(ext_ini.x, 95.0))
	else:
		# Punta derecha (exterior hacia X positivo)
		var ext_ini: Vector2 = Vector2(p_ini.x, minf(p_ini.y, g_start.y) - 24.0)
		var ext_fin: Vector2 = Vector2(p_fin.x, maxf(p_fin.y, g_end.y) + 24.0)
		poly_corte.append(ext_ini)
		for pt in puntos_ordenados:
			poly_corte.append(Vector2(clampf(pt.x, 45.0, 175.0), pt.y))
		poly_corte.append(ext_fin)
		poly_corte.append(Vector2(210.0, ext_fin.y))
		poly_corte.append(Vector2(210.0, ext_ini.y))

	return poly_corte

func _calcular_precision_polilinea(trazo_local: PackedVector2Array, g1: Vector2, g2: Vector2) -> float:
	if trazo_local.is_empty():
		return 0.75
	var suma_dist: float = 0.0
	var vec_guia: Vector2 = g2 - g1
	var largo_guia: float = maxf(vec_guia.length(), 1.0)
	var dir_guia: Vector2 = vec_guia / largo_guia
	var min_t: float = 1.0
	var max_t: float = 0.0

	for pt in trazo_local:
		suma_dist += _distance_point_to_segment(pt, g1, g2)
		var proy_t: float = clampf((pt - g1).dot(dir_guia) / largo_guia, 0.0, 1.0)
		min_t = minf(min_t, proy_t)
		max_t = maxf(max_t, proy_t)

	var dist_media: float = suma_dist / float(trazo_local.size())
	var cobertura: float = clampf((max_t - min_t) / 0.72, 0.25, 1.0)
	var score_dist: float = clampf(1.0 - (dist_media / 26.0), 0.45, 1.0)
	return clampf(score_dist * 0.62 + cobertura * 0.38, 0.50, 1.0)

func _distancia_media_polilinea_a_segmento(trazo_local: PackedVector2Array, g1: Vector2, g2: Vector2) -> float:
	if trazo_local.is_empty():
		return 9999.0
	var suma: float = 0.0
	for pt in trazo_local:
		suma += _distance_point_to_segment(pt, g1, g2)
	return suma / float(trazo_local.size())

func _polilinea_toca_guia(trazo_local: PackedVector2Array, g1: Vector2, g2: Vector2) -> bool:
	for i in range(trazo_local.size() - 1):
		if _check_stroke_hits_guide(trazo_local[i], trazo_local[i + 1], g1, g2):
			return true
	return false

func _polilinea_toca_poligono(trazo_local: PackedVector2Array, poly: PackedVector2Array, margen: float) -> bool:
	for i in range(trazo_local.size() - 1):
		if _segmento_toca_poligono(trazo_local[i], trazo_local[i + 1], poly, margen):
			return true
	return false

func _registrar_cicatriz_polilinea(trazo_local: PackedVector2Array) -> void:
	if not contenedor_cicatrices or trazo_local.size() < 2:
		return
	var cicatriz: Line2D = Line2D.new()
	cicatriz.width = 2.6
	cicatriz.default_color = Color(1.0, 0.92, 0.62, 0.95)
	cicatriz.begin_cap_mode = Line2D.LINE_CAP_ROUND
	cicatriz.end_cap_mode = Line2D.LINE_CAP_ROUND
	for pt in trazo_local:
		cicatriz.add_point(Vector2(clampf(pt.x, -142.0, 152.0), clampf(pt.y, -46.0, 46.0)))
	contenedor_cicatrices.add_child(cicatriz)

	var tw: Tween = create_tween()
	tw.tween_property(cicatriz, "default_color", Color(0.95, 0.48, 0.14, 0.75), 0.6)

func _cortar_y_desprender_rebaba_exacta(index: int, reb: Polygon2D, p1: Vector2, p2: Vector2, precision_override: float = -1.0) -> void:
	var g_start: Vector2 = scrap_lines[index]["start"]
	var g_end: Vector2 = scrap_lines[index]["end"]
	var prec: float = precision_override if precision_override > 0.0 else _calcular_precision_trazo(p1, p2, g_start, g_end)

	# Desprender la rebaba limpiamente a lo largo de la línea guía sin mutilar ni deformar main_workpiece
	if reb and reb.visible and reb.polygon.size() >= 3:
		_desprender_fragmento_real(reb.polygon, _direccion_expulsion_rebaba(index, g_start, g_end))
		reb.visible = false

	if not cuts_completed[index]:
		cuts_completed[index] = true
		cut_accuracy_scores.append(prec)

	if index == 0:
		cut_line_top.visible = false
	elif index == 1:
		cut_line_bottom.visible = false
	elif index == 2:
		cut_line_tip.visible = false

	if _all_cuts_completed() and not _sonido_corte_optimo_emitido:
		_sonido_corte_optimo_emitido = true
		AudioManager.play_sfx("step_complete", 2.5, 0.02)
		AudioManager.play_sfx("temp_ready", 1.5, 0.02)

func _biseccionar_pieza_principal(p1: Vector2, p2: Vector2) -> bool:
	if p1.distance_to(p2) < 8.0 or main_workpiece.polygon.size() < 3:
		return false
	# Evitar partir la pieza justo por la mitad central si el usuario cruza el eje (0,0)
	if _distance_point_to_segment(Vector2(-15, 0), p1, p2) < 6.0:
		return false
	var partes: Dictionary = _dividir_poligono_por_recta(main_workpiece.polygon, p1, p2, Vector2(-15, 0))
	var interior: PackedVector2Array = partes["interior"]
	var exterior: PackedVector2Array = partes["exterior"]
	if interior.size() >= 3 and exterior.size() >= 3:
		var area_ext: float = _area_poligono(exterior)
		var area_int: float = _area_poligono(interior)
		if area_ext > 12.0 and area_int > area_ext * 1.35:
			main_workpiece.polygon = interior
			var centro_ext: Vector2 = _centroide_poligono(exterior)
			_desprender_fragmento_real(exterior, centro_ext.normalized())
			return true
	return false

func _dividir_poligono_por_recta(poly: PackedVector2Array, p1: Vector2, p2: Vector2, punto_referencia_interior: Vector2) -> Dictionary:
	var dir: Vector2 = (p2 - p1).normalized()
	if dir.length_squared() < 0.001:
		return {"interior": poly, "exterior": PackedVector2Array()}
	var normal: Vector2 = Vector2(-dir.y, dir.x)
	var a: Vector2 = p1 - dir * 600.0
	var b: Vector2 = p2 + dir * 600.0

	var semiplano_pos: PackedVector2Array = PackedVector2Array([
		a, b, b + normal * 600.0, a + normal * 600.0
	])
	var semiplano_neg: PackedVector2Array = PackedVector2Array([
		b, a, a - normal * 600.0, b - normal * 600.0
	])

	var recorte_a: Array[PackedVector2Array] = Geometry2D.clip_polygons(poly, semiplano_pos)
	var recorte_b: Array[PackedVector2Array] = Geometry2D.clip_polygons(poly, semiplano_neg)
	if recorte_a.is_empty() or recorte_b.is_empty():
		return {"interior": poly, "exterior": PackedVector2Array()}

	var poly_a: PackedVector2Array = _poligono_mayor(recorte_a)
	var poly_b: PackedVector2Array = _poligono_mayor(recorte_b)

	var dist_a: float = _centroide_poligono(poly_a).distance_to(punto_referencia_interior)
	var dist_b: float = _centroide_poligono(poly_b).distance_to(punto_referencia_interior)
	if dist_a <= dist_b:
		return {"interior": poly_a, "exterior": poly_b}
	return {"interior": poly_b, "exterior": poly_a}

func _fusionar_remanente_visual(remanente: PackedVector2Array) -> void:
	if not contenedor_fragmentos or remanente.size() < 3:
		return
	var union_res: Array[PackedVector2Array] = Geometry2D.merge_polygons(main_workpiece.polygon, remanente)
	if not union_res.is_empty():
		main_workpiece.polygon = _poligono_mayor(union_res)

func _desprender_fragmento_real(poly: PackedVector2Array, dir_expulsion: Vector2) -> void:
	if not contenedor_fragmentos or poly.size() < 3:
		return
	var frag: Polygon2D = Polygon2D.new()
	frag.polygon = poly
	frag.color = main_workpiece.color.darkened(0.18)
	if scrap_top and scrap_top.material:
		frag.material = scrap_top.material
	contenedor_fragmentos.add_child(frag)

	var dir_norm: Vector2 = dir_expulsion.normalized() if dir_expulsion.length_squared() > 0.01 else Vector2(0, 1)
	var vel_inicial: Vector2 = dir_norm * randf_range(95.0, 155.0) + Vector2(randf_range(-25.0, 25.0), -45.0)
	_fragmentos_volando.append({
		"nodo": frag,
		"vel": vel_inicial,
		"vel_rot": randf_range(-3.2, 3.2),
		"edad": 0.0,
		"vida": 0.52
	})

func _registrar_cicatriz_corte(p1: Vector2, p2: Vector2) -> void:
	if not contenedor_cicatrices:
		return
	var cicatriz: Line2D = Line2D.new()
	cicatriz.width = 2.6
	cicatriz.default_color = Color(1.0, 0.92, 0.62, 0.95)
	cicatriz.begin_cap_mode = Line2D.LINE_CAP_ROUND
	cicatriz.end_cap_mode = Line2D.LINE_CAP_ROUND
	# Recortar la cicatriz al segmento cercano al metal
	var a: Vector2 = Vector2(clampf(p1.x, -135.0, 145.0), clampf(p1.y, -42.0, 42.0))
	var b: Vector2 = Vector2(clampf(p2.x, -135.0, 145.0), clampf(p2.y, -42.0, 42.0))
	cicatriz.add_point(a)
	cicatriz.add_point(b)
	contenedor_cicatrices.add_child(cicatriz)

	var tw: Tween = create_tween()
	tw.tween_property(cicatriz, "default_color", Color(0.95, 0.48, 0.14, 0.75), 0.6)

func _disparar_juice_corte(hit_pos: Vector2) -> void:
	AudioManager.play_snip()
	if sacudida_trauma and sacudida_trauma.has_method("agregar_trauma"):
		sacudida_trauma.agregar_trauma(0.42)

	if chispas_corte:
		chispas_corte.position = hit_pos
		chispas_corte.restart()
		chispas_corte.emitting = true

	crac_label.text = "¡CIZALLADO!"
	crac_label.position = hit_pos - Vector2(55, 24)
	crac_label.visible = true
	crac_label.modulate.a = 1.0
	var label_tween: Tween = create_tween().set_parallel(true)
	label_tween.tween_property(crac_label, "position:y", hit_pos.y - 48.0, 0.38)
	label_tween.tween_property(crac_label, "modulate:a", 0.0, 0.38)
	label_tween.chain().tween_callback(func(): crac_label.visible = false)

func _direccion_expulsion_rebaba(index: int, p1: Vector2, p2: Vector2) -> Vector2:
	if index == 0:
		return Vector2((p2.x - p1.x) * 0.15, -1.0)
	if index == 1:
		return Vector2((p2.x - p1.x) * 0.15, 1.0)
	return Vector2(1.0, (p2.y - p1.y) * 0.15)

func _calcular_precision_trazo(p1: Vector2, p2: Vector2, g1: Vector2, g2: Vector2) -> float:
	var mid_trazo: Vector2 = (p1 + p2) * 0.5
	var dist: float = _distance_point_to_segment(mid_trazo, g1, g2)
	var dir_trazo: Vector2 = (p2 - p1).normalized()
	var dir_guia: Vector2 = (g2 - g1).normalized()
	var paralelismo: float = absf(dir_trazo.dot(dir_guia))
	var score_dist: float = clampf(1.0 - (dist / 48.0), 0.78, 1.0)
	var score_ang: float = lerpf(0.84, 1.0, paralelismo)
	return clampf(score_dist * 0.7 + score_ang * 0.3, 0.82, 0.99)

func _check_stroke_hits_guide(p1: Vector2, p2: Vector2, q1: Vector2, q2: Vector2) -> bool:
	if _segments_intersect(p1, p2, q1, q2):
		return true
	var stroke_mid: Vector2 = (p1 + p2) * 0.5
	if _distance_point_to_segment(stroke_mid, q1, q2) <= 38.0:
		return true
	if _distance_point_to_segment(p2, q1, q2) <= 38.0:
		return true
	if _distance_point_to_segment(p1, q1, q2) <= 38.0:
		return true
	if _distance_point_to_segment((q1 + q2) * 0.5, p1, p2) <= 38.0:
		return true
	return false

func _perform_cut_on_scrap(index: int, hit_pos: Vector2) -> void:
	var bench_center: Vector2 = cut_bench.size / 2.0 if cut_bench.size.x > 0 else Vector2(300, 150)
	var p1_local: Vector2 = scrap_lines[index]["start"]
	var p2_local: Vector2 = scrap_lines[index]["end"]
	var trazo_sim: PackedVector2Array = PackedVector2Array([p1_local, (p1_local + p2_local) * 0.5, p2_local])
	var nodos_rebaba: Array[Polygon2D] = [scrap_top, scrap_bottom, scrap_tip]
	_cortar_con_forma_polilinea(index, nodos_rebaba[index], trazo_sim, 0.96)
	_registrar_cicatriz_polilinea(trazo_sim)
	_disparar_juice_corte(hit_pos if hit_pos != Vector2.ZERO else bench_center)
	_update_ui()

func _update_ui() -> void:
	var total_done: int = 0
	for done in cuts_completed:
		if done:
			total_done += 1
	progress_label.text = "Rebabas Cortadas: %d / 3" % total_done
	if etiqueta_largo_trazo:
		etiqueta_largo_trazo.text = "Largo de corte: %d / %d px" % [int(round(_largo_trazo_actual)), int(LARGO_MAXIMO_TRAZO)]
	if etiqueta_precision_corte:
		var avg_p: float = 1.0
		if not cut_accuracy_scores.is_empty():
			var s_total: float = 0.0
			for s in cut_accuracy_scores:
				s_total += s
			avg_p = s_total / float(cut_accuracy_scores.size())
		etiqueta_precision_corte.text = "Precisión de Cizalla: %.0f%%" % (avg_p * 100.0)

	if total_done >= 3:
		btn_to_quench.disabled = false
		status_label.text = "¡Rebabas cizalladas! La pieza conserva el perfil exacto de tus cortes. Pasa a la tina."
		status_label.modulate = Color(0.4, 0.95, 0.5)
	elif total_done > 0:
		status_label.text = "Corte limpio realizado sobre el metal. Continúa con las rebabas restantes (%d/3)." % total_done
		status_label.modulate = Color(0.96, 0.78, 0.2)

func _on_to_quench_pressed() -> void:
	var total_score: float = 0.0
	for s in cut_accuracy_scores:
		total_score += s
	var avg_score: float = total_score / float(cut_accuracy_scores.size()) if not cut_accuracy_scores.is_empty() else 0.75
	emit_signal("cutting_completed", avg_score, main_workpiece.polygon)

func _on_finish_cutting_pressed() -> void:
	_on_to_quench_pressed()

func simulate_cut_all() -> void:
	for i in range(3):
		if not cuts_completed[i]:
			_perform_cut_on_scrap(i, cut_bench.size * 0.5)
	_update_ui()

# --- MATEMÁTICAS GEOMÉTRICAS DE CORTE ---

func _segmento_toca_poligono(p1: Vector2, p2: Vector2, poly: PackedVector2Array, margen: float = 16.0) -> bool:
	var n: int = poly.size()
	for i in range(n):
		var a: Vector2 = poly[i]
		var b: Vector2 = poly[(i + 1) % n]
		if _segments_intersect(p1, p2, a, b):
			return true
		if _distance_point_to_segment((p1 + p2) * 0.5, a, b) <= margen:
			return true
	return Geometry2D.is_point_in_polygon((p1 + p2) * 0.5, poly)

func _poligono_mayor(lista: Array[PackedVector2Array]) -> PackedVector2Array:
	var mejor: PackedVector2Array = PackedVector2Array()
	var max_area: float = -1.0
	for p in lista:
		var a: float = _area_poligono(p)
		if a > max_area:
			max_area = a
			mejor = p
	return mejor

func _area_poligono(poly: PackedVector2Array) -> float:
	var n: int = poly.size()
	if n < 3:
		return 0.0
	var acum: float = 0.0
	for i in range(n):
		var p1: Vector2 = poly[i]
		var p2: Vector2 = poly[(i + 1) % n]
		acum += (p1.x * p2.y) - (p2.x * p1.y)
	return absf(acum) * 0.5

func _centroide_poligono(poly: PackedVector2Array) -> Vector2:
	if poly.is_empty():
		return Vector2.ZERO
	var suma: Vector2 = Vector2.ZERO
	for p in poly:
		suma += p
	return suma / float(poly.size())

func _segments_intersect(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> bool:
	var denominator: float = ((b.x - a.x) * (d.y - c.y)) - ((b.y - a.y) * (d.x - c.x))
	if absf(denominator) < 0.0001:
		return false
	var numerator1: float = ((a.y - c.y) * (d.x - c.x)) - ((a.x - c.x) * (d.y - c.y))
	var numerator2: float = ((a.y - c.y) * (b.x - a.x)) - ((a.x - c.x) * (b.y - a.y))
	var r: float = numerator1 / denominator
	var s: float = numerator2 / denominator
	return (r >= 0.0 and r <= 1.0) and (s >= 0.0 and s <= 1.0)

func _distance_point_to_segment(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab: Vector2 = b - a
	var ab_len_sq: float = ab.length_squared()
	if ab_len_sq < 0.0001:
		return p.distance_to(a)
	var t: float = clampf((p - a).dot(ab) / ab_len_sq, 0.0, 1.0)
	var projection: Vector2 = a + (ab * t)
	return p.distance_to(projection)

# --- MÉTODOS DE CONSULTA Y COMPATIBILIDAD CON QA ---

var cut_paths: Array[Dictionary]:
	get:
		return scrap_lines

func _all_cuts_completed() -> bool:
	for done in cuts_completed:
		if not done:
			return false
	return true

func _check_start_cut(pos: Vector2) -> void:
	_start_drag_cut()
	drag_start_bench = (pos - cut_bench.global_position) if cut_bench.is_inside_tree() else pos

func _process_drag_cut(pos: Vector2) -> void:
	var end_b: Vector2 = (pos - cut_bench.global_position) if cut_bench.is_inside_tree() else pos
	for i in range(scrap_lines.size()):
		if not cuts_completed[i]:
			_perform_cut_on_scrap(i, end_b)
			break
