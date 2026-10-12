shader_type canvas_item;

uniform vec4 old_color : source_color;
uniform vec4 new_color : source_color;

uniform vec4 old_color2 : source_color;
uniform vec4 new_color2 : source_color;

uniform vec4 old_color3 : source_color;
uniform vec4 new_color3 : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (COLOR.r-old_color.r < 0.01 && COLOR.b-old_color.b < 0.01 && COLOR.g-old_color.g < 0.01){
		COLOR = new_color;
	}
	if (COLOR == old_color2){
		COLOR = new_color2;
	}
	if (COLOR == old_color3){
		COLOR = new_color3;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
