extends Control

func _init() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("options"):
		if not visible:
			visible = true
			
		else:
			visible= false
