shader_type canvas_item;

uniform vec4 outline_color;

void fragment() {
	vec4 color_diff = vec4(1.0) - outline_color;
	COLOR.rgb = ((color_diff.rgb) * (COLOR.r));
	COLOR.rgb = COLOR.rgb + outline_color.rgb;
}
