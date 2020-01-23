extends Control

const PORT = 3000
const MAX_USERS = 4

onready var chat_display = $RoomUI/ChatDisplay
onready var chat_input = $RoomUI/ChatInput

func _ready():
	chat_input.connect("text_entered", self, "send_message")
	get_tree().connect("connected_to_server", self, "enter_room")
	get_tree().connect("network_peer_connected", self, "user_entered")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	$SetUp/LeaveButton.connect("button_up", self, "leave_room")
	$SetUp/JoinButton.connect("button_up", self, "join_room")
	$SetUp/HostButton.connect("button_up", self, "host_room")

func enter_room():
	$SetUp/LeaveButton.show()
	$SetUp/JoinButton.hide()
	$SetUp/IpEnter.hide()
	chat_display.text = "Successfully Joined Room\n"

func leave_room():
	$SetUp/LeaveButton.hide()
	$SetUp/JoinButton.show()
	$SetUp/HostButton.show()
	$SetUp/IpEnter.show()
	chat_display.text += "Left Room\n"
	get_tree().set_network_peer(null)

func host_room():
	var host = NetworkedMultiplayerENet.new()
	host.create_server(PORT, MAX_USERS)
	get_tree().set_network_peer(host)
	enter_room()
	chat_display.text = "Room Created\n"

func join_room():
	var ip = $SetUp/IpEnter.text
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, PORT)
	get_tree().set_network_peer(host)

func user_entered(id):
	chat_display.text += str(id) + " joined the room\n"

func user_exited(id):
	chat_display.text += str(id) + " left the room\n"

func _server_disconnected():
	chat_display.text += "Disconnected from Server\n"
	leave_room()

func send_message(msg):
	chat_input.text = ""
	var id = get_tree().get_network_unique_id()
	rpc("receive_message", id, msg)

remotesync func receive_message(id, msg):
	chat_display.text += str(id) + ": " + msg + "\n"