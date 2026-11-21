# PantallaResumenDia.gd
# Pantalla de Resumen Diario y Transición de Descanso / Medianoche
# Nomenclatura 100% en español conforme a docs/idea.txt §3.3 y §8.2
extends CanvasLayer

signal resumen_cerrado()

@onready var fondo_atenuado: ColorRect = $FondoAtenuado
@onready var panel_pergamino: PanelContainer = $ContenedorCentrado/PanelPergamino
@onready var etiqueta_titulo_amanecer: Label = $ContenedorCentrado/PanelPergamino/MargenInterno/ColumnaPrincipal/EtiquetaTituloAmanecer
@onready var etiqueta_subtitulo: Label = $ContenedorCentrado/PanelPergamino/MargenInterno/ColumnaPrincipal/EtiquetaSubtitulo
@onready var etiqueta_titulo_descanso: Label = $ContenedorCentrado/PanelPergamino/MargenInterno/ColumnaPrincipal/PanelEstadoDescanso/MargenDescanso/ColumnaDescanso/EtiquetaTituloDescanso
@onready var etiqueta_desc_descanso: Label = $ContenedorCentrado/PanelPergamino/MargenInterno/ColumnaPrincipal/PanelEstadoDescanso/MargenDescanso/ColumnaDescanso/EtiquetaDescDescanso
@onready var etiqueta_pedidos_ayer: Label = $ContenedorCentrado/PanelPergamino/MargenInterno/ColumnaPrincipal/PanelLibroCuentas/MargenCuentas/ColumnaCuentas/FilaMetricas/ColumnaIzq/EtiquetaPedidosAyer
@onready var etiqueta_ganancias_ayer: Label = $ContenedorCentrado/PanelPergamino/MargenInterno/ColumnaPrincipal/PanelLibroCuentas/MargenCuentas/ColumnaCuentas/FilaMetricas/ColumnaIzq/EtiquetaGananciasAyer
@onready var etiqueta_perdidas_ayer: Label = $ContenedorCentrado/PanelPergamino/MargenInterno/ColumnaPrincipal/PanelLibroCuentas/MargenCuentas/ColumnaCuentas/FilaMetricas/ColumnaDer/EtiquetaPerdidasAyer
@onready var etiqueta_saldo_actual: Label = $ContenedorCentrado/PanelPergamino/MargenInterno/ColumnaPrincipal/PanelLibroCuentas/MargenCuentas/ColumnaCuentas/FilaMetricas/ColumnaDer/EtiquetaSaldoActual
@onready var etiqueta_texto_rumor: Label = $ContenedorCentrado/PanelPergamino/MargenInterno/ColumnaPrincipal/PanelRumoresPueblo/MargenRumores/ColumnaRumores/EtiquetaTextoRumor
@onready var boton_comenzar_jornada: Button = $ContenedorCentrado/PanelPergamino/MargenInterno/ColumnaPrincipal/BotonComenzarJornada

const RUMORES_POR_DIA: Dictionary = {
	2: "Los campesinos comentan con alivio en la plaza: el taller de Rodrik vuelve a martillar. El arado de Mateo y el molino de Eustaquio están en marcha, pero la guardia vigila con recelo desde la garita.",
	3: "En la taberna se susurra que el Señor Feudal aumentó los peajes del puente este. Los leñadores y mineros reclaman herramientas resistentes para trabajar antes del toque de queda.",
	4: "Las patrullas de inspección vigilan las esquinas con ojos desconfiados. Se prohíbe a los campesinos transitar de noche. Doña Valeria advierte que los caminos se están volviendo peligrosos.",
	5: "¡ATENCIÓN! Carteles clavados en los postes anuncian duras penas por contrabando y quejas. El emisario feudal exige que ningún herrero entregue piezas sin tributo al castillo.",
	6: "La resistencia silenciosa del pueblo depende del acero y las herramientas de tu fragua. Mientras haya fuego en tu chimenea, habrá esperanza en la comarca."
}

var _cerrando: bool = false

func _ready() -> void:
	layer = 28
	visible = false
	if boton_comenzar_jornada:
		boton_comenzar_jornada.pressed.connect(_on_boton_comenzar_pressed)
	if TimeManager.has_signal("daily_summary_requested"):
		TimeManager.daily_summary_requested.connect(mostrar_resumen)

func _unhandled_input(event: InputEvent) -> void:
	if not visible or _cerrando:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			get_viewport().set_input_as_handled()
			_on_boton_comenzar_pressed()

