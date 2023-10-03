extends Panel


signal play_again
signal upgrade_picked
signal increase_max_health
signal increase_recovery

@onready var sel1 = $"%selector1"
@onready var sel2 = $"%selector2"

var picks

var weapon_textures = [
	preload("res://sprites/ui/weapons/fire.png"),
	preload("res://sprites/ui/weapons/turd.png"),
	preload("res://sprites/ui/weapons/gnu.png"),
	preload("res://sprites/ui/weapons/boulder.png"),
	preload("res://sprites/ui/weapons/spear.png"),
	preload("res://sprites/ui/weapons/heartmore.png"), # more health
	preload("res://sprites/ui/weapons/heartfast.png")  # faster recovery
	# sharper claws
]

var weapon_texts = [
	"FIERY BREATH: Spew fireballs in the direction you are facing.",
	"FECAL BOMBS: Leave behind a trail of fecal bombs that home in on candy.",
	"SPIRIT STAMPEDE: Ghostly gnus trample candy in a horizontal line at your level.",
	"AVALANCHE DASH: Hold jump until horizontal, then dash into the wall.",
	"JUNGLE SPEARS: Jump may launch a volley of spears.",
	"ENDURANCE: Increase maximum health by 2.",
	"RECOVERY: Recover 15% faster."
]

var upgrade_texts = [
	{  # fireball
		"rate": "FIRING RATE increase for FIERY BREATH",
		"range": "RANGE increase for FIERY BREATH",
		"dmg": "DAMAGE increase for FIERY BREATH"
	},
	{  # turd
		"rate": "DROP RATE increase for FECAL BOMBS",
		"range": "RANGE increase for FECAL BOMB (lock-on + speed)",
		"dmg": "DAMAGE increase for FECAL BOMB"
	},
	{  # stampede
		"rate": "FREQUENCY increase for SPIRIT STAMPEDE",
		"healing": "HEALING by SPIRIT STAMPEDE (+1/sec)",
		"dmg": "DAMAGE increase for SPIRIT STAMPEDE"
	},
	{  # quake
		"dash_speed": "SPEED increase for AVALANCHE DASH",
		"boulders": "NUMBER of AVALANCHE DASH boulders",
		"dmg": "DAMAGE from AVALANCHE DASH boulders"
	},
	{  # spear
		"spears": "NUMBER of JUNGLE SPEARS",
		"dmg": "DAMAGE increase for JUNGLE SPEARS",
		"rate": "CHANCE increase for throwing JUNGLE SPEARS",  # chance on every jump
	}
]

func reset():
	sel1.show()
	sel2.hide()

func game_over_diabetes():
	var game_end = $"%GameEnd"
	game_end.get_node("Title").text = "[center]Game over![/center]"
	game_end.get_node("Paragraph").text = "[center]You ate too much candy and contracted diabetes.[center]"
	game_end.show()
	$"%Shop".hide()
	self.show()

func shop():
	$"%GameEnd".hide()
	$"%Shop".show()
	$"%selector2".hide()
	$"%selector1".show()
	picks = gen_picks()
	$"%sprite1".texture = weapon_textures[picks[0][0]]
	$"%sprite2".texture = weapon_textures[picks[1][0]]
	if picks[0][0] > 4 or picks[0][1] == "owned":
		$"%text1".text = weapon_texts[picks[0][0]]
	else:
		$"%text1".text = upgrade_texts[picks[0][0]][picks[0][1]]
	if picks[1][0] > 4 or picks[1][1] == "owned":
		$"%text2".text = weapon_texts[picks[1][0]]
	else:
		$"%text2".text = upgrade_texts[picks[1][0]][picks[1][1]]
	self.show()
	get_tree().paused = true

func win():
	var game_end = $"%GameEnd"
	game_end.get_node("Title").text = "[center]Congratulations![/center]"
	game_end.get_node("Paragraph").text = "[center]You moderated your sugar consumption, defeated the candy boss and lived healthily ever after.[/center]"
	$"%Shop".hide()
	game_end.show()
	show()

func sample(input_list, n):
	var list = input_list.duplicate()
	var result = []
	for i in range(n):
		var elem = list[randi() % len(list)]
		result.append(elem)
		list.erase(elem)
	return result

func gen_picks():
	var weapons = G.weapon_levels
	var have_idxs = []
	var havent_idxs = []
	for idx in len(weapons):
		if weapons[idx]["owned"]:
			have_idxs.append(idx)
		else:
			havent_idxs.append(idx)
	var result = []
	if len(have_idxs) == 0:  # first pick, from two weapons
		var new_idxs = sample(havent_idxs, 2)
		return [
			[new_idxs[0], "owned"],
			[new_idxs[1], "owned"],
		]
	elif len(have_idxs) <= 2 and randi() % 100 < 20 * (1 + G.total_upgrades - 6 * (len(have_idxs) - 1)): # may choose a new weapon
		var new_idx = sample(havent_idxs, 1)[0]
		result.append([new_idx, "owned"])
	# Pick random valid upgrades and pad the rest with maxhealth/healthrecovery/claws
	# offer upgrades from owned weapons that are not maxed
	var upgradables = {}
	for idx in have_idxs:
		var upgrade_dict = weapons[idx]["upgrades"]
		for key in upgrade_dict:
			if upgrade_dict[key] < 5:
				if idx not in upgradables:
					upgradables[idx] = []
				upgradables[idx].append(key)
	# 50% chance of including non-weapon thing
	var to_upgrade = min(1 + randi() % 2, len(upgradables))
	var upgrade_weapon_idxs = sample(upgradables.keys(), to_upgrade)
	for weapon_idx in upgrade_weapon_idxs:
		result.append([weapon_idx, sample(upgradables[weapon_idx], 1)[0]])
	for perk_idx in sample([5, 6], 2 - len(result)):
		result.append([perk_idx, "health weapon is upgrade"])
	return result


func _on_play_again_btn_pressed():
	self.hide()

func _input(event):
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		if sel1.visible:
			sel2.show()
			sel1.hide()
		else:
			sel1.show()
			sel2.hide()
	if event.is_action_pressed("ui_accept"):
		if $"%GameEnd".visible:
			emit_signal("play_again")
		elif $"%Shop".visible:
			if sel1.visible:
				add_upgrade(picks[0])
			else:
				add_upgrade(picks[1])
			G.stars_nextlevel = floor(G.stars_nextlevel * 1.1) + 2
			hide()
			get_tree().paused = false
			emit_signal("upgrade_picked")
	if event.is_action_pressed("pause") and not self.visible:
		get_tree().paused = not get_tree().paused
	if event.is_action_pressed("restart"):
		emit_signal("play_again")

func add_upgrade(pick):
	G.total_upgrades += 1
	var idx = pick[0]
	var upgrade_name = pick[1]
	if idx == 5:
		emit_signal("increase_max_health")
	elif idx == 6:
		emit_signal("increase_recovery")
	elif upgrade_name == "owned":
		G.weapon_levels[idx]["owned"] = true
	else:
		G.weapon_levels[idx]["upgrades"][upgrade_name] += 1
