extends Node2D

class_name Room

##Left Gate Marker. Will snap to a rooms right gate.
@export var left_gate : Marker2D

##Right Gate Marker. Wll snap to a rooms left gate.
@export var right_gate : Marker2D

##Length of Room. Units arbitrary, approx proportional
@export var length : int = 1

@export var enemies = []

var has_enemies : bool = true

func _ready():
	if len(enemies) == 0:
		has_enemies = false

func _process(delta: float) -> void:
	if has_enemies and not enemies.any(func(a): return a != null):
		has_enemies = false
		if has_node("Door"):
			$Door.open()
