# AnvilTopDownStation.gd
# Vista cenital de la mesa del yunque con Martillo Físico Móvil (Area2D Hitbox),
# fuerza proporcional a la velocidad de impacto, estiramiento longitudinal real y
# convergente hacia la silueta del objeto solicitado (/herrero + /game_feel).
extends Control

signal anvil_shaping_completed(score: float, final_shape: PackedVector2Array)
signal recalentar_solicitado(temperatura_actual: float)

const HAMMER_EFFECT_SCENE: PackedScene = preload("res://src/scenes/workshop/HammerEffect.tscn")
const EscalaTermica = preload("res://src/components/EscalaTermicaAcero.gd")

# Nodos en Español
@onready var luz_brasas: TextureRect = $LuzBrasas
@onready var area_impacto: Control = $SuperficieYunque/AreaImpacto
@onready var resplandor_calor: TextureRect = $SuperficieYunque/ResplandorCalor
@onready var poligono_metal: Polygon2D = $SuperficieYunque/LingoteDeformable
@onready var area_colision_metal: Area2D = $SuperficieYunque/AreaColisionMetal
@onready var poligono_colision_metal: CollisionPolygon2D = $SuperficieYunque/AreaColisionMetal/PoligonoColisionMetal
@onready var linea_guia: Line2D = $SuperficieYunque/GuiaSilueta
@onready var destello_impacto: TextureRect = $SuperficieYunque/DestelloImpacto
@onready var chispas_forja: CPUParticles2D = $SuperficieYunque/ChispasForja
@onready var martillo_forjador: Node2D = $SuperficieYunque/MartilloForjador
@onready var sprite_martillo: Sprite2D = $SuperficieYunque/MartilloForjador/SpriteMartillo
@onready var estela_velocidad: Line2D = $SuperficieYunque/MartilloForjador/EstelaVelocidad
@onready var area_hitbox_martillo: Area2D = $SuperficieYunque/MartilloForjador/AreaHitboxMartillo
@onready var etiqueta_agarre_martillo: Label = $SuperficieYunque/MartilloForjador/EtiquetaAgarreMartillo
@onready var sacudida_trauma: Node = $SacudidaTrauma
@onready var etiqueta_estado: Label = $EtiquetaEstado
@onready var etiqueta_golpes: Label = $BarraSuperior/EtiquetaGolpes
@onready var etiqueta_temperatura_pieza: Label = $BarraSuperior/EtiquetaTemperaturaPieza
@onready var etiqueta_precision: Label = $BarraSuperior/EtiquetaPrecision
@onready var boton_volver_a_fragua: Button = $BotonVolverAFragua
@onready var boton_pasar_a_corte: Button = $BotonPasarACorte

# Alias de compatibilidad hacia atrás
var hit_area: Control:
	get: return area_impacto
var metal_polygon: Polygon2D:
	get: return poligono_metal
var guide_line: Line2D:
	get: return linea_guia
var status_label: Label:
	get: return etiqueta_estado
var strikes_label: Label:
	get: return etiqueta_golpes
var accuracy_label: Label:
	get: return etiqueta_precision
var btn_finish_anvil: Button:
	get: return boton_pasar_a_corte
var btn_reheat_forge: Button:
	get: return boton_volver_a_fragua

const NUM_SLICES: int = 24
const BAR_HALF_WIDTH: float = 140.0 # Semilargo objetivo de la silueta (-140 a +140)
const INITIAL_HALF_WIDTH: float = 104.0 # El lingote sale más corto y macizo de la fragua (-104 a +104)
const INITIAL_THICKNESS: float = 20.0 # Grosor inicial compacto (-10 a +10)
const DEFORMATION_RADIUS: float = 54.0 # Radio de influencia longitudinal de cada martillazo
const DEFORMATION_AMOUNT: float = 4.6 # Expansión transversal base
const STRETCH_LONGITUDINAL: float = 7.8 # Estiramiento longitudinal (eje X) por impacto

# Cinemática del Martillo Móvil con Hitbox (/game_feel)
const POSICION_REPOSO_MARTILLO: Vector2 = Vector2(465.0, 62.0)
const RADIO_AGARRE_MARTILLO: float = 145.0 # Radio para tomar el martillo por su cabeza o mango
const VELOCIDAD_MINIMA_GOLPE: float = 75.0 # px/s mínimos para registrar un impacto al chocar la hitbox
const VELOCIDAD_IMPACTO_BASE: float = 520.0 # px/s que equivale a fuerza estándar (1.0x)
const COOLDOWN_ENTRE_IMPACTOS: float = 0.14 # Evita rebotes múltiples en el mismo golpe

