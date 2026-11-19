# EscalaTermicaAcero.gd
# Fuente única de verdad de la escala térmica del acero dulce (/herrero).
# Umbrales en °C y colores de calor visibles en la penumbra del taller, según
# referencias/teoria_herreria_artesanal.md (tabla de colores de forja).
# Se usa vía preload (sin class_name) para no depender del caché global de clases en headless.
extends RefCounted

# --- Umbrales canónicos (°C) ---
const TEMP_AMBIENTE: float = 20.0
const TEMP_MANOMETRO_MIN: float = 20.0
const TEMP_MANOMETRO_MAX: float = 1400.0
const TEMP_FORJA_OPTIMA_MIN: float = 1000.0 # Naranja brillante
const TEMP_FORJA_OPTIMA_MAX: float = 1150.0 # Amarillo de caldeo
const TEMP_QUEMADO: float = 1250.0 # Blanco con chispas: el carbono arde y el acero se desgrana
const TEMP_DEFORMACION_PLENA: float = 800.0 # Por encima: el metal fluye bajo el martillo
const TEMP_RESISTENCIA: float = 650.0 # Rojo sombra: apenas plástico, riesgo de grietas

# --- Paradas de color de calor (temperatura, color físico de la pieza) ---
const PARADAS_TEMPERATURA: Array[float] = [450.0, 600.0, 800.0, 1000.0, 1150.0, 1300.0]
const PARADAS_COLOR: Array[Color] = [
	Color(0.24, 0.23, 0.22), # Gris acero (calor negro)
	Color(0.32, 0.06, 0.05), # Rojo sombra
	Color(0.66, 0.09, 0.07), # Rojo cereza
	Color(0.94, 0.42, 0.07), # Naranja de forja
	Color(1.00, 0.76, 0.26), # Amarillo de caldeo
	Color(1.00, 0.95, 0.82), # Blanco de soldadura
]

# Versiones aclaradas para TEXTO sobre fondos oscuros (contraste AAA sobre #211a16).
const PARADAS_COLOR_TEXTO: Array[Color] = [
	Color(0.847, 0.773, 0.647), # #d8c5a5 hueso (frío)
	Color(0.93, 0.62, 0.55),    # Rojo sombra aclarado
	Color(0.97, 0.58, 0.48),    # Cereza aclarado
	Color(0.99, 0.70, 0.38),    # Naranja aclarado
	Color(1.00, 0.85, 0.50),    # Amarillo aclarado
	Color(0.98, 0.95, 0.86),    # Blanco cálido (nunca #ffffff)
]

static func color_calor(temperatura: float) -> Color:
	return _interpolar(PARADAS_COLOR, temperatura)

static func color_texto(temperatura: float) -> Color:
	return _interpolar(PARADAS_COLOR_TEXTO, temperatura)

static func nombre_tramo(temperatura: float) -> String:
	if temperatura > TEMP_QUEMADO:
		return "Blanco quemado"
	if temperatura > TEMP_FORJA_OPTIMA_MAX:
		return "Blanco de soldadura"
	if temperatura >= TEMP_FORJA_OPTIMA_MIN:
		return "Naranja-amarillo de forja"
	if temperatura >= TEMP_DEFORMACION_PLENA:
		return "Naranja-cereza"
	if temperatura >= TEMP_RESISTENCIA:
		return "Rojo cereza oscuro"
	if temperatura >= 450.0:
		return "Rojo sombra"
	return "Gris acero"

static func _interpolar(colores: Array[Color], temperatura: float) -> Color:
	if temperatura <= PARADAS_TEMPERATURA[0]:
		return colores[0]
	var ultimo: int = PARADAS_TEMPERATURA.size() - 1
	if temperatura >= PARADAS_TEMPERATURA[ultimo]:
		return colores[ultimo]
	for i in range(ultimo):
		var t0: float = PARADAS_TEMPERATURA[i]
		var t1: float = PARADAS_TEMPERATURA[i + 1]
		if temperatura <= t1:
			return colores[i].lerp(colores[i + 1], (temperatura - t0) / (t1 - t0))
	return colores[ultimo]
