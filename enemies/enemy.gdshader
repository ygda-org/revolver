shader_type canvas_item;

uniform float flash_modulate;

void fragment() {
	COLOR.rgb += flash_modulate * vec3(1.0,1.0,1.0);
}
