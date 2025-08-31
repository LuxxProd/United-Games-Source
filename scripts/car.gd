extends VehicleBody3D

var in_range := false
var is_active := false

signal active
signal not_active

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return # Ignore input if not the owner

	if is_active:
		steering = lerp(steering, Input.get_axis("move_right", "move_left") * 0.5, 5 * delta)
		engine_force = Input.get_axis("move_backward", "move_forward") * 100
	else:
		steering = 0
		engine_force = 0

func _activate() -> void:
	is_active = true
	emit_signal("active")

func _on_interactable_3d_interacted_with() -> void:
	if in_range and not is_active:
		_activate()
	else:
		is_active = false
		emit_signal("not_active")

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		is_active = false
		in_range = false
		emit_signal("not_active")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		var player_peer_id = body.get_multiplayer_authority()
		if player_peer_id != 0: # 0 means no authority
			set_multiplayer_authority(player_peer_id)
		in_range = true

@rpc("any_peer")
func request_vehicle_control():
	var requester_id = multiplayer.get_remote_sender_id()
	set_multiplayer_authority(requester_id)
	rpc_id(requester_id, "confirm_vehicle_control")
