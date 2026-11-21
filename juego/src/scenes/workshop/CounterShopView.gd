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
var order_item_label: Label:
	get: return etiqueta_desc_comanda
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
const VELOCIDAD_REVELADO_RECETA: float = 0.42
const MAX_PEDIDOS_DIA_1: int = 3
var max_pedidos_hoy: int = 3

const ROSTER_POR_DIA: Dictionary = {
	1: [
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
			"specs": "• Barril: Hierro Dulce\n• Fragua: 1000°C - 1160°C (Fusión 1200°C)\n• Yunque: Cabeza ancha + espiga\n• Corte: Cizallar 3 rebabas\n• Temple y Pulido: Acero limpio",
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
			"specs": "• Barril: Acero al Carbono\n• Fragua: 920°C - 1040°C (Fusión 1140°C)\n• Yunque: Expansión firme (Duro)\n• Corte: Sin rebabas\n• Temple y Pulido: Acero tenaz",
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
			"specs": "• Barril: Bronce de Forja\n• Fragua: 740°C - 870°C (Fusión 1010°C)\n• Yunque: Alta maleabilidad\n• Corte: Sin rebabas\n• Temple y Pulido: Brillo dorado",
			"base_reward": 30
		}
	],
	2: [
		{
			"name": "Mateo el Granjero",
			"faction": "Agricultores del Valle Norte",
			"visual_id": "molinero",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "¡Buen día, muchacho! La reja de mi arado chocó contra una roca y se partió en dos. La siembra de cebada no espera. Necesito una reja reforzada de Hierro Dulce que abra surcos firmes.",
			"dialogue_good": "¡Qué fortaleza de hierro! Se nota que tiene buen templado y perfil limpio. Podré arar hasta el ocaso sin temor. ¡Toma tu paga bien merecida!",
			"dialogue_bad": "Mmh... la hoja quedó torcida y el filo disparejo. Al primer pedrusco se doblará. Te pagaré una suma módica.",
			"item_name": "Reja de Arado Reforzada",
			"required_metal": "hierro_dulce",
			"description": "Reja de hierro dulce para arado de tiro, con ángulo penetrante y espiga de sujeción.",
			"specs": "• Barril: Hierro Dulce\n• Fragua: 1000°C - 1160°C (Fusión 1200°C)\n• Yunque: Pala triangular ancha\n• Corte: Sin rebabas\n• Temple y Pulido: Resistencia dúctil",
			"base_reward": 28
		},
		{
			"name": "Anselmo el Herrero Viejo",
			"faction": "Veteranos del Yunque",
			"visual_id": "molinero",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "Hrmpf... Veo que reviviste el fuego de mi compadre Rodrik. Ya mis manos tiemblan con las tenazas. Necesito una herradura de tiro en Hierro Dulce para el tiro comunal de bueyes.",
			"dialogue_good": "Mmh, nada mal, jovenzuelo... Tienes buen pulso en el yunque y claveras limpias. Rodrik estaría orgulloso. Toma tu dinero.",
			"dialogue_bad": "¡La clavera está descentrada y el talón muy fino! Tienes que aprender a escuchar el metal antes de golpearlo. Te pagaré lo justo.",
			"item_name": "Herradura de Tiro Pesado",
			"required_metal": "hierro_dulce",
			"description": "Herradura ancha de hierro dulce para buey de tiro comunal.",
			"specs": "• Barril: Hierro Dulce\n• Fragua: 1000°C - 1160°C (Fusión 1200°C)\n• Yunque: Curvatura simétrica\n• Corte: Desbaste de rebabas\n• Temple y Pulido: Enfriado parejo",
			"base_reward": 25
		},
		{
			"name": "Greta la Tabernera",
			"faction": "Taberna El Callejón Hundido",
			"visual_id": "mercader",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "¡Hola artesano! Con este frío los leñadores exigen su guisado hirviendo y mi trípode de hierro viejo se desfondó. Necesito uno nuevo de Bronce de Forja con patas firmes que aguante las brasas.",
			"dialogue_good": "¡Qué hermosura de acabado, brilla como oro viejo! Esta noche en la taberna brindaremos por el nuevo herrero. ¡Aquí tienes tu buena recompensa!",
			"dialogue_bad": "Una de las patas quedó más corta que las otras... Tendré que calzarlo con piedras en el fogón. Te daré lo que vale.",
			"item_name": "Trípode de Brasa para Caldero",
			"required_metal": "bronce_cobre",
			"description": "Trípode de bronce forjado de tres patas estables para fuego directo.",
			"specs": "• Barril: Bronce de Forja\n• Fragua: 740°C - 870°C (Fusión 1010°C)\n• Yunque: Patas triples simétricas\n• Corte: 3 cortes limpios\n• Temple y Pulido: Brillo cobrizo",
			"base_reward": 30
		}
	],
	3: [
		{
			"name": "Baldomero el Leñador",
			"faction": "Gremio de Madereros de la Quebrada",
			"visual_id": "molinero",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "¡Saludos, herrero! El roble centenario del linde me melló el hacha de talar. Necesito una hoja de Acero al Carbono con ojo ancho y temple firme que muerda madera dura sin quebrarse.",
			"dialogue_good": "¡Por las barbas del bosque, qué filo y qué balance! Esta hoja cantará al rozar la madera. ¡Monedas de oro bien ganadas, amigo!",
			"dialogue_bad": "El filo está desdentado y el metal tiene fisuras. Tendré que pasarle la piedra arenisca horas enteras. Te daré una paga corta.",
			"item_name": "Hacha de Talar de Filo Tenaz",
			"required_metal": "acero_carbono",
			"description": "Hoja pesada de hacha en acero al carbono templado para corte de leña dura.",
			"specs": "• Barril: Acero al Carbono\n• Fragua: 920°C - 1040°C (Fusión 1140°C)\n• Yunque: Hoja cuneiforme y ojo centrado\n• Corte: Cizallar rebabas\n• Temple y Pulido: Filo brillante",
			"base_reward": 32
		},
		{
			"name": "Gorki el Minero",
			"faction": "Piconeros de la Galería Sur",
			"visual_id": "molinero",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "¡Hola, compañero de martillo! En la galería profunda de la mina encontramos una veta de hierro en roca viva. Necesitamos un pico de barreno de Acero al Carbono con punta templada.",
			"dialogue_good": "¡Macizo como la entraña de la montaña! Con este pico quebraremos cualquier roca sin miedo a romper la punta. ¡Aquí tienes tu bolsa de monedas!",
			"dialogue_bad": "La punta quedó roma y blanda... Al tercer golpe se achatará contra el pedernal. No mereces más que una paga mínima.",
			"item_name": "Pico de Barreno Profundo",
			"required_metal": "acero_carbono",
			"description": "Pico de minería en acero al carbono de alta penetración para vetas duras.",
			"specs": "• Barril: Acero al Carbono\n• Fragua: 920°C - 1040°C (Fusión 1140°C)\n• Yunque: Puntas cónicas opuestas\n• Corte: Cizallado parejo\n• Temple y Pulido: Acero endurecido",
			"base_reward": 35
		},
		{
			"name": "Teo el Tonelero",
			"faction": "Bodegueros del Valle Bajo",
			"visual_id": "mercader",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "¡Buenas tardes, artesano! El mosto fermentado de la vendimia carcome el hierro común. Necesito un zuncho resistente en Bronce de Forja para apretar la gran barrica de roble.",
			"dialogue_good": "¡Curvatura perfecta y flexibilidad justa! Mis barricas de vino estarán a salvo de filtraciones. ¡Toma tu oro y gracias!",
			"dialogue_bad": "La banda tiene espesores disparejos. Va a aflojarse con la presión de la fermentación. Te pagaré lo que considero justo.",
			"item_name": "Zuncho de Barril de Mosto",
			"required_metal": "bronce_cobre",
			"description": "Aro de unión en bronce forjado anticorrosivo para toneles y cubas.",
			"specs": "• Barril: Bronce de Forja\n• Fragua: 740°C - 870°C (Fusión 1010°C)\n• Yunque: Banda maleable alargada\n• Corte: Retirar rebabas de borde\n• Temple y Pulido: Sin cascarilla",
			"base_reward": 28
		}
	],
	4: [
		{
			"name": "Sargento Godofredo (Guardia Feudal)",
			"faction": "Patrulla de Inspección Feudal",
			"visual_id": "sargento",
			"portrait": PORTRAIT_SERGEANT,
			"dialogue_intro": "Herrero... La guarnición del feudo está realizando rondas nocturnas extraordinarias. Necesito una daga corta de inspección en Acero al Carbono. Y recuerda: el Señor Feudal vigila a quienes forjan a deshoras.",
			"dialogue_good": "Hoja recta, filo templado y espiga sólida. Sabes hacer tu oficio sin hacer demasiadas preguntas. Toma tus monedas y mantén el perfil bajo.",
			"dialogue_bad": "¡Una hoja mellada e indigna de un soldado feudal! Da gracias de que no te decomise los fuelles por desacato. Te daré unas pocas monedas.",
			"item_name": "Daga Corta de Inspección",
			"required_metal": "acero_carbono",
			"description": "Daga militar corta forjada en acero al carbono con filo de punzada.",
			"specs": "• Barril: Acero al Carbono\n• Fragua: 920°C - 1040°C (Fusión 1140°C)\n• Yunque: Hoja corta y espiga firme\n• Corte: Cizalla precisa\n• Temple y Pulido: Acero reluciente",
			"base_reward": 35
		},
		{
			"name": "Don Claudio el Albañil",
			"faction": "Constructores del Concejo Aldeano",
			"visual_id": "molinero",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "Saludos, muchacho. Los guardias del feudo cerraron el camino comunal y tuvimos que asegurar el portón de piedra del granero viejo. Necesito bisagras pesadas de Hierro Dulce con buenos anclajes.",
			"dialogue_good": "¡Qué robustez de goznes! Ni los carromatos de la guardia podrán forzar ese portón. Muchas gracias, el pueblo te lo agradece.",
			"dialogue_bad": "Los agujeros están desnivelados. El portón va a chirriar y descolgarse en dos semanas. Te daré lo poco que tengo.",
			"item_name": "Bisagras de Portón Pesado",
			"required_metal": "hierro_dulce",
			"description": "Par de goznes anchos de hierro dulce para compuertas de piedra comunales.",
			"specs": "• Barril: Hierro Dulce\n• Fragua: 1000°C - 1160°C (Fusión 1200°C)\n• Yunque: Placas planas con cilindro de perno\n• Corte: Desbaste de rebabas\n• Temple y Pulido: Acero limpio",
			"base_reward": 30
		},
		{
			"name": "Niña Lira",
			"faction": "Vecindario del Caserío Sur",
			"visual_id": "mercader",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "¡Hola señor herrero! En las mañanas hay mucha niebla en los pantanos y los soldados cabalgan sin mirar. ¿Me forjas un cascabel sonoro de Bronce para colgarle a la cabra de mi abuela?",
			"dialogue_good": "¡Suena hermoso y clarito como una campana de fiesta! Mi abuela me dio sus ahorros en monedas para pagarte. ¡Muchas gracias señor!",
			"dialogue_bad": "Casi no suena... suena sordo como una lata abollada. Pero te dejo mis pocas moneditas igual.",
			"item_name": "Cascabel Sonoro de Niebla",
			"required_metal": "bronce_cobre",
			"description": "Cascabel hueco en bronce de forja de alta resonancia acústica.",
			"specs": "• Barril: Bronce de Forja\n• Fragua: 740°C - 870°C (Fusión 1010°C)\n• Yunque: Cúpula esférica hueca con badajo\n• Corte: Rebaba pulida\n• Temple y Pulido: Resonancia limpia",
			"base_reward": 24
		}
	],
	5: [
		{
			"name": "Capitán de la Guarnición Feudal",
			"faction": "Fuerzas del Señor Feudal",
			"visual_id": "sargento",
			"portrait": PORTRAIT_SERGEANT,
			"dialogue_intro": "Atención, herrero. El Señor Feudal ha notado murmullos y reuniones sospechosas en la plaza tras el anochecer. Se acabó la paciencia. Forjarás de inmediato un juego de Cadenas Pesadas de Contención en Hierro Dulce reforzado. Y un consejo gratis: ocúpate de tu fuelle y olvida lo que viste.",
			"dialogue_good": "Eslabones sólidos y sin fisuras. Estas cadenas silenciarán cualquier conato de rebeldía campesina. Toma esta generosa bolsa de la corte feudal... y sé prudente.",
			"dialogue_bad": "¡Eslabones frágiles! ¿Acaso simpatizas con los rebeldes de la taberna? Si un prisionero rompe esto, tú ocuparás su lugar. Toma estas miserables monedas.",
			"item_name": "Cadenas Pesadas de Contención",
			"required_metal": "hierro_dulce",
			"description": "Eslabones de contención carcelaria forjados en hierro dulce grueso soldados a martillo.",
			"specs": "• Barril: Hierro Dulce\n• Fragua: 1000°C - 1160°C (Fusión 1200°C)\n• Yunque: Eslabones gruesos soldados a fuego\n• Corte: Cizallado limpio\n• Temple y Pulido: Acero negro endurecido",
			"base_reward": 50
		},
		{
			"name": "Aldeano Asustado",
			"faction": "Vecinos en Resistencia Silenciosa",
			"visual_id": "molinero",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "(Mira aterrado a ambos lados de la calle antes de susurrar)... Muchacho, por favor... La guardia requisó la harina de mi compadre Eustaquio. Vienen por las casas de noche. Necesito un cerrojo oculto de Acero al Carbono para la trampilla del sótano. Si los soldados lo descubren, no me conoces.",
			"dialogue_good": "¡Gracias a los cielos, encaja perfecto y corre sin hacer ruido! Mis hijos tendrán comida segura. Toma todas mis monedas, te las debo con el alma.",
			"dialogue_bad": "Se traba al empujarlo y rechina... si los guardias lo escuchan nos atraparán. Te doy lo que me queda en el bolsillo...",
			"item_name": "Cerrojo Oculto de Doble Traba",
			"required_metal": "acero_carbono",
			"description": "Mecanismo discreto de cerrojo y pasador en acero al carbono para trampillas ocultas.",
			"specs": "• Barril: Acero al Carbono\n• Fragua: 920°C - 1040°C (Fusión 1140°C)\n• Yunque: Pasador templado y traba elástica\n• Corte: Sin esquinas delatoras\n• Temple y Pulido: Acero disimulado",
			"base_reward": 35
		},
		{
			"name": "Doña Valeria (Mercader de Caravanas)",
			"faction": "Gremio Mercantil de la Comarca",
			"visual_id": "mercader",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "Joven artesano... La guarnición impuso un arancel confiscatorio y bloqueó el puente de piedra. Si nos quedamos, nos dejarán en la miseria. Necesito placas de refuerzo en Bronce de Forja para desviar las carretas por el viejo sendero del acantilado antes del alba.",
			"dialogue_good": "¡Bendita sea tu destreza! Con estos refuerzos atravesaremos el desfiladero sin romper los ejes. ¡Toma esta bolsa de oro y que los caminos te protejan!",
			"dialogue_bad": "Las placas son delgadas... espero que aguanten el peso del cargamento. Te daré tu recompensa aunque no sea el trabajo más fino.",
			"item_name": "Refuerzo de Carromato para Fuga",
			"required_metal": "bronce_cobre",
			"description": "Placas angulares en bronce de forja resistente a impactos y fatiga de caminos agrestes.",
			"specs": "• Barril: Bronce de Forja\n• Fragua: 740°C - 870°C (Fusión 1010°C)\n• Yunque: Placas de unión en ángulo reforzado\n• Corte: Sin rebabas filosas\n• Temple y Pulido: Brillo bronceado",
			"base_reward": 40
		}
	]
}

