# MinaSubterranea.gd
# Escena completa y jugable de la Mina Subterránea de 'Yunque & Sombra' (GDD §3.2 y Plan de Acción §3.1).
# Orquestación espacial Top-Down en caverna (Rect2(1800, 300, 800, 600), centro en (2200, 600)),
# iluminación dinámica cálida con antorchas, vetas de mineral con física de impacto táctil (Trauma Shake,
# Squash & Stretch y chispas) y Cinemática del Primer Hito Metalúrgico + Hoja del Diario del Tío.
# Nomenclatura de nodos 100% en español conforme a docs/idea.txt §8.2 y tipado estricto ':=' obligatorio.
extends Node2D

signal salida_mina_solicitada()
signal hito_primer_hierro_desbloqueado()
signal mineral_extraido(id_mineral: String, cantidad: int)

const LIMITES_CAMARA_MINA: Vector4 = Vector4(1780, 280, 2620, 920)
const POSICION_APARICION_MINA: Vector2 = Vector2(2200, 800)
const COSTO_ESTAMINA_GOLPE: float = 3.0
const TIEMPO_GRACIA_HITO: float = 1.6

const TEXTO_DESCRIPCION_HITO_CORTO: String = "La roca cede y revela Hierro Puro junto a una nota oculta de tu tío Rodrik:"
const TEXTO_NOTA_DIARIO_TIO_CORTO: String = "«Los Señores Feudales mintieron: esta colina no es estéril, oculta el hierro más puro de la comarca. Forja en secreto y que sus emisarios no oigan tu pico.» — Tío Rodrik"

# Nodos principales del árbol en español
@onready var suelo_caverna: Node2D = $SueloCaverna
@onready var muros_caverna: StaticBody2D = $MurosCaverna
@onready var contenedor_antorchas: Node2D = $ContenedorAntorchas
@onready var contenedor_vetas: Node2D = $ContenedorVetas
@onready var escalera_salida_taller: Node2D = $EscaleraSalidaTaller
@onready var area_salida_taller: Area2D = $EscaleraSalidaTaller/AreaInteractiva
@onready var oscuridad_caverna: Node2D = $OscuridadCaverna
@onready var manto_penumbra: ColorRect = $OscuridadCaverna/MantoPenumbra
@onready var cinematica_primer_hierro: CanvasLayer = $CinematicaPrimerHierro
@onready var fondo_oscuro_cinematica: ColorRect = $CinematicaPrimerHierro/FondoOscuroCinematica
@onready var contenedor_modal_hito: Control = $CinematicaPrimerHierro/ContenedorModalHito
@onready var panel_pergamino_hito: Panel = $CinematicaPrimerHierro/ContenedorModalHito/PanelPergaminoHito
@onready var etiqueta_descripcion_hito: Label = $CinematicaPrimerHierro/ContenedorModalHito/PanelPergaminoHito/ContenedorVertical/EtiquetaDescripcionHito
@onready var etiqueta_nota_diario_tio: Label = $CinematicaPrimerHierro/ContenedorModalHito/PanelPergaminoHito/ContenedorVertical/EtiquetaNotaDiarioTio
@onready var boton_cerrar_cinematica: Button = $CinematicaPrimerHierro/ContenedorModalHito/PanelPergaminoHito/ContenedorVertical/BotonCerrarCinematica
@onready var boton_continuar_hito: Button = $CinematicaPrimerHierro/ContenedorModalHito/PanelPergaminoHito/ContenedorVertical/BotonCerrarCinematica

# Soportes de antorchas
@onready var soporte_antorcha_1: Node2D = $ContenedorAntorchas/SoporteAntorcha1
@onready var soporte_antorcha_2: Node2D = $ContenedorAntorchas/SoporteAntorcha2
@onready var soporte_antorcha_3: Node2D = $ContenedorAntorchas/SoporteAntorcha3

# Vetas de mineral
@onready var veta_carbon_1: Node2D = $ContenedorVetas/VetaCarbon1
@onready var veta_hierro_1: Node2D = $ContenedorVetas/VetaHierro1
@onready var veta_hierro_2: Node2D = $ContenedorVetas/VetaHierro2
@onready var veta_cobre_1: Node2D = $ContenedorVetas/VetaCobre1
@onready var veta_plata_1: Node2D = $ContenedorVetas/VetaPlata1
@onready var veta_oro_1: Node2D = $ContenedorVetas/VetaOro1

