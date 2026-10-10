extends Camera2D

var target_offset
var trauma: float = 0.0
var trauma_decay: float = 1.5
@export var noise : FastNoiseLite
var max_shake: Vector2 = Vector2(100, 70)
var noise_height = 0

func _ready():
	noise.seed = randi()

func _process(delta):
	if trauma:
		trauma = clampf(trauma-trauma_decay*delta, 0, 3)
		shake()
	else:
		offset = offset.lerp(target_offset, delta*20)

func add_trauma(amount):
	trauma += amount

func shake():
	var strength = pow(trauma, 2.5)
	noise_height += 15
	offset.x = target_offset.x + max_shake.x * strength * noise.get_noise_2d(noise.seed*2,noise_height)
	offset.y = target_offset.y + max_shake.y * strength * noise.get_noise_2d(noise.seed*3,noise_height)