var customers: Array[Dictionary] = []

var current_customer_index: int = 0
var pedidos_entregados_hoy: int = 0
var clientes_atendidos_indices: Array[int] = []
var _cliente_presente_en_ventanilla: bool = false
var active_order: Dictionary = {}
var has_active_order: bool = false
var has_finished_piece: bool = false
var finished_piece_quality: float = 0.0
var _arrastrando_pieza_entrega: bool = false
var _tiempo_anim_cliente: float = 0.0
var _convocando_cliente: bool = false
var _hablando_cliente: bool = false
var _saltar_escritura_dialogo: bool = false
var _revelando_comanda: bool = false
var _tween_comanda_texto: Tween = null

const PITCH_VOZ_CLIENTE: Dictionary = {
	"sargento": 0.82,
	"molinero": 0.98,
	"mercader": 1.16
}

func _ready() -> void:
	bell_button.pressed.connect(_on_bell_clicked)
	btn_accept_order.pressed.connect(_on_accept_order_pressed)
	btn_to_forge.pressed.connect(_on_go_to_forge_pressed)
	btn_deliver_item.pressed.connect(_on_deliver_item_pressed)
	bandeja_entrega.gui_input.connect(_on_bandeja_entrega_gui_input)
	visibility_changed.connect(_on_visibility_changed)
	if caja_dialogo:
		caja_dialogo.gui_input.connect(_on_caja_dialogo_gui_input)

	_asegurar_nodos_boca_clientes()

	order_sheet.visible = false
	delivery_tray.visible = false
	btn_to_forge.visible = false
	dialogue_box.visible = false
	bell_ring_fx.visible = false
	customer_container.modulate.a = 0.0
	if indicador_entrega_cliente:
		indicador_entrega_cliente.visible = false

	if TimeManager.has_signal("day_started"):
		TimeManager.day_started.connect(func(d: int) -> void: reiniciar_jornada_mostrador(d))
	if TimeManager.has_signal("shop_closed"):
		TimeManager.shop_closed.connect(_on_shop_closed)
	if TimeManager.has_signal("shop_opened"):
		TimeManager.shop_opened.connect(_on_shop_opened)

	reiniciar_jornada_mostrador(TimeManager.day if "day" in TimeManager else 1)

