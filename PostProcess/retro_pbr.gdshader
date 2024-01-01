shader_type canvas_item;

uniform float film_grain_speed = 2.5;
uniform float film_grain_factor = 0.1;
uniform float vignette_alpha = 1.0;
uniform float vignette_inner_radius = 0.0;
uniform float vignette_outer_radius = 1.0;
uniform int dither_color_depth :hint_range(1, 8) = 5;
uniform float dither_texture_scale = 10.0;
uniform float dither_texture_strength = 4.0;
uniform sampler2D dither_texture : hint_default_white, repeat_enable, filter_nearest;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_linear;

const float to_radians = PI / 180.0;

vec4 film_grain(vec4 p_color, vec2 uv) {
	float randomIntensity = fract
		(10000.0 
		* sin
			(
				(uv.x
				+ uv.y
				* TIME 
				* film_grain_speed
				) 
			* to_radians
			)
		);
	float amount = randomIntensity * film_grain_factor;
	vec3 grain = p_color.rgb + vec3(amount);
	return vec4(grain, p_color.a);
}

// logic from: https://godotshaders.com/shader/vignette/
vec4 vignette(vec4 p_color, vec2 uv) {
	
	vec2 pos = abs(uv - vec2(0.5)) * 2.0;
	float q = (1.0 - length(pos) / vignette_outer_radius) / (1.0 - vignette_inner_radius);
	float factor = q * vignette_alpha;
	vec3 n_color = p_color.rgb * factor;
	return vec4(n_color, p_color.a);
}

// based on: https://godotshaders.com/shader/ps1-post-processing/
vec4 dither(vec4 p_color,vec2  dither_uv) {
	ivec3 c = ivec3(round(p_color.rgb * 255.0));
	int dither_pattern = int(round(texture(dither_texture, dither_uv * dither_texture_scale).r * dither_texture_strength));
	c += ivec3(dither_pattern);
	c >>= (8 - dither_color_depth);
	return vec4(vec3(c) / float(1 << dither_color_depth), p_color.a);
}

void fragment() {
	vec4 sample = texture(SCREEN_TEXTURE, SCREEN_UV);
	ivec2 size = textureSize(SCREEN_TEXTURE, 0);
	sample = dither(sample, SCREEN_UV);
	sample = film_grain(sample, SCREEN_UV * vec2(size));
	sample = vignette(sample, SCREEN_UV);
	COLOR = sample;
}


