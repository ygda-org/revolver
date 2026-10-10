extends Node2D

var pool : Array[PackedScene] = []

var min_rooms : int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for room_file in ResourceLoader.list_directory("res://levels/test_rooms/"):# DirAccess.get_files_at("res://level/rooms/room_for_real/"):
		pool.append(load("res://levels/test_rooms/" + room_file))
	generate()

func size_to_cells(size : Vector2) -> Array[Vector2]:
	var array : Array[Vector2] = []
	for x in range(size.x):
		for y in range(size.y):
			array.append(Vector2(x,y))
	return array

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_accept"):
		for i in range(1, get_child_count()):
			get_child(i).queue_free()
		generate()
	
	if Input.is_action_pressed("ui_up"):
		$Camera2D.zoom += Vector2(1,1) * delta
	if Input.is_action_pressed("ui_down"):
		$Camera2D.zoom += -Vector2(1,1) * delta
	
	var mouse_vector = get_viewport().get_mouse_position() - Vector2(960/2, 540/2)
	print(mouse_vector)
	if mouse_vector.length_squared() < 10000:
		return
	$Camera2D.position += mouse_vector * delta

func generate() -> void:
	var vtx_filled : Array[Vector2] = []
	var edges : Array[Vector4] = []
	#load first room
	var room_1 : Room = pool.pick_random().instantiate()
	edges.append_array(room_1.gates)
	vtx_filled.append_array(size_to_cells(room_1.size))
	add_child(room_1)
	for i in range(min_rooms - 1):#1 less as first room already placed
		if len(edges) == 0:
			break
		var edge_item : Vector4 = edges.pop_back()
		var anchor_cell : Vector2 = Vector2(edge_item.w, edge_item.x)
		var dir : Vector2 = Vector2(edge_item.y, edge_item.z)
		var target_cell : Vector2 = dir + anchor_cell
		
		#go through each room
		pool.shuffle()
		for pack_room : PackedScene in pool:
			var room : Room = pack_room.instantiate()
			var space : Array[Vector2] = size_to_cells(room.size)
			var is_room_valid : bool = false
			#check if room occupies another room
			for g in room.gates:
				var pos_anti_gate : Vector2 = Vector2(g.y, g.z)
				if pos_anti_gate == -dir:
					is_room_valid = true
					#The cell we place at is no longer top left,
					#as the edge can be in arbitrary cell.
					#Thus, offset needed
					target_cell -= Vector2(g.w, g.x)
			if not is_room_valid:
				continue
			#check if room occupies another room
			for cell in space:
				if target_cell + cell in vtx_filled:
					is_room_valid = false
					break
			if not is_room_valid:
				continue
			#cells are 16 tiles and tiles are 16 pixels
			room.position = target_cell * 16 * 16
			add_child(room)
			#offset gates and space vectors to match real poz
			var gates : Array[Vector4] = room.gates.duplicate()
			for g_i in range(len(gates)):
				gates[g_i].w += target_cell.x
				gates[g_i].x += target_cell.y
			for s_i in range(len(space)):
				space[s_i] += target_cell
			edges.append_array(gates)
			vtx_filled.append_array(space)
