extends Node

var commands = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		pass

func add_action_command(command: String, sig: FuncRef):
	pass
