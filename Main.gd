extends Node

var server
var client
var bytes
var connection_status
var total_packets = 255
var packets_sent = 1
var received_data = ""

var hosts = []
var white_list = []
var white_list_initialized: bool = false

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 3000
const WHITE_LIST_FILE = "white-list.txt"

func _ready():
	self.server = TCP_Server.new()
	if self.server.listen(self.SERVER_PORT, self.SERVER_IP) == 0:
		print("Server started on port " + str(self.SERVER_PORT) + " with ip address " + str(self.SERVER_IP) + "!")
		self.set_process(true)
	
	self.initialize_white_list()
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
		self.add_host(self.received_data.split("#", false, 0))
		print(self.hosts)

func find_duplicate():
	pass
	
func add_host(data):
	var host = {"ipaddr":data[0], "hwaddr":data[1], "trusted":false}
	if self.white_list_initialized:
		for entry in self.white_list:
			if entry == host["hwaddr"]:
				host['trusted'] = true
	self.hosts.append(host)

func load_file(fname):
	var file = File.new()
	var error = file.open(fname, File.READ)
	if error != OK:
		print("Error opening file -> ", error)
		return null
	
	if file.get_len() <= 0:
		print("File " + fname + " is empty!")
		return null
	return file

func initialize_white_list():
	var file = self.load_file(WHITE_LIST_FILE)
	if file != null:
		while not file.eof_reached():
			var entry = file.get_line().strip_edges()
			if entry.length() > 0:
				self.white_list.append(entry)
				if not self.white_list_initialized:
					self.white_list_initialized = true
