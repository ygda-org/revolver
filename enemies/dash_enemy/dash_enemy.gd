extends CharacterBody2D

@export var speed: float = 80.0
@export var direction: int = -1

func _ready():
	$RaycastPivot.scale.x = direction

func _physics_process(delta):
	if not is_on_floor():
		velocity.y = 50
	if is_on_wall() or not $RaycastPivot/WalkoffDetector.is_colliding():
		direction *= -1
	$RaycastPivot.scale.x = direction
	velocity.x = direction * speed
	if $RaycastPivot/PlayerDetector.is_colliding():
		velocity.x *= 2
	
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i).get_collider()
		if col is Player:
			col.hit(self)
	
	move_and_slide()