# Termodinámica de enfriamiento en el yunque (/herrero)
const TEMP_INICIAL_DEFECTO: float = 1085.0
const ENFRIAMIENTO_POR_SEGUNDO: float = 22.0
const ENFRIAMIENTO_POR_GOLPE: float = 4.0
const PENALIZACION_GOLPE_TIBIO: float = 0.04
const PENALIZACION_GOLPE_FRIO: float = 0.08

# Arrays de coordenadas X y alturas superior/inferior en cada tajada
var slice_x: Array[float] = []
var target_x: Array[float] = []
var upper_offsets: Array[float] = []
var lower_offsets: Array[float] = []
var target_upper: Array[float] = []
var target_lower: Array[float] = []

var strikes_count: int = 0
const MIN_STRIKES: int = 5
const MAX_STRIKES: int = 15
var strike_history_x: Array[float] = []

var temperatura_pieza: float = TEMP_INICIAL_DEFECTO
var penalizacion_frio: float = 0.0
var golpes_en_frio: int = 0
var metal_temperature_color: Color = Color(0.96, 0.62, 0.04)
var _tiempo_brasas: float = 0.0
var nombre_objeto_solicitado: String = "Clavo Forjado de Compuerta"

# Estado del Martillo Físico Único
var _arrastrando_martillo: bool = false
var _offset_agarre_martillo: Vector2 = Vector2.ZERO
var _pos_previa_martillo: Vector2 = POSICION_REPOSO_MARTILLO
var velocidad_martillo: Vector2 = Vector2.ZERO
var rapidez_martillo: float = 0.0
var ultimo_factor_velocidad: float = 1.0
var _cooldown_impacto: float = 0.0
var _estaba_dentro_metal: bool = false
var _ya_golpeo_en_esta_entrada: bool = false

func _ready() -> void:
	hit_area.gui_input.connect(_on_hit_area_gui_input)
	btn_finish_anvil.pressed.connect(_on_finish_pressed)
	if boton_volver_a_fragua:
		boton_volver_a_fragua.pressed.connect(_on_reheat_pressed)
	if area_hitbox_martillo:
		area_hitbox_martillo.area_entered.connect(_on_hitbox_martillo_area_entered)
	reset_station()

func configurar_molde_encargo(nombre_item: String) -> void:
	if not nombre_item.is_empty():
		nombre_objeto_solicitado = nombre_item
	_construir_silueta_objetivo()
	_draw_target_guide()

func _process(delta: float) -> void:
	if not visible or not is_visible_in_tree():
		return
	_tiempo_brasas += delta
	if _cooldown_impacto > 0.0:
		_cooldown_impacto = maxf(0.0, _cooldown_impacto - delta)

	if luz_brasas:
		var pulso: float = 0.86 + 0.14 * sin(_tiempo_brasas * 2.1)
		luz_brasas.modulate.a = pulso

	# Actualizar cinemática y colisión continua del Martillo Móvil
	if martillo_forjador and delta > 0.0001:
		var vel_instantanea: Vector2 = (martillo_forjador.position - _pos_previa_martillo) / delta
		velocidad_martillo = velocidad_martillo.lerp(vel_instantanea, 0.55)
		rapidez_martillo = velocidad_martillo.length()
		_pos_previa_martillo = martillo_forjador.position
		_actualizar_visual_martillo()
		if _arrastrando_martillo:
			_verificar_colision_continua_martillo()

	if temperatura_pieza > EscalaTermica.TEMP_AMBIENTE:
		temperatura_pieza = maxf(
			EscalaTermica.TEMP_AMBIENTE,
			temperatura_pieza - ENFRIAMIENTO_POR_SEGUNDO * delta
		)
		_sincronizar_aspecto_termico()
		_update_ui()

func _actualizar_visual_martillo() -> void:
	if not martillo_forjador:
		return
	if sprite_martillo:
		var inclinacion: float = clampf(velocidad_martillo.y * 0.0006 - velocidad_martillo.x * 0.0003, -0.75, 0.45)
		sprite_martillo.rotation = lerpf(sprite_martillo.rotation, -0.35 + inclinacion, 0.35)
	if estela_velocidad:
		if _arrastrando_martillo and rapidez_martillo > 140.0:
			estela_velocidad.visible = true
			estela_velocidad.clear_points()
			estela_velocidad.add_point(Vector2.ZERO)
			var cola: Vector2 = -velocidad_martillo.normalized() * clampf(rapidez_martillo * 0.06, 12.0, 58.0)
			estela_velocidad.add_point(cola)
			var t_vel: float = clampf(rapidez_martillo / 950.0, 0.0, 1.0)
			estela_velocidad.default_color = Color(0.95, 0.85, 0.45, 0.35).lerp(Color(1.0, 0.48, 0.14, 0.85), t_vel)
		else:
			estela_velocidad.visible = false

