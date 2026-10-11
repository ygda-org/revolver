extends Node2D

class_name BulletUI

@onready var pivot : Node2D = $SubViewportContainer/SubViewport/Pivot

var hold_spin : bool = false
var accumulator : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.start_reload.connect(_on_start_reload)
	GameState.stop_reload.connect(_on_stop_reload)
	render_bullets()

func spin():
	render_bullets()
	var tween := get_tree().create_tween()
	tween.tween_property(pivot, "rotation_degrees", -60, (5.0/32))
	tween.tween_property(pivot, "rotation_degrees", 0, 0)
	await tween.finished
	render_bullets()

func render_bullets():
	pivot.rotation = 0
	for i in range(len(GameState.active_barrel)):
		var b_res : BulletResource = GameState.active_barrel[posmod(i + GameState.barrel_index, len(GameState.active_barrel))]
		var sprite : Sprite2D = pivot.get_child(i)
		if b_res.effect == BulletResource.effects.PARRY:
			sprite.visible = false
			continue
		sprite.visible = true
		sprite.material.set_shader_parameter("outline_color", b_res.outline_color)

func tick_step():
	pivot.rotation_degrees -= 15

func _on_start_reload():
	pass

func _on_stop_reload():
	pivot.rotation = 0
	render_bullets()

func reset_rotation():
	pivot.rotation = 0
