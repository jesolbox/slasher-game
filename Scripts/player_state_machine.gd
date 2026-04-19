extends Node
class_name PlayerStateMachine

@export var initial_state: PlayerState

var current_state: PlayerState
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is PlayerState:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.player = get_parent()

	if initial_state:
		change_state(initial_state)

func change_state(new_state: PlayerState) -> void:
	if current_state:
		current_state.exit()

	current_state = new_state

	if current_state:
		current_state.enter()

func change_state_by_name(state_name: String) -> void:
	var key := state_name.to_lower()
	if states.has(key):
		change_state(states[key])

func handle_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)
