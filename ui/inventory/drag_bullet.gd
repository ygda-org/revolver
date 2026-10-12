extends Node2D

class_name DragBullet

var mouse_offset : Vector2 = Vector2.ZERO
var moving : bool = false

var intersecting_areas : Array[Area2D] = []

var bullet_resource : BulletResource

@onready var parent : Inventory = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.material.set_shader_parameter("outline_color", bullet_resource.outline_color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Button.button_pressed and moving:
		global_position = get_global_mouse_position() + mouse_offset

func _on_button_button_up() -> void:
	moving = false
	if intersecting_areas.is_empty():
		var goal_poz : Vector2 = parent.bullet_to_home[self].global_position
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", goal_poz, 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	else:
		#Snap to nearest marker
		var closest_area2d : Area2D = intersecting_areas[0]
		var dist : float = (closest_area2d.global_position - global_position).length_squared()
		for a : Area2D in intersecting_areas.slice(1):
			var new_dist : float = (a.global_position - global_position).length_squared()
			if new_dist < dist:
				dist = new_dist
				closest_area2d = a
		var loc : Marker2D = parent.area_to_marker[closest_area2d]
		global_position = loc.global_position
		#If there is a bullet there already, move them away
		for child in parent.get_children():
			if child == self:
				continue
			if child is DragBullet and child.global_position == global_position:
				var drag_child : DragBullet = child
				var goal_poz2 : Vector2 = parent.bullet_to_home[drag_child].global_position
				var tween2 = get_tree().create_tween()
				tween2.tween_property(child, "global_position", goal_poz2, 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)


func _on_button_button_down() -> void:
	mouse_offset = global_position - get_global_mouse_position()
	moving = true

func set_is_full(value : bool):
	$Full.visible = value
	$Back.visible = not value


func _on_area_2d_area_entered(area: Area2D) -> void:
	if "BArea" in area.name:
		intersecting_areas.append(area)
		set_is_full(false)


func _on_area_2d_area_exited(area: Area2D) -> void:
	if "BArea" in area.name:
		intersecting_areas.remove_at(intersecting_areas.find(area))
	if len(intersecting_areas) == 0:
		set_is_full(true)


func _on_button_mouse_entered() -> void:
	parent.update_tooltip(bullet_resource)
