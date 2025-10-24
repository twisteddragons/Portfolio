shader_type spatial;
//render_mode specular_schlick_ggx, unshaded, cull_back;//

uniform vec4 tint_color : source_color;
uniform vec3 color_1 : source_color;
uniform vec3 color_2 : source_color;
uniform vec3 color_3 : source_color;
uniform sampler2D caustics : source_color;
uniform float slowdown : hint_range( 0.1, 10.0, 0.1 ) = 5.0;
uniform float time_caust : hint_range( 0.01, 1.0, 0.01 ) = 0.13;
uniform float caust_form : hint_range( 0.01, 1.0, 0.01 ) = 0.15;
uniform float tile: hint_range( 0.1, 16.0, 0.1 ) = 4.0;

void fragment() {
	vec3 color;

// Caustics
	float caustics_form = texture(caustics , UV * (tile + sin(TIME / slowdown) * time_caust )).r;//
	vec2 caustics_uv =  UV * (tile + cos(TIME / slowdown) * time_caust ) + caustics_form * caust_form ;
	float caustics_final = texture(caustics, caustics_uv).r;
	
	color = texture(caustics, UV * tile).rgb;
	vec3 out_color = color.r * color_1 + color.b * color_2 + color.g * color_3;
	
	ALBEDO = (1.0-SCREEN_UV.y) * caustics_final * out_color ;
	//ALPHA = min(SCREEN_UV.y + 0.5, 1.0 ) * tint_color.a;
		
}