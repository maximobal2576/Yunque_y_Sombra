# AnimalPueblo.gd
# Controlador de animaciones procedurales y vida diegética para animales del pueblo (/direccion_de_arte /juice)
# Nomenclatura 100% en español conforme a docs/idea.txt §8.2
extends Node2D

enum TipoAnimal {
	BUEY,
	VACA,
	OVEJA,
	MULA,
	GALLINA,
	PERRO
}

@export var tipo_animal: TipoAnimal = TipoAnimal.BUEY
@export var velocidad_respiracion: float = 2.2
@export var amplitud_respiracion: float = 0.035
@export var permite_deambular: bool = false
@export var radio_deambular: float = 30.0

var _tiempo: float = 0.0
var _tiempo_proxima_accion: float = 2.0
var _cabeza: Node2D = null
var _cola: Node2D = null
var _oreja_izq: Node2D = null
var _oreja_der: Node2D = null
var _posicion_inicial: Vector2 = Vector2.ZERO
var _en_picoteo: bool = false
var _conteo_picotazos: int = 0
var _angulo_cabeza_base: float = 0.0

func _ready() -> void:
	_posicion_inicial = position
	_tiempo = randf() * 10.0
	_tiempo_proxima_accion = randf_range(1.5, 4.0)

	_cabeza = get_node_or_null("Cabeza") as Node2D
	_cola = get_node_or_null("Cola") as Node2D
	_oreja_izq = get_node_or_null("Cabeza/OrejaIzq") as Node2D
	_oreja_der = get_node_or_null("Cabeza/OrejaDer") as Node2D

	if _cabeza:
		_angulo_cabeza_base = _cabeza.rotation

func _process(delta: float) -> void:
	_tiempo += delta

	# 1. Respiración orgánica general (Squash & Stretch con conservación de volumen)
	var factor_respiracion: float = sin(_tiempo * velocidad_respiracion) * amplitud_respiracion
	scale.y = 1.0 + factor_respiracion
	scale.x = (signf(scale.x) if scale.x != 0.0 else 1.0) * (1.0 - factor_respiracion * 0.5)

	# 2. Comportamiento especializado por tipo de animal
	match tipo_animal:
		TipoAnimal.GALLINA:
			_procesar_gallina(delta)
		TipoAnimal.PERRO:
			_procesar_perro(delta)
		TipoAnimal.MULA, TipoAnimal.BUEY, TipoAnimal.VACA:
			_procesar_herbivoro_grande(delta)
		TipoAnimal.OVEJA:
			_procesar_oveja(delta)

func _procesar_herbivoro_grande(delta: float) -> void:
	# Movimiento suave de la cola
	if _cola:
		var latigazo: float = sin(_tiempo * 3.5) * 0.25
		if fmod(_tiempo, 4.0) < 0.8:
			latigazo = sin(_tiempo * 18.0) * 0.55 # Espantamoscas rápido ocasional
		_cola.rotation = latigazo

	# Cabeceo de pastoreo
	_tiempo_proxima_accion -= delta
	if _tiempo_proxima_accion <= 0.0:
		_tiempo_proxima_accion = randf_range(3.0, 6.0)
		if _cabeza:
			var bajar_cabeza: bool = randf() > 0.4
			var angulo_meta: float = _angulo_cabeza_base + (0.35 if bajar_cabeza else -0.15)
			var tw := create_tween()
			tw.tween_property(_cabeza, "rotation", angulo_meta, 0.8).set_trans(Tween.TRANS_SINE)

	# Movimiento de orejas de mula/burro
	if tipo_animal == TipoAnimal.MULA and _oreja_izq and _oreja_der:
		if fmod(_tiempo, 2.5) < 0.2:
			_oreja_izq.rotation = sin(_tiempo * 25.0) * 0.2
			_oreja_der.rotation = cos(_tiempo * 25.0) * 0.2

func _procesar_oveja(delta: float) -> void:
	# Las ovejas pastan a ritmo tranquilo
	if _cola:
		_cola.rotation = sin(_tiempo * 4.0) * 0.15

	_tiempo_proxima_accion -= delta
	if _tiempo_proxima_accion <= 0.0:
		_tiempo_proxima_accion = randf_range(2.5, 5.0)
		if _cabeza:
			var tw := create_tween()
			tw.tween_property(_cabeza, "position:y", 3.0 if randf() > 0.5 else 0.0, 0.4).set_trans(Tween.TRANS_SINE)

func _procesar_gallina(delta: float) -> void:
	# Cabeceo de picoteo rápido (peck peck peck)
	_tiempo_proxima_accion -= delta
	if _tiempo_proxima_accion <= 0.0 and not _en_picoteo:
		_iniciar_picoteo_gallina()

	if _en_picoteo and _cabeza:
		_cabeza.rotation = sin(_tiempo * 24.0) * 0.55

func _iniciar_picoteo_gallina() -> void:
	_en_picoteo = true
	var duracion_picoteo: float = randf_range(0.8, 1.4)
	var tw := create_tween()
	tw.tween_interval(duracion_picoteo)
	tw.finished.connect(func() -> void:
		_en_picoteo = false
		if _cabeza:
			_cabeza.rotation = _angulo_cabeza_base
		_tiempo_proxima_accion = randf_range(1.5, 3.5)

		# Salto / giro ocasional
		if randf() > 0.5:
			scale.x = -scale.x
		if permite_deambular and randf() > 0.6:
			var offset_aleatorio: Vector2 = Vector2(randf_range(-12.0, 12.0), randf_range(-8.0, 8.0))
			var nueva_pos: Vector2 = (_posicion_inicial + offset_aleatorio)
			var tw_salto := create_tween().set_parallel(true)
			tw_salto.tween_property(self, "position", nueva_pos, 0.25).set_trans(Tween.TRANS_QUAD)
			tw_salto.tween_property(self, "position:y", nueva_pos.y - 4.0, 0.12).set_trans(Tween.TRANS_QUAD)
			tw_salto.chain().tween_property(self, "position:y", nueva_pos.y, 0.13).set_trans(Tween.TRANS_QUAD)
	)

func _procesar_perro(_delta: float) -> void:
	# El perro del pueblo mueve la cola alegremente y atiende al entorno
	if _cola:
		_cola.rotation = sin(_tiempo * 7.5) * 0.35

	# Atender si el jugador está cerca
	var jugador = get_tree().get_first_node_in_group("jugador") if get_tree() else null
	if not jugador:
		jugador = get_parent().get_node_or_null("Jugador")
	if is_instance_valid(jugador) and _cabeza:
		var dist: float = global_position.distance_to(jugador.global_position)
		if dist < 90.0:
			var dir_jugador: Vector2 = (jugador.global_position - global_position).normalized()
			_cabeza.rotation = lerp_angle(_cabeza.rotation, dir_jugador.angle(), 0.1)
		else:
			_cabeza.rotation = lerp_angle(_cabeza.rotation, _angulo_cabeza_base, 0.05)
