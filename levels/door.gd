extends Node2D


func open():
	Sfx.play(Sfx.Labels.ROOM_CLEAR_DOOR)
	$Anim.play("open")
	await $Anim.animation_finished
	$CollisionShape2D.disabled = true