func _martillo_toca_metal() -> bool:
	if not martillo_forjador or not metal_polygon or metal_polygon.polygon.size() < 3:
		return false
	var pos_rel_metal: Vector2 = martillo_forjador.position - metal_polygon.position
	if Geometry2D.is_point_in_polygon(pos_rel_metal, metal_polygon.polygon):
		return true
	# Considerar el radio de la cabeza del martillo (16px)
	for offset_pt in [Vector2(0, 14), Vector2(0, -14), Vector2(-14, 0), Vector2(14, 0)]:
		if Geometry2D.is_point_in_polygon(pos_rel_metal + offset_pt, metal_polygon.polygon):
			return true
	return false

func _verificar_colision_continua_martillo() -> void:
	if not _arrastrando_martillo or not martillo_forjador or not metal_polygon or metal_polygon.polygon.size() < 3:
		return
	var toca_metal: bool = _martillo_toca_metal()

	if toca_metal:
		if not _estaba_dentro_metal and not _ya_golpeo_en_esta_entrada and _cooldown_impacto <= 0.0 and rapidez_martillo >= VELOCIDAD_MINIMA_GOLPE:
			_estaba_dentro_metal = true
			_ya_golpeo_en_esta_entrada = true
			_cooldown_impacto = COOLDOWN_ENTRE_IMPACTOS
			var factor_vel: float = calcular_factor_fuerza_por_velocidad(rapidez_martillo)
			_strike_at_position(martillo_forjador.position, factor_vel)
		else:
			_estaba_dentro_metal = true
	else:
		_estaba_dentro_metal = false
		_ya_golpeo_en_esta_entrada = false

func _on_hitbox_martillo_area_entered(area: Area2D) -> void:
	if area == area_colision_metal and _arrastrando_martillo and not _estaba_dentro_metal and not _ya_golpeo_en_esta_entrada and _cooldown_impacto <= 0.0:
		var vel_efectiva: float = maxf(rapidez_martillo, 180.0)
		if vel_efectiva >= VELOCIDAD_MINIMA_GOLPE:
			_estaba_dentro_metal = true
			_ya_golpeo_en_esta_entrada = true
			_cooldown_impacto = COOLDOWN_ENTRE_IMPACTOS
			var factor_vel: float = calcular_factor_fuerza_por_velocidad(vel_efectiva)
			_strike_at_position(martillo_forjador.position, factor_vel)

func calcular_factor_fuerza_por_velocidad(rapidez_px_s: float) -> float:
	return clampf(rapidez_px_s / VELOCIDAD_IMPACTO_BASE, 0.22, 1.85)

## Permite simular o ejecutar un impacto del MartilloForjador a una velocidad específica (px/s)
func simular_golpe_martillo_con_velocidad(pos_objetivo: Vector2, rapidez_px_s: float) -> void:
	if martillo_forjador:
		martillo_forjador.position = pos_objetivo
		_pos_previa_martillo = pos_objetivo
	rapidez_martillo = rapidez_px_s
	var factor_vel: float = calcular_factor_fuerza_por_velocidad(rapidez_px_s)
	_strike_at_position(pos_objetivo, factor_vel)

func reset_station(initial_color: Color = Color(0.96, 0.62, 0.04), initial_temp: float = TEMP_INICIAL_DEFECTO) -> void:
	temperatura_pieza = clampf(initial_temp, EscalaTermica.TEMP_AMBIENTE, EscalaTermica.TEMP_MANOMETRO_MAX)
	metal_temperature_color = initial_color if initial_temp == TEMP_INICIAL_DEFECTO else EscalaTermica.color_calor(temperatura_pieza)
	strikes_count = 0
	golpes_en_frio = 0
	penalizacion_frio = 0.0
	ultimo_factor_velocidad = 1.0
	strike_history_x.clear()
	btn_finish_anvil.disabled = true
	_arrastrando_martillo = false
	_offset_agarre_martillo = Vector2.ZERO
	_estaba_dentro_metal = false
	_ya_golpeo_en_esta_entrada = false

	if martillo_forjador:
		martillo_forjador.position = POSICION_REPOSO_MARTILLO
		_pos_previa_martillo = POSICION_REPOSO_MARTILLO
		velocidad_martillo = Vector2.ZERO
		rapidez_martillo = 0.0
	if etiqueta_agarre_martillo:
		etiqueta_agarre_martillo.visible = true

	slice_x.clear()
	upper_offsets.clear()
	lower_offsets.clear()

	for i in range(NUM_SLICES):
		var t: float = float(i) / float(NUM_SLICES - 1)
		slice_x.append(lerpf(-INITIAL_HALF_WIDTH, INITIAL_HALF_WIDTH, t))
		var bisel_extremo: float = 1.0 - 0.22 * pow(absf(t * 2.0 - 1.0), 3.0)
		var semi_alto_inicial: float = (INITIAL_THICKNESS * 0.5) * bisel_extremo
		upper_offsets.append(-semi_alto_inicial)
		lower_offsets.append(semi_alto_inicial)

	_construir_silueta_objetivo()
	_rebuild_polygon()
	_draw_target_guide()
	_sincronizar_aspecto_termico()
	_update_ui()

