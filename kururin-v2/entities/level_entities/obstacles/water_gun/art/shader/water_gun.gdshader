shader_type canvas_item;

//uniform sampler2D water_gradient;
uniform sampler2D noise_texture: repeat_enable;

// PARAMS for body
uniform float speed = 0.05; //speed 
uniform float edge_margin = 0.1; /** how much of the edge is gone*/
uniform float foam_margin = 0.1; //how much of the edge is white foam
uniform float hor_stretch = 1.0;
uniform float vert_stretch = 1.0;

// PARAMS for side
//uniform float side_intensity = 1.0;
uniform float side_offset = 0.;
uniform float amplitude = 0.1;
uniform float wavelength = 10.0;
/** How fast the sides move*/
uniform float side_speed = 1.0;

void vertex() {
	
}

void fragment() {
	COLOR = vec4(1.0);
	vec4 foobar = texture(noise_texture, vec2(UV.x * hor_stretch, (UV.y - TIME * speed) * vert_stretch));
	COLOR = foobar;
	float left_wave = sin(((TIME * side_speed) - UV.y) * wavelength) * amplitude;
	float right_wave = sin(((TIME * side_speed) - UV.y + side_offset) * wavelength) * amplitude;
	if (UV.x + left_wave < edge_margin || UV.x - (right_wave) > 1.0 - edge_margin) {
		COLOR = vec4(0.0);
	} else if (UV.x + left_wave < edge_margin + foam_margin || UV.x - (right_wave) > 1.0 - edge_margin - foam_margin) {
		COLOR = vec4(1.0);
	}
	
	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
