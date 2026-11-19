# MainHUD.gd
# HUD persistente estilo barra de tareas (GDD 3.0) y menú desplegable de volumen por canal
# Nomenclatura de nodos 100% en español y tipado estricto (:=) conforme a docs/idea.txt §8.2
extends CanvasLayer

@onready var etiqueta_reloj: Label = $BarraInferior/ContenedorFila/EtiquetaReloj
@onready var etiqueta_interaccion: Label = $BarraInferior/ContenedorFila/ContenedorCentro/EtiquetaInteraccion
@onready var barra_estamina: ProgressBar = $BarraInferior/ContenedorFila/ContenedorEstadisticas/BarraEstamina
@onready var etiqueta_estamina: Label = $BarraInferior/ContenedorFila/ContenedorEstadisticas/EtiquetaEstamina
@onready var etiqueta_monedas: Label = $BarraInferior/ContenedorFila/ContenedorEstadisticas/EtiquetaMonedas
@onready var banner_toast: Label = $BannerToast

@onready var boton_menu_audio: Button = $BarraSuperior/BotonMenuAudio
@onready var panel_menu_audio: PanelContainer = $PanelMenuAudio
@onready var slider_volumen_general: HSlider = $PanelMenuAudio/ContenedorAudio/FilaVolumenGeneral/SliderVolumenGeneral
@onready var slider_volumen_musica: HSlider = $PanelMenuAudio/ContenedorAudio/FilaVolumenMusica/SliderVolumenMusica
@onready var slider_volumen_efectos: HSlider = $PanelMenuAudio/ContenedorAudio/FilaVolumenEfectos/SliderVolumenEfectos
@onready var slider_volumen_ambiente: HSlider = $PanelMenuAudio/ContenedorAudio/FilaVolumenAmbiente/SliderVolumenAmbiente

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
	panel_menu_audio.visible = false
	etiqueta_interaccion.text = ""
	
	TimeManager.time_updated.connect(_on_time_updated)
	GameManager.stamina_changed.connect(_on_stamina_changed)
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.notification_posted.connect(_on_notification_posted)
	
	# Inicializar controles de audio por canal
	slider_volumen_general.set_value_no_signal(AudioManager.master_volume)
	slider_volumen_musica.set_value_no_signal(AudioManager.music_volume)
	slider_volumen_efectos.set_value_no_signal(AudioManager.sfx_volume)
	slider_volumen_ambiente.set_value_no_signal(AudioManager.ambience_volume)
	
	boton_menu_audio.pressed.connect(toggle_menu_audio)
	slider_volumen_general.value_changed.connect(_on_volumen_general_changed)
	slider_volumen_musica.value_changed.connect(_on_volumen_musica_changed)
	slider_volumen_efectos.value_changed.connect(_on_volumen_efectos_changed)
	slider_volumen_ambiente.value_changed.connect(_on_volumen_ambiente_changed)
	
	# Inicializar valores del HUD
	_on_stamina_changed(GameManager.stamina, GameManager.max_stamina)
	_on_coins_changed(GameManager.coins)
	TimeManager.emit_current_time()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if key_event.keycode == KEY_V or key_event.physical_keycode == KEY_V:
				toggle_menu_audio()
				get_viewport().set_input_as_handled()

func toggle_menu_audio() -> void:
	if is_instance_valid(panel_menu_audio):
		panel_menu_audio.visible = not panel_menu_audio.visible

func _on_volumen_general_changed(value: float) -> void:
	AudioManager.set_master_volume(value)

func _on_volumen_musica_changed(value: float) -> void:
	AudioManager.set_music_volume(value)

func _on_volumen_efectos_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

func _on_volumen_ambiente_changed(value: float) -> void:
	AudioManager.set_ambience_volume(value)

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
	tween.set_ignore_time_scale(true)
	banner_toast.modulate.a = 1.0
	tween.tween_interval(3.2)
	tween.tween_property(banner_toast, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func() -> void: banner_toast.visible = false)

func set_prompt(text: String) -> void:
	if text == "":
		etiqueta_interaccion.text = ""
	else:
		etiqueta_interaccion.text = "[E] %s" % text
