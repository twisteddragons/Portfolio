shader_type sky;
// used this tutorial, couldnt get it working correctly:
// https://www.youtube.com/watch?v=v-l0pmPnwp4

//uniform sampler2D gradient;
//uniform sampler2D noise;
//
//uniform vec2 scroll = vec2 (0.1, 0.1);

uniform vec3 spiralColor : source_color = vec3(0.2, 0.6, 0.3);
uniform float frequency: hint_range(1.0, 10.0, 0.1) = 8.0;
uniform float speed: hint_range(0.1, 20.0, 0.1) = 8.0;
uniform float thickness: hint_range(0.1, 1, 0.1) = 0.2;
uniform float brightness: hint_range(1.0, 10.0, 0.1) = 5.0;

float draw_spiral(vec2 uv, float rotation){
	float uv_rad = length(uv);
	float uv_phi = atan(uv.y, uv.x) + rotation;
	// what the actual fuck is TAU
	float spiral_param = (log(uv_rad)*frequency - uv_phi) / TAU;
	float fractional = fract(spiral_param);
	float dist = min(fractional, 1.0 - fractional);
	return 1.0 - smoothstep(0.0, thickness, dist);
}

void sky() {
	vec2 uv = SCREEN_UV - 0.5;
	uv.y *= -1.0;
	uv.x - 10.0;
	float spiral = draw_spiral(uv,TIME * speed);
	float fade = smoothstep(0.0, 0.5, length(uv));
	spiral *= fade;
	vec3 color = spiral * spiralColor;

	COLOR.rgb = color * brightness;


	//vec4 noise_col = texture(noise,SCREEN_UV + scroll * TIME);
	//COLOR = noise_col.rgb;
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.

}