# Estado interno de iluminación, vetas e hito
var antorchas_encendidas: Dictionary = {
	"SoporteAntorcha1": false,
	"SoporteAntorcha2": false,
	"SoporteAntorcha3": false
}

var definicion_vetas: Dictionary = {
	"VetaCarbon1": {
		"id_mineral": "carbon",
		"nombre_legible": "Carbón Mineral",
		"golpes_maximos": 3,
		"cantidad_recompensa": 3,
		"color_mineral": Color(0.18, 0.18, 0.22, 1.0)
	},
	"VetaHierro1": {
		"id_mineral": "mineral_hierro",
		"nombre_legible": "Hierro Puro",
		"golpes_maximos": 4,
		"cantidad_recompensa": 2,
		"color_mineral": Color(0.75, 0.78, 0.82, 1.0)
	},
	"VetaHierro2": {
		"id_mineral": "mineral_hierro",
		"nombre_legible": "Hierro Puro",
		"golpes_maximos": 4,
		"cantidad_recompensa": 2,
		"color_mineral": Color(0.75, 0.78, 0.82, 1.0)
	},
	"VetaCobre1": {
		"id_mineral": "mineral_cobre",
		"nombre_legible": "Cobre Nativo",
		"golpes_maximos": 3,
		"cantidad_recompensa": 2,
		"color_mineral": Color(0.85, 0.48, 0.28, 1.0)
	},
	"VetaPlata1": {
		"id_mineral": "mineral_plata",
		"nombre_legible": "Plata de Veta Profunda",
		"golpes_maximos": 4,
		"cantidad_recompensa": 1,
		"color_mineral": Color(0.88, 0.92, 0.98, 1.0)
	},
	"VetaOro1": {
		"id_mineral": "mineral_oro",
		"nombre_legible": "Oro Antiguo",
		"golpes_maximos": 5,
		"cantidad_recompensa": 1,
		"color_mineral": Color(0.96, 0.78, 0.24, 1.0)
	}
}

var estado_vetas: Dictionary = {}
var primer_hierro_desbloqueado: bool = false
var cinematica_activa: bool = false
var _tiempo_gracia_restante: float = 0.0
var _esperando_soltar_tecla_e: bool = false

# Variables de Game Feel (Trauma Shake cuadrático y Hit-Stop seguro)
var _trauma_mina: float = 0.0
var _reloj_shake: float = 0.0
var _posicion_base_suelo: Vector2 = Vector2.ZERO
var _tweens_vetas: Dictionary = {}
var _tween_penumbra: Tween = null
var _tween_cinematica: Tween = null
var _pulso_fuego: float = 0.0
var _id_hit_stop: int = 0

func _ready() -> void:
	_posicion_base_suelo = suelo_caverna.position
	if is_instance_valid(etiqueta_descripcion_hito):
		etiqueta_descripcion_hito.text = TEXTO_DESCRIPCION_HITO_CORTO
	if is_instance_valid(etiqueta_nota_diario_tio):
		etiqueta_nota_diario_tio.text = TEXTO_NOTA_DIARIO_TIO_CORTO
	if cinematica_primer_hierro:
		cinematica_primer_hierro.visible = false
	if boton_continuar_hito:
		boton_continuar_hito.pressed.connect(_al_presionar_boton_continuar_hito)

	if area_salida_taller:
		area_salida_taller.interacted.connect(_al_interactuar_escalera_salida)

	_inicializar_antorchas()
	_inicializar_vetas()
	_actualizar_iluminacion_caverna(true)

	# Conectar regeneración de vetas al cambio de día en TimeManager
	if TimeManager.has_signal("day_started"):
		TimeManager.day_started.connect(_al_iniciar_nuevo_dia)
	if TimeManager.has_signal("day_changed"):
		TimeManager.connect("day_changed", Callable(self, "_al_iniciar_nuevo_dia"))

func _process(delta: float) -> void:
	_procesar_trauma_shake(delta)
	_procesar_parpadeo_antorchas(delta)
	_procesar_gracia_cinematica(delta)

