# TimeManager.gd
# Gestor del reloj de 24 horas y ciclo diurno/nocturno (Autoload Singleton)
# Conforme a la arquitectura de bucle diario de 'Yunque & Sombra'.
extends Node

signal time_updated(hour: int, minute: int, day: int, phase_name: String)
signal day_started(day: int)
signal shop_opened()
signal shop_closed()
signal midnight_approaching()
signal player_passed_out()

var day: int = 1
var hour: int = 6
var minute: int = 0

# 1 minuto de juego transcurre cada 0.7 segundos reales (1 hora = 42s)
var seconds_per_game_minute: float = 0.7
var timer_accumulator: float = 0.0
var is_time_running: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	emit_current_time()

func _process(delta: float) -> void:
	if not is_time_running:
		return
	if GameManager.current_state == GameManager.State.PAUSED or GameManager.current_state == GameManager.State.SLEEPING:
		return
		
	timer_accumulator += delta
	if timer_accumulator >= seconds_per_game_minute:
		timer_accumulator -= seconds_per_game_minute
		advance_minute()

func advance_minute() -> void:
	minute += 1
	if minute >= 60:
		minute = 0
		advance_hour()
	emit_current_time()

func advance_hour() -> void:
	hour += 1
	if hour == 6:
		emit_signal("shop_opened")
		GameManager.post_notification("06:00 AM — ¡El portón comercial se abre!")
	elif hour == 17:
		emit_signal("shop_closed")
		GameManager.post_notification("17:00 PM — Cierre comercial. El taller baja el portón; inicia la fase nocturna.")
	elif hour == 23 and minute == 0:
		emit_signal("midnight_approaching")
		GameManager.post_notification("23:00 PM — Sientes los párpados pesados. Debes dormir antes de medianoche.")
	elif hour >= 24:
		trigger_midnight_passout()

func trigger_midnight_passout() -> void:
	is_time_running = false
	GameManager.change_state(GameManager.State.SLEEPING)
	GameManager.consume_stamina(GameManager.stamina) # Vaciado total de estamina por colapso
	emit_signal("player_passed_out")
	GameManager.post_notification("¡Colapsaste de fatiga a medianoche! Un vecino te arrastró a tu cama...")
	
	# Transicion al dia siguiente con solo 50% de energia
	await get_tree().create_timer(3.0).timeout
	start_new_day(0.5)

func sleep_voluntarily() -> void:
	is_time_running = false
	GameManager.change_state(GameManager.State.SLEEPING)
	GameManager.post_notification("Te recuestas en tu cama y descansas profundamente...")
	
	# Transicion al dia siguiente con 100% de energia
	await get_tree().create_timer(2.0).timeout
	start_new_day(1.0)

func start_new_day(stamina_percentage: float = 1.0) -> void:
	day += 1
	hour = 6
	minute = 0
	is_time_running = true
	GameManager.restore_stamina(stamina_percentage)
	GameManager.change_state(GameManager.State.OVERWORLD)
	emit_signal("day_started", day)
	emit_current_time()
	GameManager.post_notification("Amanecer del Día %d (06:00 AM) — Tu energía ha sido restaurada." % day)

func get_phase_name() -> String:
	if hour >= 6 and hour < 17:
		return "DIURNA (Comercio & Forja)"
	elif hour >= 17 and hour < 24:
		return "NOCTURNA (Exploración & Mina)"
	else:
		return "MEDIANOCHE"

func emit_current_time() -> void:
	emit_signal("time_updated", hour, minute, day, get_phase_name())

func get_formatted_time() -> String:
	var ampm: String = "AM" if hour < 12 else "PM"
	var display_hour: int = hour if hour <= 12 else hour - 12
	if display_hour == 0:
		display_hour = 12
	return "%02d:%02d %s" % [display_hour, minute, ampm]
