extends Control

func _ready() -> void:
	GameState.bullet_is_cycled.connect(_on_bullet_is_cycled)
	GameState.start_reload.connect(_on_start_reload)
	GameState.stop_reload.connect(_on_stop_reload)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$RepairBar.value = GameState.repair_amount
	if GameState.player.health == 1:
		$Vignette.scale = $Vignette.scale.lerp(Vector2(1,1), delta*15)
	else:
		$Vignette.scale = $Vignette.scale.lerp(Vector2(1.5, 1.5), delta*10)

func _on_bullet_is_cycled():
	$RevolverAnim.play("switch")
	$BulletUi.spin()
	

func _on_start_reload():
	$RevolverAnim.play("reload")

func _on_stop_reload():
	$RevolverAnim.stop()
	$BulletUi.render_bullets()
	$RevolverAnim.play("default")
