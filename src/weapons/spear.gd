extends Sprite2D

var speed = 600
var v = Vector2()
var speed_x
var vy
var dir_factor = 1.0
var dmg

func _ready():
	v = Vector2(speed, 0).rotated(rotation)
	speed_x = v.x
	vy = v.y


func _process(delta):
	vy += 280 * delta * dir_factor
	var v = dir_factor * Vector2(speed_x, vy)
	position += v * delta
	rotation = atan2(dir_factor * v.y, dir_factor * v.x)
	if position.y < -200 and v.y * dir_factor < 0 or \
	   position.y > 1100 and v.y * dir_factor > 0 or \
	   position.x < -200 and v.x * dir_factor < 0 or \
	   position.x > 1600 and v.x * dir_factor > 0:
		queue_free()


func _on_area_2d_area_entered(area):
	area.get_parent().update_health(-dmg)
