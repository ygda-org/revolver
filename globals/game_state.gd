extends Node

signal player_dead

signal level_started
signal bullet_is_cycled
signal player_hit

signal start_reload
signal stop_reload

const REPAIR_DISTANCE_THRESHOLD = 70
const BULLET_PARRY_DAMAGE = 25
var repair_amount_reducer = 1

var player: Player
var camera: Camera2D

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

var cleared_levels: int = 0

func game_reset():
	cleared_levels = 0
	inventory = {}
	repair_amount = 0
	barrel_size = 6
	barrel_index = 0
	chosen_barrel = []
	active_barrel = []
	active_enemies = []
	_ready()

func _ready():
	level_started.connect(level_start)
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
	#for i in range(6):
	#	active_barrel[i] = load("uid://cllwws72eb4kk")
	#active_barrel[1] = load("uid://dcemdey3p3kex")
	#active_barrel[0] = load("uid://dcemdey3p3kex")
	#active_barrel[2] = load("uid://dcemdey3p3kex")

## cycle bullet by dir, then mod by barrel size
func bullet_cycle(dir: int):
	Sfx.play(Sfx.Labels.NEXT_BULLET)
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
	if not closest:
		var dumb_node = Node2D.new()
		get_tree().current_scene.add_child(dumb_node)
		return dumb_node
	return closest

## for the purposes of the repair bar
func enemy_death(enemy: EnemyComponent):
	if player.health != 1:
		return
	if enemy.global_position.distance_to(player.global_position) < REPAIR_DISTANCE_THRESHOLD:
		repair_amount += enemy.repair_add_amount * repair_amount_reducer
		Sfx.play(Sfx.Labels.REPAIR_TICK)
	if repair_amount >= 1.0 and player.health == 1:
		repair_amount = 0.0
		player.health = 2
		Sfx.play(Sfx.Labels.FULL_REPAIR1)

## called by enemy spawner to tell it whether or not to spawn
func do_i_spawn():
	var random = randf()
	var threshold = (1/(1+pow(1.5, -cleared_levels))) + 0.15
	return random < threshold

func level_start():
	repair_amount_reducer = (1.34/(1+pow(1.5, cleared_levels))) + 0.33