func _construir_silueta_objetivo() -> void:
	target_x.clear()
	target_upper.clear()
	target_lower.clear()
	var es_perno: bool = "perno" in nombre_objeto_solicitado.to_lower()

	for i in range(NUM_SLICES):
		var t: float = float(i) / float(NUM_SLICES - 1)
		target_x.append(lerpf(-BAR_HALF_WIDTH, BAR_HALF_WIDTH, t))

		var desired_half_height: float
		if t < 0.18:
			# Cabeza recalcada de clavo de compuerta o cabeza hexagonal de perno
			var u_cab: float = t / 0.18
			desired_half_height = lerpf(21.0, 26.0, sin(u_cab * PI * 0.75 + 0.2)) if not es_perno else lerpf(23.0, 25.0, sin(u_cab * PI * 0.8))
		elif t < 0.27:
			# Escalón del cuello bajo la cabeza
			var u_cuello: float = (t - 0.18) / 0.09
			desired_half_height = lerpf(25.0, 12.0 if not es_perno else 14.5, u_cuello)
		elif t < 0.72:
			# Vástago / espiga central firme
			var u_vastago: float = (t - 0.27) / 0.45
			desired_half_height = lerpf(12.0, 9.0, u_vastago) if not es_perno else lerpf(14.5, 12.5, u_vastago)
		else:
			# Punta piramidal aguda del clavo / chaflán cónico del perno
			var u_punta: float = (t - 0.72) / 0.28
			desired_half_height = lerpf(9.0, 1.8, u_punta) if not es_perno else lerpf(12.5, 5.5, u_punta)

		target_upper.append(-desired_half_height)
		target_lower.append(desired_half_height)

## Recalienta la pieza tras regresar de la fragua SIN perder la forma ya martillada.
func recalentar_pieza(nueva_temp: float, nuevo_color: Color = Color.WHITE) -> void:
	temperatura_pieza = clampf(nueva_temp, EscalaTermica.TEMP_AMBIENTE, EscalaTermica.TEMP_MANOMETRO_MAX)
	metal_temperature_color = EscalaTermica.color_calor(temperatura_pieza) if nuevo_color == Color.WHITE else nuevo_color
	_sincronizar_aspecto_termico()
	_update_ui()

func _sincronizar_aspecto_termico() -> void:
	metal_temperature_color = EscalaTermica.color_calor(temperatura_pieza)
	if metal_polygon:
		metal_polygon.color = metal_temperature_color
		if metal_polygon.material is ShaderMaterial:
			var mat: ShaderMaterial = metal_polygon.material as ShaderMaterial
			mat.set_shader_parameter("temperatura", temperatura_pieza)
	if resplandor_calor:
		var intensidad_calor: float = clampf((temperatura_pieza - 500.0) / 650.0, 0.0, 1.0)
		resplandor_calor.modulate = metal_temperature_color
		resplandor_calor.modulate.a = 0.65 * intensidad_calor

