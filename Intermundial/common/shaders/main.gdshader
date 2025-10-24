shader_type sky;

uniform highp float spin_rotation;
uniform highp float spin_speed = 1.0;
uniform highp vec2 offset = vec2(0.0);
uniform vec4 colour_1 : source_color = vec4(0.2, 0.1, 0.5, 1.0);
uniform vec4 colour_2 : source_color = vec4(0.8, 0.3, 0.1, 1.0);
uniform vec4 colour_3 : source_color = vec4(0.1, 0.9, 0.4, 1.0);
uniform highp float contrast = 2.0;
uniform highp float spin_amount = 0.36;

//sun stuff
uniform highp float sun_elevation : hint_range(-90.0, 90.0) = 45.0;
uniform highp float sun_azimuth : hint_range(0.0, 360.0) = 45.0;
uniform bool use_manual_sun_position = false;

uniform vec4 sun_color : source_color = vec4(0.2, 0.1, 0.5, 1.0);
uniform float sun_radius : hint_range(0.0, 2.0, 0.001) = 0.5;
uniform bool flat_sun = true;

#define SPIN_EASE 1.0

// Correct equirectangular projection
vec2 direction_to_uv(vec3 dir) {
    // Normalize to be safe
    dir = normalize(dir);

    // Convert direction to spherical coordinates
    highp float u = 0.5 + 0.5 * atan(dir.z, dir.x) / PI;
    highp float v = acos(dir.y) / PI;

    return vec2(u, v);
}

vec3 spherical_to_direction(float elevation, float azimuth) {
    float elev_rad = radians(elevation);
    float azim_rad = radians(azimuth);
    return vec3(
        cos(elev_rad) * cos(azim_rad),
        sin(elev_rad),
        cos(elev_rad) * sin(azim_rad)
    );
}

void sky() {
	//trippy uv cords
	vec2 uv = SCREEN_UV;
	//sun uv cords
	vec2 sunUV = EYEDIR.xz / EYEDIR.y;
	// centers trippy cords
	uv = (uv - 0.5) * 2.0 - offset;
	// Swirl
	highp float uv_len = length(uv);
	highp float speed = (spin_rotation * SPIN_EASE * 0.2) + 302.2;
	// Fractal pattern generation
	uv *= 10.0;
	highp float time_speed = TIME * spin_speed;
	highp vec2 uv2 = vec2(uv.x + uv.y);

	// Reduced iterations for performance
	for(int i = 0; i < 3; i++) {
		uv2 += sin(max(uv.x, uv.y)) + uv;
		uv += 0.5 * vec2(
			cos(5.112 + 0.353 * uv2.y + time_speed * 0.13),
			sin(uv2.x - 0.113 * time_speed)
			);
	uv -= 1.0 * cos(uv.x + uv.y) - 1.0 * sin(uv.x * 0.7 - uv.y);
	}

	// Color mixing
	highp float pattern = length(uv) * 0.035;
	highp float contrast_mod = (0.25 * contrast + 0.5 * spin_amount + 1.2);
	pattern = min(2.0, max(0.0, pattern * contrast_mod));

	highp float c1p = max(0.0, 1.0 - contrast_mod * abs(1.0 - pattern));
	highp float c2p = max(0.0, 1.0 - contrast_mod * abs(pattern));
	highp float c3p = 1.0 - min(1.0, c1p + c2p);

	vec3 color = (0.3 / contrast) * colour_1.rgb +
		(1.0 - 0.3 / contrast) * (
			colour_1.rgb * c1p +
			colour_2.rgb * c2p +
			colour_3.rgb * c3p
			);

		// sun creation
	vec3 actual_sun_direction = use_manual_sun_position ? 
	spherical_to_direction(sun_elevation, sun_azimuth) : 
	LIGHT0_DIRECTION;


	float sun = distance(EYEDIR.xyz, actual_sun_direction);
	float sunDisc = 1.0 - clamp(sun / sun_radius, 0.0, 1.0);
	if (flat_sun == true) {
		sunDisc = roundEven(sunDisc);
	}
	vec3 sunsky = (sunDisc * sun_color.rgb);

	vec3 sky = color + sunsky;
	COLOR.rgb = sky;
}