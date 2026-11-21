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
signal daily_summary_requested(resumen_info: Dictionary)

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
	if not is_time_running and GameManager.current_state == GameManager.State.SLEEPING:
		return
	is_time_running = false
	GameManager.change_state(GameManager.State.SLEEPING)
	GameManager.consume_stamina(GameManager.stamina) # Vaciado total de estamina por colapso
	emit_signal("player_passed_out")
	
	var es_en_interior: bool = ("zona_actual" in GameManager and GameManager.zona_actual == "interior")
	var stamina_pct: float = 0.5 if es_en_interior else 0.4
	var monedas_robadas: int = 0
	var tipo_descanso: String = "desmayo_taller" if es_en_interior else "desmayo_exterior"
	var titulo_descanso: String = ""
	var desc_descanso: String = ""
	
	if es_en_interior:
		titulo_descanso = "Colapso por Agotamiento en el Taller"
		desc_descanso = "La medianoche te sorprendió sin descansar. Despiertas en tu cama con fatiga acumulada (50% de vigor)."
		GameManager.post_notification("¡Colapsaste de agotamiento a las 00:00 dentro de casa!")
	else:
		titulo_descanso = "Asalto Nocturno a la Intemperie"
		if GameManager.coins > 0:
			monedas_robadas = clampi(int(float(GameManager.coins) * 0.18), 5, GameManager.coins)
			GameManager.add_coins(-monedas_robadas)
			if "perdidas_oro_hoy" in GameManager:
				GameManager.perdidas_oro_hoy += monedas_robadas
		if "menas_en_mano_cantidad" in GameManager and GameManager.menas_en_mano_cantidad > 0:
			GameManager.menas_en_mano_cantidad = 0
			GameManager.menas_en_mano_tipo = ""
			if GameManager.has_signal("menas_en_mano_cambiado"):
				GameManager.menas_en_mano_cambiado.emit("", 0)
		desc_descanso = "Colapsaste a las 00:00 a la intemperie. Maleantes te robaron %d monedas de oro y te arrastraron a tu cama (40%% de vigor)." % monedas_robadas
		GameManager.post_notification("¡Colapso a medianoche! Fuiste asaltado y perdiste %d monedas..." % monedas_robadas)
	
	var info_resumen: Dictionary = {
		"tipo_descanso": tipo_descanso,
		"titulo_descanso": titulo_descanso,
		"desc_descanso": desc_descanso,
		"stamina_pct": stamina_pct,
		"monedas_robadas": monedas_robadas,
		"pedidos_ayer": GameManager.pedidos_completados_hoy if "pedidos_completados_hoy" in GameManager else 0,
		"ganancias_ayer": GameManager.ganancias_oro_hoy if "ganancias_oro_hoy" in GameManager else 0,
		"saldo_actual": GameManager.coins,
		"nuevo_dia": day + 1
	}
	
	var es_headless: bool = DisplayServer.get_name() == "headless"
	var dur_espera: float = 0.08 if es_headless else 1.5
	await get_tree().create_timer(dur_espera).timeout
	start_new_day(stamina_pct, info_resumen)

func sleep_voluntarily() -> void:
	if not is_time_running and GameManager.current_state == GameManager.State.SLEEPING:
		return
	is_time_running = false
	GameManager.change_state(GameManager.State.SLEEPING)
	GameManager.post_notification("Te recuestas en tu cama y descansas profundamente...")
	
	var info_resumen: Dictionary = {
		"tipo_descanso": "voluntario",
		"titulo_descanso": "Descanso Pleno en Cama",
		"desc_descanso": "Descansaste plácidamente antes de medianoche. Despiertas a las 06:00 AM con el 100% de tu vigor restaurado.",
		"stamina_pct": 1.0,
		"monedas_robadas": 0,
		"pedidos_ayer": GameManager.pedidos_completados_hoy if "pedidos_completados_hoy" in GameManager else 0,
		"ganancias_ayer": GameManager.ganancias_oro_hoy if "ganancias_oro_hoy" in GameManager else 0,
		"saldo_actual": GameManager.coins,
		"nuevo_dia": day + 1
	}
	
	var es_headless: bool = DisplayServer.get_name() == "headless"
	var dur_espera: float = 0.08 if es_headless else 1.2
	await get_tree().create_timer(dur_espera).timeout
	start_new_day(1.0, info_resumen)

func start_new_day(stamina_percentage: float = 1.0, info_resumen: Dictionary = {}) -> void:
	day += 1
	hour = 6
	minute = 0
	GameManager.restore_stamina(stamina_percentage)
	if GameManager.has_method("reiniciar_jornada_diaria"):
		GameManager.reiniciar_jornada_diaria(day)
	
	if info_resumen.is_empty():
		info_resumen = {
			"tipo_descanso": "voluntario",
			"titulo_descanso": "Descanso en Cama",
			"desc_descanso": "Amanece un nuevo día de forja.",
			"stamina_pct": stamina_percentage,
			"monedas_robadas": 0,
			"pedidos_ayer": GameManager.pedidos_ayer if "pedidos_ayer" in GameManager else 0,
			"ganancias_ayer": GameManager.ganancias_ayer if "ganancias_ayer" in GameManager else 0,
			"saldo_actual": GameManager.coins,
			"nuevo_dia": day
		}
	info_resumen["nuevo_dia"] = day
	
	emit_signal("day_started", day)
	emit_current_time()
	emit_signal("shop_opened")
	emit_signal("daily_summary_requested", info_resumen)
	GameManager.post_notification("Amanecer del Día %d (06:00 AM) — Tu energía ha sido restaurada." % day)
	
	var es_headless: bool = DisplayServer.get_name() == "headless"
	if es_headless:
		confirmar_inicio_jornada()

func confirmar_inicio_jornada() -> void:
	is_time_running = true
	GameManager.change_state(GameManager.State.OVERWORLD)

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