func _on_hit_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Única forma de golpear: agarrar el MartilloForjador y arrastrarlo contra el metal.
			# Hacer clic suelto NO teletransporta el martillo ni ejecuta ningún golpe.
			if martillo_forjador and martillo_forjador.position.distance_to(event.position) <= RADIO_AGARRE_MARTILLO:
				_arrastrando_martillo = true
				AudioManager.play_sfx("place_item", -2.5, 0.08)
				_offset_agarre_martillo = (martillo_forjador.position - event.position).limit_length(22.0)
				_pos_previa_martillo = martillo_forjador.position
				velocidad_martillo = Vector2.ZERO
				rapidez_martillo = 0.0
				_estaba_dentro_metal = _martillo_toca_metal()
				_ya_golpeo_en_esta_entrada = _estaba_dentro_metal
				if etiqueta_agarre_martillo:
					etiqueta_agarre_martillo.visible = false
			else:
				_arrastrando_martillo = false
				if etiqueta_agarre_martillo:
					etiqueta_agarre_martillo.visible = true
				if martillo_forjador:
					var tw_aviso: Tween = create_tween()
					tw_aviso.tween_property(martillo_forjador, "scale", Vector2(1.18, 1.18), 0.08)
					tw_aviso.tween_property(martillo_forjador, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_ELASTIC)
				if status_label:
					status_label.text = "🖐️ Toma el Martillo Forjador y arrástralo contra el metal para golpear (más rápido = más fuerza)."
					status_label.modulate = Color(0.98, 0.84, 0.35)
		else:
			_arrastrando_martillo = false
			_offset_agarre_martillo = Vector2.ZERO
			_estaba_dentro_metal = false
			_ya_golpeo_en_esta_entrada = false
			if estela_velocidad:
				estela_velocidad.visible = false
	elif event is InputEventMouseMotion and _arrastrando_martillo:
		if martillo_forjador:
			var nueva_pos: Vector2 = event.position + _offset_agarre_martillo
			var desp: Vector2 = nueva_pos - martillo_forjador.position
			if desp.length() > 0.5:
				velocidad_martillo = velocidad_martillo.lerp(desp * 60.0, 0.65)
				rapidez_martillo = velocidad_martillo.length()
			martillo_forjador.position = nueva_pos
			_verificar_colision_continua_martillo()

func _strike_at_local(offset_from_center: Vector2, factor_velocidad: float = 1.0) -> void:
	var center: Vector2 = Vector2(300.0, 140.0)
	if hit_area and hit_area.size.x > 0:
		center = hit_area.size * 0.5
	_strike_at_position(center + offset_from_center, factor_velocidad)

func _factor_deformacion_termica() -> float:
	if temperatura_pieza >= EscalaTermica.TEMP_DEFORMACION_PLENA:
		return 1.0
	if temperatura_pieza >= EscalaTermica.TEMP_RESISTENCIA:
		return 0.5
	return 0.15

