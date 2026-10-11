extends CPUParticles2D

func _ready():
	await get_tree().process_frame
	emitting = true

func _on_finished():
	queue_free()
