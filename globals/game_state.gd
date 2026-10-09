extends Node

signal level_started

var player: Player

var barrel: Array[BulletResource] = []
var barrel_index: int = 0
var barrel_size: int = 6

func _ready():
	level_started.connect(reload)

## cycle bullet by dir, then mod by barrel size
func bullet_cycle(dir: int):
	barrel_index += dir
	barrel_index = posmod(barrel_index, barrel.size())

func reload():
	barrel = []
	for i in range(6):
		barrel.append(load("uid://cllwws72eb4kk"))

func get_current_bullet():
	var bullet: BulletResource = barrel[barrel_index]
	barrel[barrel_index] = load("uid://c7kvyedwvgnr0")
	bullet_cycle(1)
	return bullet
