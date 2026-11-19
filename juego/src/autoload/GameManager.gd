# GameManager.gd
# Gestor central de estado global del juego (Autoload Singleton)
# Implementado bajo arquitectura limpia y desacoplada en GDScript 4.
extends Node

signal state_changed(new_state: State)
signal stamina_changed(current: float, maximum: float)
signal coins_changed(current: int)
signal item_crafted(item_name: String, quality: float)
signal notification_posted(message: String)
signal workshop_exited()
signal stock_barriles_cambiado()
signal menas_barril_mina_cambiado()
signal menas_en_mano_cambiado(tipo: String, cantidad: int)
signal pedido_diario_completado(total_hoy: int)
signal sueno_completado()
signal mena_fundida_en_fragua(tipo: String, cantidad: int)

enum State {
	PROLOGUE,          # Vista inicial de la carta de la madre (Onboarding GDD 2.1)
	OVERWORLD,         # Movimiento Top-Down libre en el taller / pueblo / mina
	WORKSHOP_STATION,  # Vista de estación interactiva dedicada estilo Papa's Games
	FORGING,           # Alias / compatibilidad retroactiva con minijuego de forja
	SLEEPING,          # Transición de descanso nocturno (timelapse GDD 3.3)
	PAUSED             # Menú de pausa
}

const DATOS_METALES: Dictionary = {
	"bronce_cobre": {
		"nombre": "Bronce de Forja",
		"temp_forja_min": 750.0,
		"temp_forja_max": 880.0,
		"temp_fusion": 1020.0,
		"maleabilidad": 1.25
	},
	"acero_carbono": {
		"nombre": "Acero al Carbono",
		"temp_forja_min": 920.0,
		"temp_forja_max": 1040.0,
		"temp_fusion": 1140.0,
		"maleabilidad": 0.78
	},
	"hierro_dulce": {
		"nombre": "Hierro Dulce",
		"temp_forja_min": 1000.0,
		"temp_forja_max": 1160.0,
		"temp_fusion": 1200.0,
		"maleabilidad": 1.00
	}
}

var current_state: State = State.PROLOGUE

# Variables de progresión y economía
var coins: int = 50
var stamina: float = 100.0
var max_stamina: float = 100.0

var inventory: Dictionary = {
	"carbon": 10,
	"mineral_hierro": 5,
	"clavos": 0,
	"herraduras": 0
}

var stock_barriles_fragua: Dictionary = {
	"hierro_dulce": 3,
	"acero_carbono": 3,
	"bronce_cobre": 3
}
var menas_barril_mina: Dictionary = {
	"hierro_dulce": 0,
	"acero_carbono": 0,
	"bronce_cobre": 0
}
var menas_en_mano_tipo: String = ""
var menas_en_mano_cantidad: int = 0
var pedidos_completados_hoy: int = 0
var ha_dormido_tras_jornada: bool = false
var mision_fundicion_mena_completada: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	stamina_changed.emit(stamina, max_stamina)
	coins_changed.emit(coins)
	state_changed.emit(current_state)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F12:
			_capture_live_viewport()

func _capture_live_viewport() -> void:
	var vp: Viewport = get_viewport()
	if not vp:
		return
	var img: Image = vp.get_texture().get_image()
	if img:
		DirAccess.make_dir_absolute("res://screenshots")
		var target: String = ProjectSettings.globalize_path("res://screenshots/live_eye_capture.png")
		img.save_png(target)
		print("[OJOS ACTIVADOS] Captura de viewport guardada en: ", target)
		post_notification("Captura visual registrada para el Asistente")

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	state_changed.emit(current_state)

func consume_stamina(amount: float) -> bool:
	if stamina <= 0.0:
		post_notification("¡Estás exhausto! No tienes energía para trabajar.")
		return false
	stamina = maxf(0.0, stamina - amount)
	stamina_changed.emit(stamina, max_stamina)
	return true

func restore_stamina(percentage: float = 1.0) -> void:
	stamina = clampf(max_stamina * percentage, 0.0, max_stamina)
	stamina_changed.emit(stamina, max_stamina)

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