func _on_shop_closed() -> void:
	if pedidos_entregados_hoy < max_pedidos_hoy:
		bell_button.disabled = true
		bell_label.text = "17:00 PM — Portón comercial cerrado por hoy. Ve a descansar o a la mina."

func _on_shop_opened() -> void:
	if pedidos_entregados_hoy < max_pedidos_hoy:
		bell_button.disabled = false
		bell_label.text = "Aguardando llegada de ciudadano..."
		if is_inside_tree() and is_visible_in_tree():
			call_deferred("_verificar_llegada_automatica_ciudadano")

func _on_visibility_changed() -> void:
	if is_inside_tree() and is_visible_in_tree():
		_verificar_llegada_automatica_ciudadano()

func _verificar_llegada_si_visible() -> void:
	if is_inside_tree() and is_visible_in_tree():
		_verificar_llegada_automatica_ciudadano()

func reiniciar_jornada_mostrador(dia_actual: int = -1) -> void:
	var dia: int = dia_actual if dia_actual > 0 else (TimeManager.day if "day" in TimeManager else 1)
	customers = _obtener_clientes_para_dia(dia)
	max_pedidos_hoy = customers.size()
	pedidos_entregados_hoy = 0
	clientes_atendidos_indices.clear()
	_cliente_presente_en_ventanilla = false
	has_active_order = false
	has_finished_piece = false
	_convocando_cliente = false
	current_customer_index = 0
	order_sheet.visible = false
	delivery_tray.visible = false
	btn_to_forge.visible = false
	dialogue_box.visible = false
	customer_container.modulate.a = 0.0

	var es_hora_comercial: bool = true
	if "hour" in TimeManager:
		es_hora_comercial = (TimeManager.hour >= 6 and TimeManager.hour < 17)

	if es_hora_comercial:
		bell_button.disabled = false
		bell_label.text = "Aguardando llegada de ciudadano..."
		_actualizar_busto_cliente("sargento")
		if is_inside_tree() and is_visible_in_tree():
			call_deferred("_verificar_llegada_automatica_ciudadano")
	else:
		bell_button.disabled = true
		bell_label.text = "Portón comercial cerrado por la noche. Abre a las 06:00 AM."

