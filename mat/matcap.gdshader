shader_type spatial;
render_mode unshaded;

uniform vec3 color1: source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 color2: source_color = vec3(0.0, 0.0, 0.0);
uniform float lightness : hint_range(0, 5.0) = 1.0;
uniform float sharpness : hint_range(1.0, 10.0) = 1.5;
uniform float x_offset : hint_range(-1.0, 1.0) = 0.0;
uniform float y_offset : hint_range(-1.0, 1.0) = 0.0;
uniform float z_offset : hint_range(-1.0, 2.5) = 1.0;
//uniform sampler2D normalmap: hint_normal, filter_linear_mipmap, repeat_disable;
//uniform sampler2D texture: source_color, filter_linear, repeat_disable;

void fragment () {
//	vec3 nmpd = texture(normalmap, UV).rgb * 2.0 - 1.0;
//	NORMAL= normalize(TANGENT * nmpd.x + BINORMAL * nmpd.y + NORMAL * -nmpd.z);
	vec3 matnm = vec3(NORMAL.x-x_offset, NORMAL.y-y_offset, NORMAL.z+z_offset);
	float fresnel = clamp((pow((1.0 - dot(normalize(matnm), normalize(VIEW))), lightness) * sharpness), 0.0, 1.0);
	vec3 matco = mix(color1, color2, fresnel);
	ALBEDO = matco;
//	ALBEDO = (texture(texture, UV).rgb)*matco;
}