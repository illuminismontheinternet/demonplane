shader_type spatial;
render_mode depth_draw_opaque;

uniform sampler2D albedo_texture;
uniform vec4 albedo_color : source_color  = vec4(1.0);
uniform float albedo_intensity : hint_range(0.0, 5.0, 0.01) = 1.0;
//uniform vec4 outline_color : source_color  = vec4(1.0);
//uniform float outline_amount : hint_range(0.0, 1.0, 0.01) = 1.0;

uniform float band_helper : hint_range(0.0, 100.0, 0.01) = 0.1;

uniform float first_band_intensity : hint_range(0.0, 1.0, 0.01) = 0.9;
uniform float second_band_intensity : hint_range(0.0, 1.0, 0.01) = 0.6;
uniform float third_band_intensity : hint_range(0.0, 1.0, 0.01) = 0.6;
uniform bool soften_lighting = false;
uniform bool use_third_band = true;

uniform float first_band_zone : hint_range(0.0, 1.0, 0.01) = 0.9;
uniform float second_band_zone : hint_range(0.0, 1.0, 0.01) = 0.6;

uniform float current_band_intensity;
void light()
{
	// clears the bands
	if (soften_lighting)
	{
		DIFFUSE_LIGHT += ALBEDO * ATTENUATION * LIGHT_COLOR * max(dot(LIGHT,NORMAL), 0.0);
	}
	else
	{
		float lighting = dot(NORMAL, LIGHT);
		if (lighting > first_band_zone)
		{
			//DIFFUSE_LIGHT += first_band_intensity * (ATTENUATION * LIGHT_COLOR * max(dot(LIGHT,NORMAL), 0.0));
			DIFFUSE_LIGHT += first_band_intensity * band_helper * ALBEDO * ATTENUATION * LIGHT_COLOR * max(dot(LIGHT,NORMAL), 0.0);
		}
		else if (lighting > second_band_zone)
		{
			DIFFUSE_LIGHT += second_band_intensity * band_helper * ALBEDO * ATTENUATION * LIGHT_COLOR * max(dot(LIGHT,NORMAL), 0.1);
		}
		else if (use_third_band)
		{
			DIFFUSE_LIGHT += third_band_intensity * band_helper* ALBEDO * ATTENUATION * LIGHT_COLOR * max(dot(LIGHT,NORMAL), 0.1);
		}
	}
}

void fragment()
{
	ALBEDO = albedo_color.rgb * albedo_intensity;
}