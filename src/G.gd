extends Node

var max_specials = 3
var lvl_progress_max = 50

var stars = 0
var stars_nextlevel
var gameover = false

var DEBUG = false

var total_upgrades = 0
var lvl_progress = 0

var difficulty = 0.0
var weapon_levels = []

var boss_mode
var boss

func reset():
	stars = 0
	stars_nextlevel = 4
	gameover = false
	lvl_progress = 0
	difficulty = 0.0
	total_upgrades = 0
	boss_mode = false
	boss = null
	weapon_levels = [
	{  # fireball
		"owned": false,
		"upgrades": {
			"rate": 1,
			"range": 1,
			"dmg": 1
		}
	},
	{  # turd
		"owned": false,
		"upgrades": {
			"rate": 1,
			"range": 1,
			"dmg": 1
		}
	},
	{  # stampede
		"owned": false,
		"upgrades": {
			"rate": 1,
			"healing": 1,
			"dmg": 1
		}
	},
	{  # quake
		"owned": false,
		"upgrades": {
			"dash_speed": 1,
			"boulders": 1,
			"dmg": 1
		}
	},
	{  # spear
		"owned": false,
		"upgrades": {
			"spears": 1,
			"dmg": 1,
			"rate": 1,  # chance on every jump
		}
	}
]

func enable_debug():
	weapon_levels = [
	{  # fireball
		"owned": false,
		"upgrades": {
			"rate": 5,
			"range": 5,
			"dmg": 5
		}
	},
	{  # turd
		"owned": false,
		"upgrades": {
			"rate": 5,
			"range": 5,
			"dmg": 5
		}
	},
	{  # stampede
		"owned": true,
		"upgrades": {
			"rate": 3,
			"healing": 3,
			"dmg": 3
		}
	},
	{  # quake
		"owned": true,
		"upgrades": {
			"dash_speed": 3,
			"boulders": 3,
			"dmg": 3
		}
	},
	{  # spear
		"owned": true,
		"upgrades": {
			"spears": 3,
			"dmg": 3,
			"rate": 3,  # chance on every jump
		}
	}
]
