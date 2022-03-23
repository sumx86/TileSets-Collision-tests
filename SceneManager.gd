extends Node2D

func _ready():
	self.RunTransition()

func RunTransition():
	$TransitionLayer/AnimationPlayer.play("FadeOut")

func TransitionEndedUnlockPlayer():
	$CurrentScene/Main/Player.set_locked_mode(false)
