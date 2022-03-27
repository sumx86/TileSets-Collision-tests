extends KinematicBody2D

signal hit

export var speed = 150
export var step_sound = false
onready var machine_ray = $MachineRayCast2D1
onready var machine_ray2 = $MachineRayCast2D2
onready var wall_ray = $WallRayCast

var locked_mode
var direction = Vector2.ZERO
var cast_step = 20
var initial_frame_index = 0
var last_frame_index = 0

var last_input_direction
var input_directions: Array = []
var steps = 0

var state
enum states {
	IDLE,
	INTERACT,
	MOVE
}
enum directions {UP, DOWN, LEFT, RIGHT}

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	
func spawn(pos: Vector2, animation: String):
	self.position = pos
	$AnimatedSprite.animation = animation
	$AnimatedSprite.set_frame(0)
	self.show();
	self.locked_mode = true
	$CollisionShape2D.disabled = false

func _process(delta):
	self.direction = Vector2.ZERO
	if not self.locked_mode:
		self.process_player_movement(delta)
	else:
		$AnimatedSprite.stop()
		$AnimatedSprite.set_frame(self.initial_frame_index)

# The idea here is to get the last key pushed to the array and use it as a direction input
func _unhandled_input(event):
	if event is InputEventKey:
		if event.scancode == KEY_DOWN or event.scancode == KEY_UP or event.scancode == KEY_LEFT or event.scancode == KEY_RIGHT:
			if event.pressed:
				if !self.input_directions.has(event.scancode):
					self.input_directions.push_back(event.scancode)
					$AnimatedSprite.set_frame(self.initial_frame_index)
			else:
				if self.input_directions.has(event.scancode):
					self.input_directions.pop_at(self.input_directions.find(event.scancode, 0))

func process_player_movement(delta):
	if self.input_directions.size() > 0:
		self.last_input_direction = self.input_directions[-1]
		if self.last_input_direction == KEY_DOWN:  self.direction = Vector2(0,  1)
		if self.last_input_direction == KEY_UP:    self.direction = Vector2(0, -1)
		if self.last_input_direction == KEY_LEFT:  self.direction = Vector2(-1, 0)
		if self.last_input_direction == KEY_RIGHT: self.direction = Vector2(1,  0)
	
	if self.direction != Vector2.ZERO:
		self.determine_animation()
		self.move_player(delta)
	else:
		$AnimatedSprite.set_frame(self.initial_frame_index)
		
func determine_animation():
	match self.direction:
		Vector2(-1, 0), Vector2(1, 0):
			$AnimatedSprite.animation = "walkx"
			$AnimatedSprite.flip_h = self.direction.x < 0
		Vector2(0, 1):
			$AnimatedSprite.animation = "down"
		Vector2(0, -1):
			$AnimatedSprite.animation = "up"
	$AnimatedSprite.play()
	

func move_player(delta: float):
	if self.direction == Vector2(-1, 0):
		machine_ray2.cast_to = self.direction * self.cast_step
	else:
		machine_ray2.cast_to = Vector2.ZERO
	machine_ray2.force_raycast_update()
	
	machine_ray.cast_to = self.direction * self.cast_step
	machine_ray.force_raycast_update()
	
	wall_ray.cast_to = self.direction * self.cast_step
	wall_ray.force_raycast_update()
	
	if not machine_ray.is_colliding() and not machine_ray2.is_colliding() and not wall_ray.is_colliding():
		self.position += self.direction * speed * delta
		self.update_footsteps_sound()
	elif machine_ray.is_colliding() or machine_ray2.is_colliding():
		#self.interaction_manager.set_active(machine_ray.get_collider().name)
		print(machine_ray.get_collider().name)
	
func update_footsteps_sound():
	if not self.step_sound:
		return
	self.steps += 10.0
	if self.steps >= self.speed * 1.5:
		$Footsteps.play()
		self.steps = 0.0
	print(self.steps)

func update_footsteps_stop():
	if self.locked_mode or self.stopped:
		self.steps = 0
	
func _on_Player_body_entered(body):
	self.hide()
	self.emit_signal("hit")
	$CollisionShape2D.set_deferred("disabled", true)


func get_locked_mode():
	return self.locked_mode

func set_locked_mode(mode: bool):
	self.locked_mode = mode