func _strike_at_position(local_pos: Vector2, factor_velocidad: float = 1.0) -> void:
	ultimo_factor_velocidad = clampf(factor_velocidad, 0.20, 1.95)
	GameManager.consume_stamina(1.0)
	AudioManager.play_anvil(temperatura_pieza)

	strikes_count += 1
	if martillo_forjador:
		martillo_forjador.position = local_pos

	var center_x: float = hit_area.size.x / 2.0 if hit_area.size.x > 0.0 else 300.0
	var center_y: float = hit_area.size.y / 2.0 if hit_area.size.y > 0.0 else 140.0
	var click_rel_x: float = local_pos.x - center_x
	var click_rel_y: float = local_pos.y - center_y
	strike_history_x.append(click_rel_x)

	var factor_termico: float = _factor_deformacion_termica()
	var potencia_total: float = factor_termico * ultimo_factor_velocidad

	if temperatura_pieza < EscalaTermica.TEMP_RESISTENCIA:
		penalizacion_frio = minf(0.65, penalizacion_frio + PENALIZACION_GOLPE_FRIO)
		golpes_en_frio += 1
	elif temperatura_pieza < EscalaTermica.TEMP_DEFORMACION_PLENA:
		penalizacion_frio = minf(0.65, penalizacion_frio + PENALIZACION_GOLPE_TIBIO)
		golpes_en_frio += 1

	# Instanciar el destello y las chispas físicas en el punto de contacto
	var hammer: Node2D = HAMMER_EFFECT_SCENE.instantiate()
	hammer.position = local_pos
	if hammer.has_method("configurar_impacto"):
		hammer.configurar_impacto(temperatura_pieza)
	hit_area.add_child(hammer)

	_disparar_juice_impacto(local_pos, potencia_total)

	# Rebote elástico y golpe único en el MartilloForjador tras impactar el metal
	if sprite_martillo:
		var tw_m: Tween = create_tween()
		tw_m.tween_property(sprite_martillo, "rotation", -0.68, 0.035)
		tw_m.parallel().tween_property(sprite_martillo, "scale", Vector2(0.52, 0.34), 0.035)
		tw_m.tween_property(sprite_martillo, "rotation", -0.22, 0.11).set_trans(Tween.TRANS_ELASTIC)
		tw_m.parallel().tween_property(sprite_martillo, "scale", Vector2(0.42, 0.42), 0.11).set_trans(Tween.TRANS_ELASTIC)

	var sesgo_arriba: float = clampf(1.0 - (click_rel_y / 32.0), 0.65, 1.35)
	var sesgo_abajo: float = clampf(1.0 + (click_rel_y / 32.0), 0.65, 1.35)

	# 1. ESTIRAMIENTO LONGITUDINAL (EJE X) Y MOLDEADO HACIA EL OBJETO SOLICITADO SEGÚN LA VELOCIDAD DEL MARTILLO:
	for i in range(NUM_SLICES):
		var sx: float = _get_x_for_slice(i)
		var dist_x: float = absf(sx - click_rel_x)
		var t_slice: float = float(i) / float(NUM_SLICES - 1)

		var influencia_largo: float = exp(-pow(dist_x / (DEFORMATION_RADIUS * 1.45), 2.0))
		var dir_x: float = signf(sx - click_rel_x)
		if absf(sx - click_rel_x) < 6.0:
			dir_x = -1.0 if t_slice < 0.35 else 1.0
		var largo_actual: float = absf(sx)
		var amortiguacion_x: float = 1.0 / (1.0 + pow(maxf(0.0, largo_actual - 138.0) / 55.0, 1.6))
		slice_x[i] += dir_x * STRETCH_LONGITUDINAL * (0.45 + 0.55 * influencia_largo) * potencia_total * amortiguacion_x

		if dist_x < DEFORMATION_RADIUS:
			var influence: float = 0.5 * (1.0 + cos((dist_x / DEFORMATION_RADIUS) * PI))
			var paso_moldeado: float = clampf(0.34 * influence * potencia_total, 0.04, 0.72)

			# Guiar hacia la silueta del objeto pedido (cabeza ancha a la izquierda, vástago central y punta cónica a la derecha)
			# dejando un pequeño labio excedente (+2.5px) en el vástago para las rebabas de la estación de corte
			var margen_rebaba: float = 2.6 if (t_slice >= 0.20 and t_slice <= 0.78) else 0.6
			var meta_up: float = (target_upper[i] - margen_rebaba) * sesgo_arriba
			var meta_low: float = (target_lower[i] + margen_rebaba) * sesgo_abajo

			# Además de acercarse al perfil del clavo/perno, un golpe muy veloz (>1.25x) expande extra el metal
			var empuje_velocidad: float = maxf(0.0, ultimo_factor_velocidad - 1.05) * DEFORMATION_AMOUNT * 0.55 * influence
			upper_offsets[i] = lerpf(upper_offsets[i], meta_up, paso_moldeado) - empuje_velocidad * sesgo_arriba
			lower_offsets[i] = lerpf(lower_offsets[i], meta_low, paso_moldeado) + empuje_velocidad * sesgo_abajo

	# 2. DIFUSIÓN PLÁSTICA SUAVE (conservando el escalón de la cabeza del clavo/perno)
	_difundir_flujo_plastico()

	var max_grosor: float = 8.0
	var max_largo: float = 110.0
	for i in range(NUM_SLICES):
		max_grosor = maxf(max_grosor, maxf(absf(upper_offsets[i]), absf(lower_offsets[i])))
		max_largo = maxf(max_largo, absf(slice_x[i]))

	if metal_polygon and metal_polygon.material is ShaderMaterial:
		var mat: ShaderMaterial = metal_polygon.material as ShaderMaterial
		mat.set_shader_parameter("semi_grosor_max", max_grosor)
		mat.set_shader_parameter("semi_largo", max_largo)

	temperatura_pieza = maxf(EscalaTermica.TEMP_AMBIENTE, temperatura_pieza - ENFRIAMIENTO_POR_GOLPE)

	_rebuild_polygon()
	_sincronizar_aspecto_termico()

	var tween: Tween = create_tween()
	var deform_escala: float = clampf(0.025 * ultimo_factor_velocidad, 0.01, 0.05)
	metal_polygon.scale = Vector2(1.0 + deform_escala, 1.0 - deform_escala * 1.2)
	tween.tween_interval(0.035)
	tween.tween_property(metal_polygon, "scale", Vector2.ONE, 0.13).set_trans(Tween.TRANS_ELASTIC)

	_update_ui()

