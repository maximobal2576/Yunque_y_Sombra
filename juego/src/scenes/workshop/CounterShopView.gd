# CounterShopView.gd
# Vista en primera persona detrás del mostrador.
# Muestra la pieza forjada real (Polygon2D) sobre el paño de la mesada y permite arrastrarla
# directamente hacia el cliente en la ventanilla para concretar la entrega y cobrar.
extends Control

signal order_accepted(order_info: Dictionary)
signal go_to_workbench_requested()
signal item_delivered(quality: float, reward: int)

const PORTRAIT_SERGEANT: Texture2D = preload("res://assets/sprites/characters/sergeant_portrait.png")
const PORTRAIT_PEASANT: Texture2D = preload("res://assets/sprites/characters/peasant_portrait.png")

# Nodos en Español
@onready var boton_campana: Button = $MesaMostrador/ContenedorCampana/BotonCampana
@onready var etiqueta_campana: Label = $MesaMostrador/ContenedorCampana/EtiquetaCampana
@onready var efecto_timbre: Label = $MesaMostrador/ContenedorCampana/EfectoTimbre

@onready var contenedor_cliente: Control = $MarcoVentana/ContenedorCliente
@onready var retrato_cliente: TextureRect = $MarcoVentana/ContenedorCliente/RetratoCliente
@onready var personaje_cliente_articulado: Node2D = $MarcoVentana/ContenedorCliente/PersonajeClienteArticulado
@onready var busto_sargento_godofredo: Node2D = $MarcoVentana/ContenedorCliente/PersonajeClienteArticulado/BustoSargentoGodofredo
@onready var busto_molinero_eustaquio: Node2D = $MarcoVentana/ContenedorCliente/PersonajeClienteArticulado/BustoMolineroEustaquio
@onready var busto_mercader_valeria: Node2D = $MarcoVentana/ContenedorCliente/PersonajeClienteArticulado/BustoMercaderValeria
@onready var indicador_entrega_cliente: Panel = $MarcoVentana/ContenedorCliente/IndicadorEntregaCliente
@onready var etiqueta_nombre_cliente: Label = $MarcoVentana/ContenedorCliente/EtiquetaNombre
@onready var etiqueta_estado_cliente: Label = $MarcoVentana/ContenedorCliente/EtiquetaEstado
@onready var caja_dialogo: Panel = $CajaDialogo
@onready var texto_dialogo: Label = $CajaDialogo/TextoDialogo

@onready var pergamino_comanda: Control = $MesaMostrador/PergaminoComanda
@onready var etiqueta_titulo_comanda: Label = $MesaMostrador/PergaminoComanda/ContenedorComanda/EtiquetaTitulo
@onready var etiqueta_desc_comanda: Label = $MesaMostrador/PergaminoComanda/ContenedorComanda/EtiquetaDescripcion
@onready var etiqueta_specs_comanda: Label = $MesaMostrador/PergaminoComanda/ContenedorComanda/EtiquetaEspecificaciones
@onready var etiqueta_paga_comanda: Label = $MesaMostrador/PergaminoComanda/ContenedorComanda/EtiquetaPaga
@onready var boton_aceptar_comanda: Button = $MesaMostrador/PergaminoComanda/ContenedorComanda/BotonAceptarComanda

@onready var bandeja_entrega: Panel = $MesaMostrador/BandejaEntrega
@onready var visual_pieza_entrega: ColorRect = $MesaMostrador/BandejaEntrega/VisualPieza
@onready var pieza_entregable_mesada: Node2D = $MesaMostrador/BandejaEntrega/PiezaEntregableMesada
@onready var sombra_pieza_mesada: Polygon2D = $MesaMostrador/BandejaEntrega/PiezaEntregableMesada/SombraPiezaMesada
@onready var poligono_pieza_terminada: Polygon2D = $MesaMostrador/BandejaEntrega/PiezaEntregableMesada/PoligonoPiezaTerminada
@onready var brillo_especular_pieza: Polygon2D = $MesaMostrador/BandejaEntrega/PiezaEntregableMesada/BrilloEspecularPieza
@onready var contorno_bisel_pieza: Line2D = $MesaMostrador/BandejaEntrega/PiezaEntregableMesada/ContornoBiselPieza
@onready var etiqueta_estado_bandeja: Label = $MesaMostrador/BandejaEntrega/EtiquetaEstadoBandeja
@onready var boton_entregar_pieza: Button = $MesaMostrador/BandejaEntrega/BotonEntregarPieza

