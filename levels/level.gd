extends Node2D

var pool : Array[PackedScene] = []

var start_room : PackedScene = preload("res://levels/start_end_rooms/t_room_start.tscn")
var end_room : PackedScene = preload("res://levels/start_end_rooms/t_room_end.tscn")

# intended 16
var level_length : int = 11

const ROOMS_PATH : String = "res://levels/finalized_levels/"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.level_started.emit()
	for room_file in ResourceLoader.list_directory(ROOMS_PATH):
		pool.append(load(ROOMS_PATH + room_file))
	#pool.sort_custom(func(a,b): return a.length > b.length)
	generate()

#func _process(delta: float) -> void:
	#
	#if Input.is_action_just_pressed("ui_accept"):
		#for i in range(1, get_child_count()):
			#get_child(i).queue_free()
		#generate()
	#
	#if Input.is_action_pressed("ui_up"):
		#$Camera2D.zoom += Vector2(1,1) * delta
	#if Input.is_action_pressed("ui_down"):
		#$Camera2D.zoom += -Vector2(1,1) * delta
	#
	#var mouse_vector = get_viewport().get_mouse_position() - Vector2(960/2, 540/2)
	#if mouse_vector.length_squared() < 10000:
		#return
	#$Camera2D.position += mouse_vector * delta

func generate() -> void:
	var queue : Array[Room] = []
	var remaining_length : int = level_length
	
	var room_1 : Room = start_room.instantiate()
	add_child(room_1)
	var anchor : Marker2D = room_1.right_gate if room_1.right_gate else room_1.get_node("RightGate")
	
	var room_last : Room = end_room.instantiate()
	
	remaining_length -= room_1.length
	remaining_length -= room_last.length
	
	while(remaining_length > 0):
		var r : Room = pool.pick_random().instantiate()
		if r.length > remaining_length:
			continue
		remaining_length -= r.length
		queue.append(r)
	queue.append(room_last)
	
	for r in queue:
		anchor.position = snapped(anchor.position, Vector2(16,16))
		var left_gate = r.left_gate if r.left_gate else r.get_node("LeftGate")
		left_gate.position = snapped(left_gate.position, Vector2(16,16))
		r.position = anchor.global_position - left_gate.position
		add_child(r)
		if r == queue[-1]:
			continue
		anchor = r.right_gate if r.right_gate else r.get_node("RightGate")