func add_item(item_key: String, amount: int = 1) -> void:
	if item_key.is_empty() or amount <= 0:
		return
	var actual: int = int(inventory.get(item_key, 0))
	inventory[item_key] = actual + amount
	if item_key == "mineral_hierro" or item_key == "cobre" or item_key == "carbon" or item_key == "plata" or item_key == "oro":
		agregar_mena_barril_mina(item_key, amount)

func obtener_datos_metal(tipo: String) -> Dictionary:
	return DATOS_METALES.get(tipo, DATOS_METALES["hierro_dulce"]) as Dictionary

func consumir_lingote_barril_fragua(tipo: String) -> bool:
	var stock_actual: int = int(stock_barriles_fragua.get(tipo, 0))
	if stock_actual <= 0:
		return false
	stock_barriles_fragua[tipo] = stock_actual - 1
	stock_barriles_cambiado.emit()
	return true

func agregar_mena_barril_mina(tipo: String, cantidad: int = 1) -> void:
	if cantidad <= 0:
		return
	var clave: String = "hierro_dulce"
	match tipo:
		"mineral_hierro", "hierro_dulce":
			clave = "hierro_dulce"
		"cobre", "bronce_cobre":
			clave = "bronce_cobre"
		"carbon", "plata", "oro", "acero_carbono":
			clave = "acero_carbono"
		_:
			if menas_barril_mina.has(tipo):
				clave = tipo
			else:
				return
	var actual: int = int(menas_barril_mina.get(clave, 0))
	menas_barril_mina[clave] = actual + cantidad
	menas_barril_mina_cambiado.emit()

func retirar_menas_barril_a_mano(tipo: String, cantidad: int) -> bool:
	if cantidad < 1 or cantidad > 3:
		return false
	if menas_en_mano_cantidad > 0 and menas_en_mano_tipo != tipo:
		return false
	if menas_en_mano_cantidad + cantidad > 3:
		return false
	var disponible: int = int(menas_barril_mina.get(tipo, 0))
	if disponible < cantidad:
		return false
	menas_barril_mina[tipo] = disponible - cantidad
	menas_en_mano_tipo = tipo
	menas_en_mano_cantidad = clampi(menas_en_mano_cantidad + cantidad, 1, 3)
	menas_barril_mina_cambiado.emit()
	menas_en_mano_cambiado.emit(menas_en_mano_tipo, menas_en_mano_cantidad)
	return true

func completar_fundicion_menas_en_mano() -> int:
	if menas_en_mano_cantidad <= 0:
		return 0
	var cant: int = menas_en_mano_cantidad
	var t: String = menas_en_mano_tipo
	var stock_actual: int = int(stock_barriles_fragua.get(t, 0))
	stock_barriles_fragua[t] = stock_actual + cant
	menas_en_mano_tipo = ""
	menas_en_mano_cantidad = 0
	mision_fundicion_mena_completada = true
	mena_fundida_en_fragua.emit(t, cant)
	menas_en_mano_cambiado.emit("", 0)
	stock_barriles_cambiado.emit()
	return cant

func registrar_pedido_completado() -> void:
	pedidos_completados_hoy += 1
	pedido_diario_completado.emit(pedidos_completados_hoy)

func registrar_sueno_completado() -> void:
	ha_dormido_tras_jornada = true
	sueno_completado.emit()

func record_crafted_item(item_name: String, quality: float, reward_coins: int) -> void:
	if inventory.has(item_name):
		inventory[item_name] = int(inventory[item_name]) + 1
	else:
		inventory[item_name] = 1
	add_coins(reward_coins)
	item_crafted.emit(item_name, quality)
	post_notification("Forjaste %s (Calidad: %.0f%%) | +%d monedas" % [item_name, quality * 100.0, reward_coins])

func post_notification(msg: String) -> void:
	notification_posted.emit(msg)

func exit_workshop() -> void:
	change_state(State.OVERWORLD)
	workshop_exited.emit()
