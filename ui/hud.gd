extends Control

func _ready() -> void:
	GameState.bullet_is_cycled.connect(_on_bullet_is_cycled)
	GameState.start_reload.connect(_on_start_reload)
	GameState.stop_reload.connect(_on_stop_reload)
	GameState.player_hit.connect($HitStaticTimer.start)
	GameState.player_dead.connect($DeathTimer.start)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$RepairBar.value = lerpf($RepairBar.value, GameState.repair_amount * 100, delta * 2)
	if GameState.player.health == 1:
		$Vignette.scale = $Vignette.scale.lerp(Vector2(1,1), delta*15)
	else:
		$Vignette.scale = $Vignette.scale.lerp(Vector2(3, 3), delta*10)
	if not $DeathTimer.is_stopped():
		$HitStatic.visible = true
		$HitStatic.material.set_shader_parameter("multiplier", move_toward($HitStatic.material.get_shader_parameter("multiplier"), 500, delta * 21))
		return
	if $HitStaticTimer.is_stopped():
		$HitStatic.material.set_shader_parameter("multiplier", move_toward($HitStatic.material.get_shader_parameter("multiplier"), 0.0, delta * 2))
	else:
		$HitStatic.visible = true
		$HitStatic.material.set_shader_parameter("multiplier", move_toward($HitStatic.material.get_shader_parameter("multiplier"), 0.5, delta * 9))
	if $HitStatic.material.get_shader_parameter("multiplier") < 0.01:
		$HitStatic.visible = false

func _on_bullet_is_cycled():
	$RevolverAnim.play("switch")
	$BulletUi.spin()
	

func _on_start_reload():
	$RevolverAnim.play("reload")
	$RevolverAnim.frame_changed.connect($BulletUi.tick_step)

func _on_stop_reload():
	$RevolverAnim.stop()
	$RevolverAnim.frame_changed.disconnect($BulletUi.tick_step)
	$RevolverAnim.play("default")
	$BulletUi.reset_rotation()


func _on_death_timer_timeout():
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($ColorRect, "position", Vector2($ColorRect.position.x + 500, 0), 0.2)
	tween.tween_property($ColorRect2, "position", Vector2($ColorRect2.position.x - 500, 0), 0.2)
	Sfx.force_clear_audios()
	Sfx.paused = true
	MusicPlayer.force_clear_music(true)
	Sfx.play(Sfx.Labels.TV_OFF, true)
	await get_tree().create_timer(1.5).timeout
	GameState.game_reset()
	Sfx.paused = false
	$HitStatic.material.set_shader_parameter("multiplier", 0.0)
	get_tree().change_scene_to_file("uid://cnoahdbn2sxq3")
