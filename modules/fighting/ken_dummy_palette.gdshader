shader_type canvas_item;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	vec3 colour = source.rgb;
	bool red_gi = colour.r > 0.18
		&& colour.g < 0.48
		&& colour.r > colour.g * 1.35
		&& colour.r > colour.b * 1.45;
	if (red_gi) {
		float original_red = colour.r;
		colour.r = colour.b * 0.55;
		colour.g = max(colour.g, original_red * 0.28);
		colour.b = original_red;
	}
	COLOR = vec4(colour, source.a);
}