func _difundir_flujo_plastico() -> void:
	for i in range(1, NUM_SLICES):
		if slice_x[i] < slice_x[i - 1] + 4.5:
			slice_x[i] = slice_x[i - 1] + 4.5

	var nuevos_up: Array[float] = upper_offsets.duplicate()
	var nuevos_low: Array[float] = lower_offsets.duplicate()
	for i in range(1, NUM_SLICES - 1):
		# Menor difusión justo en el cuello de la cabeza (i == 4..6) para preservar la forma de clavo/perno
		var peso_vecino: float = 0.07 if (i >= 4 and i <= 6) else 0.14
		var peso_propio: float = 1.0 - peso_vecino * 2.0
		nuevos_up[i] = upper_offsets[i] * peso_propio + (upper_offsets[i - 1] + upper_offsets[i + 1]) * peso_vecino
		nuevos_low[i] = lower_offsets[i] * peso_propio + (lower_offsets[i - 1] + lower_offsets[i + 1]) * peso_vecino
	nuevos_up[0] = lerpf(nuevos_up[1] * 0.90, upper_offsets[0], 0.65)
	nuevos_low[0] = lerpf(nuevos_low[1] * 0.90, lower_offsets[0], 0.65)
	nuevos_up[NUM_SLICES - 1] = lerpf(nuevos_up[NUM_SLICES - 2] * 0.55, upper_offsets[NUM_SLICES - 1], 0.4)
	nuevos_low[NUM_SLICES - 1] = lerpf(nuevos_low[NUM_SLICES - 2] * 0.55, lower_offsets[NUM_SLICES - 1], 0.4)
	upper_offsets = nuevos_up
	lower_offsets = nuevos_low

func _disparar_juice_impacto(local_pos: Vector2, potencia_impacto: float) -> void:
	var factor_norm: float = clampf(potencia_impacto / 1.5, 0.15, 1.0)
	if sacudida_trauma and sacudida_trauma.has_method("agregar_trauma"):
		var trauma_golpe: float = lerpf(0.22, 0.68, factor_norm)
		sacudida_trauma.agregar_trauma(trauma_golpe)

	if destello_impacto:
		destello_impacto.position = local_pos - destello_impacto.pivot_offset
		destello_impacto.scale = Vector2(0.35 + 0.25 * factor_norm, 0.35 + 0.25 * factor_norm)
		destello_impacto.modulate = EscalaTermica.color_calor(maxf(temperatura_pieza, 750.0))
		destello_impacto.modulate.a = lerpf(0.28, 0.95, factor_norm)
		var tw: Tween = create_tween().set_parallel(true)
		tw.tween_property(destello_impacto, "scale", Vector2(1.0 + 0.5 * factor_norm, 0.8 + 0.4 * factor_norm), 0.13).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(destello_impacto, "modulate:a", 0.0, 0.14)

	if chispas_forja:
		chispas_forja.position = local_pos
		chispas_forja.color = EscalaTermica.color_calor(maxf(temperatura_pieza, 700.0))
		chispas_forja.amount = int(lerpf(6.0, 32.0, factor_norm))
		chispas_forja.restart()
		chispas_forja.emitting = true

func _get_x_for_slice(i: int) -> float:
	if i >= 0 and i < slice_x.size():
		return slice_x[i]
	var t: float = float(i) / float(NUM_SLICES - 1)
	return lerp(-BAR_HALF_WIDTH, BAR_HALF_WIDTH, t)

func _rebuild_polygon() -> void:
	var points: PackedVector2Array = PackedVector2Array()

	# Sombrero redondeado de la cabeza izquierda del clavo/perno
	var x_izq: float = _get_x_for_slice(0)
	var semialto_izq: float = (lower_offsets[0] - upper_offsets[0]) * 0.5
	var y_centro_izq: float = (upper_offsets[0] + lower_offsets[0]) * 0.5
	points.append(Vector2(x_izq - minf(11.0, semialto_izq * 0.45), y_centro_izq + semialto_izq * 0.45))
	points.append(Vector2(x_izq - minf(13.0, semialto_izq * 0.55), y_centro_izq))
	points.append(Vector2(x_izq - minf(11.0, semialto_izq * 0.45), y_centro_izq - semialto_izq * 0.45))

	for i in range(NUM_SLICES):
		var x: float = _get_x_for_slice(i)
		points.append(Vector2(x, upper_offsets[i]))

	var u: int = NUM_SLICES - 1
	var x_der: float = _get_x_for_slice(u)
	var semialto_der: float = (lower_offsets[u] - upper_offsets[u]) * 0.5
	points.append(Vector2(x_der + clampf(16.0 - semialto_der * 0.6, 6.0, 16.0), (upper_offsets[u] + lower_offsets[u]) * 0.5))

	for i in range(NUM_SLICES - 1, -1, -1):
		var x: float = _get_x_for_slice(i)
		points.append(Vector2(x, lower_offsets[i]))

	metal_polygon.polygon = points
	if poligono_colision_metal:
		poligono_colision_metal.polygon = points