@onready var boton_ir_a_forja: Button = $MesaMostrador/BotonIrAForja

# Alias de compatibilidad hacia atrás
var bell_button: Button:
	get: return boton_campana
var bell_label: Label:
	get: return etiqueta_campana
var bell_ring_fx: Label:
	get: return efecto_timbre
var customer_container: Control:
	get: return contenedor_cliente
var customer_portrait: TextureRect:
	get: return retrato_cliente
var customer_name_label: Label:
	get: return etiqueta_nombre_cliente
var customer_status_label: Label:
	get: return etiqueta_estado_cliente
var dialogue_box: Panel:
	get: return caja_dialogo
var dialogue_text: Label:
	get: return texto_dialogo
var order_sheet: Control:
	get: return pergamino_comanda
var order_title_label: Label:
	get: return etiqueta_titulo_comanda
var order_desc_label: Label:
	get: return etiqueta_desc_comanda
var order_specs_label: Label:
	get: return etiqueta_specs_comanda
var order_reward_label: Label:
	get: return etiqueta_paga_comanda
var btn_accept_order: Button:
	get: return boton_aceptar_comanda
var delivery_tray: Panel:
	get: return bandeja_entrega
var tray_item_visual: ColorRect:
	get: return visual_pieza_entrega
var tray_status_label: Label:
	get: return etiqueta_estado_bandeja
var btn_deliver_item: Button:
	get: return boton_entregar_pieza
var btn_to_forge: Button:
	get: return boton_ir_a_forja

const POSICION_PIEZA_EN_BANDEJA: Vector2 = Vector2(190.0, 92.0)

var customers: Array[Dictionary] = [
	{
		"name": "Sargento Godofredo (Guardia Feudal)",
		"faction": "Patrulla del Feudo",
		"visual_id": "sargento",
		"portrait": PORTRAIT_SERGEANT,
		"dialogue_intro": "Tú debes ser el sobrino del viejo herrero... No hagas preguntas indiscretas. Necesito un clavo de Hierro Dulce reforzado para la compuerta de la mazmorra. Que tenga buena cabeza y punta firme.",
		"dialogue_good": "Mmh... cabeza bien recalcada y templado parejo. Tu tío tenía buena técnica y veo que la heredas. Toma tus monedas y no hables de esto.",
		"dialogue_bad": "¡Esto es una porquería quebradiza! Si la compuerta cede, te colgaré de las vigas del taller. No esperes buena paga por esta basura.",
		"item_name": "Clavo Forjado de Compuerta",
		"required_metal": "hierro_dulce",
		"description": "Clavo de hierro dulce con cabeza ancha y espiga cónica para roble pesado.",
		"specs": "• Barril: Hierro Dulce\n• Fragua: 1000°C - 1150°C\n• Yunque: Cabeza ancha + espiga\n• Corte: Cizallar 3 rebabas\n• Temple y Pulido: Acero limpio",
		"base_reward": 25
	},
	{
		"name": "Eustaquio el Molinero",
		"faction": "Aldeano del Bajo Pueblo",
		"visual_id": "molinero",
		"portrait": PORTRAIT_PEASANT,
		"dialogue_intro": "¡Muchacho, qué alivio ver humo saliendo de la chimenea! El eje de la noria de mi molino se soltó. Necesito un perno de Acero al Carbono resistente antes de perder la molienda.",
		"dialogue_good": "¡Qué bendición de pieza! Brillante y sólida como piedra. Te pagaré hasta la última moneda, ¡salvaste mi molienda!",
		"dialogue_bad": "Ay... el metal tiene grietas y está todo disparejo. No aguantará ni tres giros de la rueda. Te daré solo una limosna.",
		"item_name": "Perno Rústico de Molino",
		"required_metal": "acero_carbono",
		"description": "Perno de acero al carbono capaz de resistir la vibración de la rueda hidráulica.",
		"specs": "• Barril: Acero al Carbono\n• Fragua: 1000°C - 1150°C\n• Yunque: Expansión simétrica\n• Corte: Sin rebabas\n• Temple y Pulido: Acero tenaz",
		"base_reward": 20
	},
	{
		"name": "Doña Valeria (Mercader de Caravanas)",
		"faction": "Gremio Mercantil de la Comarca",
		"visual_id": "mercader",
		"portrait": PORTRAIT_PEASANT,
		"dialogue_intro": "Buenas tardes, joven maestro. Mi carromato de especias sufrió un percance en el puente viejo y requiero un pasador de Bronce de Forja que no se oxide con la humedad del camino.",
		"dialogue_good": "¡Exquisito acabado y proporciones impecables! Se nota la mano de un verdadero artesano. Aquí tienes tu bolsa de oro bien ganada.",
		"dialogue_bad": "Qué pieza tan tosca y mal batida... Supongo que servirá para salir del paso, pero no puedo pagarte el precio completo.",
		"item_name": "Perno de Bronce de Caravana",
		"required_metal": "bronce_cobre",
		"description": "Pasador de bronce forjado resistente a la intemperie para el eje del carromato.",
		"specs": "• Barril: Bronce de Forja\n• Fragua: 1000°C - 1150°C\n• Yunque: Cabeza firme + espiga\n• Corte: Sin rebabas\n• Temple y Pulido: Brillo dorado",
		"base_reward": 30
	}
]

