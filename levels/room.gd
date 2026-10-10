extends Node2D

class_name Room

##Size of the room in units of 16x16 tiles.
##X value is width, Y value is height.
@export var size : Vector2 = Vector2(1,1)

##An array of the entrances/exits in a room.
##The first two numbers is the coordinate of the "unit".
##The last two is the relative vector of the opening.
@export var gates : Array[Vector4] = [
	Vector4(0,0,0,0)
]
