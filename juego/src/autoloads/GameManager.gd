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

enum State {
	PROLOGUE,          # Vista inicial de la carta de la madre (Onboarding GDD §2.1)
	OVERWORLD,         # Movimiento Top-Down libre en el taller / pueblo / mina
	WORKSHOP_STATION,  # Vista de estación interactiva dedicada estilo Papa's Games
	FORGING,           # Alias / compatibilidad retroactiva con minijuego de forja
	SLEEPING,          # Transición de descanso nocturno (timelapse GDD §3.3)
	PAUSED             # Menú de pausa
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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	emit_signal("stamina_changed", stamina, max_stamina)
	emit_signal("coins_changed", coins)
	emit_signal("state_changed", current_state)

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	emit_signal("state_changed", current_state)

func consume_stamina(amount: float) -> bool:
	if stamina <= 0.0:
		post_notification("¡Estás exhausto! No tienes energía para trabajar.")
		return false
	stamina = max(0.0, stamina - amount)
	emit_signal("stamina_changed", stamina, max_stamina)
	return true

func restore_stamina(percentage: float = 1.0) -> void:
	stamina = clamp(max_stamina * percentage, 0.0, max_stamina)
	emit_signal("stamina_changed", stamina, max_stamina)

func add_coins(amount: int) -> void:
	coins += amount
	emit_signal("coins_changed", coins)

func record_crafted_item(item_name: String, quality: float, reward_coins: int) -> void:
	if inventory.has(item_name):
		inventory[item_name] += 1
	else:
		inventory[item_name] = 1
	add_coins(reward_coins)
	emit_signal("item_crafted", item_name, quality)
	post_notification("Forjaste %s (Calidad: %.0f%%) | +%d monedas" % [item_name, quality * 100.0, reward_coins])

func post_notification(msg: String) -> void:
	emit_signal("notification_posted", msg)

func exit_workshop() -> void:
	change_state(State.OVERWORLD)
	emit_signal("workshop_exited")
