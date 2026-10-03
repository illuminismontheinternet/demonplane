extends Node3D
class_name LobbyManager

signal signal_lobby_match_finished(bVictory: bool)

# TODO: move lobby to its own class
var lobby_level_world : Node3D
var bLevelActive = false

@onready var multiplayer_panel = $CanvasLayer/LobbyMultiplayerPanel
var decal_manager : Node3D

# similar to network manager
@onready var lobby_spawn_points = [
	$LobbySpawnPoint0,
	$LobbySpawnPoint1,
	$LobbySpawnPoint2,
	$LobbySpawnPoint3,
]
var respawn_point : Node3D
var current_spawn_index = -1

const PORT = 9999
const MAX_CLIENTS = 4
const player_scene = preload("res://player.tscn")

var active_players : Dictionary = {}
var enet_peer = ENetMultiplayerPeer.new()

func _ready() -> void:
	create_lobby_level()
	
func remove_player(peer_id):
	var leaving_player = get_node_or_null(str(peer_id))
	if leaving_player:
		# IMPORTANT: remove this from active_players
		active_players.erase(peer_id)
		leaving_player.queue_free()
		
func add_player(peer_id):
	# WARNING peer_id is unique but the originating call is only ran on the host machine
	var new_player = player_scene.instantiate()
	new_player.name = str(peer_id)
	#print("add_player - peer: ", peer_id)
	# IMPORTANT: players are children of the network manager NOT the level
	add_child(new_player)
	active_players[peer_id] = new_player
	#print(active_players)
		
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

func move_players_into_spawns(spawnPoints : Array[Node3D]):
	var players = get_tree().get_nodes_in_group("player")
	var iterator = 0
	for player in players:
		player.global_position = spawnPoints.get(iterator).global_position
	#for i in range(active_players.size()):
		#active_players.get(i).global_position = spawnPoints.get(i).global_position
		
func _on_offline_bots_pressed() -> void:
	multiplayer_panel.hide()
	add_player(1)

# level specific functions
func create_plane_level() -> void:
	bLevelActive = true
	call_deferred("remove_child", lobby_level_world)
	var plane_level_scene = load("res://levels/plane_level.tscn")
	var plane_level_world = plane_level_scene.instantiate()
	add_child(plane_level_world)
	# bind match ended signal
	plane_level_world.match_finished.connect(internal_lobby_match_finished)
	# get the decal manager
	decal_manager = plane_level_world.get_node("DecalManager")
	move_players_into_spawns(plane_level_world.spawn_locations)
	respawn_point = plane_level_world.respawn_point
	
func create_lobby_level() -> void:
	var lobby_level_scene = load("res://levels/lobby_level.tscn")
	lobby_level_world = lobby_level_scene.instantiate()
	add_child(lobby_level_world)
	# go forth and bind the area body entered 
	var plane_level_area = lobby_level_world.get_node("DemonPlaneArea3D")
	plane_level_area.body_entered.connect(_on_demon_plane_area_3d_body_entered)
	# get the decal manager
	decal_manager = lobby_level_world.get_node("DecalManager")
	
func _on_demon_plane_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("player_die") and not bLevelActive:
		create_plane_level()

# player specific functions
func get_spawn_point() -> Vector3:
	current_spawn_index = current_spawn_index + 1 % MAX_CLIENTS
	return lobby_spawn_points.get(current_spawn_index).global_position
	
func get_respawn_loc() -> Vector3:
	if respawn_point:
		return respawn_point.global_position
	else:
		return lobby_spawn_points.get(0).global_position
	
@rpc("any_peer", "call_local", "reliable")
func respawn_player_rpc(inPeerID):
	if not is_multiplayer_authority(): return
	var respawning_player = active_players[inPeerID]
	var health_component = respawning_player.get_node_or_null("Health")
	if health_component:
		health_component.restart_health()
		
func respawn_player() -> void:
	respawn_player_rpc.rpc()
	
func place_impact_decal(inReparentToStructure, inPosition, inNormal) -> void:
	if decal_manager:
		decal_manager.place_decal_impact(inReparentToStructure, inPosition, inNormal)
	else:
		print("lobby manager has no decal manager")

func internal_lobby_match_finished(bVictory : bool) -> void:
	signal_lobby_match_finished.emit(bVictory)
