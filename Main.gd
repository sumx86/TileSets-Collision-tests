extends Node

var thread
var server
var client
var bytes

func _ready():
	self.server = TCP_Server.new()
	if self.server.listen(3000, "127.0.0.1") == 0:
		print("Server started on port 3000 with ip address 127.0.0.1!")
		self.set_process(true)
	
	$Player.spawn($StartPosition.position, "down")
	self.thread = Thread.new()
	thread.start(self, "_thread_function", "sex")

func _process(delta):
	if self.server.is_connection_available():
		self.client = self.server.take_connection()
		if self.client.is_connected_to_host():
			self.bytes = self.client.get_available_bytes()
			if self.bytes > 0:
				print(self.client.get_string(self.bytes))

func _thread_function(param):
	print(param)

func _exit_tree():
	self.thread.wait_to_finish()
	print("done")
