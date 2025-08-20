extends Node

#Toggle Fullscreen
var previous_size
var maximized_size

func _input(event):
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("toggle_fullscreen"):
			var win = get_window()
			if win.mode == Window.MODE_FULLSCREEN and previous_size == maximized_size:
				win.mode = Window.MODE_MAXIMIZED
				maximized_size = win.size
			elif win.mode == Window.MODE_FULLSCREEN:
				win.mode = Window.MODE_WINDOWED
				previous_size = win.size
			else:
				previous_size = win.size
				win.mode = Window.MODE_FULLSCREEN
