// NOTE: Shader automatically converted from Redot Engine LTS 26.1.stable's StandardMaterial3D.

shader_type spatial;

uniform float wave_scale = 3.0;
uniform vec4 albedo : source_color;
uniform vec4 emission : source_color;

void vertex() {
	float wave_shuttle = cos(VERTEX.x * 1.0+TIME) * sin(VERTEX.z * 2.0+TIME);
	VERTEX.y += (wave_shuttle * wave_scale);
}

void fragment() {
	ALBEDO = albedo.rgb;
	EMISSION = emission.rgb;
	ROUGHNESS = 0.25;
	ALPHA = 0.9;
	SPECULAR = 0.4;
	METALLIC = 0.01;
}
