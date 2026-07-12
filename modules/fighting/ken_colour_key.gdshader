shader_type canvas_item;

// The source sheet uses an opaque teal backdrop rather than transparency.
// Remove only that exact colour, preserving the original sprite pixels.
uniform vec4 key_colour : source_color = vec4(0.0, 0.505882, 0.505882, 1.0);
uniform float tolerance = 0.012;

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	if (distance(pixel.rgb, key_colour.rgb) < tolerance) {
		pixel.a = 0.0;
	}
	COLOR = pixel;
}