func _obtener_clientes_para_dia(num_dia: int) -> Array[Dictionary]:
	if ROSTER_POR_DIA.has(num_dia):
		var base: Array = ROSTER_POR_DIA[num_dia] as Array
		var resultado: Array[Dictionary] = []
		for elem in base:
			if elem is Dictionary:
				resultado.append((elem as Dictionary).duplicate(true))
		return resultado
	return _generar_clientes_procedurales(num_dia)

func _generar_clientes_procedurales(num_dia: int) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	var pool: Array[Dictionary] = [
		{
			"name": "Patrulla de Vigilancia Feudal",
			"faction": "Guarnición del Castillo",
			"visual_id": "sargento",
			"portrait": PORTRAIT_SERGEANT,
			"dialogue_intro": "Herrero. Inspección de rutina del Día %d. Requerimos clavazón y herrajes de compuerta en Hierro Dulce para el cuartel. Trabaja rápido." % num_dia,
			"dialogue_good": "Metal resistente y templado reglamentario. Buen servicio.",
			"dialogue_bad": "Pieza torpe. Esperaba más de un herrero registrado en la comarca.",
			"item_name": "Herraje de Compuerta Feudal",
			"required_metal": "hierro_dulce",
			"description": "Herraje de hierro dulce para compuertas de la guarnición.",
			"specs": "• Barril: Hierro Dulce\n• Fragua: 1000°C - 1160°C (Fusión 1200°C)\n• Yunque: Formado simétrico\n• Corte: Sin rebabas\n• Temple y Pulido: Acero limpio",
			"base_reward": 30 + (num_dia % 5) * 2
		},
		{
			"name": "Gorki el Minero",
			"faction": "Piconeros de la Galería Sur",
			"visual_id": "molinero",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "¡Hola camarada! La roca profunda del nivel %d está desgastando nuestras herramientas. Necesitamos un pico de Acero al Carbono bien templado." % num_dia,
			"dialogue_good": "¡Qué filo tenaz! Esta noche extraeremos buenas menas gracias a ti.",
			"dialogue_bad": "Mmh, la punta tiene fisuras... tendré que usarlo con cuidado.",
			"item_name": "Pico de Galería Profunda",
			"required_metal": "acero_carbono",
			"description": "Pico de minería en acero al carbono para roca viva.",
			"specs": "• Barril: Acero al Carbono\n• Fragua: 920°C - 1040°C (Fusión 1140°C)\n• Yunque: Puntas opuestas\n• Corte: Cizallado limpio\n• Temple y Pulido: Acero oscuro tenaz",
			"base_reward": 34 + (num_dia % 4) * 2
		},
		{
			"name": "Doña Valeria (Mercader)",
			"faction": "Caravanas de la Comarca",
			"visual_id": "mercader",
			"portrait": PORTRAIT_PEASANT,
			"dialogue_intro": "Saludos, artesano. En el Día %d partimos hacia las tierras altas y requerimos un perno de Bronce de Forja que soporte las lluvias del paso de montaña." % num_dia,
			"dialogue_good": "¡Pieza formidable! El bronce brilla perfecto y no se oxidará jamás.",
			"dialogue_bad": "Un poco áspero, pero servirá para no quedarnos varados en el lodo.",
			"item_name": "Perno de Bronce de Travesía",
			"required_metal": "bronce_cobre",
			"description": "Perno de bronce forjado inoxidable para carromatos de viaje.",
			"specs": "• Barril: Bronce de Forja\n• Fragua: 740°C - 870°C (Fusión 1010°C)\n• Yunque: Cilindro maleable\n• Corte: Sin rebabas\n• Temple y Pulido: Brillo cobrizo",
			"base_reward": 32 + (num_dia % 3) * 3
		}
	]
	for p: Dictionary in pool:
		resultado.append(p.duplicate(true))
	return resultado

