shader_type canvas_item;

uniform sampler2D color_gradient;
uniform sampler2D alpha_mask: repeat_enable;
uniform vec3 spiral_color: source_color = vec3(0.2, 0.3, 0.8);
uniform float frequency = 20.0;
uniform float speed = 1.0;
uniform int inward_curve = 9;
uniform int direction = 1; //1 for counter clockwise. -1 for clockwise

float draw_spiral(vec2 uv, float rotation) {
	float uv_radius = length(uv); // how far fragment is from center
	float uv_phi = atan(uv.y, uv.x) + rotation; //angle of point in radians
	uv_phi *= float(inward_curve); // how much the spiral should curve inward
	float spiral_phi = (log(uv_radius) * frequency - uv_phi * float(direction)) / TAU;
	float spiral_floor_radius = exp((TAU * floor(spiral_phi) + uv_phi * float(direction)) / frequency);
	float spiral_ceil_radius = exp((TAU * ceil(spiral_phi) + uv_phi * float(direction)) / frequency);
	return spiral_floor_radius;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 centered_uv = UV - 0.5;
	float spiral = draw_spiral(centered_uv, TIME * speed * float(direction));
	//vec3 color = vec3(spiral * 2.0);
	//COLOR = vec4(color, 1.0);
	COLOR = texture(color_gradient, vec2(spiral, 0.0));
	COLOR = COLOR * texture(alpha_mask, UV);

	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
