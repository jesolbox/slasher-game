extends CharacterBody3D

enum PlayerState {
	STATE_IDLE,
	STATE_WALK,
	STATE_WINDUP,
	STATE_ATTACK,
	STATE_RECOVERY
}

@export var walk_speed := 4.5
@export var sprint_speed := 6.5
@export var acceleration := 8.0
@export var friction := 12.0
@export var turn_speed := 8.0
@export var mouse_sensitivity := 0.003
@export var gravity := 18.0

@export var windup_time := 0.2
@export var attack_time := 0.12
@export var recovery_time := 0.35
@export var attack_range := 2.0

var camera: Camera3D
var state := PlayerState.STATE_IDLE
var state_timer := 0.0

func _ready():
	camera = $Camera3D
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	_handle_gravity(delta)
	_handle_state(delta)
	
	if state == PlayerState.STATE_IDLE or state == PlayerState.STATE_WALK:
		_handle_movement(delta)
	else:
		_handle_attack_movement_lock(delta)

	move_and_slide()

func _handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

func _handle_state(delta):
	match state:
		PlayerState.STATE_WINDUP:
			state_timer -= delta
			if state_timer <= 0.0:
				state = PlayerState.STATE_ATTACK
				state_timer = attack_time
				_do_attack()

		PlayerState.STATE_ATTACK:
			state_timer -= delta
			if state_timer <= 0.0:
				state = PlayerState.STATE_RECOVERY
				state_timer = recovery_time

		PlayerState.STATE_RECOVERY:
			state_timer -= delta
			if state_timer <= 0.0:
				state = PlayerState.STATE_IDLE

	if Input.is_action_just_pressed("attack") and (state == PlayerState.STATE_IDLE or state == PlayerState.STATE_WALK):
		state = PlayerState.STATE_WINDUP
		state_timer = windup_time

func _handle_movement(delta):
	var input_dir := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += transform.basis.x

	input_dir.y = 0.0
	input_dir = input_dir.normalized()

	var current_speed := walk_speed
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed

	if input_dir.length() > 0.0:
		var target_velocity = input_dir * current_speed

		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta * current_speed)
		velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta * current_speed)

		state = PlayerState.STATE_WALK
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta * walk_speed)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta * walk_speed)

		state = PlayerState.STATE_IDLE

func _handle_attack_movement_lock(delta):
	velocity.x = move_toward(velocity.x, 0.0, friction * delta * walk_speed)
	velocity.z = move_toward(velocity.z, 0.0, friction * delta * walk_speed)

func _do_attack():
	var space_state = get_world_3d().direct_space_state

	var origin = global_transform.origin
	var forward = -global_transform.basis.z
	var target = origin + forward * attack_range

	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [self]

	var result = space_state.intersect_ray(query)

	if result:
		var collider = result.collider
		print("Hit: ", collider.name)

		if collider.has_method("take_damage"):
			collider.take_damage(1)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
