extends TextureRect


func set_level(lvl):
	if lvl == 0:
		self_modulate = Color(0.0, 0.0, 0.0, 1.0)
	if lvl == 1:
		self_modulate = Color.hex(0x8a3f11ff)
	if lvl == 2:
		self_modulate = Color.SILVER
	if lvl == 3:
		self_modulate = Color.GOLD
