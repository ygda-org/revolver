extends Node

signal level_started
signal bullet_is_cycled

signal start_reload
signal stop_reload

const REPAIR_DISTANCE_THRESHOLD = 100
const BULLET_PARRY_DAMAGE = 25

var player: Player
var camera

## array of all active enemy components
var active_enemies: Array[EnemyComponent]

var chosen_barrel: Array[BulletResource] = []
var active_barrel: Array[BulletResource] = []
var barrel_index: int = 0
var barrel_size: int = 6

## player heals when it reaches 1. Only fills when the player is in critical and gets filled when you kill enemies from close range
var repair_amount: float = 0.0

const EMPTY_RES : BulletResource = preload("uid://c7kvyedwvgnr0")

var inventory : Dictionary[BulletResource, int] = {
	
}

const NORMAL_RES : BulletResource = preload("res://player/bullet/bullet_resources/normal.tres")

func _ready():
	for i in range(barrel_size):
		active_barrel.append(EMPTY_RES)
		chosen_barrel.append(EMPTY_RES)
	chosen_barrel[0] = NORMAL_RES
	active_barrel[0] = NORMAL_RES
	chosen_barrel[1] = NORMAL_RES
	active_barrel[1] = NORMAL_RES
	chosen_barrel[2] = NORMAL_RES
	active_barrel[2] = NORMAL_RES
	
	inventory[NORMAL_RES] = 3
	
	# for testing
	active_barrel[1] = load("uid://croa2j6asmrij")

## cycle bullet by dir, then mod by barrel size
func bullet_cycle(dir: int):
	bullet_is_cycled.emit()
	barrel_index += dir
	barrel_index = posmod(barrel_index, active_barrel.size())

func reload():
	for i in range(barrel_size):
		active_barrel[i] = chosen_barrel[i].duplicate()
	barrel_index = 0

## for use with shooting. Returns current bullet and cycles the barrel
func get_bullet():
	var bullet: BulletResource = active_barrel[barrel_index]
	active_barrel[barrel_index] = load("uid://c7kvyedwvgnr0") # empty slot
	bullet_cycle(1)
	return bullet

## pass in global position, get enemy component of nearest enemy
func get_closest_enemy_to_position(pos: Vector2):
	if not active_enemies:
		return null
	var closest: EnemyComponent
	for enemy in active_enemies:
		if not enemy:
			continue
		if not closest:
			closest = enemy
		if pos.distance_squared_to(enemy.global_position) < pos.distance_squared_to(closest.global_position):
			closest = enemy
	return closest

## for the purposes of the repair bar
func enemy_death(enemy: EnemyComponent):
	if player.health != 1:
		return
	if enemy.global_position.distance_to(player.global_position) < REPAIR_DISTANCE_THRESHOLD:
		repair_amount += enemy.repair_add_amount
	if repair_amount >= 1.0 and player.health == 1:
		repair_amount = 0.0
		player.health = 2
