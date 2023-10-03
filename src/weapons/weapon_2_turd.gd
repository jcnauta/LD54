extends Sprite2D

var a = 100
var speed = 100
var lock_range = 250
var countdown = 6.0
var detonate_range = 36
var blast_radius = 72
var v = Vector2(0, 0)
var enemies
var target = null
var detonated = false
var dmg

func _process(delta):
	if not detonated:
		countdown -= delta
		if countdown < 0:
			detonate()
		else:
			if target == null:
				var near_dist = INF
				for enemy in enemies.get_children():
					var dist = position.distance_to(enemy.position)
					if dist < lock_range and dist < near_dist:
						target = enemy
						near_dist = dist
			if target != null:
				if self.position.distance_to(target.position) < detonate_range:
					detonate()
				v = Vector2(speed, 0).rotated(self.position.angle_to_point(target.position))
			position += v * delta

func detonate():
	detonated = true
	$explosion.show()
	$explosion.play("first")
	$boom.play()
	self_modulate = Color(1, 1, 1, 0.5)

func _on_explosion_animation_finished():
	var animation = $explosion.animation
	if animation == "first":
		for enemy in enemies.get_children():
			if position.distance_to(enemy.position) < blast_radius:
				enemy.update_health(-dmg)
		$explosion.play("second")
	elif animation == "second":
		queue_free()
