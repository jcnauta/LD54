extends Sprite2D

var speed = 800
var v = Vector2()
var dir_factor = 1.0
var countdown
var dmg

func _ready():
	v = Vector2(speed, 0).rotated(rotation)

func _process(delta):
	position += v * delta * dir_factor
	countdown -= delta
	if countdown < 0.0 or \
	   position.y < -200 and v.y * dir_factor < 0 or \
	   position.y > 1100 and v.y * dir_factor > 0 or \
	   position.x < -200 and v.x * dir_factor < 0 or \
	   position.x > 1600 and v.x * dir_factor > 0:
		queue_free()

func _on_area_2d_area_entered(area):
	area.get_parent().update_health(-dmg)
	self.queue_free()
