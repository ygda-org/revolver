extends CharacterBody2D

@export var speed: float = 80.0
@export var direction: int = -1

func _ready():
	$RaycastPivot.scale.x = direction

func _physics_process(delta):
	if is_on_wall() or not $RaycastPivot/WalkoffDetector.is_colliding():
		direction *= -1
	$RaycastPivot.scale.x = direction
	velocity.x = direction * speed
	if $RaycastPivot/PlayerDetector.is_colliding():
		velocity.x *= 2
	move_and_slide()
