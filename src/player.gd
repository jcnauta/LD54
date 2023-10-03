extends Node2D

signal update_health
signal game_over_diabetes
signal earthquake
signal spears
signal difficulty_change
signal lap_completed

var falling_back
var max_speed
var speed
var brake
var speed_recovery
var vy
var v_up
var thrust
var fall_power
var dir_factor
var max_health
var health

var recovery
var health_recover_countdown

var dashing
var dash_brake
var already_pressed

var spearing
var to_touch

var claw_dmg
var lap_was_completed

func reset():
#	if G.DEBUG:
#		max_speed = 800
#		speed = 800
#	else:
	max_speed = 400.0
	speed = 200.0  # always positive
	brake = 150.0
	speed_recovery = 200
	vy = 0.0
	v_up = -500.0
	thrust = false
	fall_power = 900.0  # always positive
	dir_factor = 1.0  # 1.0 = right, -1.0 = left

	max_health = 3
	health = 3
	recovery = 2.0
	health_recover_countdown = 1.0
	dashing = false
	dash_brake = 2000
	already_pressed = false
	spearing = false
	to_touch = "right"
	
	claw_dmg = 10
	lap_was_completed = false
	
	position = Vector2(150, 750)
	self.rotation = 0
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite != null:
		sprite.flip_h = false
	emit_signal("update_health", health, max_health)

func increase_max_health():
	max_health += 2
	emit_signal("update_health", health, max_health)
	
# Recovery is a countdown, so smaller "increases" recovery
func increase_recovery():
	recovery = 0.1 + (recovery - 0.1) * 0.85
	
func increase_claw():
	pass

func _init():
	reset()

func _ready():
	emit_signal("update_health", health, max_health)

func _process(delta):
	if lap_was_completed:
		lap_was_completed = false
		emit_signal("lap_completed")
	if not G.gameover and health < max_health:
		health_recover_countdown -= delta
		if health_recover_countdown <= 0.0:
			health_recover_countdown = recovery
			health += 1
			emit_signal("update_health", health, max_health)
	# test for x and y whether we collide with center, in that case bounce off the wall
	var old_position = position
	position += delta * Vector2(dir_factor * speed, 0)
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = $Area2D/CollisionShape2D.get_shape()
	query.set_shape(shape)
	query.set_collision_mask(256)  # wall
	query.set_collide_with_areas(true)
	query.set_exclude([$Area2D])
	query.set_transform($Area2D.global_transform)
	var hits = get_world_2d().direct_space_state.intersect_shape(query)
	if len(hits) > 0:
		for hit in hits:
			var maybe_wall = hit.collider.get_parent()
			if maybe_wall.name == "CenterWall":
				position = old_position
				dir_factor *= -1.0
				$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
	old_position = position
	position += delta * Vector2(0, vy)
	query = PhysicsShapeQueryParameters2D.new()
	shape = $Area2D/CollisionShape2D.get_shape()
	query.set_shape(shape)
	query.set_collision_mask(256)  # wall
	query.set_collide_with_areas(true)
	query.set_exclude([$Area2D])
	query.set_transform($Area2D.global_transform)
	hits = get_world_2d().direct_space_state.intersect_shape(query)
	if len(hits) > 0:
		for hit in hits:
			var maybe_wall = hit.collider.get_parent()
			if maybe_wall.name == "CenterWall":
				position = old_position
				if vy > 0:
					vy = -0.8 * vy
				else:
					vy = 0.2 * abs(vy)
	var v = Vector2(dir_factor * speed, vy)
	# Possibly turn around, and maybe cause an earthquake
	var quaking = false
	if speed > max_speed and \
			(position.x > 1300 and dir_factor == 1.0 or \
			 position.x < 100 and dir_factor == -1.0):
		$Quake.play()
		quaking = true
		emit_signal("earthquake")
	if position.x > 1300 and dir_factor == 1.0:
		$AnimatedSprite2D.flip_h = true
		dir_factor = -1.0
		if to_touch == "right":
			lap_was_completed = true
			to_touch = "left"
		if not quaking:
			$GroundJump.play()
	if position.x < 100 and dir_factor == -1.0:
		$AnimatedSprite2D.flip_h = false
		dir_factor = 1.0
		if to_touch == "left":
			to_touch = "right"
			G.difficulty += 0.05
			lap_was_completed = true
			emit_signal("difficulty_change")
		if not quaking:
			$GroundJump.play()
	var prev_vy = vy
	vy += fall_power * delta
	if vy > 0 and prev_vy < 0:
		spearing = false
	if G.weapon_levels[3]["owned"] and vy > 0 and prev_vy < 0 and thrust and not dashing:
		vy = 0
		dashing = true
		thrust = false
		speed = max_speed * (2.0 + 0.25 * G.weapon_levels[3]["upgrades"]["dash_speed"])
		$Jump.play()
	if dashing:
		speed -= dash_brake * delta
		if speed < 0.7 * max_speed:
			dashing = false
	if position.y > 800 and vy > 0:
		vy = clamp(-0.8 * abs(vy), v_up, 0.5 * v_up)
		speed = clamp(speed - brake, 0.5 * max_speed, max_speed)
		falling_back = false
		$GroundJump.play()
	if position.y < -100:
		falling_back = true
	if not dashing:
		speed = clamp(speed + speed_recovery * delta, 0, max_speed)
	rotation = atan2(dir_factor * v.y, dir_factor * v.x)

func _input(event):
	if G.gameover:
		return
	if event.is_action_pressed("action_press") and not already_pressed and not falling_back:
		already_pressed = true
		speed = clamp(speed - brake, 0.5 * max_speed, max_speed)
		if vy < v_up + 180.0:
			vy -= 180.0
		else:
			vy = v_up
		var spear_chance = 70 + 5 * G.weapon_levels[4]["upgrades"]["rate"]
		if randi() % 100 < spear_chance and G.weapon_levels[4]["owned"]:
			emit_signal("spears")
			spearing = true
			$Spear.play()
		else:
			$Jump.play()
		thrust = true
	if event.is_action_released("action_press"):
		already_pressed = false
		thrust = false

func _on_area_2d_area_entered(area):
	var collider = area.get_parent()
	if collider.name == "CenterWall":
		return
	collider.update_health(-claw_dmg)
	if health > 0:
#		if collider == G.boss:
#			health = 0
#		else:
		health -= 1
		if not G.gameover:
			$Hurt.play()
		if health == 0:
			if not G.gameover:
				$GameOver.play()
				G.gameover = true
				emit_signal("game_over_diabetes")
		emit_signal("update_health", health, max_health)

func heal(hp):
	health = min(max_health, health + hp)
	emit_signal("update_health", health, max_health)

func heal_full():
	health = max_health
	emit_signal("update_health", health, max_health)
