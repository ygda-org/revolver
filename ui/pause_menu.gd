extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if visible:
			visible = false
			$Start.stop()
			$AudioStreamPlayer.stop()
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true
			$Start.play(0.0)


func _on_audio_stream_player_finished():
	if visible:
		$AudioStreamPlayer.play(0.0)


func _on_start_finished():
	if visible:
		$AudioStreamPlayer.play(0.0)
