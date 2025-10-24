@tool
class_name StateMachine
extends Node

@export_tool_button("Connect State Signals") var connect_signals = connect_state_functions
@export_tool_button("Disconnect All State Signals") var disconnect_signals = disconnect_state_functions

## all the signals that the states care about. others can be used too, but must be connected manually.
const STATE_SIGNAL_LIST: PackedStringArray = ["state_entered", "state_exited", "state_physics_processing", "state_processing", "state_input", "state_unhandled_input"]

func _ready():
	pass

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if get_child_count() != 1:
		warnings.append("StateMachine must have exactly one child")
	else:
		var child: Node = get_child(0)
		if not child is StateChart:
			warnings.append("StateMachine's child must be a StateChart")
	return warnings

func connect_state_functions():
	disconnect_state_functions()
	
	for state: AtomicState in find_children("*", "AtomicState"):
		for child: State in state.find_children("*", "State"):
			state.state_entered.connect(child.state_entered, CONNECT_PERSIST)
			state.state_exited.connect(child.state_exited, CONNECT_PERSIST)
			state.state_processing.connect(child.state_processing, CONNECT_PERSIST)
			state.state_physics_processing.connect(child.state_physics_processing, CONNECT_PERSIST)
			state.state_input.connect(child.state_input, CONNECT_PERSIST)
			state.state_unhandled_input.connect(child.state_unhandled_input, CONNECT_PERSIST)

## disconnect all previous signals somehow. We may want the signals to connect to other non state functions, so nuking all connections is a bad idea.
## If a node is deleted all signals are cleaned up by Godot so maybe it doesn't matter too much. Although, if for some reason a State is moved 
## (e.g. old chase state is now the melee state), then the signals will persist and cause issues. Very much an edge case.
## To fix, somehow check if existing connections are to a State class that are not a child anymore.
func disconnect_state_functions():
	for state: AtomicState in find_children("*", "AtomicState"):
		for child in state.find_children("*", "State"):
			for signal_name: String in STATE_SIGNAL_LIST:
				for state_signal in state.get_signal_connection_list(signal_name):
					state_signal["signal"].disconnect(state_signal["callable"])
