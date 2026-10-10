extends Resource
class_name BulletResource

@export var damage: int = 10
@export var speed: float
@export var recoil: float = 0.0
@export var effect: effects
@export var effect_strength: float = 0.0

enum effects {
	NONE,
	FREEZE
}
