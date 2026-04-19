extends PlayerState

@export var attack_duration := 0.45
var timer := 0.0

func enter() -> void:
	timer = attack_duration
	player.velocity.x = 0.0
	player.velocity.z = 0.0

	# Example:
	# player.get_node("AnimationPlayer").play("axe_slash")

func physics_update(delta: float) -> void:
	timer -= delta

	player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction * delta)
	player.velocity.z = move_toward(player.velocity.z, 0.0, player.friction * delta)

	if timer <= 0.0:
		if player.move_input.length() > 0.01:
			state_machine.change_state_by_name("move")
		else:
			state_machine.change_state_by_name("idle")
