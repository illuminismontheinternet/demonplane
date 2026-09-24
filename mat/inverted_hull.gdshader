shader_type spatial;
render_mode unshaded, cull_front;

uniform float weight : hint_range(0, 1.0) = 1.0;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex() {
	VERTEX += NORMAL * (weight /10000.0) * COLOR.r;
}

void fragment() {
	ALBEDO = color.rgb;
}