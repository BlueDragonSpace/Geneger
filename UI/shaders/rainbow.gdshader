shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

/*
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform int pixel_size : hint_range(1, 64) = 4; // Pixel size
uniform vec2 screen_size = vec2(1920.0, 1080.0); // Screen size (set manually)

void fragment() {

    //Pixel coordinates in screen space
    vec2 pixel_coords = floor(FRAGCOORD.xy / float(pixel_size)) * float(pixel_size);
    // Convert pixel coordinates to UVs for screen texture
    vec2 uv = pixel_coords / screen_size;
    // Get color from texture screen
    COLOR = texture(SCREEN_TEXTURE, uv);
}
*/

float pytha(float one, float two) {
	float three = pow(one, 2) + pow(two, 2);
	three = sqrt(three);
	return three;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 new_color = texture(SCREEN_TEXTURE, UV);

	new_color.a = 0.5;
	new_color.r = pytha(UV.x, UV.y);

	//how do hsv values???

	COLOR = new_color;
}
