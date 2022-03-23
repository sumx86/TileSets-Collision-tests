extends Area2D

#onready var player = self.get_parent().get_node("Player")

func _ready():
	pass


func _on_Machine_body_entered(body):
	#self.player.set_locked_mode(not self.player.get_locked_mode())
	pass
