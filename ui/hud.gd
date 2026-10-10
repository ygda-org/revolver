extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$RepairBar.value = GameState.repair_amount
