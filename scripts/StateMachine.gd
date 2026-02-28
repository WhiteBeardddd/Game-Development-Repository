# StateMachine.gd
# Place this in res://scripts/StateMachine.gd
class_name StateMachine extends Node

@export var initial_state: State = null

@onready var state: State = (func() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()


func _ready() -> void:
	for s: State in find_children("*", "State"):
		s.finished.connect(_on_state_finished)
	await owner.ready
	state.enter("")


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func _on_state_finished(next_state: String, data: Dictionary = {}) -> void:
	if not has_node(next_state):
		printerr(owner.name + ": State not found -> " + next_state)
		return
	var prev := state.name
	state.exit()
	state = get_node(next_state)
	state.enter(prev, data)