var current_customer_index: int = 0
var active_order: Dictionary = {}
var has_active_order: bool = false
var has_finished_piece: bool = false
var finished_piece_quality: float = 0.0
var _arrastrando_pieza_entrega: bool = false
var _tiempo_anim_cliente: float = 0.0
var _convocando_cliente: bool = false

func _ready() -> void:
	bell_button.pressed.connect(_on_bell_clicked)
	btn_accept_order.pressed.connect(_on_accept_order_pressed)
	btn_to_forge.pressed.connect(_on_go_to_forge_pressed)
	btn_deliver_item.pressed.connect(_on_deliver_item_pressed)
	bandeja_entrega.gui_input.connect(_on_bandeja_entrega_gui_input)

	order_sheet.visible = false
	delivery_tray.visible = false
	btn_to_forge.visible = false
	dialogue_box.visible = false
	bell_ring_fx.visible = false
	customer_container.modulate.a = 0.0
	if indicador_entrega_cliente:
		indicador_entrega_cliente.visible = false

	bell_label.text = "Toca la campana"
	_actualizar_busto_cliente("sargento")

func reset_if_stuck() -> void:
	if _convocando_cliente:
		return
	if not order_sheet.visible and not delivery_tray.visible:
		has_active_order = false
		has_finished_piece = false
		bell_label.text = "Toca la campana"
	elif order_sheet.visible and btn_accept_order.disabled and not delivery_tray.visible:
		btn_to_forge.visible = true

func _process(delta: float) -> void:
	if not visible or not is_visible_in_tree():
		return
	_tiempo_anim_cliente += delta
	if personaje_cliente_articulado and customer_container.modulate.a > 0.05:
		# Respiración orgánica y ligero balanceo del cliente en la ventanilla
		var resp: float = sin(_tiempo_anim_cliente * 2.4)
		personaje_cliente_articulado.position.y = 178.0 + resp * 2.2
		personaje_cliente_articulado.scale = Vector2(1.0 + resp * 0.008, 1.0 - resp * 0.010)
		var cabeza_activa: Node2D = _obtener_cabeza_cliente_activa()
		if cabeza_activa:
			cabeza_activa.rotation = sin(_tiempo_anim_cliente * 1.4) * 0.032

func _obtener_cabeza_cliente_activa() -> Node2D:
	if busto_sargento_godofredo and busto_sargento_godofredo.visible:
		return busto_sargento_godofredo.get_node_or_null("CabezaCliente") as Node2D
	if busto_molinero_eustaquio and busto_molinero_eustaquio.visible:
		return busto_molinero_eustaquio.get_node_or_null("CabezaMolinero") as Node2D
	if busto_mercader_valeria and busto_mercader_valeria.visible:
		return busto_mercader_valeria.get_node_or_null("CabezaMercader") as Node2D
	return null

