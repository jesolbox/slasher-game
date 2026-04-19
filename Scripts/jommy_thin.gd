extends CharacterBody3D

enum State {
	IDLE,
	FLEE
}

@export var walk_speed := 1.5
@export var run_speed := 4.0
@export var acceleration := 8.0
@export var gravity := 18.0
@export var detection_range := 10.0
@export var safe_range := 16.0
@export var wander_radius := 4.0
@export var idle_move_interval := 2.5

var state: State = State.IDLE
var player: Node3D = null
var wander_timer := 0.0
var wander_direction := Vector3.ZERO

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node3D
	randomize()
	pick_new_wander_direction()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if player == null:
		move_and_slide()
		return

	var to_player := player.global_position - global_position
	var flat_to_player := Vector3(to_player.x, 0.0, to_player.z)
	var distance := flat_to_player.length()

	match state:
		State.IDLE:
			handle_idle(delta, distance)

		State.FLEE:
			handle_flee(delta, flat_to_player, distance)

	move_and_slide()

func handle_idle(delta: float, distance: float) -> void:
	wander_timer -= delta

	if wander_timer <= 0.0:
		pick_new_wander_direction()

	var target_velocity := wander_direction * walk_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if wander_direction.length() > 0.01:
		look_at(global_position + wander_direction, Vector3.UP)

	if distance <= detection_range:
		change_state(State.FLEE)

func handle_flee(delta: float, flat_to_player: Vector3, distance: float) -> void:
	var flee_dir := (-flat_to_player).normalized()

	var target_velocity := flee_dir * run_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if flee_dir.length() > 0.01:
		look_at(global_position + flee_dir, Vector3.UP)

	if distance >= safe_range:
		change_state(State.IDLE)

func pick_new_wander_direction() -> void:
	wander_timer = randf_range(1.5, idle_move_interval)
	
	if randf() < 0.3:
		wander_direction = Vector3.ZERO
	else:
		var angle := randf_range(0.0, TAU)
		wander_direction = Vector3(cos(angle), 0.0, sin(angle)).normalized()

func change_state(new_state: State) -> void:
	if state == new_state:
		return

	state = new_state

	match state:
		State.IDLE:
			pick_new_wander_direction()
			print("Capsule man -> IDLE")
		State.FLEE:
			print("Capsule man -> FLEE")
