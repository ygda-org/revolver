extends Area2D
class_name PlayerBullet

var delta_time_save: float

var direction: Vector2
var vel: Vector2
var resource: BulletResource
var player: Player

var damage: int

var pierces: int = 1

var effect_methods = {
	BulletResource.effects.FREEZE: Callable(freeze),
	BulletResource.effects.DASH: Callable(dash),
	BulletResource.effects.FIRE: Callable(fire),
	BulletResource.effects.COIN: Callable(coin_gravity),
	BulletResource.effects.RICOPIERCE: Callable(ricopierce_setup),
	BulletResource.effects.SHOTGUN: Callable(shotgun_setup)
}

var thing_i_hit: EnemyComponent

func _ready():
	$Anim.material.set_shader_parameter("outline_color", resource.outline_color)
	$Light.texture.gradient.set_color(0, Color(resource.outline_color.r, resource.outline_color.g, resource.outline_color.b, 0.3))
	$Light.texture.gradient.set_color(1, Color(resource.outline_color.r, resource.outline_color.g, resource.outline_color.b, 0.0))
	if resource.sprite_frames_ovveride:
		$Anim.material = null
		$Anim.sprite_frames = resource.sprite_frames_ovveride
		$Anim.play("default")
	damage = resource.damage
	vel = direction * resource.speed
	if resource.effect_on_shot:
		effect_methods[resource.effect].call()
	$LifeTime.wait_time = resource.life_duration
	$LifeTime.start()

func _process(delta):
	delta_time_save = delta
	if direction:
		position += vel * delta
	if resource.called_in_process:
		effect_methods[resource.effect].call()

func _on_body_entered(body: Object):
	pierces -= 1
	var enemy_component: EnemyComponent = body.find_child("EnemyComponent")
	if not enemy_component:
		if pierces <= 0:
			call_deferred("queue_free")
			return
		# ricochet
		var maxis: int = global_position.direction_to(body.global_position).max_axis_index()
		direction = direction.bounce([Vector2(1,0), Vector2(0,1)][maxis])
		vel = direction * resource.speed
		return
	enemy_component.hit(damage)
	thing_i_hit = enemy_component
	if not resource.effect_on_shot and resource.effect in effect_methods:
		effect_methods[resource.effect].call()
	if pierces <= 0:
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
		vel = 1.5*resource.speed * direction * area.resource.effect_strength
		area.vel = 300 * Vector2(1, 0).rotated(randf_range(PI/3, 2*PI/3))

func ricopierce_setup():
	pierces = int(resource.effect_strength)


func _on_life_time_timeout():
	#var tween = get_tree().create_tween()
	#tween.tween_property()
	queue_free()

func shotgun_setup():
	self_modulate = Color(1.0, 1.0, 1.0, 0.0)
	for i in range(5):
		var bullet = load("uid://k308fsvc3jvh").instantiate()
		bullet.resource = load("uid://cllwws72eb4kk")
		bullet.direction = direction.rotated((i-2)*PI/9)
		bullet.player = player
		add_child(bullet)
		bullet.vel *= 3
