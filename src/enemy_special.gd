extends "res://src/enemy.gd"

func _init():
	super._init()
	max_health = 12 * G.total_upgrades * (0.8 + 0.2 * randf())
	health = max_health