func reset_if_stuck() -> void:
	if _convocando_cliente:
		return
	if pedidos_entregados_hoy >= max_pedidos_hoy:
		bell_button.disabled = true
		bell_label.text = "Jornada del día %d completada (%d de %d encargos). Ve a descansar o a la mina." % [TimeManager.day if "day" in TimeManager else 1, max_pedidos_hoy, max_pedidos_hoy]
		return
	if _cliente_presente_en_ventanilla:
		bell_button.disabled = true
		if order_sheet.visible and btn_accept_order.disabled and not delivery_tray.visible:
			btn_to_forge.visible = true
		elif not order_sheet.visible and not delivery_tray.visible and not has_active_order and not has_finished_piece:
			# Si la llegada previa fue interrumpida al cerrar la vista, mostrar al cliente que ya tocó la campana
			var customer: Dictionary = customers[current_customer_index]
			active_order = customer
			var visual_id: String = str(customer.get("visual_id", "sargento"))
			customer_portrait.texture = customer["portrait"]
			_actualizar_busto_cliente(visual_id)
			customer_name_label.text = customer["name"]
			customer_status_label.text = customer["faction"]
			customer_container.modulate.a = 1.0
			dialogue_box.visible = true
			dialogue_text.text = str(customer.get("dialogue_intro", ""))
			dialogue_text.visible_characters = -1
			order_title_label.text = "COMANDA: %s" % customer["item_name"]
			order_desc_label.text = customer["description"]
			order_specs_label.text = customer["specs"]
			order_reward_label.text = "Paga ofrecida: %d Monedas de Oro" % customer["base_reward"]
			btn_accept_order.disabled = false
			btn_accept_order.text = "Aceptar Encargo y Forjar"
			_completar_revelado_comanda_inmediato()
			bell_label.text = "El ciudadano ya tocó la campana y aguarda en ventanilla."
		return
	if not order_sheet.visible and not delivery_tray.visible:
		has_active_order = false
		has_finished_piece = false
		if is_inside_tree() and is_visible_in_tree():
			_verificar_llegada_automatica_ciudadano()
	elif order_sheet.visible and btn_accept_order.disabled and not delivery_tray.visible:
		btn_to_forge.visible = true

