shader_type canvas_item;

uniform vec4 outline_color;
uniform vec4 fill_color;

void fragment() {
	if (COLOR.a == 0.0)
		COLOR.a = 0.0;
	else if (COLOR.r == 1.0)
		COLOR = fill_color;
	else
		COLOR = outline_color;
}