func _actualizar_busto_cliente(visual_id: String) -> void:
	if busto_sargento_godofredo:
		busto_sargento_godofredo.visible = (visual_id == "sargento")
	if busto_molinero_eustaquio:
		busto_molinero_eustaquio.visible = (visual_id == "molinero")
	if busto_mercader_valeria:
		busto_mercader_valeria.visible = (visual_id == "mercader")

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if order_sheet.visible and not btn_accept_order.disabled:
				_on_accept_order_pressed()
			elif delivery_tray.visible and not btn_deliver_item.disabled:
				_on_deliver_item_pressed()

func _input(event: InputEvent) -> void:
	if not visible or not _arrastrando_pieza_entrega:
		return
	if event is InputEventMouseMotion:
		if pieza_entregable_mesada:
			pieza_entregable_mesada.global_position = get_global_mouse_position()
		var sobre_cliente: bool = _cursor_sobre_zona_cliente(get_global_mouse_position())
		if indicador_entrega_cliente:
			indicador_entrega_cliente.modulate = Color(0.55, 1.0, 0.65, 1.0) if sobre_cliente else Color(1, 1, 1, 0.85)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_finalizar_arrastre_pieza(get_global_mouse_position())

func _on_bandeja_entrega_gui_input(event: InputEvent) -> void:
	if not has_finished_piece or btn_deliver_item.disabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_iniciar_arrastre_pieza()

func _iniciar_arrastre_pieza() -> void:
	_arrastrando_pieza_entrega = true
	AudioManager.play_sfx("place_item", -2.5, 0.07)
	if indicador_entrega_cliente:
		indicador_entrega_cliente.visible = true
	if pieza_entregable_mesada:
		pieza_entregable_mesada.scale = Vector2(1.14, 1.14)
		pieza_entregable_mesada.global_position = get_global_mouse_position()
	if sombra_pieza_mesada:
		sombra_pieza_mesada.position = Vector2(12, 16)
	bell_label.text = "Arrastra la pieza hasta el cliente en la ventanilla y suéltala para entregar."

