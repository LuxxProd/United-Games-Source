class_name InteractionRayCast3D extends RayCast3D

var _focused_node: Interactable3D = null


func _init() -> void:
	enabled = true

	collide_with_bodies = false
	collide_with_areas = true


func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("interact"):
			print("input detected")
		if _focused_node != null and event.is_action_pressed("interact"):
			_focused_node.interact()
			print("collision shape detected")

func _physics_process(_delta: float) -> void:
	force_raycast_update()
	var collider := get_collider() as Interactable3D
	_focused_node = collider