func _procesar_gracia_cinematica(delta: float) -> void:
	if not cinematica_activa:
		return
	var delta_real: float = delta / maxf(Engine.time_scale, 0.0001)
	if _tiempo_gracia_restante > 0.0:
		_tiempo_gracia_restante = maxf(_tiempo_gracia_restante - delta_real, 0.0)
		if _tiempo_gracia_restante <= 0.0:
			_tiempo_gracia_restante = 0.0
			if not Input.is_action_pressed("interact") and not Input.is_physical_key_pressed(KEY_E):
				_esperando_soltar_tecla_e = false
			if is_instance_valid(boton_continuar_hito):
				boton_continuar_hito.disabled = false
				boton_continuar_hito.text = "[E] Guardar nota en el diario"

func _input(event: InputEvent) -> void:
	if not cinematica_activa:
		return
	_procesar_evento_cinematica(event, true)

func _unhandled_input(event: InputEvent) -> void:
	if not cinematica_activa:
		return
	_procesar_evento_cinematica(event, false)

func _procesar_evento_cinematica(event: InputEvent, desde_input_temprano: bool) -> void:
	if event is InputEventKey:
		var evento_tecla: InputEventKey = event as InputEventKey
		if not evento_tecla.pressed:
			if evento_tecla.keycode == KEY_E or evento_tecla.physical_keycode == KEY_E or event.is_action_released("interact"):
				_esperando_soltar_tecla_e = false
			get_viewport().set_input_as_handled()
			return
	elif event.is_action_released("interact"):
		_esperando_soltar_tecla_e = false
		get_viewport().set_input_as_handled()
		return

	if _tiempo_gracia_restante > 0.0:
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventAction:
			get_viewport().set_input_as_handled()
		return

	var es_tecla_e: bool = false
	if event is InputEventKey:
		var tecla_presionada: InputEventKey = event as InputEventKey
		if tecla_presionada.pressed and not tecla_presionada.echo:
			if tecla_presionada.keycode == KEY_E or tecla_presionada.physical_keycode == KEY_E:
				es_tecla_e = true

	var es_accion_cierre: bool = (not event.is_echo()) and (
		event.is_action_pressed("interact")
		or event.is_action_pressed("ui_accept")
		or event.is_action_pressed("cancel_escape")
	)

	if es_tecla_e or es_accion_cierre:
		if not event.is_echo():
			_esperando_soltar_tecla_e = false
		if not _esperando_soltar_tecla_e:
			get_viewport().set_input_as_handled()
			cerrar_cinematica_primer_hierro()
			return

	# Evitar que entradas del jugador sigan picando o moviendo detrás de la cinemática
	if not desde_input_temprano or event is InputEventKey:
		get_viewport().set_input_as_handled()

# ==============================================================================
# CONFIGURACIÓN DE ANTORCHAS E ILUMINACIÓN CÁLIDA (GDD §3.2)
# ==============================================================================

func _inicializar_antorchas() -> void:
	var lista_antorchas: Array[Node2D] = [soporte_antorcha_1, soporte_antorcha_2, soporte_antorcha_3]
	for soporte in lista_antorchas:
		if not is_instance_valid(soporte):
			continue
		var nombre_soporte: String = soporte.name
		antorchas_encendidas[nombre_soporte] = false
		var area: Area2D = soporte.get_node_or_null("AreaInteractiva") as Area2D
		if area:
			area.set("prompt_text", "Encender Antorcha de Pared")
			area.interacted.connect(func() -> void: encender_antorcha(nombre_soporte))
		_aplicar_estado_visual_antorcha(soporte, false)

func encender_antorcha(nombre_soporte: String) -> void:
	var soporte: Node2D = contenedor_antorchas.get_node_or_null(nombre_soporte) as Node2D
	if not is_instance_valid(soporte):
		return

	if antorchas_encendidas.get(nombre_soporte, false):
		GameManager.post_notification("La antorcha ya arde iluminando la roca húmeda.")
		return

	antorchas_encendidas[nombre_soporte] = true
	AudioManager.play_sfx("torch_light", 0.5, 0.05)
	AudioManager.play_fire()

	_aplicar_estado_visual_antorcha(soporte, true)
	_aplicar_squash_and_stretch(soporte, Vector2(1.25, 0.78))
	_actualizar_iluminacion_caverna(false)

	var area: Area2D = soporte.get_node_or_null("AreaInteractiva") as Area2D
	if area:
		area.set("prompt_text", "Antorcha Encendida")

	GameManager.post_notification("Antorcha encendida. La penumbra de la caverna retrocede ante el fuego.")

