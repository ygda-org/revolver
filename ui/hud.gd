extends Control

func _ready() -> void:
	GameState.bullet_is_cycled.connect(_on_bullet_is_cycled)
	GameState.start_reload.connect(_on_start_reload)
	GameState.stop_reload.connect(_on_stop_reload)
	GameState.player_hit.connect($HitStaticTimer.start)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$RepairBar.value = GameState.repair_amount
	if GameState.player.health == 1:
		$Vignette.scale = $Vignette.scale.lerp(Vector2(1,1), delta*15)
	else:
		$Vignette.scale = $Vignette.scale.lerp(Vector2(3, 3), delta*10)
	if $HitStaticTimer.is_stopped():
		$HitStatic.material.set_shader_parameter("multiplier", move_toward($HitStatic.material.get_shader_parameter("multiplier"), 0.0, delta * 2))
	else:
		$HitStatic.material.set_shader_parameter("multiplier", move_toward($HitStatic.material.get_shader_parameter("multiplier"), 0.5, delta * 9))
	

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