func _process(delta: float) -> void:
	if not visible or not is_visible_in_tree():
		return
	_tiempo_anim_cliente += delta
	if personaje_cliente_articulado and customer_container.modulate.a > 0.05:
		# Respiración orgánica y ligero balanceo del cliente en la ventanilla
		var resp: float = sin(_tiempo_anim_cliente * 2.4)
		var extra_habla_y: float = absf(sin(_tiempo_anim_cliente * 17.5)) * 1.8 if _hablando_cliente else 0.0
		personaje_cliente_articulado.position.y = 178.0 + resp * 2.2 - extra_habla_y
		personaje_cliente_articulado.scale = Vector2(1.0 + resp * 0.008, 1.0 - resp * 0.010)
		var cabeza_activa: Node2D = _obtener_cabeza_cliente_activa()
		if cabeza_activa:
			if _hablando_cliente:
				cabeza_activa.rotation = sin(_tiempo_anim_cliente * 14.0) * 0.048
				cabeza_activa.position.y = -51.0 + sin(_tiempo_anim_cliente * 19.0) * 1.4
			else:
				cabeza_activa.rotation = sin(_tiempo_anim_cliente * 1.4) * 0.032
		var boca_activa: Node2D = _obtener_boca_cliente_activa()
		if boca_activa:
			if _hablando_cliente:
				var pulso_silaba: float = 0.5 + 0.5 * sin(_tiempo_anim_cliente * 24.0)
				boca_activa.scale = Vector2(lerpf(0.92, 1.08, pulso_silaba), lerpf(0.4, 1.45, pulso_silaba))
			else:
				boca_activa.scale = Vector2(1.0, 0.4)

func _asegurar_nodos_boca_clientes() -> void:
	var config_bustos: Array[Dictionary] = [
		{"busto": busto_sargento_godofredo, "cabeza": "CabezaCliente", "pos": Vector2(0, 22), "color": Color(0.24, 0.08, 0.09, 1)},
		{"busto": busto_molinero_eustaquio, "cabeza": "CabezaMolinero", "pos": Vector2(0, 20), "color": Color(0.26, 0.09, 0.09, 1)},
		{"busto": busto_mercader_valeria, "cabeza": "CabezaMercader", "pos": Vector2(0, 18), "color": Color(0.46, 0.14, 0.18, 1)}
	]
	for cfg in config_bustos:
		var busto_n: Node2D = cfg["busto"]
		if busto_n == null:
			continue
		var cabeza_n: Node2D = busto_n.get_node_or_null(str(cfg["cabeza"])) as Node2D
		if cabeza_n == null:
			continue
		var boca_n: Polygon2D = cabeza_n.get_node_or_null("BocaCliente") as Polygon2D
		if boca_n == null:
			boca_n = Polygon2D.new()
			boca_n.name = "BocaCliente"
			boca_n.position = cfg["pos"]
			boca_n.color = cfg["color"]
			boca_n.polygon = PackedVector2Array([
				Vector2(-7, -1.5), Vector2(0, -2.5), Vector2(7, -1.5),
				Vector2(5, 3.5), Vector2(0, 4.5), Vector2(-5, 3.5)
			])
			cabeza_n.add_child(boca_n)
		boca_n.scale = Vector2(1.0, 0.4)

func _obtener_boca_cliente_activa() -> Node2D:
	var cabeza: Node2D = _obtener_cabeza_cliente_activa()
	if cabeza:
		return cabeza.get_node_or_null("BocaCliente") as Node2D
	return null

func _on_caja_dialogo_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _hablando_cliente:
			_saltar_escritura_dialogo = true
		elif _revelando_comanda:
			_completar_revelado_comanda_inmediato()

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

func _seleccionar_siguiente_cliente_no_atendido() -> int:
	for i in range(customers.size()):
		var candidato: int = (current_customer_index + i) % customers.size()
		if not clientes_atendidos_indices.has(candidato):
			return candidato
	return -1

func _hacer_sonar_campana_por_ciudadano() -> void:
	AudioManager.play_bell()
	if bell_button:
		var bell_tween: Tween = create_tween()
		bell_tween.tween_property(bell_button, "scale", Vector2(1.2, 0.85), 0.06)
		bell_tween.tween_property(bell_button, "scale", Vector2(0.9, 1.15), 0.08)
		bell_tween.tween_property(bell_button, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_ELASTIC)

	if bell_ring_fx:
		bell_ring_fx.visible = true
		bell_ring_fx.modulate.a = 1.0
		bell_ring_fx.position.y = -30.0
		var fx_tween: Tween = create_tween().set_parallel(true)
		fx_tween.tween_property(bell_ring_fx, "position:y", -55.0, 0.45)
		fx_tween.tween_property(bell_ring_fx, "modulate:a", 0.0, 0.45)
		fx_tween.chain().tween_callback(func(): bell_ring_fx.visible = false)

func _verificar_llegada_automatica_ciudadano() -> void:
	if not is_inside_tree():
		return
	if pedidos_entregados_hoy >= max_pedidos_hoy:
		bell_button.disabled = true
		bell_label.text = "Jornada del día %d completada (%d de %d encargos). Ve a descansar o a la mina." % [TimeManager.day if "day" in TimeManager else 1, max_pedidos_hoy, max_pedidos_hoy]
		return
	if _cliente_presente_en_ventanilla or has_active_order or has_finished_piece or _convocando_cliente:
		return

	var siguiente_idx: int = _seleccionar_siguiente_cliente_no_atendido()
	if siguiente_idx == -1:
		pedidos_entregados_hoy = max_pedidos_hoy
		bell_button.disabled = true
		bell_label.text = "Jornada del día %d completada (%d de %d encargos). Ve a descansar o a la mina." % [TimeManager.day if "day" in TimeManager else 1, max_pedidos_hoy, max_pedidos_hoy]
		return

	current_customer_index = siguiente_idx
	_cliente_presente_en_ventanilla = true
	bell_button.disabled = true
	bell_label.text = "El ciudadano acaba de tocar la campana al llegar a la ventanilla."
	_hacer_sonar_campana_por_ciudadano()
	_summon_customer()

