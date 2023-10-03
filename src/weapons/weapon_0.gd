extends Node

var missile = preload("res://src/weapons/weapon_0_missile.tscn")

func fire(player, missiles):
	if not G.weapon_levels[0]["owned"]:
		return
	var lvl = G.weapon_levels[0]["upgrades"]["rate"]
	var chance = 4 + (lvl - 1) * 3
	var roll = randi() % 100
	if roll < chance:
		var new_missile = missile.instantiate()
		new_missile.countdown = 0.3 + G.weapon_levels[0]["upgrades"]["range"] * 0.1
		new_missile.dmg = 10 + 10 * G.weapon_levels[0]["upgrades"]["dmg"]
		new_missile.position = player.position
		new_missile.rotation = player.rotation
		new_missile.flip_h = player.get_node("AnimatedSprite2D").flip_h
		new_missile.dir_factor = player.dir_factor
		missiles.add_child(new_missile)
