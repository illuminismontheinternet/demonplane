shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform sampler2D NOISE_TEXTURE :  filter_linear_mipmap;
uniform float line_reduction : hint_range(0.0, 50.0, 0.01) = 10;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Converts an RGB color to HSV.
vec3 rgb2hsv(vec3 c) {
    float cMax = max(max(c.r, c.g), c.b);
    float cMin = min(min(c.r, c.g), c.b);
    float delta = cMax - cMin;

    float h = 0.0;
    if(delta < 0.00001) {
        h = 0.0;
    } else if(cMax == c.r) {
        h = mod(((c.g - c.b) / delta), 6.0);
    } else if(cMax == c.g) {
        h = ((c.b - c.r) / delta) + 2.0;
    } else {
        h = ((c.r - c.g) / delta) + 4.0;
    }
    h /= 6.0;
    if(h < 0.0) h += 1.0;

    float s = (cMax <= 0.0) ? 0.0 : (delta / cMax);
    float v = cMax;
    return vec3(h, s, v);
}

// Converts an HSV color back to RGB.
vec3 hsv2rgb(vec3 c) {
    float h = c.x * 6.0;
    float s = c.y;
    float v = c.z;

    float c_val = v * s;
    float x = c_val * (1.0 - abs(mod(h, 2.0) - 1.0));
    vec3 rgb;

    if (0.0 <= h && h < 1.0) {
        rgb = vec3(c_val, x, 0.0);
    } else if (1.0 <= h && h < 2.0) {
        rgb = vec3(x, c_val, 0.0);
    } else if (2.0 <= h && h < 3.0) {
        rgb = vec3(0.0, c_val, x);
    } else if (3.0 <= h && h < 4.0) {
        rgb = vec3(0.0, x, c_val);
    } else if (4.0 <= h && h < 5.0) {
        rgb = vec3(x, 0.0, c_val);
    } else if (5.0 <= h && h < 6.0) {
        rgb = vec3(c_val, 0.0, x);
    } else {
        rgb = vec3(0.0, 0.0, 0.0);
    }
    float m = v - c_val;
    return rgb + vec3(m);
}

void fragment() {
	/*
    vec4 original_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	float vR = original_color.r;
	float vG = original_color.g;
	float vB = original_color.b;
	// This gives 0 dark to 255 white
	float texel_brightness = (vR + vG + vB)/3.0;
	vec4 noise_original = texture(NOISE_TEXTURE, SCREEN_UV);
	float noise_pixel_value = (noise_original.r + noise_original.g + noise_original.b) /3.0;

	float final_texel = texel_brightness/255.0;
	vec3 noise_color = mix(original_color.rgb, noise_original.rgb, texel_brightness);//texel_brightness*3.0);
	vec3 soft_color = mix(original_color.rgb, noise_color, noise_pixel_value);
	COLOR = vec4(soft_color, 1.0);*/
	float saturation_mult = 0.0;
	vec4 original_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	// darken the scene vec3 mod_color = original_color.rgb * original_color.rgb;
	// blows out the scene vec3 mod_color = original_color.rgb * 1.5;
	    // Convert to HSV to adjust hue, saturation, and value.
    vec3 hsv = rgb2hsv(original_color.rgb);
    // Adjust saturation and value multipliers.
    hsv.y *= saturation_mult;

    // Convert back to RGB.
    vec3 col = hsv2rgb(hsv);
	float cR = pow(col.r,4.0);
	float cG = pow(col.g,4.0);
	float cB = pow(col.b,4.0);
	vec3 powcol = vec3(cR, cG, cB);

	// We have the lum values now use them
	vec4 noise_original = texture(NOISE_TEXTURE, SCREEN_UV);
	float lumval = (cR + cG + cB) / 3.0;
	float noise_val = noise_original.r / line_reduction;
	float lumcheck = 0.1;//0.2 only worked on level1
	if (lumval > lumcheck)
	{
		vec3 final_color = mix(original_color.rgb, noise_original.rgb, noise_val);
		COLOR = vec4(final_color, 1.0);
	}
	else
	{
		COLOR = vec4(original_color.rgb, 1.0);
	}

}