func _aplicar_estado_visual_antorcha(soporte: Node2D, encendida: bool) -> void:
	var llama: Polygon2D = soporte.get_node_or_null("LlamaAntorcha") as Polygon2D
	var halo_calido: Polygon2D = soporte.get_node_or_null("HaloLuzCalida") as Polygon2D
	var nucleo_luz: Polygon2D = soporte.get_node_or_null("NucleoLuz") as Polygon2D
	var particulas: CPUParticles2D = soporte.get_node_or_null("ParticulasFuego") as CPUParticles2D

	if llama:
		llama.visible = encendida
	if halo_calido:
		halo_calido.visible = encendida
	if nucleo_luz:
		nucleo_luz.visible = encendida
	if particulas:
		particulas.emitting = encendida

func obtener_cantidad_antorchas_encendidas() -> int:
	var total: int = 0
	for clave: String in antorchas_encendidas:
		if antorchas_encendidas[clave]:
			total += 1
	return total

func _actualizar_iluminacion_caverna(inmediato: bool = false) -> void:
	if not is_instance_valid(manto_penumbra):
		return

	var encendidas: int = obtener_cantidad_antorchas_encendidas()
	# Sin antorchas: oscuridad densa (0.76); cada antorcha despeja la caverna cálidamente
	var opacidad_objetivo: float = clampf(0.76 - float(encendidas) * 0.22, 0.10, 0.76)

	if _tween_penumbra and _tween_penumbra.is_valid():
		_tween_penumbra.kill()

	if inmediato:
		manto_penumbra.color.a = opacidad_objetivo
	else:
		_tween_penumbra = create_tween()
		_tween_penumbra.tween_property(manto_penumbra, "color:a", opacidad_objetivo, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _procesar_parpadeo_antorchas(delta: float) -> void:
	_pulso_fuego += delta * 7.5
	var lista_antorchas: Array[Node2D] = [soporte_antorcha_1, soporte_antorcha_2, soporte_antorcha_3]
	var indice: int = 0
	for soporte in lista_antorchas:
		indice += 1
		if not is_instance_valid(soporte):
			continue
		if not antorchas_encendidas.get(soporte.name, false):
			continue
		var halo: Polygon2D = soporte.get_node_or_null("HaloLuzCalida") as Polygon2D
		var llama: Polygon2D = soporte.get_node_or_null("LlamaAntorcha") as Polygon2D
		var desfase: float = float(indice) * 1.7
		var factor: float = 1.0 + sin(_pulso_fuego + desfase) * 0.06
		if halo:
			halo.scale = Vector2(factor, factor)
		if llama:
			llama.scale = Vector2(1.0 + cos(_pulso_fuego * 1.4 + desfase) * 0.08, 1.0 + sin(_pulso_fuego * 1.8 + desfase) * 0.12)

# ==============================================================================
# MECÁNICA DE VETAS DE MINERAL Y PICADO TÁCTIL (GDD §3.2 y Plan §3.1)
# ==============================================================================

func _inicializar_vetas() -> void:
	for nombre_veta: String in definicion_vetas:
		var nodo_veta: Node2D = contenedor_vetas.get_node_or_null(nombre_veta) as Node2D
		if not is_instance_valid(nodo_veta):
			continue
		var datos: Dictionary = definicion_vetas[nombre_veta]
		var golpes_max: int = int(datos["golpes_maximos"])
		estado_vetas[nombre_veta] = {
			"golpes_restantes": golpes_max,
			"agotada": false
		}
		var area: Area2D = nodo_veta.get_node_or_null("AreaInteractiva") as Area2D
		if area:
			var nombre_legible: String = String(datos["nombre_legible"])
			area.set("prompt_text", "Picar Veta de %s" % nombre_legible)
			area.interacted.connect(func() -> void: picar_veta(nombre_veta))
		_actualizar_visual_veta(nodo_veta, false)

func picar_veta(nombre_veta: String) -> void:
	if cinematica_activa:
		return
	if not estado_vetas.has(nombre_veta) or not definicion_vetas.has(nombre_veta):
		return

	var estado: Dictionary = estado_vetas[nombre_veta]
	if bool(estado["agotada"]):
		GameManager.post_notification("Esta veta ya fue extraída por completo. Se regenerará al amanecer.")
		return

	# Consumo de estamina por golpe de pico (3.0 puntos)
	if not GameManager.consume_stamina(COSTO_ESTAMINA_GOLPE):
		return

	var nodo_veta: Node2D = contenedor_vetas.get_node_or_null(nombre_veta) as Node2D
	var datos: Dictionary = definicion_vetas[nombre_veta]
	var golpes_restantes: int = int(estado["golpes_restantes"]) - 1
	estado["golpes_restantes"] = golpes_restantes

	# Sonido de golpe de pico + fallback metálico
	AudioManager.play_sfx("pickaxe_hit", 1.0, 0.07)
	AudioManager.play_anvil(550.0)

	# Game Feel: Trauma Shake, Squash & Stretch elástico y chispas de impacto
	agregar_trauma_mina(0.45)
	if is_instance_valid(nodo_veta):
		_aplicar_squash_and_stretch_veta(nombre_veta, nodo_veta, Vector2(1.24, 0.76))
		_emitir_chispas_veta(nodo_veta)

	if golpes_restantes > 0:
		var nombre_legible: String = String(datos["nombre_legible"])
		var area: Area2D = nodo_veta.get_node_or_null("AreaInteractiva") as Area2D if is_instance_valid(nodo_veta) else null
		if area:
			area.set("prompt_text", "Picar Veta de %s" % nombre_legible)
		GameManager.post_notification("La roca de %s se agrieta bajo el pico." % nombre_legible)
	else:
		_quebrar_veta(nombre_veta, nodo_veta, datos)

func _quebrar_veta(nombre_veta: String, nodo_veta: Node2D, datos: Dictionary) -> void:
	estado_vetas[nombre_veta]["agotada"] = true
	estado_vetas[nombre_veta]["golpes_restantes"] = 0

	# Sonidos de fractura de roca y recolección
	AudioManager.play_sfx("rock_shatter", 1.2, 0.05)
	AudioManager.play_sfx("place_item", 0.5, 0.05)
	AudioManager.play_coins()

	agregar_trauma_mina(0.85)
	_ejecutar_hitstop(0.045)

	var id_mineral: String = String(datos["id_mineral"])
	var cantidad: int = int(datos["cantidad_recompensa"])
	var nombre_legible: String = String(datos["nombre_legible"])

	# Añadir al inventario de GameManager
	if GameManager.inventory.has(id_mineral):
		GameManager.inventory[id_mineral] = int(GameManager.inventory[id_mineral]) + cantidad
	else:
		GameManager.inventory[id_mineral] = cantidad

	if is_instance_valid(nodo_veta):
		_actualizar_visual_veta(nodo_veta, true)
		_emitir_chispas_veta(nodo_veta)
		var area: Area2D = nodo_veta.get_node_or_null("AreaInteractiva") as Area2D
		if area:
			area.set("prompt_text", "Veta de %s Agotada (Regenera al dormir)" % nombre_legible)

	emit_signal("mineral_extraido", id_mineral, cantidad)
	GameManager.post_notification("¡Veta quebrada! Obtuviste +%d %s (Total: %d)." % [
		cantidad,
		nombre_legible,
		int(GameManager.inventory[id_mineral])
	])

	# EL PRIMER HITO (GDD §3.2): Al quebrar la primera veta de hierro puro
	if id_mineral == "mineral_hierro" and not primer_hierro_desbloqueado:
		primer_hierro_desbloqueado = true
		_disparar_cinematica_primer_hierro()

func _actualizar_visual_veta(nodo_veta: Node2D, agotada: bool) -> void:
	var cuerpo_roca: Polygon2D = nodo_veta.get_node_or_null("CuerpoRoca") as Polygon2D
	var cristales_mineral: Polygon2D = nodo_veta.get_node_or_null("CristalesMineral") as Polygon2D
	var grietas_roca: Line2D = nodo_veta.get_node_or_null("GrietasRoca") as Line2D
	var escombros_fractura: Polygon2D = nodo_veta.get_node_or_null("EscombrosFractura") as Polygon2D

	if cuerpo_roca:
		cuerpo_roca.modulate = Color(0.45, 0.42, 0.40, 0.85) if agotada else Color.WHITE
		cuerpo_roca.scale = Vector2(0.92, 0.72) if agotada else Vector2.ONE
	if cristales_mineral:
		cristales_mineral.visible = not agotada
	if grietas_roca:
		grietas_roca.visible = true
		grietas_roca.width = 3.0 if agotada else 1.8
	if escombros_fractura:
		escombros_fractura.visible = agotada

func _emitir_chispas_veta(nodo_veta: Node2D) -> void:
	var chispas: CPUParticles2D = nodo_veta.get_node_or_null("ChispasImpacto") as CPUParticles2D
	if chispas:
		chispas.restart()
		chispas.emitting = true

func regenerar_todas_las_vetas() -> void:
	for nombre_veta: String in definicion_vetas:
		var datos: Dictionary = definicion_vetas[nombre_veta]
		var golpes_max: int = int(datos["golpes_maximos"])
		estado_vetas[nombre_veta] = {
			"golpes_restantes": golpes_max,
			"agotada": false
		}
		var nodo_veta: Node2D = contenedor_vetas.get_node_or_null(nombre_veta) as Node2D
		if is_instance_valid(nodo_veta):
			_actualizar_visual_veta(nodo_veta, false)
			var area: Area2D = nodo_veta.get_node_or_null("AreaInteractiva") as Area2D
			if area:
				var nombre_legible: String = String(datos["nombre_legible"])
				area.set("prompt_text", "Picar Veta de %s" % nombre_legible)

func _al_iniciar_nuevo_dia(_nuevo_dia: int = 1) -> void:
	regenerar_todas_las_vetas()

# ==============================================================================
# CINEMÁTICA DEL PRIMER HITO METALÚRGICO Y NOTA DEL TÍO (GDD §2.3 y §3.2)
# ==============================================================================

func _disparar_cinematica_primer_hierro() -> void:
	desplegar_cinematica_primer_hierro()

func desplegar_cinematica_primer_hierro() -> void:
	if not is_instance_valid(cinematica_primer_hierro):
		return

	cinematica_activa = true
	_tiempo_gracia_restante = TIEMPO_GRACIA_HITO
	_esperando_soltar_tecla_e = true

	if is_instance_valid(etiqueta_descripcion_hito):
		etiqueta_descripcion_hito.text = TEXTO_DESCRIPCION_HITO_CORTO
	if is_instance_valid(etiqueta_nota_diario_tio):
		etiqueta_nota_diario_tio.text = TEXTO_NOTA_DIARIO_TIO_CORTO
	if is_instance_valid(boton_continuar_hito):
		boton_continuar_hito.disabled = true
		boton_continuar_hito.text = "Espera un instante..."

	cinematica_primer_hierro.visible = true
	AudioManager.play_bell()

	if fondo_oscuro_cinematica:
		fondo_oscuro_cinematica.modulate.a = 0.0
	if contenedor_modal_hito:
		contenedor_modal_hito.modulate.a = 0.0
		contenedor_modal_hito.scale = Vector2(0.84, 0.84)
		contenedor_modal_hito.pivot_offset = Vector2(640.0, 360.0)

	if _tween_cinematica and _tween_cinematica.is_valid():
		_tween_cinematica.kill()

	_tween_cinematica = create_tween().set_parallel(true).set_ignore_time_scale(true)
	if fondo_oscuro_cinematica:
		_tween_cinematica.tween_property(fondo_oscuro_cinematica, "modulate:a", 1.0, 0.35)
	if contenedor_modal_hito:
		_tween_cinematica.tween_property(contenedor_modal_hito, "modulate:a", 1.0, 0.35)
		_tween_cinematica.tween_property(contenedor_modal_hito, "scale", Vector2.ONE, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Registrar la nota del diario en el inventario simbólico
	if not GameManager.inventory.has("notas_diario_tio"):
		GameManager.inventory["notas_diario_tio"] = 1
	else:
		GameManager.inventory["notas_diario_tio"] = int(GameManager.inventory["notas_diario_tio"]) + 1

	emit_signal("hito_primer_hierro_desbloqueado")

func _al_presionar_boton_continuar_hito() -> void:
	if _tiempo_gracia_restante > 0.0:
		return
	cerrar_cinematica_primer_hierro()

func cerrar_cinematica_primer_hierro() -> void:
	if not cinematica_activa:
		return
	cinematica_activa = false
	_tiempo_gracia_restante = 0.0
	_esperando_soltar_tecla_e = false

	if _tween_cinematica and _tween_cinematica.is_valid():
		_tween_cinematica.kill()

	_tween_cinematica = create_tween().set_parallel(true).set_ignore_time_scale(true)
	if fondo_oscuro_cinematica:
		_tween_cinematica.tween_property(fondo_oscuro_cinematica, "modulate:a", 0.0, 0.22)
	if contenedor_modal_hito:
		_tween_cinematica.tween_property(contenedor_modal_hito, "modulate:a", 0.0, 0.22)
		_tween_cinematica.tween_property(contenedor_modal_hito, "scale", Vector2(0.94, 0.94), 0.22)

	await _tween_cinematica.finished
	if not is_inside_tree():
		return
	if is_instance_valid(cinematica_primer_hierro):
		cinematica_primer_hierro.visible = false
	GameManager.post_notification("Has archivado la nota grabada del Diario del Tío Rodrik.")

# ==============================================================================
# ESCALERA DE SALIDA AL TALLER / ACCESO MINA
# ==============================================================================

func _al_interactuar_escalera_salida() -> void:
	if cinematica_activa:
		return
	GameManager.post_notification("Asciendes por la escalera de madera hacia la trampilla trasera del taller...")
	emit_signal("salida_mina_solicitada")

# ==============================================================================
# ALGORITMOS CANÓNICOS DE GAME FEEL (/game_feel)
# ==============================================================================

func agregar_trauma_mina(cantidad: float) -> void:
	_trauma_mina = clampf(_trauma_mina + cantidad, 0.0, 1.0)

func _procesar_trauma_shake(delta: float) -> void:
	if _trauma_mina > 0.0:
		var delta_real: float = delta / maxf(Engine.time_scale, 0.0001)
		_trauma_mina = maxf(_trauma_mina - 2.8 * delta_real, 0.0)
		var factor_cuadratico: float = _trauma_mina * _trauma_mina
		_reloj_shake += delta_real * 30.0
		var desplazamiento := Vector2(
			10.0 * factor_cuadratico * sin(_reloj_shake * 1.7),
			8.0 * factor_cuadratico * sin(_reloj_shake * 2.3)
		)
		suelo_caverna.position = _posicion_base_suelo + desplazamiento
	else:
		suelo_caverna.position = _posicion_base_suelo

func _aplicar_squash_and_stretch(objetivo: Node2D, deformacion: Vector2 = Vector2(1.2, 0.8)) -> void:
	if not is_instance_valid(objetivo):
		return
	var tw: Tween = create_tween()
	tw.tween_property(objetivo, "scale", deformacion, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(objetivo, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _aplicar_squash_and_stretch_veta(clave: String, objetivo: Node2D, deformacion: Vector2) -> void:
	if not is_instance_valid(objetivo):
		return
	if _tweens_vetas.has(clave):
		var previo: Tween = _tweens_vetas[clave] as Tween
		if previo and previo.is_valid():
			previo.kill()
	var tw: Tween = create_tween()
	_tweens_vetas[clave] = tw
	tw.tween_property(objetivo, "scale", deformacion, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(objetivo, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _ejecutar_hitstop(duracion_segundos: float = 0.045) -> void:
	_id_hit_stop += 1
	var mi_id: int = _id_hit_stop
	Engine.time_scale = 0.08
	await get_tree().create_timer(duracion_segundos, true, false, true).timeout
	if mi_id == _id_hit_stop:
		Engine.time_scale = 1.0
