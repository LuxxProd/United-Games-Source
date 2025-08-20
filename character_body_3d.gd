extends CharacterBody3D

var can_move = true
var climbing = false
var swimming = false
var in_vehicle = false
var thirdperson = false
var vehicle_camera = false

@export var SPEED: float = 5
const JUMP_VELOCITY = 4.5

signal walking
signal not_walking

@rpc("any_peer", "call_local")
func set_position_rpc(pos: Vector3):
	position = pos

#Handle Physics
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor() and can_move:
			velocity.y = JUMP_VELOCITY
		elif swimming and Input.is_action_pressed("jump"):
			velocity.y = JUMP_VELOCITY
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
		if direction and can_move:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		elif direction and climbing:
			velocity.y = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()
		rpc("set_position_rpc", position)

#Handle Camera
var camera
var rotation_helper
var MOUSE_SENSITIVITY = 0.05

func _ready():
	camera = $Rotation_Helper/Camera3D
	rotation_helper = $Rotation_Helper
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if is_multiplayer_authority():
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotation_helper.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
			self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
			var camera_rot = rotation_helper.rotation_degrees
			camera_rot.x = clamp(camera_rot.x, -90, 90)
			rotation_helper.rotation_degrees = camera_rot
		
func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("camera") and not thirdperson and not vehicle_camera:
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_BACK if thirdperson else Tween.TRANS_BOUNCE)
			#tween.tween_property(camera, "rotation:y", Vector3(0.5,0,1), 1)
			camera.translate(Vector3(0.5,0,1))
			thirdperson = true
		elif Input.is_action_just_pressed("camera") and thirdperson and not vehicle_camera:
			camera.translate(Vector3(-0.5,0,-1))
			thirdperson = false
		elif Input.is_action_just_pressed("camera") and in_vehicle and not vehicle_camera:
			camera.translate(Vector3(0,1,4))
			vehicle_camera = true
		elif Input.is_action_just_pressed("camera") and in_vehicle and vehicle_camera:
			camera.translate(Vector3(0,-1,-4))
			vehicle_camera = false

#Handle Multiplayer
func _enter_tree() -> void:
	if is_multiplayer_authority():
		$Rotation_Helper/Camera3D.current = true
	print("Player ready with authority:", multiplayer.get_unique_id())

#Handle Vehicle Limitation
func _on_car_active() -> void:
	can_move = false
	in_vehicle = true
	emit_signal("not_walking")

func _on_car_not_active() -> void:
	can_move = true
	in_vehicle = false
	emit_signal("walking")
	if vehicle_camera:
		camera.translate(Vector3(0,-1,-4))

#Handle Climbing
func _on_ladder_climbing() -> void:
	climbing = true
	can_move = false

func _on_ladder_not_climbing() -> void:
	climbing = false
	can_move = true

#Handle Swimming
func _on_area_3d_body_entered(body: Node3D) -> void:
	swimming = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	swimming = false