func _on_bell_clicked() -> void:
	if pedidos_entregados_hoy >= max_pedidos_hoy:
		bell_button.disabled = true
		bell_label.text = "Jornada del día %d completada (%d de %d encargos). Ve a descansar o a la mina." % [TimeManager.day if "day" in TimeManager else 1, max_pedidos_hoy, max_pedidos_hoy]
		return
	if _cliente_presente_en_ventanilla or has_active_order or has_finished_piece or _convocando_cliente:
		bell_button.disabled = true
		bell_label.text = "El ciudadano ya tocó la campana y aguarda en ventanilla."
		return

	# Solo si aún no había llegado el ciudadano (ej. llamada directa desde batería de pruebas)
	_verificar_llegada_automatica_ciudadano()

func _summon_customer() -> void:
	if _convocando_cliente:
		return
	_convocando_cliente = true
	_cliente_presente_en_ventanilla = true
	bell_button.disabled = true
	var es_headless: bool = DisplayServer.get_name() == "headless"
	var customer: Dictionary = customers[current_customer_index]
	active_order = customer
	var visual_id: String = str(customer.get("visual_id", "sargento"))

	customer_portrait.texture = customer["portrait"]
	_actualizar_busto_cliente(visual_id)
	customer_name_label.text = customer["name"]
	customer_status_label.text = customer["faction"]

	# 1. Al llegar el cliente: ocultar la receta mientras empieza y habla el comentario
	order_sheet.visible = false
	dialogue_box.visible = false

	var dur_llegada: float = 0.18 if es_headless else 0.45
	var center_x: float = (size.x - customer_container.size.x) * 0.5 if size.x > 0 else 540.0
	customer_container.position.x = center_x + 70.0
	customer_container.modulate.a = 0.0
	var enter_tween: Tween = create_tween().set_parallel(true)
	enter_tween.tween_property(customer_container, "position:x", center_x, dur_llegada).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	enter_tween.tween_property(customer_container, "modulate:a", 1.0, dur_llegada)

	await enter_tween.finished
	if not is_inside_tree():
		_convocando_cliente = false
		return

	# 2. Mostrar diálogo primero con efecto letra por letra, movimiento de boca y balbuceo
	dialogue_box.visible = true
	order_sheet.visible = false
	var texto_intro: String = str(customer.get("dialogue_intro", ""))
	var dur_dialogo: float = 0.14 if es_headless else clampf(float(texto_intro.length()) / 45.0, 1.2, 3.8)
	await _reproducir_dialogo_cliente(texto_intro, visual_id, dur_dialogo)
	if not is_inside_tree():
		_convocando_cliente = false
		return

	if not es_headless and not _saltar_escritura_dialogo:
		await get_tree().create_timer(0.25).timeout
		if not is_inside_tree():
			_convocando_cliente = false
			return

	# 3. Recién cuando termina el comentario, se despliega la comanda y su contenido aparece de a poco
	await _desplegar_y_revelar_comanda(customer, es_headless)
	if not is_inside_tree():
		_convocando_cliente = false
		return

	bell_label.text = "El ciudadano ya tocó la campana y aguarda en ventanilla."
	_convocando_cliente = false

func _reproducir_dialogo_cliente(texto: String, visual_id: String, duracion_total: float) -> void:
	dialogue_box.visible = true
	dialogue_text.text = texto
	var total_chars: int = texto.length()
	if total_chars <= 0:
		dialogue_text.visible_characters = -1
		return

	dialogue_text.visible_characters = 0
	_hablando_cliente = true
	_saltar_escritura_dialogo = false
	var pitch_cliente: float = float(PITCH_VOZ_CLIENTE.get(visual_id, 0.98))
	var ultimo_blip_char: int = -3
	var tiempo_transcurrido: float = 0.0

	while tiempo_transcurrido < duracion_total and not _saltar_escritura_dialogo:
		if not is_inside_tree():
			return
		await get_tree().process_frame
		if not is_inside_tree():
			return
		tiempo_transcurrido += get_process_delta_time()
		var progreso: float = clampf(tiempo_transcurrido / maxf(duracion_total, 0.01), 0.0, 1.0)
		var chars_visibles: int = int(round(progreso * float(total_chars)))
		dialogue_text.visible_characters = chars_visibles
		if chars_visibles - ultimo_blip_char >= 3 and chars_visibles < total_chars:
			ultimo_blip_char = chars_visibles
			_emitir_sonido_balbuceo(pitch_cliente)

	dialogue_text.visible_characters = -1
	_hablando_cliente = false
	var boca: Node2D = _obtener_boca_cliente_activa()
	if boca:
		boca.scale = Vector2(1.0, 0.4)

func _emitir_sonido_balbuceo(pitch_cliente: float) -> void:
	if AudioManager.has_method("play_voice_blip"):
		AudioManager.call("play_voice_blip", pitch_cliente)
	else:
		AudioManager.play_sfx("place_item", -15.0, 0.12)

