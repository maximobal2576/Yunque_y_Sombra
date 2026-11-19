# HammerEffect.gd
# Juice visual de impacto de martillo para la estación de forja (/game_feel + /herrero)
# Usa el sprite real blacksmith_hammer.png, destello radial de contacto y chispas con física
# (gravedad, rebote en la cara del yunque y estela orientada según la velocidad).
extends Node2D

const EscalaTermica = preload("res://src/components/EscalaTermicaAcero.gd")

@onready var destello_cabeza: Sprite2D = $DestelloCabeza
@onready var martillo_visual: Node2D = $MartilloVisual
@onready var contenedor_chispas: Node2D = $ContenedorChispas

# Alias de compatibilidad
var hammer_visual: Node2D:
	get: return martillo_visual
var sparks_container: Node2D:
	get: return contenedor_chispas

var temperatura_impacto: float = 1085.0
var spark_count: int = 14

const GRAVEDAD_CHISPAS: float = 520.0
const PLANO_REBOTE_Y: float = 14.0

var _chispas_activas: Array[Dictionary] = []

func configurar_impacto(temperatura: float) -> void:
	temperatura_impacto = temperatura
	if temperatura >= EscalaTermica.TEMP_FORJA_OPTIMA_MIN:
		spark_count = 16
	elif temperatura >= EscalaTermica.TEMP_DEFORMACION_PLENA:
		spark_count = 11
	elif temperatura >= EscalaTermica.TEMP_RESISTENCIA:
		spark_count = 6
	else:
		spark_count = 3

func _ready() -> void:
	configurar_impacto(temperatura_impacto)
	play_strike_animation()

func _process(delta: float) -> void:
	if _chispas_activas.is_empty():
		return
	for datos in _chispas_activas:
		var nodo: Node2D = datos["nodo"]
		if not is_instance_valid(nodo):
			continue
		var vel: Vector2 = datos["vel"]
		vel.y += GRAVEDAD_CHISPAS * delta
		nodo.position += vel * delta
		# Rebote sobre la mesa de acero del yunque
		if nodo.position.y > PLANO_REBOTE_Y and vel.y > 0.0:
			nodo.position.y = PLANO_REBOTE_Y
			vel.y = -vel.y * 0.42
			vel.x *= 0.78
		datos["vel"] = vel
		nodo.rotation = vel.angle()
		datos["edad"] = float(datos["edad"]) + delta
		var t: float = clampf(float(datos["edad"]) / float(datos["vida"]), 0.0, 1.0)
		nodo.modulate.a = 1.0 - t * t
		nodo.scale = Vector2(lerpf(1.25, 0.25, t), lerpf(1.0, 0.35, t))

func play_strike_animation() -> void:
	# El martillo físico único es MartilloForjador en AnvilTopDownStation;
	# aquí mantenemos MartilloVisual oculto para no duplicar nunca el martillo en pantalla.
	martillo_visual.visible = false
	destello_cabeza.modulate.a = 0.0

	var strike_tween: Tween = create_tween()
	strike_tween.tween_callback(_on_impact)
	strike_tween.tween_interval(0.36)
	strike_tween.tween_callback(queue_free)

func _on_impact() -> void:
	_spawn_flash()
	_spawn_sparks()

func _spawn_flash() -> void:
	var intensidad: float = clampf((temperatura_impacto - 500.0) / 700.0, 0.25, 1.0)
	destello_cabeza.modulate = EscalaTermica.color_calor(maxf(temperatura_impacto, 750.0))
	destello_cabeza.modulate.a = 0.9 * intensidad
	destello_cabeza.scale = Vector2(0.35, 0.35)
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(destello_cabeza, "scale", Vector2(1.35, 0.95) * (0.7 + 0.4 * intensidad), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(destello_cabeza, "modulate:a", 0.0, 0.14)

func _spawn_sparks() -> void:
	var color_base: Color = EscalaTermica.color_calor(temperatura_impacto)
	for i in range(spark_count):
		var chispa: Polygon2D = Polygon2D.new()
		var largo: float = randf_range(6.0, 11.0)
		var alto: float = randf_range(1.6, 2.8)
		chispa.polygon = PackedVector2Array([
			Vector2(-largo, 0.0),
			Vector2(0.0, -alto),
			Vector2(largo * 0.45, 0.0),
			Vector2(0.0, alto)
		])
		var variacion: float = randf_range(-0.08, 0.16)
		chispa.color = Color(
			clampf(color_base.r + variacion + 0.15, 0.35, 1.0),
			clampf(color_base.g + variacion, 0.12, 0.96),
			clampf(color_base.b + variacion * 0.5, 0.05, 0.85),
			1.0
		)
		contenedor_chispas.add_child(chispa)

		var angulo: float = randf_range(-PI * 0.92, -PI * 0.08)
		var rapidez: float = randf_range(130.0, 310.0)
		var vel: Vector2 = Vector2(cos(angulo), sin(angulo)) * rapidez
		chispa.rotation = vel.angle()
		_chispas_activas.append({
			"nodo": chispa,
			"vel": vel,
			"edad": 0.0,
			"vida": randf_range(0.20, 0.32)
		})
