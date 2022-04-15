extends Node2D

func _ready():
	self.RunTransition("FadeIn")

func RunTransition(name):
	$TransitionLayer/AnimationPlayer.play(name)

func TransitionEndedUnlockPlayer():
	$CurrentScene/Main/Player.set_locked_mode(false)
	#$CurrentScene.get_child(0).queue_free()

func TransitionEnded():
	print("yesssex")
