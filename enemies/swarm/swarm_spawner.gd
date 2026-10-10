extends Node2D

var sight_distance: float = 200
var to_spawn: int = 3

func _ready():
	for i in range(to_spawn):
		var child = load("uid://beqsmg5ppk8qu").instantiate()
		$Swarm.add_child(child)
		child.position += Vector2(randf_range(-5, 5), randf_range(-5,5))

func _process(_delta):
	if not $Swarm.get_children():
		die()
	if $Timer.is_stopped() and global_position.distance_to(GameState.player.global_position) < sight_distance:
		$Timer.start()
		set_target()

func die():
	queue_free()

func set_target(disable = false):
	for node in $Swarm.get_children():
		if disable:
			node.set_target_position(global_position)
			node.targeting = false
			continue
		node.targeting = true
		node.set_target_position(GameState.player.global_position + Vector2(randf_range(-5, 5), randf_range(-5,5)))

func _on_timer_timeout():
	if global_position.distance_to(GameState.player.global_position) < sight_distance:
		$Timer.start()
	else:
		set_target(true)
