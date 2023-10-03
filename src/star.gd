extends Sprite2D

signal star_pickup

@onready var player = $/root/Game.get_node(^"%Player")

var speed = 1000

func _process(delta):
	var playerpos = player.position
	var dvec = playerpos - position
	if dvec.length() < 400:
		var dir = (playerpos - position).normalized()
		position += speed * dir * delta
		if (playerpos - position).length() < 0.05 * speed:
			emit_signal("star_pickup")
			queue_free()
