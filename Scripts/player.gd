extends CharacterBody3D

@export var speed := 5.0
@export var acceleration := 8.0
@export var friction := 10.0
@export var gravity := 18.0
@export var mouse_sensitivity := 0.003

var move_input := Vector2.ZERO
var camera_pivot: Node3D
var camera: Camera3D
var state_machine: PlayerStateMachine

func _ready() -> void:
	camera_pivot = $Head
	camera = $Head/Camera3D
	state_machine = $StateMachine
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-75), deg_to_rad(75))

	state_machine.handle_input(event)

func _process(delta: float) -> void:
	state_machine.update(delta)

func _physics_process(delta: float) -> void:
	move_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	if not is_on_floor():
		velocity.y -= gravity * delta

	state_machine.physics_update(delta)
	move_and_slide()

func get_move_direction() -> Vector3:
	var input_dir := Vector3(move_input.x, 0, move_input.y)
	if input_dir.length() == 0:
		return Vector3.ZERO

	var dir := (transform.basis * input_dir).normalized()
	return dir
