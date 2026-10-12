extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if visible:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true
