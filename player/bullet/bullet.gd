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
	BulletResource.effects.SHOTGUN: Callable(shotgun_setup),
	BulletResource.effects.SHIFT: Callable(shift),
	BulletResource.effects.SLAM: Callable(slam),
	BulletResource.effects.TP_SHOT: Callable(tp_shot),
	BulletResource.effects.REVOLVER: Callable(revolver),
	BulletResource.effects.HELIX: Callable(helix),
	BulletResource.effects.HELIX_HELPER: Callable(helix_helper),
	BulletResource.effects.HOMING: Callable(homing),
	BulletResource.effects.BLACKHOLE: Callable(blackhole),
	BulletResource.effects.BACKWARDS: Callable(backwards),
	BulletResource.effects.TRISHOT: Callable(tri_shot_setup),
	BulletResource.effects.OCTOSHOT: Callable(octo_shot_setup),
	BulletResource.effects.RNGSHOT: Callable(rng_shot_setup),
	BulletResource.effects.BURST_FIRE: Callable(burst_fire_setup),
	BulletResource.effects.LEVITATION: Callable(levitate),
	BulletResource.effects.INSTALL: Callable(install)
}

var thing_i_hit: EnemyComponent

func _ready():
	if resource.override_shot_sfx != BulletResource.OverrideSettings.NONE:
		Sfx.play(resource.shot_sfx_override)
	if resource.override_shot_sfx != BulletResource.OverrideSettings.OVERRIDE:
		Sfx.play(Sfx.Labels.GUN_PLACEHOLDER)
	if resource.effect == BulletResource.effects.PARRY:
		queue_free()
	if resource.invisible_and_no_collision:
		self_modulate = Color(1.0, 1.0, 1.0, 0.0)
	$Trail.default_color = resource.outline_color
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
	if resource.invisible_and_no_collision:
		return
	pierces -= 1
	var enemy_component: EnemyComponent = body.find_child("EnemyComponent")
	if not enemy_component:
		var particles = load("uid://coy8q1pbe5txe").instantiate()
		particles.direction = -vel.normalized()
		#particles.color = resource.outline_color
		particles.global_position = global_position
		get_parent().add_child(particles)
		if resource.can_call_on_walls and not resource.effect_on_shot and resource.effect in effect_methods:
			effect_methods[resource.effect].call()
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
func _on_area_entered(area):
	if area is PlayerBullet:
		if area.resource.effect == BulletResource.effects.COIN:
			damage *= area.resource.effect_strength
			var closest_enemy = GameState.get_closest_enemy_to_position(global_position)
			if not closest_enemy:
				return
			direction = global_position.direction_to(closest_enemy.global_position)
			vel = 1.5*resource.speed * direction * area.resource.effect_strength
			area.vel = 300 * Vector2(1, 0).rotated(randf_range(PI/3, 2*PI/3))
	else:
		var particles = load("uid://coy8q1pbe5txe").instantiate()
		particles.direction = -vel.normalized()
		particles.color = Color(0.185, 0.603, 0.794, 1.0)
		particles.global_position = global_position
		get_parent().add_child(particles)
		call_deferred("queue_free")

func ricopierce_setup():
	pierces = int(resource.effect_strength)


func _on_life_time_timeout():
	#var tween = get_tree().create_tween()
	#tween.tween_property()
	queue_free()

func shotgun_setup():
	for i in range(5):
		var bullet = load("uid://k308fsvc3jvh").instantiate()
		bullet.resource = load("uid://cllwws72eb4kk")
		bullet.direction = direction.rotated((i-2)*PI/9)
		bullet.player = player
		add_child(bullet)
		bullet.vel *= 3

func shift():
	player.shift(direction, resource.effect_strength)
	queue_free()

func slam():
	player.slam()
	queue_free()

func tp_shot():
	player.global_position = global_position

func revolver():
	GameState.player.next_bullet_twice = true
	queue_free()

func helix():
	var top = load("uid://k308fsvc3jvh").instantiate()
	var bot = load("uid://k308fsvc3jvh").instantiate()
	top.resource = load("uid://dkowsl3jc0v57")
	bot.resource = load("uid://dkowsl3jc0v57")
	$Pivot.add_child(top)
	$Pivot.add_child(bot)
	top.position.y = -7
	bot.position.y = 7

func helix_helper():
	get_parent().rotation += 4*PI*delta_time_save
	var rot_pos: Vector2 = global_position - get_parent().global_position
	get_parent().rotation = 0
	position = rot_pos

