extends Node
class_name RCPNode

const PORT = 9000
const LOCALHOST = "127.0.0.1"

var peer = ENetMultiplayerPeer.new()

func transmit(mtd: String, msg) -> void:
	rpc_id(1, mtd, msg)

func _ready():
	# Connect to server at localhost:9000
	var result = peer.create_client(LOCALHOST, PORT)
	if result != OK:
		push_error("Failed to connect to server: %s" % result)
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected():
	print("Connected to server")
	rpc_id(1, "register_game", "ButtonMen")

func _on_connection_failed():
	print("Failed to connect to server")

func _on_server_disconnected():
	print("Disconnected from server")

# RPC function to add a message stream that one pane will be watching
@rpc("any_peer", "call_local", "reliable")
func claim_pane():
	var sender_id = multiplayer.get_remote_sender_id()
	print("Claiming pane for client ", sender_id)

# RPC function to register other running games with image panes
@rpc("any_peer", "call_local", "reliable")
func register_game(game_name: String):
	print("Received game name:", game_name)

# RPC function to receive messages from clients
@rpc("any_peer", "call_local", "reliable")
func send_message(msg):
	print("Received from client:", msg)

# RPC function to send messages to clients
@rpc("authority")
func receive_message(msg: String):
	print("Message to client:", msg)
