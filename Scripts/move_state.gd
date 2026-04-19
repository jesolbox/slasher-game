extends PlayerState

func physics_update(delta: float) -> void:
	var move_dir := player.get_move_direction()

	if move_dir.length() <= 0.01:
		state_machine.change_state_by_name("idle")
		return

	player.velocity.x = move_toward(player.velocity.x, move_dir.x * player.speed, player.acceleration * delta)
	player.velocity.z = move_toward(player.velocity.z, move_dir.z * player.speed, player.acceleration * delta)

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		state_machine.change_state_by_name("attack")
