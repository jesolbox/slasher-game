extends PlayerState

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	var move_dir :Vector3 = player.get_move_direction()

	player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction * delta)
	player.velocity.z = move_toward(player.velocity.z, 0.0, player.friction * delta)

	if move_dir.length() > 0.01:
		state_machine.change_state_by_name("move")

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		state_machine.change_state_by_name("attack")
