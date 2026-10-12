shader_type canvas_item;

uniform float flash_modulate;
uniform vec4 old_color : source_color;
uniform vec4 new_color : source_color;

uniform vec4 old_color2 : source_color;
uniform vec4 new_color2 : source_color;

uniform vec4 old_color3 : source_color;
uniform vec4 new_color3 : source_color;

uniform vec4 old_color4 : source_color;
uniform vec4 new_color4 : source_color;

uniform vec4 old_color5 : source_color;
uniform vec4 new_color5 : source_color;

void fragment() {
	COLOR.rgb += flash_modulate * vec3(1.0,1.0,1.0);
	if (COLOR == old_color){
		COLOR = new_color;
	}
	if (COLOR == old_color2){
		COLOR = new_color2;
	}
	if (COLOR == old_color3){
		COLOR = new_color3;
	}
	if (COLOR == old_color4){
		COLOR = new_color4;
	}
	if (COLOR == old_color5){
		COLOR = new_color5;
	}
}