func _draw_target_guide() -> void:
	if not guide_line or target_x.is_empty():
		return
	guide_line.clear_points()
	var x0: float = target_x[0]
	var h0: float = absf(target_lower[0])
	guide_line.add_point(Vector2(x0 - 10.0, h0 * 0.45))
	guide_line.add_point(Vector2(x0 - 12.0, 0.0))
	guide_line.add_point(Vector2(x0 - 10.0, -h0 * 0.45))
	for i in range(NUM_SLICES):
		guide_line.add_point(Vector2(target_x[i], target_upper[i]))
	var xn: float = target_x[NUM_SLICES - 1]
	guide_line.add_point(Vector2(xn + 14.0, 0.0))
	for i in range(NUM_SLICES - 1, -1, -1):
		guide_line.add_point(Vector2(target_x[i], target_lower[i]))
	guide_line.add_point(Vector2(x0 - 10.0, h0 * 0.45))

func _evaluate_current_shaping() -> float:
	var total_error: float = 0.0
	var max_possible_error: float = 0.0

	for i in range(NUM_SLICES):
		var diff_up: float = absf(upper_offsets[i] - target_upper[i])
		var diff_down: float = absf(lower_offsets[i] - target_lower[i])
		var diff_x: float = absf(_get_x_for_slice(i) - target_x[i]) * 0.25
		total_error += (diff_up + diff_down + diff_x)
		max_possible_error += 34.0

	var base_accuracy: float = clampf(1.0 - (total_error / max_possible_error), 0.10, 1.0)
	var accuracy: float = clampf(base_accuracy - penalizacion_frio, 0.10, 1.0)

	if strikes_count < MIN_STRIKES:
		accuracy *= float(strikes_count) / float(MIN_STRIKES)

	return accuracy

func _update_ui() -> void:
	var current_acc: float = _evaluate_current_shaping()
	var largo_mm: float = (_get_x_for_slice(NUM_SLICES - 1) - _get_x_for_slice(0))
	strikes_label.text = "🔨 Golpes: %d (Fuerza: %.0f%% | Largo: %.0fpx)" % [
		strikes_count,
		ultimo_factor_velocidad * 100.0,
		largo_mm
	]
	if etiqueta_temperatura_pieza:
		etiqueta_temperatura_pieza.text = "🌡️ Pieza: %.0f°C (%s)" % [
			temperatura_pieza,
			EscalaTermica.nombre_tramo(temperatura_pieza)
		]
		etiqueta_temperatura_pieza.add_theme_color_override(
			"font_color",
			EscalaTermica.color_texto(temperatura_pieza)
		)
	accuracy_label.text = "Molde (%s): %.0f%%" % [nombre_objeto_solicitado.split(" ")[0], current_acc * 100.0]

	if strikes_count >= MIN_STRIKES:
		btn_finish_anvil.disabled = false

	if temperatura_pieza < EscalaTermica.TEMP_RESISTENCIA:
		status_label.text = "❄️ ¡METAL FRÍO (%.0f°C)! Casi no se estira y agrieta el acero (-%.0f%%). ¡Vuelve a la Fragua!" % [
			temperatura_pieza,
			penalizacion_frio * 100.0
		]
		status_label.modulate = Color(0.95, 0.55, 0.48)
	elif temperatura_pieza < EscalaTermica.TEMP_DEFORMACION_PLENA:
		status_label.text = "⚠️ Metal tibio (%.0f°C): se resiste al estirado (50%% fuerza, -%.0f%% precisión). Recalienta pronto." % [
			temperatura_pieza,
			penalizacion_frio * 100.0
		]
		status_label.modulate = Color(0.98, 0.72, 0.38)
	elif current_acc > 0.85:
		status_label.text = "¡Excelente forjado de %s! La cabeza y la espiga encajan con la guía. Pasa al corte." % nombre_objeto_solicitado
		status_label.modulate = Color(0.4, 0.9, 0.5)
	elif strikes_count < MIN_STRIKES:
		status_label.text = "Mueve el martillo contra el metal: golpe rápido = mucha expansión; golpe lento = ajuste suave."
		status_label.modulate = Color(0.95, 0.9, 0.8)
	else:
		status_label.text = "Continúa perfilando la cabeza a la izquierda y la punta a la derecha o pasa al corte."
		status_label.modulate = Color(0.96, 0.78, 0.2)

func _on_reheat_pressed() -> void:
	emit_signal("recalentar_solicitado", temperatura_pieza)

func _on_finish_pressed() -> void:
	var final_score: float = _evaluate_current_shaping()
	emit_signal("anvil_shaping_completed", final_score, metal_polygon.polygon)
