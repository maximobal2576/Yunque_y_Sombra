# SacudidaTrauma.gd
# Componente reutilizable de sacudida por trauma (/game_feel).
# Fuerza = trauma² sobre ruido continuo (FastNoiseLite): picos contundentes que se apagan
# suavemente, sin el temblor aleatorio cuadro a cuadro que provoca mareo.
# Uso: añadir como hijo, asignar `ruta_objetivo` (Control o Node2D) y llamar agregar_trauma(0..1).
extends Node

@export var ruta_objetivo: NodePath
## Desplazamiento máximo en píxeles con trauma = 1.0 (pequeño a propósito: anti-mareo).
@export var desplazamiento_maximo: Vector2 = Vector2(7.0, 5.0)
## Trauma perdido por segundo.
@export var decaimiento: float = 2.4
## Velocidad de recorrido del ruido (más alto = vibración más seca).
@export var frecuencia_ruido: float = 22.0

var trauma: float = 0.0

var _objetivo: Node = null
var _posicion_base: Vector2 = Vector2.ZERO
var _sacudiendo: bool = false
var _tiempo: float = 0.0
var _ruido: FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
	_ruido.seed = randi()
	_ruido.frequency = 1.0
	_ruido.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	if not ruta_objetivo.is_empty():
		_objetivo = get_node_or_null(ruta_objetivo)
	set_process(false)

func asignar_objetivo(objetivo: Node) -> void:
	detener()
	_objetivo = objetivo

func agregar_trauma(cantidad: float) -> void:
	if not _objetivo_valido() or cantidad <= 0.0:
		return
	if not _sacudiendo:
		_posicion_base = _objetivo.get("position")
		_sacudiendo = true
	trauma = clampf(trauma + cantidad, 0.0, 1.0)
	set_process(true)

func _process(delta: float) -> void:
	if not _objetivo_valido():
		_sacudiendo = false
		trauma = 0.0
		set_process(false)
		return
	_tiempo += delta
	trauma = maxf(trauma - decaimiento * delta, 0.0)
	if trauma <= 0.0:
		detener()
		return
	var fuerza: float = trauma * trauma
	var t: float = _tiempo * frecuencia_ruido
	# El ruido simplex rara vez supera ±0.6; se normaliza ×1.6 para aprovechar el rango.
	var desplazamiento: Vector2 = Vector2(
		desplazamiento_maximo.x * fuerza * clampf(_ruido.get_noise_2d(t, 0.0) * 1.6, -1.0, 1.0),
		desplazamiento_maximo.y * fuerza * clampf(_ruido.get_noise_2d(0.0, t) * 1.6, -1.0, 1.0)
	)
	_objetivo.set("position", _posicion_base + desplazamiento)

## Restaura la posición de reposo exacta y apaga el procesamiento.
func detener() -> void:
	if _sacudiendo and _objetivo_valido():
		_objetivo.set("position", _posicion_base)
	_sacudiendo = false
	trauma = 0.0
	set_process(false)

func _exit_tree() -> void:
	detener()

func _objetivo_valido() -> bool:
	return _objetivo != null and is_instance_valid(_objetivo)
