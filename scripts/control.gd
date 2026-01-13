extends Control

func _init() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("options"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			visible = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			visible= true
