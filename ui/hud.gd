extends Control

func _ready() -> void:
	GameState.bullet_is_cycled.connect(_on_bullet_is_cycled)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$RepairBar.value = GameState.repair_amount

func _on_bullet_is_cycled():
	$RevolverAnim.play("switch")