func _desplegar_y_revelar_comanda(customer: Dictionary, es_headless: bool) -> void:
	AudioManager.play_sfx("place_item", 0.5, 0.05)
	order_title_label.text = "COMANDA: %s" % customer["item_name"]
	order_desc_label.text = customer["description"]
	order_specs_label.text = customer["specs"]
	order_reward_label.text = "Paga ofrecida: %d Monedas de Oro" % customer["base_reward"]
	btn_accept_order.disabled = false
	btn_accept_order.text = "Aceptar Encargo y Forjar"

	order_title_label.visible_ratio = 0.0
	order_desc_label.visible_ratio = 0.0
	order_specs_label.visible_ratio = 0.0
	order_reward_label.visible_ratio = 0.0

	order_sheet.visible = true
	order_sheet.modulate.a = 0.0
	order_sheet.pivot_offset = order_sheet.size * 0.5
	order_sheet.scale = Vector2(0.86, 1.12)

	var velocidad_efectiva: float = 9.5 if es_headless else VELOCIDAD_REVELADO_RECETA
	var dur_entrada_papel: float = 0.04 if es_headless else 0.34
	var dur_campo: float = 0.03 if es_headless else (0.30 / maxf(velocidad_efectiva, 0.1))

	_revelando_comanda = true
	if _tween_comanda_texto and _tween_comanda_texto.is_valid():
		_tween_comanda_texto.kill()

	_tween_comanda_texto = create_tween()
	_tween_comanda_texto.set_parallel(true)
	_tween_comanda_texto.tween_property(order_sheet, "modulate:a", 1.0, dur_entrada_papel)
	_tween_comanda_texto.tween_property(order_sheet, "scale", Vector2.ONE, dur_entrada_papel).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_tween_comanda_texto.chain().tween_property(order_title_label, "visible_ratio", 1.0, dur_campo)
	_tween_comanda_texto.chain().tween_property(order_desc_label, "visible_ratio", 1.0, dur_campo)
	_tween_comanda_texto.chain().tween_property(order_specs_label, "visible_ratio", 1.0, dur_campo)
	_tween_comanda_texto.chain().tween_property(order_reward_label, "visible_ratio", 1.0, dur_campo)

	await _tween_comanda_texto.finished
	_completar_revelado_comanda_inmediato()

func _completar_revelado_comanda_inmediato() -> void:
	if _tween_comanda_texto and _tween_comanda_texto.is_valid():
		_tween_comanda_texto.kill()
	order_sheet.visible = true
	order_sheet.modulate.a = 1.0
	order_sheet.scale = Vector2.ONE
	order_title_label.visible_ratio = 1.0
	order_desc_label.visible_ratio = 1.0
	order_specs_label.visible_ratio = 1.0
	order_reward_label.visible_ratio = 1.0
	_revelando_comanda = false

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

	if not clientes_atendidos_indices.has(current_customer_index):
		clientes_atendidos_indices.append(current_customer_index)
	pedidos_entregados_hoy += 1
	if GameManager.has_method("registrar_pedido_completado"):
		GameManager.call("registrar_pedido_completado")

	dialogue_box.visible = true
	var item_name: String = str(customer.get("item_name", "Clavo Forjado"))
	var visual_id: String = str(customer.get("visual_id", "sargento"))
	var respuesta_final: String = ""
	if is_good:
		respuesta_final = str(customer.get("dialogue_good", "¡Excelente trabajo!")) + ("\n[Cobraste +%d monedas]" % final_reward)
	else:
		respuesta_final = str(customer.get("dialogue_bad", "Trabajo tosco.")) + ("\n[Cobraste solo +%d monedas]" % final_reward)

	GameManager.record_crafted_item(item_name, finished_piece_quality, final_reward)
	AudioManager.play_coins()
	emit_signal("item_delivered", finished_piece_quality, final_reward)

	var es_headless: bool = DisplayServer.get_name() == "headless"
	var dur_respuesta: float = 0.14 if es_headless else clampf(float(respuesta_final.length()) / 48.0, 1.1, 2.8)
	await _reproducir_dialogo_cliente(respuesta_final, visual_id, dur_respuesta)
	if not is_inside_tree():
		return

	var dur_salida: float = 0.22 if es_headless else 0.5
	var center_x: float = (size.x - customer_container.size.x) * 0.5 if size.x > 0 else 540.0
	var exit_tween: Tween = create_tween().set_parallel(true)
	exit_tween.tween_property(customer_container, "position:x", center_x - 100.0, dur_salida).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	exit_tween.tween_property(customer_container, "modulate:a", 0.0, dur_salida)
	exit_tween.tween_property(delivery_tray, "modulate:a", 0.0, dur_salida * 0.8)

	await exit_tween.finished
	if not is_inside_tree():
		return
	delivery_tray.visible = false
	has_active_order = false
	has_finished_piece = false
	_convocando_cliente = false
	_cliente_presente_en_ventanilla = false

	var siguiente_idx: int = _seleccionar_siguiente_cliente_no_atendido()
	if pedidos_entregados_hoy < max_pedidos_hoy and siguiente_idx != -1:
		current_customer_index = siguiente_idx
		bell_button.disabled = true
		bell_label.text = "Aguardando llegada del siguiente ciudadano (%d de %d)..." % [pedidos_entregados_hoy + 1, max_pedidos_hoy]
		var espera_siguiente: float = 0.05 if es_headless else 1.2
		await get_tree().create_timer(espera_siguiente).timeout
		if not is_inside_tree():
			return
		if is_visible_in_tree():
			_verificar_llegada_automatica_ciudadano()
	else:
		pedidos_entregados_hoy = max_pedidos_hoy
		bell_button.disabled = true
		bell_label.text = "Jornada del día %d completada (%d de %d encargos). Ve a descansar o a la mina." % [TimeManager.day if "day" in TimeManager else 1, max_pedidos_hoy, max_pedidos_hoy]
		dialogue_box.visible = true
		dialogue_text.text = "Has completado los %d encargos del Día %d. El taller baja el portón comercial por hoy." % [max_pedidos_hoy, TimeManager.day if "day" in TimeManager else 1]
		dialogue_text.visible_characters = -1
