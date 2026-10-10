extends Node2D

class_name Room

##Left Gate Marker. Will snap to a rooms right gate.
@export var left_gate : Marker2D

##Right Gate Marker. Wll snap to a rooms left gate.
@export var right_gate : Marker2D

##Length of Room. Units arbitrary, approx proportional
@export var length : int = 1
