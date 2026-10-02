extends Node3D
class_name NetworkManager

@onready var decal_manager = $DecalManager

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
@onready var respawn_point = $RespawnPoint0

@rpc("any_peer", "call_local", "reliable")
func place_impact_decal_rpc(inReparentToStructure, inPosition, inNormal) -> void:
	decal_manager.place_decal_impact(inReparentToStructure, inPosition, inNormal)
	
func place_impact_decal(inReparentToStructure, inPosition, inNormal) -> void:
	place_impact_decal_rpc.rpc(inReparentToStructure, inPosition, inNormal)
	
func get_respawn_loc() -> Vector3:
	return respawn_point.global_position
