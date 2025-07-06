shader_type canvas_item;

//uniform sampler2D grayscale_image;
// Higher index = lighter colour
uniform vec4[5] base_colours : source_color;
uniform vec4[6] highlight_colours : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 grayscale_texture = texture(TEXTURE, UV); // get grayscale version of sprite. NOTE: might want to make base sprite grayscale
	float grayscale_value = grayscale_texture.r; // color value, r, g, and b are all the same so just use r
	float grayscale_alpha = grayscale_texture.a; // alpha value must be retained
	int index = int(grayscale_value * 10.0); //color value determines index of new colour, maybe multiply by 9?

	bool highlight = (index > 5); // whether or not its a highlight color



	if (highlight) {
		COLOR = highlight_colours[index-5];
	} else {
		COLOR = base_colours[index];
	}

	if (index == 10) {
		COLOR = vec4(1.0, 1.0, 1.0, 1.0);
	}
	COLOR.a = grayscale_alpha;

	//vec4 input_color = texture(TEXTURE, UV);
	//if (input_color == vec4(1,1,1,1)) {
		//COLOR = vec4(1,1,1,1);
	//}

	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
