shader_type canvas_item;

//uniform float flash_modulate;
uniform vec4[4] old_color : source_color;
uniform vec4[4] new_color : source_color;

void fragment() {
	//COLOR.rgb += flash_modulate * vec3(1.0,1.0,1.0);
	for (int i = 0; i < 4; i++){
		if (COLOR == old_color[i]){
			COLOR = new_color[i];
		}
	}
}
