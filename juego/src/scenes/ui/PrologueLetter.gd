# PrologueLetter.gd
# Pantalla completa de narrativa de la carta de la madre (GDD §2.1)
# Estética artesanal de autor: pergamino cálido sobre penumbra medieval.
# Nomenclatura de nodos 100% en español conforme a docs/idea.txt §8.2
extends CanvasLayer

signal letter_closed()

@onready var fondo_oscurecido: ColorRect = $FondoOscurecido
@onready var contenedor_pergamino: Control = $ContenedorPergamino
@onready var panel_pergamino: Panel = $ContenedorPergamino/PanelPergamino
@onready var boton_cerrar_carta: Button = $ContenedorPergamino/PanelPergamino/ContenedorVertical/BotonCerrarCarta
@onready var etiqueta_texto_carta: Label = $ContenedorPergamino/PanelPergamino/ContenedorVertical/EtiquetaTextoCarta

# Alias de compatibilidad hacia atrás
var background_dim: ColorRect:
	get: return fondo_oscurecido
var parchment_container: Control:
	get: return contenedor_pergamino
var parchment_panel: Panel:
	get: return panel_pergamino
var close_button: Button:
	get: return boton_cerrar_carta
var letter_text_label: Label:
	get: return etiqueta_texto_carta

var is_closing: bool = false

func _ready() -> void:
	layer = 15
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	boton_cerrar_carta.pressed.connect(close_letter)
	
	if GameManager.current_state == GameManager.State.PROLOGUE:
		show_letter()
	else:
		visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible or is_closing:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("action") or event.is_action_pressed("cancel_escape"):
		close_letter()

func show_letter() -> void:
	visible = true
	is_closing = false
	fondo_oscurecido.modulate.a = 0.0
	contenedor_pergamino.modulate.a = 0.0
	contenedor_pergamino.scale = Vector2(0.92, 0.92)
	contenedor_pergamino.pivot_offset = contenedor_pergamino.size / 2.0
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(fondo_oscurecido, "modulate:a", 1.0, 0.4)
	tween.tween_property(contenedor_pergamino, "modulate:a", 1.0, 0.4)
	tween.tween_property(contenedor_pergamino, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func close_letter() -> void:
	if is_closing:
		return
	is_closing = true
	
	GameManager.change_state(GameManager.State.OVERWORLD)
	GameManager.post_notification("Sigue la guía hacia el taller de tu tío.")
	emit_signal("letter_closed")
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(fondo_oscurecido, "modulate:a", 0.0, 0.25)
	tween.tween_property(contenedor_pergamino, "modulate:a", 0.0, 0.25)
	tween.tween_property(contenedor_pergamino, "scale", Vector2(0.95, 0.95), 0.25)
	
	await tween.finished
	visible = false
