# MainHUD.gd
# HUD inferior persistente estilo barra de tareas (GDD 3.0)
# Nomenclatura de nodos 100% en español y tipado estricto (:=) conforme a docs/idea.txt §8.2
extends CanvasLayer

@onready var etiqueta_reloj: Label = $BarraInferior/ContenedorFila/EtiquetaReloj
@onready var etiqueta_interaccion: Label = $BarraInferior/ContenedorFila/ContenedorCentro/EtiquetaInteraccion
@onready var barra_estamina: ProgressBar = $BarraInferior/ContenedorFila/ContenedorEstadisticas/BarraEstamina
@onready var etiqueta_estamina: Label = $BarraInferior/ContenedorFila/ContenedorEstadisticas/EtiquetaEstamina
@onready var etiqueta_monedas: Label = $BarraInferior/ContenedorFila/ContenedorEstadisticas/EtiquetaMonedas
@onready var banner_toast: Label = $BannerToast

# Alias de compatibilidad hacia atrás
var time_label: Label:
	get: return etiqueta_reloj
var prompt_label: Label:
	get: return etiqueta_interaccion
var stamina_bar: ProgressBar:
	get: return barra_estamina
var stamina_label: Label:
	get: return etiqueta_estamina
var coins_label: Label:
	get: return etiqueta_monedas
var toast_banner: Label:
	get: return banner_toast

var toast_timer: SceneTreeTimer = null

func _ready() -> void:
	layer = 5
	banner_toast.visible = false
	etiqueta_interaccion.text = ""
	
	TimeManager.time_updated.connect(_on_time_updated)
	GameManager.stamina_changed.connect(_on_stamina_changed)
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.notification_posted.connect(_on_notification_posted)
	
	# Inicializar valores
	_on_stamina_changed(GameManager.stamina, GameManager.max_stamina)
	_on_coins_changed(GameManager.coins)
	TimeManager.emit_current_time()

func _on_time_updated(_hour: int, _minute: int, day: int, phase_name: String) -> void:
	etiqueta_reloj.text = "DÍA %d  |  %s  |  %s" % [day, TimeManager.get_formatted_time(), phase_name]

func _on_stamina_changed(current: float, maximum: float) -> void:
	barra_estamina.max_value = maximum
	barra_estamina.value = current
	etiqueta_estamina.text = "Vigor: %.0f / %.0f" % [current, maximum]

func _on_coins_changed(coins: int) -> void:
	etiqueta_monedas.text = "Oro: %d" % coins

func _on_notification_posted(msg: String) -> void:
	banner_toast.text = msg
	banner_toast.visible = true
	var tween := create_tween()
	banner_toast.modulate.a = 1.0
	tween.tween_interval(3.2)
	tween.tween_property(banner_toast, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): banner_toast.visible = false)

func set_prompt(text: String) -> void:
	if text == "":
		etiqueta_interaccion.text = ""
	else:
		etiqueta_interaccion.text = "[E] %s" % text
