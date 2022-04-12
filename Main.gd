extends Node

var server
var client
var bytes
var connection_status
var total_packets = 255
var packets_sent = 1
var received_data = ""

var hosts = []
var host = {
	"ip":"",
	"hw":"",
	"trusted":true
}
var white_list = []

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 3000

func _ready():
	self.server = TCP_Server.new()
	if self.server.listen(self.SERVER_PORT, self.SERVER_IP) == 0:
		print("Server started on port " + str(self.SERVER_PORT) + " with ip address " + str(self.SERVER_IP) + "!")
		self.set_process(true)
		
	$Player.spawn($StartPosition.position, "down")

func _process(delta):
	if self.server.is_connection_available():
		self.client = self.server.take_connection()
		self.connection_status = self.client.get_status()
		if self.connection_status == StreamPeerTCP.STATUS_CONNECTED:
			self.bytes = self.client.get_available_bytes()
			if self.bytes > 0:
				self.handle_received_data()

func handle_received_data():
	self.received_data = self.client.get_string(self.bytes)
	if "Packet - " in self.received_data:
		self.packets_sent = int(self.received_data.split(" - ", false, 0)[1])
	else:
		self.new_host(self.received_data)
		self.hosts.append(self.host)
		print(self.hosts)
		
func find_duplicate():
	pass
	
func new_host(data):
	var _data = data.split("#", false, 0)
	self.host.ip = _data[0]
	self.host.hw = _data[1]
	if not self.host in self.white_list:
		self.host.trusted = false
