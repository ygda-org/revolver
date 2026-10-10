extends Resource
class_name BulletResource

@export var damage: int = 10
@export var speed: float = 350
@export var recoil: float = 0.0
@export var effect: effects
@export var effect_strength: float = 0.0
## if true, then runs the bullet effect when you shoot, as opposed to when you hit an enemy
@export var effect_on_shot: bool = false
@export var called_in_process: bool = false

enum effects {
	NONE,
	FREEZE,
	DASH,
	FIRE,
	COIN
}
