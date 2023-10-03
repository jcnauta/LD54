extends Sprite2D

var dir
var speed
var rotspeed
var v
var dmg

func _init():
	speed = 200 + randf() * 150
	rotspeed = ((2 * (randi() % 2)) - 1) * (1 + randf())
	rotation = 2 * PI * randf()

func _process(delta):
	position += delta * v
	v.y += delta * 200
	rotation += delta * rotspeed
	
func set_dir(dir):
	v = dir * speed

func _on_area_2d_area_entered(area):
	area.get_parent().update_health(-dmg)