func homing():
	var enemy: EnemyComponent = GameState.get_closest_enemy_to_position(global_position)
	if not enemy:
		return
	var target_pos: Vector2 = enemy.global_position
	var perp: Vector2 = vel.orthogonal().normalized()
	perp = perp if (global_position + perp).distance_to(target_pos) < (global_position - perp).distance_to(target_pos) else -perp
	vel += perp * resource.effect_strength * delta_time_save

func blackhole():
	var enemy: EnemyComponent = GameState.get_closest_enemy_to_position(global_position)
	if not enemy:
		return
	var dir = enemy.get_parent().global_position.direction_to(global_position)
	enemy.get_parent().position += dir * resource.effect_strength * delta_time_save

func backwards():
	direction *= -1
	vel *= -1

func tri_shot_setup():
	var bullet1 = load("uid://k308fsvc3jvh").instantiate()
	bullet1.resource = load("uid://cllwws72eb4kk")
	bullet1.direction = direction.rotated(PI/6)
	get_parent().add_child(bullet1)
	bullet1.global_position = global_position
	var bullet2 = load("uid://k308fsvc3jvh").instantiate()
	bullet2.resource = load("uid://cllwws72eb4kk")
	bullet2.direction = direction.rotated(-PI/6)
	get_parent().add_child(bullet2)
	bullet2.global_position = global_position

func octo_shot_setup():
	for i in range(1,8):
		var bullet1 = load("uid://k308fsvc3jvh").instantiate()
		bullet1.resource = load("uid://cllwws72eb4kk")
		bullet1.direction = direction.rotated(i*PI/4)
		get_parent().add_child(bullet1)
		bullet1.global_position = global_position

func rng_shot_setup():
	direction = Vector2(1,0).rotated(randf_range(0, 2*PI))
	vel = direction * resource.speed

func burst_fire_setup():
	for i in range(int(resource.effect_strength)):
		var bullet = load("uid://k308fsvc3jvh").instantiate()
		bullet.resource = load("uid://dj3urqcujfedn")
		bullet.direction = global_position.direction_to(get_global_mouse_position())
		GameState.camera.add_trauma(bullet.resource.shake_trauma)
		add_child(bullet)
		await get_tree().create_timer(0.07).timeout

func levitate():
	player.velocity.y -= resource.effect_strength * delta_time_save

func install():
	visible = false
	dash()
	await player.dash_ended
	var new_resource: BulletResource = GameState.get_bullet()
	GameState.camera.add_trauma(new_resource.shake_trauma)
	var shot_dir: Vector2 = global_position.direction_to(get_global_mouse_position())
	if new_resource.effect == BulletResource.effects.REVOLVER:
		var next_resource: BulletResource = GameState.get_bullet()
		GameState.camera.add_trauma(next_resource.shake_trauma)
		for i in range(4):
			var bullet = load("uid://k308fsvc3jvh").instantiate()
			bullet.resource = next_resource
			bullet.direction = shot_dir
			bullet.global_position = player.shot_position.global_position
			bullet.player = player
			get_parent().add_child(bullet)
			bullet.damage *= resource.damage
			if next_resource.recoil:
				player.velocity.y /= 3
				player.velocity += new_resource.recoil * -shot_dir * resource.damage
				player.get_node("$RecoilLock").start()
			await get_tree().create_timer(0.1).timeout
		queue_free()
	var bullet = load("uid://k308fsvc3jvh").instantiate()
	bullet.resource = new_resource
	bullet.direction = shot_dir
	bullet.global_position = player.shot_position.global_position
	bullet.player = player
	get_parent().add_child(bullet)
	bullet.damage *= resource.damage
	if player.next_bullet_twice:
		player.next_bullet_twice = false
		var bullet2 = bullet.duplicate()
		bullet2.resource = new_resource
		bullet2.direction = shot_dir
		bullet2.global_position = player.shot_position.global_position
		bullet2.player = player
		get_tree().create_timer(0.1).timeout.connect(get_parent().add_child.bind(bullet2))
		if new_resource.recoil:
			player.velocity.y /= 3
			player.velocity += new_resource.recoil * -shot_dir
	if new_resource.recoil:
		player.velocity.y /= 3
		player.velocity += new_resource.recoil * -shot_dir * resource.damage
		player.get_node("$RecoilLock").start()
	queue_free()
