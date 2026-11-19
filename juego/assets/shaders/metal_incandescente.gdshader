// metal_incandescente.gdshader
// Color de calor del acero según `temperatura` (°C), controlado desde AnvilTopDownStation.gd.
// Rampa física (/herrero): gris acero -> rojo sombra -> cereza -> naranja -> amarillo -> blanco.
// El núcleo conserva más calor que los bordes y las puntas (pierden calor antes por su menor masa).
// Ruido sutil de cascarilla martillada, más visible a medida que la pieza se enfría.
shader_type canvas_item;

uniform float temperatura : hint_range(20.0, 1400.0) = 1100.0;
// Semi-grosor máximo actual de la barra (px locales) para estimar la distancia al núcleo.
uniform float semi_grosor_max = 16.0;
// Semi-largo de la barra (px locales) para enfriar antes las puntas.
uniform float semi_largo = 140.0;
// Caída de temperatura en bordes respecto del núcleo (°C).
uniform float caida_borde = 130.0;
uniform float intensidad_cascarilla : hint_range(0.0, 1.0) = 0.4;

varying vec2 pos_local;

void vertex() {
	pos_local = VERTEX;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

vec3 color_calor(float t) {
	vec3 c = vec3(0.24, 0.23, 0.22);                                  // Gris acero
	c = mix(c, vec3(0.32, 0.06, 0.05), smoothstep(450.0, 600.0, t));   // Rojo sombra
	c = mix(c, vec3(0.66, 0.09, 0.07), smoothstep(600.0, 800.0, t));   // Cereza
	c = mix(c, vec3(0.94, 0.42, 0.07), smoothstep(800.0, 1000.0, t));  // Naranja
	c = mix(c, vec3(1.00, 0.76, 0.26), smoothstep(1000.0, 1150.0, t)); // Amarillo
	c = mix(c, vec3(1.00, 0.95, 0.82), smoothstep(1150.0, 1300.0, t)); // Blanco
	return c;
}

void fragment() {
	float borde_y = clamp(abs(pos_local.y) / max(semi_grosor_max, 1.0), 0.0, 1.0);
	float borde_x = clamp(abs(pos_local.x) / max(semi_largo, 1.0), 0.0, 1.0);
	float factor_borde = max(smoothstep(0.35, 1.0, borde_y), smoothstep(0.72, 1.0, borde_x) * 0.85);
	vec3 c = color_calor(temperatura - factor_borde * caida_borde);

	// Cascarilla: escamas oscuras de óxido, más marcadas en frío.
	float n = ruido(pos_local * 0.32) * 0.6 + ruido(pos_local * 1.15) * 0.4;
	float frio = 1.0 - smoothstep(600.0, 1100.0, temperatura);
	float escama = smoothstep(0.55, 0.85, n) * intensidad_cascarilla * (0.35 + 0.65 * frio);
	c *= 1.0 - escama * 0.55;

	// Núcleo incandescente ligeramente más luminoso.
	c += vec3(0.08, 0.05, 0.02) * (1.0 - borde_y) * smoothstep(700.0, 1100.0, temperatura);

	COLOR = vec4(clamp(c, 0.0, 1.0), COLOR.a);
}
