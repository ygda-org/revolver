extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	
	if Input.is_action_pressed("ui_up"):
		$Camera2D.zoom += Vector2(1,1) * delta
	if Input.is_action_pressed("ui_down"):
		$Camera2D.zoom += -Vector2(1,1) * delta
	
	var mouse_vector = get_viewport().get_mouse_position() - Vector2(960/2, 540/2)
	if mouse_vector.length_squared() < 10000:
		return
	$Camera2D.position += mouse_vector * delta
