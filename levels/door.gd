extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func open():
	self.visible = false
	$CollisionShape2D.disabled = true
