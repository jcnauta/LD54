extends Node

var Turd = preload("res://src/weapons/weapon_2_turd.tscn") 

func fire(player, missiles, enemies):
	if G.weapon_levels[1]["owned"]:
		var promille = 10 + 5 * G.weapon_levels[1]["upgrades"]["rate"]
		if randi() % 1000 < promille:
			var new_turd = Turd.instantiate()
			new_turd.dmg = 20 * G.weapon_levels[1]["upgrades"]["dmg"]
			new_turd.speed = 50 + 25 * G.weapon_levels[1]["upgrades"]["range"]
			new_turd.lock_range = 100 + 40 * G.weapon_levels[1]["upgrades"]["range"]
			new_turd.enemies = enemies
			new_turd.position = player.position
			new_turd.flip_h = player.get_node("AnimatedSprite2D").flip_h
			missiles.add_child(new_turd)
