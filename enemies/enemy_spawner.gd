extends Node2D

## if flying, spawns flying enemies. Else does grounded ones
@export var flying: bool = false

const FLYING = [preload("uid://bjxissut13r5b"), 
preload("uid://1qekgha414yp")]

const GROUNDED = [preload("uid://dbj21rwlxkyql")]

var active_array

func _ready():
	if flying:
		active_array = FLYING
	else:
		active_array = GROUNDED
	
	add_child(active_array.pick_random().instantiate())
