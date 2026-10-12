extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		GameState.cleared_levels += 1
		GameState.repair_amount = 0.0
		get_tree().call_deferred("change_scene_to_file","res://ui/inventory/inventory.tscn")
