extends AudioStreamPlayer


func _input(event):
	if event.is_action_pressed("mute"):
		self.stream_paused = not self.stream_paused