func _finalizar_arrastre_pieza(pos_global_soltado: Vector2) -> void:
	_arrastrando_pieza_entrega = false
	if indicador_entrega_cliente:
		indicador_entrega_cliente.visible = false
	if _cursor_sobre_zona_cliente(pos_global_soltado):
		_on_deliver_item_pressed()
	else:
		# Regresar suavemente la pieza al paño de cuero en la mesada
		AudioManager.play_sfx("place_item", 0.5, 0.05)
		if pieza_entregable_mesada:
			var tw: Tween = create_tween().set_parallel(true)
			tw.tween_property(pieza_entregable_mesada, "position", POSICION_PIEZA_EN_BANDEJA, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(pieza_entregable_mesada, "scale", Vector2(0.88, 0.88), 0.22)
		if sombra_pieza_mesada:
			sombra_pieza_mesada.position = Vector2(5, 7)

func _cursor_sobre_zona_cliente(pos_global: Vector2) -> bool:
	if contenedor_cliente and contenedor_cliente.get_global_rect().grow(45.0).has_point(pos_global):
		return true
	# También aceptar si el jugador arrastra la pieza hacia la mitad superior de la ventanilla
	return pos_global.y < 430.0

func _on_bell_clicked() -> void:
	AudioManager.play_bell()
	var bell_tween: Tween = create_tween()
	bell_tween.tween_property(bell_button, "scale", Vector2(1.2, 0.85), 0.06)
	bell_tween.tween_property(bell_button, "scale", Vector2(0.9, 1.15), 0.08)
	bell_tween.tween_property(bell_button, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_ELASTIC)

	bell_ring_fx.visible = true
	bell_ring_fx.modulate.a = 1.0
	bell_ring_fx.position.y = -30.0
	var fx_tween: Tween = create_tween().set_parallel(true)
	fx_tween.tween_property(bell_ring_fx, "position:y", -55.0, 0.45)
	fx_tween.tween_property(bell_ring_fx, "modulate:a", 0.0, 0.45)
	fx_tween.chain().tween_callback(func(): bell_ring_fx.visible = false)

	if _convocando_cliente:
		return
	if (not has_active_order and not has_finished_piece) or (not order_sheet.visible and not delivery_tray.visible):
		has_active_order = false
		has_finished_piece = false
		_summon_customer()

func _summon_customer() -> void:
	if _convocando_cliente:
		return
	_convocando_cliente = true
	var customer: Dictionary = customers[current_customer_index]
	active_order = customer

	customer_portrait.texture = customer["portrait"]
	_actualizar_busto_cliente(str(customer.get("visual_id", "sargento")))
	customer_name_label.text = customer["name"]
	customer_status_label.text = customer["faction"]

	var center_x: float = (size.x - customer_container.size.x) * 0.5 if size.x > 0 else 540.0
	customer_container.position.x = center_x + 70.0
	customer_container.modulate.a = 0.0
	var enter_tween: Tween = create_tween().set_parallel(true)
	enter_tween.tween_property(customer_container, "position:x", center_x, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	enter_tween.tween_property(customer_container, "modulate:a", 1.0, 0.45)

	await enter_tween.finished

	dialogue_box.visible = true
	dialogue_text.text = customer["dialogue_intro"]

	AudioManager.play_sfx("place_item", 0.5, 0.05)
	order_sheet.visible = true
	order_sheet.modulate.a = 0.0
	order_sheet.pivot_offset = order_sheet.size * 0.5
	order_sheet.scale = Vector2(0.86, 1.12)
	order_title_label.text = "COMANDA: %s" % customer["item_name"]
	order_desc_label.text = customer["description"]
	order_specs_label.text = customer["specs"]
	order_reward_label.text = "Paga ofrecida: %d Monedas de Oro" % customer["base_reward"]
	btn_accept_order.disabled = false
	btn_accept_order.text = "Aceptar Encargo y Forjar"

	var order_tween: Tween = create_tween().set_parallel(true)
	order_tween.tween_property(order_sheet, "modulate:a", 1.0, 0.25)
	order_tween.tween_property(order_sheet, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	bell_label.text = "Cliente en ventanilla: Revisa la comanda y acéptala"
	_convocando_cliente = false

func _on_accept_order_pressed() -> void:
	has_active_order = true
	AudioManager.play_sfx("place_item", 0.5, 0.05)
	btn_accept_order.disabled = true
	btn_accept_order.text = "Encargo en Proceso"
	btn_to_forge.visible = true
	if order_sheet:
		order_sheet.pivot_offset = order_sheet.size * 0.5
		var tw_acc: Tween = create_tween()
		tw_acc.tween_property(order_sheet, "scale", Vector2(1.06, 0.94), 0.07)
		tw_acc.tween_property(order_sheet, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	bell_label.text = "Encargo aceptado. Ve a la forja para iniciar la manufactura."
	emit_signal("order_accepted", active_order)

func _on_go_to_forge_pressed() -> void:
	emit_signal("go_to_workbench_requested")

func set_piece_ready_for_delivery(quality: float, crafted_shape: PackedVector2Array = PackedVector2Array(), metal_tint: Color = Color(0.72, 0.76, 0.80)) -> void:
	has_finished_piece = true
	finished_piece_quality = quality
	_arrastrando_pieza_entrega = false
	AudioManager.play_sfx("place_item", 0.5, 0.05)

	order_sheet.visible = false
	delivery_tray.visible = true
	delivery_tray.modulate.a = 0.0
	delivery_tray.pivot_offset = delivery_tray.size * 0.5
	delivery_tray.scale = Vector2(0.88, 1.12)
	btn_to_forge.visible = false
	if indicador_entrega_cliente:
		indicador_entrega_cliente.visible = false

	var color_acero_final: Color = Color(0.36, 0.40, 0.45).lerp(metal_tint, clampf(quality, 0.25, 1.0))
	tray_item_visual.color = color_acero_final

	_configurar_geometria_pieza_mesada(crafted_shape, color_acero_final)

	tray_status_label.text = "%s (Calidad: %.0f%%) — Arrastra al cliente" % [
		active_order.get("item_name", "Clavo Forjado"),
		quality * 100.0
	]
	btn_deliver_item.disabled = false
	btn_deliver_item.text = "Entregar Pieza (o arrastra al cliente)"

	var tray_tween: Tween = create_tween().set_parallel(true)
	tray_tween.tween_property(delivery_tray, "modulate:a", 1.0, 0.28)
	tray_tween.tween_property(delivery_tray, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	bell_label.text = "Arrastra al cliente"

func _configurar_geometria_pieza_mesada(crafted_shape: PackedVector2Array, color_acero: Color) -> void:
	var poly: PackedVector2Array = crafted_shape
	if poly.size() < 4:
		poly = PackedVector2Array([
			Vector2(-128, 0),
			Vector2(-122, -22),
			Vector2(-86, -22),
			Vector2(-82, -12),
			Vector2(85, -8),
			Vector2(118, 0),
			Vector2(85, 8),
			Vector2(-82, 12),
			Vector2(-86, 22),
			Vector2(-122, 22)
		])

	if pieza_entregable_mesada:
		pieza_entregable_mesada.position = POSICION_PIEZA_EN_BANDEJA
		pieza_entregable_mesada.scale = Vector2(0.88, 0.88)
	if poligono_pieza_terminada:
		poligono_pieza_terminada.polygon = poly
		poligono_pieza_terminada.color = color_acero
	if sombra_pieza_mesada:
		sombra_pieza_mesada.polygon = poly
		sombra_pieza_mesada.position = Vector2(5, 7)
	if contorno_bisel_pieza:
		contorno_bisel_pieza.clear_points()
		for pt in poly:
			contorno_bisel_pieza.add_point(pt)
		contorno_bisel_pieza.add_point(poly[0])
		contorno_bisel_pieza.default_color = color_acero.lightened(0.28)
	if brillo_especular_pieza:
		var pts_brillo: PackedVector2Array = PackedVector2Array()
		for pt in poly:
			pts_brillo.append(Vector2(pt.x * 0.82, pt.y * 0.38 - 3.0))
		brillo_especular_pieza.polygon = pts_brillo

func _on_deliver_item_pressed() -> void:
	if btn_deliver_item.disabled:
		return
	btn_deliver_item.disabled = true
	_arrastrando_pieza_entrega = false
	if indicador_entrega_cliente:
		indicador_entrega_cliente.visible = false

	var customer: Dictionary = active_order if not active_order.is_empty() else customers[0]
	var is_good: bool = finished_piece_quality >= 0.70
	var base_reward: int = int(customer.get("base_reward", 20))
	var final_reward: int = int(float(base_reward) * finished_piece_quality)
	if final_reward < 5:
		final_reward = 5

	dialogue_box.visible = true
	var item_name: String = str(customer.get("item_name", "Clavo Forjado"))
	if is_good:
		dialogue_text.text = str(customer.get("dialogue_good", "¡Excelente trabajo!")) + ("\n[Cobraste +%d monedas]" % final_reward)
	else:
		dialogue_text.text = str(customer.get("dialogue_bad", "Trabajo tosco.")) + ("\n[Cobraste solo +%d monedas]" % final_reward)

	GameManager.record_crafted_item(item_name, finished_piece_quality, final_reward)
	AudioManager.play_coins()
	emit_signal("item_delivered", finished_piece_quality, final_reward)

	var center_x: float = (size.x - customer_container.size.x) * 0.5 if size.x > 0 else 540.0
	var exit_tween: Tween = create_tween().set_parallel(true)
	exit_tween.tween_property(customer_container, "position:x", center_x - 100.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	exit_tween.tween_property(customer_container, "modulate:a", 0.0, 0.5)
	exit_tween.tween_property(delivery_tray, "modulate:a", 0.0, 0.4)

	await exit_tween.finished
	delivery_tray.visible = false
	has_active_order = false
	has_finished_piece = false
	_convocando_cliente = false
	current_customer_index = (current_customer_index + 1) % customers.size()
	bell_label.text = "Toca la campana"
