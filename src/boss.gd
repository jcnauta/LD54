extends "res://src/enemy.gd"

signal boss_health_change

func _init():
	max_health = 1500
	health = max_health
	patrol_points = [Vector2(700, 100), Vector2(700, 800)]
	position = Vector2(700, -200)

func _process(delta):
	super._process(delta)

func switch_patrol_direction():
	pass

func update_health(d_health):
	health = max(0, health + d_health)
	if d_health <= 0:
		$AnimatedSprite2D.material.set_shader_parameter("tint", Vector3(1, 1, 1))
		$AnimatedSprite2D.material.set_shader_parameter("saturation", 1)
		flash_health_counter = 0.05
	emit_signal("boss_health_change")

func move(delta):
	if not G.gameover:
		super.move(delta)