func mostrar_resumen(datos_resumen: Dictionary) -> void:
	_cerrando = false
	var dia: int = int(datos_resumen.get("nuevo_dia", TimeManager.day))
	var tipo_descanso: String = String(datos_resumen.get("tipo_descanso", "voluntario"))
	var titulo_descanso: String = String(datos_resumen.get("titulo_descanso", "Descanso en Cama"))
	var desc_descanso: String = String(datos_resumen.get("desc_descanso", ""))
	var monedas_robadas: int = int(datos_resumen.get("monedas_robadas", 0))
	var pedidos_ayer: int = int(datos_resumen.get("pedidos_ayer", 0))
	var ganancias_ayer: int = int(datos_resumen.get("ganancias_ayer", 0))
	var saldo_actual: int = int(datos_resumen.get("saldo_actual", GameManager.coins))

	etiqueta_titulo_amanecer.text = "☀️ AMANECER DEL DÍA %d" % dia
	etiqueta_subtitulo.text = "06:00 AM — Despiertas en tus aposentos del taller"

	match tipo_descanso:
		"voluntario":
			etiqueta_titulo_descanso.text = "🛌 %s" % titulo_descanso
			etiqueta_titulo_descanso.modulate = Color(0.96, 0.85, 0.45)
			etiqueta_desc_descanso.text = desc_descanso if not desc_descanso.is_empty() else "Descansaste plácidamente antes de medianoche. Tu vigor ha sido restaurado al 100%."
		"desmayo_taller":
			etiqueta_titulo_descanso.text = "🥱 %s" % titulo_descanso
			etiqueta_titulo_descanso.modulate = Color(0.95, 0.65, 0.35)
			etiqueta_desc_descanso.text = desc_descanso if not desc_descanso.is_empty() else "La medianoche te sorprendió sin descansar. Despiertas con fatiga acumulada (50% de vigor)."
		"desmayo_exterior", _:
			etiqueta_titulo_descanso.text = "🌑 %s" % titulo_descanso
			etiqueta_titulo_descanso.modulate = Color(0.92, 0.38, 0.38)
			etiqueta_desc_descanso.text = desc_descanso if not desc_descanso.is_empty() else "Colapsaste a las 00:00 a la intemperie. Maleantes te robaron %d monedas de oro y sufres fatiga severa (40%% de vigor)." % monedas_robadas

	etiqueta_pedidos_ayer.text = "Encargos ayer: %d completados" % pedidos_ayer
	etiqueta_ganancias_ayer.text = "Ganancias por forja: +%d monedas de oro" % ganancias_ayer
	if monedas_robadas > 0:
		etiqueta_perdidas_ayer.text = "Pérdidas por asalto: -%d monedas de oro" % monedas_robadas
		etiqueta_perdidas_ayer.visible = true
	else:
		etiqueta_perdidas_ayer.text = "Pérdidas nocturnas: 0 monedas"
		etiqueta_perdidas_ayer.visible = true
	etiqueta_saldo_actual.text = "Saldo total en bolsa: %d monedas de oro" % saldo_actual

	var texto_rumor: String = ""
	if RUMORES_POR_DIA.has(dia):
		texto_rumor = String(RUMORES_POR_DIA[dia])
	else:
		texto_rumor = "El pueblo continúa prosperando en secreto gracias a la calidad de tus herramientas y la fuerza del fuego en tu fragua."
	etiqueta_texto_rumor.text = texto_rumor

	# Mostrar con animación suave
	visible = true
	if fondo_atenuado:
		fondo_atenuado.color.a = 0.0
	if panel_pergamino:
		panel_pergamino.modulate.a = 0.0
	var tween: Tween = create_tween().set_parallel(true)
	if fondo_atenuado:
		tween.tween_property(fondo_atenuado, "color:a", 0.85, 0.3)
	if panel_pergamino:
		tween.tween_property(panel_pergamino, "modulate:a", 1.0, 0.35)
	if boton_comenzar_jornada:
		boton_comenzar_jornada.grab_focus()

	AudioManager.play_coins()

func _on_boton_comenzar_pressed() -> void:
	if _cerrando:
		return
	_cerrando = true
	AudioManager.play_place_item()

	var tween: Tween = create_tween().set_parallel(true)
	if fondo_atenuado:
		tween.tween_property(fondo_atenuado, "color:a", 0.0, 0.2)
	if panel_pergamino:
		tween.tween_property(panel_pergamino, "modulate:a", 0.0, 0.2)
	await tween.finished
	visible = false
	_cerrando = false
	resumen_cerrado.emit()
	if TimeManager.has_method("confirmar_inicio_jornada"):
		TimeManager.confirmar_inicio_jornada()
