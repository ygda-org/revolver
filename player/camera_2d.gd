extends Camera2D

var target_offset
var trauma: float = 0.0
var trauma_decay: float = 1.5
@export var noise : FastNoiseLite
var max_shake: Vector2 = Vector2(50, 30)
var noise_height = 0

var zoom_trauma: float = 1.0
var zoom_trauma_decay: float = 1.5
const MAX_ZOOM_TRAUMA_DIFF = 0.5

const MULTIPLIER = 1.9

func _ready():
	noise.seed = 1042314
	GameState.camera = self

func _process(delta):
	if trauma:
		trauma = clampf(trauma-trauma_decay*delta, 0, 2)
		shake()
	else:
		offset = offset.lerp(target_offset, delta*20)
	offset = offset.clamp(-max_shake, max_shake)
	zoom_trauma = clampf(move_toward(zoom_trauma, 1, delta*zoom_trauma_decay), 1-MAX_ZOOM_TRAUMA_DIFF, 1+MAX_ZOOM_TRAUMA_DIFF)
	zoom = zoom.lerp(Vector2(2,2)*zoom_trauma, delta * 20)

func add_trauma(amount):
	if trauma:
		trauma += amount * (1/(1+2*(amount+trauma)))
	else:
		trauma += amount

func shake():
	var strength = pow(trauma, 2.5)
	noise_height += 1
	offset.x = target_offset.x + MULTIPLIER * max_shake.x * strength * noise.get_noise_2d(noise.seed*2,noise_height)
	offset.y = target_offset.y + MULTIPLIER * max_shake.y * strength * noise.get_noise_2d(noise.seed*3,noise_height)

func add_zoom_trauma(amount):
	if zoom_trauma:
		zoom_trauma += amount * (1/(1+abs(amount*8+zoom_trauma))) * 0.5
	else:
		zoom_trauma += amount
