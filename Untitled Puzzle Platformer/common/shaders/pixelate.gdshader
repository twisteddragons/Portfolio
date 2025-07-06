shader_type canvas_item;

//uniform vec2 target_resolution = vec2(1920., 1080.);

void fragment() {
	vec2 target_resolution = vec2(1920., 1080.);
	vec2 target_resolution_inverse = 1./target_resolution;
	vec2 scale = target_resolution_inverse/SCREEN_PIXEL_SIZE; //3 for 1920x1080
	vec2 pixel_UV_size = 1./TEXTURE_PIXEL_SIZE; //size of a pixel in UV space
	vec2 scaled_pixel_UV_size = pixel_UV_size/scale; //size of a scaled pixel in UV space
	vec2 rounded_UV = floor(UV * scaled_pixel_UV_size)/scaled_pixel_UV_size;
	//if (mod(rounded_UV * scaled_pixel_UV_size, 3.0) == vec2(0.)){
		//COLOR = vec4(1.0);
	//}
	COLOR = texture(TEXTURE, rounded_UV);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
