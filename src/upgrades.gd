extends HBoxContainer

# left to right which weapons have been set
var weapon_idxs_set = []

var StarMarker = preload("res://src/starmarker.tscn")

var tex32s = [
	preload("res://sprites/ui/sidebar/fireball32.png"),
	preload("res://sprites/ui/sidebar/turd32.png"),
	preload("res://sprites/ui/sidebar/gnu32.png"),
	preload("res://sprites/ui/sidebar/boulder32.png"),
	preload("res://sprites/ui/sidebar/spear32.png")
]

var starboxes

func _ready():
	starboxes = [$"%Stars1", $"%Stars2", $"%Stars3"]
	
func reset():
	$"%Up1".texture = null
	$"%Up2".texture = null
	$"%Up3".texture = null
	weapon_idxs_set = []
	for sb in starboxes:
		for star in sb.get_children():
			star.set_level(0)
		

func update_upgrades():
	# weapon_idx to array of star levels (5 numbers in 0-3)
	var star_lvls = {0: [], 1: [], 2: [], 3: [], 4: []}
	for weapon_idx in len(G.weapon_levels):
		if not G.weapon_levels[weapon_idx]["owned"]:
			continue
		var nth = weapon_idxs_set.find(weapon_idx)
		if nth == -1:
			weapon_idxs_set.append(weapon_idx)
			match len(weapon_idxs_set):
				1:
					$"%Up1".texture = tex32s[weapon_idx]
				2:
					$"%Up2".texture = tex32s[weapon_idx]
				3:
					$"%Up3".texture = tex32s[weapon_idx]
		# update stars for this weapon
		var ups = G.weapon_levels[weapon_idx]["upgrades"]
		for grade in range(5):
			var grade_lvl = 0
			for key in ups:
				if ups[key] > grade:
					grade_lvl += 1
			star_lvls[weapon_idx].append(grade_lvl)
	var col_idx = 0
	for weapon_idx in weapon_idxs_set:
		var starbox = starboxes[col_idx]
		col_idx += 1
		for ch in starbox.get_children():
			ch.queue_free()
		for star_lvl in star_lvls[weapon_idx]:
			var star = StarMarker.instantiate()
			star.set_level(star_lvl)
			starbox.add_child(star)
