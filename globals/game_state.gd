extends Node

signal level_started

var player: Player

var chosen_barrel: Array[BulletResource] = []
var active_barrel: Array[BulletResource] = []
var barrel_index: int = 0
var barrel_size: int = 6

func _ready():
	for i in range(barrel_size):
		active_barrel.append(load("uid://buewsi61jgls0"))

## cycle bullet by dir, then mod by barrel size
func bullet_cycle(dir: int):
	barrel_index += dir
	barrel_index = posmod(barrel_index, active_barrel.size())

func reload():
	for i in range(barrel_size):
		active_barrel.append(chosen_barrel[i].duplicate())

## for use with shooting. Returns current bullet and cycles the barrel
func get_bullet():
	var bullet: BulletResource = active_barrel[barrel_index]
	active_barrel[barrel_index] = load("uid://c7kvyedwvgnr0") # empty slot
	bullet_cycle(1)
	return bullet
