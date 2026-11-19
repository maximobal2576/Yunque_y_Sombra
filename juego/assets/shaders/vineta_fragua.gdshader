// vineta_fragua.gdshader
// Viñeta cálida del taller con respiración lenta de brasas desde el borde inferior.
// Parpadeo de baja frecuencia y baja amplitud (sin estroboscopia ni mareo).
shader_type canvas_item;

uniform vec4 color_vineta : source_color = vec4(0.129, 0.102, 0.086, 1.0); // #211a16
uniform vec4 color_brasa : source_color = vec4(0.42, 0.13, 0.07, 1.0);
uniform float intensidad : hint_range(0.0, 1.0) = 0.78;
uniform float radio_interior : hint_range(0.0, 1.0) = 0.34;
uniform float velocidad_parpadeo = 1.1;

void fragment() {
	vec2 centrado = UV - vec2(0.5);
	float distancia = length(centrado * vec2(1.0, 1.3));
	float vineta = smoothstep(radio_interior, 0.86, distancia);

	// Dos senos desfasados no armónicos: respiración orgánica entre 0.65 y 1.0.
	float parpadeo = 0.825 + 0.1 * sin(TIME * velocidad_parpadeo) + 0.075 * sin(TIME * velocidad_parpadeo * 2.71 + 1.3);
	float desde_abajo = smoothstep(0.45, 1.0, UV.y);
	vec3 color = mix(color_vineta.rgb, color_brasa.rgb, desde_abajo * 0.55 * parpadeo);

	COLOR = vec4(color, vineta * intensidad);
}
