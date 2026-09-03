extends Node3D

@onready var multiplayer_panel = $"../CanvasLayer/MultiplayerPanel"
@onready var addy_box = $"../CanvasLayer/MultiplayerPanel/MarginContainer/VBoxContainer/Addy"

# spawn points
@onready var sp0 = $SpawnPoint0
@onready var sp1 = $SpawnPoint1
@onready var sp2 = $SpawnPoint2
@onready var sp3 = $SpawnPoint3

@onready var spawn_points = [
	sp0,
	sp1,
	sp2,
	sp3
]
var current_spawn_index = -1

var active_players : Dictionary = {}

const PORT = 9999
const MAX_CLIENTS = 4
const player_scene = preload("res://player.tscn")

var enet_peer = ENetMultiplayerPeer.new()

signal network_match_finished(bVictory: bool)

func get_spawn_point() -> Vector3:
	current_spawn_index = current_spawn_index + 1
	return spawn_points[current_spawn_index].global_position
	
func remove_player(peer_id):
	var leaving_player = get_node_or_null(str(peer_id))
	if leaving_player:
		# IMPORTANT: remove this from active_players
		active_players.erase(peer_id)
		leaving_player.queue_free()
		
func add_player(peer_id):
	var new_player = player_scene.instantiate()
	new_player.name = str(peer_id)
	# IMPORTANT: players are children of the network manager NOT the level
	add_child(new_player)
	new_player.global_position = get_spawn_point()
	# IMPORTANT: add this to the active_players
	active_players[peer_id] = new_player
		
func _on_host_button_pressed() -> void:
	multiplayer_panel.hide()
	enet_peer.create_server(PORT, MAX_CLIENTS)
	
	# the 'multiplayer' variable is a pre-existing object
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	
	#TODO remove this so upnp works
	# upnp_setup()
	
func _on_join_button_pressed() -> void:
	multiplayer_panel.hide()
	# TODO: change addy to the IP that works
	# addy_box.text will do and prevent any calls if its empty
	enet_peer.create_client("localhost", PORT)
	# the 'multiplayer' variable is a pre-existing object
	multiplayer.multiplayer_peer = enet_peer

func upnp_setup():
	var upnp = UPNP.new()
	var disc_res = upnp.discover()
	assert(disc_res == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discover Failed! ERROR %s" % disc_res)
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")
	
	var map_res = upnp.add_port_mapping(PORT)
	assert(map_res == UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed ERROR %s" % map_res)
	
	print("SUCCESS! JOIN ADDRESS: %s" % upnp.query_external_address())


func _on_level_match_finished(bVictory: bool) -> void:
	network_match_finished.emit(bVictory)
	#print("network manager end match - peer: ", multiplayer.get_unique_id())
	# DO NOT notify players manually let rpc handle it
	#for key in active_players:
		#active_players[key]._on_level_match_finished(bVictory)
