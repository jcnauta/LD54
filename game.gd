extends Node

# Collision layers:
# 1 = Player
# 2 = Enemies
# 3 = Missiles
# 4 = Shock

# 9 = Walls

@onready var player = $"%Player"
@onready var shadow = $"%PlayerShadow"
@onready var enemies = $"%Enemies"
@onready var enemies_special = $"%EnemiesSpecial"
@onready var missiles = $"%Missiles"
@onready var pickups = $"%Pickups"
@onready var menu = $Menu
@onready var starbar = $"Sidebar/%Starbar"
@onready var candybar = $"Sidebar/%Candybar"
@onready var upgradebar = $"Sidebar/%Upgrades"

var Enemy = preload("res://src/enemy.tscn")
var EnemySpecial = preload("res://src/enemy_special.tscn")
var Boss = preload("res://src/boss.tscn")
var Boulder = preload("res://src/weapons/boulder.tscn")
var Spear = preload("res://src/weapons/spear.tscn")
var Star = preload("res://src/star.tscn")
var Weapon0 = preload("res://src/weapons/weapon_0.gd")
var Weapon1 = preload("res://src/weapons/weapon_1.gd")
var Weapon2 = preload("res://src/weapons/weapon_2.gd")


var spawn_counter
var spawn_pause
var wave_counter
var wave
var boss

var weapon0 = Weapon0.new()
var weapon1 = Weapon1.new()
var weapon2 = Weapon2.new()

func _init():
	reset_variables()

func _ready():
	var healthbar = $"Sidebar/%Healthbar"
	var play_again_btn = $Menu/%PlayAgainBtn
	player.connect("update_health", healthbar.update_bar)
	player.emit_signal("update_health", player.health, player.max_health)
	player.connect("game_over_diabetes", menu.game_over_diabetes)
	player.connect("earthquake", earthquake)
	player.connect("spears", spears)
	player.connect("difficulty_change", candybar.update_bar)
	player.connect("lap_completed", lap_completed)
	menu.connect("play_again", play_again)
	menu.connect("upgrade_picked", upgrade_picked)
	menu.connect("increase_max_health", player.increase_max_health)
	menu.connect("increase_recovery", player.increase_recovery)
	play_again_btn.connect("pressed", play_again)
	update_shadow()
	if G.boss_mode:
		G.boss = Boss.instantiate()
		G.boss.connect("boss_health_change", boss_health_change)
		enemies.add_child(G.boss)
		candybar.update_bar()
	if G.DEBUG:
		G.enable_debug()
		menu.hide()
		upgradebar.update_upgrades()
	else:
		menu.shop()

func reset_variables():
	G.reset()
	spawn_counter = 0.3
	spawn_pause = false
	wave_counter = 0.0
	wave = false


func _process(delta):
#	if len(enemies.get_children()) > 15 + G.difficulty * 40:
#		# avoid overwhelming the player, pause spawning
#		spawn_pause = true
#	elif len(enemies.get_children()) < 10:
#		spawn_pause = false
#	if not G.gameover and G.boss_mode and G.boss == null:
#		G.boss = Boss.instantiate()
#		G.boss.connect("boss_health_change", boss_health_change)
#		enemies.add_child(G.boss)
#		candybar.update_bar()

	if not G.gameover and not spawn_pause:
		wave_counter -= delta
		if wave_counter <= 0.0:
			if wave:
				wave_counter = 16.0
			else:
				wave_counter = 4.0
		spawn_counter -= delta
		if spawn_counter <= 0.0:
			var new_enemy
			if len(get_tree().get_nodes_in_group("specials")) < G.max_specials and randi() % 3 == 0:
				new_enemy = EnemySpecial.instantiate()
				new_enemy.add_to_group("specials")
			else:
				new_enemy = Enemy.instantiate()
			new_enemy.connect("enemy_death", kill_enemy)
			var player_x = player.position.x
			if randi() % 2 == 0:
				# top or bottom
				var min_x = player_x + 250
				var max_x = 1300
				if player_x > 700:
					min_x = 100
					max_x = player_x - 250
				new_enemy.position.x = min_x + randf() * (max_x - min_x)
