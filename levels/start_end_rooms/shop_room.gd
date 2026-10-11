extends Room

var elapsed_time : float = 0

var shop_inven : Array[BulletResource] = []

var shop_enabled : bool = true
var is_light_changing : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(5):
		var area : Area2D = $Areas.get_child(i)
		area.body_entered.connect(_on_body_entered.bind(i))
	var temp : Array[BulletResource] = []
	for room_file in ResourceLoader.list_directory("res://player/bullet/bullet_resources/"):
		temp.append(load("res://player/bullet/bullet_resources/" + room_file))
	temp.shuffle()
	for i in range(5):
		var node : Sprite2D = $BulletOps.get_child(i)
		shop_inven.append(temp.pop_front())
		var res : BulletResource = shop_inven[i]
		node.material.set_shader_parameter("outline_color", res.outline_color)

# Called every frame. 'delta' is the elapsed time since the prevdious frame.
func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if is_light_changing:
		update_lights(0.4 + sin(elapsed_time) * 0.1)

func update_lights(amount : float):
	for l in $Lights.get_children():
		l.texture.gradient.set_offset(1,amount)

func _on_body_entered(body : Node2D, idx : int):
	if not body is Player:
		return
	if not shop_enabled:
		return
	if shop_inven[idx] in GameState.inventory.keys():
		GameState.inventory[shop_inven[idx]] += 1
	else:
		GameState.inventory[shop_inven[idx]] = 1
	shop_enabled = false
	is_light_changing = false
	update_lights(0.1)
	for option : Sprite2D in $BulletOps.get_children():
		option.visible = false
