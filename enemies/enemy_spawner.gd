extends Node2D

## if flying, spawns flying enemies. Else does grounded ones
@export var flying: bool = false

const FLYING = [preload("uid://bjxissut13r5b"), 
preload("uid://1qekgha414yp"),
preload("uid://c1c7vo31sm74l")]

const GROUNDED = [preload("uid://dbj21rwlxkyql"),
preload("uid://cqkgsr8jgrndt"),
preload("uid://cx5ec1o3ypbvs")]

var active_array

func _ready():
	if flying:
		active_array = FLYING
	else:
		active_array = GROUNDED
	
	add_child(active_array.pick_random().instantiate())
