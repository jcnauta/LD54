extends Node2D

signal enemy_death

enum STRAT {
	PATROL,
	FOLLOW,
	FINDHOME,
}

var speed = 100
var followspeed = 100
var findhomespeed = 200
var health
var max_health
var flash_health_counter = 0.0
var center = Vector2(700, 450)
var center_margin_idx
var center_margin
var center_margins = [50, 150, 250, 325, 400]
var center_margin_countdown = 10.0
var strategy = STRAT.PATROL
var strategy_countdown = 20.0
var home = null
var patrol_points = []
var patrol_idx = 0

@onready var player = $/root/Game.get_node(^"%Player")

func _init():
	speed = 90 + randi() % 20
#	max_health = 10 * (1.0 + 19.0 * G.difficulty * (0.7 + 0.3 * randf()))  # 10-200
	if G.boss_mode:
		max_health = 100 * (0.8 + 0.2 * randf())
	else:
		max_health = 5 * G.total_upgrades * (0.8 + 0.2 * randf())
	health = max_health
	var min_margin = 10
	center_margin_idx = randi() % len(center_margins)
	center_margin = center_margins[center_margin_idx]
	set_patrol_points()

func set_patrol_points():
	var horz = false
	var p0
	var p1
	if randi() % 2 == 0:
		horz = true
	horz = true
	if horz:
		# default left
		p0 = Vector2(100, 100 + randi() % 700)
		if randi() % 2: # change to right
			p0.x = 1300
		p1 = p0
		p1.x = 100 + randi() % 1200
#	else:  #vertical
	patrol_points = [p0, p1]

func switch_patrol_direction():
	if 100 > position.x or position.x > 1300 or 100 > position.y or position.y > 800:
		return
	var p0 = position
	var p1 = p0
	if patrol_points[0].y == patrol_points[1].y:
		# go vertical now, pick an edge
		if p0.y > 450:
			p1.y = 100
		else:
			p1.y = 800
	else:  # go horizontal now
		if p0.x > 700:
			p1.x = 100
		else:
			p1.x = 1300
	patrol_points = [p0, p1]

func consider_strategy(delta):
	strategy_countdown -= delta
	if strategy_countdown <= 0:
		strategy_countdown = 10.0
		var roll = randi() % 3
		if roll == 0:
			strategy = STRAT.FOLLOW
			speed = followspeed
		elif roll == 1:
			strategy = STRAT.FINDHOME
			speed = findhomespeed
			home = player.position
		else:
			strategy = STRAT.PATROL
			speed = followspeed

func consider_margin(delta):
	center_margin_countdown -= delta
	if center_margin_countdown <= 0.0:
		center_margin_idx = randi() % len(center_margins)
		center_margin = center_margins[center_margin_idx]
		center_margin_countdown = 10.0

func animate_flash(delta):
	if flash_health_counter > 0.0:
		flash_health_counter = max(0.0, flash_health_counter - delta)
		if flash_health_counter == 0.0:
			$AnimatedSprite2D.material.set_shader_parameter("tint", Vector3(0.2, 0.2, 0.2))
			$AnimatedSprite2D.material.set_shader_parameter("saturation", 1.0 - float(health) / float(max_health))

func move_old(delta):
	var from_center = position - center
	var dir
	if from_center.length() < center_margin:
		dir = from_center.normalized()
	else:
		if strategy == "follow":
			var playerpos = player.position
			dir = (playerpos - position).normalized()
		elif strategy == "findhome":
			dir = (home - position).normalized()
	position += speed * dir * delta

func move(delta):
	var to_patrol = patrol_points[patrol_idx] - position
	if to_patrol.length() < 10.0:
		patrol_idx = (patrol_idx + 1) % 2
		to_patrol = patrol_points[patrol_idx] - position
	var dir = to_patrol.normalized()
	position += speed * dir * delta

func _process(delta):
#	consider_strategy(delta)
#	consider_margin(delta)
	animate_flash(delta)
	move(delta)

func update_health(d_health):
	health += d_health
	if d_health <= 0:
		$AnimatedSprite2D.material.set_shader_parameter("tint", Vector3(1, 1, 1))
		$AnimatedSprite2D.material.set_shader_parameter("saturation", 1)
		flash_health_counter = 0.1
	if health <= 0:
		emit_signal("enemy_death", self)
