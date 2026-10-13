extends Control

var in_animation: bool = false

func _ready():
	MusicPlayer.start(MusicPlayer.Labels.MENU)

func _on_play_button_pressed():
	in_animation = true
	$PlayButton.disabled = true
	Sfx.play(Sfx.Labels.BUTTON_CLICK)
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($ColorRect, "position", Vector2($ColorRect.position.x + 500, 0), 0.2)
	tween.tween_property($ColorRect2, "position", Vector2($ColorRect2.position.x - 500, 0), 0.2)
	MusicPlayer.force_clear_music(true)
	Sfx.play(Sfx.Labels.TV_OFF, true)
	await get_tree().create_timer(1.5).timeout
	GameState.game_reset()
	get_tree().change_scene_to_file("uid://cnoahdbn2sxq3")


func _on_credits_button_pressed():
	if in_animation:
		return
	Sfx.play(Sfx.Labels.BUTTON_CLICK)
	var target_pos = Vector2(50, 250) if $Credits.position.y > 400 else Vector2(50, 700)
	var tween = get_tree().create_tween()
	tween.tween_property($Credits, "position", target_pos, 1.5)


func _on_play_button_mouse_entered():
	if in_animation:
		return
	Sfx.play(Sfx.Labels.BUTTON_HOVER)


func _on_credits_button_mouse_entered():
	if in_animation:
		return
	Sfx.play(Sfx.Labels.BUTTON_HOVER)
