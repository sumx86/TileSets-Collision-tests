extends Area2D

var _data = {}
var good_bot = preload("res://Bots/goodbot.png")
var evil_bot = preload("res://Bots/evilbot.png")

func _ready():
	pass
	
func set_data(data, _position: Vector2):
	self._data = data
	self.position = _position
	if not self._data["trusted"]:
		$Sprite.set_texture(self.evil_bot)
	else:
		$Sprite.set_texture(self.good_bot)
	return self
