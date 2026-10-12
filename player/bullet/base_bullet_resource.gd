extends Resource
class_name BulletResource

@export var damage: int = 10
@export var speed: float = 450
@export var recoil: float = 0.0
@export var effect: effects
@export var effect_strength: float = 0.0
## if true, then runs the bullet effect when you shoot, as opposed to when you hit an enemy
@export var effect_on_shot: bool = false
@export var called_in_process: bool = false
@export var life_duration: float = 10.0
@export var shake_trauma: float = 0.5
@export var can_call_on_walls: bool = false
@export var invisible_and_no_collision: bool = false


enum OverrideSettings {
	NONE,
	PLAYBOTH,
	OVERRIDE
}
@export_category("SFX")
@export var override_shot_sfx: OverrideSettings
@export var shot_sfx_override: SFX.Labels
@export var override_hit_sfx: OverrideSettings
@export var hit_sfx_override: SFX.Labels

@export_category("Colors")
@export var outline_color: Color = Color(0.6, 0.3, 0.0, 1.0)
@export var sprite_frames_ovveride: SpriteFrames

@export var bullet_name: String
@export var description: String

enum effects {
	NONE,
	FREEZE,
	DASH,
	FIRE,
	COIN,
	RICOPIERCE,
	SHOTGUN,
	PARRY,
	SHIFT,
	SLAM,
	TP_SHOT,
	REVOLVER,
	HELIX,
	HELIX_HELPER,
	HOMING,
	BLACKHOLE,
	BACKWARDS,
	TRISHOT,
	OCTOSHOT,
	RNGSHOT,
	BURST_FIRE,
	LEVITATION,
	INSTALL
}
