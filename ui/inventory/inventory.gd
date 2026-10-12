extends Control

class_name Inventory

const DRAG_BULLET = preload("uid://ct6eu3ndhd4ml")

@onready var area_to_marker : Dictionary[Area2D, Marker2D] = {
	$ChosenBullets/BArea1 : $ChosenBullets/Chosen1,
	$ChosenBullets/BArea2 : $ChosenBullets/Chosen2,
	$ChosenBullets/BArea3 : $ChosenBullets/Chosen3,
	$ChosenBullets/BArea4 : $ChosenBullets/Chosen4,
	$ChosenBullets/BArea5 : $ChosenBullets/Chosen5,
	$ChosenBullets/BArea6 : $ChosenBullets/Chosen6,
}

var bullet_to_home : Dictionary[DragBullet, Marker2D] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var total_bullets : float = GameState.inventory.values().reduce(func(accum, number): return accum + number, 0)
	if total_bullets <= 10:
		$TopLeft.position.y = 270
		generate_inven_markers(3, total_bullets)
	elif total_bullets <= 20:
		$TopLeft.position.y += 75
		$BotRight.position.y -= 75
		generate_inven_markers(2, ceil(total_bullets/2))
	else:
		generate_inven_markers(3, ceil(total_bullets/3))
	#Duplicate cur Barrel
	var dup_chosen : Array[BulletResource] = GameState.chosen_barrel.duplicate()
	#Current marker
	var cur_marker = 0
	#Bullets to place in inven normally; unused bullets
	var unused_bullets : Array[DragBullet] = []
	for b_res : BulletResource in GameState.inventory.keys():
		for i in range(GameState.inventory[b_res]):
			var drag_bullet : DragBullet = DRAG_BULLET.instantiate()
			drag_bullet.bullet_resource = b_res
			bullet_to_home[drag_bullet] = $InvenMarkers.get_child(cur_marker)
			cur_marker += 1
			#If it is a chosen bullet, snap there
			if b_res in dup_chosen:
				var cur_chosen = dup_chosen.find(b_res)
				dup_chosen[cur_chosen] = null
				var loc : Marker2D = $ChosenBullets.get_child(cur_chosen)
				drag_bullet.position = loc.global_position
				drag_bullet.set_is_full(false)
			#Else, lets move it to its spot
			else:
				drag_bullet.position = Vector2(-100,-100)
				unused_bullets.append(drag_bullet)
			add_child(drag_bullet)
	#var tween : Tween = get_tree().create_tween()
	#for drag_bullet : DragBullet in unused_bullets:
		#var goal : Vector2 = bullet_to_home[drag_bullet].global_position
		#tween.tween_property(drag_bullet, "global_position", goal, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	
	var accume_offset : float = 0
	var increment : float = 0.12
	for drag_bullet : DragBullet in unused_bullets:
		var goal : Vector2 = bullet_to_home[drag_bullet].global_position
		var tween : Tween = get_tree().create_tween()
		tween.tween_interval(accume_offset)
		tween.tween_property(drag_bullet, "global_position", goal, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		accume_offset += increment
		if increment > 0.02:
			increment *= 0.95

func generate_inven_markers(rows : int, columns : int):
	var x_vec : float = $BotRight.position.x - $TopLeft.position.x
	var y_vec : float = $BotRight.position.y - $TopLeft.position.y
	for r in range(0, rows):
		for c in range(0, columns):
			var r_percent = r/float(rows-1)
			var c_percent = c/float(columns-1)
			var marker : Marker2D = Marker2D.new()
			marker.position = $TopLeft.position
			marker.position.x += x_vec * c_percent
			marker.position.y += y_vec * r_percent
			$InvenMarkers.add_child(marker)


func _on_exit_pressed() -> void:
	for i in range(6):
		GameState.chosen_barrel[i] = GameState.EMPTY_RES
	for child in get_children():
		if not child is DragBullet:
			continue
		var drag_bul : DragBullet = child
		if drag_bul.global_position == $ChosenBullets/Chosen1.global_position:
			GameState.chosen_barrel[0] = drag_bul.bullet_resource
		elif drag_bul.global_position == $ChosenBullets/Chosen2.global_position:
			GameState.chosen_barrel[1] = drag_bul.bullet_resource
		elif drag_bul.global_position == $ChosenBullets/Chosen3.global_position:
			GameState.chosen_barrel[2] = drag_bul.bullet_resource
		elif drag_bul.global_position == $ChosenBullets/Chosen4.global_position:
			GameState.chosen_barrel[3] = drag_bul.bullet_resource
		elif drag_bul.global_position == $ChosenBullets/Chosen5.global_position:
			GameState.chosen_barrel[4] = drag_bul.bullet_resource
		elif drag_bul.global_position == $ChosenBullets/Chosen6.global_position:
			GameState.chosen_barrel[5] = drag_bul.bullet_resource
	GameState.reload()
	get_tree().call_deferred("change_scene_to_file","res://main/main.tscn")
