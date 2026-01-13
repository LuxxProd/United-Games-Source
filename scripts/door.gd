class_name Door3D extends Interactable3D

var is_active := false: set = set_is_active

var _tween_door: Tween = null

@onready var _static_body_collision_shape_3d: CollisionShape3D = %StaticBodyCollisionShape3D2
@onready var _door: Node3D = $CollisionShape3D


func interact() -> void:
	super()
	if multiplayer.is_server():
		set_is_active(not is_active)
		rpc("sync_door_state", is_active)
	else:
		rpc_id(1, "request_toggle_door") # Assuming server is peer ID 1


func set_is_active(value: bool) -> void:
	is_active = value
	var door_value := PI / -2.0 if is_active else 0.0
	
	if _tween_door != null:
		_tween_door.kill()
	_tween_door = create_tween().set_parallel(true)
	
	_tween_door.set_ease(Tween.EASE_OUT)
	_tween_door.set_trans(Tween.TRANS_BACK if is_active else Tween.TRANS_BOUNCE)
	
	_tween_door.tween_property(_door, "rotation:y", door_value, 1)

@rpc("any_peer")
func request_toggle_door():
	var sender_id = multiplayer.get_remote_sender_id()
	if multiplayer.is_server():
		set_is_active(not is_active)
		rpc("sync_door_state", is_active)

@rpc("authority", "call_remote")
func sync_door_state(value: bool):
	if not is_multiplayer_authority():
		set_is_active(value)
