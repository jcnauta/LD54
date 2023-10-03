extends AnimatedSprite2D

var player

var shocked_countdowns = {}
var heal_accumulated = 0.0
var dmg = 1.0

func _ready():
	position.x = 700
	$Stampede.play()

func _process(delta):
	heal_accumulated += delta * 0.5 * (3.0 + G.weapon_levels[2]["upgrades"]["healing"])
	if heal_accumulated >= 1.0:
		player.heal(1)
		heal_accumulated = 0.0
	position.y = player.position.y
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = $Area2D/CollisionShape2D.get_shape()
	query.set_shape(shape)
	query.set_collision_mask(2)  # enemies
	query.set_collide_with_areas(true)
	query.set_exclude([$Area2D])
	query.set_transform($Area2D.global_transform)
	var hits = get_world_2d().direct_space_state.intersect_shape(query)
	if len(hits) > 0:
		for hit in hits:
			var enemy = hit.collider.get_parent()
			if enemy not in shocked_countdowns.keys() or shocked_countdowns[enemy] <= 0:
				shocked_countdowns[enemy] = 0.1 - 0.018 * G.weapon_levels[2]["upgrades"]["dmg"]
				var actual_dmg = dmg + floor(randf() * G.weapon_levels[2]["upgrades"]["dmg"])
				enemy.update_health(-actual_dmg)
	for key in shocked_countdowns.keys():
		shocked_countdowns[key] = max(0, shocked_countdowns[key] - delta)

func _on_animation_finished():
	queue_free()
