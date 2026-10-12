extends Room

var elapsed_time : float = 0

var shop_inven : Array[BulletResource] = []

var shop_enabled : bool = true
var is_light_changing : bool = true

@onready var bullet_tex : TextureRect = $Screen/VBoxContainer/HBoxContainer/BulletTexture
@onready var bullet_name : Label = $Screen/VBoxContainer/HBoxContainer/Name
@onready var bullet_desc : Label = $Screen/VBoxContainer/Description
@onready var bullet_damage : Label = $Screen/VBoxContainer/HBoxContainer2/Damage
@onready var bullet_speed : Label = $Screen/VBoxContainer/HBoxContainer2/Speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(5):
		var area : Area2D = $Areas.get_child(i)
		var hover : Area2D = $Hovers.get_child(i)
		area.body_entered.connect(_on_body_entered.bind(i))
		hover.body_entered.connect(_on_hovers_entered.bind(i))
	var temp : Array[BulletResource] = []
	for room_file in ResourceLoader.list_directory("res://player/bullet/bullet_resources/"):
		temp.append(load("res://player/bullet/bullet_resources/" + room_file))
	temp.shuffle()
	for i in range(5):
		var node : Sprite2D = $BulletOps.get_child(i)
		shop_inven.append(temp.pop_front())
		var res : BulletResource = shop_inven[i]
		node.material.set_shader_parameter("outline_color", res.outline_color)
		var title : Label = $BulletNames.get_child(i)
		title.text = res.bullet_name

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

func _on_hovers_entered(body : Node2D, idx : int):
	if not body is Player:
		return
	if not shop_enabled:
		return
	var res : BulletResource = shop_inven[idx]
	bullet_tex.material.set_shader_parameter("outline_color", res.outline_color)
	bullet_name.text = res.bullet_name
	bullet_desc.text = res.description
	bullet_damage.text = "Damage: " + str(res.damage)
	bullet_speed.text = "Speed: " + str(res.speed)
	return


func _on_room_entry_trigger_body_entered(body):
	if body is Player:
		var new_cam = load("uid://cgx6o1n5kloe4").instantiate()
		new_cam.target_position = global_position + Vector2(280, 130)
		add_child(new_cam)
		new_cam.global_position = GameState.camera.get_screen_center_position()
		GameState.camera.enabled = false
