extends Area2D
class_name PlayerBullet

var delta_time_save: float

var direction: Vector2
var vel: Vector2
var resource: BulletResource
var player: Player

var damage: int

var effect_methods = {
	BulletResource.effects.FREEZE: Callable(freeze),
	BulletResource.effects.DASH: Callable(dash),
	BulletResource.effects.FIRE: Callable(fire),
	BulletResource.effects.COIN: Callable(coin_gravity)
}

var thing_i_hit: EnemyComponent

func _ready():
	damage = resource.damage
	vel = direction * resource.speed
	if resource.effect_on_shot:
		effect_methods[resource.effect].call()

func _process(delta):
	delta_time_save = delta
	if direction:
		position += vel * delta
	if resource.called_in_process:
		effect_methods[resource.effect].call()

func _on_body_entered(body: Object):
	var enemy_component: EnemyComponent = body.find_child("EnemyComponent")
	if not enemy_component:
		call_deferred("queue_free")
		return
	enemy_component.hit(damage)
	thing_i_hit = enemy_component
	if not resource.effect_on_shot and resource.effect in effect_methods:
		effect_methods[resource.effect].call()
	call_deferred("queue_free")

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# effect methods

func freeze():
	thing_i_hit.freeze(resource.effect_strength)

func dash():
	player.dash(direction, resource.effect_strength)

func fire():
	thing_i_hit.burn(resource.effect_strength)

func coin_gravity():
	vel /= (1 + delta_time_save)
	vel.y += 100 * delta_time_save

# entered another bullet
func _on_area_entered(area: PlayerBullet):
	if area.resource.effect == BulletResource.effects.COIN:
		damage *= area.resource.effect_strength
		var closest_enemy = GameState.get_closest_enemy_to_position(global_position)
		if not closest_enemy:
			return
		direction = global_position.direction_to(closest_enemy.global_position)
		vel = resource.speed * direction * area.resource.effect_strength
