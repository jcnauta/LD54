extends TextureProgressBar


func update_bar():
	if G.boss_mode:
		max_value = G.boss.max_health
		value = G.boss.health
	else:
		max_value = G.lvl_progress_max
		value = G.lvl_progress
