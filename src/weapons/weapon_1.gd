extends Node

var Shock = preload("res://src/weapons/weapon_1_shock.tscn")

var countdown = 0.0

func fire(player, missiles, delta):
	if not G.weapon_levels[2]["owned"]:
		return
	countdown -= delta
	if countdown <= 0:
		var shock = Shock.instantiate()
		shock.player = player
		shock.flip_h = player.get_node("AnimatedSprite2D").flip_h
		shock.position.y = player.position.y
		missiles.add_child(shock)
		countdown = 3.0 - G.weapon_levels[2]["upgrades"]["rate"] * 0.4 + randf() * 2.0