#				if randi() % 2 == 0:
#					new_enemy.position.y = 1000
#				else:
				new_enemy.position.y = -100
			else:
				if player_x > 700:
					new_enemy.position.x = -100
				else:
					new_enemy.position.x = 1500
				new_enemy.position.y = 100 + randf() * 700
			enemies.add_child(new_enemy)
			spawn_counter = 0.8 - 0.3 * G.difficulty
			if wave:
				spawn_counter -= 0.2
		
	weapon0.fire(player, missiles)
	weapon1.fire(player, missiles, delta)
	weapon2.fire(player, missiles, enemies)

	update_shadow()

func update_shadow():
	shadow.position.x = player.position.x
	shadow.scale = 0.5 * (1.0 - ((shadow.position.y - player.position.y) / 1800)) * Vector2(1, 1)
	shadow.self_modulate.a = shadow.scale.x

func play_again():
	reset_variables()
	upgradebar.reset()
	menu.reset()
	player.reset()
	update_shadow()
	for enemy in enemies.get_children():
		enemy.queue_free()
	for enemy in enemies_special.get_children():
		enemy.queue_free()
	for missile in missiles.get_children():
		missile.queue_free()
	for pickup in pickups.get_children():
		pickup.queue_free()
	menu.shop()


func create_boulder():
	var new_boulder = Boulder.instantiate()
	new_boulder.position.y = randi() % 400
	return new_boulder
	
func earthquake():
	var left_boulders = 2 + floor(randf() * (1.0 + 1.0 * G.weapon_levels[3]["upgrades"]["boulders"]))
	var right_boulders = 2 + floor(randf() * (1.0 + 1.0 * G.weapon_levels[3]["upgrades"]["boulders"]))
	var boulder_dmg = 8.0 + 8.0 * G.weapon_levels[3]["upgrades"]["dmg"]
	for _idx in range(left_boulders):
		var new_boulder = create_boulder()
		new_boulder.dmg = boulder_dmg
		new_boulder.position.x = -72
		var angle = -0.25 * PI * randf()
		new_boulder.set_dir(Vector2(1, 0).rotated(angle))
		missiles.add_child(new_boulder)
	for _idx in range(right_boulders):
		var new_boulder = create_boulder()
		new_boulder.position.x = 1472
		new_boulder.dmg = boulder_dmg
		var angle = PI + 0.25 * PI * randf()
		new_boulder.set_dir(Vector2(1, 0).rotated(angle))
		missiles.add_child(new_boulder)

	
func spears():
	var num = 3 + floor(randf() * 2.0 * G.weapon_levels[4]["upgrades"]["spears"])
	var total_angle = min(0.5 * PI, (num - 1) * 0.05 * PI)
	var delta_angle = 0.0
	if num > 1:
		delta_angle = total_angle / (num - 1)
	var current_angle = player.rotation - 0.5 * total_angle
	for _idx in range(num):
		var new_spear = Spear.instantiate()
		new_spear.dmg = 5.0 + 10.0 * G.weapon_levels[4]["upgrades"]["dmg"]
		new_spear.position = player.position
		new_spear.rotation = current_angle
		current_angle += delta_angle
		new_spear.flip_h = player.get_node("AnimatedSprite2D").flip_h
		new_spear.dir_factor = player.dir_factor
		missiles.add_child(new_spear)

func kill_enemy(enemy):
	var star = Star.instantiate()
	star.connect("star_pickup", pickup_star)
	star.position = enemy.position
	$%Pickups.add_child(star)
	if enemy.is_in_group("specials"):
		G.lvl_progress += 1
		candybar.update_bar()
		if G.lvl_progress == G.lvl_progress_max:
			G.boss_mode = true
			G.boss = Boss.instantiate()
			G.boss.connect("boss_health_change", boss_health_change)
			enemies.add_child(G.boss)
			candybar.update_bar()
	enemy.queue_free()

func pickup_star():
	if G.gameover:
		return
	add_stars(1)

func upgrade_picked():
	starbar.update_stars()
	upgradebar.update_upgrades()

func lap_completed():
#	if randi() % 2 == 0:
		for enemy in enemies.get_children():
			enemy.switch_patrol_direction()
		for enemy in enemies_special.get_children():
			enemy.switch_patrol_direction()
	
func add_stars(n):
	G.stars += n
	starbar.update_stars()
	if G.stars >= G.stars_nextlevel:
		G.stars -= G.stars_nextlevel
		player.heal_full()
		menu.shop()
		$Powerup.play()
	else:
		$Star.play()

func boss_health_change():
	candybar.update_bar()
	if not G.gameover and G.boss.health <= 0:
		G.gameover = true
		menu.win()
		$Win.play()
